class_name VisionCone
extends Area2D

signal seen
signal lost

@export var raycast: RayCast2D

var stickman: Stickman = null
var is_visible: bool = false

func _ready() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if not stickman:
		return
	
	raycast.target_position = stickman.position - global_position
	raycast.force_raycast_update()
	update_visible(raycast.get_collider() == stickman)


func update_visible(value: bool) -> void:
	if value == is_visible:
		return
	
	if value:
		is_visible = true
		Events.stickman_seen.emit()
	else:
		is_visible = false
		Events.stickman_lost.emit()


func _on_body_entered(body: Node2D) -> void:
	stickman = body
	set_physics_process(true)


func _on_body_exited(_body: Node2D) -> void:
	set_physics_process(false)
	update_visible(false)
