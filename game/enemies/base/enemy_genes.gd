class_name EnemyGenes extends RefCounted

# Rango y topes de los genes para que la dificultad no se dispare
const SPEED_MIN := 0.7
const SPEED_MAX := 1.5

const HEALTH_MIN := 0.7
const HEALTH_MAX := 1.6

const SIZE_MIN := 0.8
const SIZE_MAX := 1.4

const AGGRESSION_MIN := 0.7
const AGGRESSION_MAX := 1.5

# Tipos de ataque
enum AttackType {
	NORMAL = 0,    # Ataque estándar de la unidad
	RAPID = 1,     # Más frecuente / menor cooldown o windup
	HEAVY = 2,     # Mayor daño y radio / impacto contundente
}

var speed: float = 1.0        # Multiplicador de velocidad [0.7 - 1.5]
var health: float = 1.0       # Multiplicador de vida [0.7 - 1.6]
var size: float = 1.0         # Multiplicador de tamaño/escala [0.8 - 1.4]
var aggression: float = 1.0   # Afecta rangos de ataque, reacción y agresividad [0.7 - 1.5]
var attack_type: int = AttackType.NORMAL

# Estadísticas de aptitud (Fitness = daño hecho al jugador + tiempo sobrevivido)
var damage_dealt: int = 0
var time_survived: float = 0.0

func _init(p_speed := 1.0, p_health := 1.0, p_size := 1.0, p_aggression := 1.0, p_attack_type := AttackType.NORMAL) -> void:
	speed = clampf(p_speed, SPEED_MIN, SPEED_MAX)
	health = clampf(p_health, HEALTH_MIN, HEALTH_MAX)
	size = clampf(p_size, SIZE_MIN, SIZE_MAX)
	aggression = clampf(p_aggression, AGGRESSION_MIN, AGGRESSION_MAX)
	attack_type = p_attack_type

func get_fitness() -> float:
	# Aptitud = daño hecho al jugador + tiempo sobrevivido
	# El daño al jugador es el objetivo primario (pesado), tiempo sobrevivido premia resistencia
	return float(damage_dealt * 10) + time_survived

func clone() -> EnemyGenes:
	var copy := EnemyGenes.new(speed, health, size, aggression, attack_type)
	return copy

# Cruce con otro genotipo
func crossover(partner: EnemyGenes) -> EnemyGenes:
	var child := EnemyGenes.new()
	child.speed = speed if randf() < 0.5 else partner.speed
	child.health = health if randf() < 0.5 else partner.health
	child.size = size if randf() < 0.5 else partner.size
	child.aggression = aggression if randf() < 0.5 else partner.aggression
	child.attack_type = attack_type if randf() < 0.5 else partner.attack_type
	return child

# Mutación con topes
func mutate(rate := 0.25, magnitude := 0.15) -> void:
	if randf() < rate:
		speed = clampf(speed + randf_range(-magnitude, magnitude), SPEED_MIN, SPEED_MAX)
	if randf() < rate:
		health = clampf(health + randf_range(-magnitude, magnitude), HEALTH_MIN, HEALTH_MAX)
	if randf() < rate:
		size = clampf(size + randf_range(-magnitude, magnitude), SIZE_MIN, SIZE_MAX)
	if randf() < rate:
		aggression = clampf(aggression + randf_range(-magnitude, magnitude), AGGRESSION_MIN, AGGRESSION_MAX)
	if randf() < (rate * 0.6): # Mutación de tipo de ataque menos frecuente
		var types := [AttackType.NORMAL, AttackType.RAPID, AttackType.HEAVY]
		attack_type = types.pick_random()

static func random_genes() -> EnemyGenes:
	var g := EnemyGenes.new(
		randf_range(0.85, 1.15),
		randf_range(0.85, 1.15),
		randf_range(0.9, 1.1),
		randf_range(0.85, 1.15),
		AttackType.NORMAL
	)
	return g
