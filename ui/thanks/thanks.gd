extends UiPage


func _ready() -> void:
	pass
	#Fade.fade_in.bind(1.0, Global.COLOR_CLEAR).call_deferred()


func _process(_delta: float) -> void:
	if visible and Input.is_anything_pressed():
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://main.tscn")
