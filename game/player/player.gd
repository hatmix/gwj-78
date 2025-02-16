extends CharacterBody2D

enum State { IDLE, MOVE }

@export var speed: float = 50

var state: State
var last_facing: String = "Right"
var direction: Vector2 = Vector2.ZERO


func get_sprite_facing(radians):
	var angle = int(round(4 * rad_to_deg(radians) / 360)) % 4
	match angle:
		0:
			return "Right"
		-1:
			return "Up"
		1:
			return "Down"
		_:
			return "Left"


func _input(event: InputEvent) -> void:
	direction = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")


func _physics_process(delta: float) -> void:
	if direction.length() > 0:
		state = State.MOVE
		var facing = get_sprite_facing(direction.angle())
		last_facing = facing
		velocity = direction * speed
	else:
		state = State.IDLE
		velocity = Vector2.ZERO

	var animation: String = str(State.keys()[state]).to_pascal_case()
	%StateLabel.text = "%s_%s" % [animation, last_facing]

	move_and_slide()
