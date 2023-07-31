## An indicator [Sprite2D] used by an [EnergyCounter] to represent a spare
## energy point.
class_name EnergyPoint
extends Sprite2D

## Run when the energy point is ready. Fade the energy point in.
func _ready() -> void:
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.1)


## Fade the energy point out and free it.
func deplete() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
	await tween.finished
	queue_free()
