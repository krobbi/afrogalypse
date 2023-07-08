extends GUICard

const STORY: Array[String] = [
	"The plague of robotic frogs\nhas descended upon the city.",
	"Maybe you can escape if\nyou take to the road.",
	"Beware of crossing frogs.\nThey will damage your car.",
	"WASD / Arrow Keys:\nSteer",
	"Space / Z:\nBrake",
	"Good luck.",
]

var story_line: int = 0

@onready var label: Label = $VBoxContainer/Label
@onready var next_player: AudioStreamPlayer = $NextPlayer
@onready var done_player: AudioStreamPlayer = $DonePlayer

func _ready() -> void:
	display_story()


func display_story() -> void:
	label.text = STORY[story_line]


func _on_continue_button_pressed() -> void:
	story_line += 1
	
	if story_line >= len(STORY):
		if not done_player.playing:
			done_player.play()
		
		await done_player.finished
		
		if Global.is_main_card:
			Global.new_game()
			close_card()
		else:
			change_card("options")
	else:
		next_player.play()
		display_story()
