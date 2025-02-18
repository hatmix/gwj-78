class_name FsmState
extends Node

# injected by state machine
var active: bool = false
var _state: StateMachine


func enter_state():
	pass


func exit_state():
	pass


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	pass
