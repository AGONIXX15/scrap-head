extends Node

signal wave_started(n: int)
signal wave_cleared(n: int)
signal all_waves_cleared
signal tick(dt: float)

const WORKSHOP := preload("res://game/workshop/workshop.tscn")
const WARNING := preload("res://game/level/spawn_warning.tscn")
const ARENA := Vector2(1280, 720)
const MARGIN := 48.0
const MAX_ENEMIES := 40
const MIN_DIST := 200.0
const SPAWN_TRIES := 8
const INTERIOR_MIN_DIST := 280.0
const OXIDADO := "res://game/enemies/oxidado/oxidado.tscn"
const SPARK := "res://game/enemies/chispa/chispa.tscn"
const RIVETER := "res://game/enemies/remachadora/remachadora.tscn"
const INTERIOR := [RIVETER]
const PRESS := "res://game/enemies/prensa/prensa.tscn"
# time: duración (s), interval: segundos entre tandas, burst: enemigos por tanda, cap: tope de vivos
const WAVES := [
	{"time": 40.0, "interval": 1.4, "burst": 1, "cap": 12, "mix": {OXIDADO: 1.0}},
	{"time": 40.0, "interval": 1.2, "burst": 1, "cap": 16, "mix": {OXIDADO: 3.0, SPARK: 2.0}},
	{"time": 40.0, "interval": 1.1, "burst": 1, "cap": 20, "mix": {OXIDADO: 3.0, SPARK: 2.0, RIVETER: 1.0}},
	{"time": 40.0, "interval": 1.0, "burst": 2, "cap": 26, "mix": {OXIDADO: 4.0, SPARK: 3.0, RIVETER: 1.0, PRESS: 1.0}},
	{"time": 40.0, "interval": 1.6, "burst": 4, "cap": MAX_ENEMIES, "mix": {OXIDADO: 4.0, SPARK: 3.0, RIVETER: 2.0, PRESS: 2.0}},
]
const ELITE_FROM_WAVE := 3
const ELITE_CHANCE := 0.12
const CHAIN_DELAY := 0.08
const SCRAP_PULL_TIME := 2.5

const BANNER_SIZE := 48
const BANNER_OUTLINE := 10
const BANNER_IN := 0.3
const BANNER_HOLD := 1.8
const BANNER_OUT := 0.4
const BANNER_START_SCALE := 2.5
const CLOCK_SIZE := 16
const CLOCK_OUTLINE := 4
const CLOCK_TOP := 6.0
const AMBER := Color("ffb02e")
const ORANGE := Color("ff7a1a")
const OUTLINE_COLOR := Color("1a1030")

@export var duration_mult := 1.0

var _mix: Dictionary = {}
var _cap := MAX_ENEMIES
var _left := 0.0
var _tween: Tween

@onready var enemies: Node = $"../Enemies"
@onready var player: Node2D = $"../Player"
@onready var banner: Label = $UI/Banner
@onready var clock: Label = $UI/Clock

func _ready() -> void:
	_style(banner, BANNER_SIZE, BANNER_OUTLINE)
	_style(clock, CLOCK_SIZE, CLOCK_OUTLINE)
	banner.pivot_offset = banner.get_viewport_rect().size / 2.0
	banner.modulate.a = 0.0
	clock.hide()
	_run()

func _process(delta: float) -> void:
	tick.emit(delta)

func _wait(t: float) -> void:
	var tw := create_tween()
	tw.tween_interval(t)
	await tw.finished

func _style(l: Label, size: int, outline: int) -> void:
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", AMBER)
	l.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	l.add_theme_constant_override("outline_size", outline)

func _run() -> void:
	for i in WAVES.size():
		await _play(i)
	all_waves_cleared.emit()
	_show("¡SOBREVIVISTE!", AMBER)

func _play(i: int) -> void:
	var w: Dictionary = WAVES[i]
	_mix.clear()
	for path in w.mix:
		_mix[load(path)] = w.mix[path]
	_cap = w.cap
	_left = w.time * duration_mult
	wave_started.emit(i + 1)
	_show("OLEADA %d" % (i + 1), ORANGE)
	clock.show()
	var acc := 0.0
	while _left > 0.0:
		var dt: float = await tick
		_left -= dt
		acc += dt
		clock.text = str(ceili(maxf(_left, 0.0)))
		if acc >= w.interval:
			acc = 0.0
			for n in w.burst:
				_spawn(i + 1)
	clock.hide()
	for s in get_tree().get_nodes_in_group("spawn_warning"):
		s.queue_free()
	_show("¡OLEADA SUPERADA!", AMBER)
	for e in enemies.get_children():
		if is_instance_valid(e):
			e.sweep()
		await _wait(CHAIN_DELAY)
	wave_cleared.emit(i + 1)
	if i < WAVES.size() - 1:
		get_tree().call_group("scrap", "attract")
		await _wait(SCRAP_PULL_TIME)
		var workshop := WORKSHOP.instantiate()
		workshop.player = player
		workshop.wave = i + 1
		add_child(workshop)
		await workshop.closed

func _spawn(wave: int) -> void:
	if enemies.get_child_count() + get_tree().get_nodes_in_group("spawn_warning").size() >= _cap:
		return
	var scene: PackedScene = _pick()
	var interior := scene.resource_path in INTERIOR
	var pos := _interior_point() if interior else _perimeter_point()
	var tries := SPAWN_TRIES
	while not interior and pos.distance_to(player.global_position) < MIN_DIST and tries > 0:
		pos = _perimeter_point()
		tries -= 1
	if not interior and pos.distance_to(player.global_position) < MIN_DIST:
		return
	var e := scene.instantiate()
	if wave >= ELITE_FROM_WAVE and randf() < ELITE_CHANCE:
		e.elite = true
	var warn := WARNING.instantiate()
	warn.position = pos
	warn.enemy = e
	warn.parent = enemies
	add_child(warn)

func _pick() -> PackedScene:
	var total := 0.0
	for s in _mix:
		total += _mix[s]
	var r := randf() * total
	for s in _mix:
		r -= _mix[s]
		if r <= 0.0:
			return s
	return _mix.keys()[0]

func _interior_point() -> Vector2:
	var p := Vector2.ZERO
	while p.distance_to(player.global_position) < INTERIOR_MIN_DIST:
		p = Vector2(randf_range(MARGIN, ARENA.x - MARGIN), randf_range(MARGIN, ARENA.y - MARGIN))
	return p

func _perimeter_point() -> Vector2:
	var t := randf()
	var w := ARENA.x - 2.0 * MARGIN
	var h := ARENA.y - 2.0 * MARGIN
	var d := t * 2.0 * (w + h)
	if d < w:
		return Vector2(MARGIN + d, MARGIN)
	d -= w
	if d < h:
		return Vector2(ARENA.x - MARGIN, MARGIN + d)
	d -= h
	if d < w:
		return Vector2(ARENA.x - MARGIN - d, ARENA.y - MARGIN)
	return Vector2(MARGIN, ARENA.y - MARGIN - (d - w))

func _show(text: String, color: Color) -> void:
	if _tween:
		_tween.kill()
	banner.text = text
	banner.add_theme_color_override("font_color", color)
	banner.scale = Vector2.ONE * BANNER_START_SCALE
	banner.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(banner, "scale", Vector2.ONE, BANNER_IN).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(banner, "modulate:a", 1.0, BANNER_IN)
	_tween.tween_interval(BANNER_HOLD)
	_tween.tween_property(banner, "modulate:a", 0.0, BANNER_OUT)
