extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var label: Label = $Label


func _ready() -> void:
	label.visible = false
	area_2d.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		label.visible = true
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()
