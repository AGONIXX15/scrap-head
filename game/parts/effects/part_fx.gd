class_name PartFx extends Node2D
# Efectos de pieza con lógica propia (piernas, espalda y radar). Hijo del jugador; solo procesa si hay alguno equipado.

const PATCH := preload("res://game/parts/effects/ground_patch.tscn")
const MINE := preload("res://game/parts/effects/mine.tscn")
const SAW := preload("res://game/parts/effects/saw.tscn")
const IDS := ["rastro_fuego", "rastro_aceite", "minas", "pisoton", "sierra_orbital", "escudo", "regenerador", "radar"]
const TRAIL_STEP := 40.0
const MAX_PATCHES := 14
const FIRE_LIFE := 2.5
const OIL_LIFE := 4.0
const MINE_EVERY := 3.0
const MAX_MINES := 6
const MINE_GAP := 20.0
const STOMP_EVERY := 4.0
const STOMP_RADIUS := 70.0
const STOMP_RADIUS_PER := 10.0
const STOMP_SHAKE := 1.5
const MAX_SAWS := 6
const SHIELD_EVERY := 8.0
const SHIELD_RADIUS := 15.0
const SHIELD_COLOR := Color("6fd8ff")
const REGEN_EVERY := 10.0
const THORNS_RADIUS := 50.0
const RADAR_RANGE := 1500.0
const RADAR_MARGIN := 8.0
const RADAR_COLOR := Color("ff4a4a")

var player: Node2D

var _n := {}
var _last_pos := Vector2.ZERO
var _trail := 0.0
var _patches: Array = []
var _mines: Array = []
var _stomp := 0.0
var _mine_t := 0.0
var _regen_t := 0.0
var _shield_up := false
var _shield_t := 0.0

func _ready() -> void:
	player = get_parent()
	z_index = 5
	set_process(false)

# Llamar al cambiar las piezas: recuenta efectos y crea o quita las sierras.
func refresh() -> void:
	var had_regen: int = _n.get("regenerador", 0)
	for id: String in IDS:
		_n[id] = player.effect_count(id)
	if had_regen == 0 and _n.regenerador > 0:
		_regen_t = REGEN_EVERY / _n.regenerador
	if _n.minas == 0:
		for m in _mines:
			if is_instance_valid(m):
				m.queue_free()
		_mines.clear()
	set_process(IDS.any(func(id: String): return _n[id] > 0))
	_last_pos = player.global_position
	if _n.escudo == 0:
		_shield_up = false
		_shield_t = 0.0
	for s in get_children():
		s.queue_free()
	var saws := mini(_n.sierra_orbital, MAX_SAWS)
	for i in saws:
		var s := SAW.instantiate()
		s.angle = TAU * i / saws
		add_child(s)
	queue_redraw()

# Escudo de Blindado: true si absorbe el golpe.
func absorb() -> bool:
	if not _shield_up:
		return false
	_shield_up = false
	_shield_t = SHIELD_EVERY / _n.escudo
	queue_redraw()
	return true

func thorns() -> void:
	var n: int = player.effect_count("espinas")
	if n > 0:
		for e: Node2D in Spatial.near(player.global_position, THORNS_RADIUS):
			e.hit(n, player.global_position.direction_to(e.global_position))

func _process(delta: float) -> void:
	var pos := player.global_position
	if _n.rastro_fuego + _n.rastro_aceite > 0:
		_trail += pos.distance_to(_last_pos)
		_last_pos = pos
		if _trail >= TRAIL_STEP:
			_trail = 0.0
			if _n.rastro_fuego > 0:
				_patch("fuego", FIRE_LIFE * _n.rastro_fuego)
			if _n.rastro_aceite > 0:
				_patch("aceite", OIL_LIFE * _n.rastro_aceite)
	if _n.minas > 0:
		_mine_t -= delta
		if _mine_t <= 0.0:
			_mine_t = MINE_EVERY / _n.minas
			_mines = _mines.filter(func(m): return is_instance_valid(m))
			# parado no apila minas en el mismo punto
			if _mines.size() < MAX_MINES and not _mines.any(func(m): return m.global_position.distance_to(pos) < MINE_GAP):
				var m := MINE.instantiate()
				m.global_position = pos
				_mines.append(m)
				get_tree().current_scene.add_child(m)
	if _n.pisoton > 0:
		_stomp -= delta
		if _stomp <= 0.0:
			_do_stomp(pos)
	if _n.escudo > 0 and not _shield_up:
		_shield_t -= delta
		if _shield_t <= 0.0:
			_shield_up = true
			queue_redraw()
	if _n.regenerador > 0:
		_regen_t -= delta
		if _regen_t <= 0.0:
			_regen_t = REGEN_EVERY / _n.regenerador
			player.heal(1)
	if _n.radar > 0:
		queue_redraw()

func _patch(kind: String, life: float) -> void:
	_patches = _patches.filter(func(p): return is_instance_valid(p))
	while _patches.size() >= MAX_PATCHES:
		_patches.pop_front().queue_free()
	var p := PATCH.instantiate()
	p.kind = kind
	p.life = life
	p.global_position = player.global_position
	_patches.append(p)
	get_tree().current_scene.add_child(p)

func _do_stomp(pos: Vector2) -> void:
	var radius: float = STOMP_RADIUS + STOMP_RADIUS_PER * (_n.pisoton - 1)
	var near := Spatial.near(pos, radius)
	if near.is_empty():
		return  # espera a tener enemigos cerca
	_stomp = STOMP_EVERY
	for e: Node2D in near:
		e.hit(1 + _n.pisoton, pos.direction_to(e.global_position))
	Juice.shake(STOMP_SHAKE)
	var ring := Node2D.new()
	ring.global_position = pos
	ring.draw.connect(func(): ring.draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(1, 1, 1, 0.7), 2.0))
	get_tree().current_scene.add_child(ring)
	ring.scale = Vector2.ONE * 0.2
	var t := ring.create_tween().set_parallel()
	t.tween_property(ring, "scale", Vector2.ONE, 0.25)
	t.tween_property(ring, "modulate:a", 0.0, 0.25)
	t.chain().tween_callback(ring.queue_free)

func _draw() -> void:
	if _shield_up:
		draw_circle(Vector2.ZERO, SHIELD_RADIUS, Color(SHIELD_COLOR, 0.15))
		draw_arc(Vector2.ZERO, SHIELD_RADIUS, 0.0, TAU, 24, SHIELD_COLOR, 1.0)
	if _n.get("radar", 0) > 0:
		var cam := get_viewport().get_camera_2d()
		if cam == null:
			return
		var view := Rect2(cam.get_screen_center_position() - get_viewport_rect().size * 0.5, get_viewport_rect().size)
		var edge := view.grow(-RADAR_MARGIN)
		for e: Node2D in Spatial.near(player.global_position, RADAR_RANGE):
			if not view.has_point(e.global_position):
				var p := e.global_position.clamp(edge.position, edge.end)
				draw_circle(to_local(p), 1.0 + _n.radar, RADAR_COLOR)
