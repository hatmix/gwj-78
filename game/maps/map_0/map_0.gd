extends Map


func _ready() -> void:
	# pause weather for effect
	if is_instance_valid(Global.weather):
		Global.weather.snow_fade_duration = 0.0
		Global.weather.stop_snowing()
		Global.weather.weather_change_timer.process_mode = Node.PROCESS_MODE_DISABLED
		Global.weather.set_deferred("snow_fade_duration", 3.0)
	
	
func resume_weather() -> void:
	# Needed to re-enable random weather that was disabled for effect above
	Global.weather.weather_change_timer.process_mode = Node.PROCESS_MODE_INHERIT
	Global.weather.weather_change_timer.start()
