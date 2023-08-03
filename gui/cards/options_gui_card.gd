## A [GUICard] containing the options.
class_name OptionsGUICard
extends GUICard

## The [HSlider] to control the sound volume with.
@onready var _sound_slider: HSlider = $VBoxContainer/GridContainer/SoundSlider

## The [HSlider] to control the music volume with.
@onready var _music_slider: HSlider = $VBoxContainer/GridContainer/MusicSlider

## The [AudioStreamPlayer] to play when the sound volume changes.
@onready var _blip_player: AudioStreamPlayer = $BlipPlayer

## Run when the options GUI card is ready. Notify the game that the main menu is
## not active and connect the volume [HSlider]s to updating the volume config.
func _ready() -> void:
	Global.is_main_card = false
	_sound_slider.value = Config.get_float("volume/sound")
	_sound_slider.value_changed.connect(_on_sound_slider_value_changed)
	_music_slider.value = Config.get_float("volume/music")
	_music_slider.value_changed.connect(_on_music_slider_value_changed)


## Run when the options GUI card exits the scene tree. Disconnect the volume
## [HSlider]s from updating the volume config.
func _exit_tree() -> void:
	_sound_slider.value_changed.disconnect(_on_sound_slider_value_changed)
	_music_slider.value_changed.disconnect(_on_music_slider_value_changed)


## Run when the sound volume [HSlider] is changed. Update the sound volume
## config and play a blip sound.
func _on_sound_slider_value_changed(value: float) -> void:
	Config.set_int("volume/sound", int(value))
	_blip_player.play()


## Run when the music volume [HSlider] is changed. Update the music volume
## config.
func _on_music_slider_value_changed(value: float) -> void:
	Config.set_int("volume/music", int(value))
