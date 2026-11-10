extends Node2D
const ORBIT := 26.0
const FIRE_EVERY := 1.0
const FIRE_RANGE := 260.0
const ORBIT_SPEED := 2.5
const ORBIT_FLATTEN := 0.5
const HOVER_Y := -10.0
const PROP_FPS := 6.0

@onready var sprite: Sprite2D = $Sprite
@onready var player: Node2D = get_parent()

var _a := 0.0
var _cooldown := 0.0

func _process(delta: float) -> void:
	_a += delta * ORBIT_SPEED
	position = Vector2(cos(_a) * ORBIT, sin(_a) * ORBIT * ORBIT_FLATTEN + HOVER_Y)
	sprite.frame = int(_a * PROP_FPS) % sprite.hframes
	_cooldown -= delta
	if _cooldown > 0.0:
		return
	var target: Vector2 = player.nearest_enemy(global_position, FIRE_RANGE)
	if target != Vector2.INF:
		player.spawn_bullet(global_position, global_position.direction_to(target))
		_cooldown = FIRE_EVERY
