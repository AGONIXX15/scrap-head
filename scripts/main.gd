extends Node2D

const ENEMY := preload("res://scenes/enemy.tscn")
const ARENA := Vector2(1280, 720)
const MARGIN := 16.0
const MAX_ENEMIES := 40
const MIN_DIST := 200.0

@onready var enemies: Node = $Enemies
@onready var player: Node2D = $Player

func _ready() -> void:
	$SpawnTimer.timeout.connect(_spawn)

func _spawn() -> void:
	if enemies.get_child_count() >= MAX_ENEMIES:
		return
	var pos := _perimeter_point()
	if pos.distance_to(player.global_position) < MIN_DIST:
		return  # se salta este tick; el siguiente probará otro punto
	var e := ENEMY.instantiate()
	e.position = pos
	enemies.add_child(e)

func _perimeter_point() -> Vector2:
	var t := randf()
	var w := ARENA.x - 2.0 * MARGIN
	var h := ARENA.y - 2.0 * MARGIN
	var d := t * 2.0 * (w + h)
	if d < w:
		return Vector2(MARGIN + d, MARGIN)
	d -= w
	if d < h:
		return Vector2(ARENA.x - MARGIN, MARGIN + d)
	d -= h
	if d < w:
		return Vector2(ARENA.x - MARGIN - d, ARENA.y - MARGIN)
	return Vector2(MARGIN, ARENA.y - MARGIN - (d - w))
