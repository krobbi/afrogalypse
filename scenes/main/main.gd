extends Node2D

@onready var music_player: AudioStreamPlayer = $MusicPlayer

var _cached_audio: Array[AudioStreamOggVorbis] = []

func _ready() -> void:
	# Cache audio to reduce in-game lag spikes.
	for audio_name in [
		"boost",
		"deplete",
		"gain_energy",
		"gui_navigate",
		"nitro_refill",
		"story_done",
	]:
		_cached_audio.append(load("res://resources/audio/%s.ogg" % audio_name))
	
	Global.gui_card_changed.emit("main")
	# Avoid nasty loop point on startup.
	music_player.create_tween().tween_property(music_player, "volume_db", 0.0, 1.0)
