extends Node2D

const MUSIC := "res://game/intro/audio/intro.ogg"
const SFX_CLANK := preload("res://game/intro/audio/intro_clank.ogg")
const SFX_ATTACH := preload("res://game/intro/audio/intro_attach.ogg")
const MUSIC_SILENT_DB := -60.0
const NEXT_SCENE := "res://game/level/main.tscn"
const DIR := "res://game/intro/sprites/"
const SPR := "res://game/player/sprites/"
const SHADOW := "res://game/shared/sprites/shadow.png"
const VIEW := Vector2(640, 360)
const BAR_H := 44.0
const TEXT_SIZE := 14
const TEXT_OUTLINE := 5
const TEXT_MARGIN := 24.0
const TEXT_COLOR := Color(1.0, 0.69, 0.19)
const TEXT_OUTLINE_COLOR := Color(0.08, 0.04, 0.1)
const TYPE_CPS := 26.0
const TEXT_FADE := 0.4
const CUT_FADE := 0.4
const SKIP_FADE := 0.3
const END_FADE := 1.0

const T_S2 := 8.0
const T_S3 := 14.0
const ROLL_TIME := FALL_TIME - FALL_BASE # segundos que la intro crece desde AT_FALL (desfase para sincronizar la musica)
const T_S4 := 27.6 + ROLL_TIME
const T_TITLE := 29.5 + ROLL_TIME
const T_FADE_OUT := 31.5 + ROLL_TIME
const SAY_DELAY_S1 := 0.6
const SAY_DELAY_S3 := 0.3
const EYE_GLOW_COLOR := Color(1, 0.15, 0.1, 0.8)
const VISOR_GLOW_COLOR := Color(1, 0.6, 0.15, 0.9)
const DRAG_PUFF_OFF := Vector2(-30, 40)
const S1_PAN := Vector3(60, 130, 230)
const S2_PAN := Vector3(70, 150, 300)
const S2_EYES_PAN := 110.0
const EYE_START := 0.9
const EYE_STEP := 0.55
const EYE_SPOTS := [Vector2(520, 214), Vector2(130, 200), Vector2(380, 224), Vector2(570, 190),
		Vector2(230, 218), Vector2(300, 196), Vector2(80, 226), Vector2(450, 204)]

const ROBOT_POS := Vector2(320, 226)
const ROBOT_SCALE := 4.0
const ARM_POS := Vector2(5, 3)
const LEG_FRAMES := 10
const HEAD_FRAMES := 4
const DEAD_TINT := Color(0.28, 0.24, 0.32)
const PART_ORDER := ["legs", "torso", "arm", "head"]
const GROUND_Y := 240.0
const HEAD_X := 150.0
const DRAG_TO_X := 320.0
const DRAG_DROP := 22.0
const SKY_Y := -50.0
const HEAD_SIDE := 1.45
const HEAD_CROOK := 0.5
const HEAD_TILT := 0.3
const SHADOW_OFF := Vector2(0, 62)
const SHADOW_FROM := 0.3
const SHADOW_TO := 2.2
const FALL_BASE := 0.8
const FALL_TIME := 4.0
const QUAKE_AT := 0.3
const QUAKE_PEAK := 0.8
const QUAKE_TIME := QUAKE_PEAK + ROLL_TIME
const QUAKE_AMP := 6.0
const QUAKE_MIN := 0.4
const QUAKE_HOP := 5.0
const QUAKE_EYE_SPREAD := 0.8
const RAIN_SPREAD := 12.0
const RAIN_SPEED := Vector2(20, 80)
# cantidad, vida, color, gravedad, escala
const RAIN := [[110, 2.2, Color(0.62, 0.52, 0.5, 0.7), Vector2(0, 100), Vector2(1, 3)],
		[24, 0.9, Color(0.35, 0.3, 0.32), Vector2(0, 520), Vector2(2, 4)]]
const TOWER_Y := -1100.0
const HEAD_R := 32.0
const HEAD_START := Vector2(320, -840)
const FALL_TURNS := 3
const TRAIL := [[40, 0.9, Color(0.62, 0.52, 0.5, 0.8), Vector2(0, -30), Vector2(10, 30)],
		[3, 1.6, Color(0.7, 0.7, 0.75), Vector2(0, 200), Vector2(20, 60)]]
const CAM_LEAD := 80.0
const CAM_FOLLOW := 5.0
const SQUASH_FALL := Vector2(1.7, 0.5)
const VIB_TIME := 1.4
const VIB_AMP := 5.0
const VIB_SPARKS := 4
const PILE_R := Vector2(430, 290)
const PILE_L := Vector2(60, 290)
const PILE_LEGS_OFF := Vector2(60, 40)
const FLY_TIME := 0.4
const FLY_SPIN := 6.0
const ARM_DELAY := 0.4
const HOP_H := 14.0
const HOP_TIME := 0.18
const JERKS := 3
const ARM_REACH := 0.7
const ARM_REACH_TIME := 0.15
const JERK_TIME := 0.3
const JERK_PAUSE := 0.35
const SCREW_TIME := 0.7
const ANTENNA_SKEW := 0.35
const ANTENNA_POP := 1.2
const BOING_TIME := 0.9
const FLICKER := [[1.0, 0.06], [0.0, 0.18], [1.0, 0.08], [0.0, 0.22], [1.0, 0.1], [0.0, 0.3]]
const VISOR_GLOW_POS := Vector2(2, -1)
const GLOW_SCALE := 0.35
const VISOR_GLOW_SCALE := 5.0
const SINK_TIME := 0.3
const STAND_TIME := 0.7
const SQUASH := Vector2(1.25, 0.8)
const STRETCH := Vector2(0.92, 1.12)
const SQUASH_TIME := 0.1
const TILT_TIME := 0.5
const TREMBLE_STEP := 0.04
const DUST_SHAKE := 0.07
const DUST_SHAKE_LOOPS := 5
const AT_FALL := QUAKE_AT + QUAKE_PEAK
const AT_VIB := 2.9 + ROLL_TIME
const AT_LAUNCH := 4.4 + ROLL_TIME
const AT_DRAG := 5.6 + ROLL_TIME
const AT_LEGS := 8.2 + ROLL_TIME
const AT_STAND := 10.3 + ROLL_TIME
const AT_VISOR := 12.7 + ROLL_TIME
const AT_TILT := 13.9 + ROLL_TIME
const SPARK_AMOUNT := 14
const DUST_AMOUNT := 8
const DUST_LIFE := 0.7
const DUST_SPEED := Vector2(12, 40)
const DUST_GRAVITY := Vector2(0, -24)
const DUST_COLOR := Color(0.62, 0.52, 0.5, 0.8)
const SPARK_COLOR := Color(1, 0.9, 0.4)
const SPARK_LIFE := 0.45
const SPARK_SPEED := Vector2(70, 170)
const SPARK_GRAVITY := Vector2(0, 320)
const FLASH_ALPHA := 0.7
const FLASH_TIME := 0.35
const SHAKE_STEPS := 8
const SHAKE_STEP_TIME := 0.04
const SHAKE_LAND := 3.0
const SHAKE_TITLE := 12.0

const ALARM_ALPHA := 0.4
const ALARM_PULSE := 0.5
const ALARM_LOOPS := 6
const ALARM_COLOR := Color(0.9, 0.05, 0.05)
const TURN_AT := 1.5
const TURN_TIME := 0.35
const CHASE_EYES := 6
const CHASE_AT := 0.1
const CHASE_TIME := 2.0
const CHASE_FROM_SCALE := 0.8
const CHASE_TO_SCALE := 3.2
const CHASE_Y := 252.0
const CHASE_NEAR_X := 110.0
const CHASE_SPREAD_X := 62.0
const TITLE_POS := Vector2(320, 112)
const TITLE_FROM := 3.0
const TITLE_HIT := 0.14

const TXT := [
	"Año 2187. Las fábricas siguen encendidas... pero ya nadie las controla.",
	"Las máquinas se volvieron defectuosas. Y hostiles.",
	"Pero de la chatarra... algo despertó.",
]

var _world := Node2D.new()
var _cam := Camera2D.new()
var _label := Label.new()
var _fade := ColorRect.new()
var _flash := ColorRect.new()
var _alarm := ColorRect.new()
var _sc: Array[Node2D] = []
var _timeline: Tween
var _leaving := false
var _glow_mat := CanvasItemMaterial.new()
var _robot := Node2D.new()
var _parts := {}
var _head: Sprite2D
var _shadow: Sprite2D
var _pile: Sprite2D
var _q_eyes: Array[Node2D] = []
var _title: Sprite2D
var _s2_layers: Array[Node2D] = []
var _s2_eyes := Node2D.new()
var _s1_layers: Array[Node2D] = []
var _following := false

func _ready() -> void:
	_glow_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	add_child(_world)
	_cam.position = VIEW / 2
	_world.add_child(_cam)
	for i in 3:
		var n := Node2D.new()
		n.visible = i == 0
		_world.add_child(n)
		_sc.append(n)
	_build_s1()
	_build_s2()
	_build_s3()
	_build_ui()
	_fade.modulate.a = 1.0
	create_tween().tween_property(_fade, "modulate:a", 0.0, END_FADE)
	_run_s1()
	if ResourceLoader.exists(MUSIC):
		$Music.stream = load(MUSIC)
		$Music.play()
	_timeline = create_tween()
	var t := 0.0
	for step in [[T_S2 - CUT_FADE, _cut_out], [T_S2, _run_s2], [T_S3 - CUT_FADE, _cut_out],
			[T_S3, _run_s3], [T_S3 + QUAKE_AT, _quake], [T_S3 + AT_FALL, _head_fall], [T_S3 + AT_VIB, _vibrate],
			[T_S3 + AT_LAUNCH, _launch], [T_S3 + AT_DRAG, _drag], [T_S3 + AT_LEGS, _legs],
			[T_S3 + AT_STAND, _stand], [T_S3 + AT_VISOR, _visor], [T_S3 + AT_TILT, _tilt],
			[T_S4, _run_s4], [T_S4 + CHASE_AT, _chase],
			[T_S4 + TURN_AT, _turn], [T_TITLE, _title_hit], [T_FADE_OUT, _leave]]:
		_timeline.tween_interval(step[0] - t)
		_timeline.tween_callback(step[1])
		t = step[0]

func _unhandled_input(event: InputEvent) -> void:
	if _leaving:
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		_leave(SKIP_FADE)

func _leave(time := END_FADE) -> void:
	if _leaving:
		return
	_leaving = true
	_timeline.kill()
	create_tween().tween_property($Music, "volume_db", MUSIC_SILENT_DB, time)
	var tw := create_tween()
	tw.tween_property(_fade, "modulate:a", 1.0, time)
	tw.tween_callback(get_tree().change_scene_to_file.bind(NEXT_SCENE))

func _sfx(stream: AudioStream) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.finished.connect(p.queue_free)
	add_child(p)
	p.play()

func _tex(n: String) -> Texture2D:
	return load(n)

func _spr(parent: Node, tex: String, pos := Vector2.ZERO) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = _tex(tex)
	s.centered = false
	s.position = pos
	parent.add_child(s)
	return s

func _layer(parent: Node, tex: String) -> Node2D:
	var n := Node2D.new()
	_spr(n, DIR + tex + ".png")
	parent.add_child(n)
	return n

func _eyes(parent: Node, pos: Vector2, sc: float) -> Node2D:
	var n := Node2D.new()
	n.position = pos
	n.scale = Vector2(sc, sc)
	var g := Sprite2D.new()
	g.texture = _tex(DIR + "glow.png")
	g.material = _glow_mat
	g.modulate = EYE_GLOW_COLOR
	g.scale = Vector2.ONE
	n.add_child(g)
	var e := Sprite2D.new()
	e.texture = _tex(DIR + "eyes.png")
	n.add_child(e)
	parent.add_child(n)
	return n

func _build_s1() -> void:
	_spr(_sc[0], DIR + "sky.png")
	for n in ["fact_far", "fact_mid", "fact_near"]:
		_s1_layers.append(_layer(_sc[0], n))

func _build_s2() -> void:
	_spr(_sc[1], DIR + "dump_sky.png")
	_s2_layers.append(_layer(_sc[1], "dump_far"))
	_sc[1].add_child(_s2_eyes)
	for i in EYE_SPOTS.size():
		var t := EYE_START + i * EYE_STEP
		var e := _eyes(_s2_eyes, EYE_SPOTS[i] + Vector2(S2_EYES_PAN * t / (T_S3 - T_S2), 0), 1.0)
		e.modulate.a = 0.0
	_s2_layers.append(_layer(_sc[1], "dump_mid"))
	_s2_layers.append(_layer(_sc[1], "dump_front"))

func _build_s3() -> void:
	var sc := _sc[2]
	_spr(sc, DIR + "dump_sky.png")
	_spr(sc, DIR + "tower_sky.png", Vector2(0, TOWER_Y))
	_layer(sc, "dump_far").modulate = Color(0.6, 0.6, 0.7)
	for spot in EYE_SPOTS:
		var e := _eyes(sc, spot, 1.0)
		e.modulate.a = 0.0
		_q_eyes.append(e)
	_spr(sc, DIR + "tower.png", Vector2(0, TOWER_Y))
	_pile = _spr(sc, DIR + "pile.png")
	_shadow = _spr(sc, SHADOW, Vector2(HEAD_X, GROUND_Y) + SHADOW_OFF)
	_shadow.centered = true
	_shadow.modulate.a = 0.0
	_shadow.scale = Vector2.ONE * SHADOW_FROM
	_robot.position = Vector2(HEAD_X, GROUND_Y)
	_robot.scale = Vector2(ROBOT_SCALE, ROBOT_SCALE)
	sc.add_child(_robot)
	var defs := {"legs": ["legs_base", LEG_FRAMES, Vector2.ZERO], "torso": ["body_0", 1, Vector2.ZERO],
			"arm": ["arm_base", 1, ARM_POS], "head": ["head_base", HEAD_FRAMES, Vector2.ZERO]}
	for k in PART_ORDER:
		var s := Sprite2D.new()
		s.texture = _tex(SPR + defs[k][0] + ".png")
		s.hframes = defs[k][1]
		s.visible = k == "head"
		s.modulate = DEAD_TINT
		_robot.add_child(s)
		_parts[k] = s
	_head = _parts["head"]
	_head.position = _head_origin(HEAD_START, 0.0)
	_title = Sprite2D.new()
	_title.texture = _tex(DIR + "title.png")
	_title.position = TITLE_POS
	_title.modulate.a = 0.0
	sc.add_child(_title)

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	for y in [0.0, VIEW.y - BAR_H]:
		var b := ColorRect.new()
		b.color = Color.BLACK
		b.position = Vector2(0, y)
		b.size = Vector2(VIEW.x, BAR_H)
		ui.add_child(b)
	_label.position = Vector2(TEXT_MARGIN, VIEW.y - BAR_H)
	_label.size = Vector2(VIEW.x - TEXT_MARGIN * 2, BAR_H)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", TEXT_SIZE)
	_label.add_theme_color_override("font_color", TEXT_COLOR)
	_label.add_theme_color_override("font_outline_color", TEXT_OUTLINE_COLOR)
	_label.add_theme_constant_override("outline_size", TEXT_OUTLINE)
	_label.visible_ratio = 0.0
	ui.add_child(_label)
	_alarm.color = ALARM_COLOR
	_alarm.modulate.a = 0.0
	_flash.color = Color.WHITE
	_flash.modulate.a = 0.0
	_fade.color = Color.BLACK
	for r in [_alarm, _flash]:
		r.size = VIEW
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui.add_child(r)
		ui.move_child(r, 0)
	var top := CanvasLayer.new()
	top.layer = 20
	add_child(top)
	_fade.size = VIEW
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(_fade)

func _say(i: int) -> void:
	_label.text = TXT[i]
	_label.modulate.a = 1.0
	_label.visible_ratio = 0.0
	var tw := create_tween()
	tw.tween_property(_label, "visible_ratio", 1.0, TXT[i].length() / TYPE_CPS)

func _hide_text() -> void:
	create_tween().tween_property(_label, "modulate:a", 0.0, TEXT_FADE)

func _pan(layers: Array[Node2D], pan: Vector3, time: float) -> void:
	for i in layers.size():
		create_tween().tween_property(layers[i], "position:x", -pan[i], time)

func _cut_out() -> void:
	_hide_text()
	create_tween().tween_property(_fade, "modulate:a", 1.0, CUT_FADE)

func _cut_in(idx: int) -> void:
	for i in _sc.size():
		_sc[i].visible = i == idx
	create_tween().tween_property(_fade, "modulate:a", 0.0, CUT_FADE)

func _run_s1() -> void:
	_pan(_s1_layers, S1_PAN, T_S2)
	get_tree().create_timer(SAY_DELAY_S1).timeout.connect(_say.bind(0))

func _run_s2() -> void:
	_cut_in(1)
	_pan(_s2_layers, S2_PAN, T_S3 - T_S2)
	create_tween().tween_property(_s2_eyes, "position:x", -S2_EYES_PAN, T_S3 - T_S2)
	get_tree().create_timer(SAY_DELAY_S1).timeout.connect(_say.bind(1))
	for i in _s2_eyes.get_child_count():
		get_tree().create_timer(EYE_START + i * EYE_STEP).timeout.connect(_eye_on.bind(_s2_eyes.get_child(i)))

func _eye_on(e: Node2D) -> void:
	# SFX: ojo_on
	var tw := create_tween()
	for a in [1.0, 0.2, 1.0, 0.5, 1.0]:
		tw.tween_property(e, "modulate:a", a, TREMBLE_STEP)

func _run_s3() -> void:
	_cut_in(2)
	_cam.position.y = HEAD_START.y + CAM_LEAD
	_following = true
	get_tree().create_timer(SAY_DELAY_S3).timeout.connect(_say.bind(2))

func _lp(v: Vector2) -> Vector2:
	return v / ROBOT_SCALE

# el sprite de la cabeza ocupa la mitad superior del frame: se rota alrededor de su centro
func _head_origin(center: Vector2, rot: float) -> Vector2:
	return _lp(center - _robot.position) + Vector2(0, HEAD_R / ROBOT_SCALE).rotated(rot)

func _process(delta: float) -> void:
	if _following:
		var y := clampf(_robot.position.y + _head.position.y * ROBOT_SCALE + CAM_LEAD, HEAD_START.y + CAM_LEAD, VIEW.y / 2)
		_cam.position.y = lerpf(_cam.position.y, y, 1.0 - exp(-CAM_FOLLOW * delta))

func _emit(pos: Vector2, c0: Color, amount: int, life: float, speed: Vector2, grav: Vector2) -> void:
	var p := CPUParticles2D.new()
	p.position = pos
	p.amount = amount
	p.lifetime = life
	p.one_shot = true
	p.explosiveness = 1.0
	p.spread = 180.0
	p.gravity = grav
	p.initial_velocity_min = speed.x
	p.initial_velocity_max = speed.y
	p.scale_amount_min = 1.0
	p.scale_amount_max = 3.0
	var g := Gradient.new()
	g.colors = PackedColorArray([c0, Color(c0.r, c0.g * 0.5, c0.b * 0.5, 0)])
	p.color_ramp = g
	p.emitting = true
	_sc[2].add_child(p)
	get_tree().create_timer(life * 2).timeout.connect(p.queue_free)

func _sparks(pos: Vector2) -> void:
	_emit(pos, SPARK_COLOR, SPARK_AMOUNT, SPARK_LIFE, SPARK_SPEED, SPARK_GRAVITY)

func _puff(pos: Vector2) -> void:
	_emit(pos, DUST_COLOR, DUST_AMOUNT, DUST_LIFE, DUST_SPEED, DUST_GRAVITY)

func _shake(amp: float) -> void:
	var tw := create_tween()
	for i in SHAKE_STEPS:
		var k := 1.0 - float(i) / SHAKE_STEPS
		tw.tween_property(_cam, "offset", Vector2(randf_range(-1, 1), randf_range(-1, 1)) * amp * k, SHAKE_STEP_TIME)
	tw.tween_property(_cam, "offset", Vector2.ZERO, SHAKE_STEP_TIME)

func _flash_now(a := FLASH_ALPHA) -> void:
	_flash.modulate.a = a
	create_tween().tween_property(_flash, "modulate:a", 0.0, FLASH_TIME)

func _quake() -> void:
	# SFX: temblor
	for r in RAIN:
		_rain(r)
	for e in _q_eyes:
		get_tree().create_timer(randf() * QUAKE_EYE_SPREAD).timeout.connect(_eye_on.bind(e))
	var tw := create_tween()
	tw.tween_method(_quake_step, 0.0, 1.0, QUAKE_TIME)
	tw.tween_callback(_quake_end)

func _quake_step(k: float) -> void:
	var peak := QUAKE_PEAK / QUAKE_TIME
	var env := k / peak if k < peak else (1.0 - k) / (1.0 - peak)
	var n := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * randf_range(QUAKE_MIN, 1.0)
	_cam.offset = n * QUAKE_AMP * env
	_pile.position.y = -randf() * QUAKE_HOP * env

func _quake_end() -> void:
	_pile.position = Vector2.ZERO
	for e in _q_eyes:
		create_tween().tween_property(e, "modulate:a", 0.0, TEXT_FADE)

func _rain(r: Array) -> void:
	var p := CPUParticles2D.new()
	p.position = Vector2(0, -VIEW.y / 2)
	p.amount = r[0]
	p.lifetime = r[1]
	p.color = r[2]
	p.gravity = r[3]
	p.scale_amount_min = r[4].x
	p.scale_amount_max = r[4].y
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(VIEW.x / 2, 1)
	p.direction = Vector2.DOWN
	p.spread = RAIN_SPREAD
	p.initial_velocity_min = RAIN_SPEED.x
	p.initial_velocity_max = RAIN_SPEED.y
	_cam.add_child(p)
	get_tree().create_timer(QUAKE_TIME).timeout.connect(func(): p.emitting = false)
	get_tree().create_timer(QUAKE_TIME + r[1]).timeout.connect(p.queue_free)

func _head_fall() -> void:
	# SFX: silbido
	var sh := create_tween().set_parallel(true)
	sh.tween_property(_shadow, "modulate:a", 1.0, FALL_TIME)
	sh.tween_property(_shadow, "scale", Vector2.ONE * SHADOW_TO, FALL_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	var trail: Array[CPUParticles2D] = []
	for r in TRAIL:
		trail.append(_trail(r))
	var tw := create_tween()
	tw.tween_method(_fall_step.bind(trail), 0.0, 1.0, FALL_TIME)
	tw.tween_callback(_head_land.bind(trail))

func _trail(r: Array) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.amount = r[0]
	p.lifetime = r[1]
	p.color = r[2]
	p.gravity = r[3]
	p.initial_velocity_min = r[4].x
	p.initial_velocity_max = r[4].y
	p.spread = 180.0
	p.scale_amount_min = 1.0
	p.scale_amount_max = 3.0
	_sc[2].add_child(p)
	return p

func _fall_step(k: float, trail: Array[CPUParticles2D]) -> void:
	var end := _robot.position + Vector2(0, -HEAD_R).rotated(HEAD_SIDE)
	var pos := Vector2(lerpf(HEAD_START.x, end.x, k), lerpf(HEAD_START.y, end.y, k * k))
	_head.rotation = lerpf(0.0, HEAD_SIDE + TAU * FALL_TURNS, k * k)
	_head.position = _head_origin(pos, _head.rotation)
	for p in trail:
		p.position = pos

func _head_land(trail: Array[CPUParticles2D]) -> void:
	_sfx(SFX_CLANK)
	for p in trail:
		p.emitting = false
		get_tree().create_timer(p.lifetime).timeout.connect(p.queue_free)
	_following = false
	_cam.position.y = VIEW.y / 2
	_head.rotation = HEAD_SIDE
	_sparks(_robot.position)
	_puff(_robot.position + Vector2(0, 40))
	_shake(SHAKE_LAND)
	_robot.scale = Vector2(ROBOT_SCALE, ROBOT_SCALE) * SQUASH_FALL
	create_tween().tween_property(_robot, "scale", Vector2(ROBOT_SCALE, ROBOT_SCALE), SQUASH_TIME * 3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	create_tween().tween_property(_shadow, "modulate:a", 0.0, SQUASH_TIME * 3)

func _vibrate() -> void:
	# SFX: zumbido
	var tw := create_tween()
	tw.tween_method(_jitter, 0.0, 1.0, VIB_TIME)
	tw.tween_callback(func(): _head.position = Vector2.ZERO)
	var sp := create_tween().set_loops(VIB_SPARKS)
	sp.tween_interval(VIB_TIME / VIB_SPARKS)
	sp.tween_callback(func(): _sparks(_robot.position))
	var fl := create_tween()
	for f in FLICKER:
		fl.tween_property(_head, "modulate", DEAD_TINT.lerp(Color.WHITE, f[0]), f[1])

func _jitter(k: float) -> void:
	_head.position = _lp(Vector2(randf_range(-1, 1), randf_range(-1, 1)) * VIB_AMP * k)

func _launch() -> void:
	_fly("torso", PILE_R, Vector2.ZERO, _torso_stuck)
	get_tree().create_timer(ARM_DELAY).timeout.connect(_fly.bind("arm", PILE_L, ARM_POS, _clonk))

func _fly(k: String, from: Vector2, target: Vector2, done: Callable) -> void:
	var s: Sprite2D = _parts[k]
	s.position = _lp(from - _robot.position)
	s.rotation = FLY_SPIN
	s.visible = true
	_puff(from)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(s, "position", target, FLY_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(s, "rotation", 0.0, FLY_TIME)
	tw.chain().tween_callback(done)

func _clonk() -> void:
	_sfx(SFX_ATTACH)
	_sparks(_robot.position)
	_puff(_robot.position + Vector2(0, 40))
	_shake(SHAKE_LAND)
	var y := _robot.position.y
	var tw := create_tween()
	tw.tween_property(_robot, "position:y", y - HOP_H, HOP_TIME).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(_robot, "position:y", y, HOP_TIME * 2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _torso_stuck() -> void:
	_clonk()
	create_tween().tween_property(_head, "rotation", HEAD_CROOK, SQUASH_TIME * 5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _drag() -> void:
	var step := (DRAG_TO_X - HEAD_X) / JERKS
	var arm: Sprite2D = _parts["arm"]
	var tw := create_tween()
	for i in JERKS:
		tw.tween_property(arm, "rotation", -ARM_REACH, ARM_REACH_TIME)
		tw.tween_callback(func():
			# SFX: arrastre
			_puff(_robot.position + DRAG_PUFF_OFF))
		tw.tween_property(_robot, "position:x", HEAD_X + step * (i + 1), JERK_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(_robot, "position:y", GROUND_Y + DRAG_DROP * (i + 1) / JERKS, JERK_TIME)
		tw.parallel().tween_property(arm, "rotation", 0.0, JERK_TIME)
		tw.tween_interval(JERK_PAUSE)

func _legs() -> void:
	_fly("legs", _robot.position + PILE_LEGS_OFF, Vector2.ZERO, _legs_stuck)

func _legs_stuck() -> void:
	_clonk()
	# SFX: tornillo
	var tw := create_tween()
	tw.tween_property(_head, "rotation", TAU, SCREW_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(_boing)

func _boing() -> void:
	# SFX: boing
	_head.rotation = 0.0
	_head.skew = ANTENNA_SKEW
	_head.scale.y = ANTENNA_POP
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_head, "skew", 0.0, BOING_TIME).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(_head, "scale:y", 1.0, BOING_TIME).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _tilt() -> void:
	var tw := create_tween()
	tw.tween_property(_head, "rotation", HEAD_TILT, TILT_TIME).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_interval(TILT_TIME)
	tw.tween_property(_head, "rotation", 0.0, SQUASH_TIME * 3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _visor() -> void:
	# SFX: visor
	var tw := create_tween()
	for f in FLICKER:
		tw.tween_property(_head, "modulate", DEAD_TINT.lerp(Color.WHITE, f[0]), f[1])
	tw.tween_callback(_visor_on)

func _visor_on() -> void:
	var g := Sprite2D.new()
	g.texture = _tex(DIR + "glow.png")
	g.material = _glow_mat
	g.modulate = VISOR_GLOW_COLOR
	g.position = VISOR_GLOW_POS
	g.scale = Vector2(GLOW_SCALE, GLOW_SCALE)
	_robot.add_child(g)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(g, "scale", Vector2(VISOR_GLOW_SCALE, VISOR_GLOW_SCALE), FLASH_TIME)
	tw.tween_property(g, "modulate:a", 0.0, FLASH_TIME * 2)
	for k in PART_ORDER:
		tw.tween_property(_parts[k], "modulate", Color.WHITE, FLASH_TIME)
	_flash_now()

func _stand() -> void:
	# SFX: arranque
	var base := Vector2(ROBOT_SCALE, ROBOT_SCALE)
	var tw := create_tween()
	tw.tween_property(_robot, "scale", base * SQUASH, SINK_TIME).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_robot, "position", ROBOT_POS, STAND_TIME).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_robot, "scale", base * STRETCH, STAND_TIME * 0.5)
	tw.tween_callback(func():
		_puff(_robot.position + Vector2(-40, 56))
		_puff(_robot.position + Vector2(40, 56))
		_shake(SHAKE_LAND))
	tw.tween_property(_robot, "scale", base * SQUASH, SQUASH_TIME)
	tw.tween_property(_robot, "scale", base, SQUASH_TIME * 3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	for i in DUST_SHAKE_LOOPS:
		tw.tween_property(_robot, "rotation", DUST_SHAKE, TREMBLE_STEP)
		tw.tween_property(_robot, "rotation", -DUST_SHAKE, TREMBLE_STEP)
	tw.tween_property(_robot, "rotation", 0.0, TREMBLE_STEP)

func _run_s4() -> void:
	_hide_text()
	# SFX: alarma
	var tw := create_tween().set_loops(ALARM_LOOPS)
	tw.tween_property(_alarm, "modulate:a", ALARM_ALPHA, ALARM_PULSE / 2)
	tw.tween_property(_alarm, "modulate:a", 0.0, ALARM_PULSE / 2)

func _turn() -> void:
	var tw := create_tween()
	tw.tween_property(_robot, "scale:x", -ROBOT_SCALE, TURN_TIME).set_trans(Tween.TRANS_SINE)
	tw.tween_interval(TURN_TIME)
	tw.tween_property(_robot, "scale:x", ROBOT_SCALE, TURN_TIME).set_trans(Tween.TRANS_SINE)

func _chase() -> void:
	for i in CHASE_EYES:
		var side := -1.0 if i % 2 == 0 else 1.0
		var depth := i / 2
		var e := _eyes(_sc[2], Vector2(ROBOT_POS.x + side * (VIEW.x / 2 + 20), CHASE_Y - depth * 6), CHASE_FROM_SCALE)
		var to := Vector2(ROBOT_POS.x + side * (CHASE_NEAR_X + depth * CHASE_SPREAD_X), CHASE_Y + depth * 8)
		var tw := create_tween().set_parallel(true)
		tw.tween_property(e, "position", to, CHASE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_property(e, "scale", Vector2.ONE * CHASE_TO_SCALE, CHASE_TIME)

func _title_hit() -> void:
	# SFX: titulo
	_title.scale = Vector2.ONE * TITLE_FROM
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_title, "modulate:a", 1.0, TITLE_HIT)
	tw.tween_property(_title, "scale", Vector2.ONE, TITLE_HIT).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(func(): _flash_now(); _shake(SHAKE_TITLE))
