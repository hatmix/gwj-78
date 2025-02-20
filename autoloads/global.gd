extends Node

@warning_ignore("unused_signal")
signal player_lost
@warning_ignore("unused_signal")
signal player_won

@warning_ignore("unused_signal")
signal weather_changed(state: Weather.State)

## Use UI/MessageBox to display a status update message to the player
@warning_ignore("unused_signal")
signal post_ui_message(text: String)

## Emitted by UI/Controls when a action is remapped
@warning_ignore("unused_signal")
signal controls_changed(config: GUIDERemappingConfig)


var _weather: Weather


# Supposed to be called only by the Weather class. This is how Godot apparently wants us to do Singleton Nodes / Scenes.
func set_weather(new: Weather):
	_weather = new


func get_weather():
	return _weather


func _ready() -> void:
	pass
	#weather_changed.connect(func(v): print("signal weather_changed emitted with value ", v))
