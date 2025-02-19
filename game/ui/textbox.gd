extends Control

const CHARACTER_DELAY := 0.04
const PITCH_MIN := 0.97
const PITCH_MAX := 1.03

enum STATE {
	RUNNING_TEXT,
	WAITING,
}

# TODO: Move dialogue data out of this class.
var char_narrator = DialogCharacter.new("", Color.BLACK, null)
var char_hero     = DialogCharacter.new("Character 1", Color.DARK_BLUE,
		preload("res://game/enemies/drone/assets/static-dron.png"))
var char_sidekick = DialogCharacter.new("Character 2", Color.LIME_GREEN,
		preload("res://game/enemies/drone/assets/static-dron.png"))

var dialog := [
	DialogPart.new(
		char_narrator,
		"Narrator narrates."
	),
	DialogPart.new(
		char_hero,
		"Hero says."
	),
	DialogPart.new(
		char_sidekick,
		"Sidekick says."
	),
	DialogPart.new(
		char_hero,
		"Hero responds."
	),
	DialogPart.new(
		char_narrator,
		"..."
	),
	DialogPart.new(
		char_sidekick,
		"Maybe the hero needs a little help..."
	),
]


var state: int = STATE.RUNNING_TEXT
var current_part: int
@onready var label := $DialogTextbox/MarginContainer/VBoxContainer/RichTextLabel
@onready var portrait := $DialogTextbox/MarginContainer/VBoxContainer/TextureRect
@onready var sfx_voice_high := $AudioStreamPlayerHigh
@onready var sfx_voice_low := $AudioStreamPlayerLow
@onready var text_tween: Tween


# Called when the node enters the scene tree for the first time.
func _ready():
	show_next_part()


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if state == STATE.RUNNING_TEXT:
			text_tween.kill()
			label.visible_ratio = 1.0
			_on_TweenText_tween_completed()
		elif state == STATE.WAITING:
			show_next_part()
	if state == STATE.RUNNING_TEXT and not current_part == dialog.size():
		if dialog[current_part].character == char_sidekick \
		   and not sfx_voice_high.is_playing():
			sfx_voice_high.pitch_scale = randf_range(PITCH_MIN, PITCH_MAX)
			sfx_voice_high.play()
		if dialog[current_part].character == char_hero \
		   and not sfx_voice_low.is_playing():
			sfx_voice_low.pitch_scale = randf_range(PITCH_MIN, PITCH_MAX)
			sfx_voice_low.play()


func show_next_part():
	if current_part == dialog.size():
		print("dialog sequence done")
		# TODO: implement level and scene transitions
		return
	state = STATE.RUNNING_TEXT
	var part: DialogPart = dialog[current_part]
	var text := ""
	
	if part.character.portrait:
		portrait.texture = part.character.portrait
	else:
		portrait.texture = null
	
	if not part.character.name.is_empty():
		text = "[color=#%s]%s[/color]\n" \
				% [part.character.name_color.to_html(false), part.character.name]

	text += part.text
	label.visible_ratio = 0.0
	label.bbcode_enabled = true
	label.text = text
	text_tween = get_tree().create_tween()
	text_tween.tween_property(label, "visible_ratio", 1, text.length() * CHARACTER_DELAY)
	await text_tween.finished
	_on_TweenText_tween_completed()


func _on_TweenText_tween_completed(_object = null, _key = null):
	state = STATE.WAITING
	current_part += 1


class DialogPart:
	var character: DialogCharacter
	var text: String
	
	func _init(_character: DialogCharacter, _text: String):
		character = _character
		text = _text


class DialogCharacter:
	var name: String
	var name_color: Color
	var portrait: Texture
	
	func _init(_name: String, _name_color: Color, _portrait: Texture):
		name = _name
		name_color = _name_color
		portrait = _portrait
