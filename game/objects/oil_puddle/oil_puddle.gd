class_name OilPuddle extends Area2D

@export var slow_factor := 0.45

var _affected_bodies: Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body in _affected_bodies:
		return
	_affected_bodies.append(body)
	_apply_slow(body)

func _on_body_exited(body: Node2D) -> void:
	_affected_bodies.erase(body)
	_remove_slow(body)

func _apply_slow(body: Node2D) -> void:
	if body.has_method("set_oil_slow"):
		body.set_oil_slow(slow_factor)
	elif "speed_mult" in body:
		body.speed_mult = slow_factor

func _remove_slow(body: Node2D) -> void:
	if not is_instance_valid(body):
		return
	if body.has_method("remove_oil_slow"):
		body.remove_oil_slow()
	elif "speed_mult" in body:
		body.speed_mult = 1.0

func _exit_tree() -> void:
	for body in _affected_bodies:
		if is_instance_valid(body):
			_remove_slow(body)
	_affected_bodies.clear()
