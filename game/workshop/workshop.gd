extends CanvasLayer

signal closed

const PARTS_DIR := "res://game/parts/data/"
const FRAMES := [preload("res://game/workshop/sprites/frame_chatarra.png"),
		preload("res://game/workshop/sprites/frame_reparada.png"),
		preload("res://game/workshop/sprites/frame_legendaria.png")]
const SCRAP_ICON := preload("res://game/parts/scrap/scrap.png")
const SCRAP_ICON_SIZE := 8
const LEGENDARY := 2
const LEGENDARY_FROM_WAVE := 3
const WEIGHT_BASE := [6.0, 3.0, 1.0]
const WEIGHT_PER_WAVE := [-1.0, 0.5, 0.5]
const MIN_WEIGHT := 0.5
const OFFERS := 3
const REROLL_BASE := 10
const REROLL_STEP := 5
const SKIP_REWARD := 10

const RARITY_NAMES := ["CHATARRA", "REPARADA", "LEGENDARIA"]
const RARITY_COLORS := [Color("a0a6b8"), Color("82beff"), Color("ffd64a")]
const SLOT_NAMES := {Part.HEAD: "Cabeza", Part.ARM: "Brazo", Part.LEGS: "Piernas", Part.BACK: "Espalda"}
const STAT_NAMES := {"speed": "Velocidad", "max_hp": "Vida", "damage": "Daño", "fire_rate": "Cadencia",
		"range": "Alcance", "pierce": "Perforación", "auto_aim": "Autoapuntado", "ignore_oil": "Ignora aceite", "bounces": "Rebotes"}
const LOWER_IS_BETTER := ["fire_rate"]

const TEXT_COLOR := Color("dce0ea")
const MUTED_COLOR := Color("a0a6b8")
const AMBER := Color("ffb02e")
const GOOD_COLOR := Color("6fe06f")
const BAD_COLOR := Color("ff5a4a")
const OUTLINE_COLOR := Color("1a1030")
const BUTTON_BG := Color("3b3a4c")
const BUTTON_HOVER := Color("6e2f1c")
const BUTTON_OFF := Color("23202e")
const BUTTON_BORDER := Color("ff7a1a")
const BUTTON_OFF_BORDER := Color("4a4a5c")
const BUTTON_PAD := 6
const BUTTON_BORDER_W := 2
const TITLE_SIZE := 20
const TITLE_OUTLINE := 6
const NAME_SIZE := 10
const TEXT_SIZE := 8
const TEXT_OUTLINE := 3

const CARD_SIZE := Vector2(176, 170)
const FRAME_MARGIN := 8
const CARD_PAD := 10
const CARD_SEPARATION := 2
const ICON_SCALE := 2
const ICON_FRAME := 32
const ICON_LOOP_FRAMES := 4
const HOVER_SCALE := Vector2(1.06, 1.06)
const HOVER_TIME := 0.1
const GLOW_COLOR := Color(1.5, 1.3, 0.8)
const GLOW_TIME := 0.7

const PREVIEW_SCALE := Vector2(3, 3)
const IDLE_FRAMES := 4
const IDLE_FPS := 5.0
const LAYER_FPS := 6.0
const FLY_TIME := 0.3
const FADE_TIME := 0.2
const FADE_ALPHA := 0.15
const FLASH_COLOR := Color(4, 4, 4)
const FLASH_TIME := 0.2
const SQUASH := Vector2(1.3, 0.7)
const SQUASH_TIME := 0.4
const EQUIP_HOLD := 0.5

var player: Node2D
var wave := 1

var _pool: Array[Part] = []
var _offers: Array[Part] = []
var _cards: Array[Control] = []
var _icons: Array = []
var _layers := {}
var _base := {}
var _rerolls := 0
var _busy := false
var _clock := 0.0

@onready var title: Label = %Title
@onready var scrap_icon: TextureRect = %Icon
@onready var scrap_label: Label = %Count
@onready var stage: Control = %Stage
@onready var pivot: Node2D = %Pivot
@onready var robot: Node2D = %Robot
@onready var sparks: CPUParticles2D = %Sparks
@onready var cards_box: HBoxContainer = %Cards
@onready var reroll: Button = %Reroll
@onready var skip: Button = %Skip

func _ready() -> void:
	get_tree().paused = true
	for f in DirAccess.get_files_at(PARTS_DIR):
		var path := PARTS_DIR + f.trim_suffix(".remap")
		if path.ends_with(".tres") and load(path) is Part:
			_pool.append(load(path))
	title.text = "TALLER"
	_style(title, TITLE_SIZE, AMBER, TITLE_OUTLINE)
	_style(scrap_label, NAME_SIZE, TEXT_COLOR, TEXT_OUTLINE)
	var icon := AtlasTexture.new()
	icon.atlas = SCRAP_ICON
	icon.region = Rect2(0, 0, SCRAP_ICON_SIZE, SCRAP_ICON_SIZE)
	scrap_icon.texture = icon
	for b: Button in [reroll, skip]:
		_style(b, TEXT_SIZE, TEXT_COLOR, TEXT_OUTLINE)
		b.add_theme_stylebox_override("normal", _button_box(BUTTON_BG, BUTTON_BORDER))
		b.add_theme_stylebox_override("hover", _button_box(BUTTON_HOVER, BUTTON_BORDER))
		b.add_theme_stylebox_override("pressed", _button_box(BUTTON_HOVER, BUTTON_BORDER))
		b.add_theme_stylebox_override("disabled", _button_box(BUTTON_OFF, BUTTON_OFF_BORDER))
		b.add_theme_color_override("font_disabled_color", MUTED_COLOR)
	skip.text = "Saltar (+%d tornillos)" % SKIP_REWARD
	reroll.pressed.connect(_reroll)
	skip.pressed.connect(_skip)
	player.scrap_changed.connect(_refresh)
	stage.resized.connect(_center_stage)
	_build_preview()
	_deal()

func _process(delta: float) -> void:
	_clock += delta
	for slot in _layers:
		var l: Sprite2D = _layers[slot]
		var frames := mini(l.hframes, IDLE_FRAMES) if slot == Part.LEGS else l.hframes
		l.frame = int(_clock * (IDLE_FPS if slot == Part.LEGS else LAYER_FPS)) % frames
	for i in _icons:
		i[0].region.position.x = (int(_clock * LAYER_FPS) % i[1]) * ICON_FRAME

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		var i: int = event.physical_keycode - KEY_1
		if i >= 0 and i < _offers.size():
			_choose(i)

func _center_stage() -> void:
	pivot.position = stage.size / 2.0

func _build_preview() -> void:
	robot.scale = PREVIEW_SCALE
	_layers = {Part.HEAD: %Head, Part.ARM: %Arm, Part.LEGS: %Legs,
			Part.BACK: %Back}
	%Torso.texture = player.torso.texture
	for slot in _layers:
		var src: Sprite2D = player.layers[slot]
		_base[slot] = [src.texture, src.hframes]
		_restore(slot)

func _show_part(part: Part) -> void:
	var l: Sprite2D = _layers[part.slot]
	l.texture = part.texture
	l.hframes = part.frames()

func _restore(slot: String) -> void:
	var l: Sprite2D = _layers[slot]
	l.texture = _base[slot][0]
	l.hframes = _base[slot][1]

func _deal() -> void:
	for c in _cards:
		cards_box.remove_child(c)
		c.queue_free()
	_cards.clear()
	_icons.clear()
	_offers = _roll()
	for i in _offers.size():
		_cards.append(_make_card(i, _offers[i]))
	_refresh()

func _roll() -> Array[Part]:
	var equipped: Array = player.parts.values()
	var left := _pool.filter(func(p: Part): return p not in equipped and _weight(p) > 0.0)
	var out: Array[Part] = []
	var slots := []
	while out.size() < OFFERS and not left.is_empty():
		var fresh := left.filter(func(p: Part): return p.slot not in slots)
		var p := _pick(fresh if not fresh.is_empty() else left)
		out.append(p)
		slots.append(p.slot)
		left.erase(p)
	return out

func _weight(p: Part) -> float:
	if p.rarity == LEGENDARY and wave < LEGENDARY_FROM_WAVE:
		return 0.0
	return maxf(WEIGHT_BASE[p.rarity] + WEIGHT_PER_WAVE[p.rarity] * wave, MIN_WEIGHT)

func _pick(from: Array) -> Part:
	var total := 0.0
	for p: Part in from:
		total += _weight(p)
	var r := randf() * total
	for p: Part in from:
		r -= _weight(p)
		if r <= 0.0:
			return p
	return from[0]

func _make_card(i: int, part: Part) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = CARD_SIZE
	card.pivot_offset = CARD_SIZE / 2.0
	var sb := StyleBoxTexture.new()
	sb.texture = FRAMES[part.rarity]
	sb.set_texture_margin_all(FRAME_MARGIN)
	sb.set_content_margin_all(CARD_PAD)
	card.add_theme_stylebox_override("panel", sb)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", CARD_SEPARATION)
	card.add_child(box)

	var top := HBoxContainer.new()
	box.add_child(top)
	top.add_child(_label("[%d]" % (i + 1), TEXT_SIZE, MUTED_COLOR))
	var slot := _label(SLOT_NAMES[part.slot], TEXT_SIZE, MUTED_COLOR, true)
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(slot)
	var rar := _label(RARITY_NAMES[part.rarity], TEXT_SIZE, RARITY_COLORS[part.rarity])
	top.add_child(rar)

	var atlas := AtlasTexture.new()
	atlas.atlas = part.texture
	atlas.region = Rect2(0, 0, ICON_FRAME, ICON_FRAME)
	_icons.append([atlas, mini(part.frames(), ICON_LOOP_FRAMES)])
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon.texture = atlas
	icon.custom_minimum_size = Vector2.ONE * ICON_FRAME * ICON_SCALE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	box.add_child(icon)

	box.add_child(_label(part.name, NAME_SIZE, TEXT_COLOR, true))
	var desc := _label(part.description, TEXT_SIZE, TEXT_COLOR, true)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(desc)
	for d in _diff(part):
		box.add_child(_label(d[0], TEXT_SIZE, d[1], true))
	var cur: Part = player.parts.get(part.slot)
	box.add_child(_label("reemplaza: %s" % (cur.name if cur else "ranura libre"), TEXT_SIZE, MUTED_COLOR, true))

	for c in card.find_children("*", "Control", true, false):
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.mouse_entered.connect(_hover.bind(card, part))
	card.mouse_exited.connect(_unhover.bind(card, part))
	card.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_choose(i))
	cards_box.add_child(card)
	if part.rarity == LEGENDARY:
		var glow := card.create_tween().set_loops()
		glow.tween_property(sb, "modulate_color", GLOW_COLOR, GLOW_TIME)
		glow.tween_property(sb, "modulate_color", Color.WHITE, GLOW_TIME)
	return card

func _diff(part: Part) -> Array:
	var cur: Part = player.parts.get(part.slot)
	var old: Dictionary = cur.stats if cur else {}
	var keys := part.stats.keys()
	for k in old:
		if k not in keys:
			keys.append(k)
	var out := []
	for k in keys:
		var d := float(part.stats.get(k, 0)) - float(old.get(k, 0))
		if is_zero_approx(d):
			continue
		var good := d < 0.0 if k in LOWER_IS_BETTER else d > 0.0
		var n := "%d" % absf(d) if is_equal_approx(absf(d), roundf(absf(d))) else "%.2f" % absf(d)
		out.append(["%s%s %s" % ["+" if d > 0.0 else "-", n, STAT_NAMES.get(k, k)], GOOD_COLOR if good else BAD_COLOR])
	return out

func _hover(card: Control, part: Part) -> void:
	if _busy:
		return
	_show_part(part)
	card.create_tween().tween_property(card, "scale", HOVER_SCALE, HOVER_TIME)

func _unhover(card: Control, part: Part) -> void:
	if _busy:
		return
	_restore(part.slot)
	card.create_tween().tween_property(card, "scale", Vector2.ONE, HOVER_TIME)

func _choose(i: int) -> void:
	if _busy:
		return
	_busy = true
	_refresh()
	var part := _offers[i]
	_show_part(part)
	var icon: TextureRect = _cards[i].find_child("Icon", true, false)
	var fly := Sprite2D.new()
	fly.texture = icon.texture
	fly.scale = Vector2.ONE * ICON_SCALE
	fly.global_position = icon.global_position + icon.size / 2.0
	for c in _cards:
		create_tween().tween_property(c, "modulate:a", FADE_ALPHA, FADE_TIME)
	_restore(part.slot)
	add_child(fly)
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(fly, "global_position", robot.global_position, FLY_TIME)
	t.tween_property(fly, "scale", PREVIEW_SCALE, FLY_TIME)
	await t.finished
	fly.queue_free()
	# SFX: equip
	_show_part(part)
	sparks.restart()
	robot.modulate = FLASH_COLOR
	create_tween().tween_property(robot, "modulate", Color.WHITE, FLASH_TIME)
	robot.scale = PREVIEW_SCALE * SQUASH
	create_tween().tween_property(robot, "scale", PREVIEW_SCALE, SQUASH_TIME).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(EQUIP_HOLD).timeout
	player.equip(part)
	_close()

func _reroll() -> void:
	if _busy or player.scrap < _reroll_cost():
		return
	player.add_scrap(-_reroll_cost())
	_rerolls += 1
	_deal()

func _skip() -> void:
	if _busy:
		return
	player.add_scrap(SKIP_REWARD)
	_close()

func _close() -> void:
	get_tree().paused = false
	closed.emit()
	queue_free()

func _reroll_cost() -> int:
	return REROLL_BASE + REROLL_STEP * _rerolls

func _refresh(_n := 0) -> void:
	scrap_label.text = " x %d" % player.scrap
	reroll.text = "Re-roll (%d tornillos)" % _reroll_cost()
	reroll.disabled = _busy or player.scrap < _reroll_cost()
	skip.disabled = _busy

func _label(text: String, size: int, color: Color, center := false) -> Label:
	var l := Label.new()
	l.text = text
	_style(l, size, color, TEXT_OUTLINE)
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _style(c: Control, size: int, color: Color, outline: int) -> void:
	c.add_theme_font_size_override("font_size", size)
	c.add_theme_color_override("font_color", color)
	c.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	c.add_theme_constant_override("outline_size", outline)

func _button_box(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(BUTTON_BORDER_W)
	s.set_content_margin_all(BUTTON_PAD)
	return s
