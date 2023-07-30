## The game's config data.
extends Node

## The file path to save config data to.
const _FILE_PATH: String = "user://options.cfg"

## Whether the config data should be saved.
var _should_save: bool = false

## The game's raw config data.
var _data: Dictionary = {
	"volume/sound": 75.0,
	"volume/music": 50.0,
}

## Run when the config data is ready. Load the config data.
func _ready() -> void:
	load_file()


## Run when the config data exits the scene tree. Save the config data.
func _exit_tree() -> void:
	save_file()


## Set a config [Variant] from its key.
func set_value(key: String, value: Variant) -> void:
	if not key in _data or is_same(_data[key], value):
		return
	
	_data[key] = value
	_should_save = true # Save to update modified key.


## Set a config [float] from its key.
func set_float(key: String, value: float) -> void:
	set_value(key, value)


## Get a config [Variant] from its key.
func get_value(key: String) -> Variant:
	return _data.get(key)


## Get a config [float] from its key.
func get_float(key: String) -> float:
	return cast_float(get_value(key))


## Cast a [Variant] to a [float].
func cast_float(value: Variant) -> float:
	match typeof(value):
		TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return float(value)
		TYPE_FLOAT:
			if is_finite(value) and value != -0.0:
				return value
	
	return 0.0


## Save the config data to its file if it needs to be saved.
func save_file() -> void:
	if not _should_save:
		return
	
	var file: ConfigFile = ConfigFile.new()
	
	for key in _data:
		var key_parts: PackedStringArray = key.split("/", true, 1)
		
		assert(key_parts.size() == 2, "Key '%s' does not have 2 parts." % key)
		assert(not key_parts[0].is_empty(), "Key '%s' has an empty section." % key)
		assert(not key_parts[1].is_empty(), "Key '%s' has an empty key." % key)
		
		file.set_value(key_parts[0], key_parts[1], _data[key])
	
	if file.save(_FILE_PATH) == OK:
		_should_save = false # Saved file should be up to date.


## Load the config data from its file.
func load_file() -> void:
	if not FileAccess.file_exists(_FILE_PATH):
		_should_save = true # Save to replace missing file.
		return
	
	var file: ConfigFile = ConfigFile.new()
	
	if file.load(_FILE_PATH) != OK:
		return
	
	_should_save = false # Data should be up to date.
	
	for key in _data:
		var key_parts: PackedStringArray = key.split("/", true, 1)
		
		assert(key_parts.size() == 2, "Key '%s' does not have 2 parts." % key)
		assert(not key_parts[0].is_empty(), "Key '%s' has an empty section." % key)
		assert(not key_parts[1].is_empty(), "Key '%s' has an empty key." % key)
		
		var key_section: String = key_parts[0]
		var key_key: String = key_parts[1]
		
		if file.has_section_key(key_section, key_key):
			_data[key] = file.get_value(key_section, key_key)
		else:
			_should_save = true # Save to replace missing key.
