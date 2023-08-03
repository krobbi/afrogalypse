## Manages input mapping.
extends Node

## A map of actions to their default input mapping code [String]s.
const _DEFAULT_MAPPINGS: Dictionary = {
	"boost": "key/%s" % KEY_SPACE,
}

## Run when the input manager is ready. Subscribe the input manager to the
## config data.
func _ready() -> void:
	for action in _DEFAULT_MAPPINGS:
		Config.subscribe_string("controls/%s" % action, map.bind(action))


## Get an action's input as a human-readable [String].
func get_mapping_name(action: String) -> String:
	return OS.get_keycode_string(decode(Config.get_string("controls/%s" % action)).physical_keycode)


## Translate a message with input substitutions.
func translate(message: String) -> String:
	for action in _DEFAULT_MAPPINGS:
		message = message.replace("{input/%s}" % action, get_mapping_name(action))
	
	return message


## Return whether an [InputEvent] can be used for input mapping.
func can_map(event: InputEvent) -> bool:
	return event is InputEventKey


## Encode an [InputEvent] to an input mapping code [String].
func encode(event: InputEvent) -> String:
	assert(event is InputEventKey, "Only keyboard input can be mapped.")
	
	return "key/%d" % event.physical_keycode


## Decode an [InputEvent] from an input mapping code [String]. Return
## [code]null[/code] if [param code] is invalid.
func decode(code: String) -> InputEvent:
	var code_parts: PackedStringArray = code.split("/")
	
	if code_parts[0] == "key" and len(code_parts) == 2:
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = int(code_parts[1]) as Key
		return event
	else:
		return null


## Map an input mapping code [String] to an action.
func map(code: String, action: String) -> void:
	assert(action in _DEFAULT_MAPPINGS, "Action '%s' does not exist." % action)
	
	var event: InputEvent = decode(code)
	
	if event:
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
	else:
		Config.set_string("controls/%s" % action, _DEFAULT_MAPPINGS[action])
