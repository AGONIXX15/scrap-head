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
	if not is_instance_valid(_player):
		return
	var dist := global_position.distance_to(_player.global_position)
	_t += delta
	sprite.frame = int(_t * PROP_FPS) % sprite.hframes
	_knock = _knock.move_toward(Vector2.ZERO, KNOCK_DECAY * delta)
	_beep += delta * lerpf(BEEP_HZ_NEAR, BEEP_HZ_FAR, clampf(dist / BEEP_RANGE, 0.0, 1.0))
	var lit := int(_beep) % 2 == 0
	if lit and not _lit:
		pass  # SFX: beep
	_lit = lit
	light.energy = _light_energy if lit else _light_energy * LIGHT_DIM
	if _fuse >= 0.0:
		_fuse -= delta
		velocity = _knock
		var explode_rad := EXPLODE_RADIUS * (1.3 if (genes and genes.attack_type == EnemyGenes.AttackType.HEAVY) else 1.0)
		var fuse_dur := FUSE_TIME / (1.3 if (genes and genes.attack_type == EnemyGenes.AttackType.RAPID) else 1.0)
		_telegraph(explode_rad, 1.0 - _fuse / fuse_dur)
		if _fuse <= 0.0:
			if dist <= explode_rad:
				var dmg := damage + (1 if (genes and genes.attack_type == EnemyGenes.AttackType.HEAVY) else 0)
				var prev_hp: int = _player.hp
				_player.take_damage(dmg)
				if _player.hp < prev_hp:
					record_player_damage(prev_hp - _player.hp)
			hp = 0
			_die()
			return
	else:
		var dir := global_position.direction_to(_player.global_position)
		velocity = dir.rotated(sin(_t * ZIG_FREQ + _phase) * ZIG_ANGLE) * (speed * speed_mult) + _knock
		var trig_dist := TRIGGER_DIST * (genes.aggression if genes else 1.0)
		if dist < trig_dist:
			var fuse_dur := FUSE_TIME / (1.3 if (genes and genes.attack_type == EnemyGenes.AttackType.RAPID) else 1.0)
			_fuse = fuse_dur
			# SFX: charge
	move_and_slide()
