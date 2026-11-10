extends Area2D

const IMPACT := preload("res://scenes/impact.tscn")
const FRAME_DIST := 32.0

@export var speed := 400.0

var direction := Vector2.RIGHT
var damage := 1
var pierce := 0
var max_range := 450.0

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
	var enemy := body.is_in_group("enemies")
	if enemy:
		body.hit(damage, direction)
	var fx := IMPACT.instantiate()
	fx.global_position = global_position
	fx.rotation = direction.angle() + PI
	get_tree().current_scene.add_child.call_deferred(fx)
	if enemy and pierce > 0:
		pierce -= 1
	else:
		queue_free()
