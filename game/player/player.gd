extends CharacterBody2D

signal in_position

enum State { IDLE, WALK }

@export var move_action: GUIDEAction
@export var speed: float = 30

var state: State
var last_facing: String = "Right"
var direction: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO

@onready var visual: Sprite2D = $Visual
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var footsteps_sfx: AudioStreamPlayer = $FootstepsSfx
@onready var interaction_area_2d: Area2D = $InteractionArea2D


func get_sprite_facing(radians):
	var angle = int(round(4 * rad_to_deg(radians) / 360)) % 4
	match angle:
		0:
			return "right"
		-1:
			return "up"
		1:
			return "down"
		_:
			return "left"


func footstep() -> void:
	footsteps_sfx.play()


func _hide(enabled: bool = true) -> void:
	set_collision_layer_value(4, !enabled)
	if enabled:
		visual.self_modulate = Color("#FFFFFF88")
	else:
		visual.self_modulate = Color("#FFFFFFFF")


func move_to(point: Vector2) -> void:
	if Global.game.state != Game.State.DIALOGUE:
		return
	print("moving player to %v" % point)
	_target_position = point
	direction = global_position.direction_to(_target_position)
	await in_position


func _ready() -> void:
	move_action.triggered.connect(_on_move_action)
	move_action.completed.connect(_on_move_action)
	interaction_area_2d.area_entered.connect(_on_area_entered)
	interaction_area_2d.area_exited.connect(_on_area_exited)


func _on_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Trees"):
		_hide()


func _on_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("Trees"):
		_hide(false)


func _on_move_action():
	direction = move_action.value_axis_2d.normalized()


func _input(_event: InputEvent) -> void:
	if OS.is_debug_build() and Input.is_action_just_pressed("DebugHide"):
		# toggle on whether collision layer is on
		_hide(get_collision_layer_value(4))


func _physics_process(_delta: float) -> void:
	if _target_position and global_position.distance_to(_target_position) <= 4:
		_target_position = Vector2.ZERO
		direction = Vector2.ZERO
		in_position.emit()

	if direction.length() > 0 and speed > 0:
		state = State.WALK
		var facing = get_sprite_facing(direction.angle())
		last_facing = facing
		velocity = direction * speed
	else:
		state = State.IDLE
		velocity = Vector2.ZERO

	var animation: String = str(State.keys()[state]).to_lower()

	match state:
		State.IDLE:
			visual.flip_h = (last_facing == "left")
			anim_player.play("idle")
		State.WALK:
			visual.flip_h = false
			anim_player.play("%s-%s" % [animation, last_facing])

	%StateLabel.text = "%s-%s" % [animation, last_facing]

	move_and_slide()

	#if move_and_slide() and _target_position:
	#	var collider: KinematicCollision2D = get_last_slide_collision()
