extends Node

const SFX_SHOOT := preload("res://game/audio/sfx/shoot.wav")
const SFX_HIT := preload("res://game/audio/sfx/hit.wav")
const SFX_EXPLODE := preload("res://game/audio/sfx/explode.wav")
const SFX_PICKUP := preload("res://game/audio/sfx/pickup.wav")
const SFX_EQUIP := preload("res://game/audio/sfx/equip.wav")
var music_battle: AudioStream = preload("res://game/audio/music/cubedcanada+invaderloop.mp3")

const POOL_SIZE := 12

var _players: Array[AudioStreamPlayer] = []
var _next_player := 0
var _music_player: AudioStreamPlayer
var _fade_tween: Tween

var sfx_volume_db := -2.0
var music_volume_db := -4.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_buses()
	_init_players()

func _setup_buses() -> void:
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus()
		var music_idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_idx, "Music")
		AudioServer.set_bus_send(music_idx, "Master")
	
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		var sfx_idx := AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_idx, "SFX")
		AudioServer.set_bus_send(sfx_idx, "Master")

func _init_players() -> void:
	_setup_buses()
	if _players.is_empty():
		for i in POOL_SIZE:
			var p := AudioStreamPlayer.new()
			p.name = "SfxPlayer_%d" % i
			p.bus = "SFX"
			add_child(p)
			_players.append(p)

	if not _music_player:
		_music_player = AudioStreamPlayer.new()
		_music_player.name = "MusicPlayer"
		_music_player.bus = "Music"
		add_child(_music_player)
		_music_player.finished.connect(_on_music_finished)

func _on_music_finished() -> void:
	if _music_player and _music_player.stream:
		_music_player.play()

## Reproduce un sonido según su nombre (HU-15)
func play(nombre: String, volume_offset_db := 0.0, pitch_variance := 0.06) -> void:
	match nombre.to_lower():
		"shoot", "disparo":
			play_shoot()
		"hit", "golpe":
			play_hit()
		"explode", "explosion", "explosión":
			play_explode()
		"pickup", "recoger":
			play_pickup()
		"equip", "equipar":
			play_equip()
		"music", "musica", "música", "battle":
			play_music(null, volume_offset_db)
		_:
			push_warning("Sound: Sonido desconocido '%s'" % nombre)

func play_sfx(stream: AudioStream, volume_offset_db := 0.0, pitch_variance := 0.06) -> void:
	_init_players()
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
	play_sfx(SFX_SHOOT, -3.0, 0.08)

func play_hit() -> void:
	play_sfx(SFX_HIT, -1.0, 0.1)

func play_explode() -> void:
	play_sfx(SFX_EXPLODE, 0.0, 0.07)

func play_pickup() -> void:
	play_sfx(SFX_PICKUP, -2.0, 0.05)

func play_equip() -> void:
	play_sfx(SFX_EQUIP, 0.0, 0.04)

func play_music(stream: AudioStream = null, volume_offset_db: float = 0.0) -> void:
	_init_players()
	if _fade_tween:
		_fade_tween.kill()
	
	if stream == null:
		stream = music_battle
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	
	_music_player.stream = stream
	_music_player.volume_db = music_volume_db + volume_offset_db
	if not _music_player.playing:
		_music_player.play()

func stop_music() -> void:
	if _fade_tween:
		_fade_tween.kill()
	if _music_player:
		_music_player.stop()

func fade_music_out(duration := 0.5) -> void:
	if not _music_player or not _music_player.playing:
		return
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_music_player, "volume_db", -60.0, duration)
	_fade_tween.tween_callback(_music_player.stop)

# --- Control de volumen y buses (HU-15) ---

func set_bus_volume_db(bus_name: String, volume_db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, volume_db)

func get_bus_volume_db(bus_name: String) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		return AudioServer.get_bus_volume_db(idx)
	return 0.0

func set_bus_volume_linear(bus_name: String, linear: float) -> void:
	set_bus_volume_db(bus_name, linear_to_db(clampf(linear, 0.0001, 1.0)))

func get_bus_volume_linear(bus_name: String) -> float:
	return db_to_linear(get_bus_volume_db(bus_name))

func set_master_volume(linear: float) -> void:
	set_bus_volume_linear("Master", linear)

func set_music_volume(linear: float) -> void:
	set_bus_volume_linear("Music", linear)

func set_sfx_volume(linear: float) -> void:
	set_bus_volume_linear("SFX", linear)

func set_bus_mute(bus_name: String, muted: bool) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_mute(idx, muted)

func is_bus_mute(bus_name: String) -> bool:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		return AudioServer.is_bus_mute(idx)
	return false
