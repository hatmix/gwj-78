class_name Trail
extends Node2D

#const COVER_POINT_SCENE: PackedScene = preload("res://game/components/snow_trail/cover_point.tscn")
const TRAIL_LINE_SCENE: PackedScene = preload("res://game/components/snow_trail/trail_line.tscn")

@export var node_tracked: Node2D
@export var snow_time_to_cover: float = 6.0
@export var min_distance_between_points: float = 4
@export var points_between_areas: float = 3

var points: Array[Vector2] = []

# how many seconds it has snowed since last snow cover update
var accumulation: float = 0
var points_since_area_count: int = 0

# for global_position points, how long has it been snowed on?
var snow_time: Dictionary = {}

# lookup of area nodes by points' global coords for erasing trails
var areas: Dictionary = {}

# lookup points index by node tracking
var trackers: Dictionary = {}
var last_track_step: int = [-1, 1].pick_random()

# lookup which line starts at point
var lines: Dictionary = {}
#var cover: Dictionary = {}

@onready var snow_cover_timer: Timer = $SnowCoverTimer


# TODO: think about possible memory leaks with all these refs stored
func register_tracker(tracker_node: Node, area: Area2D) -> bool:
	if area not in areas.values():
		return false
	var idx: int = points.find(area.global_position)
	if idx == -1:
		return false
	var tracker: Tracker = Tracker.new()
	tracker.idx = idx
	last_track_step = -last_track_step
	tracker.step = last_track_step
	trackers[tracker_node] = tracker
	#print(trackers)
	return true


func unregister_tracker(tracker_node: Node) -> void:
	trackers.erase(tracker_node)


func get_next_path_point(tracker_node) -> Variant:
	if tracker_node not in trackers:
		return
	var tracker: Tracker = trackers[tracker_node]
	var idx = tracker.get_next_idx()
	if idx >= points.size() or idx < 0:
		if not tracker.reversed:
			tracker.reverse()
			# first idx is the one we just had
			idx = tracker.get_next_idx()
		else:
			return
	var point: Vector2 = points[idx]
	# If point is not covered by snow, it will still be in snow_time dict
	if point in snow_time and snow_time[point] < snow_time_to_cover:
		return point
	return


func add_area(global_pos: Vector2) -> void:
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = min_distance_between_points * points_between_areas / 2

	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.shape = shape

	var area: Area2D = Area2D.new()
	area.top_level = true
	area.set_collision_layer_value(3, true)
	area.monitoring = false
	area.monitorable = true
	area.add_to_group("Trails")
	area.add_child(collision)
	add_child(area)
	area.global_position = global_pos
	areas[global_pos] = area


func add_line(global_pos: Vector2) -> void:
	points.append(global_pos)
	var line: Line2D = TRAIL_LINE_SCENE.instantiate()
	line.add_point(global_pos)
	add_child(line)
	lines[global_pos] = line
	snow_time[global_pos] = 0


func _update_snow_cover() -> void:
	var amount: float = accumulation
	accumulation = 0
	for point: Vector2 in snow_time.keys():
		snow_time[point] += amount
		if snow_time[point] >= snow_time_to_cover - 1.0:
			var line: Line2D = lines[point]
			var tween: Tween = line.create_tween()
			tween.tween_property(line, "modulate", Color.TRANSPARENT, 1.0)
		if snow_time[point] >= snow_time_to_cover:
			snow_time.erase(point)
			if point in areas:
				areas[point].queue_free()
				areas.erase(point)
			points.pop_front()
			# decrement index for trackers' next points
			for tracker in trackers:
				trackers[tracker].decrement_idx()
			lines.erase(point)
	#print("snow times count: %d\nareas count: %d\nlines count: %d" % [snow_time.keys().size(), areas.keys().size(), lines.keys().size()])


func _ready() -> void:
	snow_cover_timer.timeout.connect(_update_snow_cover)


func _physics_process(delta):
	if is_instance_valid(Global.weather) and Global.weather.is_snowing():
		accumulation += delta * Global.weather.get_snow_intensity()
		#print("accumulation = ", accumulation)
	if not is_instance_valid(node_tracked):
		return
	var pos: Vector2 = node_tracked.global_position

	if points.size() == 0:
		add_line(pos)
		# disabling this as it leads to drones never leaving you alone b/c they always see it
		#add_area(pos)
	elif points[-1].distance_to(pos) >= min_distance_between_points:
		# Before adding points, update prior 2 lines with point
		# Each line should end up with 3 points to ensure smooth curves
		if points[-1] in lines:
			lines[points[-1]].add_point(pos)
		if points.size() > 2 and points[-2] in lines:
			lines[points[-2]].add_point(pos)
		# Now add the new line
		add_line(pos)
		points_since_area_count += 1

	if points_since_area_count >= points_between_areas:
		#print("adding area to trail at %.1v" % pos)
		points_since_area_count = 0
		add_area(pos)


class Tracker:
	extends RefCounted
	## current index into points
	var idx: int
	## increment or decrement to get next point
	var step: int
	var reversed: bool = false

	func reverse() -> void:
		step = -step
		reversed = true

	func get_next_idx() -> int:
		idx += step
		return idx

	func decrement_idx() -> void:
		idx = max(0, idx - 1)
