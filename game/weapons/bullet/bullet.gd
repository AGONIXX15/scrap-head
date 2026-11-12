extends Area2D

const IMPACT := preload("res://game/fx/impact.tscn")
const FRAME_DIST := 32.0

@export var speed := 400.0

var direction := Vector2.RIGHT
var damage := 1
var pierce := 0
var max_range := 450.0

var _dist := 0.0
var _hit: Array[Node] = []

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

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
	if body.has_method("hit") and body not in _hit:
		_hit.append(body)
		body.hit(damage, direction)
		_impact(true)
		return
	_impact(false)

func _on_area_entered(area: Area2D) -> void:
	if is_queued_for_deletion():
		return
	var target := area.get_parent()
	if target in _hit:
		return
	_hit.append(target)
	if target.has_method("hit"):
		target.hit(damage, direction)
	_impact(true)

func _impact(hurt: bool) -> void:
	if is_queued_for_deletion():
		return
	var fx := IMPACT.instantiate()
	fx.global_position = global_position
	fx.rotation = direction.angle() + PI
	get_tree().current_scene.add_child.call_deferred(fx)
	if hurt and pierce > 0:
		pierce -= 1
	else:
		queue_free()
