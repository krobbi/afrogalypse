## Manages input mapping.
extends Node

## The map of action [String]s to their default mapping code [String]s.
const _DEFAULT_MAPPINGS: Dictionary = {
	"steer_left": "key/%d" % KEY_A,
	"steer_right": "key/%d" % KEY_D,
	"brake": "key/%d" % KEY_SHIFT,
	"boost": "key/%d" % KEY_SPACE,
}

## The map of action [String]s to their current mapping code [String]s.
var _mappings: Dictionary = _DEFAULT_MAPPINGS.duplicate()

## Run when the input manager is ready. Apply the mappings from the config data.
func _ready() -> void:
	for action in _mappings:
		_map_action_code(action, Config.get_string("controls/%s" % action))
	
	_apply_mappings()


## Get an action [String]'s mapped input as a human-readable [String].
func get_mapping_name(action: String) -> String:
	if not action in _mappings:
		return tr("input.no_action")
	
	var code_parts: PackedStringArray = _mappings[action].split("/")
	
	if code_parts[0] == "key" and code_parts.size() == 2:
		return OS.get_keycode_string(int(code_parts[1]))
	elif code_parts[0] == "mouse_button" and code_parts.size() == 2:
		var mouse_button: MouseButton = int(code_parts[1]) as MouseButton
		
		match mouse_button:
			MOUSE_BUTTON_LEFT:
				return tr("input.mouse_button.left")
			MOUSE_BUTTON_RIGHT:
				return tr("input.mouse_button.right")
			MOUSE_BUTTON_MIDDLE:
				return tr("input.mouse_button.middle")
			MOUSE_BUTTON_WHEEL_UP:
				return tr("input.mouse_button.wheel_up")
			MOUSE_BUTTON_WHEEL_DOWN:
				return tr("input.mouse_button.wheel_down")
			MOUSE_BUTTON_WHEEL_LEFT:
				return tr("input.mouse_button.wheel_left")
			MOUSE_BUTTON_WHEEL_RIGHT:
				return tr("input.mouse_button.wheel_right")
			MOUSE_BUTTON_XBUTTON1:
				return tr("input.mouse_button.xbutton1")
			MOUSE_BUTTON_XBUTTON2:
				return tr("input.mouse_button.xbutton2")
			_:
				return tr("input.mouse_button.unknown").format({"index": mouse_button})
	else:
		return tr("input.unknown")


## Translate a message [String] with action substitution [String]s.
func translate(message: String) -> String:
	var mapping_names: Dictionary = {}
	
	for action in _mappings:
		mapping_names[action] = get_mapping_name(action)
	
	return message.format(mapping_names)


## Attempt to map an action [String] to an [InputEvent] and return whether it
## was successful.
func map_action_event(action: String, event: InputEvent) -> bool:
	if action in _mappings and _is_event_mappable(event):
		_map_action_code(action, _get_event_code(event))
		_apply_mappings()
		return true
	else:
		return false


## Get a mapping code [String]'s [InputEvent]. Return [code]null[/code] if
## [param code] is not a valid mapping code.
func _get_code_event(code: String) -> InputEvent:
	var code_parts: PackedStringArray = code.split("/")
	
	if code_parts[0] == "key" and code_parts.size() == 2:
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = int(code_parts[1]) as Key
		return event
	elif code_parts[0] == "mouse_button" and code_parts.size() == 2:
		var event: InputEventMouseButton = InputEventMouseButton.new()
		event.button_index = int(code_parts[1]) as MouseButton
		return event
	else:
		return null


## Get an [InputEvent]'s mapping code [String]. Return an empty [String] if
## [param event] is not mappable.
func _get_event_code(event: InputEvent) -> String:
	if event is InputEventKey:
		return "key/%d" % event.physical_keycode
	elif event is InputEventMouseButton:
		return "mouse_button/%d" % event.button_index
	else:
		return ""


## Return whether an [InputEvent] can be used for input mapping.
func _is_event_mappable(event: InputEvent) -> bool:
	return not _get_event_code(event).is_empty()


## Normalize a mapping code [String]. Return [param action]'s default mapping
## code if [param code] is not a valid mapping code.
func _normalize_code(code: String, action: String) -> String:
	var event: InputEvent = _get_code_event(code)
	
	if not event:
		event = _get_code_event(_DEFAULT_MAPPINGS[action])
	
	return _get_event_code(event)


## Map an action [String] to a mapping code [String].
func _map_action_code(action: String, code: String) -> void:
	code = _normalize_code(code, action)
	
	# Swap existing codes to prevent conflicts.
	for other_action in _mappings:
		if other_action != action and _mappings[other_action] == code:
			_mappings[other_action] = _mappings[action]
			break
	
	_mappings[action] = code


## Apply the current mappings.
func _apply_mappings() -> void:
	for action in _mappings:
		var code: String = _mappings[action]
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, _get_code_event(code))
		Config.set_string("controls/%s" % action, code)
