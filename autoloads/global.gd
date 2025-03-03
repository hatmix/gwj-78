extends Node

@warning_ignore("unused_signal")
signal player_lost
@warning_ignore("unused_signal")
signal player_won

@warning_ignore("unused_signal")
signal game_state_changed(state: Game.State)
@warning_ignore("unused_signal")
signal level_started(level_scene: String)

@warning_ignore("unused_signal")
signal weather_changed(state: Weather.State)

## Use UI/MessageBox to display a status update message to the player
@warning_ignore("unused_signal")
signal post_ui_message(text: String)
## Emitted by UI/Controls when a action is remapped
@warning_ignore("unused_signal")
signal controls_changed(config: GUIDERemappingConfig)

const COLOR_BRIGHT := Color("ebebeb")
const COLOR_SHADOW := Color("#9cafb3")
const COLOR_BUTTON := Color("c4c6c8")
const COLOR_MID := Color("889ca1")
const COLOR_DARK := Color("565a5d")
const COLOR_BLACK := Color("#242430")
var COLOR_CLEAR: Color = ProjectSettings.get_setting(
	"rendering/environment/defaults/default_clear_color"
)

# I guess it is pretty weird/difficult to store a ref to a node in the tree in a var in an autoload
# Doing the previous way was only working until the scene was reloaded. Then, Global was left with
# an empty "previously freed" value. Using the group, it avoids this problem /shrug.
var weather: Weather:
	get:
		return get_tree().get_first_node_in_group("Weather")

var game: Game:
	get:
		return get_tree().get_first_node_in_group("Game")

# Used to track dialogue/story stuff
var p_state_defaults: Dictionary = {
	"mud": false,
	"mud_expired": false,
	"transponder_offer": false,
	"transponder_taken": false,
	"transponder_used": false,
	"reaction": "",
}

# initialized by game _ready but duplicated for testing dialogue in engine
var p_state: Dictionary = {
	"mud": false,
	"mud_expired": false,
	"transponder_offer": false,
	"transponder_taken": false,
	"transponder_used": false,
	"reaction": "",
}


func _ready() -> void:
	pass
	weather_changed.connect(func(v): print("signal weather_changed emitted with value ", v))
	level_started.connect(func(v): print("signal level_started emitted with value ", v))
	#post_ui_message.connect(func(v): print("signal post_ui_message emitted with value ", v))
