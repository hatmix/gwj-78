extends FsmState

@export var min_turn_time: float = 2.0
@export var max_turn_time: float = 6.0

@onready var direction_change_timer: Timer = $DirectionChangeTimer


func enter_state() -> void:
	direction_change_timer.start()


func exit_state() -> void:
	direction_change_timer.stop()


func physics_process(_delta: float) -> void:
	if _state.target.direction:
		_state.target.velocity = _state.target.direction * _state.target.speed
	else:
		_state.target.velocity = _state.target.velocity.move_toward(
			Vector2.ZERO, _state.target.speed
		)

	# move_and_slide() returns true if collision happened
	if _state.target.move_and_slide():
		_change_direction()


func _ready() -> void:
	direction_change_timer.timeout.connect(_change_direction)
	direction_change_timer.wait_time = randf_range(min_turn_time, max_turn_time)


func _change_direction() -> void:
	# shouldn't be needed, but extra safe!
	if not active:
		return
	# 60 degree turn left or right
	var angle: float = [-PI / 3, PI / 3].pick_random()
	_state.target.direction = _state.target.direction.rotated(angle)
	#print("drone ", _state.target.name, " change direction to %.0v" % _state.target.direction)
