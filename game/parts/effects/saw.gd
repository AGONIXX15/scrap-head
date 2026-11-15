extends Area2D
# Sierra orbital: gira alrededor del jugador y daña a los enemigos que toca.

const ORBIT := 34.0
const ORBIT_SPEED := 3.0
const SPIN := 14.0
const TICK := 0.3

var angle := 0.0  # fase inicial (reparte las sierras en círculo)

var _tick := 0.0

@onready var sprite: Sprite2D = $Sprite

func _process(delta: float) -> void:
	angle += delta * ORBIT_SPEED
	position = Vector2.from_angle(angle) * ORBIT
	sprite.rotation += delta * SPIN
	_tick += delta
	if _tick >= TICK:
		_tick -= TICK
		for b in get_overlapping_bodies():
			if b.has_method("hit"):
				b.hit(1)
