## The player controlled car entity.
class_name Car
extends Sprite2D

## The car's speed in pixels per second.
static var speed: float = 0.0

## A state of the car.
enum State {
	IDLE, ## The car is not in an in-game state.
	STARTING, ## The car is accelerating for the game state.
	GAME, ## The car is in an in-game state.
	STOPPING, ## The car is stopping for a game over.
}

## The rate to gain difficulty per second.
const _DIFFICULTY_GAIN: float = 0.01

## The amount to multiply difficulty by after getting hit.
const _DIFFICULTY_DROP: float = 0.6

## The rate from neutral to full steering per second.
const _WHEEL_ATTACK: float = 6.0

## The rate from full to neutral steering per second.
const _WHEEL_RELEASE: float = 6.0

## The rate from no to full braking per second.
const _BRAKE_ATTACK: float = 5.0

## The rate from full to no braking per second.
const _BRAKE_RELEASE: float = 2.0

## The amount to rotate the car in radians.
const _PIVOT_AMOUNT: float = 0.6

## The amount to rotate the car in radians from braking.
const _BRAKE_PIVOT_AMOUNT: float = -0.4

## The amount to move the car sideways in pixels per second.
const _TURN_SPEED: float = 150.0

## The amount to move the car sideways in pixels per second from braking.
const _BRAKE_TURN_SPEED: float = -240.0

## The minimum time between boosts in seconds.
const _BOOST_PERIOD: float = 12.0

## The rate to lose boosting per second.
const _BOOST_DECAY: float = 0.2

## The target speed to start the car at.
const _START_SPEED: float = 200.0

## The maximum target speed to accelerate to.
const _MAX_SPEED: float = 250.0

## The speed to accelerate to at the start of a boost.
const _BOOST_SPEED: float = 600.0

## The amount to multiply the car's speed by when braking.
const _BRAKE_SPEED_MULTIPLIER: float = 0.8

## The car's acceleration in pixels per second per second when starting.
const _START_ACCELERATION: float = 50.0

## The car's acceleration in pixels per second per second during gameplay.
const _GAME_ACCELERATION: float = 1.0

## The car's deceleration in pixels per second per second when stopping.
const _STOP_DECELERATION: float = 200.0

## The car's [enum State].
var _state: State = State.IDLE

## The car's score.
var _score: int = 0

## The car's energy points.
var _energy: int = 0

## The car's difficulty from [code]0.0[/code] to [code]1.0[/code].
var _difficulty: float = 0.0

## The car's steering wheel position from [code]-1.0[/code] to [code]1.0[/code].
var _wheel_position: float = 0.0

## The car's brake pedal position from [code]0.KEY_0[/code] to [code]1.0[/code].
var _brake_position: float = 0.0

## The amount the car is boosting from [code]0.0[/code] to [code]1.0[/code].
var _boost_amount: float = 0.0

## The car's ideal speed without braking or boosting.
var _target_speed: float = 0.0

## The time in seconds until hitting a frog loses energy.
var _hit_cooldown: float = 0.0

## The time in seconds until the player can boost.
var _boost_cooldown: float = 0.0

## The [BoostEffects] to enable when the car is boosting.
@onready var _boost_effects: BoostEffects = $BoostMarker/BoostEffects

## The [AudioStreamPlayer2D] to play when a boost is used.
@onready var _boost_player: AudioStreamPlayer2D = $BoostMarker/BoostPlayer

## The [AudioStreamPlayer2D] to play when boosting becomes available.
@onready var _boost_cooldown_player: AudioStreamPlayer2D = $BoostCooldownPlayer

## The [AudioStreamPlayer2D] to play when the car hits a [Frog].
@onready var _hit_player: AudioStreamPlayer2D = $HitPlayer

## The [AudioStreamPlayer2D] that plays engine sounds.
@onready var _engine_player: AudioStreamPlayer2D = $EnginePlayer

## The [DistanceClock] to count the score with.
@onready var _distance_clock: DistanceClock = $DistanceClock

## Run when the car is ready. Subscribe the car to event [Signal]s.
func _ready() -> void:
	Event.subscribe(Event.new_game_started, _on_new_game_started)
	Event.subscribe(Event.sign_passed, _on_sign_passed)


## Run on every physics frame. Process the car's state.
func _physics_process(delta: float) -> void:
	match _state:
		State.STARTING:
			_process_starting_state(delta)
		State.GAME:
			_process_game_state(delta)
		State.STOPPING:
			_process_stopping_state(delta)
	
	_apply_speed()
	_boost_amount = maxf(_boost_amount - _BOOST_DECAY * delta, 0.0)


## Get the car's difficulty.
func get_difficulty() -> float:
	return _difficulty


## Set the car's score and emit [signal Event.score_changed].
func _set_score(value: int) -> void:
	_score = value
	Event.score_changed.emit(_score)


## Gain a duration of invincibility.
func _gain_invincibility(duration: float) -> void:
	_hit_cooldown = maxf(duration, _hit_cooldown)


## Gain an energy point if the maximum has not been reached and emit
## [signal Event.energy_gained].
func _gain_energy() -> void:
	if _energy < 5:
		_energy += 1
		_gain_invincibility(0.5)
		Event.energy_gained.emit()


## Lose an energy point if available and emit [signal Event.energy_lost].
func _lose_energy() -> void:
	if _energy > 0:
		_energy -= 1
		Event.energy_lost.emit()


## Play a hit sound with an intensity.
func _play_hit(intensity: float) -> void:
	_hit_player.volume_db = (1.0 - intensity) * -10.0
	randomize()
	_hit_player.pitch_scale = 1.0 + (1.0 - intensity) + randf_range(-0.05, 0.05)
	_hit_player.play()


## Update the car's real speed from its target speed.
func _apply_speed() -> void:
	var boosted_speed: float = lerpf(_target_speed, _BOOST_SPEED, _boost_amount)
	var braked_speed: float = lerpf(
			boosted_speed, boosted_speed * _BRAKE_SPEED_MULTIPLIER, _brake_position)
	speed = braked_speed
	_engine_player.pitch_scale = maxf(speed * 0.005, 0.01)


## Update the car's steering, braking, position, and rotation.
func _handle_input(delta: float, can_steer: bool) -> void:
	var steer_axis: float = Input.get_axis("steer_left", "steer_right") if can_steer else 0.0
	
	if steer_axis:
		_wheel_position = clampf(_wheel_position + steer_axis * _WHEEL_ATTACK * delta, -1.0, 1.0)
	else:
		var wheel_position_sign: float = signf(_wheel_position)
		_wheel_position = _wheel_position - _WHEEL_RELEASE * wheel_position_sign * delta
		
		if signf(_wheel_position) != wheel_position_sign:
			_wheel_position = 0.0
	
	if can_steer and Input.is_action_pressed("brake"):
		_brake_position = minf(_brake_position + _BRAKE_ATTACK * delta, 1.0)
	else:
		_brake_position = maxf(_brake_position - _BRAKE_RELEASE * delta, 0.0)
	
	rotation = _wheel_position * (_PIVOT_AMOUNT + _brake_position * _BRAKE_PIVOT_AMOUNT)
	position.x = clampf(
			position.x
			+ _wheel_position * (_TURN_SPEED + _brake_position * _BRAKE_TURN_SPEED) * delta,
			56.0, 264.0
	)


## Process the car's starting [enum State]. Emit [signal Event.level_started]
## when the car has started.
func _process_starting_state(delta: float) -> void:
	_target_speed = minf(_target_speed + _START_ACCELERATION * delta, _START_SPEED)
	_handle_input(delta, true)
	
	if _target_speed >= _START_SPEED and not get_tree().get_first_node_in_group("frogs"):
		_state = State.GAME
		Event.level_started.emit()


## Process the car's game [enum State].
func _process_game_state(delta: float) -> void:
	_target_speed = minf(_target_speed + _GAME_ACCELERATION * delta, _MAX_SPEED)
	
	if _boost_cooldown > 0.0:
		_boost_cooldown -= delta
		
		if _boost_cooldown <= 0.0:
			_boost_cooldown_player.play()
			Event.boost_available.emit()
	
	if _energy > 0 and _boost_cooldown <= 0.0 and Input.is_action_just_pressed("boost"):
		_boost_cooldown = _BOOST_PERIOD
		_boost_amount = 1.0
		_lose_energy()
		_boost_effects.enable()
		_boost_player.play()
		Event.boost_used.emit()
	
	_handle_input(delta, true)
	
	_difficulty = minf(_difficulty + _DIFFICULTY_GAIN * delta, 1.0)
	
	if _hit_cooldown > 0.0:
		_hit_cooldown = maxf(_hit_cooldown - delta, 0.0)
		material.set_shader_parameter("flash_amount", minf(_hit_cooldown, 1.0))
	
	if _boost_amount <= 0.0:
		_boost_effects.disable()
	
	if Input.is_action_just_pressed("pause"):
		Event.game_paused.emit()


## Process the car's stopping [enum State]. Emit [signal Event.game_over] when
## the car has stopped.
func _process_stopping_state(delta: float) -> void:
	_target_speed = maxf(_target_speed - _STOP_DECELERATION * delta, 0.0)
	_handle_input(delta, false)
	
	if speed <= 0.0:
		_state = State.IDLE
		_engine_player.stop()
		Event.game_over.emit()


## Run when a new game starts. Reset the stats.
func _on_new_game_started() -> void:
	_state = State.STARTING
	_difficulty = 0.0
	_energy = 0
	_distance_clock.reset()
	_set_score(0)
	_hit_cooldown = 2.0
	_boost_cooldown = 0.01
	_engine_player.play()


## Run when the car passes a sign. Gain an energy point.
func _on_sign_passed() -> void:
	if _state == State.GAME or _state == State.STARTING:
		_gain_energy()


## Run when the [DistanceClock] reaches a distance. Increment the current score.
func _on_distance_clock_distance_reached() -> void:
	if _score % 10 == 9 and _score < 30:
		_gain_energy() # Gain energy at 10, 20, and 30 points.
	
	_set_score(_score + 1)


## Run when a [Frog] is hit. Hit the [Frog], adjust the difficulty and lose an
## energy point if vulnerable. Emit [signal Event.level_finished] if the energy
## points are depleted.
func _on_frog_hit(frog: Frog) -> void:
	frog.hit(speed * 0.25)
	
	if _hit_cooldown <= 0.0 and _boost_amount <= 0.0 and _state == State.GAME:
		_difficulty *= _DIFFICULTY_DROP
		
		if _energy > 0:
			_gain_invincibility(1.5)
			_play_hit(1.0)
			_lose_energy()
		else:
			_play_hit(1.4)
			_state = State.STOPPING
			Event.level_finished.emit()
	else:
		_play_hit(0.2)
