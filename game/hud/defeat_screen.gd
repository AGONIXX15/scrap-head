class_name DefeatScreen extends CanvasLayer

signal retried

const RED := Color("ff5a4a")
const OUTLINE_COLOR := Color("1a1030")
const TEXT_COLOR := Color("dce0ea")
const MUTED_COLOR := Color("a0a6b8")
const BUTTON_BG := Color("3b3a4c")
const BUTTON_HOVER := Color("6e2f1c")
const BUTTON_PRESSED := Color("23202e")
const BUTTON_BORDER := Color("ff7a1a")
const BUTTON_BORDER_W := 2
const BUTTON_PAD := 6
const TITLE_SIZE := 24
const TITLE_OUTLINE := 6
const BUTTON_FONT_SIZE := 10
const BUTTON_OUTLINE := 3
const HINT_SIZE := 8
const HINT_OUTLINE := 2
const DEFEAT_DELAY := 0.6
const FADE_TIME := 0.25

@export var player: CharacterBody2D

@onready var dim: ColorRect = $Dim
@onready var panel: PanelContainer = %Panel
@onready var title: Label = %Title
@onready var hint: Label = %Hint
@onready var btn_retry: Button = %BtnRetry
@onready var btn_quit: Button = %BtnQuit

var _active := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_setup_styles()
	btn_retry.pressed.connect(restart)
	if btn_quit:
		btn_quit.pressed.connect(quit_game)

	if not player:
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player and is_instance_valid(player):
		if not player.died.is_connected(_on_player_died):
			player.died.connect(_on_player_died)

func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			get_viewport().set_input_as_handled()
			restart()

func _on_player_died() -> void:
	_active = true
	await get_tree().create_timer(DEFEAT_DELAY, true, false, true).timeout
	if not is_inside_tree():
		return
	get_tree().paused = true
	show()
	btn_retry.grab_focus()

	dim.modulate.a = 0.0
	panel.modulate.a = 0.0
	panel.pivot_offset = panel.size / 2.0 if panel.size != Vector2.ZERO else Vector2(90, 60)
	panel.scale = Vector2(0.9, 0.9)
	var tw := create_tween().set_parallel()
	tw.tween_property(dim, "modulate:a", 1.0, FADE_TIME)
	tw.tween_property(panel, "modulate:a", 1.0, FADE_TIME)
	tw.tween_property(panel, "scale", Vector2.ONE, FADE_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func restart() -> void:
	_active = false
	retried.emit()
	get_tree().paused = false
	get_tree().reload_current_scene()

func quit_game() -> void:
	_active = false
	get_tree().paused = false
	get_tree().quit()

func _setup_styles() -> void:
	# Dialog panel
	var panel_sb := StyleBoxFlat.new()
	panel_sb.bg_color = Color(0.1, 0.07, 0.14, 0.95)
	panel_sb.border_color = Color(0.5, 0.2, 0.25, 0.95)
	panel_sb.set_border_width_all(2)
	panel_sb.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", panel_sb)

	# Title
	title.text = "Destruido"
	title.add_theme_font_size_override("font_size", TITLE_SIZE)
	title.add_theme_color_override("font_color", RED)
	title.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	title.add_theme_constant_override("outline_size", TITLE_OUTLINE)

	# Hint
	if hint:
		hint.add_theme_font_size_override("font_size", HINT_SIZE)
		hint.add_theme_color_override("font_color", MUTED_COLOR)
		hint.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
		hint.add_theme_constant_override("outline_size", HINT_OUTLINE)

	# Buttons
	for btn: Button in [btn_retry, btn_quit]:
		if btn:
			_style_button(btn)

func _style_button(btn: Button) -> void:
	btn.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE)
	btn.add_theme_color_override("font_color", TEXT_COLOR)
	btn.add_theme_color_override("font_hover_color", RED)
	btn.add_theme_color_override("font_pressed_color", RED)
	btn.add_theme_color_override("font_focus_color", RED)
	btn.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	btn.add_theme_constant_override("outline_size", BUTTON_OUTLINE)

	var normal_box := _button_box(BUTTON_BG, BUTTON_BORDER)
	var hover_box := _button_box(BUTTON_HOVER, BUTTON_BORDER)
	var pressed_box := _button_box(BUTTON_PRESSED, RED)
	var focus_box := _button_box(BUTTON_HOVER, RED)

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
