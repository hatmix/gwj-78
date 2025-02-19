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

# lookup which line starts at point
var lines: Dictionary = {}
#var cover: Dictionary = {}

@onready var snow_cover_timer: Timer = $SnowCoverTimer


# TODO: think about possible memory leaks with all these refs stored
func register_tracker(tracker: Node, area: Area2D) -> bool:
	if area not in areas.values():
		return false
	var idx: int = points.find(area.global_position)
	if idx == -1:
		return false
	trackers[tracker] = idx
	#print(trackers)
	return true


func unregister_tracker(tracker: Node) -> void:
	trackers.erase(tracker)


func get_next_path_point(tracker) -> Variant:
	if tracker not in trackers:
		return
	trackers[tracker] += 1
	if trackers[tracker] >= points.size():
		return
	var point: Vector2 = points[trackers[tracker]]
	# If point is not covered by snow, it will still be in snow_time dict
	if point in snow_time:
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
		# First half of disappearing...
		if snow_time[point] >= snow_time_to_cover:
			snow_time.erase(point)
			if point in areas:
				areas[point].queue_free()
				areas.erase(point)
			var line: Line2D = lines[point]
			var tween: Tween = line.create_tween()
			tween.tween_property(line, "modulate", Color.TRANSPARENT, 2.0)
			tween.tween_callback(line.queue_free)
			lines.erase(point)
			points.pop_front()
			# decrement index for trackers' next points
			for tracker in trackers:
				trackers[tracker] = max(0, trackers[tracker] - 1)
	#print("snow times count: %d\nareas count: %d\nlines count: %d" % [snow_time.keys().size(), areas.keys().size(), lines.keys().size()])


func _ready() -> void:
	snow_cover_timer.timeout.connect(_update_snow_cover)


# TODO: fading of tracks based on weather conditions & time elapsed
# TODO: how to use gradient across width of line? (line2d's built-in gradients
# seem to work over the length)
func _physics_process(delta):
	if is_instance_valid(Global.get_weather()) and Global.get_weather().is_snowing():
		accumulation += delta * Global.get_weather().get_snow_intensity()
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
		lines[points[-1]].add_point(pos)
		if points.size() > 2:
			lines[points[-2]].add_point(pos)
		# Now add the new line
		add_line(pos)
		points_since_area_count += 1

	if points_since_area_count >= points_between_areas:
		#print("adding area to trail at %.1v" % pos)
		points_since_area_count = 0
		add_area(pos)
