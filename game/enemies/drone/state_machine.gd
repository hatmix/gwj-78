extends StateMachine

var scanned: Array[Node2D] = []

@onready var _patrol: Node = $Patrol
@onready var _search: Node = $Search
@onready var _track: Node = $Track


func on_detect_area_entered(area: Area2D) -> void:
	if current_state == _track:
		return

	var node: Node2D = area.get_parent()
	#print(name, " detected ", area.name, " belonging to ", node.name)

	if node.is_in_group("Trails"):
		node = node as Trail
		if node.register_tracker(_track, area):
			_track.trail = node
			_track.next_point = area.global_position
			change_to(_track)
			return

	if node.is_in_group("Remains") and node not in scanned:
		scanned.append(node)
		_search.point_of_interest = node.global_position
		change_to(_search)


func on_visible_on_screen_notifier_2d_screen_exited() -> void:
	match current_state:
		_patrol:
			target.direction = target.global_position.direction_to(Vector2(160, 90))
		#_track:
		# Following something off the map...
		#queue_free()
