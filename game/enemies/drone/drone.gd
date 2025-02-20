class_name Drone
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

var scan_audio_stream: AudioStream = preload("res://game/enemies/drone/assets/scanning.ogg")

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_player_sfx_2d: AudioStreamPlayer2D = $AnimPlayerSfx2D
# Detect trails and interesting objects
@onready var detect_area_2d: Area2D = $DetectArea2D
# Detect player in smaller area for better feel
@onready var player_detect_area_2d: Area2D = $PlayerDetectArea2D

@onready var scanner_back: Sprite2D = $ScannerBack
@onready var scanner_front: Sprite2D = $ScannerFront
@onready var shadow: Sprite2D = $Shadow
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@onready var _state: StateMachine = $StateMachine


func scan(enable: bool = true) -> void:
	scanner_back.visible = enable
	scanner_front.visible = enable
	shadow.visible = !enable
	if enable:
		# playing the audio here allows for smooth looping where doing it in
		# the animation different ways caused chops or multiple plays
		# overlapping for one scan
		anim_player_sfx_2d.stream = scan_audio_stream
		anim_player_sfx_2d.play()


func _ready() -> void:
	%StateLabel.text = name
	%TargetLabel.text = "%s\npatrol\ntarget" % name
	_state._patrol.patrol_target_changed.connect(_update_target_label)
	visible_on_screen_notifier_2d.screen_exited.connect(
		_state._patrol.on_visible_on_screen_notifier_2d_screen_exited
	)
	player_detect_area_2d.body_entered.connect(_on_body_entered_player_detect_area)
	detect_area_2d.area_entered.connect(_state.on_detect_area_entered)
	scan(false)
	# set initial direction toward center of screen
	direction = global_position.direction_to(Vector2(160, 90))


func _update_target_label(pos: Vector2) -> void:
	%TargetLabel.visible = true
	%TargetLabel.global_position = pos


# Override base Enemy _input behavior
func _input(_event: InputEvent) -> void:
	pass


# Override base Enemy _physics_process behavior
func _physics_process(_delta: float) -> void:
	pass
	#if _state.current_state:
	#	%StateLabel.text = "%s\n%s" % [_state.current_state.name, anim_player.current_animation]


func _update_state_label(new_state: FsmState, _old_state: FsmState) -> void:
	pass
	#%StateLabel.text = new_state.name


func _on_body_entered_player_detect_area(body: Node2D) -> void:
	#print(name, " detected ", body.name)
	if body.name == "Player":
		Global.player_lost.emit()
