class_name Recicladora extends CharacterBody2D

signal decision_resolved(resolution_type: String)

enum BossPhase {
	COMBAT,        # Combate activo antes de sobrecalentarse
	OVERHEATING,   # Ventana de decisión (~20 s): disparar núcleo o mantener E en Inhibidor
	SECRET_THIRD   # Tercer camino (~45 s): aguantar aturdiendo con radio de Nora y enfriando 3 válvulas
}

const IMPACT := preload("res://game/fx/impact.tscn")
const EXPLOSION := preload("res://game/fx/explosion.tscn")
const DUST := preload("res://game/fx/dust.tscn")
const RIVET := preload("res://game/enemies/remachadora/remache.tscn")

# Stats y tiempos
@export var max_health := 60
var health := 60
var phase: BossPhase = BossPhase.COMBAT
var stun_timer := 0.0

# Mecánica de Sobrecalentamiento / Decisión
const OVERHEAT_TIME := 20.0
var overheat_timer := 20.0
const INHIBITOR_HOLD_TIME := 3.5 # Mantener E durante 3.5 segundos en el inhibidor
var inhibitor_held := 0.0
var inhibitor_player_inside := false

# Tercer camino (Nora)
const SECRET_TIME := 45.0
var secret_timer := 45.0
var antenna_broken := false
var valves_cooled := [false, false, false]
const VALVE_RELOAD_TIME := 12.0
var valve_cooldowns := [0.0, 0.0, 0.0]

# Ataques y combate
var _attack_timer := 2.5
var _slam_timer := 0.0
var _burst_count := 0
var _burst_gap := 0.15
var _burst_timer := 0.0
var _aim_angle := 0.0
var _resolved := false

# Referencias internas
var _player: Node2D

@onready var body_sprite: Sprite2D = $BodySprite
@onready var core: Area2D = $Core
@onready var core_light: PointLight2D = $Core/CoreLight
@onready var inhibitor: Area2D = $Inhibitor
@onready var antenna: Area2D = $Antenna
@onready var antenna_sprite: Sprite2D = $Antenna/AntennaSprite
@onready var antenna_light: PointLight2D = $Antenna/AntennaLight
@onready var valves: Node2D = $Valves
@onready var ui_canvas: CanvasLayer = $BossUI
@onready var boss_health_bar: ProgressBar = $BossUI/Margin/VBox/HealthBar
@onready var boss_name_label: Label = $BossUI/Margin/VBox/NameLabel
@onready var decision_box: VBoxContainer = $BossUI/DecisionBox
@onready var decision_timer_bar: ProgressBar = $BossUI/DecisionBox/TimerBar
@onready var decision_hint: Label = $BossUI/DecisionBox/HintLabel
@onready var secret_hint: Label = $BossUI/DecisionBox/SecretHint

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	_player = get_tree().get_first_node_in_group("player")
	health = max_health
	boss_health_bar.max_value = max_health
	boss_health_bar.value = health
	boss_name_label.text = "LA RECICLADORA (MÁQUINA GIGANTE)"
	
	decision_box.hide()
	secret_hint.hide()
	
	core.area_entered.connect(_on_core_hit)
	antenna.area_entered.connect(_on_antenna_hit)
	inhibitor.body_entered.connect(_on_inhibitor_body_entered)
	inhibitor.body_exited.connect(_on_inhibitor_body_exited)
	
	for i in range(3):
		var valve: Area2D = valves.get_child(i)
		valve.area_entered.connect(_on_valve_hit.bind(i))

func _physics_process(delta: float) -> void:
	if _resolved:
		return
	
	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")
		if not is_instance_valid(_player):
			return

	match phase:
		BossPhase.COMBAT:
			_process_combat(delta)
		BossPhase.OVERHEATING:
			_process_overheating(delta)
		BossPhase.SECRET_THIRD:
			_process_secret_third(delta)

func _process_combat(delta: float) -> void:
	# Ataques mientras la máquina gigante está activa
	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_attack_timer = randf_range(2.0, 3.5)
		if randf() < 0.5:
			_start_burst_attack()
		else:
			_start_slam_shockwave()

	if _burst_count > 0:
		_burst_timer -= delta
		if _burst_timer <= 0.0:
			_burst_timer = _burst_gap
			_burst_count -= 1
			_fire_rivet(_aim_angle + randf_range(-0.25, 0.25))

func _process_overheating(delta: float) -> void:
	# Barra de recalentamiento ~20 s
	overheat_timer -= delta
	decision_box.show()
	decision_timer_bar.max_value = OVERHEAT_TIME
	decision_timer_bar.value = overheat_timer
	decision_hint.text = "¡NÚCLEO SOBRECALENTADO! [%d s]\nDispara al Núcleo para DESTRUIR | Mantén [E] en el Inhibidor para LIBERAR" % ceili(overheat_timer)

	# Parpadeo de alarma en el núcleo
	var flash_rate := (1.0 - (overheat_timer / OVERHEAT_TIME)) * 15.0 + 3.0
	core_light.energy = 1.0 + sin(Time.get_ticks_msec() * 0.001 * flash_rate) * 0.8
	core_light.color = Color("FF394D")

	# Verificar interacción [E] en el inhibidor
	if inhibitor_player_inside and (Input.is_action_pressed("interact") or Input.is_key_pressed(KEY_E)):
		inhibitor_held += delta
		var progress := clampf(inhibitor_held / INHIBITOR_HOLD_TIME, 0.0, 1.0)
		decision_hint.text = "DESACTIVANDO INHIBIDOR: %d%%..." % int(progress * 100.0)
		if inhibitor_held >= INHIBITOR_HOLD_TIME:
			_resolve("liberar")
			return
	else:
		inhibitor_held = maxf(0.0, inhibitor_held - delta * 1.5)

	# Si se agota el tiempo sin decidir -> el núcleo revienta
	if overheat_timer <= 0.0:
		_resolve("reventar")

func _process_secret_third(delta: float) -> void:
	# Tercer camino: aguantar ~45 s mientras la radio de Nora transmite
	secret_timer -= delta
	decision_box.show()
	secret_hint.show()
	decision_timer_bar.max_value = SECRET_TIME
	decision_timer_bar.value = secret_timer
	
	var cooled_count := 0
	for c in valves_cooled:
		if c:
			cooled_count += 1

	decision_hint.text = "SEÑAL DE NORA RECUPERADA (Tiempo restante: %d s)\nVálvulas de refrigeración enfriadas: %d/3" % [ceili(secret_timer), cooled_count]
	secret_hint.text = "¡Los disparos a la máquina solo la aturden! Enfría las 3 válvulas antes de que se recarguen."

	# Cooldowns de las válvulas (se recargan / vuelven a calentarse si no se coordinan)
	for i in range(3):
		if valves_cooled[i]:
			valve_cooldowns[i] -= delta
			if valve_cooldowns[i] <= 0.0:
				valves_cooled[i] = false
				_update_valve_visual(i)

	# Si la máquina está aturdida, no ataca
	if stun_timer > 0.0:
		stun_timer -= delta
		body_sprite.modulate = Color(0.6, 0.8, 1.5) # Color aturdimiento
	else:
		body_sprite.modulate = Color.WHITE
		# Ataques defensivos automáticos cada pocos segundos
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = 3.0
			_fire_radial_rivets()

	# Condición de éxito del tercer camino: 3 válvulas frías simultáneas o resistir los 45s con al menos enfriamiento
	if cooled_count >= 3 or secret_timer <= 0.0:
		_resolve("tercer_camino_nora")

func _start_burst_attack() -> void:
	if not is_instance_valid(_player):
		return
	_aim_angle = global_position.direction_to(_player.global_position).angle()
	_burst_count = 6
	_burst_timer = 0.0
	Sfx.play("charge", global_position, 1.0)

func _start_slam_shockwave() -> void:
	Sfx.play("slam", global_position)
	Juice.shake(6.0)
	var d := DUST.instantiate()
	d.global_position = global_position
	get_parent().add_child(d)
	_fire_radial_rivets(8)

func _fire_rivet(angle: float) -> void:
	Sfx.play("rivet_shot", global_position)
	var s := RIVET.instantiate()
	s.direction = Vector2.from_angle(angle)
	s.global_position = global_position + s.direction * 36.0
	get_parent().add_child(s)

func _fire_radial_rivets(count := 12) -> void:
	Sfx.play("rivet_shot", global_position)
	for i in range(count):
		var angle := (TAU / float(count)) * i
		var s := RIVET.instantiate()
		s.direction = Vector2.from_angle(angle)
		s.global_position = global_position + s.direction * 40.0
		get_parent().add_child(s)

func hit(amount: int, from_dir := Vector2.ZERO) -> void:
	if _resolved:
		return

	if phase == BossPhase.SECRET_THIRD:
		# En el tercer camino, los disparos solo aturden a la Recicladora
		stun_timer = 2.5
		Sfx.play("enemy_hit", global_position)
		Juice.damage_number(global_position + Vector2(0, -30), amount)
		return

	health -= amount
	boss_health_bar.value = health
	Juice.damage_number(global_position + Vector2(0, -30), amount)
	Sfx.play("enemy_hit", global_position)
	
	# Si la vida cae al umbral crítico (~30% de vida o 0), entra a la fase de sobrecalentamiento/decisión
	if health <= max_health * 0.35 and phase == BossPhase.COMBAT:
		_trigger_overheat()

func _trigger_overheat() -> void:
	phase = BossPhase.OVERHEATING
	overheat_timer = OVERHEAT_TIME
	Sfx.play("defeat", global_position) # Sonido dramático de fallo mecánico
	Juice.shake(4.0)

func _on_core_hit(area: Area2D) -> void:
	if not _is_bullet(area):
		return
	if phase == BossPhase.OVERHEATING:
		# Disparar al núcleo durante sobrecalentamiento = Destruir
		_resolve("destruir")

func _on_antenna_hit(area: Area2D) -> void:
	if not _is_bullet(area):
		return
	if not antenna_broken and phase != BossPhase.SECRET_THIRD:
		# Romper la antena roja de la Recicladora devuelve la radio de Nora
		antenna_broken = true
		antenna_sprite.modulate = Color(0.2, 0.2, 0.2)
		antenna_light.hide()
		Sfx.play("explosion", antenna.global_position)
		var exp := EXPLOSION.instantiate()
		exp.global_position = antenna.global_position
		get_parent().add_child(exp)
		_trigger_secret_third_path()

func _trigger_secret_third_path() -> void:
	phase = BossPhase.SECRET_THIRD
	secret_timer = SECRET_TIME
	overheat_timer = 9999.0 # Cancelar explosión directa
	decision_box.show()
	secret_hint.show()
	Sfx.play("laser", global_position)
	Juice.shake(5.0)

func _on_valve_hit(area: Area2D, valve_idx: int) -> void:
	if not _is_bullet(area):
		return
	if phase == BossPhase.SECRET_THIRD:
		valves_cooled[valve_idx] = true
		valve_cooldowns[valve_idx] = VALVE_RELOAD_TIME
		_update_valve_visual(valve_idx)
		Sfx.play("shield_block", valves.get_child(valve_idx).global_position)

func _is_bullet(area: Area2D) -> bool:
	if area == null:
		return false
	if area.is_in_group("player_bullet"):
		return true
	if "pierce" in area or area.get_script() != null:
		return true
	return area.name.to_lower().contains("bullet")

func _update_valve_visual(idx: int) -> void:
	var valve: Node2D = valves.get_child(idx)
	var light_node: PointLight2D = valve.get_node_or_null("ValveLight")
	if light_node:
		if valves_cooled[idx]:
			light_node.color = Color("36D9FF") # Azul frío
			light_node.energy = 1.2
		else:
			light_node.color = Color("FF8A36") # Naranja caliente
			light_node.energy = 0.6

func _on_inhibitor_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		inhibitor_player_inside = true

func _on_inhibitor_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		inhibitor_player_inside = false
		inhibitor_held = 0.0

func _resolve(resolution_type: String) -> void:
	if _resolved:
		return
	_resolved = true
	set_physics_process(false)
	decision_box.hide()
	ui_canvas.hide()
	
	decision_resolved.emit(resolution_type)
	
	match resolution_type:
		"destruir":
			# Explosión completa y destrucción
			Sfx.play("explosion", global_position)
			Juice.shake(10.0)
			for i in range(5):
				var exp := EXPLOSION.instantiate()
				exp.global_position = global_position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
				get_parent().add_child.call_deferred(exp)
			queue_free()
		"liberar":
			# Desactivación pacífica del inhibidor
			Sfx.play("wave_clear", global_position)
			body_sprite.modulate = Color(0.4, 1.2, 0.6)
			core_light.color = Color("36D9FF")
		"reventar":
			# El núcleo revienta por falta de decisión
			Sfx.play("explosion", global_position)
			Juice.shake(12.0)
			if is_instance_valid(_player):
				_player.take_damage(2) # Daño residual de la explosión al jugador
			queue_free()
		"tercer_camino_nora":
			# Se enfría el núcleo y se salva la radio de Nora
			Sfx.play("wave_clear", global_position)
			Sfx.play("charge", global_position)
			body_sprite.modulate = Color(0.3, 0.9, 1.4)
			core_light.color = Color("B66CFF")
