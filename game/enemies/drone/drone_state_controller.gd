extends StateMachine

var scanned: Array[Node2D] = []
var _player: Node2D

@onready var _dialogue: Node = $Dialogue
@onready var _patrol: Node = $Patrol
@onready var _search: Node = $Search
@onready var _track: Node = $Track


func on_detect_body_entered(body: Node2D) -> void:
	#print(target.name, " detected ", body.name)
	if body.is_in_group("Player"):
		_player = body
		match current_state:
			_dialogue:
				pass
			_patrol:
				_search.point_of_interest = body.global_position
				change_to(_search)
			_search:
				change_to(_track)
			_track:
				_track.next_point = body.global_position


func on_detect_body_exited(body: Node2D) -> void:
	#print(body.name, " exited detect area of ", target.name)
	if body.is_in_group("Player"):
		_player = null


func on_detect_area_entered(area: Area2D) -> void:
	if area in scanned:
		return
	scanned.append(area)
	if current_state == _track:
		return

	var node: Node2D = area.get_parent()

	if node.is_in_group("Trails"):
		node = node as Trail
		if node.register_tracker(_track, area):
			_track.trail = node
			_track.next_point = area.global_position
			change_to(_track)
			return

	if node in scanned:
		return

	if node.is_in_group("Remains"):
		scanned.append(node)
		var pos: Vector2 = node.global_position
		var visual: Sprite2D = node.find_child("Visual")
		if visual:
			pos += visual.offset
		_search.point_of_interest = pos
		change_to(_search)

	if node.name in ["Cart", "Box"]:
		scanned.append(node)
		var pos: Vector2 = node.global_position
		var visual: Sprite2D = node.find_child("Visual")
		if visual:
			pos += visual.offset
		_search.point_of_interest = pos
		change_to(_search)


func _process(_delta: float) -> void:
	if is_instance_valid(_player):
		_track.next_point = _player.global_position
