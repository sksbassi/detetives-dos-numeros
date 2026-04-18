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

@onready var lives_label: Label = $RootMargin/RootVBox/InfoPanel/InfoMargin/InfoVBox/LivesLabel
@onready var phase_label: Label = $RootMargin/RootVBox/InfoPanel/InfoMargin/InfoVBox/PhaseLabel
@onready var question_label: Label = $RootMargin/RootVBox/InfoPanel/InfoMargin/InfoVBox/QuestionLabel
@onready var feedback_label: Label = $RootMargin/RootVBox/InfoPanel/InfoMargin/InfoVBox/FeedbackLabel
@onready var options_vbox: VBoxContainer = $RootMargin/RootVBox/InfoPanel/InfoMargin/InfoVBox/OptionsVBox
@onready var start_overlay: ColorRect = $StartOverlay
@onready var pause_overlay: ColorRect = $PauseOverlay
@onready var end_overlay: ColorRect = $EndOverlay
@onready var end_text: Label = $EndOverlay/EndCenter/EndPanel/EndMargin/EndVBox/EndText

func _ready() -> void:
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
