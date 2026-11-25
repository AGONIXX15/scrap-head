extends Node

func _ready() -> void:
	print("--- EJECUTANDO SUITE DE TESTS FUSIÓN Y TALLER ---")
	
	# 1. Test básico de cruce
	var p_a := PartGenerator.make(Part.HEAD, 0, 1)
	var p_b := PartGenerator.make(Part.HEAD, 1, 1)
	print("Padre A: ", p_a.name)
	print("Padre B: ", p_b.name)
	
	var child := PartGenerator.fuse(p_a, p_b)
	print("Hija generada: ", child.name)
	print("  Material primario: ", child.material, " | secundario: ", child.secondary_material)
	print("  Pedigree: ", child.pedigree)
	
	assert(child.slot == Part.HEAD, "El slot debe ser HEAD")
	assert(child.pedigree.has("parent_a_name") and child.pedigree.has("parent_b_name"), "Pedigree incompleto")
	print("[PASS] Cruce genético correcto.")

	# 2. Test de Shader split
	var mat := PartGenerator.material_for(child, float(child.frames()))
	assert(mat != null, "ShaderMaterial no generado")
	print("[PASS] Shader split material correcto.")
	
	# 3. Test de mutaciones
	var mutations := 0
	for i in 60:
		var slot = [Part.HEAD, Part.ARM, Part.LEGS, Part.BACK].pick_random()
		var parent1 := PartGenerator.make(slot, randi() % 3, 2)
		var parent2 := PartGenerator.make(slot, randi() % 3, 2)
		var c := PartGenerator.fuse(parent1, parent2)
		if not c.pedigree.mutations.is_empty():
			mutations += 1
	print("Mutaciones en 60 casos: ", mutations)
	assert(mutations > 0, "No ocurrieron mutaciones")
	print("[PASS] Probabilidad de mutación verificada.")
	
	# 4. Test de escena Workshop
	var workshop_scene := preload("res://game/workshop/workshop.tscn")
	var workshop = workshop_scene.instantiate()
	var player_scene := preload("res://game/player/player.tscn")
	var dummy_player = player_scene.instantiate()
	add_child(dummy_player)
	workshop.player = dummy_player
	workshop.wave = 2
	add_child(workshop)
	
	assert(workshop._fusion_mode == false, "Modo inicial incorrecto")
	workshop._toggle_fusion_mode()
	assert(workshop._fusion_mode == true, "No cambió a modo fusión")
	assert(workshop._fusion_candidates.size() >= 2, "Candidatos insuficientes")
	print("Candidatos en taller: ", workshop._fusion_candidates.size())
	
	print("[PASS] Integración con escena Taller correcta.")
	print("--- TODOS LOS TESTS COMPLETADOS SATISFACTORIAMENTE ---")
	get_tree().quit(0)
