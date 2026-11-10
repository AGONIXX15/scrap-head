extends EnemyBase

const SHOT := preload("res://game/enemies/remachadora/remache.tscn")
const SIGHT_RANGE := 420.0
const AIM_TURN := 5.0
const COOLDOWN := 2.0
const CHARGE_TIME := 1.0
const LOCK_FRAC := 0.75
const BURST_COUNT := 4
const BURST_GAP := 0.12
const MUZZLE_DIST := 30.0
const LASER_W_MIN := 0.5
const LASER_W_MAX := 2.0
const LASER_ALPHA_MIN := 0.2
const IDLE_FRAME := 0
const CHARGE_FRAME := 1

enum State { IDLE, CHARGE, FIRE }

@onready var barrel: Sprite2D = $Sprite/Barrel
@onready var laser: Line2D = $Sprite/Barrel/Laser

var _state := State.IDLE
var _timer := COOLDOWN
var _left := 0
var _locked := false

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		return
	var aim := global_position.direction_to(_player.global_position).angle()
	_timer -= delta
	match _state:
		State.IDLE:
			barrel.rotation = lerp_angle(barrel.rotation, aim, AIM_TURN * delta)
			if _timer <= 0.0 and global_position.distance_to(_player.global_position) < SIGHT_RANGE:
				_state = State.CHARGE
				_timer = CHARGE_TIME
				_locked = false
				barrel.frame = CHARGE_FRAME
				laser.show()
				# SFX: charge
		State.CHARGE:
			var k := 1.0 - _timer / CHARGE_TIME
			if k < LOCK_FRAC:
				barrel.rotation = lerp_angle(barrel.rotation, aim, AIM_TURN * delta)
			elif not _locked:
				_locked = true
				# SFX: laser
			laser.width = lerpf(LASER_W_MIN, LASER_W_MAX, k)
			laser.modulate.a = lerpf(LASER_ALPHA_MIN, 1.0, k)
			if _timer <= 0.0:
				_state = State.FIRE
				_left = BURST_COUNT
				_timer = 0.0
				laser.hide()
		State.FIRE:
			if _timer <= 0.0:
				_shoot()
				_left -= 1
				_timer = BURST_GAP
				if _left == 0:
					_state = State.IDLE
					_timer = COOLDOWN
					barrel.frame = IDLE_FRAME

func _shoot() -> void:
	# SFX: shoot
	var s := SHOT.instantiate()
	s.direction = Vector2.from_angle(barrel.rotation)
	s.global_position = barrel.global_position + s.direction * MUZZLE_DIST
	get_tree().current_scene.add_child.call_deferred(s)
