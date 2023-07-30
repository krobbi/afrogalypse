## Manages scene transitions.
extends CanvasLayer

## Whether the scene manager is quitting.
var _is_quitting: bool = false

## The [ColorRect] to fade out with.
@onready var _fade_color: ColorRect = $FadeColor

## Run when the scene manager receives a notification. Make a quit request when
## a window close request is received.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		request_quit()


## Make a request to quit the game.
func request_quit() -> void:
	if _is_quitting:
		return
	
	_is_quitting = true
	Global.save_data()
	get_tree().quit()


## Change the current scene from a file path.
func change_scene(path: String) -> void:
	show()
	await create_tween().tween_property(_fade_color, "modulate", Color.WHITE, 0.4).finished
	get_tree().change_scene_to_file(path)
	await create_tween().tween_property(_fade_color, "modulate", Color.TRANSPARENT, 0.4).finished
	hide()
