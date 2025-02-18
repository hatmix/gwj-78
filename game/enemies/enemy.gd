class_name Enemy
extends CharacterBody2D

@export var speed: float = 10.0

var direction: Vector2


func _input(_event: InputEvent) -> void:
	# FIXME: Enemies move in the reverse of player input for now
	direction = Input.get_vector("Move Right", "Move Left", "Move Down", "Move Up")


func _physics_process(_delta: float) -> void:
	if direction:
		velocity = direction * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)

	move_and_slide()
