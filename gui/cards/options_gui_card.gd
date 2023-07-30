extends GUICard

@onready var sound_slider: HSlider = $VBoxContainer/GridContainer/SoundSlider
@onready var music_slider: HSlider = $VBoxContainer/GridContainer/MusicSlider
@onready var pip_player: AudioStreamPlayer = $PipPlayer

func _ready() -> void:
	Global.is_main_card = false
	sound_slider.value = Config.get_float("volume/sound")
	sound_slider.value_changed.connect(_on_sound_slider_value_changed)
	music_slider.value = Config.get_float("volume/music")
	music_slider.value_changed.connect(_on_music_slider_value_changed)


func _exit_tree() -> void:
	sound_slider.value_changed.disconnect(_on_sound_slider_value_changed)
	music_slider.value_changed.disconnect(_on_music_slider_value_changed)


func _on_sound_slider_value_changed(value: float) -> void:
	Config.set_float("volume/sound", value)
	pip_player.play()


func _on_music_slider_value_changed(value: float) -> void:
	Config.set_float("volume/music", value)
