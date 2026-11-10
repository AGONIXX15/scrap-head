extends Area2D

const MAGNET_RADIUS := 60.0
const MAGNET_SPEED := 70.0
const MAGNET_ACCEL := 700.0
const LIFETIME := 10.0
const BLINK_TIME := 2.0
const BLINK_HZ := 14.0
const BLINK_ALPHA := 0.3
const SHINE_FPS := 6.0
const JUMP_DIST_MIN := 8.0
const JUMP_DIST_MAX := 28.0
const JUMP_HEIGHT := 14.0
const JUMP_TIME := 0.35

var _age := 0.0
var _speed := MAGNET_SPEED
var _landed := false
var _pull := false

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	sprite.frame = randi() % sprite.hframes
	body_entered.connect(_on_body_entered)
	add_to_group("scrap")
	var land := position + Vector2.from_angle(randf() * TAU) * randf_range(JUMP_DIST_MIN, JUMP_DIST_MAX)
	var t := create_tween().set_parallel()
	t.tween_property(self, "position", land, JUMP_TIME)
	t.tween_property(sprite, "position:y", -JUMP_HEIGHT, JUMP_TIME * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	t.chain().tween_property(sprite, "position:y", 0.0, JUMP_TIME * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.chain().tween_callback(func(): _landed = true)

func attract() -> void:
	_pull = true

func _physics_process(delta: float) -> void:
	_age += delta
	sprite.frame = int(_age * SHINE_FPS) % sprite.hframes
	var left := LIFETIME - _age
	if left <= 0.0:
		queue_free()
	sprite.modulate.a = BLINK_ALPHA if left < BLINK_TIME and int(left * BLINK_HZ) % 2 == 0 else 1.0
	var player := get_tree().get_first_node_in_group("player")
	if not _landed or player == null:
		return
	if _pull or global_position.distance_to(player.global_position) < MAGNET_RADIUS:
		_speed += MAGNET_ACCEL * delta
		global_position = global_position.move_toward(player.global_position, _speed * delta)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.hp > 0:
		body.add_scrap(1)
		queue_free()
