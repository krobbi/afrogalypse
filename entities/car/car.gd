## The player controlled car entity.
class_name Car
extends Sprite2D

## Emitted when the score changes.
signal score_changed(score: int)

## Emitted when energy is gained.
signal energy_gained

## Emitted when energy is lost.
signal energy_lost

## Emitted when a boost is used.
signal boost_used

## Emitted when a boost is available.
signal boost_available

## Emitted when the car stops.
signal stopped

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

## The player's energy points.
var _energy: int = 0

## The player's current score.
var _score: int = 0

## The time in seconds until hitting a frog loses energy.
var _hit_cooldown: float = 0.0

## The time in seconds until the player can boost.
var _boost_cooldown: float = 0.0

@onready var _boost_player: AudioStreamPlayer2D = $BoostMarker/BoostPlayer
@onready var _boost_effects: BoostEffects = $BoostMarker/BoostEffects

## The [AudioStreamPlayer2D] to play when the car hits something.
@onready var _hit_player: AudioStreamPlayer2D = $HitPlayer

## The [AudioStreamPlayer2D] to play when boosting becomes available.
@onready var _boost_cooldown_player: AudioStreamPlayer2D = $BoostCooldownPlayer

## The [DistanceClock] to count the score with.
@onready var _distance_clock: DistanceClock = $DistanceClock

## Run when the car is ready. Connect to event signals.
func _ready() -> void:
	Global.new_game_started.connect(_on_new_game_started)


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
	
	if _boost_cooldown > 0.0:
		_boost_cooldown -= delta
		
		if _boost_cooldown <= 0.0:
			_boost_cooldown_player.play()
			boost_available.emit()
	
	if _energy > 0 and _boost_cooldown <= 0.0 and Input.is_action_just_pressed("boost"):
		_boost_cooldown = 12.0
		boost_amount = 1.0
		_lose_energy()
		_boost_effects.enable()
		_boost_player.play()
		boost_used.emit()
	
	handle_input(delta, true)
	
	Global.no_hit_time = minf(Global.no_hit_time + delta, 100.0)
	_hit_cooldown = maxf(_hit_cooldown - delta, 0.0)
	
	if boost_amount <= 0.0:
		_boost_effects.disable()


## Process the car's stopping state. Emit [signal stopped] when the car has
## stopped.
func stopping_state(delta: float) -> void:
	target_speed = maxf(target_speed - stop_deceleration * delta, 0.0)
	handle_input(delta, false)
	
	if Global.speed <= 0.0:
		Global.state = Global.GameState.IDLE
		stopped.emit()


## Set the score and emit [signal score_changed].
func _set_score(value: int) -> void:
	_score = value
	score_changed.emit(_score)


## Gain an energy point if the maximum has not been reached and emit
## [signal energy_gained].
func _gain_energy() -> void:
	if _energy < 5:
		_energy += 1
		_hit_cooldown = maxf(_hit_cooldown, 0.5)
		energy_gained.emit()


## Lose an energy point if available and emit [signal energy_lost].
func _lose_energy() -> void:
	if _energy > 0:
		_energy -= 1
		energy_lost.emit()


## Run when a new game starts. Reset the stats.
func _on_new_game_started() -> void:
	_energy = 0
	_distance_clock.reset()
	_set_score(0)
	_hit_cooldown = 2.0
	_boost_cooldown = 0.01


## Run when the car passes a sign. Gain an energy point.
func _on_sign_passed() -> void:
	if Global.state == Global.GameState.GAME or Global.state == Global.GameState.STARTING:
		_gain_energy()


## Run when the [DistanceClock] reaches a distance. Increment the current score.
func _on_distance_clock_distance_reached() -> void:
	if _score % 10 == 9 and _score < 30:
		_gain_energy() # Gain energy at 10, 20, and 30 points.
	
	_set_score(_score + 1)


## Run when a [Frog] is hit. Hit the [Frog], adjust the difficulty and lose an
## energy point if vulnerable.
func _on_frog_hit(frog: Frog) -> void:
	frog.hit(Global.speed * 0.25)
	
	if _hit_cooldown <= 0.0 and boost_amount <= 0.0 and Global.state == Global.GameState.GAME:
		_hit_cooldown = 1.5
		Global.no_hit_time *= 0.6 # Reduce the difficulty a little.
		
		if _energy > 0:
			_hit_player.pitch_scale = 1.0
			_hit_player.play()
			_lose_energy()
		else:
			_hit_player.pitch_scale = 0.75
			_hit_player.play()
			Global.state = Global.GameState.STOPPING
