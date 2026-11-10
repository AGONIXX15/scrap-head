extends Area2D

const BOB_HEIGHT := 4.0
const BOB_TIME := 0.6
const GLOW_COLOR := Color(1.9, 1.7, 1.3)
const GLOW_TIME := 0.5

var part: Part

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	sprite.texture = part.texture
	sprite.hframes = part.frames()
	body_entered.connect(_on_body_entered)
	var bob := create_tween().set_loops().set_trans(Tween.TRANS_SINE)
	bob.tween_property(sprite, "position:y", -BOB_HEIGHT, BOB_TIME)
	bob.tween_property(sprite, "position:y", 0.0, BOB_TIME)
	var glow := create_tween().set_loops()
	glow.tween_property(sprite, "modulate", GLOW_COLOR, GLOW_TIME)
	glow.tween_property(sprite, "modulate", Color.WHITE, GLOW_TIME)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and body.hp > 0:
		# SFX: pickup
		body.equip(part)
		queue_free()
