extends Node2D

@onready var music_player: AudioStreamPlayer = $MusicPlayer

func _ready() -> void:
	Global.gui_card_changed.emit("main")
	# Avoid nasty loop point on startup.
	music_player.create_tween().tween_property(music_player, "volume_db", 0.0, 1.0)
