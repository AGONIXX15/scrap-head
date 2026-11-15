extends Node

const SFX_SHOOT := preload("res://game/audio/sfx/shoot.wav")
const SFX_HIT := preload("res://game/audio/sfx/hit.wav")
const SFX_EXPLODE := preload("res://game/audio/sfx/explode.wav")
const SFX_PICKUP := preload("res://game/audio/sfx/pickup.wav")
const SFX_EQUIP := preload("res://game/audio/sfx/equip.wav")
var music_battle: AudioStream = preload("res://game/audio/music/battle.wav")

const POOL_SIZE := 12

var _players: Array[AudioStreamPlayer] = []
var _next_player := 0
var _music_player: AudioStreamPlayer

var sfx_volume_db := -2.0
var music_volume_db := -8.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Pool para efectos de sonido (SFX)
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.name = "SfxPlayer_%d" % i
		p.bus = "Master"
		add_child(p)
		_players.append(p)

	# Reproductor dedicado para música de fondo
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	_music_player.bus = "Master"
	add_child(_music_player)

	# Habilitar bucle (loop) en la música
	if music_battle is AudioStreamWAV:
		(music_battle as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD

func play_sfx(stream: AudioStream, volume_offset_db := 0.0, pitch_variance := 0.06) -> void:
	if not stream or _players.is_empty():
		return
	
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

func play_music(stream: AudioStream = null, volume_db: float = 0.0) -> void:
	if stream == null:
		stream = music_battle
	if stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.volume_db = music_volume_db + volume_db
	_music_player.play()

func stop_music() -> void:
	if _music_player:
		_music_player.stop()

func fade_music_out(duration := 0.5) -> void:
	if not _music_player or not _music_player.playing:
		return
	var tw := create_tween()
	tw.tween_property(_music_player, "volume_db", -60.0, duration)
	tw.tween_callback(_music_player.stop)
