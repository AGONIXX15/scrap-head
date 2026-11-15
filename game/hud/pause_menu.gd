class_name PauseMenu extends CanvasLayer

signal paused
signal resumed

const AMBER := Color("ffb02e")
const ORANGE := Color("ff7a1a")
const OUTLINE_COLOR := Color("1a1030")
const TEXT_COLOR := Color("dce0ea")
const BUTTON_BG := Color("3b3a4c")
const BUTTON_HOVER := Color("6e2f1c")
const BUTTON_PRESSED := Color("23202e")
const BUTTON_BORDER := Color("ff7a1a")
const BUTTON_BORDER_W := 2
const BUTTON_PAD := 6
const TITLE_SIZE := 20
const TITLE_OUTLINE := 6
const BUTTON_FONT_SIZE := 10
const BUTTON_OUTLINE := 3

@onready var panel: PanelContainer = %Panel
@onready var title: Label = %Title
@onready var btn_resume: Button = %BtnResume
@onready var btn_restart: Button = %BtnRestart
@onready var btn_quit: Button = %BtnQuit

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_setup_styles()
	btn_resume.pressed.connect(resume)
	btn_restart.pressed.connect(restart)
	btn_quit.pressed.connect(quit_game)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
		if visible:
			resume()
			get_viewport().set_input_as_handled()
		else:
			if _can_pause():
				pause()
				get_viewport().set_input_as_handled()

func _can_pause() -> bool:
	var workshop := get_tree().get_first_node_in_group("workshop")
	if workshop and is_instance_valid(workshop) and workshop.is_inside_tree():
		return false
	var player := get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player) and "hp" in player and player.hp <= 0:
		return false
	return true

func pause() -> void:
	get_tree().paused = true
	show()
	btn_resume.grab_focus()
	panel.pivot_offset = panel.size / 2.0 if panel.size != Vector2.ZERO else Vector2(90, 60)
	panel.scale = Vector2(0.92, 0.92)
	var tw := panel.create_tween()
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.18)
	paused.emit()

func resume() -> void:
	get_tree().paused = false
	hide()
	resumed.emit()

func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()

func _setup_styles() -> void:
	# Dialog panel
	var panel_sb := StyleBoxFlat.new()
	panel_sb.bg_color = Color(0.1, 0.08, 0.15, 0.95)
	panel_sb.border_color = Color(0.3, 0.28, 0.42, 0.95)
	panel_sb.set_border_width_all(2)
	panel_sb.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", panel_sb)

	# Title
	title.add_theme_font_size_override("font_size", TITLE_SIZE)
	title.add_theme_color_override("font_color", AMBER)
	title.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	title.add_theme_constant_override("outline_size", TITLE_OUTLINE)

	# Buttons
	for btn: Button in [btn_resume, btn_restart, btn_quit]:
		_style_button(btn)

func _style_button(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	btn.add_theme_color_override("font_color", TEXT_COLOR)
	btn.add_theme_color_override("font_hover_color", AMBER)
	btn.add_theme_color_override("font_pressed_color", AMBER)
	btn.add_theme_color_override("font_focus_color", AMBER)
	btn.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	btn.add_theme_constant_override("outline_size", BUTTON_OUTLINE)

	var normal_box := _button_box(BUTTON_BG, BUTTON_BORDER)
	var hover_box := _button_box(BUTTON_HOVER, BUTTON_BORDER)
	var pressed_box := _button_box(BUTTON_PRESSED, AMBER)
	var focus_box := _button_box(BUTTON_HOVER, AMBER)

	btn.add_theme_stylebox_override("normal", normal_box)
	btn.add_theme_stylebox_override("hover", hover_box)
	btn.add_theme_stylebox_override("pressed", pressed_box)
	btn.add_theme_stylebox_override("focus", focus_box)

func _button_box(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(BUTTON_BORDER_W)
	s.set_content_margin_all(BUTTON_PAD)
	s.set_corner_radius_all(3)
	return s
