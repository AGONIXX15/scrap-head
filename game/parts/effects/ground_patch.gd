extends Area2D
# Parche en el suelo del jugador: "fuego" quema y "aceite" ralentiza a los enemigos encima.

const RADIUS := 12.0
const TICK := 0.5
const FADE_TIME := 0.5
const OIL_SLOW := 0.5
const COLORS := {"fuego": Color(1.0, 0.45, 0.1, 0.5), "aceite": Color(0.12, 0.08, 0.2, 0.65)}

var kind := "fuego"
var life := 2.5

var _t := 0.0
var _tick := 0.0
var _slowed: Array[Node2D] = []

func _ready() -> void:
	if kind == "aceite":
		body_entered.connect(func(b: Node2D):
			if b.has_method("set_oil_slow") and b not in _slowed:
				_slowed.append(b)
				b.set_oil_slow(OIL_SLOW))
		body_exited.connect(func(b: Node2D):
			if b in _slowed:
				_slowed.erase(b)
				if is_instance_valid(b):
					b.remove_oil_slow())

func _process(delta: float) -> void:
	_t += delta
	if kind == "fuego":
		_tick += delta
		if _tick >= TICK:
			_tick -= TICK
			for b in get_overlapping_bodies():
				if b.has_method("burn"):
					b.burn()
	modulate.a = clampf((life - _t) / FADE_TIME, 0.0, 1.0)
	if _t >= life:
		queue_free()

func _exit_tree() -> void:
	for b in _slowed:
		if is_instance_valid(b):
			b.remove_oil_slow()
	_slowed.clear()

func _draw() -> void:
	draw_circle(Vector2.ZERO, RADIUS, COLORS[kind])
