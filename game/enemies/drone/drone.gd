extends Enemy

enum State {PATROL, TRACK}

var state: State = State.PATROL

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var patrol_direction_change_timer: Timer = $PatrolDirectionChangeTimer


func _ready() -> void:
	visible_on_screen_notifier_2d.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	patrol_direction_change_timer.timeout.connect(_change_direction)
	patrol_direction_change_timer.wait_time = randf_range(2.0, 6.0)
	patrol_direction_change_timer.start()
	direction = global_position.direction_to(Vector2(160, 90))
	


# Override base Enemy _input behavior
func _input(event: InputEvent) -> void:
	pass


func _change_direction() -> void:
	var angle: float = [-PI/2, PI/2, PI].pick_random()
	direction = direction.rotated(angle)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	match state:
		State.PATROL:
			direction = global_position.direction_to(Vector2(160, 90))
		State.TRACK:
			# Following something off the map...
			queue_free()
