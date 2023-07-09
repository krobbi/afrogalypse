class_name EnergyCounter
extends Marker2D

@export var point_scene: PackedScene

var points: Array[EnergyPoint] = []
var remove_cooldown: float = 0.0
var boost_cooldown: float = 0.0

@onready var gain_player: AudioStreamPlayer = $GainPlayer
@onready var deplete_player: AudioStreamPlayer = $DepletePlayer

func _ready() -> void:
	Global.new_game_started.connect(reset)
	Global.energy_added.connect(add_point)
	Global.energy_removed.connect(remove_energy)


func remove_energy() -> void:
	remove_point(true)


func _physics_process(delta: float) -> void:
	if remove_cooldown > 0.0:
		remove_cooldown -= delta
	
	if boost_cooldown > 0.0:
		boost_cooldown -= delta
		modulate = Color(0.5, 0.25, 0.25, 1.0)
	else:
		modulate = Color.WHITE
	
	if (
			Global.state == Global.GameState.GAME
			and boost_cooldown <= 0.0
			and remove_cooldown <= 0.0
			and Input.is_action_just_pressed("boost")
			and len(points) > 0):
		remove_point(false)
		boost_cooldown = 10.0
		Global.boost_used.emit()


func reset() -> void:
	remove_cooldown = 2.0
	boost_cooldown = 2.0


func add_point() -> void:
	if len(points) >= 5:
		return
	
	var point: EnergyPoint = point_scene.instantiate()
	point.position.y = len(points) * -16.0
	randomize()
	point.position.x = randf_range(-2.0, 2.0)
	point.position.y += randf_range(-1.0, 1.0)
	add_child(point)
	points.push_back(point)
	gain_player.pitch_scale = 0.5 + 0.1 * len(points)
	gain_player.play()
	
	if remove_cooldown < 0.5:
		remove_cooldown = 0.5


func remove_point(play_sound: bool) -> void:
	if remove_cooldown > 0.0:
		return
	
	if len(points) < 1:
		deplete_player.pitch_scale = 0.75
		deplete_player.play()
		Global.on_energy_depleted()
		return
	
	var point: EnergyPoint = points.pop_back()
	point.deplete()
	
	if play_sound:
		deplete_player.pitch_scale = 1.0
		deplete_player.play()
	
	remove_cooldown = 1.5
