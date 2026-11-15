class_name ArmFx

const EXPLOSION := preload("res://game/fx/explosion.tscn")
const ACID := preload("res://game/parts/effects/acid_puddle.tscn")
const BOLT_RADIUS := 90.0
const BOLT_COLOR := Color("9be8ff")
const BOLT_STEPS := 5
const BOLT_JITTER := 6.0
const BOLT_TIME := 0.15
const ACID_RADIUS := 14.0
const BLAST_RADIUS := 40.0
const BLAST_SCALE := 0.5
const BLAST_SHAKE := 1.0

static var _puddles: Array = []

# Rayo desde el enemigo impactado a los `count` enemigos más cercanos (excepto él); les hace `damage`.
static func lightning(ctx: Node, source: Node2D, count: int, damage: int) -> void:
	var near := Spatial.near(source.global_position, BOLT_RADIUS).filter(func(e: Node2D): return e != source)
	near.sort_custom(func(a: Node2D, b: Node2D):
		return a.global_position.distance_to(source.global_position) < b.global_position.distance_to(source.global_position))
	var from := source.global_position
	for e: Node2D in near.slice(0, count):
		var to := e.global_position
		var line := Line2D.new()
		line.width = 1.0
		line.default_color = BOLT_COLOR
		line.z_index = 5
		for i in BOLT_STEPS + 1:
			var p := from.lerp(to, float(i) / BOLT_STEPS)
			line.add_point(p if i == 0 or i == BOLT_STEPS else p + Vector2(randf_range(-BOLT_JITTER, BOLT_JITTER), randf_range(-BOLT_JITTER, BOLT_JITTER)))
		ctx.get_tree().current_scene.add_child(line)
		line.create_tween().tween_property(line, "modulate:a", 0.0, BOLT_TIME).finished.connect(line.queue_free)
		e.hit(damage, from.direction_to(to))

# Daño en área sin dañar al jugador ni encadenar (golpea directo, no crea balas).
static func blast(ctx: Node, pos: Vector2, damage: int, skip: Node = null) -> void:
	var fx := EXPLOSION.instantiate()
	fx.global_position = pos
	fx.scale = Vector2.ONE * BLAST_SCALE
	ctx.get_tree().current_scene.add_child.call_deferred(fx)
	Juice.shake(BLAST_SHAKE)
	for e: Node2D in Spatial.near(pos, BLAST_RADIUS):
		if e != skip:
			e.hit(damage, pos.direction_to(e.global_position))

static func acid(ctx: Node, pos: Vector2) -> void:
	_puddles = _puddles.filter(func(q): return is_instance_valid(q))
	for q: Node2D in _puddles:
		if q.global_position.distance_to(pos) < ACID_RADIUS:
			q.refresh()  # no apilar charcos: refresca el existente
			return
	var p := ACID.instantiate()
	p.global_position = pos
	_puddles.append(p)
	ctx.get_tree().current_scene.add_child.call_deferred(p)
