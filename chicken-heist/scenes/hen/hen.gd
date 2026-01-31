extends Pickable
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var area_2d_2: Area2D = $Area2D2

@export var walking_area_size : float = 150
@export var walking_speed : float = 20
@export var running_speed : float = 500
@export var running_area_size : float = 500

var target_position : Vector2 = Vector2.ZERO
var picking_time : float = 5
var last_position : Vector2

enum HenState {Picking, Walking, Running}
var current_state = HenState.Walking

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if current_state == HenState.Picking:
		velocity = Vector2.ZERO
		if picking_time <= 0:
			_set_state(HenState.Walking)

		picking_time -= delta

	if current_state == HenState.Walking:
		_assign_walk_target_position()

		var direction = target_position - self.global_position
		velocity = direction.normalized() * walking_speed

	if current_state == HenState.Running:
		_assign_running_target_position()

		var direction = target_position - self.global_position
		velocity = direction.normalized() * running_speed

	last_position = self.global_position
	move_and_slide()

func _set_state(new_state : HenState):
	if new_state != current_state:
		target_position = Vector2.ZERO
		if new_state == HenState.Picking:
			picking_time = 5

	current_state = new_state

func _assign_walk_target_position():

#	var screen_size = get_viewport_rect().size
	if (target_position - self.global_position).length() < 2:
		target_position = Vector2.ZERO
		_set_state( HenState.Picking )

	if (last_position - self.global_position).length() < 1:
		target_position = Vector2.ZERO

	if target_position == Vector2.ZERO:
		var target_x = randf_range(-walking_area_size/2, walking_area_size/2)
		var target_y = randf_range(-walking_area_size/2, walking_area_size/2)
		target_position = self.global_position + Vector2(target_x, target_y)

func _assign_running_target_position():

#	var screen_size = get_viewport_rect().size
	if (target_position - self.global_position).length() < 5:
		target_position = Vector2.ZERO
		_set_state( HenState.Walking )

	if (last_position - self.global_position).length() < 3:
		target_position = Vector2.ZERO

	if target_position == Vector2.ZERO:
		var target_x = randf_range(-running_area_size/2, running_area_size/2)
		var target_y = randf_range(-running_area_size/2, running_area_size/2)
		target_position = self.global_position + Vector2(target_x, target_y)

func get_points() -> int:
	return 10

func picked() -> void:
	area_2d_2.monitorable = false
	sprite_2d.visible = false
	animation_player.play("picked")


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	_set_state(HenState.Running)

	var flee_vector = (body.global_position - self.global_position) * -1.0
	flee_vector = flee_vector.rotated( deg_to_rad(randf_range(-45, 45)))
	flee_vector = flee_vector.normalized() * running_area_size

#	var target_x = randf_range(-walking_area_size/2, walking_area_size/2)
#	var target_y = randf_range(-walking_area_size/2, walking_area_size/2)
	target_position = self.global_position + flee_vector
