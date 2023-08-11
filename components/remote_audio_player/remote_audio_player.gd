## An [AudioStreamPlayer] that can continue playing after leaving the scene
## tree.
class_name RemoteAudioPlayer
extends AudioStreamPlayer

## Play the remote audio player remotely.
func play_remote(from_position: float = 0.0) -> void:
	if stream:
		var copy: AudioStreamPlayer = AudioStreamPlayer.new()
		copy.stream = stream
		copy.volume_db = volume_db
		copy.pitch_scale = pitch_scale
		copy.mix_target = mix_target
		copy.bus = bus
		copy.finished.connect(copy.queue_free, CONNECT_ONE_SHOT)
		AudioManager.add_child(copy)
		copy.play(from_position)
