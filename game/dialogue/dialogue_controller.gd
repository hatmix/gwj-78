class_name DialogueController
extends Node

@export var dialogue_mapping_context: GUIDEMappingContext

var test_dialogue := preload("res://game/dialogue/popup_test.dialogue")
var popup := preload("res://ui/dialogue/popup_balloon.tscn")
var balloon := preload("res://ui/dialogue/balloon.tscn")


func start_popup_dialogue(dialogue: DialogueResource, pause: bool = false) -> void:
	Global.game.state = Game.State.DIALOGUE
	get_tree().set_deferred("paused", pause)
	print("enabling dialogue_mapping_context")
	GUIDE.enable_mapping_context(dialogue_mapping_context)
	DialogueManager.show_dialogue_balloon_scene(popup, dialogue)


func start_dialogue(dialogue: DialogueResource) -> void:
	Global.game.state = Game.State.DIALOGUE
	get_tree().set_deferred("paused", true)
	print("enabling dialogue_mapping_context")
	GUIDE.enable_mapping_context(dialogue_mapping_context)
	DialogueManager.show_dialogue_balloon_scene(balloon, dialogue)


func start_level_end_dialogue(scene_path) -> void:
	var level_end_dialogues: Dictionary = {
		"res://game/maps/map_0/map_0.tscn": "res://game/dialogue/map_0_end.dialogue",
		"res://game/maps/map_1/map_1.tscn": "res://game/dialogue/map_1_end.dialogue",
		"res://game/maps/map_2/map_2.tscn": "res://game/dialogue/map_2_end.dialogue",
		"res://game/maps/map_4/map_4.tscn": "res://game/dialogue/ending.dialogue",
	}
	if scene_path in level_end_dialogues:
		var dialogue: DialogueResource = load(level_end_dialogues[scene_path])
		#if "map_0" not in scene_path:
		#	start_popup_dialogue(dialogue)
		#else:
		# Always starting unpaused to walk to starting point from off edge
		start_dialogue(dialogue)
		await DialogueManager.dialogue_ended


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
		"res://game/maps/map_2/map_2.tscn": "res://game/dialogue/map_2_start.dialogue",
		"res://game/maps/map_3/map_3.tscn": "res://game/dialogue/map_3_start.dialogue",
		"res://game/maps/map_4/map_4.tscn": "res://game/dialogue/map_4_start.dialogue",
	}

	if scene_path in level_started_popups:
		var dialogue: DialogueResource = load(level_started_popups[scene_path])
		#if "map_0" not in scene_path:
		#	start_popup_dialogue(dialogue)
		#else:
		# Always starting unpaused to walk to starting point from off edge
		start_popup_dialogue(dialogue, false)


func _on_weather_changed(_state: Weather.State):
	pass


func _on_dialogue_ended(_dialogue_resource: DialogueResource) -> void:
	get_tree().paused = false
	print("disabling dialogue_mapping_context")
	GUIDE.disable_mapping_context(dialogue_mapping_context)
	Global.game.state = Game.State.PLAY
