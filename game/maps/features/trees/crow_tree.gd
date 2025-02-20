extends StaticBody2D

@onready var crow: Area2D = $CrowInteraction
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# Only react to drones if player was last one reacted to
var crow_for_drones: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#crow.area_entered.connect(_on_area_entered)
	crow.body_entered.connect(_on_body_entered)


func _on_area_entered(area: Area2D) -> void:
	print(area.name, " entered crow's area")
	if area.get_parent().is_in_group("Drones"):
		anim_player.play("circle")


func _on_body_entered(body: Node2D) -> void:
	print(body.name, " entered crow's area with delay time let ", $Timer.time_left)
	if body.name == "Player" and $Timer.is_stopped():
		anim_player.play("caws")
		crow_for_drones = false
		$Timer.start()
	elif body.is_in_group("Drones") and not crow_for_drones and $Timer.is_stopped():
		anim_player.play("circle")
		crow_for_drones = true
		$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
