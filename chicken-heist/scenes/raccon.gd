extends Node2D

var aim_vector : Vector2
@onready var aim: Node2D = $Aim
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"
@onready var aim_sprite: Sprite2D = $Aim/AimSprite
@onready var lasso_line: Line2D = $LassoLine
@onready var foxy_body_2d: CharacterBody2D = $".."
@onready var fetch_sprite_2d: Sprite2D = $FetchSprite2D
@onready var miss_sprite_2d: Sprite2D = $MissedSprite2D
@onready var rocky_hand_node: Node2D = $RacconSprite/RockyHandNode

@export var aim_distance := 300.0
@export var aim_speed := 500.0
@export var aim_retract_speed := 10.0
@export var fetch_retract_speed := 2000.0

var shot_to_vector_from_hand := Vector2.ZERO
var shot_to_vector_from_hand_length := 0.0

enum FetchType { None, Hit, Miss }
var show_fetch_type : FetchType =  FetchType.None

var current_pickable : Pickable

func _ready() -> void:
	aim_vector = Vector2(1, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Rotate the crosshair to make it look fancy
	aim_sprite.rotate(delta)

	shot_to_vector_from_hand_length -= fetch_retract_speed * delta
	if(shot_to_vector_from_hand_length < 0) :
		shot_to_vector_from_hand_length = 0
		show_fetch_type = FetchType.None

	if show_fetch_type == FetchType.Hit:
		fetch_sprite_2d.visible = true
		miss_sprite_2d.visible = false
		lasso_line.visible = true
	elif show_fetch_type == FetchType.Miss:
		fetch_sprite_2d.visible = false
		miss_sprite_2d.visible = true
		lasso_line.visible = true
	else:
		fetch_sprite_2d.visible = false
		miss_sprite_2d.visible = false
		lasso_line.visible = false





	# Handle aim input and crosshair logic
	var new_aim_vector = Input.get_vector(GameManager.rocky_controls.lasso_left, GameManager.rocky_controls.lasso_right, GameManager.rocky_controls.lasso_up, GameManager.rocky_controls.lasso_down)

	var aim_from_pos := self.global_position

	var aim_vector = aim.global_position - aim_from_pos
	aim_vector += new_aim_vector * aim_speed * delta

	var aim_vector_length = aim_vector.length()
	if aim_vector_length > aim_distance:
		aim_vector_length = aim_distance;

	if new_aim_vector.length() == 0:
		aim_vector_length -= aim_retract_speed

	if(aim_vector_length < 0) :
		aim_vector_length = 0

	aim.global_position = aim_from_pos + aim_vector.normalized() *  aim_vector_length

	# Handle shot to logic

	var shot_hen_pos = rocky_hand_node.global_position + shot_to_vector_from_hand * shot_to_vector_from_hand_length

	lasso_line.points[0] = rocky_hand_node.global_position
	lasso_line.points[1] = shot_hen_pos

	miss_sprite_2d.global_position = shot_hen_pos + Vector2(10,10)
	fetch_sprite_2d.global_position = shot_hen_pos + Vector2(10,10)


#	line_2d.set_point_position(0, self.global_position)
#	line_2d.set_point_position(1, self.global_position + shot_to)

	if Input.is_action_just_pressed(GameManager.rocky_controls.lasso_fire):
		print("fire")

		var v = aim.global_position - rocky_hand_node.global_position
		shot_to_vector_from_hand_length = v.length()
		shot_to_vector_from_hand = v.normalized()

		if current_pickable != null:
			GameManager.modify_score(current_pickable.get_points())
			current_pickable.picked()
			show_fetch_type = FetchType.Hit
		else:
			show_fetch_type = FetchType.Miss

	if Input.is_action_just_pressed(GameManager.rocky_controls.rocky_horn):
		audio_stream_player_2d.play()
		GameManager.horn_pressed.emit()

func _on_area_2d_area_entered(area: Area2D) -> void:

	var owner = area.get_parent()

	if owner is Pickable && current_pickable == null:
		current_pickable = owner
		print("hen entered")

func _on_area_2d_area_exited(area: Area2D) -> void:
	var owner = area.get_parent()
	if owner is Pickable && current_pickable == owner:
		current_pickable = null
		print("hen exit")
