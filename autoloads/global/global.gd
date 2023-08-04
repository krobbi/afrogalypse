extends Node

# Global State

signal new_game_started
signal game_over_cleared

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var is_main_card: bool = true

## Start a new game.
func new_game() -> void:
	rng.seed = hash("Frog RNG.")
	rng.state = 0xf706
	new_game_started.emit()
