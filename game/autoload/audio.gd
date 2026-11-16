extends Node

## Autoload Audio (HU-15)
## Gestor de audio compatible con llamadas Audio.play(nombre), buses y volumen.

func play(nombre: String, volume_offset_db := 0.0, pitch_variance := 0.06) -> void:
	Sound.play(nombre, volume_offset_db, pitch_variance)

func play_music(stream: AudioStream = null, volume_offset_db := 0.0) -> void:
	Sound.play_music(stream, volume_offset_db)

func stop_music() -> void:
	Sound.stop_music()

func fade_music_out(duration := 0.5) -> void:
	Sound.fade_music_out(duration)

func set_master_volume(linear: float) -> void:
	Sound.set_master_volume(linear)

func set_music_volume(linear: float) -> void:
	Sound.set_music_volume(linear)

func set_sfx_volume(linear: float) -> void:
	Sound.set_sfx_volume(linear)

func set_bus_volume_db(bus_name: String, volume_db: float) -> void:
	Sound.set_bus_volume_db(bus_name, volume_db)

func get_bus_volume_db(bus_name: String) -> float:
	return Sound.get_bus_volume_db(bus_name)

func set_bus_volume_linear(bus_name: String, linear: float) -> void:
	Sound.set_bus_volume_linear(bus_name, linear)

func get_bus_volume_linear(bus_name: String) -> float:
	return Sound.get_bus_volume_linear(bus_name)

func set_bus_mute(bus_name: String, muted: bool) -> void:
	Sound.set_bus_mute(bus_name, muted)

func is_bus_mute(bus_name: String) -> bool:
	return Sound.is_bus_mute(bus_name)
