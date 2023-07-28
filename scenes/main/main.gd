## The main scene. Contains all parts of the game.
extends Node2D

## The [AudioStreamPlayer] that plays the background music.
@onready var _music_player: AudioStreamPlayer = $MusicPlayer

## Pre-loaded [AudioStream]s to avoid lag spikes from loading.
var _cached_audio: Array[AudioStreamOggVorbis] = []

## Run when the main scene is ready. Cache audio and initialize the background
## music and menu.
func _ready() -> void:
	# Cache audio to reduce in-game lag spikes.
	for audio_name in [
		"boost",
		"deplete",
		"gain_energy",
		"gui_navigate",
		"nitro_refill",
		"tutorial/finished",
	]:
		_cached_audio.append(load("res://resources/audio/%s.ogg" % audio_name))
	
	Global.gui_card_changed.emit("main")
	# Avoid nasty loop point on startup.
	_music_player.create_tween().tween_property(_music_player, "volume_db", 0.0, 1.0)
