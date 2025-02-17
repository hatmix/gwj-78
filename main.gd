extends Node

@onready var bgm: AudioStreamPlayer = $Bgm

# FIXME: collision layers for ground vs flyers, etc.


func _ready() -> void:
	bgm.play()
