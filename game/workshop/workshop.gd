extends CanvasLayer

signal closed

const PARTS_DIR := "res://game/parts/data/"
const FRAMES := [preload("res://game/workshop/sprites/frame_chatarra.png"),
		preload("res://game/workshop/sprites/frame_reparada.png"),
		preload("res://game/workshop/sprites/frame_legendaria.png")]
const SCRAP_ICON := preload("res://game/parts/scrap/scrap.png")
const SCRAP_ICON_SIZE := 8
const LEGENDARY := 2
const LEGENDARY_FROM_WAVE := PartGenerator.LEGENDARY_FROM_WAVE
const GENERATED_BASE := 0.25
const GENERATED_PER_WAVE := 0.2
const GENERATED_MAX := 0.9
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
const CYAN := Color("5ce6e6")
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

# Modo fusión
var _fusion_mode := false
var _fusion_candidates: Array[Part] = []
var _selected_fusion_indices: Array[int] = []

@onready var title: Label = %Title
@onready var scrap_icon: TextureRect = %Icon
@onready var scrap_label: Label = %Count
@onready var stage: Control = %Stage
@onready var pivot: Node2D = %Pivot
@onready var robot: Node2D = %Robot
@onready var sparks: CPUParticles2D = %Sparks
@onready var cards_box: HBoxContainer = %Cards
@onready var mode_toggle: Button = %ModeToggle
@onready var reroll: Button = %Reroll
@onready var skip: Button = %Skip

func _ready() -> void:
	get_tree().paused = true
	for f in DirAccess.get_files_at(PARTS_DIR):
		var path := PARTS_DIR + f.trim_suffix(".remap")
		if path.ends_with(".tres") and load(path) is Part:
			_pool.append(load(path))
	_update_title()
	_style(title, TITLE_SIZE, AMBER, TITLE_OUTLINE)
	_style(scrap_label, NAME_SIZE, TEXT_COLOR, TEXT_OUTLINE)
	var icon := AtlasTexture.new()
	icon.atlas = SCRAP_ICON
	icon.region = Rect2(0, 0, SCRAP_ICON_SIZE, SCRAP_ICON_SIZE)
	scrap_icon.texture = icon
	for b: Button in [mode_toggle, reroll, skip]:
		_style(b, TEXT_SIZE, TEXT_COLOR, TEXT_OUTLINE)
		b.add_theme_stylebox_override("normal", _button_box(BUTTON_BG, BUTTON_BORDER))
		b.add_theme_stylebox_override("hover", _button_box(BUTTON_HOVER, BUTTON_BORDER))
		b.add_theme_stylebox_override("pressed", _button_box(BUTTON_HOVER, BUTTON_BORDER))
		b.add_theme_stylebox_override("disabled", _button_box(BUTTON_OFF, BUTTON_OFF_BORDER))
		b.add_theme_color_override("font_disabled_color", MUTED_COLOR)
	skip.text = "Saltar (+%d tornillos)" % SKIP_REWARD
	mode_toggle.pressed.connect(_toggle_fusion_mode)
	reroll.pressed.connect(_reroll)
	skip.pressed.connect(_skip)
	player.scrap_changed.connect(_refresh)
	stage.resized.connect(_center_stage)
	_build_preview()
	_deal()

func _update_title() -> void:
	if _fusion_mode:
		title.text = "TALLER: FUSIÓN DE PIEZAS (Elige 2 de la misma ranura)"
		mode_toggle.text = "Modo: Tienda"
	else:
		title.text = "TALLER"
		mode_toggle.text = "Modo: Fusión"

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
		if _fusion_mode:
			if i >= 0 and i < _fusion_candidates.size():
				_toggle_fusion_select(i)
		else:
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
	PartGenerator.dress(l, part)

func _restore(slot: String) -> void:
	var l: Sprite2D = _layers[slot]
	l.texture = _base[slot][0]
	l.hframes = _base[slot][1]
	PartGenerator.dress(l, player.parts.get(slot))

func _clear_cards() -> void:
	for c in _cards:
		cards_box.remove_child(c)
		c.queue_free()
	_cards.clear()
	_icons.clear()

func _deal() -> void:
	_clear_cards()
	_offers = _roll()
	for i in _offers.size():
		_cards.append(_make_card(i, _offers[i]))
	_refresh()

func _toggle_fusion_mode() -> void:
	if _busy:
		return
	Sfx.play("ui_click")
	_fusion_mode = not _fusion_mode
	_selected_fusion_indices.clear()
	_update_title()
	if _fusion_mode:
		_build_fusion_candidates()
	else:
		_deal()

func _build_fusion_candidates() -> void:
	_clear_cards()
	_selected_fusion_indices.clear()
	# Reunir piezas equipadas del jugador y piezas de ofertas o banco
	var candidate_list: Array[Part] = []
	for p in player.parts.values():
		if p is Part:
			candidate_list.append(p)
	for p in _offers:
		if p is Part and p not in candidate_list:
			candidate_list.append(p)
	# Si aún tenemos pocas, añadir piezas del pool o generadas para asegurar al menos pares
	var slots := [Part.HEAD, Part.ARM, Part.LEGS, Part.BACK]
	for s in slots:
		var count := candidate_list.filter(func(p: Part): return p.slot == s).size()
		if count < 2:
			var extra := PartGenerator.make(s, _roll_rarity(), wave)
			candidate_list.append(extra)
	_fusion_candidates = candidate_list
	for i in _fusion_candidates.size():
		_cards.append(_make_fusion_card(i, _fusion_candidates[i]))
	_refresh()

func _roll() -> Array[Part]:
	var equipped: Array = player.parts.values()
	var left := _pool.filter(func(p: Part): return p not in equipped and _weight(p) > 0.0)
	var out: Array[Part] = []
	var slots := []
	var generated := clampf(GENERATED_BASE + GENERATED_PER_WAVE * wave, 0.0, GENERATED_MAX)
	while out.size() < OFFERS:
		var fresh := left.filter(func(p: Part): return p.slot not in slots)
		var p: Part
		if fresh.is_empty() or randf() < generated:
			var free := SLOT_NAMES.keys().filter(func(s: String): return s not in slots)
			p = PartGenerator.make(free.pick_random(), _roll_rarity(), wave)
		else:
			p = _pick(fresh)
			left.erase(p)
		out.append(p)
		slots.append(p.slot)
	return out

func _roll_rarity() -> int:
	var r := randf() * (_rarity_weight(0) + _rarity_weight(1) + _rarity_weight(2))
	for i in 3:
		r -= _rarity_weight(i)
		if r <= 0.0:
			return i
	return 0

func _rarity_weight(rarity: int) -> float:
	if rarity == LEGENDARY and wave < LEGENDARY_FROM_WAVE:
		return 0.0
	return maxf(WEIGHT_BASE[rarity] + WEIGHT_PER_WAVE[rarity] * wave, MIN_WEIGHT)

func _weight(p: Part) -> float:
	return _rarity_weight(p.rarity)

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
	PartGenerator.dress_icon(icon, part)
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

	# Información de linaje / mutaciones si es una pieza híbrida
	if not part.pedigree.is_empty():
		_add_pedigree_summary(box, part)

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

func _make_fusion_card(i: int, part: Part) -> Control:
	var card := PanelContainer.new()
	card.name = "FusionCard_%d" % i
	card.custom_minimum_size = Vector2(130, 175)
	card.pivot_offset = Vector2(130, 175) / 2.0
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
	var is_eq: bool = player.parts.get(part.slot) == part
	if is_eq:
		top.add_child(_label("EQUIPADA", TEXT_SIZE, CYAN))
	else:
		top.add_child(_label(RARITY_NAMES[part.rarity], TEXT_SIZE, RARITY_COLORS[part.rarity]))

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
	PartGenerator.dress_icon(icon, part)
	box.add_child(icon)

	box.add_child(_label(part.name, NAME_SIZE, TEXT_COLOR, true))
	var desc := _label(part.description, TEXT_SIZE, TEXT_COLOR, true)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(desc)

	for k in part.stats:
		var v = part.stats[k]
		var val_str: String = "%d" % v if is_equal_approx(float(v), roundf(float(v))) else "%.2f" % float(v)
		box.add_child(_label("%s: %s" % [STAT_NAMES.get(k, k), val_str], TEXT_SIZE, GOOD_COLOR, true))

	if not part.pedigree.is_empty():
		_add_pedigree_summary(box, part)

	for c in card.find_children("*", "Control", true, false):
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.mouse_entered.connect(_hover.bind(card, part))
	card.mouse_exited.connect(_unhover.bind(card, part))
	card.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			_toggle_fusion_select(i))
	cards_box.add_child(card)
	return card

func _add_pedigree_summary(box: VBoxContainer, part: Part) -> void:
	var ped: Dictionary = part.pedigree
	var sep := HSeparator.new()
	box.add_child(sep)
	box.add_child(_label("Origen Genético:", TEXT_SIZE, AMBER, true))
	if ped.has("from_a") and not ped.from_a.is_empty():
		box.add_child(_label("P1 (%s): %s" % [ped.parent_a_name, ", ".join(ped.from_a)], TEXT_SIZE, TEXT_COLOR, true))
	if ped.has("from_b") and not ped.from_b.is_empty():
		box.add_child(_label("P2 (%s): %s" % [ped.parent_b_name, ", ".join(ped.from_b)], TEXT_SIZE, TEXT_COLOR, true))
	if ped.has("mutations") and not ped.mutations.is_empty():
		box.add_child(_label("★ " + ", ".join(ped.mutations), TEXT_SIZE, GOOD_COLOR, true))

func _toggle_fusion_select(i: int) -> void:
	if _busy or i < 0 or i >= _fusion_candidates.size():
		return
	var card: Control = _cards[i]
	if i in _selected_fusion_indices:
		_selected_fusion_indices.erase(i)
		card.modulate = Color.WHITE
		card.scale = Vector2.ONE
		Sfx.play("ui_click")
		return

	if _selected_fusion_indices.size() == 1:
		var first_idx: int = _selected_fusion_indices[0]
		var first_part: Part = _fusion_candidates[first_idx]
		var second_part: Part = _fusion_candidates[i]
		if first_part.slot != second_part.slot:
			_float_warning("¡Deben ser de la misma ranura (%s vs %s)!" % [SLOT_NAMES[first_part.slot], SLOT_NAMES[second_part.slot]])
			Sfx.play("ui_click")
			return
		_selected_fusion_indices.append(i)
		card.modulate = CYAN
		card.scale = HOVER_SCALE
		Sfx.play("ui_click")
		_execute_fusion(first_idx, i)
	else:
		_selected_fusion_indices.append(i)
		card.modulate = CYAN
		card.scale = HOVER_SCALE
		Sfx.play("ui_click")

func _execute_fusion(idx_a: int, idx_b: int) -> void:
	_busy = true
	var p_a: Part = _fusion_candidates[idx_a]
	var p_b: Part = _fusion_candidates[idx_b]
	var card_a: Control = _cards[idx_a]
	var card_b: Control = _cards[idx_b]

	# Animación de fusión en el taller:
	# 1. Crear sprites voladores de ambos padres desde sus iconos hacia el centro del escenario (robot)
	var icon_a: TextureRect = card_a.find_child("Icon", true, false)
	var icon_b: TextureRect = card_b.find_child("Icon", true, false)

	var fly_a := Sprite2D.new()
	fly_a.texture = icon_a.texture
	fly_a.scale = Vector2.ONE * ICON_SCALE
	PartGenerator.dress(fly_a, p_a)
	fly_a.global_position = icon_a.global_position + icon_a.size / 2.0

	var fly_b := Sprite2D.new()
	fly_b.texture = icon_b.texture
	fly_b.scale = Vector2.ONE * ICON_SCALE
	PartGenerator.dress(fly_b, p_b)
	fly_b.global_position = icon_b.global_position + icon_b.size / 2.0

	for c in _cards:
		create_tween().tween_property(c, "modulate:a", FADE_ALPHA, FADE_TIME)

	add_child(fly_a)
	add_child(fly_b)

	Sfx.play("charge")

	# Volar hacia el centro chocando entre sí con rotación
	var mid_pos: Vector2 = robot.global_position
	var t := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(fly_a, "global_position", mid_pos, 0.45)
	t.tween_property(fly_b, "global_position", mid_pos, 0.45)
	t.tween_property(fly_a, "rotation", TAU, 0.45)
	t.tween_property(fly_b, "rotation", -TAU, 0.45)
	await t.finished

	fly_a.queue_free()
	fly_b.queue_free()

	# Creación de la pieza hija mediante cruce y mutación
	var child_part := PartGenerator.fuse(p_a, p_b)

	# Explosión visual y sonora de fusión
	Sfx.play("laser")
	Sfx.play("equip")
	sparks.amount = 40
	sparks.restart()

	_show_part(child_part)
	robot.modulate = FLASH_COLOR
	create_tween().tween_property(robot, "modulate", Color.WHITE, FLASH_TIME)
	robot.scale = PREVIEW_SCALE * SQUASH * 1.2
	create_tween().tween_property(robot, "scale", PREVIEW_SCALE, SQUASH_TIME).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# Mostrar tarjeta de la pieza resultante con feedback de herencia
	_clear_cards()
	title.text = "¡FUSIÓN COMPLETADA!"
	var res_card := _make_card(0, child_part)
	res_card.modulate = Color.WHITE

	await get_tree().create_timer(EQUIP_HOLD).timeout
	player.equip(child_part)
	await get_tree().create_timer(1.0).timeout
	_close()

func _float_warning(msg: String) -> void:
	var l := Label.new()
	l.text = msg
	_style(l, NAME_SIZE, BAD_COLOR, TITLE_OUTLINE)
	l.position = stage.size / 2.0 - Vector2(100, 20)
	stage.add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position:y", l.position.y - 20, 1.2)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 1.2)
	await tw.finished
	l.queue_free()

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
	Sfx.play("ui_click")
	_refresh()
	var part := _offers[i]
	_show_part(part)
	var icon: TextureRect = _cards[i].find_child("Icon", true, false)
	var fly := Sprite2D.new()
	fly.texture = icon.texture
	fly.scale = Vector2.ONE * ICON_SCALE
	PartGenerator.dress(fly, part)
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
	Sfx.play("equip")
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
	Sfx.play("ui_click")
	player.add_scrap(-_reroll_cost())
	_rerolls += 1
	if _fusion_mode:
		_build_fusion_candidates()
	else:
		_deal()

func _skip() -> void:
	if _busy:
		return
	Sfx.play("ui_click")
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
	mode_toggle.disabled = _busy

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
