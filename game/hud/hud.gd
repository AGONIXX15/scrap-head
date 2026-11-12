class_name HUD extends CanvasLayer

const SLOTS: Array[String] = [Part.HEAD, Part.ARM, Part.LEGS, Part.BACK]
const SLOT_NAMES := {
	Part.HEAD: "CABEZA",
	Part.ARM: "BRAZO",
	Part.LEGS: "TRACCIÓN",
	Part.BACK: "ESPALDA",
}
const SLOT_TITLES := {
	Part.HEAD: "Cabeza",
	Part.ARM: "Brazo",
	Part.LEGS: "Tracción",
	Part.BACK: "Espalda",
}

const FRAMES := [
	preload("res://game/workshop/sprites/frame_chatarra.png"),
	preload("res://game/workshop/sprites/frame_reparada.png"),
	preload("res://game/workshop/sprites/frame_legendaria.png"),
]
const RARITY_NAMES := ["Chatarra", "Reparada", "Legendaria"]
const RARITY_COLORS := [Color("a0a6b8"), Color("82beff"), Color("ffd64a")]

const LABEL_COLOR := Color("a0a6b8")
const OUTLINE_COLOR := Color("1a1030")
const LABEL_SIZE := 8
const LABEL_OUTLINE := 2

const FRAME_MARGIN := 8
const FRAME_PAD := 2
const POP_SCALE := Vector2(1.25, 1.25)
const POP_TIME := 0.25

@export var player: CharacterBody2D

@onready var parts_dock: PanelContainer = %PartsDock
@onready var slots_container: HBoxContainer = %SlotsContainer

var _slot_nodes := {}
var _last_parts := {}
var _empty_style: StyleBoxFlat
var _dock_style: StyleBoxFlat

func _ready() -> void:
	_init_styles()
	_init_dock()
	_setup_slots()
	if not player:
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player:
		if not player.parts_changed.is_connected(_on_parts_changed):
			player.parts_changed.connect(_on_parts_changed)
		update_parts(player.parts)
	else:
		update_parts({})

func _init_styles() -> void:
	_empty_style = StyleBoxFlat.new()
	_empty_style.bg_color = Color(0.08, 0.07, 0.12, 0.75)
	_empty_style.border_color = Color(0.24, 0.22, 0.32, 0.8)
	_empty_style.set_border_width_all(1)
	_empty_style.set_corner_radius_all(3)
	_empty_style.set_content_margin_all(FRAME_PAD)

	_dock_style = StyleBoxFlat.new()
	_dock_style.bg_color = Color(0.05, 0.04, 0.08, 0.6)
	_dock_style.border_color = Color(0.18, 0.16, 0.24, 0.6)
	_dock_style.set_border_width_all(1)
	_dock_style.set_corner_radius_all(4)
	_dock_style.set_content_margin_all(5)

func _init_dock() -> void:
	if parts_dock:
		parts_dock.add_theme_stylebox_override("panel", _dock_style)

func _setup_slots() -> void:
	_slot_nodes.clear()
	for slot in SLOTS:
		var node_name: String = "Slot_" + slot
		var col: Control = null
		if has_node("%" + node_name):
			col = get_node("%" + node_name)
		elif slots_container:
			col = _create_slot_node(slot)
			slots_container.add_child(col)

		if col:
			var label: Label = col.get_node_or_null("Label")
			var frame: PanelContainer = col.get_node_or_null("Frame")
			var icon: TextureRect = frame.get_node_or_null("Icon") if frame else null
			if label:
				_style_label(label, SLOT_NAMES[slot])
			if frame:
				frame.pivot_offset = Vector2(18, 18)
			_slot_nodes[slot] = {
				"col": col,
				"label": label,
				"frame": frame,
				"icon": icon,
			}

func _create_slot_node(slot: String) -> Control:
	var col := VBoxContainer.new()
	col.name = "Slot_" + slot
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 2)

	var label := Label.new()
	label.name = "Label"
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style_label(label, SLOT_NAMES[slot])
	col.add_child(label)

	var frame := PanelContainer.new()
	frame.name = "Frame"
	frame.custom_minimum_size = Vector2(36, 36)
	frame.pivot_offset = Vector2(18, 18)
	frame.mouse_filter = Control.MOUSE_FILTER_PASS
	col.add_child(frame)

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(icon)

	return col

func _style_label(label: Label, text: String) -> void:
	label.text = text
	label.add_theme_font_size_override("font_size", LABEL_SIZE)
	label.add_theme_color_override("font_color", LABEL_COLOR)
	label.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	label.add_theme_constant_override("outline_size", LABEL_OUTLINE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func update_parts(parts: Dictionary) -> void:
	for slot in SLOTS:
		if not _slot_nodes.has(slot):
			continue
		var s: Dictionary = _slot_nodes[slot]
		var frame: PanelContainer = s.frame
		var icon: TextureRect = s.icon
		var label: Label = s.label
		var prev_part: Part = _last_parts.get(slot)
		var current_part: Part = parts.get(slot)

		if current_part:
			var atlas := AtlasTexture.new()
			atlas.atlas = current_part.texture
			atlas.region = Rect2(0, 0, Part.FRAME_SIZE, Part.FRAME_SIZE)
			icon.texture = atlas
			icon.modulate = Color.WHITE

			var sb := StyleBoxTexture.new()
			sb.texture = FRAMES[current_part.rarity]
			sb.set_texture_margin_all(FRAME_MARGIN)
			sb.set_content_margin_all(FRAME_PAD)
			frame.add_theme_stylebox_override("panel", sb)

			frame.tooltip_text = "%s [%s]\n%s" % [current_part.name, RARITY_NAMES[current_part.rarity], current_part.description]
			label.add_theme_color_override("font_color", RARITY_COLORS[current_part.rarity])

			if prev_part != current_part and is_inside_tree():
				_pop(frame)
		else:
			icon.texture = null
			frame.add_theme_stylebox_override("panel", _empty_style)
			frame.tooltip_text = "Ranura: %s (vacía)" % SLOT_TITLES[slot]
			label.add_theme_color_override("font_color", LABEL_COLOR)

	_last_parts = parts.duplicate()

func _pop(control: Control) -> void:
	control.pivot_offset = control.size / 2.0 if control.size != Vector2.ZERO else Vector2(18, 18)
	var tw := control.create_tween()
	control.scale = POP_SCALE
	tw.tween_property(control, "scale", Vector2.ONE, POP_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_parts_changed(parts: Dictionary) -> void:
	update_parts(parts)

func set_player(p: CharacterBody2D) -> void:
	if player and is_instance_valid(player) and player.parts_changed.is_connected(_on_parts_changed):
		player.parts_changed.disconnect(_on_parts_changed)
	player = p
	if player and is_instance_valid(player):
		if not player.parts_changed.is_connected(_on_parts_changed):
			player.parts_changed.connect(_on_parts_changed)
		update_parts(player.parts)
