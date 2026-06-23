extends Control

const CONTENT_PATH := "res://data/game_content.json"
const FONT_BODY_PATH := "res://assets/fonts/comic.ttf"
const FONT_BOLD_PATH := "res://assets/fonts/comicbd.ttf"
const DEFAULT_TIME_LIMIT := 300.0
const URGENCY_THRESHOLD := 30
const MAX_CHILD_NUMBER := 20

const GameContent := preload("res://scripts/game_content.gd")
const ThemeFactory := preload("res://scripts/theme_factory.gd")

const QUACK_AUDIO := "res://assets/audio/duck_quack.wav"
const CORRECT_AUDIO := "res://assets/audio/correct_chime.wav"
const WRONG_AUDIO := "res://assets/audio/wrong_boop.wav"
const REWARD_AUDIO := "res://assets/audio/bubble_pop.wav"

var game_data: Dictionary = {}
var phases: Array = []
var hero_path: Array[String] = []
var story_modal_lines: Array[String] = []
var suggestions: Array[String] = []
var badge_catalog: Dictionary = {}

var player_name := ""
var score := 0
var badges: Array[Dictionary] = []
var current_phase_index := 0
var current_phase_source: Dictionary = {}
var current_phase: Dictionary = {}
var current_question: Dictionary = {}
var current_round_index := 0
var boss_lives := 0
var player_lives := 0
var in_boss_phase := false
var is_test_phase := false
var phase_in_progress := false
var needs_retry_phase := false
var current_time_limit := DEFAULT_TIME_LIMIT
var timer_remaining := DEFAULT_TIME_LIMIT
var last_urgency_second := -1
var selected_answer: Variant = null
var selected_button: Button = null
var streak_fast_correct := 0
var selected_option_buttons: Array[Button] = []
var phase_setup_serial := 0
var master_volume_linear := 0.82
var fireworks_layer: Control
var score_float_layer: Control
var victory_overlay: ColorRect
var victory_title_label: Label
var victory_body_label: Label
var btn_victory_home: Button
var btn_victory_prizes: Button
var prizes_gallery_overlay: ColorRect
var prizes_gallery_grid: GridContainer
var prizes_gallery_empty_label: Label
var btn_prizes_close: Button
var feedback_modal_overlay: ColorRect
var feedback_modal_title_label: Label
var feedback_modal_body_label: Label
var feedback_modal_icon_label: Label
var feedback_modal_badge_wrap: Control
var feedback_modal_badge_card: PanelContainer
var feedback_modal_badge_icon: Label
var feedback_modal_badge_title: Label
var feedback_modal_badge_body: Label
var feedback_modal_primary_button: Button
var feedback_modal_secondary_button: Button
var feedback_modal_primary_action := ""
var feedback_modal_secondary_action := ""
var pause_tabs: TabContainer
var pause_prizes_grid: GridContainer
var pause_prizes_empty_label: Label
var volume_slider: HSlider
var volume_value_label: Label
var start_story_scroll: ScrollContainer
var journey_scroll: ScrollContainer
var btn_pause_menu: Button
var btn_pause_prizes: Button
var btn_pause_sound: Button
var btn_pause_prizes_close: Button
var btn_pause_sound_close: Button

var quack_player: AudioStreamPlayer
var correct_player: AudioStreamPlayer
var wrong_player: AudioStreamPlayer
var urgency_player: AudioStreamPlayer
var reward_player: AudioStreamPlayer
var click_player: AudioStreamPlayer
var celebration_player: AudioStreamPlayer

@onready var background_rect: ColorRect = $Background
@onready var backdrop_glow: ColorRect = $BackgroundDecor/BackdropGlow
@onready var blob_left: ColorRect = $BackgroundDecor/BlobLeft
@onready var blob_right: ColorRect = $BackgroundDecor/BlobRight
@onready var ambient_back: Control = $BackgroundDecor/AmbientLayerBack
@onready var ambient_front: Control = $BackgroundDecor/AmbientLayerFront
@onready var main_scroll: ScrollContainer = $MainCenter
@onready var outer_margin: MarginContainer = $MainCenter/OuterMargin
@onready var main_container: PanelContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer
@onready var main_margin: MarginContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin
@onready var main_vbox: VBoxContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox
@onready var body_row: HBoxContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow
@onready var side_column: VBoxContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn
@onready var player_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/HUDCard/HUDMargin/HUDVBox/TopRow/PlayerLabel
@onready var score_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/HUDCard/HUDMargin/HUDVBox/TopRow/ScoreLabel
@onready var timer_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/HUDCard/HUDMargin/HUDVBox/TopRow/TimerLabel
@onready var hud_top_row: HBoxContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/HUDCard/HUDMargin/HUDVBox/TopRow
@onready var btn_journey: Button = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/HUDCard/HUDMargin/HUDVBox/TopRow/BtnJourney
@onready var btn_pause: Button = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/HUDCard/HUDMargin/HUDVBox/TopRow/BtnPause
@onready var title_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/HUDCard/HUDMargin/HUDVBox/TitleLabel
@onready var progress_bar: ProgressBar = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/HUDCard/HUDMargin/HUDVBox/ProgressBar
@onready var progress_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/HUDCard/HUDMargin/HUDVBox/ProgressLabel

@onready var stage_card: PanelContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard
@onready var stage_margin: MarginContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard/StageMargin
@onready var phase_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard/StageMargin/StageVBox/PhaseLabel
@onready var story_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard/StageMargin/StageVBox/StoryLabel
@onready var mentor_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard/StageMargin/StageVBox/MentorLabel
@onready var stage_name_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard/StageMargin/StageVBox/StageFrame/StageFrameMargin/StageFrameVBox/StageNameLabel
@onready var stage_hint_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard/StageMargin/StageVBox/StageHintLabel
@onready var stage_canvas: PanelContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard/StageMargin/StageVBox/StageFrame/StageFrameMargin/StageFrameVBox/StageCanvas
@onready var stage_particles: Control = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard/StageMargin/StageVBox/StageFrame/StageFrameMargin/StageFrameVBox/StageCanvas/StageCanvasMargin/StageCanvasRoot/StageParticles
@onready var stage_rows: VBoxContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard/StageMargin/StageVBox/StageFrame/StageFrameMargin/StageFrameVBox/StageCanvas/StageCanvasMargin/StageCanvasRoot/StageRowsCenter/StageRows
@onready var boss_avatar_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/StageCard/StageMargin/StageVBox/StageFrame/StageFrameMargin/StageFrameVBox/StageCanvas/StageCanvasMargin/StageCanvasRoot/BossAvatarLabel

@onready var question_card: PanelContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/QuestionCard
@onready var question_margin: MarginContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/QuestionCard/QuestionMargin
@onready var theme_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/QuestionCard/QuestionMargin/QuestionVBox/ThemeLabel
@onready var question_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/QuestionCard/QuestionMargin/QuestionVBox/QuestionLabel
@onready var feedback_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/QuestionCard/QuestionMargin/QuestionVBox/FeedbackLabel

@onready var options_card: PanelContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/OptionsCard
@onready var options_margin: MarginContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/OptionsCard/OptionsMargin
@onready var options_title_label: Label = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/OptionsCard/OptionsMargin/OptionsVBox/OptionsTitleLabel
@onready var options_grid: GridContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/OptionsCard/OptionsMargin/OptionsVBox/OptionsGrid

@onready var actions_card: PanelContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/ActionsCard
@onready var actions_margin: MarginContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/ActionsCard/ActionsMargin
@onready var actions_row: HBoxContainer = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/ActionsCard/ActionsMargin/ActionsRow
@onready var btn_confirm: Button = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/ActionsCard/ActionsMargin/ActionsRow/BtnConfirm
@onready var btn_next: Button = $MainCenter/OuterMargin/ContentColumn/MainContainer/MainMargin/MainVBox/BodyRow/SideColumn/ActionsCard/ActionsMargin/ActionsRow/BtnNext

@onready var reward_popup: PanelContainer = $RewardPopupLayer/RewardPopup
@onready var btn_reward_close: Button = $RewardPopupLayer/RewardPopup/BtnRewardClose
@onready var reward_popup_label: Label = $RewardPopupLayer/RewardPopup/RewardPopupMargin/RewardPopupVBox/RewardPopupTitle
@onready var reward_popup_body: Label = $RewardPopupLayer/RewardPopup/RewardPopupMargin/RewardPopupVBox/RewardPopupBody
@onready var flash_overlay: ColorRect = $FeedbackFlash
@onready var transition_overlay: ColorRect = $TransitionOverlay

@onready var start_overlay: ColorRect = $StartOverlay
@onready var start_card: PanelContainer = $StartOverlay/StartCenter/StartCard
@onready var start_title_label: Label = $StartOverlay/StartCenter/StartCard/StartMargin/StartVBox/StartTitle
@onready var start_subtitle_label: Label = $StartOverlay/StartCenter/StartCard/StartMargin/StartVBox/StartSubtitle
@onready var name_input: LineEdit = $StartOverlay/StartCenter/StartCard/StartMargin/StartVBox/NameInput
@onready var btn_suggestion_1: Button = $StartOverlay/StartCenter/StartCard/StartMargin/StartVBox/SuggestionRow/BtnSuggestion1
@onready var btn_suggestion_2: Button = $StartOverlay/StartCenter/StartCard/StartMargin/StartVBox/SuggestionRow/BtnSuggestion2
@onready var btn_suggestion_3: Button = $StartOverlay/StartCenter/StartCard/StartMargin/StartVBox/SuggestionRow/BtnSuggestion3
@onready var start_story_label: Label = $StartOverlay/StartCenter/StartCard/StartMargin/StartVBox/StartStory
@onready var btn_start_game: Button = $StartOverlay/StartCenter/StartCard/StartMargin/StartVBox/StartButtons/BtnStartGame
@onready var btn_test_phase: Button = $StartOverlay/StartCenter/StartCard/StartMargin/StartVBox/StartButtons/BtnTestPhase
@onready var btn_open_journey_start: Button = $StartOverlay/StartCenter/StartCard/StartMargin/StartVBox/StartButtons/BtnOpenJourneyStart

@onready var journey_overlay: ColorRect = $JourneyOverlay
@onready var journey_card: PanelContainer = $JourneyOverlay/JourneyCenter/JourneyCard
@onready var journey_vbox: VBoxContainer = $JourneyOverlay/JourneyCenter/JourneyCard/JourneyMargin/JourneyVBox
@onready var btn_journey_back: Button = $JourneyOverlay/JourneyCenter/JourneyCard/JourneyMargin/JourneyVBox/JourneyTopRow/BtnJourneyBack
@onready var btn_journey_close: Button = $JourneyOverlay/JourneyCenter/JourneyCard/JourneyMargin/JourneyVBox/JourneyTopRow/BtnJourneyClose
@onready var journey_path_label: Label = $JourneyOverlay/JourneyCenter/JourneyCard/JourneyMargin/JourneyVBox/JourneyPathLabel
@onready var journey_story_label: Label = $JourneyOverlay/JourneyCenter/JourneyCard/JourneyMargin/JourneyVBox/JourneyStoryLabel

@onready var pause_overlay: ColorRect = $PauseOverlay
@onready var pause_card: PanelContainer = $PauseOverlay/PauseCenter/PauseCard
@onready var btn_pause_overlay_close: Button = $PauseOverlay/PauseCenter/PauseCard/BtnPauseOverlayClose
@onready var btn_continue: Button = $PauseOverlay/PauseCenter/PauseCard/PauseMargin/PauseVBox/BtnContinue
@onready var btn_restart_phase: Button = $PauseOverlay/PauseCenter/PauseCard/PauseMargin/PauseVBox/BtnRestartPhase
@onready var btn_restart_game: Button = $PauseOverlay/PauseCenter/PauseCard/PauseMargin/PauseVBox/BtnRestartGame
@onready var btn_back_to_start: Button = $PauseOverlay/PauseCenter/PauseCard/PauseMargin/PauseVBox/BtnBackToStart

func _ready() -> void:
	randomize()
	theme = ThemeFactory.build_theme(FONT_BODY_PATH, FONT_BOLD_PATH)
	get_viewport().size_changed.connect(_update_layout_constraints)
	_load_content()
	_create_audio_players()
	_create_fireworks_layer()
	_create_feedback_modal()
	_create_victory_overlay()
	_create_prizes_gallery_overlay()
	_create_pause_hud_buttons()
	_wire_buttons()
	_upgrade_start_overlay()
	_upgrade_journey_overlay()
	_upgrade_pause_overlay()
	_prepare_static_ui()
	_prepare_motion()
	_prepare_overlays()
	_apply_master_volume()
	_update_layout_constraints()
	_show_start_overlay()

func _process(delta: float) -> void:
	if not phase_in_progress:
		return
	if start_overlay.visible or journey_overlay.visible or pause_overlay.visible:
		return
	if feedback_modal_overlay != null and feedback_modal_overlay.visible:
		return
	if victory_overlay != null and victory_overlay.visible:
		return
	if prizes_gallery_overlay != null and prizes_gallery_overlay.visible:
		return
	timer_remaining = max(timer_remaining - delta, 0.0)
	timer_label.text = _format_time_label(timer_remaining)
	var whole_second := int(ceil(timer_remaining))
	if whole_second <= URGENCY_THRESHOLD and whole_second > 0 and whole_second != last_urgency_second:
		last_urgency_second = whole_second
		_play_sound(urgency_player)
	if timer_remaining <= 0.0:
		_handle_timeout_modal()

func _load_content() -> void:
	game_data = GameContent.load_game_data(CONTENT_PATH)
	phases = game_data.get("phases", [])
	hero_path = GameContent.to_string_array(game_data.get("journey_path", []))
	story_modal_lines = GameContent.to_string_array(game_data.get("story_modal", []))
	suggestions = GameContent.to_string_array(game_data.get("name_suggestions", []))
	badge_catalog = game_data.get("badges", {})

func _wire_buttons() -> void:
	btn_start_game.pressed.connect(_on_start_game_pressed)
	btn_test_phase.pressed.connect(_on_test_phase_pressed)
	btn_open_journey_start.pressed.connect(_show_journey_overlay)
	btn_journey.pressed.connect(_show_journey_overlay)
	btn_pause.pressed.connect(_show_pause_overlay)
	if btn_pause_prizes != null:
		btn_pause_prizes.pressed.connect(_open_pause_prizes_tab)
	if btn_pause_sound != null:
		btn_pause_sound.pressed.connect(_open_pause_sound_tab)
	btn_confirm.pressed.connect(_on_confirm_pressed)
	btn_next.pressed.connect(_on_next_pressed)
	btn_continue.pressed.connect(_hide_pause_overlay)
	btn_restart_phase.pressed.connect(_restart_current_phase)
	btn_restart_game.pressed.connect(_restart_whole_game)
	btn_back_to_start.pressed.connect(_show_start_overlay)
	btn_pause_overlay_close.pressed.connect(_hide_pause_overlay)
	btn_journey_back.pressed.connect(_hide_journey_overlay)
	btn_journey_close.pressed.connect(_hide_journey_overlay)
	btn_reward_close.pressed.connect(_hide_reward_popup)
	if btn_victory_home != null:
		btn_victory_home.pressed.connect(_show_start_overlay)
	if btn_victory_prizes != null:
		btn_victory_prizes.pressed.connect(_show_prizes_gallery_overlay)
	if btn_prizes_close != null:
		btn_prizes_close.pressed.connect(_hide_prizes_gallery_overlay)

	var suggestion_buttons: Array[Button] = [btn_suggestion_1, btn_suggestion_2, btn_suggestion_3]
	for index in range(min(suggestions.size(), suggestion_buttons.size())):
		var button := suggestion_buttons[index]
		button.text = suggestions[index]
		button.pressed.connect(_on_suggestion_pressed.bind(button.text))

	for button in [
		btn_confirm, btn_next, btn_pause, btn_journey,
		btn_start_game, btn_test_phase, btn_open_journey_start,
		btn_continue, btn_restart_phase, btn_restart_game, btn_back_to_start,
		btn_journey_back, btn_journey_close, btn_reward_close, btn_pause_overlay_close,
		btn_suggestion_1, btn_suggestion_2, btn_suggestion_3
	]:
		_attach_button_motion(button)
	for button in [btn_pause_prizes, btn_pause_sound]:
		if button != null:
			_attach_button_motion(button)

func _prepare_static_ui() -> void:
	title_label.text = str(game_data.get("title", "Detetive dos Números"))
	progress_label.text = "✨ A aventura vai começar."
	start_title_label.text = str(game_data.get("title", "Detetive dos Números"))
	start_subtitle_label.text = "Escolha um nome, descubra a jornada encantada e comece sua investigação."
	start_story_label.text = "\n".join(story_modal_lines)
	_refresh_journey_copy()
	options_title_label.text = "Escolha uma alternativa"
	reward_popup.visible = false
	progress_bar.max_value = max(phases.size(), 1)
	progress_bar.value = 0
	feedback_label.text = "✨ Observe o cenário, escolha sua resposta e confirme."
	stage_hint_label.text = ""
	boss_avatar_label.visible = false
	background_rect.color = Color("#F9F5FF")
	player_label.text = "🕵️ Explorador"
	score_label.text = "⭐ 0"
	timer_label.text = _format_time_label(DEFAULT_TIME_LIMIT)
	btn_pause.text = "📋 Menu/Pause"

func _refresh_journey_copy() -> void:
	var hero_name := player_name if not player_name.is_empty() else (suggestions[0] if not suggestions.is_empty() else "Pequeno Detetive")
	var progress_text := "✨ Sua jornada está prestes a começar."
	if not start_overlay.visible:
		progress_text = "⭐ Estrelas atuais: %d    🏅 Selos conquistados: %d" % [score, badges.size()]
	journey_path_label.text = "🗺️ Jornada de %s\n\n%s\n\n%s" % [hero_name, "\n".join(hero_path), progress_text]
	journey_story_label.text = "📖 História encantada\n\n%s" % "\n\n".join(story_modal_lines)

func _prepare_motion() -> void:
	for card in [stage_card, question_card, options_card, actions_card]:
		card.modulate.a = 1.0
		card.scale = Vector2.ONE

func _prepare_overlays() -> void:
	flash_overlay.visible = false
	flash_overlay.color = Color(1, 1, 1, 0)
	transition_overlay.color = Color(1, 1, 1, 0)
	main_scroll.follow_focus = false
	main_scroll.horizontal_scroll_mode = 0
	main_scroll.vertical_scroll_mode = 1
	reward_popup.visible = false
	if feedback_modal_overlay != null:
		feedback_modal_overlay.visible = false

func _create_feedback_modal() -> void:
	feedback_modal_overlay = ColorRect.new()
	feedback_modal_overlay.visible = false
	feedback_modal_overlay.color = Color(0.13, 0.17, 0.34, 0.74)
	feedback_modal_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_modal_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(feedback_modal_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	feedback_modal_overlay.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(720, 420)
	card.theme_type_variation = "ModalCard"
	center.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	feedback_modal_icon_label = Label.new()
	feedback_modal_icon_label.theme_type_variation = "ModalTitleLabel"
	feedback_modal_icon_label.add_theme_font_size_override("font_size", 54)
	feedback_modal_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(feedback_modal_icon_label)

	feedback_modal_title_label = Label.new()
	feedback_modal_title_label.theme_type_variation = "ModalTitleLabel"
	feedback_modal_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(feedback_modal_title_label)

	feedback_modal_body_label = Label.new()
	feedback_modal_body_label.theme_type_variation = "BodyLabel"
	feedback_modal_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_modal_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(feedback_modal_body_label)

	feedback_modal_badge_wrap = VBoxContainer.new()
	feedback_modal_badge_wrap.visible = false
	feedback_modal_badge_wrap.add_theme_constant_override("separation", 8)
	vbox.add_child(feedback_modal_badge_wrap)

	var badge_caption := Label.new()
	badge_caption.theme_type_variation = "HeadingLabel"
	badge_caption.text = "🏅 Seu prêmio desta fase"
	badge_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_modal_badge_wrap.add_child(badge_caption)

	feedback_modal_badge_card = PanelContainer.new()
	feedback_modal_badge_card.custom_minimum_size = Vector2(0, 146)
	feedback_modal_badge_wrap.add_child(feedback_modal_badge_card)

	var badge_margin := MarginContainer.new()
	badge_margin.add_theme_constant_override("margin_left", 20)
	badge_margin.add_theme_constant_override("margin_top", 18)
	badge_margin.add_theme_constant_override("margin_right", 20)
	badge_margin.add_theme_constant_override("margin_bottom", 18)
	feedback_modal_badge_card.add_child(badge_margin)

	var badge_row := HBoxContainer.new()
	badge_row.alignment = BoxContainer.ALIGNMENT_CENTER
	badge_row.add_theme_constant_override("separation", 16)
	badge_margin.add_child(badge_row)

	feedback_modal_badge_icon = Label.new()
	feedback_modal_badge_icon.theme_type_variation = "ModalTitleLabel"
	feedback_modal_badge_icon.add_theme_font_size_override("font_size", 46)
	badge_row.add_child(feedback_modal_badge_icon)

	var badge_text_box := VBoxContainer.new()
	badge_text_box.add_theme_constant_override("separation", 4)
	badge_text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge_row.add_child(badge_text_box)

	feedback_modal_badge_title = Label.new()
	feedback_modal_badge_title.theme_type_variation = "HeadingLabel"
	feedback_modal_badge_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	badge_text_box.add_child(feedback_modal_badge_title)

	feedback_modal_badge_body = Label.new()
	feedback_modal_badge_body.theme_type_variation = "BodyLabel"
	feedback_modal_badge_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	badge_text_box.add_child(feedback_modal_badge_body)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	vbox.add_child(buttons)

	feedback_modal_primary_button = Button.new()
	feedback_modal_primary_button.theme_type_variation = "CelebrateButton"
	feedback_modal_primary_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(feedback_modal_primary_button)
	_attach_button_motion(feedback_modal_primary_button)
	feedback_modal_primary_button.pressed.connect(_on_feedback_modal_primary_pressed)

	feedback_modal_secondary_button = Button.new()
	feedback_modal_secondary_button.theme_type_variation = "GhostButton"
	feedback_modal_secondary_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(feedback_modal_secondary_button)
	_attach_button_motion(feedback_modal_secondary_button)
	feedback_modal_secondary_button.pressed.connect(_on_feedback_modal_secondary_pressed)

func _upgrade_pause_overlay() -> void:
	if pause_tabs != null:
		return
	_apply_pause_menu_surface()
	var pause_vbox := btn_continue.get_parent() as VBoxContainer
	var pause_text := pause_vbox.get_node("PauseText") as Label
	pause_text.text = "⏸️ A aventura está em pausa. Escolha como seguir em Numerópolis."

	pause_tabs = TabContainer.new()
	pause_tabs.custom_minimum_size = Vector2(0, 0)
	pause_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pause_tabs.clip_contents = false
	pause_tabs.tabs_visible = false
	pause_tabs.theme = _build_pause_tabs_theme()
	pause_vbox.add_child(pause_tabs)
	pause_vbox.move_child(pause_tabs, 1)

	var menu_tab := VBoxContainer.new()
	menu_tab.name = "Menu"
	menu_tab.add_theme_constant_override("separation", 12)
	pause_tabs.add_child(menu_tab)
	pause_tabs.set_tab_title(0, "Menu/Pause")

	pause_text.reparent(menu_tab)
	btn_continue.reparent(menu_tab)
	btn_restart_phase.reparent(menu_tab)
	btn_restart_game.reparent(menu_tab)
	btn_back_to_start.reparent(menu_tab)

	var prizes_tab := VBoxContainer.new()
	prizes_tab.name = "MeusPremios"
	prizes_tab.add_theme_constant_override("separation", 12)
	pause_tabs.add_child(prizes_tab)
	pause_tabs.set_tab_title(1, "Premiação")

	var prizes_top_row := HBoxContainer.new()
	prizes_top_row.add_theme_constant_override("separation", 12)
	prizes_tab.add_child(prizes_top_row)

	var prizes_title := Label.new()
	prizes_title.theme_type_variation = "HeadingLabel"
	prizes_title.text = "Meus Premios"
	prizes_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prizes_top_row.add_child(prizes_title)

	btn_pause_prizes_close = Button.new()
	btn_pause_prizes_close.text = "X"
	btn_pause_prizes_close.theme_type_variation = "PauseCloseButton"
	prizes_top_row.add_child(btn_pause_prizes_close)

	var prizes_intro := Label.new()
	prizes_intro.theme_type_variation = "BodyLabel"
	prizes_intro.text = "🏅 Aqui ficam os selos mágicos conquistados em cada pedaço da jornada."
	prizes_intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prizes_tab.add_child(prizes_intro)

	pause_prizes_empty_label = Label.new()
	pause_prizes_empty_label.theme_type_variation = "BodyLabel"
	pause_prizes_empty_label.text = "✨ Nenhum prêmio ainda. Acerte bem rápido para liberar os selos especiais da cidade."
	pause_prizes_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prizes_tab.add_child(pause_prizes_empty_label)

	var prizes_scroll := ScrollContainer.new()
	prizes_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prizes_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	prizes_scroll.horizontal_scroll_mode = 0
	prizes_tab.add_child(prizes_scroll)

	pause_prizes_grid = GridContainer.new()
	pause_prizes_grid.columns = 1
	pause_prizes_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_prizes_grid.add_theme_constant_override("h_separation", 12)
	pause_prizes_grid.add_theme_constant_override("v_separation", 12)
	prizes_scroll.add_child(pause_prizes_grid)

	var audio_tab := VBoxContainer.new()
	audio_tab.name = "Audio"
	audio_tab.add_theme_constant_override("separation", 14)
	pause_tabs.add_child(audio_tab)
	pause_tabs.set_tab_title(2, "Som")

	var audio_top_row := HBoxContainer.new()
	audio_top_row.add_theme_constant_override("separation", 12)
	audio_tab.add_child(audio_top_row)

	var audio_title := Label.new()
	audio_title.theme_type_variation = "HeadingLabel"
	audio_title.text = "Volume do jogo"
	audio_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	audio_top_row.add_child(audio_title)

	btn_pause_sound_close = Button.new()
	btn_pause_sound_close.text = "X"
	btn_pause_sound_close.theme_type_variation = "PauseCloseButton"
	audio_top_row.add_child(btn_pause_sound_close)

	var audio_body := Label.new()
	audio_body.theme_type_variation = "BodyLabel"
	audio_body.text = "Deslize a barrinha para aumentar ou diminuir facilmente todos os sons da aventura."
	audio_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	audio_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	audio_tab.add_child(audio_body)

	volume_slider = HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.01
	volume_slider.value = master_volume_linear
	volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_slider.value_changed.connect(_on_volume_slider_changed)
	audio_tab.add_child(volume_slider)

	volume_value_label = Label.new()
	volume_value_label.theme_type_variation = "CaptionLabel"
	volume_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	audio_tab.add_child(volume_value_label)
	_attach_button_motion(btn_pause_prizes_close)
	_attach_button_motion(btn_pause_sound_close)
	btn_pause_prizes_close.pressed.connect(_hide_pause_overlay)
	btn_pause_sound_close.pressed.connect(_hide_pause_overlay)
	_style_pause_tabs()
	call_deferred("_style_pause_tabs")

func _apply_pause_menu_surface() -> void:
	if pause_card != null:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#FFFFFF")
		style.border_color = Color("#FFFFFF")
		style.border_width_left = 6
		style.border_width_top = 6
		style.border_width_right = 6
		style.border_width_bottom = 6
		style.corner_radius_top_left = 32
		style.corner_radius_top_right = 32
		style.corner_radius_bottom_left = 32
		style.corner_radius_bottom_right = 32
		style.shadow_color = Color(0.18, 0.24, 0.46, 0.16)
		style.shadow_size = 20
		style.shadow_offset = Vector2(0, 8)
		pause_card.add_theme_stylebox_override("panel", style)
	for button in [btn_continue, btn_restart_phase, btn_restart_game, btn_back_to_start]:
		if button != null:
			button.theme_type_variation = "PrimaryButton"

func _style_pause_tabs() -> void:
	if pause_tabs == null:
		return
	pause_tabs.theme = _build_pause_tabs_theme()
	pause_tabs.tabs_visible = false
	var pause_tab_bar := pause_tabs.get_tab_bar()
	if pause_tab_bar == null:
		return
	pause_tabs.add_theme_stylebox_override("panel", _make_pause_tabs_panel_style())
	pause_tab_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_tab_bar.clip_tabs = false
	pause_tab_bar.tab_alignment = TabBar.ALIGNMENT_LEFT
	pause_tab_bar.custom_minimum_size = Vector2(0.0, 54.0)
	pause_tab_bar.add_theme_stylebox_override("tab_selected", _make_pause_tab_style(Color("#FFFFFF"), Color("#DDE8FF"), 0.12))
	pause_tab_bar.add_theme_stylebox_override("tab_hovered", _make_pause_tab_style(Color("#F8FBFF"), Color("#DDE8FF"), 0.1))
	pause_tab_bar.add_theme_stylebox_override("tab_unselected", _make_pause_tab_style(Color("#FFFFFF"), Color("#E7EEF8"), 0.06))
	pause_tab_bar.add_theme_stylebox_override("tab_disabled", _make_pause_tab_style(Color("#F5F7FB"), Color("#E7EEF8"), 0.03))
	pause_tab_bar.add_theme_stylebox_override("panel", _make_pause_tabs_panel_style())
	pause_tab_bar.add_theme_color_override("font_selected_color", Color("#2D325A"))
	pause_tab_bar.add_theme_color_override("font_hovered_color", Color("#40557C"))
	pause_tab_bar.add_theme_color_override("font_unselected_color", Color("#58638A"))
	pause_tab_bar.add_theme_color_override("font_disabled_color", Color("#8B97B5"))
	pause_tab_bar.add_theme_constant_override("h_separation", 10)
	pause_tab_bar.add_theme_constant_override("top_margin", 6)
	pause_tab_bar.add_theme_constant_override("side_margin", 8)
	pause_tab_bar.add_theme_font_size_override("font_size", 18)

func _build_pause_tabs_theme() -> Theme:
	var pause_theme := Theme.new()
	var body_font: Font = load(FONT_BODY_PATH) if ResourceLoader.exists(FONT_BODY_PATH) else null
	var bold_font: Font = load(FONT_BOLD_PATH) if ResourceLoader.exists(FONT_BOLD_PATH) else body_font
	pause_theme.set_stylebox("panel", "TabContainer", _make_pause_tabs_panel_style())
	pause_theme.set_stylebox("tab_selected", "TabBar", _make_pause_tab_style(Color("#FFFFFF"), Color("#DDE8FF"), 0.12))
	pause_theme.set_stylebox("tab_hovered", "TabBar", _make_pause_tab_style(Color("#F8FBFF"), Color("#DDE8FF"), 0.1))
	pause_theme.set_stylebox("tab_unselected", "TabBar", _make_pause_tab_style(Color("#FFFFFF"), Color("#E7EEF8"), 0.06))
	pause_theme.set_stylebox("tab_disabled", "TabBar", _make_pause_tab_style(Color("#F5F7FB"), Color("#E7EEF8"), 0.03))
	pause_theme.set_stylebox("tab_focus", "TabBar", _make_pause_tab_focus_style())
	pause_theme.set_stylebox("panel", "TabBar", _make_pause_tabs_panel_style())
	pause_theme.set_color("font_selected_color", "TabBar", Color("#2D325A"))
	pause_theme.set_color("font_hovered_color", "TabBar", Color("#40557C"))
	pause_theme.set_color("font_unselected_color", "TabBar", Color("#58638A"))
	pause_theme.set_color("font_disabled_color", "TabBar", Color("#8B97B5"))
	pause_theme.set_constant("h_separation", "TabBar", 10)
	pause_theme.set_constant("top_margin", "TabBar", 6)
	pause_theme.set_constant("side_margin", "TabBar", 8)
	if bold_font != null:
		pause_theme.set_font("font", "TabBar", bold_font)
	pause_theme.set_font_size("font_size", "TabBar", 18)
	return pause_theme

func _create_pause_hud_buttons() -> void:
	if btn_pause != null:
		btn_pause.text = "📋 Menu/Pause"
		btn_pause.theme_type_variation = "PauseHudButton"
		btn_pause.visible = true
	if hud_top_row == null:
		return
	if btn_pause_prizes == null:
		btn_pause_prizes = _build_hud_pause_button("Premiação")
		hud_top_row.add_child(btn_pause_prizes)
		hud_top_row.move_child(btn_pause_prizes, btn_pause.get_index() + 1)
	if btn_pause_sound == null:
		btn_pause_sound = _build_hud_pause_button("Som")
		hud_top_row.add_child(btn_pause_sound)
		hud_top_row.move_child(btn_pause_sound, btn_pause_prizes.get_index() + 1)
	return
	if hud_top_row == null or btn_pause_menu != null:
		return
	btn_pause_menu = _build_hud_pause_button("Menu")
	btn_pause_prizes = _build_hud_pause_button("Premiação")
	btn_pause_sound = _build_hud_pause_button("Som")
	hud_top_row.add_child(btn_pause_menu)
	hud_top_row.add_child(btn_pause_prizes)
	hud_top_row.add_child(btn_pause_sound)
	hud_top_row.move_child(btn_pause_menu, btn_journey.get_index() + 1)
	hud_top_row.move_child(btn_pause_prizes, btn_pause_menu.get_index() + 1)
	hud_top_row.move_child(btn_pause_sound, btn_pause_prizes.get_index() + 1)
	btn_pause.visible = true

func _build_hud_pause_button(label_text: String) -> Button:
	var button := Button.new()
	if label_text == "Menu/Pause":
		button.text = "📋 Menu/Pause"
		button.theme_type_variation = "PauseHudButton"
		button.custom_minimum_size = Vector2(116.0, 0.0)
		return button
	if label_text == "Premiação" or label_text == "Premiacao":
		button.text = "🏅 Premiação"
		button.theme_type_variation = "PauseHudButton"
		button.custom_minimum_size = Vector2(116.0, 0.0)
		return button
	match label_text:
		"Menu":
			button.text = "📋 Menu"
		"Premiação":
			button.text = "🏅 Premiação"
		"Som":
			button.text = "🔊 Som"
		_:
			button.text = label_text
	button.theme_type_variation = "PauseHudButton"
	button.custom_minimum_size = Vector2(116.0, 0.0)
	return button

func _open_pause_menu_tab() -> void:
	_show_pause_overlay(0)

func _open_pause_prizes_tab() -> void:
	_show_pause_overlay(1)

func _open_pause_sound_tab() -> void:
	_show_pause_overlay(2)

func _apply_master_volume() -> void:
	var clamped: float = clamp(master_volume_linear, 0.0, 1.0)
	var bus_index := AudioServer.get_bus_index("Master")
	if bus_index == -1:
		bus_index = 0
	AudioServer.set_bus_mute(bus_index, clamped <= 0.001)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(max(clamped, 0.001)))
	if volume_slider != null:
		volume_slider.value = clamped
	if volume_value_label != null:
		volume_value_label.text = "Volume atual: %d%%" % int(round(clamped * 100.0))

func _upgrade_journey_overlay() -> void:
	if journey_vbox == null or journey_scroll != null:
		return
	journey_scroll = ScrollContainer.new()
	journey_scroll.name = "JourneyScroll"
	journey_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journey_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	journey_scroll.horizontal_scroll_mode = 0
	journey_scroll.clip_contents = true
	journey_vbox.add_child(journey_scroll)
	journey_vbox.move_child(journey_scroll, 1)

	var scroll_content := VBoxContainer.new()
	scroll_content.name = "JourneyScrollContent"
	scroll_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_content.add_theme_constant_override("separation", 14)
	journey_scroll.add_child(scroll_content)

	journey_path_label.reparent(scroll_content)
	journey_story_label.reparent(scroll_content)
	journey_path_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journey_story_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	journey_path_label.custom_minimum_size = Vector2.ZERO
	journey_story_label.custom_minimum_size = Vector2.ZERO

func _upgrade_start_overlay() -> void:
	if start_story_label == null or start_story_scroll != null:
		return
	var start_vbox := start_story_label.get_parent() as VBoxContainer
	if start_vbox == null:
		return
	start_story_scroll = ScrollContainer.new()
	start_story_scroll.name = "StartStoryScroll"
	start_story_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_story_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	start_story_scroll.horizontal_scroll_mode = 0
	start_story_scroll.clip_contents = true
	start_vbox.add_child(start_story_scroll)
	start_vbox.move_child(start_story_scroll, start_story_label.get_index())
	start_story_label.reparent(start_story_scroll)
	start_story_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_story_label.custom_minimum_size = Vector2.ZERO

func _make_pause_tab_style(fill: Color, border: Color, shadow_alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.shadow_color = Color(0.16, 0.22, 0.4, shadow_alpha * 0.12)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 11
	style.content_margin_bottom = 11
	return style

func _make_pause_tabs_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0)
	style.border_color = Color(1, 1, 1, 0)
	style.border_width_left = 0
	style.border_width_top = 0
	style.border_width_right = 0
	style.border_width_bottom = 0
	style.corner_radius_top_left = 22
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_left = 22
	style.corner_radius_bottom_right = 22
	style.shadow_color = Color(0.16, 0.22, 0.4, 0.0)
	style.shadow_size = 0
	style.shadow_offset = Vector2.ZERO
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 4
	style.content_margin_bottom = 0
	return style

func _make_pause_tab_focus_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.draw_center = false
	style.border_color = Color("#9ED8FF")
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 22
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_left = 22
	style.corner_radius_bottom_right = 22
	return style

func _on_volume_slider_changed(value: float) -> void:
	master_volume_linear = value
	_apply_master_volume()

func _refresh_prizes_ui() -> void:
	if pause_prizes_grid == null or pause_prizes_empty_label == null:
		return
	for child in pause_prizes_grid.get_children():
		child.queue_free()
	if badges.is_empty():
		pause_prizes_empty_label.visible = true
		pause_prizes_grid.visible = false
		return
	pause_prizes_empty_label.visible = false
	pause_prizes_grid.visible = true
	pause_prizes_grid.columns = 1
	for badge in badges:
		pause_prizes_grid.add_child(_build_badge_card(badge, false))

func _refresh_prizes_gallery_ui() -> void:
	if prizes_gallery_grid == null or prizes_gallery_empty_label == null:
		return
	for child in prizes_gallery_grid.get_children():
		child.queue_free()
	if badges.is_empty():
		prizes_gallery_empty_label.visible = true
		prizes_gallery_grid.visible = false
		return
	prizes_gallery_empty_label.visible = false
	prizes_gallery_grid.visible = true
	prizes_gallery_grid.columns = 1 if get_viewport_rect().size.x < 1100.0 else 2
	for badge in badges:
		prizes_gallery_grid.add_child(_build_badge_card(badge, true))

func _update_layout_constraints() -> void:
	var viewport_size := get_viewport_rect().size
	var compactness: float = clamp((viewport_size.y - 720.0) / 260.0, 0.0, 1.0)
	var target_width: float = clamp(viewport_size.x * 0.9, 960.0, 1440.0)
	var overlay_width_limit: float = max(viewport_size.x - 56.0, 320.0)
	var overlay_height_limit: float = max(viewport_size.y - 56.0, 320.0)
	var horizontal_margin := int(max((viewport_size.x - target_width) * 0.5, 12.0))
	var vertical_margin := int(clamp(viewport_size.y * 0.016, 10.0, 18.0))
	outer_margin.custom_minimum_size = viewport_size
	outer_margin.add_theme_constant_override("margin_left", horizontal_margin)
	outer_margin.add_theme_constant_override("margin_right", horizontal_margin)
	outer_margin.add_theme_constant_override("margin_top", vertical_margin)
	outer_margin.add_theme_constant_override("margin_bottom", vertical_margin)

	var main_padding := int(round(lerp(14.0, 22.0, compactness)))
	var card_padding := int(round(lerp(12.0, 18.0, compactness)))
	var section_gap := int(round(lerp(8.0, 14.0, compactness)))
	main_margin.add_theme_constant_override("margin_left", main_padding)
	main_margin.add_theme_constant_override("margin_right", main_padding)
	main_margin.add_theme_constant_override("margin_top", main_padding)
	main_margin.add_theme_constant_override("margin_bottom", main_padding)
	main_vbox.add_theme_constant_override("separation", section_gap)
	body_row.add_theme_constant_override("separation", section_gap)
	side_column.add_theme_constant_override("separation", section_gap)

	for container in [stage_margin, question_margin, options_margin]:
		container.add_theme_constant_override("margin_left", card_padding)
		container.add_theme_constant_override("margin_right", card_padding)
		container.add_theme_constant_override("margin_top", card_padding)
		container.add_theme_constant_override("margin_bottom", card_padding)

	actions_margin.add_theme_constant_override("margin_left", max(card_padding - 2, 12))
	actions_margin.add_theme_constant_override("margin_right", max(card_padding - 2, 12))
	actions_margin.add_theme_constant_override("margin_top", max(card_padding - 2, 12))
	actions_margin.add_theme_constant_override("margin_bottom", max(card_padding - 2, 12))
	actions_row.add_theme_constant_override("separation", max(section_gap - 2, 8))
	options_grid.add_theme_constant_override("h_separation", max(section_gap - 2, 8))
	options_grid.add_theme_constant_override("v_separation", max(section_gap - 2, 8))
	main_container.custom_minimum_size = Vector2(0.0, 0.0)
	options_grid.columns = 1 if target_width < 1120.0 else 2
	question_card.custom_minimum_size = Vector2(0.0, clamp(viewport_size.y * 0.18, 148.0, 212.0))
	options_card.custom_minimum_size = Vector2(0.0, clamp(viewport_size.y * 0.31, 228.0, 340.0))
	actions_card.custom_minimum_size = Vector2(0.0, clamp(viewport_size.y * 0.105, 86.0, 112.0))
	stage_card.custom_minimum_size = Vector2(0.0, clamp(viewport_size.y * 0.44, 340.0, 520.0))
	var action_button_height: float = clamp(viewport_size.y * 0.072, 52.0, 62.0)
	btn_confirm.custom_minimum_size = Vector2(0.0, action_button_height)
	btn_next.custom_minimum_size = Vector2(0.0, action_button_height)
	if pause_prizes_grid != null:
		pause_prizes_grid.columns = 1
	if prizes_gallery_grid != null:
		prizes_gallery_grid.columns = 1 if target_width < 1120.0 else 2
	if start_card != null:
		start_card.custom_minimum_size = Vector2(
			min(clamp(viewport_size.x * 0.82, 560.0, 940.0), overlay_width_limit),
			min(clamp(viewport_size.y * 0.82, 420.0, 620.0), overlay_height_limit)
		)
	if journey_card != null:
		journey_card.custom_minimum_size = Vector2(
			min(clamp(viewport_size.x * 0.76, 540.0, 900.0), overlay_width_limit),
			min(clamp(viewport_size.y * 0.74, 380.0, 560.0), overlay_height_limit)
		)
	if pause_card != null:
		pause_card.custom_minimum_size = Vector2(
			min(clamp(viewport_size.x * 0.7, 520.0, 860.0), overlay_width_limit),
			min(clamp(viewport_size.y * 0.68, 360.0, 560.0), overlay_height_limit)
		)
	if start_story_scroll != null:
		start_story_scroll.custom_minimum_size = Vector2(0.0, clamp(viewport_size.y * 0.2, 120.0, 220.0))
	start_story_label.custom_minimum_size = Vector2(0.0, 0.0)
	if journey_scroll != null:
		journey_scroll.custom_minimum_size = Vector2(0.0, clamp(viewport_size.y * 0.5, 220.0, 360.0))
	journey_path_label.custom_minimum_size = Vector2(0.0, 0.0)
	journey_story_label.custom_minimum_size = Vector2(0.0, 0.0)

	var stage_height: float = clamp(viewport_size.y * 0.22, 160.0, 250.0)
	stage_canvas.custom_minimum_size = Vector2(0.0, stage_height)
	var popup_width: float = clamp(target_width * 0.38, 320.0, 420.0)
	reward_popup.custom_minimum_size = Vector2(popup_width, 0.0)
	reward_popup.offset_left = -popup_width * 0.5
	reward_popup.offset_right = popup_width * 0.5
	reward_popup.offset_top = clamp(viewport_size.y * 0.1, 72.0, 112.0)
	reward_popup.offset_bottom = reward_popup.offset_top + 160.0

func _show_start_overlay() -> void:
	start_overlay.visible = true
	journey_overlay.visible = false
	pause_overlay.visible = false
	reward_popup.visible = false
	is_test_phase = false
	_hide_feedback_modal()
	_hide_victory_overlay()
	_clear_effect_layers()
	phase_in_progress = false
	player_name = ""
	name_input.text = ""
	_hide_prizes_gallery_overlay()
	_refresh_journey_copy()
	_queue_scroll_reset()

func _show_journey_overlay() -> void:
	if feedback_modal_overlay != null and feedback_modal_overlay.visible:
		return
	if prizes_gallery_overlay != null and prizes_gallery_overlay.visible:
		return
	_refresh_journey_copy()
	journey_overlay.visible = true
	if journey_scroll != null:
		journey_scroll.scroll_vertical = 0

func _hide_journey_overlay() -> void:
	journey_overlay.visible = false

func _show_pause_overlay(tab_index: int = 0) -> void:
	if start_overlay.visible:
		return
	if feedback_modal_overlay != null and feedback_modal_overlay.visible:
		return
	if prizes_gallery_overlay != null and prizes_gallery_overlay.visible:
		return
	_refresh_prizes_ui()
	if pause_tabs != null:
		_style_pause_tabs()
		pause_tabs.current_tab = clamp(tab_index, 0, 2)
	pause_overlay.visible = true

func _hide_pause_overlay() -> void:
	pause_overlay.visible = false

func _on_suggestion_pressed(suggested_name: String) -> void:
	name_input.text = suggested_name

func _on_start_game_pressed() -> void:
	player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		player_name = suggestions[0] if not suggestions.is_empty() else "Explorador"
	is_test_phase = false
	start_overlay.visible = false
	_restart_whole_game()

func _on_test_phase_pressed() -> void:
	player_name = name_input.text.strip_edges()
	if player_name.is_empty():
		name_input.grab_focus()
		name_input.placeholder_text = "Digite um nome para testar a fase."
		return
	start_overlay.visible = false
	is_test_phase = true
	_reset_runtime_state()
	_load_test_phase()

func _reset_runtime_state() -> void:
	_hide_feedback_modal()
	_hide_victory_overlay()
	_hide_reward_popup()
	_clear_effect_layers()
	score = 0
	badges.clear()
	current_phase_index = 0
	current_round_index = 0
	boss_lives = 0
	player_lives = 0
	streak_fast_correct = 0
	needs_retry_phase = false
	phase_in_progress = false
	btn_pause.disabled = false
	_refresh_prizes_ui()
	_hide_prizes_gallery_overlay()
	_refresh_journey_copy()

func _load_test_phase() -> void:
	current_phase_source = _build_test_phase_data()
	current_phase = current_phase_source.duplicate(true)
	current_question = current_phase.duplicate(true)
	current_phase_index = 0
	current_round_index = 0
	in_boss_phase = false
	_setup_phase_ui(current_phase, current_question)

func _build_test_phase_data() -> Dictionary:
	var template_phase: Dictionary = {}
	for phase_source in phases:
		var phase_id := str(phase_source.get("id", ""))
		if phase_id in ["doces", "escola", "floresta", "castelo"]:
			template_phase = phase_source
			break
	if template_phase.is_empty() and not phases.is_empty():
		template_phase = phases[min(1, phases.size() - 1)]
	var phase := _build_runtime_phase(template_phase)
	phase["id"] = "test_phase"
	phase["title"] = "Fase de Teste"
	phase["story"] = "Vamos treinar com uma fase igual as fases normais antes de comecar a aventura."
	phase["mentor"] = "Resolva a conta e conheca o ritmo do jogo sem pontuar."
	phase["time_limit"] = 180.0
	return phase

func _restart_whole_game() -> void:
	_reset_runtime_state()
	if is_test_phase:
		_load_test_phase()
		return
	_load_phase_by_index(current_phase_index)

func _restart_current_phase() -> void:
	needs_retry_phase = false
	pause_overlay.visible = false
	if is_test_phase:
		_setup_phase_ui(current_phase, current_question)
		return
	_load_phase_by_index(current_phase_index)

func _load_phase_by_index(index: int) -> void:
	if index < 0 or index >= phases.size():
		return
	current_phase_source = phases[index].duplicate(true)
	in_boss_phase = str(current_phase_source.get("type", "")) == "boss"
	if in_boss_phase:
		current_phase = current_phase_source.duplicate(true)
		if boss_lives <= 0:
			boss_lives = int(current_phase_source.get("boss_lives", 3))
		if player_lives <= 0:
			player_lives = int(current_phase_source.get("player_lives", 3))
		_load_boss_round(current_round_index)
	else:
		current_phase = _build_runtime_phase(current_phase_source)
		current_question = current_phase.duplicate(true)
		_setup_phase_ui(current_phase, current_phase)

func _load_boss_round(round_index: int) -> void:
	var rounds: Array = current_phase_source.get("rounds", [])
	if round_index >= rounds.size():
		_finish_game()
		return
	current_round_index = round_index
	current_question = _build_runtime_boss_round(current_phase_source, rounds[round_index], round_index)
	current_phase = current_phase_source.duplicate(true)
	current_phase["question"] = current_question.get("question", "")
	current_phase["visual_lines"] = current_question.get("visual_lines", current_phase_source.get("visual_lines", []))
	current_phase["visual_hint"] = current_question.get("visual_hint", current_phase_source.get("visual_hint", ""))
	_setup_phase_ui(current_phase, current_question)
	_update_boss_status()

func _setup_phase_ui(phase_data: Dictionary, question_data: Dictionary) -> void:
	phase_setup_serial += 1
	var setup_serial := phase_setup_serial
	selected_answer = null
	selected_button = null
	needs_retry_phase = false
	phase_in_progress = false
	btn_confirm.disabled = true
	btn_next.disabled = true
	btn_next.visible = false
	btn_next.theme_type_variation = "CelebrateButton"
	btn_next.text = "Prosseguir"
	btn_pause.disabled = false

	phase_label.text = "%s  |  %s" % [phase_data.get("title", "Fase"), phase_data.get("theme", "")]
	story_label.text = str(phase_data.get("story", ""))
	mentor_label.text = "Professor Ponto: %s" % phase_data.get("mentor", "")
	stage_name_label.text = str(phase_data.get("background_name", "Cenário"))
	theme_label.text = "Tema: %s" % phase_data.get("theme", "")
	question_label.text = str(question_data.get("question", ""))
	feedback_label.text = "✨ Observe a cena, pense com calma e confirme sua resposta."
	stage_hint_label.text = _build_stage_hint(phase_data)
	_apply_phase_palette(phase_data)
	options_title_label.text = "Escolha uma alternativa"

	_render_stage_visual(phase_data)
	_create_option_buttons(_build_options(question_data), int(question_data.get("correct_answer", 0)))
	_update_header()
	_hide_feedback_modal()
	_play_phase_transition()
	_animate_phase_cards()
	call_deferred("_finalize_phase_setup", float(phase_data.get("time_limit", DEFAULT_TIME_LIMIT)), setup_serial)

func _finalize_phase_setup(limit_seconds: float, setup_serial: int) -> void:
	if setup_serial != phase_setup_serial:
		return
	_update_layout_constraints()
	_reset_main_scroll()
	btn_confirm.disabled = false
	_start_phase_timer(limit_seconds)
	call_deferred("_reset_main_scroll")

func _star_range() -> Dictionary:
	var bucket: int = min(int(floor(float(score) / 5.0)), 7)
	var range_max: int = min(6 + (bucket * 2), MAX_CHILD_NUMBER)
	return {
		"min": 0,
		"max": range_max
	}

func _build_runtime_phase(phase_source: Dictionary) -> Dictionary:
	var phase := phase_source.duplicate(true)
	var phase_id := str(phase_source.get("id", ""))
	var range_data := _star_range()
	var range_max := int(range_data.get("max", 10))
	match phase_id:
		"brinquedos":
			var max_count: int = clamp(6 + int(score / 5), 6, 12)
			var count: int = randi_range(4, max_count)
			phase["story"] = "🦆✨ A fonte encantada espirrou bolhas novas e os patinhos mudaram de lugar. Se você contar rapidinho, o portão brilhante se abre e a música alegre volta a tocar no bairro."
			phase["mentor"] = "🫧 Conte apenas os patinhos amarelos e ignore as distrações que estão dançando na água."
			phase["question"] = "🦆 Quantos patinhos de borracha estão na fonte agora?"
			phase["correct_answer"] = count
			phase["options"] = _build_answer_options(count, 0, 16)
			phase["extra_distractors"] = _build_answer_options(count + 2, 0, 18)
			phase["visual_lines"] = _build_count_visual_lines("🦆", count, ["🫧", "⚽"])
			phase["visual_hint"] = "Observe com carinho a fonte e conte só os patinhos."
			phase["count_target"] = count
		"doces":
			var candies_a := randi_range(1, max(4, range_max - 3))
			var candies_b := randi_range(1, max(2, min(8, MAX_CHILD_NUMBER - candies_a)))
			var candies_total := candies_a + candies_b
			phase["story"] = "🍭🌈 A ponte dos doces brilhou mais forte e novas caixas chegaram correndo pelo mercado colorido. Cada soma certa acende um pedaço do arco-íris de açúcar sobre a praça."
			phase["mentor"] = "🧠 Some o que já estava na banca com o que acabou de chegar."
			phase["question"] = "🍭 Há %d caixas de pirulitos na banca e chegaram mais %d. Quantas caixas há agora?" % [candies_a, candies_b]
			phase["correct_answer"] = candies_total
			phase["options"] = _build_answer_options(candies_total, 0, MAX_CHILD_NUMBER)
			phase["extra_distractors"] = _build_answer_options(min(candies_total + 3, MAX_CHILD_NUMBER), 0, MAX_CHILD_NUMBER)
			phase["visual_lines"] = [
				"Banca: 🍭x%d" % candies_a,
				"Chegaram: 🍭x%d" % candies_b,
				"Distrações: 🍬 ✨"
			]
			phase["visual_hint"] = "Junte as caixas da banca com as caixas recém-chegadas."
			phase["count_target"] = candies_total
		"escola":
			var balloons_total := randi_range(8, max(10, range_max))
			var balloons_gone := randi_range(1, min(6, balloons_total - 1))
			var balloons_left := balloons_total - balloons_gone
			phase["story"] = "🎈🏫 O vento passou pelo pátio e alguns balões resolveram passear pelo céu azul da escola. A festa só continua quando você descobre quantos ainda estão sorrindo no chão."
			phase["mentor"] = "☁️ Pense no total, retire os que voaram e descubra quantos ficaram."
			phase["question"] = "🎈 Havia %d balões e %d voaram. Quantos sobraram?" % [balloons_total, balloons_gone]
			phase["correct_answer"] = balloons_left
			phase["options"] = _build_answer_options(balloons_left, 0, MAX_CHILD_NUMBER)
			phase["extra_distractors"] = _build_answer_options(min(balloons_left + 2, MAX_CHILD_NUMBER), 0, MAX_CHILD_NUMBER)
			phase["visual_lines"] = [
				"Havia: 🎈x%d" % balloons_total,
				"Voaram: ☁️x%d" % balloons_gone,
				"Sobraram no pátio: 🎈x%d" % balloons_left
			]
			phase["visual_hint"] = "Veja o total, observe quantos voaram e descubra quantos sobraram no pátio."
			phase["count_target"] = balloons_left
		"floresta":
			var leaves_a := randi_range(3, max(6, range_max - 4))
			var leaves_b := randi_range(2, max(3, min(7, MAX_CHILD_NUMBER - leaves_a)))
			var leaves_total := leaves_a + leaves_b
			phase["story"] = "🍃✨ A floresta acendeu trilhas novas e cada grupo de folhas douradas mostra um pedacinho do caminho secreto. Quanto mais rápido você soma, mais rápido a clareira mágica aparece."
			phase["mentor"] = "🌿 Some os grupos com calma e acompanhe as folhas brilhantes."
			phase["question"] = "🍃 Se existem %d folhas douradas e aparecem mais %d, quantas folhas há ao todo?" % [leaves_a, leaves_b]
			phase["correct_answer"] = leaves_total
			phase["options"] = _build_answer_options(leaves_total, 0, MAX_CHILD_NUMBER)
			phase["extra_distractors"] = _build_answer_options(min(leaves_total + 4, MAX_CHILD_NUMBER), 0, MAX_CHILD_NUMBER)
			phase["visual_lines"] = [
				"Clareira: 🍃x%d" % leaves_a,
				"Chegaram: 🍃x%d" % leaves_b,
				"Brilho: ✨✨"
			]
			phase["visual_hint"] = "Siga os grupos de folhas e some tudo o que está brilhando."
			phase["count_target"] = leaves_total
		"castelo":
			var flags_a := randi_range(5, max(7, range_max - 4))
			var flags_b := randi_range(2, max(3, min(6, MAX_CHILD_NUMBER - flags_a)))
			var flags_off := randi_range(1, min(flags_a + flags_b - 1, 5))
			var flags_total := flags_a + flags_b - flags_off
			phase["story"] = "🏰👑 No castelo, novas bandeiras acenderam enquanto outras perderam o brilho no corredor encantado. Cada conta resolvida reacende as janelas douradas da torre."
			phase["mentor"] = "✨ Some primeiro as bandeiras que acenderam e depois retire as que apagaram."
			phase["question"] = "👑 No castelo, %d bandeiras já brilhavam, %d foram acesas e %d apagaram. Quantas ficaram brilhando?" % [flags_a, flags_b, flags_off]
			phase["correct_answer"] = flags_total
			phase["options"] = _build_answer_options(flags_total, 0, MAX_CHILD_NUMBER)
			phase["extra_distractors"] = _build_answer_options(min(flags_total + 3, MAX_CHILD_NUMBER), 0, MAX_CHILD_NUMBER)
			phase["visual_lines"] = [
				"Brilhando: 🚩x%d" % flags_a,
				"Acenderam: 🚩x%d" % flags_b,
				"Apagaram: 🌫x%d" % flags_off
			]
			phase["visual_hint"] = "Observe o salão, some as bandeiras novas e retire as que perderam o brilho."
			phase["count_target"] = flags_total
	return phase

func _build_runtime_boss_round(phase_source: Dictionary, round_source: Dictionary, round_index: int) -> Dictionary:
	var runtime_round := round_source.duplicate(true)
	var range_data := _star_range()
	var range_max := int(range_data.get("max", 10))
	var visual_lines: Array[String] = []

	match round_index % 5:
		0:
			var a := randi_range(5, max(8, range_max - 3))
			var b := randi_range(3, max(4, min(8, MAX_CHILD_NUMBER - a)))
			var result := a + b
			runtime_round["question"] = "❄️ Quanto é %d + %d?" % [a, b]
			runtime_round["correct_answer"] = result
			visual_lines = ["Gelo A: ❄️x%d" % a, "Gelo B: ❄️x%d" % b, "Monstro: 👹 ruge forte"]
		1:
			var total := randi_range(10, max(12, range_max + 4))
			var removed := randi_range(2, min(7, total - 2))
			var result_sub := total - removed
			runtime_round["question"] = "🧊 Quanto é %d - %d?" % [total, removed]
			runtime_round["correct_answer"] = result_sub
			visual_lines = ["Blocos: 🧊x%d" % total, "Quebraram: 💥x%d" % removed, "Monstro: 👹 perdeu força"]
		2:
			var total_mix := randi_range(7, max(9, range_max - 2))
			var removed_mix := randi_range(1, min(4, total_mix - 1))
			var bonus_sum := randi_range(2, min(6, MAX_CHILD_NUMBER - (total_mix - removed_mix)))
			var result_mix := total_mix - removed_mix + bonus_sum
			runtime_round["question"] = "🌨️ Quanto é %d - %d + %d?" % [total_mix, removed_mix, bonus_sum]
			runtime_round["correct_answer"] = result_mix
			visual_lines = ["Neve: ❄️x%d" % total_mix, "Quebrou: 💥x%d" % removed_mix, "Ajuda: ⭐x%d" % bonus_sum]
		3:
			var pair_a := randi_range(3, max(5, range_max - 5))
			var pair_b := randi_range(2, min(6, MAX_CHILD_NUMBER - pair_a))
			var removed_pair := randi_range(1, min(4, pair_b))
			var result_pair := pair_a + pair_b - removed_pair
			runtime_round["question"] = "👹 Quanto é %d + %d - %d?" % [pair_a, pair_b, removed_pair]
			runtime_round["correct_answer"] = result_pair
			visual_lines = ["Grupo A: ⚡x%d" % pair_a, "Grupo B: ⚡x%d" % pair_b, "Caíram: 💨x%d" % removed_pair]
		_:
			var boss_a := randi_range(6, max(8, range_max - 3))
			var boss_b := randi_range(2, min(7, MAX_CHILD_NUMBER - boss_a))
			var result_final := boss_a + boss_b
			runtime_round["question"] = "🐧 Quanto é %d + %d?" % [boss_a, boss_b]
			runtime_round["correct_answer"] = result_final
			visual_lines = ["Cristais: 💎x%d" % boss_a, "Força extra: ⭐x%d" % boss_b, "Monstro: 👹 quase vencido"]

	runtime_round["options"] = _build_answer_options(int(runtime_round.get("correct_answer", 0)), 0, MAX_CHILD_NUMBER)
	runtime_round["extra_distractors"] = _build_answer_options(min(int(runtime_round.get("correct_answer", 0)) + 3, MAX_CHILD_NUMBER), 0, MAX_CHILD_NUMBER)
	runtime_round["visual_lines"] = visual_lines
	runtime_round["visual_hint"] = "Respire fundo, leia a conta toda e ataque o chefão com o cálculo certo."
	return runtime_round

func _build_answer_options(correct_answer: int, min_value: int, max_value: int) -> Array:
	var options: Array = [correct_answer]
	var attempts := 0
	while options.size() < 4 and attempts < 60:
		var delta := randi_range(1, max(3, int(ceil(float(max_value - min_value + 1) * 0.35))))
		var direction := -1 if randf() < 0.5 else 1
		var candidate: int = max(min_value, correct_answer + (delta * direction))
		if candidate != correct_answer and not options.has(candidate):
			options.append(candidate)
		attempts += 1
	while options.size() < 4:
		var fallback := correct_answer + options.size() + 1
		if not options.has(fallback):
			options.append(fallback)
	options.shuffle()
	return options

func _build_count_visual_lines(symbol: String, target_count: int, distractions: Array[String]) -> Array[String]:
	var lines: Array[String] = []
	var remaining := target_count
	var row_index := 0
	while remaining > 0:
		var row_amount: int = min(remaining, 4)
		lines.append("Fonte %d: %s" % [row_index + 1, "  ".join(_repeat_symbol(symbol, row_amount))])
		remaining -= row_amount
		row_index += 1
	if not distractions.is_empty():
		lines.append("Distrações: %s" % "  ".join(distractions))
	return lines

func _repeat_symbol(symbol: String, amount: int) -> Array[String]:
	var items: Array[String] = []
	for _index in range(amount):
		items.append(symbol)
	return items

func _render_stage_visual(phase_data: Dictionary) -> void:
	for child in stage_rows.get_children():
		child.queue_free()
	for child in stage_particles.get_children():
		child.queue_free()

	var lines := GameContent.to_string_array(phase_data.get("visual_lines", []))
	for line in lines:
		stage_rows.add_child(_build_visual_row(line))

	_populate_stage_particles(str(phase_data.get("id", "")))
	_populate_background_ambience(str(phase_data.get("id", "")))
	boss_avatar_label.visible = str(phase_data.get("type", "")) == "boss"
	if boss_avatar_label.visible:
		boss_avatar_label.text = str(phase_data.get("boss_avatar", "👹"))

func _build_visual_row(line: String) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", 12)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	if ":" in line:
		var parts := line.split(":", false, 1)
		var prefix := Label.new()
		prefix.theme_type_variation = "CaptionLabel"
		prefix.text = "%s:" % parts[0]
		prefix.custom_minimum_size = Vector2(116, 0)
		prefix.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		prefix.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(prefix)

		var chip_row := HBoxContainer.new()
		chip_row.alignment = BoxContainer.ALIGNMENT_BEGIN
		chip_row.add_theme_constant_override("separation", 8)
		chip_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(chip_row)

		for token in _visual_tokens(parts[1]):
			chip_row.add_child(_build_symbol_chip(token))
		return row

	var centered := Label.new()
	centered.theme_type_variation = "BodyLabel"
	centered.text = line
	centered.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	centered.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row.add_child(centered)
	return row

func _build_symbol_chip(token: String) -> Control:
	var chip := PanelContainer.new()
	chip.theme_type_variation = "SymbolChip"

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	chip.add_child(margin)

	var label := Label.new()
	label.theme_type_variation = "BadgeLabel"
	label.text = token
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(34.0, 34.0)
	margin.add_child(label)
	return chip

func _populate_background_ambience(phase_id: String) -> void:
	for child in ambient_back.get_children():
		child.queue_free()
	for child in ambient_front.get_children():
		child.queue_free()

	var back_symbol := "☁"
	var front_symbol := "✦"
	var back_color := Color("#FFFFFF")
	var front_color := Color("#FFD93D")

	match phase_id:
		"doces":
			back_symbol = "✿"
			front_symbol = "🍬"
			back_color = Color("#FFD0E8")
			front_color = Color("#FF6B9A")
		"escola":
			back_symbol = "☁"
			front_symbol = "✎"
			back_color = Color("#D8F1FF")
			front_color = Color("#4FACFE")
		"floresta":
			back_symbol = "🍃"
			front_symbol = "✦"
			back_color = Color("#D7F4D6")
			front_color = Color("#6BCB77")
		"castelo":
			back_symbol = "✦"
			front_symbol = "⚑"
			back_color = Color("#E7D9FF")
			front_color = Color("#A786FF")
		"boss":
			back_symbol = "❄"
			front_symbol = "✧"
			back_color = Color("#DDF4FF")
			front_color = Color("#7FD0FF")
		_:
			back_symbol = "☁"
			front_symbol = "✦"
			back_color = Color("#DCEFFF")
			front_color = Color("#FFD93D")

	_spawn_ambient_symbols(ambient_back, back_symbol, back_color, 7, Vector2(40, 140), Vector2(180, 540), 0.10, 32)
	_spawn_ambient_symbols(ambient_front, front_symbol, front_color, 5, Vector2(1200, 120), Vector2(1600, 620), 0.22, 26)

func _spawn_ambient_symbols(layer: Control, symbol: String, tint: Color, amount: int, start_min: Vector2, start_max: Vector2, alpha: float, font_size: int) -> void:
	for index in range(amount):
		var fx := Label.new()
		fx.theme_type_variation = "BadgeLabel"
		fx.text = symbol
		fx.add_theme_font_size_override("font_size", font_size + (index % 2) * 6)
		fx.modulate = Color(tint.r, tint.g, tint.b, alpha)
		fx.position = Vector2(randf_range(start_min.x, start_max.x), randf_range(start_min.y, start_max.y))
		layer.add_child(fx)
		var drift := fx.position + Vector2(randf_range(-30.0, 30.0), randf_range(-22.0, 22.0))
		var tween := create_tween().set_loops()
		tween.tween_property(fx, "position", drift, 3.0 + randf_range(0.0, 1.4)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(fx, "rotation", randf_range(-0.15, 0.15), 3.0 + randf_range(0.0, 1.4))
		tween.tween_property(fx, "position", fx.position, 3.0 + randf_range(0.0, 1.4)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(fx, "rotation", 0.0, 3.0 + randf_range(0.0, 1.4))

func _visual_tokens(raw_text: String) -> Array[String]:
	var tokens: Array[String] = []
	for item in raw_text.strip_edges().split(" ", false):
		var cleaned := item.strip_edges()
		if cleaned.is_empty():
			continue
		tokens.append(cleaned)
	return tokens

func _populate_stage_particles(phase_id: String) -> void:
	var symbol := "•"
	var tint := Color("#FFD93D")
	if phase_id == "doces":
		symbol = "✿"
		tint = Color("#FF6B9A")
	elif phase_id == "escola":
		symbol = "•"
		tint = Color("#4FACFE")
	elif phase_id == "floresta":
		symbol = "✦"
		tint = Color("#6BCB77")
	elif phase_id == "castelo":
		symbol = "✧"
		tint = Color("#A786FF")
	elif phase_id == "boss":
		symbol = "❄"
		tint = Color("#8ED1FF")

	var usable_width: float = max(stage_particles.size.x, stage_canvas.size.x - 28.0)
	var usable_height: float = max(stage_particles.size.y, stage_canvas.size.y - 28.0)
	var area := Rect2(Vector2.ZERO, Vector2(max(usable_width, 640.0), max(usable_height, 96.0)))
	for index in range(10):
		var fx := Label.new()
		fx.text = symbol
		fx.theme_type_variation = "CaptionLabel"
		fx.modulate = Color(tint.r, tint.g, tint.b, 0.22 if phase_id != "boss" else 0.34)
		fx.position = Vector2(randf_range(20.0, area.size.x - 30.0), randf_range(18.0, area.size.y - 18.0))
		fx.z_index = -1
		stage_particles.add_child(fx)

		var drift := fx.position + Vector2(randf_range(-18.0, 18.0), randf_range(-10.0, 14.0))
		var tween := create_tween().set_loops()
		tween.tween_property(fx, "position", drift, 2.2 + randf_range(0.0, 0.8)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(fx, "modulate:a", max(fx.modulate.a * 0.45, 0.12), 2.2 + randf_range(0.0, 0.8))
		tween.tween_property(fx, "position", fx.position, 2.2 + randf_range(0.0, 0.8)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.parallel().tween_property(fx, "modulate:a", fx.modulate.a, 2.2 + randf_range(0.0, 0.8))

func _create_option_buttons(options: Array, correct_answer: int) -> void:
	_clear_option_buttons()
	var display_options: Array = options.duplicate()
	display_options.shuffle()
	var option_height: float = clamp(get_viewport_rect().size.y * 0.075, 52.0, 68.0)

	for option_value in display_options:
		var button := Button.new()
		button.text = str(int(option_value))
		button.theme_type_variation = "ChoiceButton"
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, option_height)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_option_selected.bind(int(option_value), button, int(option_value) == correct_answer))
		_attach_button_motion(button)
		options_grid.add_child(button)
		selected_option_buttons.append(button)

func _clear_option_buttons() -> void:
	for child in options_grid.get_children():
		child.queue_free()
	selected_option_buttons.clear()

func _on_option_selected(option_value: int, button: Button, is_correct_item: bool) -> void:
	selected_answer = option_value
	selected_button = button
	for item in selected_option_buttons:
		item.theme_type_variation = "ChoiceButton"
	button.theme_type_variation = "ChoiceButtonSelected"
	_press_button(button)
	feedback_label.text = "✨ Você escolheu %d. Agora confirme." % option_value

func _on_confirm_pressed() -> void:
	if not phase_in_progress:
		return
	if selected_answer == null:
		feedback_label.text = "Escolha uma alternativa antes de confirmar."
		return
	phase_in_progress = false

	if int(selected_answer) == _current_correct_answer():
		_handle_correct_answer_modal()
	else:
		_handle_wrong_answer_modal()

func _handle_correct_answer() -> void:
	_play_sound(correct_player)
	var earned_points := _points_for_time(current_time_limit - timer_remaining)
	score += earned_points
	var badge_text := _award_badge(earned_points)
	_flash_card(question_card, Color("#DFFFE4"))
	_screen_flash(Color(0.85, 1.0, 0.89, 0.46))
	_spawn_score_popup("+%d" % earned_points, Color("#38B44A"))
	_spawn_confetti_burst(Color("#6BCB77"))
	feedback_label.text = "Muito bem, %s! Você ganhou %d ponto(s)." % [player_name, earned_points]

	if in_boss_phase:
		boss_lives -= 1
		_update_boss_status()
		_play_boss_motion(true)
		if boss_lives <= 0:
			_finish_game()
			return
		current_round_index += 1
	else:
		pass
	btn_next.visible = false
	btn_next.disabled = true
	_show_reward_popup(earned_points, badge_text)
	_update_header()

func _handle_wrong_answer() -> void:
	_play_sound(wrong_player)
	streak_fast_correct = 0
	_flash_card(question_card, Color("#FFE2E2"))
	_screen_flash(Color(1.0, 0.82, 0.82, 0.32))
	_shake_main_container()
	if in_boss_phase:
		player_lives -= 1
		_play_boss_motion(false)
		_update_boss_status()
		feedback_label.text = "O monstro atacou. Você perdeu 1 vida."
		if player_lives <= 0:
			btn_next.text = "Reiniciar chefão"
			btn_next.visible = true
			btn_next.disabled = false
			needs_retry_phase = true
			return
		btn_next.text = "Próxima rodada"
	else:
		feedback_label.text = "Quase! Revise o cenário e tente novamente."
		btn_next.text = "Tentar de novo"
		needs_retry_phase = true
	btn_next.visible = true
	btn_next.disabled = false
	_update_header()
	_queue_scroll_to(question_card, 10.0)

func _handle_timeout() -> void:
	phase_in_progress = false
	_play_sound(wrong_player)
	feedback_label.text = "⏰ Tempo esgotado!"
	_flash_card(question_card, Color("#FFEBC7"))
	_screen_flash(Color(1.0, 0.93, 0.7, 0.32))
	_shake_main_container()
	if in_boss_phase:
		player_lives -= 1
		_update_boss_status()
		_play_boss_motion(false)
		if player_lives <= 0:
			btn_next.text = "Reiniciar chefão"
			needs_retry_phase = true
			btn_next.visible = true
		else:
			btn_next.text = "Próxima rodada"
	else:
		btn_next.text = "Reiniciar fase"
		needs_retry_phase = true
	btn_next.visible = true
	btn_next.disabled = false
	_queue_scroll_to(question_card, 10.0)

func _on_next_pressed() -> void:
	if btn_next.disabled:
		return
	if needs_retry_phase:
		_retry_current_challenge()
		return
	_advance_after_success()

func _finish_game() -> void:
	phase_in_progress = false
	_hide_feedback_modal()
	btn_confirm.disabled = true
	btn_next.disabled = true
	btn_pause.disabled = true
	feedback_label.text = "Parabéns, %s! Numerópolis está organizada novamente." % player_name
	stage_hint_label.text = "Medalha da Lógica conquistada."
	_play_fireworks_show(10, 18, 0.1, 0.55)
	_play_sound(reward_player)
	_play_sound(celebration_player)
	_show_victory_overlay()

func _show_reward_popup(points_earned: int, badge_text: String) -> void:
	reward_popup_label.text = "🎁 Presente desbloqueado"
	reward_popup_body.text = "+%d ponto(s)" % points_earned
	if not badge_text.is_empty():
		reward_popup_body.text += "\n%s" % badge_text

	reward_popup.visible = true
	reward_popup.scale = Vector2(0.88, 0.88)
	reward_popup.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(reward_popup, "modulate:a", 1.0, 0.18)
	tween.parallel().tween_property(reward_popup, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _hide_reward_popup() -> void:
	reward_popup.visible = false
	reward_popup.modulate.a = 1.0
	reward_popup.scale = Vector2.ONE

func _handle_correct_answer_modal() -> void:
	_play_sound(correct_player)
	_play_sound(celebration_player)
	if is_test_phase:
		_flash_card(question_card, Color("#DFFFE4"))
		_screen_flash(Color(0.85, 1.0, 0.89, 0.46))
		_spawn_confetti_burst(Color("#6BCB77"))
		feedback_label.text = "Muito bem, %s! Esta fase de teste nao pontua." % player_name
		btn_next.visible = false
		btn_next.disabled = true
		_show_feedback_modal(
			"OK",
			"Muito Bem!!!",
			"Podemos comecar nossa aventura???!!!",
			"SIM!",
			"start_real_game",
			"TELA INICIAL",
			"go_start",
			{}
		)
		return
	var earned_points := _points_for_time(current_time_limit - timer_remaining)
	score += earned_points
	var badge_reward := _award_phase_badge(current_phase, earned_points)
	_flash_card(question_card, Color("#DFFFE4"))
	_screen_flash(Color(0.85, 1.0, 0.89, 0.46))
	_spawn_score_popup("+%d" % earned_points, Color("#38B44A"))
	_spawn_confetti_burst(Color("#6BCB77"))
	_play_fireworks_show(9, 24, 0.04, 0.62)
	feedback_label.text = "🎉 Acertou em cheio! %s ganhou %d estrela(s)." % [player_name, earned_points]

	if in_boss_phase:
		boss_lives -= 1
		_update_boss_status()
		_play_boss_motion(true)
		if boss_lives <= 0:
			_finish_game()
			return
		current_round_index += 1
	btn_next.visible = false
	btn_next.disabled = true
	btn_next.theme_type_variation = "CelebrateButton"
	_update_header()
	_refresh_journey_copy()

	var body := "🎉 Muito bem, %s!\nVocê ganhou %d estrela(s), fez a fase brilhar e encheu Numerópolis de fogos coloridos." % [player_name, earned_points]
	if badge_reward.is_empty():
		body += "\n\n⚡ Responda em até 45 segundos para conquistar o selo especial desta fase."
	else:
		body += "\n\n🏅 Um novo selo foi guardado em Meus Prêmios."

	_show_feedback_modal(
		"🎆",
		"Acerto brilhante!",
		body,
		"Prosseguir",
		"advance",
		"Refazer fase" if not in_boss_phase else "Refazer rodada",
		"retry",
		badge_reward
	)

func _handle_wrong_answer_modal() -> void:
	_play_sound(wrong_player)
	streak_fast_correct = 0
	_flash_card(question_card, Color("#FFE2E2"))
	_screen_flash(Color(1.0, 0.82, 0.82, 0.32))
	_shake_main_container()
	needs_retry_phase = true
	btn_next.disabled = false
	btn_next.text = "Tentar de novo"
	btn_next.theme_type_variation = "SecondaryButton"

	var body := "❌ Essa não foi a resposta desta vez.\nObserve a cena, respire fundo e tente novamente."
	if in_boss_phase:
		player_lives -= 1
		_play_boss_motion(false)
		_update_boss_status()
		body = "❌ O golpe não acertou o chefão.\nVocê ainda tem %d vida(s) para continuar o duelo." % max(player_lives, 0)
		if player_lives <= 0:
			feedback_label.text = "💥 Fomos abatidos, mas não perdemos a guerra."
			_update_header()
			_show_feedback_modal(
				"💥",
				"Fomos abatidos!",
				"Fomos abatidos, mas não perdemos a guerra.\nRespire fundo, reorganize sua estratégia e escolha como deseja voltar para a batalha.",
				"Reiniciar jogo",
				"restart_game",
				"Refazer chefão",
				"retry",
				{}
			)
			return
		feedback_label.text = "❌ Resposta errada. O chefão contra-atacou."
	else:
		feedback_label.text = "❌ Resposta errada. Você pode tentar esta fase outra vez."

	_update_header()
	_show_feedback_modal("❌", "Tente novamente", body, "Tentar novamente", "retry", "", "", {})

func _handle_timeout_modal() -> void:
	phase_in_progress = false
	_play_sound(wrong_player)
	_flash_card(question_card, Color("#FFEBC7"))
	_screen_flash(Color(1.0, 0.93, 0.7, 0.32))
	_shake_main_container()
	needs_retry_phase = true
	btn_next.disabled = false
	btn_next.text = "Reiniciar fase"
	btn_next.theme_type_variation = "SecondaryButton"

	var body := "⏰ O tempo acabou, mas você pode tentar esta fase de novo sem perder a aventura."
	if in_boss_phase:
		player_lives -= 1
		_update_boss_status()
		_play_boss_motion(false)
		body = "⏰ O tempo do duelo acabou.\nVocê ainda tem %d vida(s) para derrotar o chefão." % max(player_lives, 0)
		if player_lives <= 0:
			feedback_label.text = "💥 Fomos abatidos, mas não perdemos a guerra."
			_update_header()
			_show_feedback_modal(
				"🧊",
				"Fomos abatidos!",
				"Fomos abatidos, mas não perdemos a guerra.\nO tempo venceu esta rodada, mas você pode reiniciar e voltar mais forte para o duelo final.",
				"Reiniciar jogo",
				"restart_game",
				"Refazer chefão",
				"retry",
				{}
			)
			return
		feedback_label.text = "⏰ Tempo esgotado no duelo final."
	else:
		feedback_label.text = "⏰ Tempo esgotado. Tente de novo com mais calma."

	_show_feedback_modal("⏰", "Tempo esgotado!", body, "Tentar novamente", "retry", "", "", {})

func _advance_after_success() -> void:
	_hide_feedback_modal()
	if in_boss_phase:
		_load_boss_round(current_round_index)
		return
	current_phase_index += 1
	if current_phase_index >= phases.size():
		_finish_game()
	else:
		_load_phase_by_index(current_phase_index)

func _retry_current_challenge() -> void:
	needs_retry_phase = false
	_hide_feedback_modal()
	pause_overlay.visible = false
	btn_next.visible = false
	if is_test_phase:
		_setup_phase_ui(current_phase, current_question)
		return
	if in_boss_phase:
		if player_lives <= 0:
			boss_lives = int(current_phase_source.get("boss_lives", 3))
			player_lives = int(current_phase_source.get("player_lives", 3))
			current_round_index = 0
			_load_phase_by_index(current_phase_index)
			return
		_load_boss_round(current_round_index)
		return
	_load_phase_by_index(current_phase_index)

func _show_feedback_modal(icon_text: String, title_text: String, body_text: String, primary_label: String, primary_action: String, secondary_label: String, secondary_action: String, badge_data: Dictionary) -> void:
	if feedback_modal_overlay == null:
		return
	feedback_modal_primary_action = primary_action
	feedback_modal_secondary_action = secondary_action
	feedback_modal_icon_label.text = icon_text
	feedback_modal_title_label.text = title_text
	feedback_modal_body_label.text = body_text
	feedback_modal_primary_button.text = primary_label
	feedback_modal_secondary_button.text = secondary_label
	feedback_modal_secondary_button.visible = not secondary_action.is_empty()
	feedback_modal_badge_wrap.visible = not badge_data.is_empty()
	if not badge_data.is_empty():
		_apply_badge_card(feedback_modal_badge_card, feedback_modal_badge_icon, feedback_modal_badge_title, feedback_modal_badge_body, badge_data, true)
	feedback_modal_overlay.visible = true
	feedback_modal_overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(feedback_modal_overlay, "modulate:a", 1.0, 0.22)

func _hide_feedback_modal() -> void:
	if feedback_modal_overlay == null:
		return
	feedback_modal_overlay.visible = false
	feedback_modal_overlay.modulate.a = 1.0
	feedback_modal_primary_action = ""
	feedback_modal_secondary_action = ""

func _on_feedback_modal_primary_pressed() -> void:
	_execute_feedback_modal_action(feedback_modal_primary_action)

func _on_feedback_modal_secondary_pressed() -> void:
	_execute_feedback_modal_action(feedback_modal_secondary_action)

func _execute_feedback_modal_action(action_name: String) -> void:
	match action_name:
		"advance":
			_advance_after_success()
		"retry":
			_retry_current_challenge()
		"restart_game":
			_restart_whole_game()
		"start_real_game":
			is_test_phase = false
			_hide_feedback_modal()
			_restart_whole_game()
		"go_start":
			is_test_phase = false
			_hide_feedback_modal()
			_show_start_overlay()
		_:
			_hide_feedback_modal()

func _start_phase_timer(limit_seconds: float) -> void:
	current_time_limit = limit_seconds
	timer_remaining = limit_seconds
	last_urgency_second = -1
	phase_in_progress = true
	timer_label.text = _format_time_label(limit_seconds)

func _update_header() -> void:
	player_label.text = "🕵️ %s" % player_name
	score_label.text = "⭐ %d" % score
	if is_test_phase:
		progress_bar.value = 0
		progress_label.text = "Fase de teste"
		return
	progress_bar.value = min(current_phase_index + 1, phases.size())
	progress_label.text = "Etapa %d de %d" % [min(current_phase_index + 1, phases.size()), phases.size()]

func _update_boss_status() -> void:
	stage_hint_label.text = "Boss: %s vidas | Você: %s vidas | Rodada %d" % [boss_lives, player_lives, current_round_index + 1]

func _build_stage_hint(phase_data: Dictionary) -> String:
	var hint := str(phase_data.get("visual_hint", ""))
	var label_text := str(phase_data.get("count_label", ""))
	if hint.is_empty():
		return label_text
	return hint

func _build_options(question_data: Dictionary) -> Array:
	var options: Array = question_data.get("options", []).duplicate()
	if streak_fast_correct >= 2:
		var extras: Array = question_data.get("extra_distractors", [])
		if not extras.is_empty():
			var candidate: Variant = extras[randi() % extras.size()]
			if not options.has(candidate):
				options.append(candidate)
	return options

func _current_correct_answer() -> int:
	return int(current_question.get("correct_answer", 0))

func _points_for_time(response_time: float) -> int:
	if response_time <= 45.0:
		return 3
	if response_time <= 90.0:
		return 2
	if response_time <= 150.0:
		return 1
	return 0

func _format_time_label(seconds: float) -> String:
	var total_seconds: int = max(int(ceil(seconds)), 0)
	var minutes := int(total_seconds / 60)
	var remaining_seconds: int = total_seconds % 60
	return "Tempo %d:%02d" % [minutes, remaining_seconds]

func _award_badge(points_earned: int) -> String:
	var badge_text := ""
	if points_earned == 3:
		badge_text = str(badge_catalog.get("fast", "⚡ Rápido como um raio"))
		streak_fast_correct += 1
	elif points_earned == 2:
		badge_text = str(badge_catalog.get("smart", "🧠 Super cérebro"))
		streak_fast_correct = 0
	else:
		streak_fast_correct = 0

	if streak_fast_correct >= 2:
		badge_text = str(badge_catalog.get("perfect", "🎯 Acerto perfeito"))
	return badge_text

func _award_phase_badge(phase_data: Dictionary, points_earned: int) -> Dictionary:
	if points_earned >= 3:
		streak_fast_correct += 1
	else:
		streak_fast_correct = 0
	if points_earned < 3:
		return {}
	var badge := _build_phase_badge(phase_data)
	for existing_badge in badges:
		if str(existing_badge.get("id", "")) == str(badge.get("id", "")):
			return {}
	badges.append(badge)
	_refresh_prizes_ui()
	return badge

func _build_phase_badge(phase_data: Dictionary) -> Dictionary:
	var phase_id := str(phase_data.get("id", "fase"))
	var phase_title := str(phase_data.get("title", "Fase"))
	match phase_id:
		"brinquedos":
			return {"id": "badge_brinquedos", "title": "Selo Patinho Relâmpago", "description": "Você contou os patinhos num piscar de olhos e abriu o portão brilhante do bairro.", "phase_title": phase_title, "icon": "🦆", "color_primary": "#FFD93D", "color_secondary": "#FFB347"}
		"doces":
			return {"id": "badge_doces", "title": "Selo Ponte Açucarada", "description": "Sua conta foi tão rápida que a ponte dos doces apareceu toda iluminada de uma vez.", "phase_title": phase_title, "icon": "🍭", "color_primary": "#FF8FB8", "color_secondary": "#FFD166"}
		"escola":
			return {"id": "badge_escola", "title": "Selo Pátio Brilhante", "description": "Você organizou o pátio da escola depressa e deixou os balões sorrindo no céu.", "phase_title": phase_title, "icon": "🎈", "color_primary": "#7BD3FF", "color_secondary": "#4FACFE"}
		"floresta":
			return {"id": "badge_floresta", "title": "Selo Folha Veloz", "description": "As trilhas da floresta piscaram de alegria porque sua soma foi leve e certeira.", "phase_title": phase_title, "icon": "🍃", "color_primary": "#7ED957", "color_secondary": "#B7F27D"}
		"castelo":
			return {"id": "badge_castelo", "title": "Selo Coroa Dourada", "description": "Você resolveu a conta do castelo com classe e fez as bandeiras brilharem como ouro.", "phase_title": phase_title, "icon": "👑", "color_primary": "#FFD93D", "color_secondary": "#F6B73C"}
		"boss":
			return {"id": "badge_boss", "title": "Troféu Gelo Partido", "description": "Seu raciocínio rápido rachou o gelo do chefão e espalhou coragem por Numerópolis.", "phase_title": phase_title, "icon": "❄️", "color_primary": "#8FD9FF", "color_secondary": "#D8F3FF"}
		_:
			return {"id": "badge_%s" % phase_id, "title": "Selo da Jornada", "description": "Você ganhou um prêmio especial por responder com muita rapidez.", "phase_title": phase_title, "icon": "⭐", "color_primary": "#FFD93D", "color_secondary": "#FFF1A8"}

func _build_badge_card(badge: Dictionary, large: bool) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 148 if large else 132)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18 if large else 14)
	margin.add_theme_constant_override("margin_top", 16 if large else 14)
	margin.add_theme_constant_override("margin_right", 18 if large else 14)
	margin.add_theme_constant_override("margin_bottom", 16 if large else 14)
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14 if large else 12)
	margin.add_child(row)

	var icon_label := Label.new()
	icon_label.theme_type_variation = "ModalTitleLabel"
	icon_label.add_theme_font_size_override("font_size", 42 if large else 34)
	row.add_child(icon_label)

	var text_box := VBoxContainer.new()
	text_box.add_theme_constant_override("separation", 4)
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(text_box)

	var title_label := Label.new()
	title_label.theme_type_variation = "HeadingLabel"
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_box.add_child(title_label)

	var body_label := Label.new()
	body_label.theme_type_variation = "BodyLabel"
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_box.add_child(body_label)

	_apply_badge_card(card, icon_label, title_label, body_label, badge, large)
	return card

func _apply_badge_card(card: PanelContainer, icon_label: Label, title_label: Label, body_label: Label, badge: Dictionary, large: bool) -> void:
	var primary := Color(str(badge.get("color_primary", "#FFD93D")))
	var secondary := Color(str(badge.get("color_secondary", "#FFF1A8")))
	var style := StyleBoxFlat.new()
	style.bg_color = secondary.lerp(Color.WHITE, 0.36)
	style.border_color = primary
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 28 if large else 24
	style.corner_radius_top_right = 28 if large else 24
	style.corner_radius_bottom_right = 28 if large else 24
	style.corner_radius_bottom_left = 28 if large else 24
	style.shadow_color = Color(primary.r, primary.g, primary.b, 0.18)
	style.shadow_size = 14 if large else 10
	style.shadow_offset = Vector2(0, 6)
	card.add_theme_stylebox_override("panel", style)
	icon_label.text = str(badge.get("icon", "⭐"))
	title_label.text = "%s  •  %s" % [badge.get("title", "Selo"), badge.get("phase_title", "Fase")]
	body_label.text = str(badge.get("description", "Prêmio especial conquistado."))

func _phase_background_color(phase_data: Dictionary) -> Color:
	var values: Variant = phase_data.get("background_color", [0.95, 0.95, 1.0])
	if values is Array and values.size() >= 3:
		return Color(float(values[0]), float(values[1]), float(values[2]), 1.0)
	return Color("#F9F5FF")

func _apply_phase_palette(phase_data: Dictionary) -> void:
	var base := _phase_background_color(phase_data)
	background_rect.color = base
	backdrop_glow.color = Color(base.r + 0.06, base.g + 0.05, min(base.b + 0.08, 1.0), 0.58)
	blob_left.color = Color(base.r * 0.82, min(base.g + 0.08, 1.0), min(base.b + 0.18, 1.0), 0.18)
	blob_right.color = Color(min(base.r + 0.08, 1.0), base.g * 0.84, min(base.b + 0.10, 1.0), 0.16)

func _animate_phase_cards() -> void:
	var cards: Array[Control] = [stage_card, question_card, options_card, actions_card]
	for index in range(cards.size()):
		var card := cards[index]
		card.modulate.a = 0.0
		card.scale = Vector2.ONE
		var tween := create_tween()
		tween.tween_interval(index * 0.02)
		tween.tween_property(card, "modulate:a", 1.0, 0.14)

func _play_phase_transition() -> void:
	transition_overlay.color = Color(1, 1, 1, 0.42)
	var tween := create_tween()
	tween.tween_property(transition_overlay, "color:a", 0.0, 0.14)

func _flash_card(card: CanvasItem, flash_color: Color) -> void:
	var original := card.self_modulate
	card.self_modulate = flash_color
	var tween := create_tween()
	tween.tween_property(card, "self_modulate", original, 0.28)

func _screen_flash(color: Color) -> void:
	flash_overlay.visible = true
	flash_overlay.color = color
	var tween := create_tween()
	tween.tween_property(flash_overlay, "color:a", 0.0, 0.24)
	tween.tween_callback(func() -> void:
		flash_overlay.visible = false
	)

func _shake_main_container() -> void:
	var target := main_container
	var original: Vector2 = target.position
	var tween := create_tween()
	tween.tween_property(target, "position:x", original.x + 8.0, 0.04)
	tween.tween_property(target, "position:x", original.x - 6.0, 0.05)
	tween.tween_property(target, "position:x", original.x + 4.0, 0.04)
	tween.tween_property(target, "position", original, 0.05)

func _spawn_score_popup(text_value: String, tint: Color) -> void:
	if score_float_layer == null:
		return
	var popup := Label.new()
	popup.theme_type_variation = "HeadingLabel"
	popup.text = text_value
	popup.modulate = tint
	popup.position = Vector2(620.0, 160.0)
	score_float_layer.add_child(popup)
	var tween := create_tween()
	tween.tween_property(popup, "position:y", popup.position.y - 42.0, 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(popup, "modulate:a", 0.0, 0.55)
	tween.tween_callback(popup.queue_free)

func _spawn_confetti_burst(base_color: Color) -> void:
	if score_float_layer == null:
		return
	for index in range(12):
		var piece := Label.new()
		piece.theme_type_variation = "BadgeLabel"
		piece.text = ["✦", "●", "◆", "✿"][index % 4]
		piece.position = Vector2(560.0, 190.0)
		piece.modulate = Color(base_color.r, base_color.g, base_color.b, 0.9)
		score_float_layer.add_child(piece)
		var target := piece.position + Vector2(randf_range(-110.0, 110.0), randf_range(-90.0, 40.0))
		var tween := create_tween()
		tween.tween_property(piece, "position", target, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(piece, "modulate:a", 0.0, 0.6)
		tween.tween_callback(piece.queue_free)

func _reset_main_scroll() -> void:
	if main_scroll == null:
		return
	main_scroll.scroll_vertical = 0
	main_scroll.scroll_horizontal = 0

func _queue_scroll_reset() -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner is Control:
		(focus_owner as Control).release_focus()
	call_deferred("_reset_main_scroll")
	call_deferred("_reset_main_scroll_next_frame")

func _reset_main_scroll_next_frame() -> void:
	await get_tree().process_frame
	_reset_main_scroll()

func _queue_scroll_to(target_control: Control, padding: float = 12.0) -> void:
	var focus_owner := get_viewport().gui_get_focus_owner()
	if focus_owner is Control:
		(focus_owner as Control).release_focus()
	call_deferred("_scroll_to_control_next_frame", target_control, padding)

func _scroll_to_control_next_frame(target_control: Control, padding: float) -> void:
	await get_tree().process_frame
	if main_scroll == null or target_control == null:
		return
	var target_y: float = max(target_control.global_position.y - outer_margin.global_position.y - padding, 0.0)
	main_scroll.scroll_vertical = int(target_y)

func _attach_button_motion(button: Button) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(_play_sound.bind(click_player))
	button.pressed.connect(_press_button.bind(button))
	button.mouse_entered.connect(_hover_button.bind(button, Vector2(1.03, 1.03)))
	button.mouse_exited.connect(_hover_button.bind(button, Vector2.ONE))

func _hover_button(button: Button, target_scale: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", target_scale, 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _press_button(button: Button) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.97, 0.97), 0.05)
	tween.tween_property(button, "scale", Vector2.ONE, 0.08)

func _play_boss_motion(is_hit: bool) -> void:
	if not boss_avatar_label.visible:
		return
	var target_scale := Vector2(1.1, 1.1) if is_hit else Vector2(1.16, 0.92)
	var target_rotation := -0.03 if is_hit else 0.08
	var tween := create_tween()
	tween.tween_property(boss_avatar_label, "scale", target_scale, 0.08)
	tween.parallel().tween_property(boss_avatar_label, "rotation", target_rotation, 0.08)
	tween.tween_property(boss_avatar_label, "scale", Vector2.ONE, 0.16)
	tween.parallel().tween_property(boss_avatar_label, "rotation", 0.0, 0.16)

func _create_audio_players() -> void:
	quack_player = _audio_player_from_path(QUACK_AUDIO)
	correct_player = _audio_player_from_path(CORRECT_AUDIO)
	wrong_player = _audio_player_from_path(WRONG_AUDIO)
	reward_player = _audio_player_from_path(REWARD_AUDIO)
	urgency_player = _make_audio_player(_build_tick_stream(), -10.0)
	click_player = _make_audio_player(_build_tick_stream(), -16.0)
	celebration_player = _make_audio_player(_build_celebration_stream(), -7.0)

func _audio_player_from_path(path: String) -> AudioStreamPlayer:
	var stream: AudioStream = load(path) if ResourceLoader.exists(path) else _build_tick_stream()
	return _make_audio_player(stream, -4.0)

func _make_audio_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db
	add_child(player)
	return player

func _build_tick_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var total_samples := int(0.08 * mix_rate)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)
	for i in range(total_samples):
		var t := float(i) / float(mix_rate)
		var env := exp(-18.0 * t)
		var sample_value := 0.55 * env * sin(TAU * 1500.0 * t)
		var sample_int := int(round(clamp(sample_value, -1.0, 1.0) * 32767.0))
		bytes[i * 2] = sample_int & 0xFF
		bytes[i * 2 + 1] = (sample_int >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.data = bytes
	return stream

func _build_celebration_stream() -> AudioStreamWAV:
	var mix_rate := 22050
	var duration := 1.8
	var total_samples := int(duration * mix_rate)
	var bytes := PackedByteArray()
	bytes.resize(total_samples * 2)
	var notes := [740.0, 932.0, 1110.0, 1480.0, 1760.0, 1976.0]
	for i in range(total_samples):
		var t := float(i) / float(mix_rate)
		var note_index: int = min(int(floor(t / 0.21)), notes.size() - 1)
		var env := pow(clamp(1.0 - (t / duration), 0.0, 1.0), 1.2)
		var lead := sin(TAU * notes[note_index] * t) * 0.38
		var harmony := sin(TAU * (notes[note_index] * 0.75) * t) * 0.18
		var bell := sin(TAU * (notes[note_index] * 1.5) * t) * 0.12
		var sparkle: float = sin(TAU * (2400.0 + (note_index * 120.0)) * t) * 0.04 * clamp(1.0 - (t * 0.6), 0.0, 1.0)
		var pulse := sin(TAU * 6.0 * t) * 0.04
		var sample_value: float = (lead + harmony + bell + sparkle + pulse) * env
		var sample_int := int(round(clamp(sample_value, -1.0, 1.0) * 32767.0))
		bytes[i * 2] = sample_int & 0xFF
		bytes[i * 2 + 1] = (sample_int >> 8) & 0xFF
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.data = bytes
	return stream

func _play_sound(player: AudioStreamPlayer) -> void:
	if player == null:
		return
	player.stop()
	player.play()

func _create_fireworks_layer() -> void:
	fireworks_layer = Control.new()
	fireworks_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	fireworks_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fireworks_layer)
	score_float_layer = Control.new()
	score_float_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	score_float_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(score_float_layer)

func _create_victory_overlay() -> void:
	victory_overlay = ColorRect.new()
	victory_overlay.visible = false
	victory_overlay.color = Color(0.16, 0.28, 0.56, 0.74)
	victory_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	victory_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(victory_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	victory_overlay.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(720, 340)
	card.theme_type_variation = "ModalCard"
	center.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	victory_title_label = Label.new()
	victory_title_label.theme_type_variation = "ModalTitleLabel"
	victory_title_label.text = "Ihulll!"
	victory_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(victory_title_label)

	var subtitle := Label.new()
	subtitle.theme_type_variation = "HeadingLabel"
	subtitle.text = "Você derrotou o chefão e salvou Numerópolis."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(subtitle)

	victory_body_label = Label.new()
	victory_body_label.custom_minimum_size = Vector2(0, 96)
	victory_body_label.theme_type_variation = "BodyLabel"
	victory_body_label.text = "Os fogos estão brilhando no céu e a Medalha de Ouro da Lógica é sua."
	victory_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	victory_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(victory_body_label)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	vbox.add_child(buttons)

	btn_victory_prizes = Button.new()
	btn_victory_prizes.theme_type_variation = "CelebrateButton"
	btn_victory_prizes.text = "Ver meus prêmios"
	btn_victory_prizes.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_victory_prizes.focus_mode = Control.FOCUS_NONE
	buttons.add_child(btn_victory_prizes)
	_attach_button_motion(btn_victory_prizes)

	btn_victory_home = Button.new()
	btn_victory_home.theme_type_variation = "PrimaryButton"
	btn_victory_home.text = "Voltar ao início"
	btn_victory_home.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_victory_home.focus_mode = Control.FOCUS_NONE
	buttons.add_child(btn_victory_home)
	_attach_button_motion(btn_victory_home)

func _create_prizes_gallery_overlay() -> void:
	prizes_gallery_overlay = ColorRect.new()
	prizes_gallery_overlay.visible = false
	prizes_gallery_overlay.color = Color(0.16, 0.2, 0.38, 0.78)
	prizes_gallery_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	prizes_gallery_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(prizes_gallery_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	prizes_gallery_overlay.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(860, 560)
	card.theme_type_variation = "JourneyCard"
	center.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 12)
	vbox.add_child(top_row)

	var title := Label.new()
	title.text = "🏅 Meus Prêmios"
	title.theme_type_variation = "ModalTitleLabel"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(title)

	btn_prizes_close = Button.new()
	btn_prizes_close.text = "Fechar"
	btn_prizes_close.theme_type_variation = "PrimaryButton"
	top_row.add_child(btn_prizes_close)
	_attach_button_motion(btn_prizes_close)

	var intro := Label.new()
	intro.theme_type_variation = "BodyLabel"
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.text = "✨ Aqui estão todos os selos conquistados na aventura. Cada um representa uma fase salva com coragem e rapidez."
	vbox.add_child(intro)

	prizes_gallery_empty_label = Label.new()
	prizes_gallery_empty_label.theme_type_variation = "BodyLabel"
	prizes_gallery_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prizes_gallery_empty_label.text = "Ainda não há prêmios guardados nesta jornada."
	vbox.add_child(prizes_gallery_empty_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = 0
	vbox.add_child(scroll)

	prizes_gallery_grid = GridContainer.new()
	prizes_gallery_grid.columns = 2
	prizes_gallery_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prizes_gallery_grid.add_theme_constant_override("h_separation", 14)
	prizes_gallery_grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(prizes_gallery_grid)

func _show_prizes_gallery_overlay() -> void:
	if prizes_gallery_overlay == null:
		return
	_refresh_prizes_gallery_ui()
	prizes_gallery_overlay.visible = true
	prizes_gallery_overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(prizes_gallery_overlay, "modulate:a", 1.0, 0.22)

func _hide_prizes_gallery_overlay() -> void:
	if prizes_gallery_overlay == null:
		return
	prizes_gallery_overlay.visible = false
	prizes_gallery_overlay.modulate.a = 1.0

func _show_victory_overlay() -> void:
	if victory_overlay == null:
		return
	victory_title_label.text = "Ihulll!"
	victory_body_label.text = "%s venceu o chefão, fez %d ponto(s) e conquistou %d selo(s).\nNumerópolis está organizada novamente. Você também pode abrir a galeria para ver todos os prêmios conquistados." % [player_name, score, badges.size()]
	victory_overlay.visible = true
	victory_overlay.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(victory_overlay, "modulate:a", 1.0, 0.25)

func _hide_victory_overlay() -> void:
	if victory_overlay == null:
		return
	victory_overlay.visible = false
	victory_overlay.modulate.a = 1.0
	_hide_prizes_gallery_overlay()

func _clear_effect_layers() -> void:
	if fireworks_layer != null:
		for child in fireworks_layer.get_children():
			child.queue_free()
	if score_float_layer != null:
		for child in score_float_layer.get_children():
			child.queue_free()

func _play_fireworks_show(bursts: int = 8, particles_per_burst: int = 10, burst_delay: float = 0.14, radius_scale: float = 1.0) -> void:
	if fireworks_layer == null:
		return
	for child in fireworks_layer.get_children():
		child.queue_free()
	var colors: Array[Color] = [
		Color("#4FACFE"),
		Color("#FFD93D"),
		Color("#6BCB77"),
		Color("#FF6B9A"),
		Color("#A786FF"),
		Color("#FF8C42")
	]
	var spark_symbols := ["✦", "✧", "✺", "•"]
	var viewport_size := get_viewport_rect().size
	for burst_index in range(max(bursts, 1)):
		var center := Vector2(randf_range(120.0, viewport_size.x - 120.0), randf_range(80.0, viewport_size.y * 0.55))
		for particle_index in range(max(particles_per_burst, 1)):
			var spark := Label.new()
			spark.theme_type_variation = "BadgeLabel"
			spark.text = spark_symbols[(burst_index + particle_index) % spark_symbols.size()]
			spark.position = center
			spark.scale = Vector2(1.6, 1.6)
			spark.modulate = colors[(burst_index + particle_index) % colors.size()]
			fireworks_layer.add_child(spark)

			var angle: float = randf_range(0.0, TAU)
			var radius: float = randf_range(86.0, 160.0) * max(radius_scale, 0.2)
			var target: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius
			var tween := create_tween()
			tween.tween_interval(burst_delay * burst_index)
			tween.tween_property(spark, "position", target, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(spark, "modulate:a", 0.0, 0.8)
			tween.parallel().tween_property(spark, "scale", Vector2(0.24, 0.24), 0.8)
			tween.tween_callback(spark.queue_free)
