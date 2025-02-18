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

@export var search_speed: float = 15.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var detect_area_2d: Area2D = $DetectArea2D
@onready var scanner_back: Sprite2D = $ScannerBack
@onready var scanner_front: Sprite2D = $ScannerFront
@onready var shadow: Sprite2D = $Shadow
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@onready var _state: StateMachine = $StateMachine
@onready var _patrol: Node = $StateMachine/Patrol
@onready var _track: Node = $StateMachine/Track
@onready var _search: Node = $StateMachine/Search


func scan(enable: bool = true) -> void:
	scanner_back.visible = enable
	scanner_front.visible = enable
	shadow.visible = !enable


func _ready() -> void:
	visible_on_screen_notifier_2d.screen_exited.connect(
		_on_visible_on_screen_notifier_2d_screen_exited
	)
	detect_area_2d.body_entered.connect(_on_body_entered_detect_area)
	detect_area_2d.area_entered.connect(_on_area_entered_detect_area)
	_state.state_changed.connect(_update_state_label)
	%StateLabel.text = _state.current_state.name
	scan(false)
	# set initial direction toward center of screen
	direction = global_position.direction_to(Vector2(160, 90))
	anim_player.play("default")


# Override base Enemy _input behavior
func _input(_event: InputEvent) -> void:
	pass


# Override base Enemy _physics_process behavior
func _physics_process(_delta: float) -> void:
	pass


func _update_state_label(new_state: FsmState, _old_state: FsmState) -> void:
	%StateLabel.text = new_state.name


func _on_body_entered_detect_area(body: Node2D) -> void:
	print(name, " detected ", body.name)
	if body.name == "Player":
		# For now, just change to search state until more tracking is worked out
		_search.point_of_interest = body.global_position
		_state.change_to(_search)


func _on_area_entered_detect_area(area: Area2D) -> void:
	print(name, " detected ", area.name, " belonging to ", area.get_parent().name)


# TODO: figure out a good way to avoid this entanglement
# notifier2D loses global_position if under FsmState nodes
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	match _state.current_state:
		_patrol:
			direction = global_position.direction_to(Vector2(160, 90))
		_track:
			# Following something off the map...
			queue_free()
