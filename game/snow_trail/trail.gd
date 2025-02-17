extends Line2D

@export var node_tracked: Node2D
@export var min_distance_between_points: float = 4


# TODO: how to handle collision/detection of trails by enemies?
# TODO: fading of tracks based on weather conditions & time elapsed
# TODO: how to use gradient across width of line? (line2d's built-in gradients
# seem to work over the length)
func _physics_process(_delta):
	var pos: Vector2 = node_tracked.global_position
	if points.size() > 1 and points[-1].distance_to(pos) >= min_distance_between_points:
		add_point(node_tracked.global_position)
	else:
		add_point(node_tracked.global_position)
