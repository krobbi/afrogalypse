## A [GUICard] that displays a tutorial before exiting to the options menu or
## starting a new game.
class_name TutorialGUICard
extends GUICard

## The images and text to display for the tutorial.
const _TUTORIAL: Array[String] = [
	"!story",
	"tutorial.story.premise",
	"tutorial.story.goal",
	"tutorial.dodging.avoid_frogs",
	"tutorial.dodging.control.steer",
	"tutorial.dodging.control.brake",
	"tutorial.dodging.drift",
	"!signs",
	"tutorial.signs.gain_energy",
	"tutorial.signs.protect_car",
	"!boosting",
	"tutorial.boosting.use_energy",
	"tutorial.boosting.control",
	"tutorial.end",
]

## The current line in the tutorial.
var _tutorial_line: int = 0

## The [TextureRect] to display tutorial images on.
@onready var _tutorial_texture: TextureRect = $VBoxContainer/TutorialTexture

## The [Label] to display tutorial text on.
@onready var _tutorial_label: Label = $VBoxContainer/TutorialLabel

## The [AudioStreamPlayer] that is played when the tutorial is continued.
@onready var _continue_player: AudioStreamPlayer = $ContinuePlayer

## The [AudioStreamPlayer] that is played when the tutorial is finished.
@onready var _finished_player: AudioStreamPlayer = $FinishedPlayer

## Run when the tutorial GUI card is ready. Display the current line of the
## tutorial.
func _ready() -> void:
	_display_tutorial()


## Display the current line of the tutorial.
func _display_tutorial() -> void:
	if _TUTORIAL[_tutorial_line].begins_with("!"):
		_tutorial_texture.texture = load(
				"res://resources/textures/tutorial/%s.png" % _TUTORIAL[_tutorial_line].substr(1))
		_tutorial_line += 1
	
	_tutorial_label.text = _TUTORIAL[_tutorial_line]


## Run when the continue button is pressed. Continue to the next line of the
## tutorial or close the tutorial if it is finished.
func _on_continue_button_pressed() -> void:
	_tutorial_line += 1
	
	if _tutorial_line >= len(_TUTORIAL):
		if not _finished_player.playing:
			_finished_player.play()
		
		await _finished_player.finished
		Config.set_bool("progress/has_seen_tutorial", true)
		
		if Global.is_main_card:
			Global.new_game()
			close_card()
		else:
			change_card("options")
	else:
		_continue_player.play()
		_display_tutorial()
