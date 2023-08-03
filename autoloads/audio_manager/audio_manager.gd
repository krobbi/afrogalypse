## Manages audio options.
extends Node

## A map of keys to audio bus indices.
var _buses: Dictionary = {}

## The [AudioStreamPlayer] to play the background music with.
@onready var _music_player: AudioStreamPlayer = $MusicPlayer

## Run when the audio manager is ready. Apply the volume options and fade in the
## background music.
func _ready() -> void:
	for key in ["Sound", "Music"] as Array[String]:
		var bus_index: int = AudioServer.get_bus_index(key)
		
		if bus_index >= 0:
			key = key.to_lower()
			_buses[key] = bus_index
			Config.subscribe_float("volume/%s" % key, _set_bus_volume.bind(key))
	
	_music_player.play()
	create_tween().tween_property(_music_player, "volume_db", 0.0, 1.0)


## Set an audio bus' volume from its key.
func _set_bus_volume(value: float, key: String) -> void:
	if value >= 0.0 and value <= 100.0:
		AudioServer.set_bus_volume_db(_buses[key], linear_to_db(value * 0.01))
	else:
		Config.set_int("volume/%s" % key, clampi(int(value), 0, 100))
