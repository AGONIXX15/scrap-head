extends Node

func _ready() -> void:
	print("--- INICIANDO TESTS DE HU-20 ---")
	test_genes_initialization_and_clamping()
	test_fitness_calculation()
	test_crossover_and_mutation()
	test_evolution_manager()
	test_enemy_instantiation_with_genes()
	test_enemy_visual_accessories()
	print("--- TODOS LOS TESTS PASARON EXITOSAMENTE ---")
	get_tree().quit(0)

func test_genes_initialization_and_clamping() -> void:
	print("Testing EnemyGenes init and clamping...")
	var g := EnemyGenes.new(2.5, 0.2, 0.5, 3.0, EnemyGenes.AttackType.HEAVY)
	assert(is_equal_approx(g.speed, EnemyGenes.SPEED_MAX), "Speed should be clamped to max")
	assert(is_equal_approx(g.health, EnemyGenes.HEALTH_MIN), "Health should be clamped to min")
	assert(is_equal_approx(g.size, EnemyGenes.SIZE_MIN), "Size should be clamped to min")
	assert(is_equal_approx(g.aggression, EnemyGenes.AGGRESSION_MAX), "Aggression should be clamped to max")
	assert(g.attack_type == EnemyGenes.AttackType.HEAVY, "AttackType should be HEAVY")
	print("  EnemyGenes clamping OK")

func test_fitness_calculation() -> void:
	print("Testing fitness formula...")
	var g := EnemyGenes.new()
	g.damage_dealt = 3
	g.time_survived = 12.5
	# Fitness = daño hecho al jugador (x10) + tiempo sobrevivido
	var expected := 3.0 * 10.0 + 12.5
	assert(is_equal_approx(g.get_fitness(), expected), "Fitness calculation incorrect")
	print("  Fitness calculation OK")

func test_crossover_and_mutation() -> void:
	print("Testing crossover and mutation...")
	var parent_a := EnemyGenes.new(0.8, 0.9, 0.9, 0.8, EnemyGenes.AttackType.RAPID)
	var parent_b := EnemyGenes.new(1.4, 1.5, 1.3, 1.4, EnemyGenes.AttackType.HEAVY)
	
	var child := parent_a.crossover(parent_b)
	assert(child.speed == parent_a.speed or child.speed == parent_b.speed, "Child speed from parents")
	assert(child.health == parent_a.health or child.health == parent_b.health, "Child health from parents")
	assert(child.attack_type == parent_a.attack_type or child.attack_type == parent_b.attack_type, "Child attack_type from parents")
	
	for i in range(100):
		child.mutate(1.0, 0.5)
		assert(child.speed >= EnemyGenes.SPEED_MIN and child.speed <= EnemyGenes.SPEED_MAX, "Mutated speed in bounds")
		assert(child.health >= EnemyGenes.HEALTH_MIN and child.health <= EnemyGenes.HEALTH_MAX, "Mutated health in bounds")
		assert(child.size >= EnemyGenes.SIZE_MIN and child.size <= EnemyGenes.SIZE_MAX, "Mutated size in bounds")
		assert(child.aggression >= EnemyGenes.AGGRESSION_MIN and child.aggression <= EnemyGenes.AGGRESSION_MAX, "Mutated aggression in bounds")
	print("  Crossover and mutation clamping OK")

func test_evolution_manager() -> void:
	print("Testing EvolutionManager...")
	var evo := EvolutionManager.new()
	var species := "res://game/enemies/oxidado/oxidado.tscn"
	
	for i in range(10):
		var g := EnemyGenes.new()
		g.damage_dealt = i
		g.time_survived = float(i * 2)
		evo.record_genes(species, g)
	
	evo.evolve_generation()
	
	var next_genes := evo.get_next_genes(species)
	assert(next_genes != null, "Next generation genes should be available")
	assert(next_genes.speed >= EnemyGenes.SPEED_MIN and next_genes.speed <= EnemyGenes.SPEED_MAX, "Next genes within bounds")
	print("  EvolutionManager generation & selection OK")

func test_enemy_instantiation_with_genes() -> void:
	print("Testing enemy node instantiation with genes...")
	var oxidado_scene: PackedScene = load("res://game/enemies/oxidado/oxidado.tscn")
	var enemy: EnemyBase = oxidado_scene.instantiate()
	var g := EnemyGenes.new(1.2, 1.3, 1.1, 1.4, EnemyGenes.AttackType.HEAVY)
	enemy.genes = g
	add_child(enemy)
	
	assert(enemy.genes == g, "Enemy has assigned genes")
	assert(is_equal_approx(enemy.scale.x, 1.1), "Enemy scale reflects gene size")
	
	enemy.record_player_damage(2)
	assert(enemy.genes.damage_dealt == 2, "Recorded damage to player")
	
	enemy.queue_free()
	print("  Enemy node instantiation and gene application OK")

func test_enemy_visual_accessories() -> void:
	print("Testing visual accessory creation...")
	var chispa_scene: PackedScene = load("res://game/enemies/chispa/chispa.tscn")
	var enemy: EnemyBase = chispa_scene.instantiate()
	var g := EnemyGenes.new(1.4, 1.5, 1.2, 1.4, EnemyGenes.AttackType.RAPID)
	enemy.genes = g
	add_child(enemy)
	
	assert(enemy.scale.x > 1.0, "Scale increased by size gene")
	assert(enemy.get_node_or_null("@Node2D@*") != null or enemy.find_children("", "Node2D").size() > 0, "Accessory node added")
	
	enemy.queue_free()
	print("  Visual accessories OK")
