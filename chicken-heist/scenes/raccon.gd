extends Node2D

var aim_vector : Vector2
@onready var aim: Node2D = $Aim

var shot_to := Vector2.ZERO

func _ready() -> void:
	aim_vector = Vector2(1, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	var new_aim_vector = Input.get_vector("lasso_left", "lasso_right", "lasso_up", "lasso_down")
	if new_aim_vector.length() > 0:
		aim_vector = new_aim_vector

	aim_vector = aim_vector.normalized()
	var shoot_vector = aim_vector * 300
	aim.global_position = self.global_position + shoot_vector

#	line_2d.set_point_position(0, self.global_position)
#	line_2d.set_point_position(1, self.global_position + shot_to)

	if Input.is_action_just_pressed("fire"):
		print("fire")
		shot_to = shoot_vector
