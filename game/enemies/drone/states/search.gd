extends FsmState

var point_of_interest: Vector2
var path: Array[Vector2]

var _is_animating: bool = false

@onready var patrol_pattern: Line2D = $PatrolPattern


func enter_state():
	_is_animating = true
	_state.target.anim_player.play("search_enter")
	# Rotate the search pattern by drone's travel direction
	# consider whether it's better for player if it's never rotated...
	var theta: float = Vector2.RIGHT.angle_to(_state.target.direction)
	var points: PackedVector2Array = patrol_pattern.points
	path = []
	for point: Vector2 in points:
		var rotated_point: Vector2
		rotated_point.x = (point.x * cos(theta) - point.y * sin(theta) + point_of_interest.x)
		rotated_point.y = (point.x * sin(theta) + point.y * cos(theta) + point_of_interest.y)
		path.append(rotated_point)

	await _state.target.anim_player.animation_finished
	_is_animating = false
	_state.target.scan(true)
	_state.target.anim_player.play("searching")


func exit_state():
	_is_animating = true
	_state.target.scan(false)
	point_of_interest = Vector2.ZERO
	path = []
	_state.target.anim_player.play("search_exit")
	await _state.target.anim_player.animation_finished
	_is_animating = false


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	if _is_animating:
		return
	if _state.target.global_position.distance_to(path[0]) < 10:
		path.pop_front()

	# If we've completed the search path, go back to patrolling
	if path.size() == 0:
		_state.change_to("Patrol")
		return

	_state.target.direction = _state.target.global_position.direction_to(path[0])
	_state.target.velocity = _state.target.direction * _state.target.search_speed
	# FIXME: handle obstacle avoidance--what if path[0] is inside a collider?
	if _state.target.move_and_slide():
		print(_state.target.name, " search pattern collision :(")
