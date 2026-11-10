class_name EnemyBase extends CharacterBody2D

const EXPLOSION := preload("res://scenes/explosion.tscn")
const PICKUP := preload("res://scenes/pickup.tscn")
const KNOCKBACK := 140.0
const KNOCK_DECAY := 600.0
const FLASH_COLOR := Color(4, 4, 4)
const FLASH_TIME := 0.1
const ELITE_HP_MULT := 3
const ELITE_SCALE := 1.25
const ELITE_COLOR := Color(1.6, 1.3, 0.5)
const BAR_SIZE := Vector2(20, 2)
const BAR_BACK := Color("181220")
const BAR_FILL := Color("ff2828")
const WARN_COLOR := Color("ff2828")
const WARN_BASE_ALPHA := 0.15
const WARN_FILL_ALPHA := 0.45
const WARN_LINE := 1.0
const WARN_POINTS := 48

@export var speed := 60.0
@export var hp := 3
@export var damage := 1
@export var elite := false
@export_range(0.0, 1.0) var drop_chance := 0.25
@export var drops: Array[Part] = []
@export var knock_scale := 1.0
@export var bar_y := -22.0
@export var fx_scale := 1.0
@export var death_shake := 1.5

@onready var sprite: Sprite2D = $Sprite
@onready var hitbox: Area2D = get_node_or_null("Hitbox")

var _player: Node2D
var _knock := Vector2.ZERO
var _max_hp := 0
var _tint := Color.WHITE
var _bar := Node2D.new()
var _warn := Node2D.new()
var _warn_radius := 0.0
var _warn_fill := 0.0

func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if elite:
		hp *= ELITE_HP_MULT
		drop_chance = 1.0
		scale = Vector2.ONE * ELITE_SCALE
		_tint = ELITE_COLOR
		sprite.modulate = _tint
	_max_hp = hp
	for n: Node2D in [_bar, _warn]:
		n.scale = Vector2.ONE / scale
		add_child(n)
	_bar.z_index = 1
	_bar.visible = false
	_bar.draw.connect(_draw_bar)
	_warn.show_behind_parent = true
	_warn.draw.connect(_draw_warn)

func hit(amount: int, from_dir := Vector2.ZERO) -> void:
	if hp <= 0:
		return  # dos balas en el mismo frame
	hp -= amount
	_juice(&"damage_number", [global_position + Vector2(0.0, bar_y), amount])
	_bar.visible = true
	_bar.queue_redraw()
	if hp <= 0:
		# SFX: explode
		_die()
		return
	# SFX: hit
	_knock = from_dir * KNOCKBACK * knock_scale
	sprite.modulate = FLASH_COLOR
	create_tween().tween_property(sprite, "modulate", _tint, FLASH_TIME)

func _die() -> void:
	_on_death()
	var scene := get_tree().current_scene
	var fx := EXPLOSION.instantiate()
	fx.global_position = global_position
	fx.scale = Vector2.ONE * fx_scale
	scene.add_child.call_deferred(fx)
	if not drops.is_empty() and randf() < drop_chance:
		var p := PICKUP.instantiate()
		p.part = drops.pick_random()
		p.global_position = global_position
		scene.add_child.call_deferred(p)
	_juice(&"hitstop")
	_juice(&"shake", [death_shake])
	queue_free()

func _on_death() -> void:
	pass

func _touch() -> void:
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(damage)

func _telegraph(radius: float, fill := 0.0) -> void:
	_warn_radius = radius
	_warn_fill = fill
	_warn.queue_redraw()

func _juice(fn: StringName, args := []) -> void:
	var j := get_node_or_null("/root/Juice")
	if j:
		j.callv(fn, args)

func _draw_bar() -> void:
	var origin := Vector2(-BAR_SIZE.x * 0.5, bar_y)
	_bar.draw_rect(Rect2(origin - Vector2.ONE, BAR_SIZE + Vector2.ONE * 2.0), BAR_BACK)
	_bar.draw_rect(Rect2(origin, Vector2(BAR_SIZE.x * maxf(hp, 0) / _max_hp, BAR_SIZE.y)), BAR_FILL)

func _draw_warn() -> void:
	if _warn_radius <= 0.0:
		return
	_warn.draw_circle(Vector2.ZERO, _warn_radius, Color(WARN_COLOR, WARN_BASE_ALPHA))
	_warn.draw_circle(Vector2.ZERO, _warn_radius * _warn_fill, Color(WARN_COLOR, WARN_FILL_ALPHA))
	_warn.draw_arc(Vector2.ZERO, _warn_radius, 0.0, TAU, WARN_POINTS, WARN_COLOR, WARN_LINE)
