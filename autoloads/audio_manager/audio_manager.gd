## Manages audio options.
extends Node

## A map of audio bus names to audio bus indices.
var _buses: Dictionary = {}

## The [AudioStreamPlayer] to play the background music with.
@onready var _music_player: AudioStreamPlayer = $MusicPlayer

## Run when the audio manager is ready. Apply the volume options and fade in the
## background music.
func _ready() -> void:
	for bus_name in ["Sound", "Music"] as Array[String]:
		var bus_index: int = AudioServer.get_bus_index(bus_name)
		
		if bus_index >= 0:
			bus_name = bus_name.to_lower()
			_buses[bus_name] = bus_index
			Config.on_float("volume/%s" % bus_name, _set_bus_volume.bind(bus_name))
	
	_music_player.play()
	create_tween().tween_property(_music_player, "volume_db", 0.0, 1.0)


## Set an audio bus' volume from the config data.
func _set_bus_volume(value: float, bus_name: String) -> void:
	if value >= 0.0 and value <= 100.0:
		AudioServer.set_bus_volume_db(_buses[bus_name], linear_to_db(value * 0.01))
	else:
		Config.set_float("volume/%s" % bus_name, clampf(value, 0.0, 100.0))
