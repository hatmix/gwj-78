extends Camera2D


func zoom_to_position(global_pos: Vector2, duration: float = 0.25) -> void:
	var tween: Tween = create_tween()
	#tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel()
	tween.tween_property(self, "global_position", global_pos, duration)
	tween.tween_property(self, "zoom", Vector2.ONE * 8, duration)
	await tween.finished
