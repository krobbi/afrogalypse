## A display for the current score and high score.
class_name ScoreCounter
extends PanelContainer

## The current score.
var _score: int = 0

## The high score.
var _high_score: int = 0

## The [Label] to display the score on.
@onready var _label: Label = $Label

## Run when the score counter is ready. Get the high score and subscribe the
## score counter to event [Signal]s.
func _ready() -> void:
	_high_score = maxi(Config.get_int("progress/high_score"), 0)
	_on_score_changed(_high_score)
	Event.subscribe(Event.score_changed, _on_score_changed)
	Event.subscribe(Event.game_over_cleared, _on_game_over_cleared)


## Run when the score changes. Display the score.
func _on_score_changed(score: int) -> void:
	_score = score
	
	if _high_score > _score:
		_label.text = "%dm\nHI %dm" % [_score, _high_score]
	else:
		_label.text = "%dm" % _score


## Run when the [GameOverGUICard] is cleared. Save and display the high score.
func _on_game_over_cleared() -> void:
	if _score > _high_score:
		_high_score = _score
		Config.set_int("progress/high_score", _high_score)
	
	_on_score_changed(_high_score)
