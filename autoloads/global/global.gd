extends Node

# Global State

signal gui_card_changed(card_name: String)
signal new_game_started
signal game_over_cleared
signal energy_added
signal energy_removed
signal boost_used

const SAVE_PATH: String = "user://save.json"

enum GameState {
	IDLE,
	STARTING,
	GAME,
	STOPPING,
}

var state: GameState = GameState.IDLE
var speed: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var high_score: int = 0
var is_main_card: bool = true
var is_boosting: bool = false
var no_hit_time: float = 0.0

## Run when the global state is ready. Load the save data.
func _ready() -> void:
	TranslationServer.set_locale("en")
	load_data()


## Reset the gameplay [RandomNumberGenerator] to a known state.
func reset_rng() -> void:
	rng.seed = hash("Frog RNG.")
	rng.state = 0xf706


## Return whether the game is a web build.
func is_web() -> bool:
	return OS.get_name() == "Web"


## Start a new game.
func new_game() -> void:
	state = GameState.STARTING
	reset_rng()
	no_hit_time = 0.0
	new_game_started.emit()


func on_frog_hit() -> void:
	no_hit_time *= 0.6
	energy_removed.emit()


func on_energy_depleted() -> void:
	state = GameState.STOPPING


func on_game_over() -> void:
	state = GameState.IDLE
	gui_card_changed.emit("game_over")


func save_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if not file:
		return
	
	file.store_line(JSON.stringify({
		"format": "krobbizoid.afrogalypse.legacy-save",
		"version": "1.1.0",
		"high_score": high_score,
	}))
	file.close()


func load_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if not file:
		return
	
	var result: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	if not result is Dictionary:
		return
	
	var score: Variant = result.get("high_score")
	
	if score is int and score > 0:
		high_score = score
	elif score is float and is_finite(score) and score > 0.0:
		high_score = int(score)
