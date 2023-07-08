extends Node2D

func _ready() -> void:
	Global.gui_card_changed.emit("main")
