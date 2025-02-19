class_name Trail
extends Line2D

@export var node_tracked: Node2D
@export var min_distance_between_points: float = 4
@export var points_between_areas: float = 3

var points_since_area_count: int = 0

# lookup of area nodes by points' global coords for erasing trails
var areas: Dictionary = {}

# lookup points index by node tracking
var trackers: Dictionary = {}


# TODO: think about possible memory leaks with all these refs stored
func register_tracker(tracker: Node, area: Area2D) -> bool:
	if area not in areas.values():
		return false
	var idx: int = points.find(area.global_position)
	if idx == -1:
		return false
	trackers[tracker] = idx
	print(trackers)
	return true


func unregister_tracker(tracker: Node) -> void:
	trackers.erase(tracker)


func get_next_path_point(tracker) -> Variant:
	if tracker not in trackers:
		return
	trackers[tracker] += 1
	if trackers[tracker] >= points.size():
		return
	return points[trackers[tracker]]


func add_area(global_pos: Vector2) -> void:
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = min_distance_between_points * points_between_areas / 2

	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = shape

	var area: Area2D = Area2D.new()
	area.set_collision_layer_value(3, true)
	area.monitoring = false
	area.monitorable = true
	area.add_to_group("Trails")
	area.add_child(collision)
	add_child(area)
	area.global_position = global_pos
	areas[global_pos] = area


# TODO: fading of tracks based on weather conditions & time elapsed
# TODO: how to use gradient across width of line? (line2d's built-in gradients
# seem to work over the length)
func _physics_process(_delta):
	var pos: Vector2 = node_tracked.global_position
	if points.size() == 0:
		add_point(pos)
		add_area(pos)
	elif points[-1].distance_to(pos) >= min_distance_between_points:
		add_point(pos)
		points_since_area_count += 1
	if points_since_area_count >= points_between_areas:
		#print("adding area to trail at %.1v" % pos)
		points_since_area_count = 0
		add_area(pos)
