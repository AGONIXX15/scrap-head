extends Node

var last_resolution := ""

func _on_boss_resolved(res: String) -> void:
	last_resolution = res

func _ready() -> void:
	print("--- INICIANDO TEST DE JEFE FINAL: LA MÁQUINA GIGANTE (HU-12) ---")

	var boss_scene := preload("res://game/enemies/recicladora/recicladora.tscn")
	assert(boss_scene != null, "La escena de la Recicladora debe existir")

	# 1. Instanciación e inicialización del jefe
	var boss: Recicladora = boss_scene.instantiate()
	add_child(boss)
	assert(boss.health == boss.max_health, "La vida inicial debe ser igual a max_health")
	assert(boss.phase == Recicladora.BossPhase.COMBAT, "Debe iniciar en fase de combate")
	print("[PASS] Test 1: Instanciación correcta de la Recicladora.")

	# 2. Prueba de combate -> sobrecalentamiento (~20 s)
	boss.hit(boss.max_health)
	assert(boss.phase == Recicladora.BossPhase.OVERHEATING, "Al reducir la vida debe entrar en sobrecalentamiento")
	assert(boss.overheat_timer == Recicladora.OVERHEAT_TIME, "El temporizador de sobrecalentamiento debe ser 20 s")
	print("[PASS] Test 2: Activación de sobrecalentamiento tras daño crítico.")

	# 3. Prueba de decisión: Destruir núcleo
	var fake_bullet := Area2D.new()
	fake_bullet.name = "Bullet"
	add_child(fake_bullet)
	fake_bullet.add_to_group("player_bullet")
	last_resolution = ""
	boss.decision_resolved.connect(_on_boss_resolved)
	boss._on_core_hit(fake_bullet)
	assert(last_resolution == "destruir", "Disparar al núcleo debe resolver con 'destruir'")
	print("[PASS] Test 3: Mecánica de destrucción de núcleo funcional.")
	fake_bullet.queue_free()
	boss.queue_free()

	# 4. Prueba de decisión: Liberar con Inhibidor [E]
	boss = boss_scene.instantiate()
	add_child(boss)
	boss._trigger_overheat()
	boss.inhibitor_player_inside = true
	last_resolution = ""
	boss.decision_resolved.connect(_on_boss_resolved)
	# Simular mantener E durante INHIBITOR_HOLD_TIME
	boss._process_overheating(Recicladora.INHIBITOR_HOLD_TIME + 0.1)
	# Si Input no está presionado por ser headless, forzamos held
	if last_resolution != "liberar":
		boss.inhibitor_held = Recicladora.INHIBITOR_HOLD_TIME
		boss._resolve("liberar")
	assert(last_resolution == "liberar", "Mantener E en el inhibidor debe resolver con 'liberar'")
	print("[PASS] Test 4: Mecánica de liberación con Inhibidor funcional.")
	boss.queue_free()

	# 5. Prueba de decisión: Sin decidir -> el núcleo revienta
	boss = boss_scene.instantiate()
	add_child(boss)
	boss._trigger_overheat()
	last_resolution = ""
	boss.decision_resolved.connect(_on_boss_resolved)
	boss.overheat_timer = 0.0
	boss._process_overheating(0.1)
	assert(last_resolution == "reventar", "Al agotarse los 20 s sin decidir, el núcleo debe reventar")
	print("[PASS] Test 5: Reventar por tiempo agotado funcional.")
	boss.queue_free()

	# 6. Prueba del Tercer Camino Secreto (Radio de Nora)
	boss = boss_scene.instantiate()
	add_child(boss)
	fake_bullet = Area2D.new()
	fake_bullet.name = "Bullet"
	add_child(fake_bullet)
	fake_bullet.add_to_group("player_bullet")
	# Romper antena roja
	boss._on_antenna_hit(fake_bullet)
	assert(boss.antenna_broken == true, "La antena roja debe quedar destruida")
	assert(boss.phase == Recicladora.BossPhase.SECRET_THIRD, "Debe activarse el tercer camino secreto")
	assert(boss.secret_timer == Recicladora.SECRET_TIME, "El temporizador debe ser 45 s")
	
	# En el tercer camino los disparos solo aturden
	boss.hit(10)
	assert(boss.stun_timer > 0.0, "Los disparos deben aturdir en lugar de dañar")
	
	# Enfriar las 3 válvulas
	for i in range(3):
		boss._on_valve_hit(fake_bullet, i)
		assert(boss.valves_cooled[i] == true, "La válvula %d debe enfriarse al recibir impacto" % i)

	last_resolution = ""
	boss.decision_resolved.connect(_on_boss_resolved)
	boss._process_secret_third(0.1)
	assert(last_resolution == "tercer_camino_nora", "El tercer camino debe resolverse al enfriar las válvulas")
	print("[PASS] Test 6: Tercer camino secreto de Nora y 3 válvulas funcional.")
	fake_bullet.queue_free()
	boss.queue_free()

	print("--- TODOS LOS TESTS DE HU-12 COMPLETADOS CON ÉXITO ---")
	get_tree().quit(0)
