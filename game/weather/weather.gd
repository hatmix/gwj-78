@tool
class_name Weather
extends Node

enum State { SNOWING, CLEAR, SNOW_STARTING, SNOW_STOPPING }

var _state := State.SNOWING
var _snow_intensity: float
var last_shader_update: float
var shader_time: float
@export var snowfall_fps_limit: int = 20
@export var snow_color := Color.WHITE: 
	set(value):
		snow_color = value
		if snowfall_shader:
			snowfall_shader.set_shader_parameter("rain_color", value)

@onready var snowfall := $Snowfall
@onready var snowfall_shader: ShaderMaterial = snowfall.material
@onready var animationplayer := $AnimationPlayer


func _ready() -> void:
	shader_time = snowfall_shader.get_shader_parameter("time")
	last_shader_update = shader_time
	$DummyWeatherGenerator.play("snow_loop")


func _physics_process(delta: float) -> void:
	shader_time += delta
	if shader_time - last_shader_update > 1.0 / snowfall_fps_limit:
		snowfall_shader.set_shader_parameter("time", shader_time)
		last_shader_update = shader_time


func is_snowing():
	return _state != State.CLEAR


func transition_to_state(new: State):
	match new:
		State.SNOWING:
			if _state == State.CLEAR:
				_state = State.SNOW_STARTING
				animationplayer.play("fade_in")
		State.CLEAR:
			if _state == State.SNOWING:
				_state = State.SNOW_STOPPING
				animationplayer.play("fade_out")


func start_snowing():
	transition_to_state(State.SNOWING)


func stop_snowing():
	transition_to_state(State.CLEAR)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fade_in":
			_state = State.SNOWING
		"fade_out":
			_state = State.CLEAR
		_:
			push_error("Unkown animation finished in %s: '%s'" % [self, anim_name])
