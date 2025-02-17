class_name Weather
extends Node

enum State { SNOWING, CLEAR, SNOW_STARTING, SNOW_STOPPING }

var _state: State
var last_shader_update: float
var shader_time: float
@export var snowfall_fps_limit: int = 20
@onready var snowfall: ColorRect = $Snowfall
@onready var snowfall_shader: ShaderMaterial = snowfall.material


func _ready() -> void:
	shader_time = snowfall_shader.get_shader_parameter("time")
	last_shader_update = shader_time


func _physics_process(delta: float) -> void:
	shader_time += delta
	if shader_time - last_shader_update > 1.0 / snowfall_fps_limit:
		snowfall_shader.set_shader_parameter("time", shader_time)
		last_shader_update = shader_time
