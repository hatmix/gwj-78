extends Node

const IN: String = "GradientVertical"
const OUT: String = "GradientVerticalInverted"

@export var first_level: PackedScene
@export var default_mapping_context: GUIDEMappingContext
@export var transition_pattern: Image

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


func _ready() -> void:
	$UI.find_child("MainMenu").queue_free()
	GUIDE.enable_mapping_context(default_mapping_context)
	Global.player_lost.connect(_lose)
	Global.player_won.connect(_win)
	game_over.visible = false
	victory.visible = false
	$UI.show_ui("Game")
	Bgm.play_track("map", 3.0)
	await get_tree().process_frame
	start_level(first_level)


func _input(_event: InputEvent) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("next_level"):
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
	fade_in()
	get_tree().set_deferred("paused", false)


func _lose() -> void:
	get_tree().paused = true
	await camera_2d.zoom_to_position(player.global_position)
	game_over.visible = true
	var redo: PackedScene = load(map.scene_file_path)
	await get_tree().create_timer(4.0).timeout
	start_level(redo)


func _win() -> void:
	get_tree().paused = true
	get_tree().call_group("Drones", "hide")
	await camera_2d.zoom_to_position(player.global_position)
	victory.visible = true

	await get_tree().create_timer(10.0).timeout
	if map.next_level:
		start_level(map.next_level)
	else:
		var redo: PackedScene = load(map.scene_file_path)
		start_level(redo)
