extends PanelContainer

var score: int = 0

@onready var label: Label = $Label
@onready var distance_clock: DistanceClock = $DistanceClock

func _ready() -> void:
	set_score(Global.high_score)
	Global.new_game_started.connect(_on_new_game_started)
	Global.game_over_cleared.connect(_on_game_over_cleared)


func _on_new_game_started() -> void:
	distance_clock.reset()
	set_score(0)


func _on_game_over_cleared() -> void:
	if score > Global.high_score:
		Global.high_score = score
		Global.save_data()
	
	set_score(Global.high_score)


func _on_distance_clock_distance_reached() -> void:
	if score % 10 == 9 and score < 30:
		Global.energy_added.emit()
	
	set_score(score + 1)


func set_score(value: int) -> void:
	score = value
	
	if Global.high_score > score:
		label.text = "%dm\nHI %dm" % [score, Global.high_score]
	else:
		label.text = "%dm" % score
