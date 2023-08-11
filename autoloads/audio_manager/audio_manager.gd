## Manages audio settings.
extends Node

## A map of keys to audio bus indices.
var _buses: Dictionary = {}

## The [AudioStreamPlayer] to play the background music with.
@onready var _music_player: AudioStreamPlayer = $MusicPlayer

## Run when the audio manager is ready. Apply the bus volumes from the config
## data and fade in the background music.
func _ready() -> void:
	for key in ["Sound", "Music"] as Array[String]:
		var bus_index: int = AudioServer.get_bus_index(key)
		
		if bus_index >= 0:
			key = key.to_lower()
			_buses[key] = bus_index
			set_bus_volume(key, Config.get_float("volume/%s" % key))
	
	_music_player.play()
	create_tween().tween_property(_music_player, "volume_db", 0.0, 1.0)


## Set an audio bus' volume from its key.
func set_bus_volume(key: String, value: float) -> void:
	value = clampf(value, 0.0, 100.0)
	AudioServer.set_bus_volume_db(_buses[key], linear_to_db(value * 0.01))
	Config.set_int("volume/%s" % key, int(value))


## Get an audio bus' volume from its key.
func get_bus_volume(key: String) -> float:
	return Config.get_float("volume/%s" % key)


## Get an audio bus' name from its key.
func get_bus_name(key: String) -> String:
	return AudioServer.get_bus_name(_buses[key])
