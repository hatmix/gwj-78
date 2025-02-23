class_name DialogueController
extends Node

@export var dialogue_mapping_context: GUIDEMappingContext

var test_dialogue := preload("res://game/dialogue/popup_test.dialogue")
var popup := preload("res://ui/dialogue/popup_balloon.tscn")
var balloon := preload("res://ui/dialogue/balloon.tscn")


func start_popup_dialogue(dialogue: DialogueResource, pause: bool = true) -> void:
	Global.game.state = Game.State.DIALOGUE
	if pause:
		get_tree().set_deferred("paused", true)
	print("enabling dialogue_mapping_context")
	GUIDE.enable_mapping_context(dialogue_mapping_context)
	DialogueManager.show_dialogue_balloon_scene(popup, dialogue)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.level_started.connect(_on_level_started)
	Global.weather_changed.connect(_on_weather_changed)
	#Global.game_state_changed.connect(_on_game_state_changed)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_level_started(scene_path) -> void:
	var level_started_popups: Dictionary = {
		"res://game/maps/map_0/map_0.tscn": "res://game/dialogue/map_0_start.dialogue",
		"res://game/maps/map_1/map_1.tscn": "res://game/dialogue/map_1_start.dialogue",
		#"res://game/maps/map_2/map_2.tscn"
	}

	if scene_path in level_started_popups:
		var dialogue: DialogueResource = load(level_started_popups[scene_path])
		if "map_0" not in scene_path:
			start_popup_dialogue(dialogue)
		else:
			start_popup_dialogue(dialogue, false)


func _on_weather_changed(state: Weather.State):
	pass


func _on_dialogue_ended(dialogue_resource: DialogueResource) -> void:
	get_tree().paused = false
	print("disabling dialogue_mapping_context")
	GUIDE.disable_mapping_context(dialogue_mapping_context)
	Global.game.state = Game.State.PLAY
