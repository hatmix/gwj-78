extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.

## The action to use for advancing the dialogue
@export var next_action: GUIDEAction

## The action to use to skip typing the dialogue
@export var skip_action: GUIDEAction

const MARGIN := 4
const MARGINS := Vector2(4, 4)

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false:
	set(v):
		is_waiting_for_input = v
		if is_waiting_for_input:
			_input_prompt_countdown = input_prompt_delay

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

var _first_line: bool = true

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon
			queue_free()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()
var input_prompt_delay: float = 4.0
var _input_prompt_countdown: float

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

@onready var panel: Panel = %Panel
@onready var skip_prompt: InputPrompt = $Balloon/SkipPrompt
@onready var next_prompt: InputPrompt = $Balloon/NextPrompt


func _ready() -> void:
	print("popup balloon instantiated")
	balloon.hide()
	skip_prompt.visible = false
	next_prompt.visible = false
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)
	#%Balloon.gui_input.connect(_on_balloon_gui_input)
	%ResponsesMenu.response_selected.connect(_on_responses_menu_response_selected)
	%DialogueLabel.spoke.connect(type_sfx)

	# If the responses menu doesn't have a next action set, use this one
	#if responses_menu.next_action.is_empty():
	#	responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if (
		what == NOTIFICATION_TRANSLATION_CHANGED
		and _locale != TranslationServer.get_locale()
		and is_instance_valid(dialogue_label)
	):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


func type_sfx(_letter, _idx, _speed) -> void:
	%TypeOutSfx.play()


## Start some dialogue
func start(
	dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []
) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	is_waiting_for_input = false
	#balloon.focus_mode = Control.FOCUS_ALL
	#balloon.grab_focus()

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")

	# calculate the size of the popup
	%TestLabel.size = Vector2.ZERO
	await get_tree().process_frame
	%TestLabel.text = dialogue_line.text
	await get_tree().process_frame
	#print(%TestLabel.size)
	#dialogue_label.custom_minimum_size = %TestLabel.size
	dialogue_label.size = %TestLabel.size
	panel.size = %TestLabel.size + MARGINS
	skip_prompt.position.y = panel.size.y + MARGIN
	skip_prompt.position.x = panel.size.x - skip_prompt.size.x
	next_prompt.position.y = panel.size.y + MARGIN
	next_prompt.position.x = panel.size.x - next_prompt.size.x
	panel.size.y += 16
	await get_tree().process_frame
	if _first_line:
		balloon.pivot_offset = Vector2(balloon.size.x / 2, balloon.size.y)
		balloon.scale = Vector2.ZERO
		move_bubble_to_player()

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	# Show our balloon
	balloon.show()
	if _first_line:
		_first_line = false
		%PopInSfx.play()
		await create_tween().tween_property(balloon, "scale", Vector2.ONE, 0.1).finished
	will_hide_balloon = false

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		next_prompt.visible = false
		#skip_prompt.visible = true
		await dialogue_label.finished_typing
		#skip_prompt.visible = false

	# Wait for input
	if dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()
	elif dialogue_line.time != "":
		var time = (
			dialogue_line.text.length() * 0.02
			if dialogue_line.time == "auto"
			else dialogue_line.time.to_float()
		)
		is_waiting_for_input = true
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true



func reset_bubble() -> void:
	_first_line = true


func move_bubble_to_player() -> void:
	# Position balloon to player -- do we need the canvas transforms here?
	balloon.global_position = Global.game.player.global_position
	# Offset for proper position
	balloon.global_position += Vector2(0, -(30 + balloon.size.y))
	balloon.global_position.x = max(balloon.pivot_offset.x + MARGIN, balloon.global_position.x)
	balloon.global_position.x = min(320 - balloon.pivot_offset.x - MARGIN, balloon.global_position.x)
	print("balloon positioned at %.1v" % balloon.global_position)


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	mutation_cooldown.start(0.1)


func _process(delta: float) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		if skip_action.is_triggered():
			dialogue_label.skip_typing()
			return

	if is_waiting_for_input and not next_prompt.visible:
		_input_prompt_countdown -= delta
		if _input_prompt_countdown <= 0:
			next_prompt.visible = true

	if not is_waiting_for_input:
		return

	if dialogue_line.responses.size() > 0:
		return

	if next_action.is_triggered():
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)

#endregion
