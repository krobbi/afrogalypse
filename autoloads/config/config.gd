## The game's config data.
extends Node

## The file path to save config data to.
const _FILE_PATH: String = "user://options.cfg"

## Whether the config data should be saved.
var _should_save: bool = false

## The game's raw config data.
var _data: Dictionary = {
	"volume/sound": 75,
	"volume/music": 50,
	"controls/steer_left": "",
	"controls/steer_right": "",
	"controls/brake": "",
	"controls/boost": "",
	"controls/pause": "",
	"progress/has_seen_tutorial": false,
	"progress/high_score": 0,
}

## Run when the config data is ready. Load the config data.
func _ready() -> void:
	load_file()


## Run when the config data exits the scene tree. Save the config data.
func _exit_tree() -> void:
	save_file()


## Set a config [bool] from its key.
func set_bool(key: String, value: bool) -> void:
	_set_value(key, value)


## Set a config [int] from its key.
func set_int(key: String, value: int) -> void:
	_set_value(key, value)


## Set a config [float] from its key.
func set_float(key: String, value: float) -> void:
	_set_value(key, value)


## Set a config [String] from its key.
func set_string(key: String, value: String) -> void:
	_set_value(key, value)


## Get a config [bool] from its key.
func get_bool(key: String) -> bool:
	return true if _data[key] else false


## Get a config [int] from its key.
func get_int(key: String) -> int:
	var value: Variant = _data[key]
	
	match typeof(value):
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			return int(value)
		_:
			return 0


## Get a config [float] from its key.
func get_float(key: String) -> float:
	var value: Variant = _data[key]
	
	match typeof(value):
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING:
			var casted: float = float(value)
			return casted if is_finite(casted) and casted != -0.0 else 0.0
		_:
			return 0.0


## Get a config [String] from its key.
func get_string(key: String) -> String:
	return str(_data[key])


## Save the config data to its file if it needs to be saved.
func save_file() -> void:
	if not _should_save:
		return
	
	var file: ConfigFile = ConfigFile.new()
	
	for key in _data:
		var key_parts: PackedStringArray = key.split("/", true, 1)
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
		var key_section: String = key_parts[0]
		var key_key: String = key_parts[1]
		
		if file.has_section_key(key_section, key_key):
			_data[key] = file.get_value(key_section, key_key)
		else:
			_should_save = true # Save to replace missing key.


## Set a config [Variant] from its key.
func _set_value(key: String, value: Variant) -> void:
	if not is_same(_data[key], value):
		_data[key] = value
		_should_save = true # Save to update modified key.
