extends Sprite2D

signal debug(message: String)

@export var wheel_attack: float = 4.0
@export var wheel_release: float = 3.0

@export var brake_attack: float = 5.0
@export var brake_release: float = 2.0

@export var pivot_amount: float = 0.6
@export var brake_pivot_amount: float = 0.4

@export var turn_amount: float = 128.0
@export var brake_turn_amount: float = -256.0

var wheel_position: float = 0.0
var brake_position: float = 0.0

func _physics_process(delta: float) -> void:
	var steer_axis: float = Input.get_axis("steer_left", "steer_right")
	
	if steer_axis:
		wheel_position = clampf(wheel_position + steer_axis * wheel_attack * delta, -1.0, 1.0)
	else:
		var wheel_position_sign: float = sign(wheel_position)
		wheel_position = wheel_position - wheel_release * wheel_position_sign * delta
		
		if sign(wheel_position) != wheel_position_sign:
			wheel_position = 0.0
	
	if Input.is_action_pressed("brake"):
		brake_position = min(brake_position + brake_attack * delta, 1.0)
	else:
		brake_position = max(brake_position - brake_release * delta, 0.0)
	
	rotation = wheel_position * (pivot_amount + brake_position * brake_pivot_amount)
	position.x += wheel_position * (turn_amount + brake_position * brake_turn_amount) * delta
	
	debug.emit("Wheel: %f\nBrake: %f" % [wheel_position, brake_position])
