extends Node

# Global State

signal new_game_started
signal game_over_cleared

var speed: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var is_main_card: bool = true

## Run when the global state is ready. Unpause the game and set the locale.
func _ready() -> void:
	get_tree().paused = false
	TranslationServer.set_locale("en")


## Reset the gameplay [RandomNumberGenerator] to a known state.
func reset_rng() -> void:
	rng.seed = hash("Frog RNG.")
	rng.state = 0xf706


## Start a new game.
func new_game() -> void:
	reset_rng()
	new_game_started.emit()
