extends CanvasLayer

const IN: String = "GradientVertical"
const OUT: String = "GradientVerticalInverted"


# TODO: consider using the hide_ui and show_ui functions to add ui animation
func hide_ui(page: Variant = null) -> void:
	if page:
		var ui_page: UiPage = _resolve_ui_page(page)
		if ui_page:
			if ui_page.has_method("hide_ui"):
				await ui_page.hide_ui()
			else:
				ui_page.hide()
	else:
		for child: Node in get_children():
			if child is UiPage and child.visible:
				if child.has_method("hide_ui"):
					await child.hide_ui()
				else:
					child.hide()


func show_ui(page: Variant) -> void:
	var ui_page: UiPage = _resolve_ui_page(page)
	if ui_page:
		if ui_page.has_method("show_ui"):
			await ui_page.show_ui()
		else:
			ui_page.show()
		print("show_ui ", page, " called")
		# Uncomment to capture screenshots in media/ folder
		# Must wait for visibility changes and one frame is not enough
		#await get_tree().create_timer(0.2).timeout
		#var cap := get_viewport().get_texture().get_image()
		#cap.save_png("media/%s.png" % ui_page.name)


func go_to(page: Variant) -> void:
	hide_ui()
	show_ui(page)


func is_shown(page: Variant) -> bool:
	var ui_page: CanvasItem = _resolve_ui_page(page)
	if ui_page:
		return ui_page.visible
	return false


func _resolve_ui_page(node_or_name: Variant) -> Node:
	if node_or_name is UiPage:
		return node_or_name
	if node_or_name is String:
		var node: Node = find_child(node_or_name)
		if node is UiPage:
			return node
	push_error("Can't find ui page ", node_or_name)
	return


func _ready() -> void:
	Global.game_state_changed.connect(_on_game_state_changed)
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	hide()
	for child: Node in get_children():
		if child is UiPage:
			#print("injecting ui in ", child.name)
			child.set("ui", self)
			child.hide()
	show()


func _on_game_state_changed(new_state: Game.State) -> void:
	match new_state:
		Game.State.PLAY:
			print("ui set process mode ALWAYS")
			set_process_mode(Node.PROCESS_MODE_ALWAYS)
		Game.State.DIALOGUE:
			print("ui set process mode DISABLED")
			set_process_mode(Node.PROCESS_MODE_DISABLED)


func _unhandled_input(event: InputEvent) -> void:
	# I think this could be simplified somehow, but I'm not getting it just yet
	# If nothing focused, trying to focus next will focus something
	var focus_owner: Node = get_viewport().gui_get_focus_owner()
	#print("focus owner is ", focus_owner)
	if (
		(event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_controls"))
		and not focus_owner
	):
		_focus_something()
		get_viewport().set_input_as_handled()
		return

	# If something focused, ui_cancel will release focus
	if event.is_action_pressed("ui_cancel") and focus_owner:
		focus_owner.release_focus()
		get_viewport().set_input_as_handled()
		return

	if (event is InputEventJoypadMotion or event is InputEventJoypadButton) and focus_owner == null:
		for child: Node in get_children():
			if not child is UiPage or not child.visible:
				continue
			child = child as UiPage
			if not child.prevent_joypad_focus_capture:
				_focus_something()
				get_viewport().set_input_as_handled()
				break


func _focus_something() -> void:
	print("_focus_something called (looking for sporadic hanging bug)")
	for child: Node in get_children():
		if not child is UiPage or not child.visible:
			continue
		# use default focus control if defined
		child = child as UiPage
		if child.default_focus_control:
			child.default_focus_control.grab_focus()
			return
		# grab_focus on first button found
		for button: Button in child.find_children("*", "Button"):
			# Helpful for discovering focus going to a button hidden by a parent
			#print("Focus something found button %s" % button.name)
			if button.visible:
				button.grab_focus()
				break


func _on_focus_changed(_control: Control) -> void:
	# Can do something interesting with focus here...
	pass
