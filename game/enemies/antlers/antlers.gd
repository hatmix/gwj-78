extends Enemy


func _input(event: InputEvent) -> void:
	# FIXME: Antlers only moves down and right in the reverse of player input for now
	direction = Input.get_vector("Move Right", "Move Left", "Move Down", "Move Up")
	direction = clamp(direction, Vector2.ZERO, Vector2.ONE)
