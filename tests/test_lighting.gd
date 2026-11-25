extends Node

func _ready() -> void:
	print("--- INICIANDO VERIFICACIÓN DE ILUMINACIÓN SCI-FI (HU-14) ---")

	# 1. Instanciar escena principal de la arena
	var main_scene := preload("res://game/level/main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	print("[PASS] Escena principal 'main.tscn' instanciada correctamente.")

	# 2. Verificar WorldEnvironment y CanvasModulate
	var env_node = main.get_node_or_null("WorldEnvironment")
	assert(env_node != null, "WorldEnvironment no encontrado")
	assert(env_node.environment.glow_enabled == true, "Glow/Bloom debe estar habilitado")
	print("[PASS] WorldEnvironment configurado con Glow y Bloom.")

	var ambient_mod = main.get_node_or_null("Ambient") as CanvasModulate
	assert(ambient_mod != null, "CanvasModulate no encontrado")
	print("Color ambiental petróleo/gris-azulado:", ambient_mod.color)
	assert(ambient_mod.color.v < 0.85 and ambient_mod.color.v > 0.35, "Luz ambiental fuera del rango estético deseado")
	print("[PASS] Luz ambiental azul petróleo y gris azulada verificada.")

	# 3. Verificar iluminación del Jugador
	var player = main.get_node_or_null("Player")
	assert(player != null, "Player no encontrado en la arena")
	assert(player.player_light != null, "Luz del jugador (PlayerLight) no encontrada")
	assert(player.core_light != null, "Luz de núcleo del jugador (CoreLight) no encontrada")
	print("Luz de jugador configurada:", player.player_light.color, "Energy:", player.player_light.energy)
	assert(player.player_light.color == Color("36D9FF"), "Color inicial debe ser Cian (#36D9FF)")

	# 4. Verificar adaptación de la iluminación del jugador a piezas
	var fire_part := PartGenerator.make(Part.ARM, 0, 1)
	fire_part.effects.append("igneo")
	player.equip(fire_part)
	print("Luz de jugador tras equipar pieza ígnea:", player.player_light.color)
	assert(player.player_light.color.r > 0.25, "El color de la luz del jugador debe adaptarse a la pieza")
	print("[PASS] Iluminación adaptativa del jugador funcional.")

	# 5. Verificar luces de proyectiles
	var bullet_scene := preload("res://game/weapons/bullet/bullet.tscn")
	var bullet = bullet_scene.instantiate()
	add_child(bullet)
	var bullet_light = bullet.get_node_or_null("Light")
	assert(bullet_light != null, "La bala debe tener una PointLight2D suave")
	print("Luz de proyectil:", bullet_light.color)
	assert(bullet_light.color == Color("36D9FF"), "Proyectil estándar debe emitir luz Cian")
	print("[PASS] Iluminación dinámica de proyectiles verificada.")

	# 6. Verificar explosión e impacto con luz
	var exp_scene := preload("res://game/fx/explosion.tscn")
	var exp = exp_scene.instantiate()
	add_child(exp)
	var exp_light = exp.get_node_or_null("Light")
	assert(exp_light != null, "La explosión debe emitir luz dinámica de fuego/naranja")
	print("Luz de explosión:", exp_light.color)
	assert(exp_light.color == Color(1.0, 0.54, 0.21, 1), "Explosión debe tener tono naranja (#FF8A36)")
	print("[PASS] Iluminación de efectos de combate verificada.")

	# 7. Verificar luces en enemigos
	var riveter_scene := preload("res://game/enemies/remachadora/remachadora.tscn")
	var riveter = riveter_scene.instantiate()
	add_child(riveter)
	var riv_light = riveter.get_node_or_null("Sprite/Barrel/BarrelLight")
	assert(riv_light != null, "La remachadora debe tener luz roja en el cañón")
	assert(riv_light.color == Color(1.0, 0.22, 0.3, 1), "Color rojo (#FF394D)")
	print("[PASS] Iluminación de enemigos verificada.")

	print("--- TODOS LOS TESTS DE ILUMINACIÓN COMPLETADOS EXITOSAMENTE ---")
	get_tree().quit(0)
