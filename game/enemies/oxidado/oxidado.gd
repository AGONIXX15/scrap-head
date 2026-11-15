extends EnemyBase

const WALK_FPS := 8.0
const OPEN_FRAME := 0
const CLOSED_FRAME := 2
const LUNGE_RANGE := 90.0
const WINDUP_TIME := 0.5
const LUNGE_SPEED := 300.0
const LUNGE_TIME := 0.3
const RECOVER_TIME := 0.7
const TREMBLE := 1.0
const BLINK_HZ := 14.0
const BLINK_DIM := 0.3
const BLINK_BRIGHT := 2.0
const PUPIL_REACH := 1.5

enum State { CHASE, WINDUP, LUNGE, RECOVER }

@onready var pupil: Sprite2D = $Sprite/Pupil
@onready var light: PointLight2D = $Sprite/Light

var _state := State.CHASE
var _timer := 0.0
var _t := 0.0
var _lunge_dir := Vector2.ZERO
var _eye_home := Vector2.ZERO
var _light_energy := 0.0

func _ready() -> void:
	super()
	_eye_home = pupil.position
	_light_energy = light.energy

func _physics_process(delta: float) -> void:
	if _dead or not is_instance_valid(_player):
		return
	var dir := global_position.direction_to(_player.global_position)
	_knock = _knock.move_toward(Vector2.ZERO, KNOCK_DECAY * delta)
	pupil.position = _eye_home + dir * PUPIL_REACH
	_timer -= delta
	velocity = _knock
	match _state:
		State.CHASE:
			velocity += dir * (speed * speed_mult)
			_t += delta * (WALK_FPS * speed_mult)
			sprite.frame = int(_t) % sprite.hframes
			if global_position.distance_to(_player.global_position) < LUNGE_RANGE:
				_state = State.WINDUP
				_timer = WINDUP_TIME
				# SFX: charge
		State.WINDUP:
			sprite.frame = OPEN_FRAME
			sprite.position = Vector2(randf_range(-TREMBLE, TREMBLE), randf_range(-TREMBLE, TREMBLE))
			_set_eye(int(_timer * BLINK_HZ) % 2 == 0)
			if _timer <= 0.0:
				_lunge_dir = dir
				_state = State.LUNGE
				_timer = LUNGE_TIME
				sprite.position = Vector2.ZERO
				_set_eye(true)
		State.LUNGE:
			velocity = _lunge_dir * (LUNGE_SPEED * speed_mult)
			if _timer <= 0.0:
				_state = State.RECOVER
				_timer = RECOVER_TIME
				sprite.frame = CLOSED_FRAME
		State.RECOVER:
			if _timer <= 0.0:
				_state = State.CHASE
	move_and_slide()
	_touch()

func _set_eye(bright: bool) -> void:
	pupil.visible = bright
	light.energy = _light_energy * (BLINK_BRIGHT if bright else BLINK_DIM)
