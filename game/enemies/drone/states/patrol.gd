class_name DronePatrol
extends FsmState

signal patrol_target_changed(point: Vector2)

# Update if viewport resolution is changed
const QUADS: Array[Rect2] = [
	Rect2(0, 0, 160, 90),
	Rect2(160, 0, 160, 90),
	Rect2(0, 90, 160, 90),
	Rect2(160, 90, 160, 90),
]

@export var min_turn_time: float = 2.0
@export var max_turn_time: float = 6.0

static var target_quads: Dictionary = {}
var target_point: Vector2

@onready var direction_change_timer: Timer = $DirectionChangeTimer


func enter_state() -> void:
	direction_change_timer.start()
	if not is_instance_valid(_state.target.anim_player):
		await _state.target.ready
	_state.target.anim_player.play("patrolling")


func exit_state() -> void:
	if _state.target.anim_player.current_animation == "patrolling":
		_state.target.anim_player.stop()
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
	# check other drone locations and try to turn toward empty part of map...
	var my_quad: int
	var drones_in_quad: Dictionary = {0:0, 1:0, 2:0, 3:0}
	for drone: Drone in get_tree().get_nodes_in_group("Drones"):
		# Include any defined target quads
		if drone in target_quads:
			drones_in_quad[target_quads[drone]] += 1
		for idx: int in QUADS.size():
			if QUADS[idx].has_point(drone.global_position):
				if drone == _state.target:
					my_quad = idx
					continue
				drones_in_quad[idx] += 1
	var min_quad: int = 0
	for idx: int in range(1, QUADS.size()):
		if drones_in_quad[idx] < drones_in_quad[min_quad]:
			min_quad = idx
	
	# if I'm already in my target quad, take the random turn
	if min_quad == my_quad:
		var angle: float = [-PI / 3, PI / 3].pick_random()
		_state.target.direction = _state.target.direction.rotated(angle)
	else:	
		print(_state.target.name, " moving to quad ", min_quad)
		target_quads[_state.target] = min_quad
		target_point = QUADS[min_quad].get_center()
		patrol_target_changed.emit(target_point)
		_state.target.direction = _state.target.global_position.direction_to(target_point)


func on_visible_on_screen_notifier_2d_screen_exited() -> void:
	var point: Vector2 = target_point
	if not point:
		point = Vector2(160, 90)
	_state.target.direction = _state.target.global_position.direction_to(point)
