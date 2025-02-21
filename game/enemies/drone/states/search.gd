extends FsmState

var point_of_interest: Vector2
var path: Array[Vector2]

var _is_animating: bool = false
var found_something: bool = false

@onready var pattern_1: Line2D = $PatrolPattern
@onready var pattern_2: Line2D = $PatrolPattern2


func enter_state():
	#print("enter state search")
	_is_animating = true
	_state.target.anim_player.play("search_enter")
	# pick a pattern to use
	var pattern: Line2D = [pattern_1, pattern_2].pick_random()
	# Rotate the search pattern by drone's travel direction
	# consider whether it's better for player if it's never rotated...
	#var theta: float = Vector2.RIGHT.angle_to(_state.target.direction)
	var points: PackedVector2Array = pattern.points
	path = []
	for point: Vector2 in points:
		#var rotated_point: Vector2
		#rotated_point.x = (point.x * cos(theta) - point.y * sin(theta) + point_of_interest.x)
		#rotated_point.y = (point.x * sin(theta) + point.y * cos(theta) + point_of_interest.y)
		path.append(point + point_of_interest)  #rotated_point)

	await _state.target.anim_player.animation_finished
	_is_animating = false
	_state.target.scan(true)
	_state.target.anim_player.play("searching")


func exit_state():
	_is_animating = true
	_state.target.scan(false)
	point_of_interest = Vector2.ZERO
	path = []
	if found_something:
		pass
	else:
		_state.target.anim_player.play("search_exit_nothing_found")
	await _state.target.anim_player.animation_finished
	_is_animating = false


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	if _is_animating:
		return
	if path.size() and _state.target.global_position.distance_to(path[0]) < 2:
		path.pop_front()

	# If we've completed the search path, go back to patrolling
	if path.size() == 0:
		_state.change_to("Patrol")
		return

	_state.target.direction = _state.target.global_position.direction_to(path[0])
	var snow_slow: float = 0
	if is_instance_valid(Global.get_weather()):
		snow_slow = _state.target.snow_speed_reduction * Global.get_weather().get_snow_intensity()
	_state.target.velocity = _state.target.direction * (_state.target.search_speed - snow_slow)

	# FIXME: handle obstacle avoidance--what if path[0] is inside a collider?
	if _state.target.move_and_slide():
		#print(_state.target.name, " search pattern collision, dropping current path point :(")
		if path.size():
			path.pop_front()
