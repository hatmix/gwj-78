extends FsmState

var direction: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO
var _is_animating: bool = false


func enter_state():
	#print("enter state search")
	_is_animating = true
	_state.target.anim_player.play("search_enter")
	# pick a pattern to use
	

	await _state.target.anim_player.animation_finished
	_is_animating = false
	
	_state.target.anim_player.play("searching")


func exit_state():
	pass


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	if _is_animating:
		return
	if _target_position and _state.target.global_position.distance_to(_target_position) <= 4:
		_state.target.in_position.emit()
	
	_state.target.direction = _state.target.global_position.direction_to(_target_position)
	var speed: float = _state.target.search_speed
	if is_instance_valid(Global.weather):
		speed = lerp(speed, _state.target.snowing_search_speed, Global.weather.get_snow_intensity())
	_state.target.velocity = _state.target.direction * speed

	# FIXME: handle obstacle avoidance--what if path[0] is inside a collider?
	_state.target.move_and_slide()
