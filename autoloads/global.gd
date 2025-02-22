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

# I guess it is pretty weird/difficult to store a ref to a node in the tree in a var in an autoload
# Doing the previous way was only working until the scene was reloaded. Then, Global was left with
# an empty "previously freed" value. Using the group, it avoids this problem /shrug.
var weather: Weather:
	get:
		return get_tree().get_first_node_in_group("Weather")


func _ready() -> void:
	pass
	#weather_changed.connect(func(v): print("signal weather_changed emitted with value ", v))
	#post_ui_message.connect(func(v): print("signal post_ui_message emitted with value ", v))
