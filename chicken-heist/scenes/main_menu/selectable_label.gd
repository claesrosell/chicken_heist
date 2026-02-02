@tool
extends Control
class_name SelectableLabel

@onready var bullet_1: Panel = %Bullet1
@onready var bullet_2: Panel = %Bullet2
@onready var main_text: Label = %Text

@export_group("Visuals")
## How large the bullet should be relative to the font size (e.g., 0.7)
@export var bullet_scale_ratio: float = 0.4:
	set(value):
		bullet_scale_ratio = value
		_update_visuals()

@export var dual_mode: bool = false:
	set(value):
		dual_mode = value
		_update_bullets()

@export_range(0, 50) var spacing: int = 10:
	set(value):
		spacing = value
		_update_spacing()

@export var label_text: String = "Selectable Item":
	set(value):
		label_text = value
		if main_text:
			main_text.text = value

@export_group("Selection")
@export var is_selected_1: bool = false:
	set(value):
		is_selected_1 = value
		_update_bullets()

@export var is_selected_2: bool = false:
	set(value):
		is_selected_2 = value
		_update_bullets()

func _ready() -> void:
	if main_text:
		main_text.text = label_text
	_update_visuals()
	_update_bullets()

## Handles size, outline, and shape in one go
func _update_visuals() -> void:
	if not bullet_1 or not main_text:
		return

	# 1. Get current font theme data
	var font_size = main_text.get_theme_font_size("font_size")
	var font_color = main_text.get_theme_color("font_color")
	var outline_size = main_text.get_theme_constant("outline_size") / 3
	var outline_color = main_text.get_theme_color("font_outline_color")
	
	# 2. Calculate the base bullet size
	var bullet_dim = float(font_size) * bullet_scale_ratio
	var bullet_vec = Vector2(bullet_dim, bullet_dim)
	
	# Set the node size
	bullet_1.custom_minimum_size = bullet_vec
	bullet_2.custom_minimum_size = bullet_vec
	
	# 3. Create/Sync the StyleBox
	# We duplicate it so we don't accidentally change other UI elements in the game
	var base_sb = bullet_1.get_theme_stylebox("panel")
	if not base_sb: return # Safety check
	
	var sb = base_sb.duplicate() as StyleBoxFlat
	if sb:
		# Sync Color
		sb.bg_color = font_color
		# Sync Outline
		sb.set_border_width_all(outline_size)
		sb.border_color = outline_color
		# Expand margin so the outline is "Outside" the bullet size
		sb.expand_margin_left = outline_size
		sb.expand_margin_top = outline_size
		sb.expand_margin_right = outline_size
		sb.expand_margin_bottom = outline_size
		
		# Ensure it's a circle
		sb.set_corner_radius_all(int(bullet_dim))
		
		# Apply unique style to nodes
		bullet_1.add_theme_stylebox_override("panel", sb)
		bullet_2.add_theme_stylebox_override("panel", sb)

# Assuming your HBoxContainer is named "HBox" or similar
# If the root of your scene IS the HBoxContainer, use 'self'
func _update_spacing() -> void:
	var hbox = $HBoxContainer # Update this path to your actual HBox node
	hbox.add_theme_constant_override("separation", spacing)

func _update_bullets() -> void:
	if not bullet_1: return
	bullet_1.modulate.a = 1.0 if is_selected_1 else 0.0
	bullet_2.modulate.a = 1.0 if is_selected_2 else 0.0
	bullet_2.visible = dual_mode
