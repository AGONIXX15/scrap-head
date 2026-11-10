extends CharacterBody2D

const EXPLOSION := preload("res://scenes/explosion.tscn")
const PICKUP := preload("res://scenes/pickup.tscn")
const PARTS: Array[Part] = [preload("res://parts/visor_torreta.tres"), preload("res://parts/taladro.tres"),
		preload("res://parts/orugas_tanque.tres"), preload("res://parts/mini_dron.tres")]
const DROP_CHANCE := 0.25
const KNOCKBACK := 140.0
const KNOCK_DECAY := 600.0
const WALK_FPS := 8.0
const FLASH_COLOR := Color(4, 4, 4)
const FLASH_TIME := 0.1

@export var speed := 60.0
@export var hp := 3
@export var damage := 1

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox

var _player: Node2D
var _knock := Vector2.ZERO
var _t := 0.0

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		return
	var dir := global_position.direction_to(_player.global_position)
	_knock = _knock.move_toward(Vector2.ZERO, KNOCK_DECAY * delta)
	velocity = dir * speed + _knock
	move_and_slide()
	_t += delta * WALK_FPS
	sprite.frame = int(_t) % sprite.hframes
	if dir.x != 0.0:
		sprite.flip_h = dir.x < 0.0
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(damage)

func hit(amount: int, from_dir := Vector2.ZERO) -> void:
	if hp <= 0:
		return  # dos balas en el mismo frame
	hp -= amount
	if hp <= 0:
		# SFX: explode
		_die()
		return
	# SFX: hit
	_knock = from_dir * KNOCKBACK
	sprite.modulate = FLASH_COLOR
	create_tween().tween_property(sprite, "modulate", Color.WHITE, FLASH_TIME)

func _die() -> void:
	var scene := get_tree().current_scene
	var fx := EXPLOSION.instantiate()
	fx.global_position = global_position
	scene.add_child.call_deferred(fx)
	if randf() < DROP_CHANCE:
		var p := PICKUP.instantiate()
		p.part = PARTS.pick_random()
		p.global_position = global_position
		scene.add_child.call_deferred(p)
	queue_free()
