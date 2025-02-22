class_name Drone
extends CharacterBody2D

## Overview of states
## PATROL
##   somewhat random movement with turns every min-max seconds,
##   head toward center of screen if moved off screen
## TRACK
##   spotted tracks and following them
## SEARCH
##   trail ended, so enter search pattern from last point
##   (see https://owaysonline.com/iamsar-search-patterns/)

const SCAN_COLOR := Color("#FE610080")

@export var patrol_speed: float = 20.0
@export var snowing_patrol_speed: float = 12.0
@export var search_speed: float = 15.0
@export var snowing_search_speed: float = 10.0
@export var track_speed: float = 24.0
@export var snowing_track_speed: float = 14.0

var direction: Vector2
var scan_audio_stream: AudioStream = preload("res://game/enemies/drone/assets/audio/scanning.ogg")
var track_audio_stream: AudioStream = preload("res://game/enemies/drone/assets/audio/tracking.ogg")

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var propulsion_anim_player: AnimationPlayer = $Propulsion/AnimationPlayer
@onready var lildrone_anim_player: AnimationPlayer = $LilDrone/AnimationPlayer

@onready var sfx_2d: AudioStreamPlayer2D = $Sfx2D
# Detect trails and interesting objects
@onready var detect_area_2d: Area2D = $DetectArea2D
# Detect player in smaller area for better feel
@onready var player_detect_area_2d: Area2D = $PlayerDetectArea2D

@onready var scanner_back: Sprite2D = $ScannerBack
@onready var scanner_front: Sprite2D = $ScannerFront
@onready var shadow: Sprite2D = $Shadow
@onready var tracker_beam: Line2D = $TrackerBeam
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@onready var _state: StateMachine = $DroneStateController


func scan(enable: bool = true) -> void:
	scanner_back.visible = enable
	scanner_front.visible = enable
	shadow.visible = !enable
	if enable:
		# playing the audio here allows for smooth looping where doing it in
		# the animation different ways caused chops or multiple plays
		# overlapping for one scan
		sfx_2d.stream = scan_audio_stream
		sfx_2d.play()


func track(enable: bool = true) -> void:
	tracker_beam.visible = enable
	shadow.visible = !enable
	if enable:
		sfx_2d.stream = track_audio_stream
		sfx_2d.play()


func _ready() -> void:
	scanner_back.self_modulate = SCAN_COLOR
	scanner_front.self_modulate = SCAN_COLOR
	tracker_beam.self_modulate = SCAN_COLOR
	scan(false)
	track(false)

	%StateLabel.text = name
	%TargetLabel.text = "%s\npatrol\ntarget" % name

	# Signal connections
	_state._patrol.patrol_target_changed.connect(_update_target_label)
	visible_on_screen_notifier_2d.screen_exited.connect(
		_state._patrol.on_visible_on_screen_notifier_2d_screen_exited
	)
	player_detect_area_2d.body_entered.connect(_on_body_entered_player_detect_area)
	detect_area_2d.area_entered.connect(_state.on_detect_area_entered)
	detect_area_2d.body_entered.connect(_state.on_detect_body_entered)
	detect_area_2d.body_exited.connect(_state.on_detect_body_exited)

	# randomize lildrone and propulsion start frames
	lildrone_anim_player.seek(randf_range(0, lildrone_anim_player.get_current_animation_length()))
	propulsion_anim_player.seek(
		randf_range(0, propulsion_anim_player.get_current_animation_length())
	)

	# set initial direction toward center of screen
	direction = global_position.direction_to(Vector2(160, 90))


func _update_target_label(pos: Vector2) -> void:
	%TargetLabel.global_position = pos


func _update_state_label(new_state: FsmState, _old_state: FsmState) -> void:
	%StateLabel.text = new_state.name


func _on_body_entered_player_detect_area(body: Node2D) -> void:
	#print(name, " detected ", body.name)
	if body.name == "Player":
		scan(false)
		track(true)
		tracker_beam.z_index += 1
		await get_tree().process_frame
		Global.player_lost.emit()
