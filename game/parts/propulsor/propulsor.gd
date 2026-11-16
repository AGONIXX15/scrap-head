extends Node2D

@onready var player: CharacterBody2D = get_parent()
@onready var flame: Sprite2D = $Flame

var _anim_t := 0.0

func _ready() -> void:
	z_index = -1
	if flame:
		flame.visible = false

func _process(delta: float) -> void:
	if not player or not is_instance_valid(player):
		return
	_anim_t += delta * 20.0
	
	var dash_t: float = player.get("_dash_t") if player.get("_dash_t") != null else 0.0
	if dash_t > 0.0:
		flame.visible = true
		flame.frame = int(_anim_t) % flame.hframes
		var dash_dir: Vector2 = player._dash_dir if player.get("_dash_dir") != null else Vector2.ZERO
		if dash_dir.length_squared() > 0.01:
			flame.rotation = dash_dir.angle() + PI
			flame.position = Vector2(0, 8) - dash_dir.normalized() * 10.0
		else:
			flame.position = Vector2(0, 8)
	else:
		flame.visible = false
