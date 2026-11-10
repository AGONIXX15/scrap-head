extends Node2D
@export var life := 0.8
@export var fps := 14.0

@onready var sprite: Sprite2D = get_node_or_null("Sprite")

var _t := 0.0

func _ready() -> void:
	get_tree().create_timer(life).timeout.connect(queue_free)

func _process(delta: float) -> void:
	if sprite == null:
		return
	_t += delta
	if int(_t * fps) >= sprite.hframes:
		sprite.hide()
	else:
		sprite.frame = int(_t * fps)
