extends Node

@export var snowfall_fps_limit: int = 20

var last_shader_update: float
var shader_time: float

@onready var color_rect: ColorRect = $ColorRect
@onready var snowfall_shader: ShaderMaterial = color_rect.material
@onready var bgm: AudioStreamPlayer = $Bgm


func _ready() -> void:
	shader_time = snowfall_shader.get_shader_parameter("time")
	last_shader_update = shader_time
	bgm.play()


func _physics_process(delta: float) -> void:
	shader_time += delta
	if shader_time - last_shader_update > 1.0 / snowfall_fps_limit:
		snowfall_shader.set_shader_parameter("time", shader_time)
		last_shader_update = shader_time
