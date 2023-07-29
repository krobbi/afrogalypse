## The visual effects used by a [Car] when boosting.
class_name BoostEffects
extends Marker2D

@onready var _particles: GPUParticles2D = $Particles
@onready var _light: PointLight2D = $Light

## Enable the boost effects.
func enable() -> void:
	_particles.show()
	_particles.emitting = true
	_light.show()


## Disable the boost effects.
func disable() -> void:
	_particles.emitting = false
	_light.hide()
