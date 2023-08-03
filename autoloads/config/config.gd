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
	"controls/boost": "auto",
	"progress/has_seen_tutorial": false,
	"progress/high_score": 0,
}

## The config data's [Array]s of [ConfigConnection]s by key.
var _connections: Dictionary = {}

## The number of active [ConfigConnection]s.
var _connection_count: int = 0

## Run when the config data is ready. Populate the config data's connections and
## load the config data.
func _ready() -> void:
	for key in _data:
		_connections[key] = [] as Array[ConfigConnection]
	
	load_file()


## Run when the config data exits the scene tree. Save the config data.
func _exit_tree() -> void:
	assert(_connection_count == 0, "Leaked %d config connection(s) at exit." % _connection_count)
	
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
	return ConfigConnection.cast_bool(_get_value(key))


## Get a config [int] from its key.
func get_int(key: String) -> int:
	return ConfigConnection.cast_int(_get_value(key))


## Get a config [float] from its key.
func get_float(key: String) -> float:
	return ConfigConnection.cast_float(_get_value(key))


## Get a config [String] from its key.
func get_string(key: String) -> String:
	return ConfigConnection.cast_string(_get_value(key))


## Subscribe a [Node]'s [Callable] to a config [bool].
func subscribe_bool(key: String, callable: Callable) -> void:
	_subscribe_value(key, callable, TYPE_BOOL)


## Subscribe a [Node]'s [Callable] to a config [int].
func subscribe_int(key: String, callable: Callable) -> void:
	_subscribe_value(key, callable, TYPE_INT)


## Subscribe a [Node]'s [Callable] to a config [float].
func subscribe_float(key: String, callable: Callable) -> void:
	_subscribe_value(key, callable, TYPE_FLOAT)


## Subscribe a [Node]'s [Callable] to a config [String].
func subscribe_string(key: String, callable: Callable) -> void:
	_subscribe_value(key, callable, TYPE_STRING)


## Save the config data to its file if it needs to be saved.
func save_file() -> void:
	if not _should_save:
		return
	
	var file: ConfigFile = ConfigFile.new()
	
	for key in _data:
		var key_parts: PackedStringArray = key.split("/", true, 1)
		
		assert(key_parts.size() == 2, "Config key '%s' does not have 2 parts." % key)
		assert(not key_parts[0].is_empty(), "Config key '%s' has an empty section." % key)
		assert(not key_parts[1].is_empty(), "Config key '%s' has an empty key." % key)
		
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
		
		assert(key_parts.size() == 2, "Config key '%s' does not have 2 parts." % key)
		assert(not key_parts[0].is_empty(), "Config key '%s' has an empty section." % key)
		assert(not key_parts[1].is_empty(), "Config key '%s' has an empty key." % key)
		
		var key_section: String = key_parts[0]
		var key_key: String = key_parts[1]
		
		if file.has_section_key(key_section, key_key):
			_data[key] = file.get_value(key_section, key_key)
		else:
			_should_save = true # Save to replace missing key.


## Set a config [Variant] from its key.
func _set_value(key: String, value: Variant) -> void:
	assert(key in _data, "Cannot set config key '%s' as it does not exist." % key)
	
	if not is_same(_data[key], value):
		_data[key] = value
		_should_save = true # Save to update modified key.
		
		for connection in _connections[key] as Array[ConfigConnection]:
			connection.send(value)


## Get a config [Variant] from its key.
func _get_value(key: String) -> Variant:
	assert(key in _data, "Cannot get config key '%s' as it does not exist." % key)
	
	return _data[key]


## Subscribe a [Node]'s [Callable] to a config [Variant] with a
## [enum Variant.Type].
func _subscribe_value(key: String, callable: Callable, type: Variant.Type) -> void:
	assert(key in _data, "Cannot subscribe to config key '%s' as it does not exist." % key)
	assert(callable.is_valid(), "Cannot subscribe to config data with an invalid callable.")
	assert(callable.get_object() is Node, "Only nodes may subscribe to config data.")
	
	var node: Node = callable.get_object()
	
	if not node.tree_exiting.is_connected(_unsubscribe_node):
		node.tree_exiting.connect(_unsubscribe_node.bind(node), CONNECT_ONE_SHOT)
	
	var connection: ConfigConnection = ConfigConnection.new(callable, type)
	_connections[key].push_back(connection)
	_update_connection_count(1)
	connection.send(_get_value(key))


## Unsubscribe a [Node] from all of its [ConfigConnection]s.
func _unsubscribe_node(node: Node) -> void:
	for key in _data:
		var connections: Array[ConfigConnection] = _connections[key]
		
		for i in range(connections.size() - 1, -1, -1):
			if connections[i].get_node() == node:
				connections.remove_at(i)
				_update_connection_count(-1)


## Update the number of active [ConfigConnection]s.
func _update_connection_count(change: int) -> void:
	_connection_count += change
	
	assert(_connection_count >= 0, "Counted less than 0 config connections.")
	
	if OS.is_debug_build():
		print("%d config connection(s)." % _connection_count)
