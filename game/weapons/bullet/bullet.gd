extends Area2D

const IMPACT := preload("res://game/fx/impact.tscn")
const DISC_TEXTURE := preload("res://game/weapons/bullet/saw_disc.png")
const FRAME_DIST := 32.0
const SPIN_SPEED := 28.0
const HOMING_RANGE := 160.0
const HOMING_CONE := deg_to_rad(50.0)
const HOMING_TURN := 4.0
const BOOMERANG_REACH := 12.0
const BOOMERANG_LIMIT := 1.5  # alcance total máximo (ida + vuelta) en múltiplos de max_range
const FRAGMENTS := [-30.0, 0.0, 30.0]
const FRAGMENT_SCALE := 0.6
const FRAGMENT_RANGE := 120.0
const KNOCK_PER_HYDRAULIC := 2.0

@export var speed := 400.0

var direction := Vector2.RIGHT
var damage := 1
var pierce := 0
var bounces := 0
var max_range := 450.0
var is_disc := false
# id de efecto -> cantidad (solo las balas del jugador; las hijas van vacías para no encadenar efectos)
var effects := {}

var _returning := false
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
	if effects.has("buscador"):
		_home(delta)
	if effects.has("boomerang"):
		if not _returning and _dist >= max_range * 0.5:
			_returning = true
			_hit.clear()
		if _returning:
			var player := get_tree().get_first_node_in_group("player")
			if player == null or global_position.distance_to(player.global_position) <= BOOMERANG_REACH:
				queue_free()
				return
			direction = global_position.direction_to(player.global_position)
			if not is_disc:
				rotation = direction.angle()
	position += direction * step
	_dist += step
	if is_disc:
		rotation += SPIN_SPEED * delta
	else:
		sprite.frame = int(_dist / FRAME_DIST) % sprite.hframes
	if _dist >= max_range * (BOOMERANG_LIMIT if effects.has("boomerang") else 1.0):
		queue_free()

# Gira suavemente hacia el enemigo más cercano dentro del cono frontal.
func _home(delta: float) -> void:
	var best := HOMING_RANGE
	var turn := 0.0
	for e: Node2D in get_tree().get_nodes_in_group("enemies"):
		var to := e.global_position - global_position
		if to.length() <= best and e not in _hit and absf(direction.angle_to(to)) <= HOMING_CONE:
			best = to.length()
			turn = direction.angle_to(to)
	if turn != 0.0:
		direction = direction.rotated(clampf(turn, -HOMING_TURN * delta, HOMING_TURN * delta))
		if not is_disc:
			rotation = direction.angle()

func _on_body_entered(body: Node) -> void:
	if is_queued_for_deletion():
		return
	if body.has_method("hit") and body not in _hit:
		_hit.append(body)
		body.hit(damage, direction * _knock())
		_on_hurt(body)
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
		target.hit(damage, direction * _knock())
		_on_hurt(target)
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

func _knock() -> float:
	return 1.0 + KNOCK_PER_HYDRAULIC * effects.get("hidraulico", 0)

# Efectos al dañar a un objetivo (los de estado solo afectan a enemigos).
func _on_hurt(target: Node) -> void:
	if effects.is_empty():
		return
	if target.has_method("burn") and effects.has("igneo"):
		target.burn()
	if target.has_method("freeze") and effects.has("criogenico"):
		target.freeze()
	if target is Node2D:
		if effects.has("electrico"):
			ArmFx.lightning(self, target as Node2D, effects.electrico, damage)
		if effects.has("explosivo"):
			ArmFx.blast(self, global_position, maxi(damage >> 1, 1), target)
		if effects.has("acido"):
			ArmFx.acid(self, global_position)
	if effects.has("fragmentador"):
		_fragment(target)

func _fragment(target: Node) -> void:
	for a: float in FRAGMENTS:
		var b: Node = load(scene_file_path).instantiate()
		b.direction = direction.rotated(deg_to_rad(a))
		b.damage = maxi(damage >> 1, 1)
		b.max_range = FRAGMENT_RANGE
		b.scale = Vector2.ONE * FRAGMENT_SCALE
		b.global_position = global_position
		b._hit.append(target)  # que no vuelva a golpear al que lo originó
		get_tree().current_scene.add_child.call_deferred(b)
