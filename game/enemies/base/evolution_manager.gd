class_name EvolutionManager extends RefCounted

# Gestiona el pool genético por especie de enemigo a través de las oleadas.
# Al final de cada oleada:
# - Se calcula la aptitud de los ejemplares (Fitness = daño hecho al jugador + tiempo sobrevivido).
# - Se seleccionan los más aptos (torneo o ruleta ponderada).
# - Se cruzan y mutan para producir la siguiente generación de genes.

const POOL_TARGET_SIZE := 20
const SURVIVOR_RATIO := 0.4 # Mejores 40% se preservan / usan como progenitores
const MUTATION_RATE := 0.35
const MUTATION_MAGNITUDE := 0.2

# Mapa de especie (resource_path del tscn) -> Array de EnemyGenes registrados durante la oleada
var _gene_history: Dictionary = {}
# Mapa de especie -> Array de EnemyGenes listos para la siguiente oleada
var _next_generation: Dictionary = {}

func clear_wave() -> void:
	_gene_history.clear()

func record_genes(species: String, genes: EnemyGenes) -> void:
	if not _gene_history.has(species):
		_gene_history[species] = []
	_gene_history[species].append(genes)

func get_next_genes(species: String) -> EnemyGenes:
	if _next_generation.has(species) and not _next_generation[species].is_empty():
		var pool: Array = _next_generation[species]
		var chosen: EnemyGenes = pool.pick_random()
		var g: EnemyGenes = chosen.clone()
		# Ligera variación individual
		g.mutate(0.2, 0.08)
		return g
	return EnemyGenes.random_genes()

func evolve_generation() -> void:
	# Ejecuta la selección natural, cruce y mutación entre oleadas
	for species in _gene_history.keys():
		var history: Array = _gene_history[species]
		if history.is_empty():
			continue
		
		# Ordenar de mayor a menor fitness
		history.sort_custom(func(a: EnemyGenes, b: EnemyGenes) -> bool:
			return a.get_fitness() > b.get_fitness()
		)
		
		var survivors_count := maxi(int(history.size() * SURVIVOR_RATIO), 2)
		var survivors: Array[EnemyGenes] = []
		for i in range(mini(survivors_count, history.size())):
			survivors.append(history[i])
		
		var new_pool: Array[EnemyGenes] = []
		
		# Elitismo: Mantener el gen más apto intacto
		new_pool.append(survivors[0].clone())
		
		# Generar el resto de descendientes por cruce y mutación
		while new_pool.size() < POOL_TARGET_SIZE:
			# Torneo de selección entre supervivientes
			var p1 := _select_parent(survivors)
			var p2 := _select_parent(survivors)
			var child := p1.crossover(p2)
			child.mutate(MUTATION_RATE, MUTATION_MAGNITUDE)
			# Reset de aptitud para la nueva oleada
			child.damage_dealt = 0
			child.time_survived = 0.0
			new_pool.append(child)
		
		_next_generation[species] = new_pool
	
	_gene_history.clear()

func _select_parent(survivors: Array[EnemyGenes]) -> EnemyGenes:
	if survivors.size() == 1:
		return survivors[0]
	var i1 := randi() % survivors.size()
	var i2 := randi() % survivors.size()
	if survivors[i1].get_fitness() >= survivors[i2].get_fitness():
		return survivors[i1]
	return survivors[i2]
