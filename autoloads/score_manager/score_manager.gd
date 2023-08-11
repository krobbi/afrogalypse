## Manages the game's score data.
extends Node

## The file path to save score data to.
const _FILE_PATH: String= "user://high_scores.dat"

## The password to save score data with.
const _FILE_PASS: String = "17f15958d7852133cae89c22d79eb95f07fe31cabde95515e40266bddd6e29d5"

## Whether the score data should be saved.
var _should_save: bool = false

## The game's high score.
var _high_score: int = 0

## Run when the score manager is ready. Load the score data.
func _ready() -> void:
	load_data()


## Run when the score manager exits the scene tree. Save the score data.
func _exit_tree() -> void:
	save_data()


## Set the game's high score.
func set_high_score(value: int) -> void:
	if value > _high_score:
		_high_score = value
		_should_save = true


## Get the game's high score.
func get_high_score() -> int:
	return _high_score


## Save the score data if it should be saved.
func save_data() -> void:
	if not _should_save:
		return
	
	var file: FileAccess = FileAccess.open_encrypted_with_pass(
			_FILE_PATH, FileAccess.WRITE, _FILE_PASS)
	
	if not file:
		return
	
	file.store_line(JSON.stringify({
		"format": "io.itch.krobbizoid.afrogalypse.high-scores",
		"version": 1,
		"high_score": _high_score,
	}))
	file.close()
	_should_save = false


## Load the score data.
func load_data() -> void:
	if not FileAccess.file_exists(_FILE_PATH):
		return
	
	var file: FileAccess = FileAccess.open_encrypted_with_pass(
			_FILE_PATH, FileAccess.READ, _FILE_PASS)
	
	if not file:
		return
	
	var result: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	if not result is Dictionary:
		return
	
	var high_score: Variant = result.get("high_score")
	
	if high_score is int and high_score >= 0:
		_high_score = high_score
	elif high_score is float and is_finite(high_score) and high_score >= 0.0:
		_high_score = int(high_score)
	
	_should_save = false
