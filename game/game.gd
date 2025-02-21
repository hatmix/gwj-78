extends Node

const IN: String = "GradientVertical"
const OUT: String = "GradientVerticalInverted"

@export var default_mapping_context: GUIDEMappingContext
@export var transition_pattern: Image

var snow_color: Color = ProjectSettings.get_setting(
	"rendering/environment/defaults/default_clear_color"
)

@onready var bgm: AudioStreamPlayer = $Bgm
@onready var game_over: Label = $UI/GameOver
@onready var victory: Label = $UI/Victory
@onready var map_placeholder: Node2D = $MapPlaceholder
@onready var map: Map = $MapPlaceholder/Map_1


func _ready() -> void:
	GUIDE.enable_mapping_context(default_mapping_context)
	Global.player_lost.connect(_lose)
	Global.player_won.connect(_win)
	game_over.visible = false
	victory.visible = false
	$UI.show_ui("Game")
	bgm.play()


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("next_level"):
		Global.player_won.emit()


func _lose() -> void:
	game_over.visible = true
	get_tree().paused = true
	await get_tree().create_timer(2.0).timeout
	await Fade.fade_out(1.0, snow_color, OUT).finished
	Fade.fade_in(1.0, snow_color, OUT, true)
	get_tree().set_deferred("paused", false)
	# FIXME: re-instantiate the map, not the whole scene, and make the
	# transition start at the player's position
	get_tree().reload_current_scene()


# TODO: use Fade or make some kind of nice level transition
func _win() -> void:
	victory.visible = true
	get_tree().paused = true
	await get_tree().create_timer(2.0).timeout
	await Fade.fade_out(1.0, snow_color, OUT, true).finished
	if map.next_level:
		var next_level: Map = map.next_level.instantiate()
		map.free()
		map_placeholder.add_child(next_level)
		map = next_level
		victory.visible = false
		Fade.fade_in(1.0, snow_color, IN)
		get_tree().set_deferred("paused", false)
	else:
		Fade.fade_in(1.0, snow_color, IN)
		get_tree().set_deferred("paused", false)
		get_tree().reload_current_scene()
