extends Node

@export var default_mapping_context: GUIDEMappingContext

@onready var bgm: AudioStreamPlayer = $Bgm
@onready var game_over: Label = $UI/GameOver
@onready var victory: Label = $UI/Victory

# FIXME: collision layers for ground vs flyers, etc.


func _ready() -> void:
	GUIDE.enable_mapping_context(default_mapping_context)
	Global.player_lost.connect(_lose)
	Global.player_won.connect(_win)
	game_over.visible = false
	victory.visible = false
	$UI.show_ui("Game")
	bgm.play()


func _lose() -> void:
	game_over.visible = true
	get_tree().paused = true
	await get_tree().create_timer(2.0).timeout
	get_tree().set_deferred("paused", false)
	get_tree().reload_current_scene()


func _win() -> void:
	victory.visible = true
	get_tree().paused = true
	await get_tree().create_timer(2.0).timeout
	get_tree().set_deferred("paused", false)
	get_tree().reload_current_scene()
