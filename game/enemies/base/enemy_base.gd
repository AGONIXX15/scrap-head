class_name EnemyBase extends CharacterBody2D

const EXPLOSION := preload("res://game/fx/explosion.tscn")
const SCRAP := preload("res://game/parts/scrap/scrap.tscn")
const KNOCKBACK := 140.0
const KNOCK_DECAY := 600.0
const FLASH_COLOR := Color(4, 4, 4)
const FLASH_TIME := 0.1
const ELITE_HP_MULT := 3
const ELITE_SCRAP_MULT := 3
const SCRAP_SPREAD := 10.0
const ELITE_SCALE := 1.25
const ELITE_COLOR := Color(1.6, 1.3, 0.5)
const BAR_SIZE := Vector2(20, 2)
const BAR_BACK := Color("181220")
const BAR_FILL := Color("ff2828")
const WARN_COLOR := Color("ff2828")
const WARN_BASE_ALPHA := 0.15
const WARN_FILL_ALPHA := 0.45
const WARN_LINE := 1.0
const WARN_POINTS := 48
const BURN_TIME := 2.0
const BURN_TICK := 0.5
const BURN_COLOR := Color(1.6, 0.8, 0.4)
const COLD_TIME := 2.0
const COLD_MULT := 0.5
const COLD_COLOR := Color(0.5, 0.8, 1.6)
const MARK_TIME := 3.0
const MARK_COLOR := Color(1.6, 0.6, 1.6)

@export var speed := 60.0
@export var hp := 3
@export var damage := 1
@export var elite := false
@export var scrap_value := 1
@export var knock_scale := 1.0
@export var bar_y := -22.0
@export var fx_scale := 1.0
@export var death_shake := 1.5

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: Area2D = get_node_or_null("Hitbox")

var _player: Node2D
var _knock := Vector2.ZERO
var _max_hp := 0
var _tint := Color.WHITE
var _bar := Node2D.new()
var _warn := Node2D.new()
var _warn_radius := 0.0
var _warn_fill := 0.0
var _dead := false
var speed_mult := 1.0
var _oil_count := 0
var _oil_factor := 1.0
var _base_tint := Color.WHITE
var _burn := 0.0
var _burn_tick := 0.0
var _flash_tween: Tween
var _cold := 0.0
var _mark := 0.0
var mark_bonus := 0  # daño extra por golpe mientras está marcado (Marcador)

func _ready() -> void:
	set_process(false)  # solo hace falta con quemadura o frío
	_player = get_tree().get_first_node_in_group("player")
	if elite:
		hp *= ELITE_HP_MULT
		scrap_value *= ELITE_SCRAP_MULT
		scale = Vector2.ONE * ELITE_SCALE
		_base_tint = ELITE_COLOR
		_tint = _base_tint
		sprite.modulate = _tint
	_max_hp = hp
	for n: Node2D in [_bar, _warn]:
		n.scale = Vector2.ONE / scale
		add_child(n)
	_bar.z_index = 1
	_bar.visible = false
	_bar.draw.connect(_draw_bar)
	_warn.show_behind_parent = true
	_warn.draw.connect(_draw_warn)

func hit(amount: int, from_dir := Vector2.ZERO) -> void:
	if hp <= 0:
		return  # dos balas en el mismo frame
	hp -= amount
	Juice.damage_number(global_position + Vector2(0.0, bar_y), amount)
	_bar.visible = true
	_bar.queue_redraw()
	if hp <= 0:
		_die()
		return
	if from_dir != Vector2.ZERO:  # el daño por estado (quemadura, ácido) no cancela el empuje ni suena
		Sfx.play("enemy_hit", global_position)
		_knock = from_dir * KNOCKBACK * knock_scale
	if _flash_tween:
		_flash_tween.kill()
	sprite.modulate = FLASH_COLOR
	# lee _tint en cada paso: si un estado cambia el tinte durante el flash, no lo pisa
	_flash_tween = create_tween()
	_flash_tween.tween_method(func(t: float): sprite.modulate = FLASH_COLOR.lerp(_tint, t), 0.0, 1.0, FLASH_TIME)

func sweep() -> void:
	hp = 0
	_die(false)

func _die(juice := true) -> void:
	if _dead:
		return
	_dead = true
	set_physics_process(false)
	_on_death()
	var scene := get_tree().current_scene
	var fx := EXPLOSION.instantiate()
	fx.global_position = global_position
	fx.scale = Vector2.ONE * fx_scale
	scene.add_child.call_deferred(fx)
	for i in scrap_value:
		var b := SCRAP.instantiate()
		b.global_position = global_position + Vector2.from_angle(randf() * TAU) * randf_range(0.0, SCRAP_SPREAD)
		scene.add_child.call_deferred(b)
	if juice:
		if is_instance_valid(_player):
			_player.enemy_killed()
		Juice.hitstop()
		Juice.shake(death_shake)
		Sfx.chain("kill", global_position)
	queue_free()

func set_oil_slow(factor: float) -> void:
	_oil_count += 1
	_oil_factor = factor
	_refresh_status()

func remove_oil_slow() -> void:
	_oil_count = maxi(_oil_count - 1, 0)
	_refresh_status()

# Ígneo: 1 de daño cada BURN_TICK durante duration; reaplicar refresca.
func burn(duration := BURN_TIME) -> void:
	_burn = duration
	set_process(true)
	_refresh_status()

# Criogénico: ralentiza a la mitad durante duration; se combina con el aceite.
func freeze(duration := COLD_TIME) -> void:
	_cold = duration
	set_process(true)
	_refresh_status()

# Marcador: +n de daño por golpe durante duration.
func mark(n: int, duration := MARK_TIME) -> void:
	mark_bonus = n
	_mark = duration
	set_process(true)
	_refresh_status()

func _process(delta: float) -> void:
	if _mark > 0.0:
		_mark -= delta
		if _mark <= 0.0:
			mark_bonus = 0
			_refresh_status()
	if _burn > 0.0:
		_burn -= delta
		_burn_tick += delta
		if _burn_tick >= BURN_TICK:
			_burn_tick -= BURN_TICK
			hit(1)
		if _burn <= 0.0:
			_refresh_status()
	if _cold > 0.0:
		_cold -= delta
		if _cold <= 0.0:
			_refresh_status()
	if _burn <= 0.0 and _cold <= 0.0 and _mark <= 0.0:
		set_process(false)

func _oil_mult() -> float:
	return _oil_factor if _oil_count > 0 else 1.0

func _refresh_status() -> void:
	speed_mult = _oil_mult() * (COLD_MULT if _cold > 0.0 else 1.0)
	_tint = _base_tint
	if _burn > 0.0:
		_tint *= BURN_COLOR
	if _cold > 0.0:
		_tint *= COLD_COLOR
	if _mark > 0.0:
		_tint *= MARK_COLOR
	sprite.modulate = _tint

func _on_death() -> void:
	pass

func _touch() -> void:
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(damage)

func _telegraph(radius: float, fill := 0.0) -> void:
	_warn_radius = radius
	_warn_fill = fill
	_warn.queue_redraw()

func _draw_bar() -> void:
	var origin := Vector2(-BAR_SIZE.x * 0.5, bar_y)
	_bar.draw_rect(Rect2(origin - Vector2.ONE, BAR_SIZE + Vector2.ONE * 2.0), BAR_BACK)
	_bar.draw_rect(Rect2(origin, Vector2(BAR_SIZE.x * maxf(hp, 0) / _max_hp, BAR_SIZE.y)), BAR_FILL)

func _draw_warn() -> void:
	if _warn_radius <= 0.0:
		return
	_warn.draw_circle(Vector2.ZERO, _warn_radius, Color(WARN_COLOR, WARN_BASE_ALPHA))
	_warn.draw_circle(Vector2.ZERO, _warn_radius * _warn_fill, Color(WARN_COLOR, WARN_FILL_ALPHA))
	_warn.draw_arc(Vector2.ZERO, _warn_radius, 0.0, TAU, WARN_POINTS, WARN_COLOR, WARN_LINE)
