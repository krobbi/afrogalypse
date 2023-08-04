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
	for action in _DEFAULT_MAPPINGS:
		_map_action_code(action, Config.get_string("controls/%s" % action))
	
	_apply_mappings()


## Get an action [String]'s mapped input as a human-readable [String].
func get_mapping_name(action: String) -> String:
	return OS.get_keycode_string(int(_mappings[action].split("/")[1]))


## Translate a message [String] with input substitution [String]s.
func translate(message: String) -> String:
	for action in _DEFAULT_MAPPINGS:
		message = message.replace("{input.%s}" % action, get_mapping_name(action))
	
	return message


## Attempt to map an action [String] to an [InputEvent] and return whether it
## was successful.
func map_action_event(action: String, event: InputEvent) -> bool:
	if action in _DEFAULT_MAPPINGS and event is InputEventKey:
		_map_action_code(action, "key/%d" % event.physical_keycode)
		_apply_mappings()
		return true
	else:
		return false


## Normalize a mapping code [String]. Return [param default] if [param code] is
## not a valid mapping code.
func _normalize_code(code: String, default: String) -> String:
	var code_parts: PackedStringArray = code.split("/")
	
	if code_parts[0] == "key" and code_parts.size() == 2:
		return "key/%d" % int(code_parts[1])
	else:
		return default


## Map an action [String] to a mapping code [String].
func _map_action_code(action: String, code: String) -> void:
	code = _normalize_code(code, _DEFAULT_MAPPINGS[action])
	
	for other_action in _DEFAULT_MAPPINGS:
		if other_action != action and _mappings[other_action] == code:
			_mappings[other_action] = _mappings[action]
			break
	
	_mappings[action] = code


## Apply the current mappings.
func _apply_mappings() -> void:
	for action in _DEFAULT_MAPPINGS:
		var code: String = _mappings[action]
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = int(code.split("/")[1]) as Key
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		Config.set_string("controls/%s" % action, code)
