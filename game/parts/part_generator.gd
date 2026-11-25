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
# Efectos de brazo (bala): se aplican en bullet.gd / player.gd según el id; los que cambian stats lo hacen aquí.
const EFFECTS := {
	Part.ARM: [
		{"id": "perforante", "min_rarity": 1, "cost": 2, "adj": "Perforante", "desc": "Las balas atraviesan enemigos.", "stats": {"pierce": 1}},
		{"id": "rebotador", "min_rarity": 1, "cost": 2, "adj": "Rebotador", "adj_f": "Rebotadora", "desc": "Las balas rebotan en las paredes.", "stats": {"bounces": 1}},
		{"id": "igneo", "min_rarity": 1, "cost": 2, "adj": "Ígneo", "adj_f": "Ígnea", "desc": "Quema a los enemigos."},
		{"id": "criogenico", "min_rarity": 1, "cost": 2, "adj": "Criogénico", "adj_f": "Criogénica", "desc": "Ralentiza a los enemigos."},
		{"id": "electrico", "min_rarity": 1, "cost": 3, "adj": "Eléctrico", "adj_f": "Eléctrica", "desc": "El impacto salta a enemigos cercanos."},
		{"id": "explosivo", "min_rarity": 1, "cost": 3, "adj": "Explosivo", "adj_f": "Explosiva", "desc": "Las balas explotan al impactar."},
		{"id": "fragmentador", "min_rarity": 1, "cost": 3, "adj": "Fragmentador", "adj_f": "Fragmentadora", "desc": "Las balas se parten en tres al impactar."},
		{"id": "buscador", "min_rarity": 1, "cost": 2, "adj": "Buscador", "adj_f": "Buscadora", "desc": "Las balas persiguen al enemigo cercano."},
		{"id": "boomerang", "min_rarity": 1, "cost": 3, "adj": "Boomerang", "desc": "Las balas vuelven hacia ti."},
		{"id": "colosal", "min_rarity": 1, "cost": 3, "adj": "Colosal", "desc": "Balas enormes, más daño y más lentas.", "stats": {"damage": 1, "fire_rate": 0.1}},
		{"id": "gemelo", "min_rarity": 1, "cost": 2, "adj": "Gemelo", "adj_f": "Gemela", "desc": "Dispara dos balas a la vez."},
		{"id": "escopeta", "min_rarity": 1, "cost": 3, "adj": "Perdigonero", "adj_f": "Perdigonera", "desc": "Cinco perdigones de poco alcance, más lenta.", "stats": {"fire_rate": 0.1}},
		{"id": "hidraulico", "min_rarity": 1, "cost": 2, "adj": "Hidráulico", "adj_f": "Hidráulica", "desc": "Empuja a los enemigos con fuerza."},
		{"id": "acido", "min_rarity": 1, "cost": 3, "adj": "Ácido", "adj_f": "Ácida", "desc": "Deja charcos de ácido."},
	],
	Part.HEAD: [
		{"id": "autoapuntado", "min_rarity": 2, "cost": 3, "adj": "Autoapuntado", "adj_f": "Autoapuntada", "desc": "Apunta y dispara solo.", "stats": {"auto_aim": 1}},
		{"id": "ciclopeo", "min_rarity": 1, "cost": 3, "adj": "Ciclópeo", "adj_f": "Ciclópea", "desc": "15% de crítico (x2 daño) por copia, hasta 60%."},
		{"id": "telescopico", "min_rarity": 0, "cost": 2, "adj": "Telescópico", "adj_f": "Telescópica", "desc": "Más alcance y balas más rápidas.", "stats": {"range": 80}},
		{"id": "marcador", "min_rarity": 1, "cost": 3, "adj": "Marcador", "adj_f": "Marcadora", "desc": "Marca a los enemigos: reciben más daño 3 s."},
		{"id": "francotirador", "min_rarity": 2, "cost": 4, "adj": "Francotirador", "adj_f": "Francotiradora", "desc": "Más daño si la bala viaja lejos."},
		{"id": "berserker", "min_rarity": 2, "cost": 3, "adj": "Berserker", "desc": "Dispara más rápido con la mitad de vida o menos."},
		{"id": "tasador", "min_rarity": 1, "cost": 2, "adj": "Tasador", "adj_f": "Tasadora", "desc": "+1 chatarra por cada recogida."},
		{"id": "radar", "min_rarity": 1, "cost": 2, "adj": "Rastreador", "adj_f": "Rastreadora", "desc": "Puntos rojos señalan enemigos fuera de pantalla."},
	],
	Part.LEGS: [
		{"id": "antideslizante", "min_rarity": 1, "cost": 2, "adj": "Antideslizante", "desc": "Ignora el aceite.", "stats": {"ignore_oil": 1}},
		{"id": "propulsor", "min_rarity": 2, "cost": 4, "adj": "Propulsor", "adj_f": "Propulsora", "desc": "Shift: dash invulnerable. Más copias, menos espera."},
		{"id": "rastro_fuego", "min_rarity": 1, "cost": 3, "adj": "Incendiario", "adj_f": "Incendiaria", "desc": "Deja fuego a tu paso."},
		{"id": "rastro_aceite", "min_rarity": 1, "cost": 2, "adj": "Aceitoso", "adj_f": "Aceitosa", "desc": "Deja aceite que ralentiza a los enemigos."},
		{"id": "minas", "min_rarity": 2, "cost": 4, "adj": "Minero", "adj_f": "Minera", "desc": "Suelta minas que explotan al acercarse un enemigo."},
		{"id": "pisoton", "min_rarity": 2, "cost": 4, "adj": "Pisoteador", "adj_f": "Pisoteadora", "desc": "Cada 4 s una onda daña y empuja."},
		{"id": "patinador", "min_rarity": 0, "cost": 2, "adj": "Patinador", "adj_f": "Patinadora", "desc": "Más velocidad.", "stats": {"speed": 20}},
	],
	Part.BACK: [
		{"id": "orbital", "min_rarity": 2, "cost": 4, "adj": "Orbital", "desc": "Un mini dron te escolta.", "scene": preload("res://game/parts/drone/drone.tscn")},
		{"id": "sierra_orbital", "min_rarity": 2, "cost": 4, "adj": "Aserrador", "adj_f": "Aserradora", "desc": "Una sierra gira a tu alrededor."},
		{"id": "escudo", "min_rarity": 2, "cost": 4, "adj": "Blindado", "adj_f": "Blindada", "desc": "Bloquea un golpe; se recarga en 8 s."},
		{"id": "espinas", "min_rarity": 1, "cost": 3, "adj": "Espinoso", "adj_f": "Espinosa", "desc": "Al recibir daño, hiere a los enemigos cercanos."},
		{"id": "reactor", "min_rarity": 0, "cost": 2, "adj": "Reactivo", "adj_f": "Reactiva", "desc": "Dispara más rápido.", "stats": {"fire_rate": -0.06}},
		{"id": "iman", "min_rarity": 1, "cost": 2, "adj": "Magnético", "adj_f": "Magnética", "desc": "Atrae la chatarra desde más lejos."},
		{"id": "regenerador", "min_rarity": 1, "cost": 3, "adj": "Regenerador", "adj_f": "Regeneradora", "desc": "+1 vida cada 10 s."},
		{"id": "vampiro", "min_rarity": 2, "cost": 4, "adj": "Vampírico", "adj_f": "Vampírica", "desc": "Recuperas 1 vida cada pocas muertes."},
		{"id": "mochila", "min_rarity": 0, "cost": 2, "adj": "Acolchado", "adj_f": "Acolchada", "desc": "+1 vida máxima.", "stats": {"max_hp": 1}},
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
	# el daño nunca va en negativo: con daño base 1 la pieza quedaría inútil
	var neg_keys := keys.filter(func(k: String): return k != bias and k != "damage")
	if keys.size() > 1 and not neg_keys.is_empty() and randf() < NEGATIVE_CHANCE:
		var neg: String = neg_keys.pick_random()
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

# Material de paleta de la pieza (null si no tiene); un ShaderMaterial por material/combinación.
static func material_for(part: Part, frame_count: float = 1.0) -> ShaderMaterial:
	if part.material < 0 and part.secondary_material < 0:
		return null
	var key := "%d_%d_%d" % [part.material, part.secondary_material, int(frame_count)]
	if not _materials.has(key):
		var m := ShaderMaterial.new()
		m.shader = SHADER
		var mat_idx := maxi(part.material, 0)
		var ramp: Array = MATERIALS[mat_idx].ramp
		for i in ramp.size():
			m.set_shader_parameter("c%d" % i, Color(ramp[i]))
		if part.secondary_material >= 0 and part.secondary_material != part.material:
			m.set_shader_parameter("split", true)
			m.set_shader_parameter("frame_count", frame_count)
			var r_ramp: Array = MATERIALS[part.secondary_material].ramp
			for i in r_ramp.size():
				m.set_shader_parameter("r%d" % i, Color(r_ramp[i]))
		else:
			m.set_shader_parameter("split", false)
		_materials[key] = m
	return _materials[key]

# Material y accesorios sobre una capa Sprite2D (part puede ser null: la deja limpia).
static func dress(layer: Sprite2D, part: Part) -> void:
	for c in layer.get_children().filter(func(n: Node): return n.is_in_group(ACC_GROUP)):
		layer.remove_child(c)
		c.queue_free()
	var frames := float(part.frames()) if part else 1.0
	layer.material = material_for(part, frames) if part else null
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
	icon.material = material_for(part, 1.0) if part else null
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

# =========================================================================
# FUSIÓN DE PIEZAS (HU-19: Cruce y Mutación)
# =========================================================================

const MUTATION_CHANCE_ACCESSORY := 0.35
const MUTATION_CHANCE_EFFECT := 0.35
const MUTATION_CHANCE_COLOR := 0.35

# Resuelve la info de forma (Shape) para una pieza dada
static func _find_shape_info(part: Part) -> Dictionary:
	var list: Array = SHAPES.get(part.slot, [])
	for s: Dictionary in list:
		if s.tex == part.texture or (part.texture and s.tex and s.tex.resource_path == part.texture.resource_path):
			return s
	return {"name": part.name.split(" ")[0], "fem": false, "tex": part.texture}

# Resuelve la info de un efecto por su ID
static func _find_effect_info(slot: String, effect_id: String) -> Dictionary:
	for e: Dictionary in EFFECTS.get(slot, []):
		if e.id == effect_id:
			return e
	return {}

# Fusiona dos piezas parent_a y parent_b de la misma ranura
static func fuse(p_a: Part, p_b: Part) -> Part:
	assert(p_a.slot == p_b.slot, "Solo se pueden fusionar piezas de la misma ranura")
	var slot := p_a.slot
	var child := Part.new()
	child.slot = slot
	child.rarity = clampi(maxi(p_a.rarity, p_b.rarity) + (1 if randf() < 0.35 else 0), 0, LEGENDARY)

	var ped := {
		"parent_a_name": p_a.name,
		"parent_b_name": p_b.name,
		"from_a": [],
		"from_b": [],
		"mutations": [],
	}

	# 1. FORMA: hereda de A o de B
	var shape_from_a := randf() < 0.5
	var shape_parent := p_a if shape_from_a else p_b
	child.texture = shape_parent.texture
	var shape_info := _find_shape_info(shape_parent)
	if shape_from_a:
		ped.from_a.append("Forma: %s" % shape_info.name)
	else:
		ped.from_b.append("Forma: %s" % shape_info.name)

	# 2. MATERIAL Y COLOR (Primario de uno, Secundario del otro para split visual)
	var mat_a := p_a.material if p_a.material >= 0 else randi() % MATERIALS.size()
	var mat_b := p_b.material if p_b.material >= 0 else randi() % MATERIALS.size()
	var mat_from_a := randf() < 0.5
	var primary_mat := mat_a if mat_from_a else mat_b
	var secondary_mat := mat_b if mat_from_a else mat_a

	# Mutación de color
	var mutated_color := false
	if randf() < MUTATION_CHANCE_COLOR:
		mutated_color = true
		var new_mat := randi() % MATERIALS.size()
		if randf() < 0.5:
			primary_mat = new_mat
		else:
			secondary_mat = new_mat
		ped.mutations.append("¡Color mutado a %s!" % MATERIALS[new_mat].name)

	child.material = primary_mat
	child.secondary_material = secondary_mat

	if not mutated_color:
		if mat_from_a:
			ped.from_a.append("Color principal: %s" % MATERIALS[primary_mat].name)
			if secondary_mat != primary_mat:
				ped.from_b.append("Color secundario: %s" % MATERIALS[secondary_mat].name)
		else:
			ped.from_b.append("Color principal: %s" % MATERIALS[primary_mat].name)
			if secondary_mat != primary_mat:
				ped.from_a.append("Color secundario: %s" % MATERIALS[secondary_mat].name)

	# 3. ACCESORIOS: combina de ambos padres sin duplicados
	var combined_acc: Array[Texture2D] = []
	for acc in p_a.accessories:
		if acc and acc not in combined_acc:
			combined_acc.append(acc)
			ped.from_a.append("Accesorio (%s)" % acc.resource_path.get_file().get_basename().replace("acc_%s_" % slot, ""))
	for acc in p_b.accessories:
		if acc and acc not in combined_acc:
			combined_acc.append(acc)
			ped.from_b.append("Accesorio (%s)" % acc.resource_path.get_file().get_basename().replace("acc_%s_" % slot, ""))

	# Mutación de accesorio
	if randf() < MUTATION_CHANCE_ACCESSORY or combined_acc.is_empty():
		var acc_names: Array = ACCESSORIES[slot]
		var candidate_name: String = acc_names.pick_random()
		var candidate_tex: Texture2D = load(ACC_PATH % [slot, candidate_name])
		if candidate_tex not in combined_acc:
			combined_acc.append(candidate_tex)
			ped.mutations.append("¡Accesorio mutado: %s!" % candidate_name)

	# Limitar accesorios al máximo permitido para la rareza hija
	var max_acc: int = MAX_ACCESSORIES[child.rarity]
	if combined_acc.size() > max_acc:
		combined_acc.shuffle()
		combined_acc = combined_acc.slice(0, max_acc)
	child.accessories = combined_acc

	# 4. EFECTOS: cruce de efectos de ambos padres
	var combined_effects: Array[String] = []
	for ef in p_a.effects:
		if ef not in combined_effects:
			combined_effects.append(ef)
			ped.from_a.append("Efecto: %s" % ef.capitalize())
	for ef in p_b.effects:
		if ef not in combined_effects:
			combined_effects.append(ef)
			ped.from_b.append("Efecto: %s" % ef.capitalize())

	# Mutación de efecto
	if randf() < MUTATION_CHANCE_EFFECT:
		var slot_effects: Array = EFFECTS[slot]
		if not slot_effects.is_empty():
			var mut_ef: Dictionary = slot_effects.pick_random()
			if mut_ef.id not in combined_effects:
				combined_effects.append(mut_ef.id)
				ped.mutations.append("¡Efecto mutado: %s!" % mut_ef.adj)

	# Limitar efectos según rareza hija
	var max_ef := maxi(MAX_EFFECTS[child.rarity], 1)
	if combined_effects.size() > max_ef:
		combined_effects.shuffle()
		combined_effects = combined_effects.slice(0, max_ef)
	child.effects = combined_effects

	# 5. STATS: toma el mejor de cada padre + 10% bono de fusión
	var all_stat_keys := {}
	for k in p_a.stats:
		all_stat_keys[k] = true
	for k in p_b.stats:
		all_stat_keys[k] = true

	var child_stats := {}
	for k: String in all_stat_keys:
		var val_a = float(p_a.stats.get(k, 0.0))
		var val_b = float(p_b.stats.get(k, 0.0))
		var is_better_lower := k in ["fire_rate"]
		var best_val := mini(val_a, val_b) if is_better_lower else maxi(val_a, val_b)
		var chosen: float = best_val
		if is_better_lower:
			chosen *= 0.92
		else:
			chosen = chosen * 1.1 + (1.0 if chosen == 0.0 else 0.0)
		if STAT_COST.has(k) and STAT_COST[k][0] is int:
			child_stats[k] = int(round(chosen))
		else:
			child_stats[k] = snappedf(chosen, 0.01)

	# Incorporar stats directos de efectos
	for ef_id in child.effects:
		var ef_info := _find_effect_info(slot, ef_id)
		if ef_info.has("scene"):
			child.scene = ef_info.scene
		for sk in ef_info.get("stats", {}):
			if not child_stats.has(sk):
				child_stats[sk] = ef_info.stats[sk]

	child.stats = child_stats

	# 6. NOMBRE Y DESCRIPCIÓN
	var mat_name_p: String = MATERIALS[child.material].name
	var mat_name_s: String = MATERIALS[child.secondary_material].name if child.secondary_material != child.material else ""
	var mat_title := mat_name_p if mat_name_s.is_empty() else "%s-%s" % [mat_name_p, mat_name_s]

	var first_effect_adj := ""
	if not child.effects.is_empty():
		var ef_info := _find_effect_info(slot, child.effects[0])
		first_effect_adj = ef_info.get("adj_f" if shape_info.fem else "adj", ef_info.get("adj", ""))

	child.name = "%s Quimera de %s" % [shape_info.name, mat_title]
	if not first_effect_adj.is_empty():
		child.name += " " + first_effect_adj

	var descs: Array[String] = []
	descs.append("Híbrido de %s y %s." % [p_a.name, p_b.name])
	for ef_id in child.effects:
		var ef_info := _find_effect_info(slot, ef_id)
		if ef_info.has("desc"):
			descs.append(ef_info.desc)
	if not ped.mutations.is_empty():
		descs.append(" ".join(ped.mutations))
	else:
		descs.append(MATERIALS[child.material].humor)

	child.description = " ".join(descs)
	child.pedigree = ped

	return child
