class_name ExplosiveBarrel extends StaticBody2D

signal exploded

const EXPLOSION_FX := preload("res://game/fx/explosion.tscn")
const FLASH_COLOR := Color(4, 4, 4)
const FLASH_TIME := 0.08
const SQUASH := Vector2(1.15, 0.85)
const SQUASH_TIME := 0.15

@export var max_hp := 1
@export var blast_radius := 75.0
@export var blast_damage := 4
@export var knockback_force := 260.0
@export var shake_amount := 3.5
@export var damage_player := true
@export var player_damage := 1

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D
@onready var particles: CPUParticles2D = $ExplosionParticles

var hp: int
var _exploded := false
var _squash_tween: Tween

func _ready() -> void:
	hp = max_hp
	add_to_group("barrels")

func hit(amount: int, _from_dir := Vector2.ZERO) -> void:
	if _exploded:
		return
	hp -= amount
	var juice := _get_juice()
	if juice:
		juice.damage_number(global_position + Vector2(0, -16), amount)
	
	if hp <= 0:
		explode()
		return

	# Hit feedback if barrel has > 1 hp
	sprite.modulate = FLASH_COLOR
	create_tween().tween_property(sprite, "modulate", Color.WHITE, FLASH_TIME)
	_squash()

func explode() -> void:
	if _exploded:
		return
	_exploded = true
	exploded.emit()

	# Hide barrel visual and disable collision
	sprite.visible = false
	$Shadow.visible = false
	collision.set_deferred("disabled", true)
	if hurtbox_collision:
		hurtbox_collision.set_deferred("disabled", true)

	# 1. Main Explosion FX (animated sprite + sparks + flying bolts)
	var scene := get_tree().current_scene
	if scene and EXPLOSION_FX:
		var fx := EXPLOSION_FX.instantiate()
		fx.global_position = global_position
		fx.scale = Vector2.ONE * 1.8
		scene.add_child.call_deferred(fx)

	# 2. Barrel shrapnel & fire burst particles
	if particles:
		particles.restart()

	# 3. Screen shake & hitstop
	var juice := _get_juice()
	if juice:
		juice.shake(shake_amount)
		juice.hitstop()

	# 4. Area of effect damage
	_apply_blast_damage()

	# Clean up after particles finish
	await get_tree().create_timer(0.65).timeout
	queue_free()

func _apply_blast_damage() -> void:
	# Damage enemies
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			var dist := global_position.distance_to(enemy.global_position)
			if dist <= blast_radius:
				var dir := global_position.direction_to(enemy.global_position)
				if dir == Vector2.ZERO:
					dir = Vector2.RIGHT
				if enemy.has_method("hit"):
					enemy.hit(blast_damage, dir)

	# Chain reaction with other barrels
	var barrels := get_tree().get_nodes_in_group("barrels")
	for b in barrels:
		if b != self and is_instance_valid(b) and not b.is_queued_for_deletion() and not b._exploded:
			var dist := global_position.distance_to(b.global_position)
			if dist <= blast_radius:
				var chain_delay := randf_range(0.05, 0.12)
				get_tree().create_timer(chain_delay).timeout.connect(func():
					if is_instance_valid(b) and not b._exploded:
						b.hit(blast_damage)
				)

	# Damage player if close
	if damage_player:
		var player := get_tree().get_first_node_in_group("player")
		if player and is_instance_valid(player) and not player.is_queued_for_deletion():
			var dist := global_position.distance_to(player.global_position)
			if dist <= blast_radius * 0.7:
				if player.has_method("take_damage"):
					player.take_damage(player_damage)

func _squash() -> void:
	if _squash_tween:
		_squash_tween.kill()
	sprite.scale = SQUASH
	_squash_tween = create_tween()
	_squash_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_squash_tween.tween_property(sprite, "scale", Vector2.ONE, SQUASH_TIME)

func _get_juice() -> Node:
	if Engine.has_singleton("Juice"):
		return Engine.get_singleton("Juice")
	return get_node_or_null("/root/Juice")
