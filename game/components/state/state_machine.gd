class_name StateMachine
extends Node

signal state_changed(new_state, old_state)

@export var target: Node
@export var initial_state: FsmState

var current_state: FsmState:
	set = change_to


func change_to(_state: Variant) -> void:
	var new_state: FsmState = _resolve_state(_state)
	if new_state == null or current_state == new_state:
		return
	if current_state:
		current_state.active = false
		await current_state.exit_state()
	await new_state.enter_state()
	new_state.active = true
	if not is_inside_tree():
		await ready
	state_changed.emit(new_state, current_state)
	current_state = new_state


# Find state whether given a FsmState node or string
func _resolve_state(node_or_name: Variant) -> Node:
	if node_or_name is FsmState:
		return node_or_name
	if node_or_name is String:
		var node: Node = find_child(node_or_name)
		if node is FsmState:
			return node
	push_error("Node is not a FsmState or can't find state named '%s'" % node_or_name)
	return


func _ready() -> void:
	for child in get_children():
		if child is FsmState:
			child._state = self
	if initial_state:
		current_state = initial_state


func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)
