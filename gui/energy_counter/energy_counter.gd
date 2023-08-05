## A GUI element containing a stack of [EnergyPoint]s.
class_name EnergyCounter
extends Marker2D

## The [Color] to tint the display when boosts are unavailable.
const _TINT_COLOR: Color = Color("#ad1818")

## The [PackedScene] to instantiate [EnergyPoint]s from.
@export var _point_scene: PackedScene

## The energy counter's stack of [EnergyPoint]s.
var _points: Array[EnergyPoint] = []

## The [AudioStreamPlayer] to play when energy is gained.
@onready var _gain_player: AudioStreamPlayer = $GainPlayer

## Run when the energy counter is ready. Connect the energy counter to event
## [Signal]s.
func _ready() -> void:
	Event.on(Event.new_game_started, _on_boost_used)


## Run when energy is gained. Add an [EnergyPoint].
func _on_energy_gained() -> void:
	var point: EnergyPoint = _point_scene.instantiate()
	point.position.y = len(_points) * -16.0
	randomize()
	point.position.x = randf_range(-2.0, 2.0)
	point.position.y += randf_range(-1.0, 1.0)
	add_child(point)
	_points.push_back(point)
	_gain_player.pitch_scale = 0.5 + 0.1 * len(_points)
	_gain_player.play()


## Run when energy is lost. Remove an [EnergyPoint].
func _on_energy_lost() -> void:
	_points.pop_back().deplete()


## Run when a boost is used. Tint the display.
func _on_boost_used() -> void:
	create_tween().tween_property(self, "modulate", _TINT_COLOR, 0.1)


## Run when a boost is available. Untint the display.
func _on_boost_available() -> void:
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.1)
