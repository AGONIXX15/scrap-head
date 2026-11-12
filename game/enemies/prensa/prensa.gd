extends EnemyBase

const DUST := preload("res://game/fx/dust.tscn")
const WALK_FPS := 6.0
const SLAM_RANGE := 80.0
const SLAM_COOLDOWN := 3.0
const SLAM_WINDUP := 1.0
const SLAM_RADIUS := 60.0
const SLAM_DAMAGE := 2
const SLAM_RECOVER := 0.6
const SLAM_SHAKE := 8.0
const RAM_LIFT := 6.0
const RAM_DROP := 4.0
const RAM_SLAM_TIME := 0.08

enum State { WALK, WINDUP, RECOVER }

@onready var ram: Sprite2D = $Sprite/Ram

var _state := State.WALK
var _timer := 0.0
var _cooldown := 0.0
var _t := 0.0
var _ram_home := 0.0
var _ram_tween: Tween

func _ready() -> void:
	super()
	_ram_home = ram.position.y

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		return
	_knock = _knock.move_toward(Vector2.ZERO, KNOCK_DECAY * delta)
	_timer -= delta
	_cooldown -= delta
	velocity = _knock
	match _state:
		State.WALK:
			velocity += global_position.direction_to(_player.global_position) * (speed * speed_mult)
			_t += delta * (WALK_FPS * speed_mult)
			sprite.frame = int(_t) % sprite.hframes
			if _cooldown <= 0.0 and global_position.distance_to(_player.global_position) < SLAM_RANGE:
				_state = State.WINDUP
				_timer = SLAM_WINDUP
				_ram_tween = create_tween()
				_ram_tween.tween_property(ram, "position:y", _ram_home - RAM_LIFT, SLAM_WINDUP)
				# SFX: charge
		State.WINDUP:
			_telegraph(SLAM_RADIUS, 1.0 - _timer / SLAM_WINDUP)
			if _timer <= 0.0:
				_slam()
		State.RECOVER:
			if _timer <= 0.0:
				_state = State.WALK
	move_and_slide()
	if _state == State.WALK:
		_touch()

func _slam() -> void:
	# SFX: slam
	_telegraph(0.0)
	_state = State.RECOVER
	_timer = SLAM_RECOVER
	_cooldown = SLAM_COOLDOWN
	if _ram_tween:
		_ram_tween.kill()
	_ram_tween = create_tween()
	_ram_tween.tween_property(ram, "position:y", _ram_home + RAM_DROP, RAM_SLAM_TIME)
	_ram_tween.tween_property(ram, "position:y", _ram_home, SLAM_RECOVER)
	Juice.shake(SLAM_SHAKE)
	var dust := DUST.instantiate()
	dust.global_position = global_position
	get_tree().current_scene.add_child.call_deferred(dust)
	if global_position.distance_to(_player.global_position) <= SLAM_RADIUS:
		_player.take_damage(SLAM_DAMAGE)
