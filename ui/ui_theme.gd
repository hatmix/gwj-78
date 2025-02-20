@tool
extends ProgrammaticTheme

const BRIGHT := Color("#ebebeb")
const MID := Color("#9cafb3")
const DARK := Color("#242430")


# The project's default theme is set to res://ui/ui_theme.tres
func setup() -> void:
	set_save_path("res://ui/ui_theme.tres")


# TODO: Consider defining the UI theme below with ThemeGen or manually edit res://ui/ui_theme.tres
func define_theme() -> void:
	define_default_font(ResourceLoader.load("res://assets/fonts/pixelFont-4-7x7-sproutLands.ttf"))
	define_default_font_size(9)

	var sb_flat = stylebox_flat(
		{
			bg_color = MID,
			shadow_color = DARK,
			shadow_size = 1,
			shadow_offset = Vector2(-1, 1),
		}
	)

	define_style("Panel", {panel = sb_flat})
	define_style("PanelContainer", {panel = sb_flat})
	define_style(
		"Button",
		{
			font_color = BRIGHT,
			font_outline_color = DARK,
			outline_size = 2,
		}
	)

	define_style(
		"Label",
		{
			font_color = BRIGHT,
			font_outline_color = DARK,
			outline_size = 2,
		}
	)

	define_variant_style(
		"GameOver",
		"Label",
		{
			font_color = DARK,
			font = ResourceLoader.load("res://assets/fonts/pixelFont-3-7x5-sproutLands.ttf"),
			font_size = 32,
			font_outline_color = MID,
			outline_size = 6,
		}
	)

#region Message (notifications) controls styling
	define_variant_style("MessagePanelContainer", "PanelContainer", {panel = stylebox_empty({})})
	define_variant_style("MessageLabel", "Label", {outline_size = 6})
#endregion

#region Remapping controls styling
	# Buttons used for remapping controls are styled to have just a border for hover and focus
	var sb_remap_button_focused = stylebox_flat(
		{
			border_ = border_width(2),
			border_color = Color.WHITE,
			corners_ = corner_radius(2),
			bg_color = Color.TRANSPARENT,
		}
	)
	define_variant_style(
		"RemapButton",
		"Button",
		{
			normal = stylebox_empty({}),
			focus = sb_remap_button_focused,
			pressed = sb_remap_button_focused,
			hover =
			inherit(sb_remap_button_focused, stylebox_flat({border_color = Color.DIM_GRAY})),
		}
	)
	# Empty style to prevent other style changes from affecting controls UI... but does it?
	define_variant_style("RemapRichTextLabel", "RichTextLabel", {})
#endregion
