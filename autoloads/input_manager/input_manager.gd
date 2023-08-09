## Manages input mapping.
extends Node

## The map of action [String]s to their default mapping code [String]s.
const _DEFAULT_MAPPINGS: Dictionary = {
	"steer_left": "key/%d" % KEY_A,
	"steer_right": "key/%d" % KEY_D,
	"brake": "key/%d" % KEY_SHIFT,
	"boost": "key/%d" % KEY_SPACE,
	"pause": "key/%d" % KEY_ESCAPE,
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
	elif code_parts[0] == "joypad_button" and code_parts.size() == 2:
		var joy_button: JoyButton = int(code_parts[1]) as JoyButton
		
		match joy_button:
			JOY_BUTTON_A:
				return tr("input.joypad_button.a")
			JOY_BUTTON_B:
				return tr("input.joypad_button.b")
			JOY_BUTTON_X:
				return tr("input.joypad_button.x")
			JOY_BUTTON_Y:
				return tr("input.joypad_button.y")
			JOY_BUTTON_BACK:
				return tr("input.joypad_button.back")
			JOY_BUTTON_GUIDE:
				return tr("input.joypad_button.guide")
			JOY_BUTTON_START:
				return tr("input.joypad_button.start")
			JOY_BUTTON_LEFT_STICK:
				return tr("input.joypad_button.left_stick")
			JOY_BUTTON_RIGHT_STICK:
				return tr("input.joypad_button.right_stick")
			JOY_BUTTON_LEFT_SHOULDER:
				return tr("input.joypad_button.left_shoulder")
			JOY_BUTTON_RIGHT_SHOULDER:
				return tr("input.joypad_button.right_shoulder")
			JOY_BUTTON_DPAD_UP:
				return tr("input.joypad_button.dpad_up")
			JOY_BUTTON_DPAD_DOWN:
				return tr("input.joypad_button.dpad_down")
			JOY_BUTTON_DPAD_LEFT:
				return tr("input.joypad_button.dpad_left")
			JOY_BUTTON_DPAD_RIGHT:
				return tr("input.joypad_button.dpad_right")
			JOY_BUTTON_MISC1:
				return tr("input.joypad_button.misc1")
			JOY_BUTTON_PADDLE1:
				return tr("input.joypad_button.paddle1")
			JOY_BUTTON_PADDLE2:
				return tr("input.joypad_button.paddle2")
			JOY_BUTTON_PADDLE3:
				return tr("input.joypad_button.paddle3")
			JOY_BUTTON_PADDLE4:
				return tr("input.joypad_button.paddle4")
			JOY_BUTTON_TOUCHPAD:
				return tr("input.joypad_button.touchpad")
			_:
				return tr("input.joypad_button.unknown").format({"index": joy_button})
	elif code_parts[0] == "joypad_motion" and code_parts.size() == 3:
		var joy_axis: JoyAxis = int(code_parts[1]) as JoyAxis
		var direction: String = code_parts[2]
		
		if direction != "positive" and direction != "negative":
			return tr("input.unknown")
		
		match joy_axis:
			JOY_AXIS_LEFT_X:
				return tr("input.joypad_motion.left_x.%s" % direction)
			JOY_AXIS_LEFT_Y:
				return tr("input.joypad_motion.left_y.%s" % direction)
			JOY_AXIS_RIGHT_X:
				return tr("input.joypad_motion.right_x.%s" % direction)
			JOY_AXIS_RIGHT_Y:
				return tr("input.joypad_motion.right_y.%s" % direction)
			JOY_AXIS_TRIGGER_LEFT:
				return tr("input.joypad_motion.trigger_left.%s" % direction)
			JOY_AXIS_TRIGGER_RIGHT:
				return tr("input.joypad_motion.trigger_right.%s" % direction)
			_:
				return tr("input.joypad_motion.unknown.%s" % direction).format({"index": joy_axis})
	else:
		return tr("input.unknown")


## Translate a message [String] with action substitution [String]s.
func translate(message: String) -> String:
	var mapping_names: Dictionary = {}
	
	for action in _mappings:
		mapping_names[action] = get_mapping_name(action)
	
	return message.format(mapping_names)


## Reset the mappings to their defaults.
func reset_mappings() -> void:
	_mappings = _DEFAULT_MAPPINGS.duplicate()
	_apply_mappings()


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
	elif code_parts[0] == "joypad_button" and code_parts.size() == 2:
		var event: InputEventJoypadButton = InputEventJoypadButton.new()
		event.button_index = int(code_parts[1]) as JoyButton
		return event
	elif code_parts[0] == "joypad_motion" and code_parts.size() == 3:
		var event: InputEventJoypadMotion = InputEventJoypadMotion.new()
		event.axis = int(code_parts[1]) as JoyAxis
		
		match code_parts[2]:
			"positive":
				event.axis_value = 1.0
			"negative":
				event.axis_value = -1.0
			_:
				return null
		
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
	elif event is InputEventJoypadButton:
		return "joypad_button/%d" % event.button_index
	elif event is InputEventJoypadMotion and absf(event.axis_value) >= 0.5:
		if event.axis_value >= 0.0:
			return "joypad_motion/%d/positive" % event.axis
		else:
			return "joypad_motion/%d/negative" % event.axis
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


## Apply the current mappings. Emit [signal Event.input_mappings_changed].
func _apply_mappings() -> void:
	for action in _mappings:
		var code: String = _mappings[action]
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, _get_code_event(code))
		Config.set_string("controls/%s" % action, code)
	
	Event.input_mappings_changed.emit()
