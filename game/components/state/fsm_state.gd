class_name FsmState
extends Node

# injected by state machine
@warning_ignore("unused_variable")
var active: bool = false
@warning_ignore("unused_private_class_variable")
var _state: StateMachine


func enter_state():
	pass


func exit_state():
	pass


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	pass
