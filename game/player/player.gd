extends CharacterBody2D

enum State { IDLE, WALK }

@export var speed: float = 30

var state: State
var last_facing: String = "Right"
var direction: Vector2 = Vector2.ZERO

@onready var visual: Sprite2D = $Visual
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var footsteps_sfx: AudioStreamPlayer = $FootstepsSfx


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


func _input(_event: InputEvent) -> void:
	direction = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	if Input.is_action_just_pressed("DebugHide"):
		var toggle: bool = !get_collision_layer_value(4)
		set_collision_layer_value(4, toggle)
		if toggle:
			visual.self_modulate = Color("#FFFFFFFF")
		else:
			visual.self_modulate = Color("#FFFFFF88")


func _physics_process(_delta: float) -> void:
	if direction.length() > 0:
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
