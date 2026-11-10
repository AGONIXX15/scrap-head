extends CharacterBody2D

@export var speed := 150.0

@onready var sprite: Sprite2D = $Sprite

var _t := 0.0

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()
	if dir.x != 0.0:
		sprite.flip_h = dir.x < 0.0
	if dir != Vector2.ZERO:
		_t += delta * 14.0
		sprite.position.y = -absf(sin(_t)) * 2.0
	else:
		sprite.position.y = move_toward(sprite.position.y, 0.0, delta * 20.0)
