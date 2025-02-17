extends Enemy


func _input(event: InputEvent) -> void:
	# FIXME: Drone movement
	direction = Input.get_vector("Move Right", "Move Left", "Move Down", "Move Up")
	if not direction:
		if randi_range(0, 1):
			direction = global_position.direction_to(Vector2(160, 90))
		else:
			direction = -global_position.direction_to(Vector2(160, 90))
