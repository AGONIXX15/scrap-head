class_name EnemyGenetics

# Genes:
# - speed: factor multiplicador de velocidad
# - hp: factor multiplicador de vida
# - size: factor multiplicador de tamaño (scale)
# - aggression: afecta cooldowns de ataque / tiempo de reacción
# - attack_type: tipo de ataque ("normal", "fast", "heavy", "burst")
# - color_hue: variación de tono/color visual (0.0 a 1.0)
# - accessory: textura de accesorio (o "")

const ACCESSORY_PATHS := [
	"",
	"res://game/parts/sprites/acc_head_antena.png",
	"res://game/parts/sprites/acc_head_cuernos.png",
	"res://game/parts/sprites/acc_head_pinchos.png",
	"res://game/parts/sprites/acc_head_tornillos.png",
	"res://game/parts/sprites/acc_head_cresta.png",
	"res://game/parts/sprites/acc_head_foco.png",
	"res://game/parts/sprites/acc_head_parche.png"
]

const ATTACK_TYPES := ["normal", "fast", "heavy", "burst"]

# Topes estrictos para que la dificultad no se dispare
const LIMITS := {
	"speed": {"min": 0.75, "max": 1.55},
	"hp": {"min": 0.8, "max": 2.2},
	"size": {"min": 0.85, "max": 1.45},
	"aggression": {"min": 0.7, "max": 1.6}, # menor cooldown o mayor frecuencia
}

# Probabilidades de mutación
const MUTATION_CHANCE := 0.30
const MUTATION_STEP := 0.15

static func create_default_genome(atk: String = "normal") -> Dictionary:
	return {
		"speed": 1.0,
		"hp": 1.0,
		"size": 1.0,
		"aggression": 1.0,
		"attack_type": atk,
		"color_hue": 0.0,
		"accessory": ""
	}

static func crossover(parent_a: Dictionary, parent_b: Dictionary) -> Dictionary:
	var child := {}
	# Cruce paramétrico con herencia de A o B para cada gen continuo
	for key in ["speed", "hp", "size", "aggression"]:
		# 50% de probabilidad de heredar del padre A o B con promedio sesgado
		var val_a: float = parent_a.get(key, 1.0)
		var val_b: float = parent_b.get(key, 1.0)
		var inherited: float = val_a if randf() < 0.5 else val_b
		# Ligera recombinación (media ponderada)
		var mixed: float = lerpf(inherited, (val_a + val_b) * 0.5, 0.3)
		child[key] = mixed

	# Tipo de ataque: hereda de uno de los dos padres
	child["attack_type"] = parent_a.get("attack_type", "normal") if randf() < 0.5 else parent_b.get("attack_type", "normal")
	
	# Color / Tono: interpolación o herencia
	child["color_hue"] = parent_a.get("color_hue", 0.0) if randf() < 0.5 else parent_b.get("color_hue", 0.0)
	
	# Accesorio: hereda de A o B
	child["accessory"] = parent_a.get("accessory", "") if randf() < 0.5 else parent_b.get("accessory", "")

	# Aplicar mutación
	return mutate(child)

static func mutate(genome: Dictionary) -> Dictionary:
	var mutated := genome.duplicate(true)

	for key in ["speed", "hp", "size", "aggression"]:
		if randf() < MUTATION_CHANCE:
			var delta := randf_range(-MUTATION_STEP, MUTATION_STEP)
			mutated[key] = mutated.get(key, 1.0) + delta

		# Aplicar límites / topes para evitar que la dificultad se dispare
		var bounds: Dictionary = LIMITS[key]
		mutated[key] = clampf(mutated[key], bounds.min, bounds.max)

	# Mutación en tipo de ataque (probabilidad moderada)
	if randf() < MUTATION_CHANCE * 0.7:
		mutated["attack_type"] = ATTACK_TYPES.pick_random()

	# Mutación de color
	if randf() < MUTATION_CHANCE:
		mutated["color_hue"] = fmod(mutated.get("color_hue", 0.0) + randf_range(0.15, 0.5), 1.0)

	# Mutación de accesorio
	if randf() < MUTATION_CHANCE:
		mutated["accessory"] = ACCESSORY_PATHS.pick_random()

	return mutated

# Genera un nuevo genoma hijo a partir de los mejores del pool evolutivo
static func select_and_breed(population: Array) -> Dictionary:
	if population.is_empty():
		return mutate(create_default_genome())
	if population.size() == 1:
		return mutate(population[0].genome)

	# Ordenar por aptitud (fitness descendente)
	population.sort_custom(func(a, b): return a.fitness > b.fitness)

	# Selección de los mejores (top 40%)
	var top_count := maxi(int(population.size() * 0.4), 2)
	top_count = mini(top_count, population.size())
	var top_candidates := population.slice(0, top_count)

	var p1 = top_candidates.pick_random().genome
	var p2 = top_candidates.pick_random().genome
	return crossover(p1, p2)
