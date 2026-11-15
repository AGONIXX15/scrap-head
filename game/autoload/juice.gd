extends Node

const SHAKE_DECAY := 30.0
const HITSTOP_TIME := 0.05
const HITSTOP_SCALE := 0.05
const NUMBER_SIZE := 12
const NUMBER_OUTLINE := 4
const NUMBER_RISE := 22.0
const NUMBER_TIME := 0.6
const NUMBER_SPREAD := 6.0
const NUMBER_COLOR := Color("ffd24a")
const OUTLINE_COLOR := Color("1a1030")

var _strength := 0.0

func _process(delta: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return
	_strength = move_toward(_strength, 0.0, SHAKE_DECAY * delta)
	cam.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _strength

func shake(strength: float) -> void:
	_strength = maxf(_strength, strength)

var _stops := 0

func hitstop() -> void:
	_stops += 1
	Engine.time_scale = HITSTOP_SCALE
	await get_tree().create_timer(HITSTOP_TIME, true, false, true).timeout
	_stops -= 1
	if _stops == 0:
		Engine.time_scale = 1.0

func damage_number(pos: Vector2, amount: int) -> void:
	var l := Label.new()
	l.text = str(amount)
	l.add_theme_font_size_override("font_size", NUMBER_SIZE)
	l.add_theme_color_override("font_color", NUMBER_COLOR)
	l.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	l.add_theme_constant_override("outline_size", NUMBER_OUTLINE)
	l.z_index = 100
	l.position = pos + Vector2(randf_range(-NUMBER_SPREAD, NUMBER_SPREAD), 0.0)
	var scene := get_tree().current_scene if get_tree().current_scene else get_tree().root
	scene.add_child(l)
	var tw := l.create_tween().set_parallel()
	tw.tween_property(l, "position:y", l.position.y - NUMBER_RISE, NUMBER_TIME)
	tw.tween_property(l, "modulate:a", 0.0, NUMBER_TIME)
	tw.chain().tween_callback(l.queue_free)
