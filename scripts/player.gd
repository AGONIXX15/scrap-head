extends CharacterBody2D

signal hp_changed(hp: int, max_hp: int)
signal died

const BULLET := preload("res://scenes/bullet.tscn")
const RANGE := 220.0
const INVULN_TIME := 0.6

@export var speed := 150.0
@export var max_hp := 5
@export var fire_rate := 0.3
## Pieza futura del taller: dispara sola al enemigo más cercano.
@export var auto_aim := false

@onready var sprite: Sprite2D = $Sprite

var hp: int
var _t := 0.0
var _invuln := 0.0
var _cooldown := 0.0

func _ready() -> void:
	hp = max_hp
	hp_changed.emit(hp, max_hp)

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	if auto_aim:
		if dir.x != 0.0:
			sprite.flip_h = dir.x < 0.0
	else:
		sprite.flip_h = get_global_mouse_position().x < global_position.x
	_cooldown -= delta
	if _cooldown <= 0.0 and (auto_aim or Input.is_action_pressed("shoot")):
		var aim := _auto_target() if auto_aim else get_global_mouse_position()
		if aim != Vector2.INF:
			_shoot(global_position.direction_to(aim))
			_cooldown = fire_rate
	if dir != Vector2.ZERO:
		_t += delta * 14.0
		sprite.position.y = -absf(sin(_t)) * 2.0
	else:
		sprite.position.y = move_toward(sprite.position.y, 0.0, delta * 20.0)
	if _invuln > 0.0:
		_invuln -= delta
		sprite.modulate.a = 0.35 if int(_invuln * 20.0) % 2 == 0 else 1.0
		if _invuln <= 0.0:
			sprite.modulate.a = 1.0

func take_damage(n: int) -> void:
	if hp == 0 or _invuln > 0.0:
		return
	hp = maxi(hp - n, 0)
	hp_changed.emit(hp, max_hp)
	if hp == 0:
		died.emit()
		get_tree().reload_current_scene()  # provisional: HU-04 mostrará la derrota
		return
	_invuln = INVULN_TIME

func _auto_target() -> Vector2:
	var best := RANGE
	var target := Vector2.INF
	for e in get_tree().get_nodes_in_group("enemies"):
		var d := global_position.distance_to(e.global_position)
		if d <= best:
			best = d
			target = e.global_position
	return target

func _shoot(direction: Vector2) -> void:
	var b := BULLET.instantiate()
	b.direction = direction
	b.global_position = global_position
	get_tree().current_scene.add_child(b)
