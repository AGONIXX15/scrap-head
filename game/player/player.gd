extends CharacterBody2D

signal hp_changed(hp: int, max_hp: int)
signal parts_changed(parts: Dictionary)
signal scrap_changed(n: int)
signal died

const BULLET := preload("res://game/weapons/bullet/bullet.tscn")
const BODIES := [preload("res://game/player/sprites/body_0.png"), preload("res://game/player/sprites/body_1.png"),
		preload("res://game/player/sprites/body_2.png")]
const BODY_BY_PARTS := [0, 0, 1, 1, 2]
const MIN_FIRE_RATE := 0.08
const MIN_HP := 1
const INVULN_TIME := 0.6
const BLINK_HZ := 20.0
const BLINK_ALPHA := 0.35
const SHOULDER_Y := 3.0
const BOB_IDLE := [0, 0, -1, -1]
const BOB_WALK := [0, -1, -1, 0, -1, -1]
const IDLE_FRAMES := 4
const WALK_FIRST := 4
const WALK_FRAMES := 6
const IDLE_FPS := 5.0
const WALK_FPS := 12.0
const LAYER_FPS := 6.0
const ARM_FPS := 16.0
const FLASH_COLOR := Color(4, 4, 4)
const FLASH_TIME := 0.15
const START_SQUASH := Vector2(0.85, 1.15)
const EQUIP_SQUASH := Vector2(1.3, 0.7)
const START_SQUASH_TIME := 0.2
const EQUIP_SQUASH_TIME := 0.4
const MUZZLE_FRAME_TIME := 0.04
const RECOIL := 3.0
const RECOIL_TIME := 0.12
const TEXT_WIDTH := 120.0
const TEXT_SIZE := 10
const TEXT_COLOR := Color("ffd64a")
const TEXT_OUTLINE_COLOR := Color("181220")
const TEXT_OUTLINE := 3
const TEXT_OFFSET := Vector2(-60.0, -34.0)
const TEXT_RISE := 24.0
const TEXT_TIME := 0.9
const TEXT_FADE_DELAY := 0.5
const TEXT_FADE_TIME := 0.4
const TEXT_Z := 10
const DEBRIS_DIST_MIN := 30.0
const DEBRIS_DIST_MAX := 70.0
const DEBRIS_LIFT := Vector2(0, -12)
const DEBRIS_SPIN := 6.0
const DEBRIS_TIME := 0.8
const DEBRIS_FADE_DELAY := 0.5
const DEBRIS_FADE_TIME := 0.4
const RELOAD_DELAY := 1.0

@export var base_speed := 150.0
@export var base_max_hp := 5
@export var base_fire_rate := 0.3
@export var base_damage := 1
@export var base_range := 450.0
@export var base_pierce := 0
@export var base_auto_aim := false

@onready var rig: Node2D = $Rig
@onready var body: Node2D = $Rig/Body
@onready var legs: Sprite2D = $Rig/Body/Legs
@onready var torso: Sprite2D = $Rig/Body/Torso
@onready var back: Sprite2D = $Rig/Body/Back
@onready var arm: Node2D = $Rig/Body/Arm
@onready var arm_sprite: Sprite2D = $Rig/Body/Arm/Sprite
@onready var muzzle: Sprite2D = $Rig/Body/Arm/Muzzle
@onready var head: Sprite2D = $Rig/Body/Head
@onready var dust: CPUParticles2D = $Dust
@onready var sparks: CPUParticles2D = $Sparks
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var layers := {Part.HEAD: head, Part.ARM: arm_sprite, Part.LEGS: legs, Part.BACK: back}

var speed: float
var max_hp: int
var fire_rate: float
var damage: int
var shoot_range: float
var pierce: int
var auto_aim: bool
var hp: int
var parts := {}
var scrap := 0

var _extras := {}
var _clock := 0.0
var _anim := 0.0
var _moving := false
var _invuln := 0.0
var _cooldown := 0.0
var _squash_tween: Tween
var _recoil_tween: Tween

func _ready() -> void:
	_recalc()
	hp = max_hp
	hp_changed.emit(hp, max_hp)
	parts_changed.emit(parts)
	scrap_changed.emit(scrap)

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * speed
	move_and_slide()

	var aim := nearest_enemy(global_position, shoot_range) if auto_aim else get_global_mouse_position()
	var face := aim.x - global_position.x if aim != Vector2.INF else dir.x
	if face != 0.0:
		body.scale.x = signf(face)
	arm.rotation = (body.to_local(aim) - arm.position).angle() if aim != Vector2.INF else 0.0
	_cooldown -= delta
	if _cooldown <= 0.0 and aim != Vector2.INF and (auto_aim or Input.is_action_pressed("shoot")):
		_shoot(arm.global_position.direction_to(aim))
		_cooldown = fire_rate

	var moving := dir != Vector2.ZERO
	if moving and not _moving:
		_squash(START_SQUASH, START_SQUASH_TIME)
	_moving = moving
	dust.emitting = moving
	_clock += delta
	_anim += delta * (WALK_FPS if moving else IDLE_FPS)
	legs.frame = WALK_FIRST + int(_anim) % WALK_FRAMES if moving else int(_anim) % IDLE_FRAMES
	var bob: int = BOB_WALK[int(_anim) % WALK_FRAMES] if moving else BOB_IDLE[int(_anim) % IDLE_FRAMES]
	for n in [torso, back, head]:
		n.position.y = bob
	arm.position.y = SHOULDER_Y + bob
	head.frame = int(_clock * LAYER_FPS) % head.hframes
	back.frame = int(_clock * LAYER_FPS) % back.hframes
	arm_sprite.frame = int(_clock * ARM_FPS) % arm_sprite.hframes

	if _invuln > 0.0:
		_invuln -= delta
		rig.modulate.a = BLINK_ALPHA if int(_invuln * BLINK_HZ) % 2 == 0 else 1.0
		if _invuln <= 0.0:
			rig.modulate.a = 1.0

func take_damage(n: int) -> void:
	if hp == 0 or _invuln > 0.0:
		return
	hp = maxi(hp - n, 0)
	hp_changed.emit(hp, max_hp)
	_flash()
	if hp == 0:
		_disassemble()
		return
	_invuln = INVULN_TIME

func equip(part: Part) -> void:
	if hp == 0:
		return
	# SFX: equip
	parts[part.slot] = part
	var layer: Sprite2D = layers[part.slot]
	layer.texture = part.texture
	layer.hframes = part.frames()
	if _extras.has(part.slot):
		_extras[part.slot].queue_free()
		_extras.erase(part.slot)
	if part.scene:
		_extras[part.slot] = part.scene.instantiate()
		add_child(_extras[part.slot])
	var old_max := max_hp
	_recalc()
	hp = clampi(hp + max_hp - old_max, MIN_HP, max_hp)
	hp_changed.emit(hp, max_hp)
	torso.texture = BODIES[BODY_BY_PARTS[parts.size()]]
	_flash()
	_squash(EQUIP_SQUASH, EQUIP_SQUASH_TIME)
	sparks.restart()
	_float_text("¡%s!" % part.name)
	parts_changed.emit(parts)

func add_scrap(n: int) -> void:
	# SFX: pickup
	scrap += n
	scrap_changed.emit(scrap)

func nearest_enemy(from: Vector2, max_dist: float) -> Vector2:
	var best := max_dist
	var target := Vector2.INF
	for e in get_tree().get_nodes_in_group("enemies"):
		var d := from.distance_to(e.global_position)
		if d <= best:
			best = d
			target = e.global_position
	return target

func spawn_bullet(pos: Vector2, direction: Vector2) -> void:
	var b := BULLET.instantiate()
	b.direction = direction
	b.damage = damage
	b.pierce = pierce
	b.max_range = shoot_range
	b.global_position = pos
	get_tree().current_scene.add_child(b)

func _stat(key: String) -> float:
	var s := 0.0
	for p: Part in parts.values():
		s += float(p.stats.get(key, 0))  # auto_aim: true cuenta como 1
	return s

func _recalc() -> void:
	speed = base_speed + _stat("speed")
	max_hp = base_max_hp + int(_stat("max_hp"))
	fire_rate = maxf(base_fire_rate + _stat("fire_rate"), MIN_FIRE_RATE)
	damage = base_damage + int(_stat("damage"))
	shoot_range = base_range + _stat("range")
	pierce = base_pierce + int(_stat("pierce"))
	auto_aim = base_auto_aim or _stat("auto_aim") > 0.0

func _shoot(direction: Vector2) -> void:
	# SFX: shoot
	spawn_bullet(muzzle.global_position, direction)
	muzzle.show()
	muzzle.frame = 0
	var t := create_tween()
	for f in range(1, muzzle.hframes):
		t.tween_callback(muzzle.set.bind("frame", f)).set_delay(MUZZLE_FRAME_TIME)
	t.tween_callback(muzzle.hide).set_delay(MUZZLE_FRAME_TIME)
	if _recoil_tween:
		_recoil_tween.kill()
	arm_sprite.position.x = -RECOIL
	_recoil_tween = create_tween()
	_recoil_tween.tween_property(arm_sprite, "position:x", 0.0, RECOIL_TIME)

func _flash() -> void:
	body.modulate = FLASH_COLOR
	create_tween().tween_property(body, "modulate", Color.WHITE, FLASH_TIME)

func _squash(s: Vector2, t: float) -> void:
	if _squash_tween:
		_squash_tween.kill()
	rig.scale = s
	_squash_tween = create_tween()
	_squash_tween.tween_property(rig, "scale", Vector2.ONE, t).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _float_text(text: String) -> void:
	var l := Label.new()
	l.text = text
	l.custom_minimum_size.x = TEXT_WIDTH
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", TEXT_SIZE)
	l.add_theme_color_override("font_color", TEXT_COLOR)
	l.add_theme_color_override("font_outline_color", TEXT_OUTLINE_COLOR)
	l.add_theme_constant_override("outline_size", TEXT_OUTLINE)
	l.global_position = global_position + TEXT_OFFSET
	l.z_index = TEXT_Z
	get_tree().current_scene.add_child(l)
	var t := l.create_tween().set_parallel()
	t.tween_property(l, "position:y", l.position.y - TEXT_RISE, TEXT_TIME)
	t.tween_property(l, "modulate:a", 0.0, TEXT_FADE_TIME).set_delay(TEXT_FADE_DELAY)
	t.chain().tween_callback(l.queue_free)

func _disassemble() -> void:
	# SFX: explode
	died.emit()
	remove_from_group("player")
	collision.set_deferred("disabled", true)
	set_physics_process(false)
	dust.emitting = false
	rig.modulate.a = 1.0
	for e in _extras.values():
		e.queue_free()
	for n: Node2D in [legs, torso, back, arm, head]:
		var fly := Vector2.from_angle(randf() * TAU) * randf_range(DEBRIS_DIST_MIN, DEBRIS_DIST_MAX)
		var t := create_tween().set_parallel().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.tween_property(n, "position", n.position + fly + DEBRIS_LIFT, DEBRIS_TIME)
		t.tween_property(n, "rotation", randf_range(-DEBRIS_SPIN, DEBRIS_SPIN), DEBRIS_TIME)
		t.tween_property(n, "modulate:a", 0.0, DEBRIS_FADE_TIME).set_delay(DEBRIS_FADE_DELAY)
