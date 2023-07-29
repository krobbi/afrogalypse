## The player controlled car entity.
class_name Car
extends Sprite2D

@export var wheel_attack: float = 6.0
@export var wheel_release: float = 6.0

@export var brake_attack: float = 5.0
@export var brake_release: float = 2.0

@export var pivot_amount: float = 0.6
@export var brake_pivot_amount: float = -0.4

@export var turn_amount: float = 150.0
@export var brake_turn_amount: float = -240.0

@export var start_speed: float = 200.0
@export var max_speed: float = 250.0
@export var boost_speed: float = 600.0
@export var start_acceleration: float = 50.0
@export var game_acceleration: float = 1.0
@export var stop_deceleration: float = 200.0
@export var brake_speed_mul: float = 0.8

var target_speed: float = 0.0
var wheel_position: float = 0.0
var brake_position: float = 0.0
var boost_amount: float = 0.0

@onready var _boost_player: AudioStreamPlayer2D = $BoostMarker/BoostPlayer
@onready var _boost_effects: BoostEffects = $BoostMarker/BoostEffects

func _ready() -> void:
	Global.boost_used.connect(apply_boost)


func _physics_process(delta: float) -> void:
	match Global.state:
		Global.GameState.STARTING:
			starting_state(delta)
		Global.GameState.GAME:
			game_state(delta)
		Global.GameState.STOPPING:
			stopping_state(delta)
	
	apply_speed()
	boost_amount = maxf(boost_amount - 0.2 * delta, 0.0)


func apply_boost() -> void:
	boost_amount = 1.0
	Global.is_boosting = true
	_boost_effects.enable()
	_boost_player.play()


func apply_speed() -> void:
	var boosted_speed: float = lerpf(target_speed, boost_speed, boost_amount)
	var braked_speed: float = lerpf(boosted_speed, boosted_speed * brake_speed_mul, brake_position)
	Global.speed = braked_speed


func handle_input(delta: float, can_steer: bool) -> void:
	var steer_axis: float = Input.get_axis("steer_left", "steer_right") if can_steer else 0.0
	
	if steer_axis:
		wheel_position = clampf(wheel_position + steer_axis * wheel_attack * delta, -1.0, 1.0)
	else:
		var wheel_position_sign: float = signf(wheel_position)
		wheel_position = wheel_position - wheel_release * wheel_position_sign * delta
		
		if signf(wheel_position) != wheel_position_sign:
			wheel_position = 0.0
	
	if can_steer and Input.is_action_pressed("brake"):
		brake_position = minf(brake_position + brake_attack * delta, 1.0)
	else:
		brake_position = maxf(brake_position - brake_release * delta, 0.0)
	
	rotation = wheel_position * (pivot_amount + brake_position * brake_pivot_amount)
	position.x = clampf(
			position.x
			+ wheel_position * (turn_amount + brake_position * brake_turn_amount) * delta,
			56.0, 264.0
	)


func starting_state(delta: float) -> void:
	target_speed = minf(target_speed + start_acceleration * delta, start_speed)
	handle_input(delta, true)
	
	if target_speed >= start_speed and not get_tree().get_first_node_in_group("frogs"):
		Global.state = Global.GameState.GAME


func game_state(delta: float) -> void:
	target_speed = minf(target_speed + game_acceleration * delta, max_speed)
	handle_input(delta, true)
	
	if Global.no_hit_time < 100.0:
		Global.no_hit_time += delta
	
	if boost_amount <= 0.0:
		Global.is_boosting = false
		_boost_effects.disable()


func stopping_state(delta: float) -> void:
	target_speed = maxf(target_speed - stop_deceleration * delta, 0.0)
	handle_input(delta, false)
	
	if Global.speed <= 0.0:
		Global.on_game_over()
