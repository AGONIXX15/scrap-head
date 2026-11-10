extends CharacterBody2D

@export var speed := 60.0
@export var hp := 3
@export var damage := 1

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: Area2D = $Hitbox

var _player: Node2D

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_player):
		return
	var dir := global_position.direction_to(_player.global_position)
	velocity = dir * speed
	move_and_slide()
	if dir.x != 0.0:
		sprite.flip_h = dir.x < 0.0
	# se consulta cada frame para dañar también si el jugador sigue en contacto al acabar la invulnerabilidad
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(damage)

func hit(amount: int) -> void:
	hp -= amount
	if hp <= 0:
		queue_free()
		return
	sprite.modulate = Color(4, 4, 4)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.1)
