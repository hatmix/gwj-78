extends Node

const IN: String = "GradientVertical"
const OUT: String = "GradientVerticalInverted"

@export var first_level: PackedScene
@export var default_mapping_context: GUIDEMappingContext
@export var transition_pattern: Image

var map: Map

@onready var bgm: AudioStreamPlayer = $Bgm
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
	bgm.play()
	await get_tree().process_frame
	start_level(first_level)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("next_level"):
		Global.player_won.emit()


func fade_out(duration: float = 1.0) -> Fade:
	return Fade.fade_out(duration, Global.COLOR_CLEAR, OUT)


func fade_in(duration: float = 1.0) -> Fade:
	return Fade.fade_in(duration, Global.COLOR_CLEAR, IN)


func start_level(_map: PackedScene) -> void:
	fade_out()
	game_over.visible = false
	victory.visible = false
	map = _map.instantiate()
	for child in map_placeholder.get_children():
		child.queue_free()
	map_placeholder.add_child.call_deferred(map)
	GUIDE.disable_mapping_context(default_mapping_context)
	GUIDE.enable_mapping_context(default_mapping_context)
	fade_in()
	get_tree().set_deferred("paused", false)


func _lose() -> void:
	game_over.visible = true
	get_tree().paused = true
	var redo: PackedScene = load(map.scene_file_path)
	await get_tree().create_timer(2.0).timeout
	start_level(redo)


func _win() -> void:
	victory.visible = true
	get_tree().paused = true
	await get_tree().create_timer(2.0).timeout
	if map.next_level:
		start_level(map.next_level)
	else:
		var redo: PackedScene = load(map.scene_file_path)
		start_level(redo)
