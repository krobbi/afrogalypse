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
	"progress/has_seen_tutorial": false,
	"progress/high_score": 0,
}

## The config data's [Array]s of [ConfigConnection]s by key.
var _connections: Dictionary = {}

## The number of active [ConfigConnections].
var _connection_count: int = 0

## Run when the config data is ready. Populate the config data's connections and
## load the config data.
func _ready() -> void:
	for key in _data:
		_connections[key] = [] as Array[ConfigConnection]
	
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
	
	for connection in _connections[key] as Array[ConfigConnection]:
		connection.notify(value)


## Set a config [bool] from its key.
func set_bool(key: String, value: bool) -> void:
	set_value(key, value)


## Set a config [int] from its key.
func set_int(key: String, value: int) -> void:
	set_value(key, value)


## Get a config [Variant] from its key.
func get_value(key: String) -> Variant:
	return _data.get(key)


## Get a config [bool] from its key.
func get_bool(key: String) -> bool:
	return ConfigConnection.cast_bool(get_value(key))


## Get a config [int] from its key.
func get_int(key: String) -> int:
	return ConfigConnection.cast_int(get_value(key))


## Connect a [Node]'s [Callable] to a [Variant].
func on_value(key: String, callable: Callable, type: Variant.Type = TYPE_NIL) -> void:
	if not (key in _data and callable.is_valid()):
		return
	
	var node: Node = callable.get_object()
	
	if not node.tree_exiting.is_connected(_disconnect_node):
		node.tree_exiting.connect(_disconnect_node.bind(node), CONNECT_ONE_SHOT)
	
	var connection: ConfigConnection = ConfigConnection.new(callable, type)
	_connections[key].push_back(connection)
	_debug_connections(1)
	connection.notify(get_value(key))


## Connect a [Node]'s [Callable] to a [bool].
func on_bool(key: String, callable: Callable) -> void:
	on_value(key, callable, TYPE_BOOL)


## Connect a [Node]'s [Callable] to an [int].
func on_int(key: String, callable: Callable) -> void:
	on_value(key, callable, TYPE_INT)


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


## Debug the connection count.
func _debug_connections(delta: int) -> void:
	_connection_count += delta
	print_debug("%d config connection(s)." % _connection_count)


## Disconnect a [Node] from the [ConfigData].
func _disconnect_node(node: Node) -> void:
	for key in _data:
		var connections: Array[ConfigConnection] = _connections[key]
		
		for i in range(connections.size() - 1, -1, -1):
			if connections[i].get_node() == node:
				connections.remove_at(i)
				_debug_connections(-1)