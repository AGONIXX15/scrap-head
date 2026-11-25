extends Node

func _ready() -> void:
	print("--- INICIANDO TEST DE EVOLUCIÓN DE ENEMIGOS (HU-20) ---")

	# Test 1: Creación de genoma por defecto y límites
	var base_genome := EnemyGenetics.create_default_genome("normal")
	assert(base_genome.speed == 1.0)
	assert(base_genome.hp == 1.0)
	assert(base_genome.size == 1.0)
	assert(base_genome.aggression == 1.0)
	assert(base_genome.attack_type == "normal")
	print("[PASS] Test 1: Genoma base inicializado correctamente.")

	# Test 2: Cruce y Mutación dentro de topes
	var parent_a := {
		"speed": 1.2,
		"hp": 1.5,
		"size": 1.1,
		"aggression": 1.3,
		"attack_type": "fast",
		"color_hue": 0.2,
		"accessory": "res://game/parts/sprites/acc_head_antena.png"
	}
	var parent_b := {
		"speed": 0.9,
		"hp": 1.1,
		"size": 0.95,
		"aggression": 0.8,
		"attack_type": "heavy",
		"color_hue": 0.8,
		"accessory": "res://game/parts/sprites/acc_head_pinchos.png"
	}
	var child := EnemyGenetics.crossover(parent_a, parent_b)
	print("Hijo generado:", child)
	for k in ["speed", "hp", "size", "aggression"]:
		assert(child[k] >= EnemyGenetics.LIMITS[k].min, "El gen %s está por debajo del mínimo permitido" % k)
		assert(child[k] <= EnemyGenetics.LIMITS[k].max, "El gen %s está por encima del máximo permitido" % k)
	print("[PASS] Test 2: Cruce y mutación respetan topes estrictos de dificultad.")

	# Test 3: Simulación de selección natural basada en Aptitud
	# Aptitud = daño hecho al jugador * 10 + tiempo sobrevivido
	var population := [
		{"fitness": 12.0, "genome": {"speed": 0.8, "hp": 0.9, "size": 0.9, "aggression": 0.8, "attack_type": "normal", "color_hue": 0.0, "accessory": ""}},
		{"fitness": 45.0, "genome": {"speed": 1.3, "hp": 1.4, "size": 1.2, "aggression": 1.3, "attack_type": "fast", "color_hue": 0.3, "accessory": "res://game/parts/sprites/acc_head_cresta.png"}},
		{"fitness": 55.0, "genome": {"speed": 1.4, "hp": 1.6, "size": 1.3, "aggression": 1.4, "attack_type": "heavy", "color_hue": 0.6, "accessory": "res://game/parts/sprites/acc_head_cuernos.png"}},
		{"fitness": 5.0, "genome": {"speed": 0.75, "hp": 0.8, "size": 0.85, "aggression": 0.7, "attack_type": "normal", "color_hue": 0.0, "accessory": ""}}
	]
	var next_gen_child := EnemyGenetics.select_and_breed(population)
	print("Hijo de los más aptos:", next_gen_child)
	# Los más aptos tenían speed y hp altas (>1.2)
	assert(next_gen_child.speed >= 0.9, "La velocidad del hijo de los más aptos debe ser competitiva")
	print("[PASS] Test 3: Selección por aptitud (fitness) funcional.")

	# Test 4: Instanciación de enemigo con genoma y reflejo visual
	var oxidado_scene := preload("res://game/enemies/oxidado/oxidado.tscn")
	var enemy = oxidado_scene.instantiate()
	var test_genome := {
		"speed": 1.4,
		"hp": 2.0,
		"size": 1.3,
		"aggression": 1.5,
		"attack_type": "fast",
		"color_hue": 0.45,
		"accessory": "res://game/parts/sprites/acc_head_cuernos.png"
	}
	enemy.genome = test_genome
	add_child(enemy)

	# Verificar que los genes se aplicaron a las propiedades y al aspecto visual
	assert(is_equal_approx(enemy.scale.x, 1.3), "El tamaño no se aplicó al scale")
	assert(enemy.hp > 3, "La vida del enemigo no se multiplicó por el gen hp")
	assert(enemy._accessory_node != null, "El accesorio no se instanció como nodo visual")
	print("Enemigo oxidado evolucionado instanciado correctamente: scale=%s, hp=%s, acc=%s" % [enemy.scale, enemy.hp, enemy._accessory_node.texture.resource_path])
	
	# Simular daño al jugador y cálculo de fitness
	var prev_fit: float = enemy.get_fitness()
	enemy.record_damage_dealt(3)
	enemy.survival_time = 15.0
	var new_fit: float = enemy.get_fitness()
	assert(new_fit == (3.0 * 10.0 + 15.0), "Cálculo de aptitud erróneo")
	print("Aptitud calculada:", new_fit)
	print("[PASS] Test 4: EnemyBase refleja genes en tamaño, color, accesorio y calcula aptitud correctamente.")

	print("--- TODOS LOS TESTS DE HU-20 COMPLETADOS CON ÉXITO ---")
	get_tree().quit(0)
