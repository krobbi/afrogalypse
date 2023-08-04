## Manages scene transitions.
extends CanvasLayer

## The [ColorRect] to fade out with.
@onready var _fade_color: ColorRect = $FadeColor

## Run when the scene manager is ready. Unpause the game and set the locale.
func _ready() -> void:
	get_tree().paused = false
	TranslationServer.set_locale("en")


## Change the current scene from a file path.
func change_scene(path: String) -> void:
	show()
	await create_tween().tween_property(_fade_color, "modulate", Color.WHITE, 0.4).finished
	get_tree().change_scene_to_file(path)
	await create_tween().tween_property(_fade_color, "modulate", Color.TRANSPARENT, 0.4).finished
	hide()
