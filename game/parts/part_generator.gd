class_name PartGenerator

# Material = rareza en la que sale, rampa de 4 colores (oscuro a claro), stat con sesgo y chiste para la descripción.
const MATERIALS := [
	{"name": "Óxido", "rarity": 0, "ramp": ["2a140c", "6e2f1c", "a8481f", "d98a4a"], "bias": "speed", "humor": "Huele a lluvia vieja."},
	{"name": "Hierro", "rarity": 0, "ramp": ["15161c", "3b3d4a", "7d808f", "c4c7d4"], "bias": "max_hp", "humor": "Pesa lo que promete."},
	{"name": "Cobre", "rarity": 1, "ramp": ["2a1208", "7a3a1c", "c8702f", "f2b27a"], "bias": "fire_rate", "humor": "Conduce y presume."},
	{"name": "Cromo", "rarity": 1, "ramp": ["181c28", "5a6479", "aeb9cf", "f2f6ff"], "bias": "range", "humor": "Te ves en él. Mejor no mirar."},
	{"name": "Latón", "rarity": 1, "ramp": ["2a2008", "7a5f1c", "c4a032", "f0dc84"], "bias": "damage", "humor": "Suena a trompeta al caer."},
	{"name": "Oro", "rarity": 2, "ramp": ["33200a", "9a6a12", "ffc21e", "fff1a0"], "bias": "range", "humor": "Carísimo, pero es chatarra igual."},
	{"name": "Plasma", "rarity": 2, "ramp": ["1a0a3a", "5a1fa8", "b04dff", "f0c0ff"], "bias": "damage", "humor": "No lo toques. En serio."},
	{"name": "Obsidiana", "rarity": 1, "ramp": ["06050c", "1a1630", "3d3470", "8a7fd0"], "bias": "max_hp", "humor": "Cuidado, que corta."},
	{"name": "Neón", "rarity": 2, "ramp": ["06222a", "0e7a6a", "2effa0", "d0ffe8"], "bias": "speed", "humor": "Brilla en la oscuridad. Y atrae enemigos."},
	{"name": "Hueso", "rarity": 0, "ramp": ["2a2218", "7a6c54", "cfc3a0", "f6f0dc"], "bias": "fire_rate", "humor": "Ni preguntes de quién era."},
]

# Formas por ranura: nombre base, género (para concordar adjetivos) y sprite.
const SHAPES := {
	Part.HEAD: [
		{"name": "Módulo", "fem": false, "tex": preload("res://game/parts/sprites/part_autoaim.png")},
		{"name": "Visor", "fem": false, "tex": preload("res://game/parts/sprites/part_visor.png")},
		{"name": "Casco", "fem": false, "tex": preload("res://game/parts/sprites/part_head_casco.png")},
		{"name": "Cíclope", "fem": false, "tex": preload("res://game/parts/sprites/part_head_ciclope.png")},
		{"name": "Cráneo", "fem": false, "tex": preload("res://game/parts/sprites/part_head_craneo.png")},
	],
	Part.ARM: [
		{"name": "Taladro", "fem": false, "tex": preload("res://game/parts/sprites/part_drill.png")},
		{"name": "Sierra", "fem": true, "tex": preload("res://game/parts/sprites/part_sierra.png")},
		{"name": "Cañón", "fem": false, "tex": preload("res://game/parts/sprites/part_arm_canon.png")},
		{"name": "Pinza", "fem": true, "tex": preload("res://game/parts/sprites/part_arm_pinza.png")},
		{"name": "Martillo", "fem": false, "tex": preload("res://game/parts/sprites/part_arm_martillo.png")},
	],
	Part.LEGS: [
		{"name": "Orugas", "fem": true, "tex": preload("res://game/parts/sprites/part_tracks.png")},
		{"name": "Ruedas", "fem": true, "tex": preload("res://game/parts/sprites/part_wheel.png")},
		{"name": "Patas", "fem": true, "tex": preload("res://game/parts/sprites/part_patas_arana.png")},
	],
	Part.BACK: [
		{"name": "Soporte", "fem": false, "tex": preload("res://game/parts/sprites/part_dock.png")},
		{"name": "Mochila", "fem": true, "tex": preload("res://game/parts/sprites/part_back_mochila.png")},
		{"name": "Motor", "fem": false, "tex": preload("res://game/parts/sprites/part_back_motor.png")},
		{"name": "Tanque", "fem": false, "tex": preload("res://game/parts/sprites/part_back_tanque.png")},
	],
}

# acc_<ranura>_<nombre>.png en game/parts/sprites/
const ACCESSORIES := {
	Part.HEAD: ["antena", "cuernos", "pinchos", "tornillos", "foco", "orejeras", "parche", "cresta", "gafas", "remaches"],
	Part.ARM: ["mira", "cargador", "pinchos", "tubo", "foco", "cables", "placa", "remaches", "banda", "radiador"],
	Part.LEGS: ["pinchos", "rodilleras", "muelles", "luces", "tornillos", "parche", "cadena", "guardabarros", "escape", "bandas"],
	Part.BACK: ["chimenea", "antena", "ventilador", "radar", "tubos", "cadena", "parche", "luces", "placa", "cables"],
}

# Efectos por ranura (min_rarity y cost en puntos del presupuesto); para ampliar, añadir entradas aquí (adj_f = femenino si difiere).
# En esta fase solo hay efectos que el juego ya sabe aplicar (stats o escena).
const EFFECTS := {
	Part.ARM: [
		{"id": "perforante", "min_rarity": 1, "cost": 2, "adj": "Perforante", "desc": "Las balas atraviesan enemigos.", "stats": {"pierce": 1}},
		{"id": "rebotador", "min_rarity": 1, "cost": 2, "adj": "Rebotador", "adj_f": "Rebotadora", "desc": "Las balas rebotan en las paredes.", "stats": {"bounces": 1}},
	],
	Part.HEAD: [
		{"id": "autoapuntado", "min_rarity": 2, "cost": 3, "adj": "Autoapuntado", "adj_f": "Autoapuntada", "desc": "Apunta y dispara solo.", "stats": {"auto_aim": 1}},
	],
	Part.LEGS: [
		{"id": "antideslizante", "min_rarity": 1, "cost": 2, "adj": "Antideslizante", "desc": "Ignora el aceite.", "stats": {"ignore_oil": 1}},
	],
	Part.BACK: [
		{"id": "orbital", "min_rarity": 2, "cost": 4, "adj": "Orbital", "desc": "Un mini dron te escolta.", "scene": preload("res://game/parts/drone/drone.tscn")},
	],
}

# Stats que puede recibir cada ranura
const SLOT_STATS := {
	Part.HEAD: ["range", "fire_rate", "damage"],
	Part.ARM: ["damage", "fire_rate", "range"],
	Part.LEGS: ["speed", "max_hp"],
	Part.BACK: ["max_hp", "speed", "range"],
}
# stat: [cantidad por bloque, coste en puntos, máximo de bloques]
const STAT_COST := {
	"speed": [10.0, 1, 6], "max_hp": [1, 2, 3], "damage": [1, 3, 2], "fire_rate": [-0.03, 1, 4], "range": [40.0, 1, 5],
}

const LEGENDARY := 2
const LEGENDARY_FROM_WAVE := 3  # las legendarias solo salen desde esta oleada
const BUDGET := [2, 4, 8]
const NEGATIVE_CHANCE := 0.3
const MAX_ACCESSORIES := [1, 2, 3]  # rareza: hasta cuántos (mínimo: rareza 0 -> 0, 1 -> 1, 2 -> 2)
const MAX_EFFECTS := [1, 1, 2]  # rareza 0: 0-1; el resto, siempre ese número
const SHADER := preload("res://game/parts/palette.gdshader")
const ACC_PATH := "res://game/parts/sprites/acc_%s_%s.png"
const ACC_GROUP := "part_accessory"

static var _materials := {}

static func make(slot: String, rarity: int, wave: int) -> Part:
	if wave < LEGENDARY_FROM_WAVE:
		rarity = mini(rarity, LEGENDARY - 1)
	var p := Part.new()
	var shape: Dictionary = SHAPES[slot].pick_random()
	p.slot = slot
	p.rarity = rarity
	p.texture = shape.tex
	var ids := range(MATERIALS.size()).filter(func(i: int): return MATERIALS[i].rarity == rarity)
	p.material = ids.pick_random()
	var mat: Dictionary = MATERIALS[p.material]

	var names: Array = ACCESSORIES[slot].duplicate()
	names.shuffle()
	for n in names.slice(0, randi_range(rarity, MAX_ACCESSORIES[rarity])):
		p.accessories.append(load(ACC_PATH % [slot, n]))

	var effects: Array = EFFECTS[slot].filter(func(e: Dictionary): return e.min_rarity <= rarity)
	effects.shuffle()
	effects = effects.slice(0, randi_range(0 if rarity < LEGENDARY else MAX_EFFECTS[rarity], MAX_EFFECTS[rarity]))
	var points: int = BUDGET[rarity]
	var bought := []  # las lambdas capturan por valor: bucle para ir restando
	for e: Dictionary in effects:
		if e.cost <= points:
			points -= e.cost
			bought.append(e)
	effects = bought
	p.stats = _roll_stats(slot, points, mat.bias)
	var descs := []
	for e: Dictionary in effects:
		p.effects.append(e.id)
		for k in e.get("stats", {}):
			p.stats[k] = p.stats.get(k, 0) + e.stats[k]
		if e.has("scene"):
			p.scene = e.scene
		descs.append(e.desc)

	p.name = "%s de %s" % [shape.name, mat.name]
	if not effects.is_empty():
		p.name += " " + effects[0].get("adj_f" if shape.fem else "adj", effects[0].adj)
	descs.append(mat.humor)
	p.description = " ".join(descs)
	return p

static func _roll_stats(slot: String, points: int, bias: String) -> Dictionary:
	var keys: Array = SLOT_STATS[slot].duplicate()
	keys.shuffle()
	var counts := {}
	# un stat negativo devuelve sus puntos; el sesgo del material va primero
	if keys.size() > 1 and randf() < NEGATIVE_CHANCE:
		var neg: String = keys.filter(func(k: String): return k != bias).pick_random()
		keys.erase(neg)
		counts[neg] = -1
		points += STAT_COST[neg][1]
	if bias in keys:
		keys.erase(bias)
		keys.push_front(bias)
	var first := true
	while not keys.is_empty():
		var k: String = keys[0] if first else keys.pick_random()
		first = false
		var cost: int = STAT_COST[k][1]
		if cost > points or counts.get(k, 0) >= STAT_COST[k][2]:
			keys.erase(k)
			continue
		counts[k] = counts.get(k, 0) + 1
		points -= cost
	var stats := {}
	for k in counts:
		var v = counts[k] * STAT_COST[k][0]
		stats[k] = snappedf(v, 0.01) if v is float else v
	return stats

# Material de paleta de la pieza (null si no tiene); un ShaderMaterial por material.
static func material_for(part: Part) -> ShaderMaterial:
	if part.material < 0:
		return null
	if not _materials.has(part.material):
		var m := ShaderMaterial.new()
		m.shader = SHADER
		var ramp: Array = MATERIALS[part.material].ramp
		for i in ramp.size():
			m.set_shader_parameter("c%d" % i, Color(ramp[i]))
		_materials[part.material] = m
	return _materials[part.material]

# Material y accesorios sobre una capa Sprite2D (part puede ser null: la deja limpia).
static func dress(layer: Sprite2D, part: Part) -> void:
	for c in layer.get_children().filter(func(n: Node): return n.is_in_group(ACC_GROUP)):
		layer.remove_child(c)
		c.queue_free()
	layer.material = material_for(part) if part else null
	if not part:
		return
	for t in part.accessories:
		var s := Sprite2D.new()
		s.add_to_group(ACC_GROUP)
		s.texture = t
		s.use_parent_material = true
		layer.add_child(s)

# Lo mismo para un icono (TextureRect): los accesorios son hijos a pantalla completa.
static func dress_icon(icon: TextureRect, part: Part) -> void:
	for c in icon.get_children():
		icon.remove_child(c)
		c.queue_free()
	icon.material = material_for(part) if part else null
	if not part:
		return
	for t in part.accessories:
		var r := TextureRect.new()
		r.texture = t
		r.set_anchors_preset(Control.PRESET_FULL_RECT)
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.mouse_filter = Control.MOUSE_FILTER_IGNORE
		r.use_parent_material = true
		icon.add_child(r)
