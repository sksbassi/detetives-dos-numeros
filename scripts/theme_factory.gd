extends RefCounted

class_name ThemeFactory

static func build_theme(body_font_path: String, bold_font_path: String) -> Theme:
	var theme := Theme.new()
	var body_font: FontFile = load(body_font_path) if ResourceLoader.exists(body_font_path) else null
	var bold_font: FontFile = load(bold_font_path) if ResourceLoader.exists(bold_font_path) else body_font

	if body_font != null:
		theme.default_font = body_font
		theme.default_font_size = 18

	var ink := Color("#2D325A")
	var muted_ink := Color("#58638A")
	var surface := Color("#FFFFFF")
	var sky := Color("#DFF4FF")
	var mint := Color("#E6FFF0")
	var lemon := Color("#FFF5B8")
	var blush := Color("#FFE1F1")
	var lavender := Color("#F0E8FF")
	var primary := Color("#4FACFE")
	var primary_hover := Color("#62B8FF")
	var secondary := Color("#A786FF")
	var secondary_hover := Color("#B79AFF")
	var success := Color("#6BCB77")
	var warning := Color("#FFD93D")
	var coral := Color("#FF8C42")
	var chip := Color("#FFFFFF")
	var choice := Color("#F7F4FF")
	var choice_hover := Color("#FFF0FA")
	var choice_selected := Color("#FFD93D")

	theme.set_color("font_color", "Label", ink)
	theme.set_color("font_shadow_color", "Label", Color(1, 1, 1, 0.18))

	_make_label(theme, "TitleLabel", bold_font, 34, ink)
	_make_label(theme, "HeadingLabel", bold_font, 24, ink)
	_make_label(theme, "QuestionLabel", bold_font, 28, ink)
	_make_label(theme, "BodyLabel", body_font, 18, ink)
	_make_label(theme, "CaptionLabel", body_font, 15, muted_ink)
	_make_label(theme, "PillLabel", bold_font, 15, ink)
	_make_label(theme, "MentorLabel", bold_font, 16, Color("#40557C"))
	_make_label(theme, "ModalTitleLabel", bold_font, 30, ink)
	_make_label(theme, "BadgeLabel", bold_font, 16, ink)
	_make_label(theme, "AvatarLabel", bold_font, 112, Color("#31537A"))

	theme.set_stylebox("panel", "PanelContainer", _panel_style(surface, Color("#DDE8FF")))
	theme.set_stylebox("panel", "MainCard", _panel_style(surface, Color("#DDE8FF"), 28, 24))
	theme.set_stylebox("panel", "HudCard", _panel_style(sky, Color("#B9E5FF"), 26, 22))
	theme.set_stylebox("panel", "StageCard", _panel_style(lemon, Color("#F6D856"), 30, 22))
	theme.set_stylebox("panel", "QuestionCard", _panel_style(blush, Color("#FFC0DE"), 30, 22))
	theme.set_stylebox("panel", "OptionsCard", _panel_style(lavender, Color("#D3C0FF"), 30, 22))
	theme.set_stylebox("panel", "ActionsCard", _panel_style(mint, Color("#B8E6C1"), 26, 20))
	theme.set_stylebox("panel", "StageFrame", _panel_style(surface, Color("#D9E7FF"), 22, 14))
	theme.set_stylebox("panel", "StageCanvas", _panel_style(Color("#FBFDFF"), Color("#D6E8FF"), 22, 14))
	theme.set_stylebox("panel", "ModalCard", _panel_style(surface, Color("#DDE8FF"), 32, 28))
	theme.set_stylebox("panel", "IntroCard", _panel_style(Color("#FFFFFF"), Color("#DDE8FF"), 34, 30))
	theme.set_stylebox("panel", "JourneyCard", _panel_style(Color("#FFFFFF"), Color("#DDE8FF"), 34, 30))
	theme.set_stylebox("panel", "PauseCardAlt", _pause_modal_style())
	theme.set_stylebox("panel", "RewardPopupCard", _panel_style(Color("#FFFFFF"), Color("#DDE8FF"), 30, 24))
	theme.set_stylebox("panel", "SymbolChip", _panel_style(chip, Color("#D7E5FF"), 20, 8))

	theme.set_stylebox("normal", "Button", _button_style(primary, Color("#2B7FCC")))
	theme.set_stylebox("hover", "Button", _button_style(primary_hover, Color("#2B7FCC")))
	theme.set_stylebox("pressed", "Button", _button_style(Color("#379AEF"), Color("#246DA8")))
	theme.set_stylebox("disabled", "Button", _button_style(Color("#C8D3E8"), Color("#B4C4DF")))
	theme.set_stylebox("focus", "Button", _focus_style(primary))
	theme.set_color("font_color", "Button", Color.WHITE)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_pressed_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", Color("#EEF2F8"))
	if bold_font != null:
		theme.set_font("font", "Button", bold_font)
	theme.set_font_size("font_size", "Button", 18)

	_make_button_variation(theme, "PrimaryButton", primary, primary_hover, Color("#379AEF"), Color("#2B7FCC"), Color.WHITE, bold_font)
	_make_button_variation(theme, "SecondaryButton", secondary, secondary_hover, Color("#8F72F0"), Color("#7255CB"), Color.WHITE, bold_font)
	_make_button_variation(theme, "CelebrateButton", coral, Color("#FFB15C"), Color("#FF9A2F"), Color("#D66F22"), Color.WHITE, bold_font)
	_make_button_variation(theme, "ChoiceButton", choice, choice_hover, Color("#F6D8EB"), Color("#D8C3FF"), ink, bold_font)
	_make_button_variation(theme, "ChoiceButtonSelected", choice_selected, Color("#FFE35C"), warning, Color("#C8A400"), Color("#6A5100"), bold_font)
	_make_button_variation(theme, "GhostButton", Color("#FFFFFF"), Color("#F5F9FF"), Color("#EAF2FF"), Color("#D7E5FF"), ink, bold_font)

	theme.set_stylebox("normal", "LineEdit", _panel_style(Color.WHITE, Color("#D9E7FF"), 22, 12))
	theme.set_stylebox("focus", "LineEdit", _panel_style(Color.WHITE, primary, 22, 12))
	theme.set_stylebox("read_only", "LineEdit", _panel_style(Color("#F5F8FD"), Color("#D9E7FF"), 22, 12))
	theme.set_color("font_color", "LineEdit", ink)
	theme.set_color("font_placeholder_color", "LineEdit", Color("#8B97B5"))
	if body_font != null:
		theme.set_font("font", "LineEdit", body_font)
	theme.set_font_size("font_size", "LineEdit", 18)

	theme.set_stylebox("background", "ProgressBar", _panel_style(Color("#E5EEF8"), Color("#D7E3F3"), 18, 8))
	theme.set_stylebox("fill", "ProgressBar", _panel_style(success, Color("#47AF56"), 18, 8))
	theme.set_constant("outline_size", "ProgressBar", 0)
	theme.set_color("font_color", "ProgressBar", ink)

	theme.set_stylebox("slider", "HSlider", _panel_style(Color("#FFF1D4"), Color("#F6C76B"), 18, 4))
	theme.set_stylebox("grabber_area", "HSlider", _panel_style(Color("#FFF7E8"), Color("#FFD88A"), 18, 0))
	theme.set_stylebox("grabber_area_highlight", "HSlider", _panel_style(Color("#FFF2C7"), Color("#FFB347"), 18, 0))
	theme.set_stylebox("panel", "TabContainer", _panel_style(Color("#F8FBFF"), Color("#D6E7FF"), 24, 10))
	theme.set_stylebox("tab_selected", "TabBar", _button_style(primary, Color("#2B7FCC")))
	theme.set_stylebox("tab_hovered", "TabBar", _button_style(primary_hover, Color("#2B7FCC")))
	theme.set_stylebox("tab_unselected", "TabBar", _button_style(Color("#EDF5FF"), Color("#D5E6FF")))
	theme.set_stylebox("tab_disabled", "TabBar", _button_style(Color("#EEF2F8"), Color("#DCE3F2")))
	theme.set_stylebox("tab_focus", "TabBar", _focus_style(primary))
	theme.set_color("font_selected_color", "TabBar", Color.WHITE)
	theme.set_color("font_hovered_color", "TabBar", Color.WHITE)
	theme.set_color("font_unselected_color", "TabBar", ink)
	theme.set_color("font_disabled_color", "TabBar", muted_ink)
	if bold_font != null:
		theme.set_font("font", "TabBar", bold_font)
	theme.set_font_size("font_size", "TabBar", 16)

	return theme

static func _make_label(theme: Theme, type_name: String, font: Font, size: int, color: Color) -> void:
	if font != null:
		theme.set_font("font", type_name, font)
	theme.set_font_size("font_size", type_name, size)
	theme.set_color("font_color", type_name, color)

static func _make_button_variation(theme: Theme, type_name: String, normal_color: Color, hover_color: Color, pressed_color: Color, border_color: Color, font_color: Color, font: Font) -> void:
	theme.set_stylebox("normal", type_name, _button_style(normal_color, border_color))
	theme.set_stylebox("hover", type_name, _button_style(hover_color, border_color))
	theme.set_stylebox("pressed", type_name, _button_style(pressed_color, border_color))
	theme.set_stylebox("disabled", type_name, _button_style(Color("#DCE3F2"), Color("#C9D3E6")))
	theme.set_stylebox("focus", type_name, _focus_style(border_color))
	theme.set_color("font_color", type_name, font_color)
	theme.set_color("font_hover_color", type_name, font_color)
	theme.set_color("font_pressed_color", type_name, font_color)
	theme.set_color("font_disabled_color", type_name, Color("#7D87A7"))
	if font != null:
		theme.set_font("font", type_name, font)
	theme.set_font_size("font_size", type_name, 18)

static func _panel_style(fill: Color, border: Color, radius: int = 24, shadow: int = 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.shadow_color = Color(0.18, 0.24, 0.46, 0.12)
	style.shadow_size = shadow
	style.shadow_offset = Vector2(0, 7)
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	return style

static func _pause_modal_style() -> StyleBoxFlat:
	var style := _panel_style(Color("#FDFEFF"), Color("#FFFFFF"), 32, 22)
	style.border_width_left = 6
	style.border_width_top = 6
	style.border_width_right = 6
	style.border_width_bottom = 6
	style.shadow_color = Color(0.18, 0.24, 0.46, 0.16)
	style.shadow_size = 20
	style.shadow_offset = Vector2(0, 8)
	return style

static func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := _panel_style(fill, border, 22, 8)
	style.content_margin_left = 20
	style.content_margin_top = 15
	style.content_margin_right = 20
	style.content_margin_bottom = 15
	return style

static func _focus_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.draw_center = false
	style.border_color = color
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_right = 24
	style.corner_radius_bottom_left = 24
	return style
