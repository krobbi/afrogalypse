extends Node

# Global State

signal gui_card_changed(card_name: String)
signal new_game_started
signal game_over_cleared

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

func _ready() -> void:
	load_data()


func reset_rng() -> void:
	rng.seed = hash("Frog RNG.")
	rng.state = 0xf706


func new_game() -> void:
	state = GameState.STARTING
	reset_rng()
	new_game_started.emit()


func on_frog_hit() -> void:
	state = GameState.STOPPING


func on_game_over() -> void:
	state = GameState.IDLE
	gui_card_changed.emit("game_over")


func save_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if not file:
		return
	
	file.store_line(JSON.stringify({
		"format": "krobbizoid.gmtk-2023.save",
		"version": "1.0.0-jam",
		"high_score": high_score
	}))
	file.close()


func load_data() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if not file:
		return
	
	var result: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	
	if result is Dictionary and "high_score" in result:
		var score: Variant = result["high_score"]
		
		if score is int and score > 0:
			high_score = score
		elif score is float and score > 0.0:
			high_score = int(score)
