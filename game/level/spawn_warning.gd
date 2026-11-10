extends Node2D

const WARN_TIME := 1.0
const BLINK_SLOW := 3.0
const BLINK_FAST := 14.0
const RADIUS := 14.0
const ARM := 7.0
const LINE_WIDTH := 2.0
const MARK_COLOR := Color("e03c3c")
const POP_TIME := 0.25
const START_SCALE := 0.1
const DUST_LIFE := 0.6

var enemy: Node2D
var parent: Node
var _t := 0.0
var _phase := 0.0
var _done := false

@onready var dust: CPUParticles2D = $Dust

func _ready() -> void:
	add_to_group("spawn_warning")

func _process(delta: float) -> void:
	if _done:
		return
	_t += delta
	_phase += delta * lerpf(BLINK_SLOW, BLINK_FAST, _t / WARN_TIME)
	queue_redraw()
	if _t >= WARN_TIME:
		_spawn()

func _draw() -> void:
	if _done or fmod(_phase, 1.0) > 0.5:
		return
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 16, MARK_COLOR, LINE_WIDTH)
	draw_line(Vector2(-ARM, -ARM), Vector2(ARM, ARM), MARK_COLOR, LINE_WIDTH)
	draw_line(Vector2(ARM, -ARM), Vector2(-ARM, ARM), MARK_COLOR, LINE_WIDTH)

func _spawn() -> void:
	_done = true
	queue_redraw()
	enemy.position = position
	enemy.scale = Vector2.ONE * START_SCALE
	parent.add_child(enemy)
	enemy.create_tween().tween_property(enemy, "scale", Vector2.ONE, POP_TIME)
	dust.restart()
	get_tree().create_timer(DUST_LIFE).timeout.connect(queue_free)
