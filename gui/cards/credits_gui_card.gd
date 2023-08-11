## A [GUICard] that displays the credits.
class_name CreditsGUICard
extends GUICard

## The screens of credits to display.
const _CREDIT_SCREENS: Array[Array] = [
	["credits.game", "credits.game.copyright", "credits.game.license"],
	["credits.font", "credits.font.author", "credits.font.link"],
	["credits.palette", "credits.palette.author", "credits.palette.link"],
	["credits.godot"],
]

## The current screen in the credits.
var _credits_screen: int = 0

## The [Label] to display the credits to.
@onready var _credits_label: Label = $VBoxContainer/CreditsLabel

## The [AudioStreamPlayer] to play when the credits are continued.
@onready var _continue_player: AudioStreamPlayer = $ContinuePlayer

## The [AudioStreamPlayer] to play when the credits are finished.
@onready var _finished_player: AudioStreamPlayer = $FinishedPlayer

## Run when the credits gui card is ready. Display the first screen of credits.
func _ready() -> void:
	_display_credits()


## Display the current screen of credits.
func _display_credits() -> void:
	var text: String = ""
	
	for credit in _CREDIT_SCREENS[_credits_screen]:
		text += "%s\n" % tr(credit)
	
	_credits_label.text = text.trim_suffix("\n")


## Run when the continue [Button] is pressed. Display the next screen of credits
## or close the credits if they are finished.
func _on_continue_button_pressed() -> void:
	_credits_screen += 1
	
	if _credits_screen < _CREDIT_SCREENS.size():
		_continue_player.play()
		_display_credits()
	else:
		if not _finished_player.playing:
			_finished_player.play()
		
		await _finished_player.finished
		pop_card()
