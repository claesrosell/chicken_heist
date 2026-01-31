extends Node2D

var aim_vector : Vector2
@onready var aim: Node2D = $Aim

var shot_to := Vector2.ZERO

@export var aim_distance := 300.0
@export var aim_speed := 500.0
@export var aim_retract_speed := 10.0

var current_pickable : Pickable

func _ready() -> void:
	aim_vector = Vector2(1, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	var new_aim_vector = Input.get_vector(Game.rocky_controls.lasso_left, Game.rocky_controls.lasso_right, Game.rocky_controls.lasso_up, Game.rocky_controls.lasso_down)

#	if new_aim_vector.length() > 0:
#		aim_vector = new_aim_vector

	aim_vector = aim_vector.normalized()
#	var shoot_vector = aim_vector * 300
#	aim.global_position = self.global_position + shoot_vector

	var aim_vector = aim.global_position - self.global_position
	aim_vector += new_aim_vector * aim_speed * delta

	var aim_vector_length = aim_vector.length()
	if aim_vector_length > aim_distance:
		aim_vector_length = aim_distance;

	if new_aim_vector.length() == 0:
		aim_vector_length -= aim_retract_speed

	if(aim_vector_length < 0) :
		aim_vector_length = 0

	aim.global_position = self.global_position + aim_vector.normalized() *  aim_vector_length

#	line_2d.set_point_position(0, self.global_position)
#	line_2d.set_point_position(1, self.global_position + shot_to)

	if Input.is_action_just_pressed(Game.rocky_controls.lasso_fire):
		print("fire")
		if current_pickable != null:
			Game.modify_score(current_pickable.get_points())
			current_pickable.picked()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Pickable && current_pickable == null:
		current_pickable = area
		print("hen entered")

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area is Pickable && current_pickable == area:
		current_pickable = null
		print("hen exit")
