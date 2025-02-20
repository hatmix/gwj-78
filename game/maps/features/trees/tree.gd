extends StaticBody2D


func _ready() -> void:
	# Hide Visual 1 or Visual 2 or neither for tree variations
	match [1, 2, 3].pick_random():
		1:
			$Visual.visible = false
		2:
			$Visual2.visible = false
		3:
			pass
