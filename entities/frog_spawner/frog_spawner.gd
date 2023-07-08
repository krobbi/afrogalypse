extends Marker2D

# Frog Spawner

@export var frog_scene: PackedScene
@export var bottom_right: Marker2D
@export var delay: float = 0.1
@export var count: int = 5

var timer: float = 0.0

func _physics_process(delta: float) -> void:
	if Global.state != Global.GameState.GAME:
		timer = 0.0
		return
	
	timer -= delta
	
	if timer <= 0.0:
		timer += delay
		
		for i in range(count):
			spawn_frog()


func spawn_frog() -> void:
	var frog: Frog = frog_scene.instantiate()
	frog.position.x = Global.rng.randf_range(0.0, bottom_right.position.x)
	frog.position.y = Global.rng.randf_range(0.0, bottom_right.position.y)
	add_child(frog)
