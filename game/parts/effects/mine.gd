extends Area2D
# Mina del Minero: se arma un instante y explota cuando un enemigo se acerca.

const ARM_TIME := 0.6
const DAMAGE := 3

var _t := 0.0

func _process(delta: float) -> void:
	if _t < ARM_TIME:
		_t += delta
		if _t >= ARM_TIME:
			queue_redraw()
		return
	if not get_overlapping_bodies().is_empty():
		ArmFx.blast(self, global_position, DAMAGE)
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color("2a2a36"))
	draw_circle(Vector2.ZERO, 1.5, Color("ff2828") if _t >= ARM_TIME else Color("886060"))
