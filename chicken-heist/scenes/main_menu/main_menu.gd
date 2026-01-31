extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var control: Control = $CanvasLayer/Control

var selected_index := 0
var selected_label : Label

func _ready() -> void:
	_highligh_selected()
	animation_player.play("first_to_main")

func _physics_process(_delta: float) -> void:

	var index = selected_index

	if Input.is_action_just_pressed("p1_d_up") or Input.is_action_just_pressed("p2_d_up"):
		if index > 0 :
			index = index -1
	if Input.is_action_just_pressed("p1_d_down") or Input.is_action_just_pressed("p2_d_down"):
		if index < control.get_child_count(false) -1 :
			index = index + 1
	if Input.is_action_just_pressed("p1_button_a") or Input.is_action_just_pressed("p2_button_a"):
		if index == 0:
			print("play")
			animation_player.play("main_to_none")

		elif index == 1:
			print("how to play")
		elif index == 2:
			print("credits")
		elif index == 3:
			print("exit")

	if index != selected_index:
		selected_index = index
		_highligh_selected()

func _highligh_selected() ->void:
	for ii in control.get_child_count(false):
		var label = control.get_child(ii) as Label
		if ii == selected_index:
			label.set("theme_override_colors/font_color", Color(1, 1, 1))
		else:
			label.set("theme_override_colors/font_color", Color(0, 0, 0))
