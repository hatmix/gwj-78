class_name DialogueController
extends Node

var test_dialogue := preload("res://game/dialogue/test.dialogue")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.level_started.connect(_on_level_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _on_level_started() -> void:
	await get_tree().physics_frame
	Global.game.state = Game.State.DIALOGUE
	get_tree().paused = true
	DialogueManager.show_dialogue_balloon(test_dialogue)


func _on_dialogue_ended(dialogue_resource: DialogueResource) -> void:
	get_tree().paused = false
	Global.game.state = Game.State.PLAY
