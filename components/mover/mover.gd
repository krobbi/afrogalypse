extends Node

# Mover
# Moves a 2D node downwards to simulate player movement and despawns the node at
# a given point.

@export var node: Node2D
@export var despawn_position: float = 300.0

func _physics_process(delta: float) -> void:
	node.position.y += Global.speed * delta
	
	if node.global_position.y >= despawn_position:
		node.queue_free()
