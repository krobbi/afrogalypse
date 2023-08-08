## Spawns [Frog]s in batches in a rectangular area.
class_name FrogSpawner
extends Marker2D

## A direction to spawn a [Frog] in.
enum Direction {
	LEFT, ## [Frog] moves from right to left.
	RIGHT, ## [Frog] moves from left to right.
	BOTH, ## [Frog] moves in either direction.
}

## The [Car] to synchronize [Frog] spawning with.
@export var _car: Car

## The [Marker2D] forming the bottom right of the frog spawner's area.
@export var _bottom_right: Marker2D

## The direction the frog spawner spawns [Frog]s in.
@export var _direction: Direction = Direction.RIGHT

## The time between spawning batches of [Frog]s.
@export var _delay: float = 0.1

## The minimum number of [Frog]s to spawn in a batch.
@export var _min_count: int = 5

## The maximum number of [Frog]s to spawn in a batch.
@export var _max_count: int = 5

## The amount of [Frog]s to add to the maximum count at full difficulty.
@export var _difficulty_curve: float = 5.0

## The [PackedScene] to instantiate [Frog]s from.
@export var _frog_scene: PackedScene

## The frog spawner's [RandomNumberGenerator]
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

## The time in seconds until the next batch of [Frog]s is spawned.
var _timer: float = 0.0

## Run when the frog spawner is ready. Disable the frog spawner's physics
## process, set the [RandomNumberGenerator]'s seed, and subscribe the frog
## spawner to event [Signal]s.
func _ready() -> void:
	set_physics_process(false)
	_rng.seed = hash("[%d, %d]" % [position.x, position.y])
	Event.subscribe(Event.level_started, _on_level_started)
	Event.subscribe(Event.level_finished, _on_level_finished)


## Run on every physics frame while the frog spawner's physics process is
## enabled. Spawn batches of frogs when the timer elapses.
func _physics_process(delta: float) -> void:
	_timer -= delta
	
	if _timer <= 0.0:
		_timer += _delay
		
		var scaled_max: int = _max_count + int(_car.get_difficulty() * _difficulty_curve)
		
		for i in range(_rng.randi_range(_min_count, scaled_max)):
			var frog: Frog = _frog_scene.instantiate()
			frog.rng = _rng
			frog.position.x = _rng.randf_range(0.0, _bottom_right.position.x)
			frog.position.y = _rng.randf_range(0.0, _bottom_right.position.y)
			add_child(frog)
			
			match _direction:
				Direction.LEFT:
					frog.flip_left()
				Direction.BOTH:
					if _rng.randi() & 1:
						frog.flip_left()


## Run when a level starts. Reset the [RandomNumberGenerator] and start spawning
## [Frog]s.
func _on_level_started() -> void:
	_rng.state = hash("%d" % _rng.seed)
	_timer = 0.0
	set_physics_process(true)


## Run when a level finishes. Stop spawning [Frog]s.
func _on_level_finished() -> void:
	set_physics_process(false)
