extends Area2D

const IMPACT := preload("res://game/fx/impact.tscn")
const DISC_TEXTURE := preload("res://game/weapons/bullet/saw_disc.png")
const FRAME_DIST := 32.0
const SPIN_SPEED := 28.0

@export var speed := 400.0

var direction := Vector2.RIGHT
var damage := 1
var pierce := 0
var bounces := 0
var max_range := 450.0
var is_disc := false

var _dist := 0.0
var _hit: Array[Node] = []

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	if is_disc:
		sprite.texture = DISC_TEXTURE
		sprite.hframes = 1
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	var step := speed * delta
	position += direction * step
	_dist += step
	if is_disc:
		rotation += SPIN_SPEED * delta
	else:
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
	if bounces > 0:
		_bounce()
		return
	_impact(false)

func _bounce() -> void:
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position - direction * 16.0, global_position + direction * 24.0, 1)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var result := space_state.intersect_ray(query)
	var normal := Vector2.ZERO
	if not result.is_empty() and result.normal != Vector2.ZERO:
		normal = result.normal
	else:
		if global_position.x <= 48.0 and direction.x < 0.0:
			normal = Vector2.RIGHT
		elif global_position.x >= 1232.0 and direction.x > 0.0:
			normal = Vector2.LEFT
		elif global_position.y <= 64.0 and direction.y < 0.0:
			normal = Vector2.DOWN
		elif global_position.y >= 656.0 and direction.y > 0.0:
			normal = Vector2.UP
		else:
			if absf(direction.x) > absf(direction.y):
				normal = Vector2(-signf(direction.x), 0)
			else:
				normal = Vector2(0, -signf(direction.y))

	direction = direction.bounce(normal).normalized()
	if direction == Vector2.ZERO:
		direction = -normal
	position += direction * 4.0
	bounces -= 1
	_dist = maxf(_dist - 120.0, 0.0)
	_hit.clear()

	if not is_disc:
		rotation = direction.angle()

	var fx := IMPACT.instantiate()
	fx.global_position = global_position
	fx.rotation = normal.angle()
	var scene := get_tree().current_scene if get_tree().current_scene else get_tree().root
	scene.add_child.call_deferred(fx)

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
	var scene := get_tree().current_scene if get_tree().current_scene else get_tree().root
	scene.add_child.call_deferred(fx)
	if hurt and pierce > 0:
		pierce -= 1
	else:
		queue_free()
