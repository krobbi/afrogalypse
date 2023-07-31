## A GUI element representing a stack of the player's spare [EnergyPoint]s.
class_name EnergyCounter
extends Marker2D

## The [PackedScene] to instantiate [EnergyPoint]s from.
@export var _point_scene: PackedScene

## The energy counter's stack of [EnergyPoint]s.
var _points: Array[EnergyPoint] = []

## The time in seconds until an [EnergyPoint] may be lost again.
var _remove_cooldown: float = 0.0

## The time in seconds until the player may boost again.
var _boost_cooldown: float = 0.0

## The [AudioStreamPlayer] to play when energy is gained.
@onready var _gain_player: AudioStreamPlayer = $GainPlayer

## The [AudioStreamPlayer] to play when energy is lost.
@onready var _lose_player: AudioStreamPlayer = $LosePlayer

## The [AudioStreamPlayer] to play when the boost cooldown ends.
@onready var _cooldown_player: AudioStreamPlayer = $CooldownPlayer

## Run when the energy counter is ready. Connect the energy counter to event
## signals.
func _ready() -> void:
	Global.new_game_started.connect(_reset)
	Global.energy_removed.connect(_remove_point.bind(true))


## Run on every physics frame. Update the energy counter's cooldown timers and
## tint the energy counter if the player boosted.
func _physics_process(delta: float) -> void:
	if _remove_cooldown > 0.0:
		_remove_cooldown -= delta
	
	if _boost_cooldown > 0.0:
		_boost_cooldown -= delta
		
		if _boost_cooldown <= 0.0:
			create_tween().tween_property(self, "modulate", Color.WHITE, 0.1)
			
			if len(_points) > 0:
				_cooldown_player.play()
	
	if (
			Global.state == Global.GameState.GAME
			and _boost_cooldown <= 0.0
			and Input.is_action_just_pressed("boost")
			and len(_points) > 0):
		_remove_point(false)
		create_tween().tween_property(self, "modulate", Color(0.5, 0.25, 0.25, 1.0), 0.1)
		_boost_cooldown = 12.0
		Global.boost_used.emit()


## Reset the energy counter's cooldowns timers and tint.
func _reset() -> void:
	_remove_cooldown = 2.0
	_boost_cooldown = 0.0
	modulate = Color.WHITE


## Remove an [EnergyPoint] and play a sound if [param play_sound] is
## [code]true[/code].
func _remove_point(play_sound: bool) -> void:
	if _remove_cooldown > 0.0:
		return
	
	if len(_points) < 1:
		_lose_player.pitch_scale = 0.75
		_lose_player.play()
		Global.on_energy_depleted()
		return
	
	var point: EnergyPoint = _points.pop_back()
	point.deplete()
	
	if play_sound:
		_lose_player.pitch_scale = 1.0
		_lose_player.play()
	
	_remove_cooldown = 1.5


## Run when energy is gained. Add an [EnergyPoint].
func _on_energy_gained() -> void:
	if len(_points) >= 5:
		return
	
	var point: EnergyPoint = _point_scene.instantiate()
	point.position.y = len(_points) * -16.0
	randomize()
	point.position.x = randf_range(-2.0, 2.0)
	point.position.y += randf_range(-1.0, 1.0)
	add_child(point)
	_points.push_back(point)
	_gain_player.pitch_scale = 0.5 + 0.1 * len(_points)
	_gain_player.play()
	
	if _remove_cooldown < 0.5:
		_remove_cooldown = 0.5
