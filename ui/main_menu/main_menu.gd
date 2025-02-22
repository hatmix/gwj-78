extends UiPage

@onready var title: TextureRect = $Title
@onready var player: CharacterBody2D = $Player
@onready var buttons: VBoxContainer = %Buttons

var _player_active: bool = false
var _player_exit: bool = false


func _ready() -> void:
	title.visible = false
	buttons.visible = false
	call_deferred("_connect_buttons")
	if OS.get_name() == "Web":
		%Exit.hide()


func _connect_buttons() -> void:
	if ui:
		%Play.pressed.connect(_start_game)
		%HowToPlay.pressed.connect(ui.go_to.bind("HowToPlay"))
		%Settings.pressed.connect(ui.go_to.bind("Settings"))
		%Controls.pressed.connect(ui.go_to.bind("Controls"))
		%Credits.pressed.connect(ui.go_to.bind("Credits"))
		%Exit.pressed.connect(get_tree().call_deferred.bind("quit"))


func _start_game() -> void:
	await Fade.fade_out(1.0, Color("#ebebeb"), "GradientVertical", true).finished
	#Fade.fade_in.call_deferred(1.0, Color("#ebebeb"), "GradientVertical")
	#get_tree().set_deferred("paused", false)
	get_tree().change_scene_to_file("res://game/game.tscn")


func _notification(what: int) -> void:
	if not is_inside_tree():
		await ready
	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if ui and ui.is_shown("MainMenu") and not title.visible:
				# Wait for initial fade in
				await get_tree().create_timer(1.0).timeout
				Fade.crossfade_prepare(2.0, "GradientVertical", true)
				title.visible = true
				buttons.visible = true
				await Fade.crossfade_execute().finished
				await get_tree().create_timer(1.0).timeout
				_player_active = true


func _physics_process(_delta: float) -> void:
	if not visible or not _player_active:
		player.direction = Vector2.ZERO
		return
	# sometimes pause
	if _player_active and Engine.get_frames_drawn() % 1087 == 0:
		player.speed = 0
		get_tree().create_timer(2.0).timeout.connect(func(): player.speed = 10)
	if _player_exit:
		player.direction = player.global_position.direction_to(Vector2(-20, 177))
		if _player_active and player.global_position.x < -10:
			_player_active = false
		return
	if player.global_position.y < 140:
		_player_exit = true
		return
	if player.global_position.x > 160:
		player.direction = Vector2.LEFT.rotated(randf_range(0, 0.1))
	if player.global_position.x < 20:
		player.direction = Vector2.RIGHT.rotated(-randf_range(0, 0.1))
