extends FsmState

var trail: Trail
var next_point: Vector2
var _slow_down_dude: bool = false


func enter_state():
	#print("enter state track")
	_state.target.track(true)


func exit_state():
	_state.target.track(false)
	_slow_down_dude = false
	if is_instance_valid(trail):
		trail.unregister_tracker(self)
	trail = null


func get_next_point() -> void:
	_slow_down_dude = true
	if trail:
		var _next_point: Variant = trail.get_next_path_point(self)
		if _next_point:
			next_point = _next_point
			_slow_down_dude = false
			return
	#print(_state.target.name, " looking for next point and got no new point...")
	# next point is the last point on trail
	_state._search.point_of_interest = next_point
	_state.change_to("Search")


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
	var snow_slow: float = 0
	if is_instance_valid(Global.weather):
		snow_slow = _state.target.snow_speed_reduction * Global.weather.get_snow_intensity()
	_state.target.velocity = _state.target.direction * (_state.target.track_speed - snow_slow)
	# FIXME: handle obstacle avoidance
	if _state.target.move_and_slide():
		print(_state.target.name, " trail tracking collision :(")
