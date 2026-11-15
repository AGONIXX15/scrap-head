class_name QuadTree

const CAPACITY := 8
const MAX_DEPTH := 6

var rect: Rect2
var _depth: int
var _items := []  # sin tipar: puede contener enemigos ya liberados hasta la siguiente reconstrucción
var _kids: Array[QuadTree] = []

# shortcut: indexa por posición global y se reconstruye entero cada vez; con puntos fuera de `rect` las consultas pueden fallar, usar un rect holgado.
func _init(bounds: Rect2, depth := 0) -> void:
	rect = bounds
	_depth = depth

func insert(node: Node2D) -> void:
	if _kids.is_empty():
		if _items.size() < CAPACITY or _depth >= MAX_DEPTH:
			_items.append(node)
			return
		_split()
	_kids[_child(node.global_position)].insert(node)

func query_circle(pos: Vector2, radius: float) -> Array:
	var out := []
	_query(pos, radius, out)
	return out

func _query(pos: Vector2, radius: float, out: Array) -> void:
	if pos.clamp(rect.position, rect.end).distance_to(pos) > radius:
		return
	for n in _items:
		# el árbol puede tener hasta un frame físico: saltar enemigos ya liberados
		if is_instance_valid(n) and not n.is_queued_for_deletion() and n.global_position.distance_to(pos) <= radius:
			out.append(n)
	for k in _kids:
		k._query(pos, radius, out)

func _child(p: Vector2) -> int:
	var c := rect.get_center()
	return (1 if p.x >= c.x else 0) + (2 if p.y >= c.y else 0)

func _split() -> void:
	var h := rect.size * 0.5
	for i in 4:
		_kids.append(QuadTree.new(Rect2(rect.position + Vector2(h.x * (i & 1), h.y * (i >> 1)), h), _depth + 1))
	for n in _items:
		_kids[_child(n.global_position)].insert(n)
	_items.clear()
