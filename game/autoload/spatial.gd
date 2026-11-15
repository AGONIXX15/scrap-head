extends Node

# Margen holgado sobre la arena (1280x720) para que un enemigo empujado fuera no se pierda.
const BOUNDS := Rect2(-200, -200, 1680, 1120)

var _tree := QuadTree.new(BOUNDS)

# Se reconstruye una vez por frame físico; pausado no hace falta (nadie consulta).
func _physics_process(_delta: float) -> void:
	_tree = QuadTree.new(BOUNDS)
	for e: Node2D in get_tree().get_nodes_in_group("enemies"):
		if not e.is_queued_for_deletion():
			_tree.insert(e)

# Enemigos vivos a distancia <= radius de pos.
func near(pos: Vector2, radius: float) -> Array:
	return _tree.query_circle(pos, radius)
