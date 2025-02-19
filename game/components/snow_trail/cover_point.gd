extends Line2D

const GRADIENT: Gradient = preload("res://game/components/snow_trail/gradient_for_cover_point.tres")

var time_to_cover: float = 3.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().create_timer(time_to_cover).timeout.connect(_cover)


func _cover() -> void:
	gradient = GRADIENT
	texture = null
