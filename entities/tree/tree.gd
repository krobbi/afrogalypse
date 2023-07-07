extends StaticBody2D

const HIDE_MODULATE: Color = Color(1.0, 1.0, 1.0, 0.25)

func _on_hide_area_body_entered(_body: Node2D) -> void:
	create_tween().tween_property(self, "modulate", HIDE_MODULATE, 1.0)


func _on_hide_area_body_exited(_body: Node2D) -> void:
	create_tween().tween_property(self, "modulate", Color.WHITE, 1.0)
