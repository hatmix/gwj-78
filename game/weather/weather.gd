class_name Weather
extends Node

enum State {
	SNOW_STARTING,
	SNOWING,
	SNOW_STOPPING,
	CLEAR,
}

@export var snowfall_fps_limit: int = 20
@export_range(0.5, 10.0, 0.1) var snow_fade_duration := 3.0
@export_range(2.0, 60.0, 1.0) var weather_change_frequency_seconds := 3.0
@export_range(0.0, 1.0, 0.02) var _snow_intensity: float = 1.0:
	set(value):
		value = clamp(value, 0.0, 1.0)
		_snow_intensity = value
		snow_color = Color(snow_color, value)
@export var snow_color := Color.WHITE:
	set(value):
		snow_color = value
		if snowfall_shader:
			snowfall_shader.set_shader_parameter("rain_color", value)

var _state := State.SNOWING if _snow_intensity == 1.0 else State.CLEAR:
	set(new_state):
		if _state != new_state:
			_state = new_state
			Global.weather_changed.emit(_state)
var last_shader_update: float
var shader_time: float

@onready var snowfall := $Snowfall
@onready var weather_change_timer := $WeatherChangeTimer
@onready var snowfall_shader: ShaderMaterial = snowfall.material


func _init():
	Global.set_weather(self)


func _ready():
	shader_time = snowfall_shader.get_shader_parameter("time")
	last_shader_update = shader_time


func _physics_process(delta: float):
	shader_time += delta
	if shader_time - last_shader_update > 1.0 / snowfall_fps_limit:
		snowfall_shader.set_shader_parameter("time", shader_time)
		last_shader_update = shader_time


func is_snowing() -> bool:
	return _state != State.CLEAR


func get_snow_intensity() -> float:
	return _snow_intensity


func transition_to_state(new: State):
	match new:
		State.SNOWING:
			if _state == State.CLEAR:
				_state = State.SNOW_STARTING
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_LINEAR)  # Ensures linear interpolation
				tween.tween_property(self, "_snow_intensity", 1.0, snow_fade_duration)  # Tween from 0.0 to 100.0 in 2 sec
				await tween.finished
				_state = State.SNOWING
				weather_change_timer.start()
		State.CLEAR:
			if _state == State.SNOWING:
				_state = State.SNOW_STOPPING
				var tween = create_tween()
				tween.set_trans(Tween.TRANS_LINEAR)  # Ensures linear interpolation
				tween.tween_property(self, "_snow_intensity", 0.0, snow_fade_duration)  # Tween from 0.0 to 100.0 in 2 sec
				await tween.finished
				_state = State.CLEAR
				weather_change_timer.start()


func start_snowing():
	transition_to_state(State.SNOWING)


func stop_snowing():
	transition_to_state(State.CLEAR)


func _on_weather_change_timer_timeout():
	if is_snowing():
		stop_snowing()
	else:
		start_snowing()
	weather_change_timer.wait_time = (
		weather_change_frequency_seconds
		+ (weather_change_frequency_seconds * randf() - weather_change_frequency_seconds / 2.0)
	)
	print(
		(
			"Weather: transitioning to %s, then keeping weather state for %fs"
			% [State.keys()[_state], weather_change_timer.wait_time]
		)
	)
