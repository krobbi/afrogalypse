extends Node

# Global State

signal gui_card_changed(card_name: String)
signal new_game_started
signal game_over_cleared

enum GameState {
	IDLE,
	STARTING,
	GAME,
	STOPPING,
}

var state: GameState = GameState.IDLE
var speed: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var is_main_card: bool = true
var no_hit_time: float = 0.0

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
	state = GameState.STARTING
	reset_rng()
	no_hit_time = 0.0
	new_game_started.emit()


## Run when the car stops. Display the game over menu card.
func on_game_over() -> void:
	state = GameState.IDLE
	gui_card_changed.emit("game_over")
