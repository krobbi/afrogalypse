extends GUICard

const STORY: Array[String] = [
	"The plague of robotic frogs\nhas descended upon the city.",
	"Maybe you can escape if\nyou take to the road.",
	"Beware of crossing frogs.\nThey will damage your car.",
	"WASD / Arrow Keys:\nSteer",
	"Shift / X:\nBrake",
	"!sign",
	"As you pass signs you will\ngain energy.",
	"This will protect your\ncar from an additional hit.",
	"!boost",
	"Or you can use it for\na boost.",
	"Space / Z:\nBoost",
	"Good luck.",
]

var story_line: int = 0

@onready var label: Label = $VBoxContainer/Label
@onready var next_player: AudioStreamPlayer = $NextPlayer
@onready var done_player: AudioStreamPlayer = $DonePlayer
@onready var story_image: TextureRect = $VBoxContainer/TextureRect

func _ready() -> void:
	display_story()


func display_story() -> void:
	if STORY[story_line].begins_with("!"):
		story_image.texture = load(
				"res://resources/textures/gui/story/%s.png" % STORY[story_line].substr(1))
		story_line += 1
	
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
