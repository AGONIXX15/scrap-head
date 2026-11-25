extends EnemyBase

const ZIG_FREQ := 9.0
const ZIG_ANGLE := 0.9
const TRIGGER_DIST := 26.0
const FUSE_TIME := 0.35
const EXPLODE_RADIUS := 44.0
const PROP_FPS := 30.0
const BEEP_HZ_FAR := 3.0
const BEEP_HZ_NEAR := 14.0
const BEEP_RANGE := 220.0
const LIGHT_DIM := 0.2

@onready var light: PointLight2D = $Light

var _t := 0.0
var _phase := randf() * TAU
var _fuse := -1.0
var _beep := 0.0
var _lit := false
var _light_energy := 0.0

func _ready() -> void:
	super()
	_light_energy = light.energy

func _physics_process(delta: float) -> void:
	survival_time += delta
	if not is_instance_valid(_player):
		return
	var dist := global_position.distance_to(_player.global_position)
	_t += delta
	sprite.frame = int(_t * PROP_FPS) % sprite.hframes
	_knock = _knock.move_toward(Vector2.ZERO, KNOCK_DECAY * delta)
	_beep += delta * lerpf(BEEP_HZ_NEAR, BEEP_HZ_FAR, clampf(dist / BEEP_RANGE, 0.0, 1.0))
	var lit := int(_beep) % 2 == 0
	if lit and not _lit and dist < BEEP_RANGE:
		Sfx.play("beep", global_position)
	_lit = lit
	light.energy = _light_energy if lit else _light_energy * LIGHT_DIM
	if _fuse >= 0.0:
		_fuse -= delta * aggression
		velocity = _knock
		_telegraph(EXPLODE_RADIUS, 1.0 - _fuse / FUSE_TIME)
		if _fuse <= 0.0:
			if dist <= EXPLODE_RADIUS:
				var prev_hp: int = _player.hp if "hp" in _player else 0
				_player.take_damage(damage)
				var cur_hp: int = _player.hp if "hp" in _player else 0
				if prev_hp > cur_hp:
					record_damage_dealt(prev_hp - cur_hp)
			hp = 0
			_die()
			return
	else:
		var dir := global_position.direction_to(_player.global_position)
		var freq := ZIG_FREQ * (1.3 if attack_type == "fast" else 1.0)
		velocity = dir.rotated(sin(_t * freq + _phase) * ZIG_ANGLE) * (speed * speed_mult) + _knock
		if dist < TRIGGER_DIST:
			_fuse = FUSE_TIME
			Sfx.play("charge", global_position, 1.3)
	move_and_slide()
