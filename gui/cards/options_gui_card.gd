extends GUICard

@onready var sound_slider: HSlider = $VBoxContainer/GridContainer/SoundSlider
@onready var music_slider: HSlider = $VBoxContainer/GridContainer/MusicSlider
@onready var pip_player: AudioStreamPlayer = $PipPlayer

var has_changed_options: bool = false

func _ready() -> void:
	Global.is_main_card = false
	sound_slider.value = Global.sound_volume
	sound_slider.value_changed.connect(_on_sound_slider_value_changed)
	music_slider.value = Global.music_volume
	music_slider.value_changed.connect(_on_music_slider_value_changed)


func _exit_tree() -> void:
	sound_slider.value_changed.disconnect(_on_sound_slider_value_changed)
	music_slider.value_changed.disconnect(_on_music_slider_value_changed)
	
	if has_changed_options:
		Global.save_data()


func _on_sound_slider_value_changed(value: float) -> void:
	Global.set_sound_volume(value)
	pip_player.play()
	has_changed_options = true


func _on_music_slider_value_changed(value: float) -> void:
	Global.set_music_volume(value)
	has_changed_options = true
