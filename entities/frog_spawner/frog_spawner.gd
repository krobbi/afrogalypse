extends Marker2D

# Frog Spawner

enum SpawnFacing { LEFT, RIGHT, BOTH }

@export var frog_scene: PackedScene
@export var bottom_right: Marker2D
@export var delay: float = 0.1
@export var min_count: int = 5
@export var max_count: int = 5
@export var spawn_facing: SpawnFacing = SpawnFacing.RIGHT
@export var difficulty_curve: float = 5.0

var timer: float = 0.0

func _physics_process(delta: float) -> void:
	if Global.state != Global.GameState.GAME:
		timer = 0.0
		return
	
	timer -= delta
	
	if timer <= 0.0:
		timer += delay
		
		var scaled_max: int = max_count + int(Global.no_hit_time * difficulty_curve)
		
		for i in range(Global.rng.randi_range(min_count, scaled_max)):
			spawn_frog()


func spawn_frog() -> void:
	var frog: Frog = frog_scene.instantiate()
	frog.position.x = Global.rng.randf_range(0.0, bottom_right.position.x)
	frog.position.y = Global.rng.randf_range(0.0, bottom_right.position.y)
	
	match spawn_facing:
		SpawnFacing.LEFT:
			frog.flip_left()
		SpawnFacing.BOTH:
			if bool(Global.rng.randi() % 2):
				frog.flip_left()
	
	add_child(frog)
