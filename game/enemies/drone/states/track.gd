extends FsmState

var trail: Trail
var next_point: Vector2
var _slow_down_dude: bool = false


func enter_state():
	print("enter state track")
	_state.target.scan(true)


func exit_state():
	_state.target.scan(false)
	_slow_down_dude = false
	trail.unregister_tracker(self)


func get_next_point() -> void:
	_slow_down_dude = true
	var _next_point: Variant = trail.get_next_path_point(self)
	if not _next_point:
		#print(_state.target.name, " looking for next point and got no new point...")
		# next point is the last point on trail
		_state._search.point_of_interest = next_point
		_state.change_to("Search")
		return
	next_point = _next_point
	_slow_down_dude = false


func process(_delta: float) -> void:
	pass


# TODO: handle obstacle avoidance
func physics_process(_delta: float) -> void:
	if _slow_down_dude:
		return

	if _state.target.global_position.distance_to(next_point) < 3:
		get_next_point()
		return

	_state.target.direction = _state.target.global_position.direction_to(next_point)
	_state.target.velocity = _state.target.direction * _state.target.search_speed
	# FIXME: handle obstacle avoidance
	if _state.target.move_and_slide():
		print(_state.target.name, " trail tracking collision :(")
