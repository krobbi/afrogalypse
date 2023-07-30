## Manages scene transitions.
extends CanvasLayer

## The [ColorRect] to fade out with.
@onready var _fade_color: ColorRect = $FadeColor

## Change the current scene from a file path.
func change_scene(path: String) -> void:
	show()
	await create_tween().tween_property(_fade_color, "modulate", Color.WHITE, 0.4).finished
	get_tree().change_scene_to_file(path)
	await create_tween().tween_property(_fade_color, "modulate", Color.TRANSPARENT, 0.4).finished
	hide()


## Make a request to quit the game.
func request_quit() -> void:
	Global.save_data()
	get_tree().quit()
