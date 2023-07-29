## Road scene. Contains the core gameplay.
extends Node2D

## The [AudioStreamPlayer] that plays the background music.
@onready var _music_player: AudioStreamPlayer = $MusicPlayer

## Run when the road scene is ready. Display the main menu.
func _ready() -> void:
	Global.gui_card_changed.emit("main")
	# Avoid nasty loop point on startup.
	_music_player.create_tween().tween_property(_music_player, "volume_db", 0.0, 1.0)
