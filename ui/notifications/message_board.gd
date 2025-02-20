class_name MessageBoard
extends UiPage

var message_scene: PackedScene = preload("res://ui/notifications/message.tscn")


func _ready() -> void:
	Global.post_ui_message.connect(show_message)


func _check_queue() -> void:
	#print(name, " _check_queue")
	if %Messages.get_child_count() == 0:
		ui.hide_ui("MessageBoard")
		$Timer.timeout.disconnect(_check_queue)


func show_message(text: String) -> void:
	#print(name, " show_message")
	if not ui.is_shown("MessageBoard"):
		ui.show_ui("MessageBoard")
		$Timer.timeout.connect(_check_queue)

	var message: Message = message_scene.instantiate()
	%Messages.add_child(message)
	message.display(text)
