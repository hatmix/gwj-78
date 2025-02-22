@tool
extends ProgrammaticTheme

const BRIGHT := Color("#ebebeb")
const SNOW := Color("cbd5d7")
const MID := Color("#9cafb3")
const MID_DARK := Color("889ca1")
const LESS_DARK := Color("565a5d")
const BLACK := Color("#242430")


# The project's default theme is set to res://ui/ui_theme.tres
func setup() -> void:
	set_save_path("res://ui/ui_theme.tres")


# TODO: Consider defining the UI theme below with ThemeGen or manually edit res://ui/ui_theme.tres
func define_theme() -> void:
	define_default_font(ResourceLoader.load("res://assets/fonts/pixelFont-4-7x7-sproutLands.ttf"))
	define_default_font_size(9)

	var sb_snow = stylebox_flat({
		border_ = border_width(2),
		border_color = BRIGHT,
		corners_ = corner_radius(4),
		bg_color = LESS_DARK,
		expand_margins_ = expand_margins(3),
		shadow_color = BRIGHT,
		shadow_size = 2,
		shadow_offset = Vector2i(0, -2),
		skew = Vector2(0.2, 0),
		anti_aliasing = false,
	})

	define_style(
		"Button",
		{
			font_color = BLACK,
			font_focus_color = MID_DARK,
			font_pressed_color = MID_DARK,
			font_hover_color = MID_DARK,
			font_outline_color = BRIGHT,
			outline_size = 2,
			normal = sb_snow,
			focus = sb_snow,
			hover = sb_snow,
			pressed = sb_snow,
		}
	)

	define_style(
		"Label",
		{
			font_color = BLACK,
			font_outline_color = BRIGHT,
			outline_size = 2,
		}
	)

	define_variant_style(
		"GameOver",
		"Label",
		{
			font_color = BLACK,
			font = ResourceLoader.load("res://assets/fonts/pixelFont-3-7x5-sproutLands.ttf"),
			font_size = 32,
			font_outline_color = BRIGHT,
			outline_size = 6,
			font_shadow_color = BRIGHT,
			shadow_offset_y = -4,
			shadow_outline_size = 4,
			
		}
	)

	define_style(
		"RichTextLabel",
		{
			default_color = BLACK,
			outline_size = 2,
			font_outline_color = BRIGHT,
			font_shadow_color = BRIGHT,
			shadow_offset_y = -2,
			shadow_outline_size = 2,
			line_separation = 2,
			normal_font = load("res://assets/fonts/pixelFont-3-7x5-sproutLands.ttf"),
			normal_font_size = 8,
			bold_font_size = 8,
			mono_font_size = 8,
			italics_font_size = 8,
			focus = stylebox_flat(
				{
					border_ = border_width(2),
					border_color = MID,
					corners_ = corner_radius(2),
					bg_color = Color.TRANSPARENT,
				},
			)
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

#region BuildInfo label style
	define_variant_style("BuildInfoLabel", "Label", 
		{
			font = ResourceLoader.load("res://assets/fonts/pixelFont-2-5x5-sproutLands.ttf"),
			font_size = 8,
			font_color = BLACK,
			outline_size = 0
		}
	)

#endregion
