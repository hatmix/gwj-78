class_name Game
extends Node

enum State { PLAY, MENUS, DIALOGUE }

const IN: String = "GradientVertical"
const OUT: String = "GradientVerticalInverted"

@export var first_level: PackedScene
@export var default_mapping_context: GUIDEMappingContext
@export var transition_pattern: Image

var state: State = State.PLAY:
	set(value):
		if state != value:
			state = value
			match state:
				State.DIALOGUE:
					print("disabling default_mapping_context")
					GUIDE.disable_mapping_context(default_mapping_context)
				_:
					print("enabling default_mapping_context")
					GUIDE.enable_mapping_context(default_mapping_context)
			Global.game_state_changed.emit(state)

var map: Map
var player: CharacterBody2D:
	get:
		if player == null:
			player = get_tree().get_first_node_in_group("Player")
		return player

@onready var camera_2d: Camera2D = $Camera2D
@onready var game_over: Label = $UI/GameOver
@onready var victory: Label = $UI/Victory
@onready var map_placeholder: Node2D = $MapPlaceholder
@onready var dialogue: DialogueController = $DialogueController


func _ready() -> void:
	$UI.find_child("MainMenu").queue_free()
	Global.player_lost.connect(_lose)
	Global.player_won.connect(_win)
	game_over.visible = false
	victory.visible = false
	$UI.show_ui("Game")
	Bgm.play_track("map", 3.0)
	await get_tree().process_frame
	start_level(first_level)


func _input(_event: InputEvent) -> void:
	if OS.is_debug_build() and state == State.PLAY and Input.is_action_just_pressed("next_level"):
		Global.player_won.emit()


func _process(_delta: float) -> void:
	pass
	#camera_2d.global_position = player.global_position


func fade_out(duration: float = 1.0) -> Fade:
	return Fade.fade_out(duration, Global.COLOR_CLEAR, OUT)


func fade_in(duration: float = 1.0) -> Fade:
	return Fade.fade_in(duration, Global.COLOR_CLEAR, IN)


func start_level(_map: PackedScene) -> void:
	fade_out()
	game_over.visible = false
	victory.visible = false
	camera_2d.zoom = Vector2.ONE
	camera_2d.global_position = Vector2(160, 90)
	player = null
	map = _map.instantiate()
	for child in map_placeholder.get_children():
		child.queue_free()
	map_placeholder.add_child.call_deferred(map)
	GUIDE.disable_mapping_context(default_mapping_context)
	GUIDE.enable_mapping_context(default_mapping_context)
	await fade_in().finished
	get_tree().set_deferred("paused", false)
	Global.level_started.emit(map.scene_file_path)


func _lose() -> void:
	get_tree().paused = true
	await camera_2d.zoom_to_position(player.global_position)
	game_over.visible = true
	var redo: PackedScene = load(map.scene_file_path)
	await get_tree().create_timer(2.0).timeout
	start_level(redo)


func _win() -> void:
	get_tree().paused = true
	get_tree().call_group("Drones", "hide")
	await camera_2d.zoom_to_position(player.global_position)
	victory.visible = true
	get_tree().call_group("Drones", "queue_free")
	await get_tree().create_timer(1.0).timeout
	victory.visible = false
	# can this await? YES!
	await dialogue.start_level_end_dialogue(map.scene_file_path)

	if map.next_level:
		start_level(map.next_level)
	else:
		var redo: PackedScene = load(map.scene_file_path)
		start_level(redo)
