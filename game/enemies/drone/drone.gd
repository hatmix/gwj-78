extends Enemy  # Maybe not useful now...

## Overview of states
## PATROL
##   somewhat random movement with turns every min-max seconds,
##   head toward center of screen if moved off screen
## TRACK
##   spotted tracks and following them
## SEARCH
##   trail ended, so enter search pattern from last point
##   (see https://owaysonline.com/iamsar-search-patterns/)

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var _state: StateMachine = $StateMachine


func _ready() -> void:
	visible_on_screen_notifier_2d.screen_exited.connect(
		_on_visible_on_screen_notifier_2d_screen_exited
	)
	_state.state_changed.connect(_update_state_label)
	%StateLabel.text = _state.current_state.name

	# set initial direction toward center of screen
	direction = global_position.direction_to(Vector2(160, 90))


# Override base Enemy _input behavior
func _input(_event: InputEvent) -> void:
	pass


# Override base Enemy _physics_process behavior
func _physics_process(_delta: float) -> void:
	pass


func _update_state_label(new_state: FsmState, _old_state: FsmState) -> void:
	%StateLabel.text = new_state.name


# TODO: try to figure out a good way to avoid this entanglement
# notifier2D loses global_position if under FsmState nodes
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	match _state.current_state.name:
		"Patrol":
			direction = global_position.direction_to(Vector2(160, 90))
		"Track":
			# Following something off the map...
			queue_free()
