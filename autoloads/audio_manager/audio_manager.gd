## Manages audio options.
extends AudioStreamPlayer

## Run when the audio manager is ready. Play and fade in the background music.
func _ready() -> void:
	play()
	create_tween().tween_property(self, "volume_db", 0.0, 1.0)
