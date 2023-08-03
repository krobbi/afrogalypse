## A GUI widget that controls mapping an action's input.
class_name ActionButton
extends HBoxContainer

## The action to control.
@export var _action: String

## The action button's [Button].
@onready var _button: Button = $Button

## The [Timer] to automatically deactivate the action button.
@onready var _timer: Timer = $Timer

## Whether the action button is actively waiting for input.
var _is_active: bool = false

## Run when the action button is ready. Initialize the action button's
## [Control]s.
func _ready() -> void:
	$Label.text = "action.%s" % _action
	deactivate()


## Run when the action button receives an [InputEvent]. Attempt to map the
## [InputEvent] if the action button is active.
func _input(event: InputEvent) -> void:
	if _is_active and InputManager.can_map(event):
		get_viewport().set_input_as_handled() # Consume the input.
		Config.set_string("controls/%s" % _action, InputManager.encode(event))
		deactivate()


## Activate the action button.
func activate() -> void:
	for other in get_tree().get_nodes_in_group("action_buttons"):
		if other != self:
			other.deactivate()
	
	_is_active = true
	_button.set_pressed_no_signal(true)
	_button.text = "input.prompt"
	_timer.start()


## Deactivate the action button.
func deactivate() -> void:
	_is_active = false
	_timer.stop()
	_button.set_pressed_no_signal(false)
	_button.text = InputManager.get_mapping_name(_action)


## Run when the action button's [Button] is toggled.
func _on_button_toggled(button_pressed: bool) -> void:
	if button_pressed:
		activate()
	else:
		deactivate()
