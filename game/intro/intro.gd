extends Node2D

const MUSIC_SILENT_DB := -60.0
const NEXT_SCENE := "res://game/level/main.tscn"
const ANIM_NAME := "intro"
const SKIP_FADE := 0.3
const ROBOT_SCALE := 4.0
const SHAKE_STEPS := 8
const SHAKE_STEP_TIME := 0.04
const QUAKE_TIME := 4.0
const QUAKE_PEAK := 0.8
const QUAKE_AMP := 6.0
const QUAKE_MIN := 0.4
const QUAKE_HOP := 5.0
const VIB_TIME := 1.4
const VIB_AMP := 5.0

@onready var _anim: AnimationPlayer = $Anim
@onready var _music: AudioStreamPlayer = $Music
@onready var _fade: ColorRect = $Top/Fade
@onready var _cam: Camera2D = $World/Camera
@onready var _pile: Sprite2D = $World/Scene3Tower/Pile
@onready var _head: Sprite2D = $World/Scene3Tower/Robot/Head

var _leaving := false

func _ready() -> void:
	_anim.play(ANIM_NAME)
	_anim.advance(0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		_leave(SKIP_FADE)

func _leave(time: float) -> void:
	if _leaving:
		return
	_leaving = true
	_anim.pause()
	create_tween().tween_property(_music, "volume_db", MUSIC_SILENT_DB, time)
	var tw := create_tween()
	tw.tween_property(_fade, "modulate:a", 1.0, time)
	tw.tween_callback(go_next)

func go_next() -> void:
	get_tree().change_scene_to_file(NEXT_SCENE)

func shake(amp: float) -> void:
	var tw := create_tween()
	for i in SHAKE_STEPS:
		var k := 1.0 - float(i) / SHAKE_STEPS
		tw.tween_property(_cam, "offset", Vector2(randf_range(-1, 1), randf_range(-1, 1)) * amp * k, SHAKE_STEP_TIME)
	tw.tween_property(_cam, "offset", Vector2.ZERO, SHAKE_STEP_TIME)

func quake() -> void:
	create_tween().tween_method(_quake_step, 0.0, 1.0, QUAKE_TIME)

func _quake_step(k: float) -> void:
	var peak := QUAKE_PEAK / QUAKE_TIME
	var env := k / peak if k < peak else (1.0 - k) / (1.0 - peak)
	var n := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * randf_range(QUAKE_MIN, 1.0)
	_cam.offset = n * QUAKE_AMP * env
	_pile.position.y = -randf() * QUAKE_HOP * env

func vibrate() -> void:
	var tw := create_tween()
	tw.tween_method(_jitter, 0.0, 1.0, VIB_TIME)
	tw.tween_callback(func(): _head.offset = Vector2.ZERO)

func _jitter(k: float) -> void:
	_head.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * VIB_AMP * k / ROBOT_SCALE
