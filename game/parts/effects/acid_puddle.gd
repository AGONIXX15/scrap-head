extends Area2D

const LIFE := 3.0
const TICK := 0.5
const RADIUS := 14.0
const COLOR := Color(0.3, 0.9, 0.2, 0.45)
const FADE_TIME := 0.5

var _t := 0.0
var _tick := 0.0

func refresh() -> void:
	_t = 0.0

func _process(delta: float) -> void:
	_t += delta
	_tick += delta
	if _tick >= TICK:
		_tick -= TICK
		for body in get_overlapping_bodies():
			if body.has_method("hit"):
				body.hit(1)
	modulate.a = clampf((LIFE - _t) / FADE_TIME, 0.0, 1.0)
	if _t >= LIFE:
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, COLOR)
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 24, Color(COLOR, 0.9), 1.0)
