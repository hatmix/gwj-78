extends Node

var _weather: Weather

# Supposed to be called only by the Weather class. This is how Godot apparently wants us to do Singleton Nodes / Scenes.
func set_weather(new: Weather):
		_weather = new

func get_weather():
	return _weather
