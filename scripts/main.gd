extends Control

const TOTAL_LIVES := 2
const PHASES := [
	{
		"title": "Fase 1 de 2",
		"question": "Quanto e 2 + 3?",
		"answer": 5,
		"options": [4, 5, 6, 7]
	},
	{
		"title": "Fase 2 de 2",
		"question": "Quanto e 6 - 2?",
		"answer": 4,
		"options": [3, 4, 5, 6]
	}
]

var current_phase_index := 0
var lives := TOTAL_LIVES
var selected_answer := -1
var option_buttons: Array[Button] = []

@onready var ui_click_player: AudioStreamPlayer = $UiClickPlayer
@onready var lives_label: Label = $RootMargin/RootVBox/InfoPanel/InfoMargin/InfoVBox/LivesLabel
@onready var phase_label: Label = $RootMargin/RootVBox/InfoPanel/InfoMargin/InfoVBox/PhaseLabel
@onready var question_label: Label = $RootMargin/RootVBox/InfoPanel/InfoMargin/InfoVBox/QuestionLabel
@onready var feedback_label: Label = $RootMargin/RootVBox/InfoPanel/InfoMargin/InfoVBox/FeedbackLabel
@onready var options_vbox: VBoxContainer = $RootMargin/RootVBox/InfoPanel/InfoMargin/InfoVBox/OptionsVBox
@onready var start_overlay: ColorRect = $StartOverlay
@onready var pause_overlay: ColorRect = $PauseOverlay
@onready var end_overlay: ColorRect = $EndOverlay
@onready var end_text: Label = $EndOverlay/EndCenter/EndPanel/EndMargin/EndVBox/EndText
@onready var volume_label: Label = $PauseOverlay/PauseCenter/PausePanel/PauseMargin/PauseVBox/VolumeLabel
@onready var volume_slider: HSlider = $PauseOverlay/PauseCenter/PausePanel/PauseMargin/PauseVBox/VolumeSlider

func _ready() -> void:
	ui_click_player.stream = _create_click_sound()
	_apply_volume(volume_slider.value)
	_reset_game()

func _reset_game() -> void:
	lives = TOTAL_LIVES
	current_phase_index = 0
	selected_answer = -1
	start_overlay.visible = true
	pause_overlay.visible = false
	end_overlay.visible = false
	_update_phase()

func _update_phase() -> void:
	var phase: Dictionary = PHASES[current_phase_index]
	lives_label.text = "Vidas: %d" % lives
	phase_label.text = str(phase.get("title", "Fase"))
	question_label.text = str(phase.get("question", "Pergunta"))
	feedback_label.text = "Escolha uma resposta."
	selected_answer = -1
	for child in options_vbox.get_children():
		child.queue_free()
	option_buttons.clear()
	for option in phase.get("options", []):
		var button := Button.new()
		button.text = str(option)
		button.pressed.connect(_on_option_pressed.bind(int(option)))
		options_vbox.add_child(button)
		option_buttons.append(button)

func _on_option_pressed(value: int) -> void:
	ui_click_player.play()
	selected_answer = value
	for button in option_buttons:
		button.disabled = button.text == str(value)
	_check_answer()

func _check_answer() -> void:
	var phase: Dictionary = PHASES[current_phase_index]
	if selected_answer == int(phase.get("answer", -1)):
		feedback_label.text = "Resposta correta."
		if current_phase_index == PHASES.size() - 1:
			_show_end("Voce concluiu as 2 fases.")
			return
		current_phase_index += 1
		_update_phase()
		return
	lives -= 1
	lives_label.text = "Vidas: %d" % lives
	if lives <= 0:
		_show_end("Voce perdeu todas as vidas.")
		return
	feedback_label.text = "Resposta errada. Voce perdeu 1 vida."

func _show_end(message: String) -> void:
	end_text.text = message
	end_overlay.visible = true
	pause_overlay.visible = false
	start_overlay.visible = false

func _on_start_pressed() -> void:
	start_overlay.visible = false
	pause_overlay.visible = false
	end_overlay.visible = false
	_update_phase()

func _on_pause_pressed() -> void:
	if start_overlay.visible or end_overlay.visible:
		return
	pause_overlay.visible = true

func _on_resume_pressed() -> void:
	pause_overlay.visible = false

func _on_restart_pressed() -> void:
	_reset_game()

func _on_play_again_pressed() -> void:
	_reset_game()

func _on_volume_slider_value_changed(value: float) -> void:
	_apply_volume(value)

func _apply_volume(value: float) -> void:
	var bus_index: int = AudioServer.get_bus_index("Master")
	if bus_index == -1:
		bus_index = 0
	var linear_value: float = clampf(value / 100.0, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_index, linear_value <= 0.001)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(linear_value, 0.001)))
	volume_label.text = "Volume: %d%%" % int(round(value))

func _create_click_sound() -> AudioStreamWAV:
	var mix_rate := 44100
	var duration := 0.18
	var sample_count := int(mix_rate * duration)
	var pcm_data := PackedByteArray()
	pcm_data.resize(sample_count * 2)
	for i in sample_count:
		var progress: float = float(i) / float(sample_count)
		var envelope: float = pow(1.0 - progress, 1.8)
		var frequency: float = 740.0
		if progress > 0.45:
			frequency = 988.0
		var phase: float = float(i) / float(mix_rate)
		var sample_value: float = sin(TAU * frequency * phase) * envelope * 0.28
		var sample_int: int = int(round(sample_value * 32767.0))
		pcm_data[i * 2] = sample_int & 0xFF
		pcm_data[i * 2 + 1] = (sample_int >> 8) & 0xFF
	var sound := AudioStreamWAV.new()
	sound.data = pcm_data
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = mix_rate
	sound.stereo = false
	return sound
