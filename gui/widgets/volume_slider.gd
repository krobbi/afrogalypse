## A GUI widget that controls the volume of an audio bus.
class_name VolumeSlider
extends HBoxContainer

## The key of the audio bus to control.
@export var _key: String

## Whether the volume slider should be a focus.
@export var _is_focus: bool = false

## The volume slider's [HSlider].
@onready var _slider: HSlider = $Slider

## The [AudioStreamPlayer] to play when the volume slider's value is changed.
@onready var _blip_player: AudioStreamPlayer = $BlipPlayer

## Run when the volume slider is ready. Initialize the volume slider's
## [Control]s.
func _ready() -> void:
	$Label.text = "slider.volume.%s" % _key
	
	if _is_focus:
		_slider.add_to_group("focus")
	
	_blip_player.bus = AudioManager.get_bus_name(_key)
	_slider.set_value_no_signal(AudioManager.get_bus_volume(_key))


## Emitted when the volume sliders [HSlider] changes. Set the configured audio
## bus' volume and play a blip sound.
func _on_slider_value_changed(value: float) -> void:
	AudioManager.set_bus_volume(_key, value)
	_blip_player.play()
