class_name Message
extends PanelContainer

const MAX_WIDTH: int = 300

# Panel container color controlled by the ui theme
@onready var text_node: Label = %Text
@onready var sfx: AudioStreamPlayer = $AudioStreamPlayer


func display(text: String) -> void:
	text_node.text = text
	scale = Vector2.ZERO
	visible = true

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 1.0)
	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate", Color(Color.WHITE, 0.0), 1.0)
	tween.tween_callback(queue_free)
	sfx.play()


func _ready() -> void:
	visible = false
	resized.connect(_on_resized)
	text_node.resized.connect(_on_text_resized)


func _on_resized() -> void:
	#print("panel resized ", size)
	pivot_offset = size / 2
	#pivot_offset.y = size.y


func _on_text_resized() -> void:
	#print("text resized ", text_node.size)
	if text_node.size.x > MAX_WIDTH:
		text_node.custom_minimum_size.x = MAX_WIDTH
		text_node.custom_minimum_size.y += 30
		text_node.autowrap_mode = TextServer.AUTOWRAP_WORD
