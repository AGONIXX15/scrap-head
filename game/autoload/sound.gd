extends Node

const SFX_SHOOT := preload("res://game/audio/sfx/shoot.wav")
const SFX_HIT := preload("res://game/audio/sfx/hit.wav")
const SFX_EXPLODE := preload("res://game/audio/sfx/explode.wav")
const SFX_PICKUP := preload("res://game/audio/sfx/pickup.wav")
const SFX_EQUIP := preload("res://game/audio/sfx/equip.wav")

const POOL_SIZE := 12

var _players: Array[AudioStreamPlayer] = []
var _next_player := 0

var sfx_volume_db := -2.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.name = "SfxPlayer_%d" % i
		p.bus = "Master"
		add_child(p)
		_players.append(p)

func play_sfx(stream: AudioStream, volume_offset_db := 0.0, pitch_variance := 0.06) -> void:
	if not stream or _players.is_empty():
		return
	
	# Buscar un reproductor libre; si no, usar el siguiente en turno (round-robin)
	var player: AudioStreamPlayer = null
	for p in _players:
		if not p.playing:
			player = p
			break
	if not player:
		player = _players[_next_player]
		_next_player = (_next_player + 1) % POOL_SIZE

	player.stream = stream
	player.volume_db = sfx_volume_db + volume_offset_db
	player.pitch_scale = randf_range(1.0 - pitch_variance, 1.0 + pitch_variance) if pitch_variance > 0.0 else 1.0
	player.play()

func play_shoot() -> void:
	play_sfx(SFX_SHOOT, -4.0, 0.08)

func play_hit() -> void:
	play_sfx(SFX_HIT, -2.0, 0.1)

func play_explode() -> void:
	play_sfx(SFX_EXPLODE, 0.0, 0.07)

func play_pickup() -> void:
	play_sfx(SFX_PICKUP, -3.0, 0.05)

func play_equip() -> void:
	play_sfx(SFX_EQUIP, -1.0, 0.04)
