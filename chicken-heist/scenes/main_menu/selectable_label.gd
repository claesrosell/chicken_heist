extends Control
class_name SelectableLabel
# References to the nodes
@onready var bullet_1: Label = %Bullet1
@onready var bullet_2: Label = %Bullet2
@onready var main_text: Label = %Text

@export var dual_mode:=false

# Exported variables to allow easy editing in the Inspector
@export var label_text: String = "Dummy Text":
	set(value):
		label_text = value
		if is_inside_tree():
			main_text.text = value

@export var is_selected_1: bool = false:
	set(value):
		is_selected_1 = value
		_update_bullets()

@export var is_selected_2: bool = false:
	set(value):
		is_selected_2 = value
		_update_bullets()

func _ready() -> void:
	main_text.text = label_text
	_update_bullets()

func _update_bullets() -> void:
	# We use modulate.a (Alpha) to hide/show 
	# This ensures the HBoxContainer doesn't shift the text
	bullet_1.modulate.a = 1.0 if is_selected_1 else 0.0
	bullet_2.modulate.a = 1.0 if is_selected_2 else 0.0
	bullet_2.visible = self.dual_mode
