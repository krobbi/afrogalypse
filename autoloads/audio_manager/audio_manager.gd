## Manages audio options.
extends Node

## The [AudioStreamPlayer] to play the background music with.
@onready var _music_player: AudioStreamPlayer = $MusicPlayer

## Run when the audio manager is ready. Apply the volume options and fade in the
## background music.
func _ready() -> void:
	set_bus_volume("Sound", Config.get_float("volume/sound"))
	set_bus_volume("Music", Config.get_float("volume/music"))
	
	_music_player.play()
	create_tween().tween_property(_music_player, "volume_db", 0.0, 1.0)

## Set the volume of an audio bus.
func set_bus_volume(bus_name: String, value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(value * 0.01))
	
	# TODO: Use a more robust configuration system. <krobbi>
	match bus_name:
		"Sound":
			Config.set_float("volume/sound", value)
		"Music":
			Config.set_float("volume/music", value)
