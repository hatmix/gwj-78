extends Node

const CAMPFIRE_COLOR: Color = Color("#e8cdba")

@export var default_mapping_context: GUIDEMappingContext

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


func transition_out(start_point: Vector2, color: Color = CAMPFIRE_COLOR) -> Fade:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = [0,1]
	gradient.colors = [Color("#00000000"), Color("#ffffffff")]

	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	# Need a square texture to avoid bad aspect for circles
	texture.width = 320
	texture.height = 320
	texture.fill = GradientTexture2D.FILL_RADIAL
	# but crop happens from center, so adjust y uv calc
	var slope: float = 16/9
	texture.fill_from = Vector2(start_point.x/320, start_point.y/320 * slope + 70/320)
	texture.fill_to = texture.fill_from * - 1
	var img: Image = texture.get_image()
	img.crop(320,180)
	
	return Fade.fade_out(1.0, color, ImageTexture.create_from_image(img), true)


func transition_in(start_point: Vector2, color: Color = CAMPFIRE_COLOR) -> Fade:
	var gradient: Gradient = Gradient.new()
	gradient.offsets = [0,1]
	gradient.colors = [Color("#ffffffff"), Color("#00000000")]

	var texture: GradientTexture2D = GradientTexture2D.new()
	texture.gradient = gradient
	# Need a square texture to avoid bad aspect for circles
	texture.width = 320
	texture.height = 320
	texture.fill = GradientTexture2D.FILL_RADIAL
	# but crop happens from center, so adjust y uv calc
	var slope: float = 16/9
	texture.fill_from = Vector2(start_point.x/320, start_point.y/320 * slope + 70/320)
	texture.fill_to = texture.fill_from * - 1
	var img: Image = texture.get_image()
	img.crop(320,180)
	
	return Fade.fade_in(1.0, color, ImageTexture.create_from_image(img))



func _lose() -> void:
	game_over.visible = true
	get_tree().paused = true
	await get_tree().create_timer(2.0).timeout
	var start_point: Vector2 = Vector2(160,90)
	var player = get_tree().get_first_node_in_group("Player")
	if is_instance_valid(player):
		start_point = player.global_position
	var fade: Fade = transition_out(start_point)
	await fade.finished
	transition_in.bind(start_point).call_deferred()
	get_tree().set_deferred("paused", false)
	# FIXME: re-instantiate the map, not the whole scene, and make the
	# transition start at the player's position
	get_tree().reload_current_scene()


# TODO: use Fade or make some kind of nice level transition
func _win() -> void:
	victory.visible = true
	get_tree().paused = true
	await get_tree().create_timer(2.0).timeout
	var start_point: Vector2 = Vector2(160,90)
	var player = get_tree().get_first_node_in_group("Player")
	if is_instance_valid(player):
		start_point = player.global_position
	var fade: Fade = transition_out(start_point)
	await fade.finished
	if map.next_level:
		var next_level: Map = map.next_level.instantiate()
		map.free()
		map_placeholder.add_child(next_level)
		map = next_level
		victory.visible = false
		start_point = Vector2(160,90)
		player = get_tree().get_first_node_in_group("Player")
		if is_instance_valid(player):
			start_point = player.global_position
		fade = transition_in(start_point)
		await fade.finished
		
		get_tree().set_deferred("paused", false)
	else:
		transition_in.bind(start_point).call_deferred()
		get_tree().set_deferred("paused", false)
		get_tree().reload_current_scene()
