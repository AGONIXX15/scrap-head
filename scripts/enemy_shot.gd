extends Area2D

const IMPACT := preload("res://scenes/impact.tscn")
const FRAME_DIST := 16.0

@export var speed := 220.0
@export var max_range := 520.0

var direction := Vector2.RIGHT
var damage := 1

var _dist := 0.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	var step := speed * delta
	position += direction * step
	_dist += step
	sprite.frame = int(_dist / FRAME_DIST) % sprite.hframes
	if _dist >= max_range:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if is_queued_for_deletion():
		return
	if body.is_in_group("player"):
		body.take_damage(damage)
	var fx := IMPACT.instantiate()
	fx.global_position = global_position
	fx.rotation = direction.angle() + PI
	get_tree().current_scene.add_child.call_deferred(fx)
	queue_free()
