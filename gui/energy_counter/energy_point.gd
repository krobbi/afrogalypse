class_name EnergyPoint
extends Sprite2D

func _ready() -> void:
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.1)


func deplete() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.1)
	await tween.finished
	queue_free()
