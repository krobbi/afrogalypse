## Main scene. Displays a splash and initializes the game.
extends Node2D

## The [BoostEffects] instance to initialize.
@onready var _boost_effects: BoostEffects = $BoostEffects

## The [ColorRect] to fade in from.
@onready var _fade_color: ColorRect = $SplashLayer/FadeColor

## Run when the main scene is ready. Display a splash and initialize the game.
func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await create_tween().tween_property(_fade_color, "modulate", Color.TRANSPARENT, 0.4).finished
	
	# Preload large in-game resources.
	for resource_path in [
		"res://resources/audio/boost.ogg",
		"res://resources/audio/deplete.ogg",
		"res://resources/audio/gain_energy.ogg",
		"res://resources/audio/gui_navigate.ogg",
		"res://resources/audio/nitro_refill.ogg",
		"res://resources/audio/tutorial/finished.ogg",
	]:
		load(resource_path)
	
	# Initialize boost effects.
	_boost_effects.enable()
	
	await get_tree().create_timer(1.0).timeout
	SceneManager.change_scene_to_file("res://scenes/road/road.tscn")
