class_name DialogueController
extends Node

var test_dialogue := preload("res://game/dialogue/popup_test.dialogue")
var popup := preload("res://ui/dialogue/popup_balloon.tscn")
var balloon := preload("res://ui/dialogue/balloon.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.level_started.connect(_on_level_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_level_started() -> void:
	await get_tree().physics_frame
	Global.game.state = Game.State.DIALOGUE
	get_tree().paused = true
	DialogueManager.show_dialogue_balloon_scene(popup, test_dialogue)


func _on_dialogue_ended(dialogue_resource: DialogueResource) -> void:
	get_tree().paused = false
	Global.game.state = Game.State.PLAY
