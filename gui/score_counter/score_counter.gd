## Tracks and displays the current score and high score.
class_name ScoreCounter
extends PanelContainer

## The current score.
var _score: int = 0

## The high score.
var _high_score: int = 0

## The [Label] to display the score on.
@onready var _label: Label = $Label

## The [DistanceClock] to count the score with.
@onready var _distance_clock: DistanceClock = $DistanceClock

## Run when the score counter is ready. Get the high score and connect to event
## signals.
func _ready() -> void:
	_high_score = maxi(Config.get_int("progress/high_score"), 0)
	_set_score(_high_score)
	Global.new_game_started.connect(_on_new_game_started)
	Global.game_over_cleared.connect(_on_game_over_cleared)


## Set and display the current score.
func _set_score(value: int) -> void:
	_score = value
	
	if _high_score > _score:
		_label.text = "%dm\nHI %dm" % [_score, _high_score]
	else:
		_label.text = "%dm" % _score


## Run when a new game starts. Reset the current score.
func _on_new_game_started() -> void:
	_distance_clock.reset()
	_set_score(0)


## Run when the [GameOverGUICard] is cleared. Save and display the high score.
func _on_game_over_cleared() -> void:
	if _score > _high_score:
		_high_score = _score
		Config.set_int("progress/high_score", _high_score)
	
	_set_score(_high_score)


## Run when the [DistanceClock] reaches a distance. Increment and display the
## current score.
func _on_distance_clock_distance_reached() -> void:
	if _score % 10 == 9 and _score < 30:
		Global.energy_added.emit()
	
	_set_score(_score + 1)
