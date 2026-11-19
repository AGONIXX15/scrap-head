extends Node
# Efectos de sonido: Sfx.play("nombre", posición). Los .ogg viven en game/shared/audio/sfx/.
# Suena también en pausa (taller, menús); los efectos de juego son cortos y no molestan.

const DIR := "res://game/shared/audio/sfx/%s.ogg"
const MAX_VOICES := 4  # copias simultáneas de un mismo sonido
const PITCH_VAR := 0.08
const CHAIN_MS := 600  # bajas/recogidas más seguidas que esto suben de tono
const CHAIN_STEP := 0.06
const CHAIN_MAX := 1.4
# Volumen relativo (dB). La baja ("kill") es lo más fuerte: matar tiene que sentirse.
const VOLUME := {
	"kill": 0.0, "explosion": -6.0, "player_death": 0.0, "slam": -2.0, "player_hurt": -2.0, "defeat": -2.0,
	"equip": -4.0, "shield_block": -4.0, "wave_clear": -4.0, "wave_start": -6.0, "ui_click": -6.0,
	"bolt": -8.0, "charge": -8.0, "laser": -8.0, "rivet_shot": -8.0, "pickup": -10.0, "mine_place": -10.0,
	"enemy_hit": -12.0, "ricochet": -14.0, "spawn": -14.0, "beep": -16.0,
}

var _streams := {}
var _voices := {}
var _chain_ms := {}
var _chain_pitch := {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# Sin pos suena sin posición (UI). db se suma al volumen de la tabla.
func play(sound: String, pos := Vector2.INF, pitch := 1.0, db := 0.0, vary := PITCH_VAR) -> void:
	if _voices.get(sound, 0) >= MAX_VOICES:
		return
	if not _streams.has(sound):
		_streams[sound] = load(DIR % sound)
	if _streams[sound] == null:
		return  # sin archivo no hay finished: no contar la voz
	var p: Node = AudioStreamPlayer.new() if pos == Vector2.INF else AudioStreamPlayer2D.new()
	if pos != Vector2.INF:
		p.position = pos  # el padre no es Node2D: position es global
	p.bus = &"SFX"
	p.stream = _streams[sound]
	p.volume_db = VOLUME.get(sound, 0.0) + db
	p.pitch_scale = pitch * randf_range(1.0 - vary, 1.0 + vary)
	p.finished.connect(_done.bind(p, sound))
	_voices[sound] = _voices.get(sound, 0) + 1
	add_child(p)
	p.play()

# Como play, pero si se repite rápido sube de tono (racha de bajas, cascada de tornillos).
func chain(sound: String, pos: Vector2) -> void:
	var now := Time.get_ticks_msec()
	var up: bool = now - _chain_ms.get(sound, -CHAIN_MS) < CHAIN_MS
	_chain_pitch[sound] = minf(_chain_pitch.get(sound, 1.0) + CHAIN_STEP, CHAIN_MAX) if up else 1.0
	_chain_ms[sound] = now
	play(sound, pos, _chain_pitch[sound], 0.0, 0.02)

func _done(p: Node, sound: String) -> void:
	_voices[sound] -= 1
	p.queue_free()
