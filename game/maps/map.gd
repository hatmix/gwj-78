class_name Map
extends Node2D

const DRONE_SCENE: PackedScene = preload("res://game/enemies/drone/drone.tscn")
const MAP_BORDERS_SCENE: PackedScene = preload("res://game/maps/map_borders/map_borders.tscn")

@export var next_level: PackedScene


func spawn_borders() -> void:
	var borders = MAP_BORDERS_SCENE.instantiate()
	add_child(borders)


func spawn_drone(pos: Vector2 = Vector2(20, 20)) -> void:
	var drone: Drone = DRONE_SCENE.instantiate()
	drone.process_mode = Node.PROCESS_MODE_DISABLED
	drone.visible = false
	add_child(drone)
	drone.global_position = pos
	drone.process_mode = Node.PROCESS_MODE_PAUSABLE
	drone._state.change_to("Dialogue")
	drone.visible = true


func _ready() -> void:
	# Reset player position to 0,0 so dialogue offsets work as expected
	var global_pos: Vector2 = Global.game.player.global_position
	Global.game.player.position = Vector2.ZERO
	Global.game.player.global_position = global_pos
