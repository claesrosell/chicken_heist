extends Pickable
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $ChickenBody
@onready var area_2d_2: Area2D = $Area2D2

@export var walking_area_size : float = 150
@export var walking_speed : float = 20
@export var running_speed : float = 500
@export var running_area_size : float = 500

var movement_vector : Vector2 = Vector2.ZERO
#var target_position : Vector2 = Vector2.ZERO
var state_time_left : float = 5
#var last_position : Vector2

enum HenState {Picking, Walking, Running}
var current_state = HenState.Walking

var idle_time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.horn_pressed.connect(_on_horn_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	if current_state == HenState.Picking:
		print("In picking")
		velocity = Vector2.ZERO

	if current_state == HenState.Walking:
		print("In Walking")
		velocity = movement_vector

	if current_state == HenState.Running:
		print("In Running")
		velocity = movement_vector

	if state_time_left <= 0:
		if current_state == HenState.Picking:
			_set_state(HenState.Walking)
		elif current_state == HenState.Walking:
			_set_state(HenState.Picking)
		elif current_state == HenState.Running:
			_set_state(HenState.Walking)

	state_time_left -= delta

	if current_state != HenState.Picking:
		var target_angle =  movement_vector.angle() + PI / 2
		var lerped_angle = lerp_angle(self.rotation, target_angle , 0.5 )
		print("target angle: " + str(target_angle) + " lerped angle: " + str(lerped_angle))
		self.rotation = lerped_angle

#	last_position = self.global_position
	move_and_slide()

func _track_movement(delta: float) -> bool:

	var has_moved := true

	# Check if the character is actually moving
	if velocity.length() > 0.1:
		idle_time = 0.0 # Reset if moving
	else:
		idle_time += delta # Accumulate time if still

	if idle_time >= 2.0:
		has_moved = false
		print("Character has been still for at least 2 seconds")

	return has_moved

func _set_state(new_state : HenState):
	if new_state != current_state:
		if new_state == HenState.Picking:
			state_time_left = 5
			movement_vector = Vector2.ZERO
			animation_player.play("picking")

		if new_state == HenState.Walking:
			state_time_left = 5
			var target_x = randf_range(-walking_area_size/2, walking_area_size/2)
			var target_y = randf_range(-walking_area_size/2, walking_area_size/2)
			movement_vector = Vector2(target_x, target_y).normalized() * walking_speed
			animation_player.play("walking")

		if new_state == HenState.Running:
			state_time_left = 2

			var screen_size = get_viewport_rect().size
			var target_x = randf_range( 100, screen_size.x - 100)
			var target_y = randf_range(100, screen_size.y - 100)
			movement_vector =  (Vector2(target_x, target_y) - self.global_position).normalized() * running_speed
			animation_player.play("running")
			animation_player.queue("running_2")

		current_state = new_state

func get_points() -> int:
	return 10

func picked() -> void:
	area_2d_2.monitorable = false
	animation_player.play("picked")

func _on_horn_pressed() -> void:
	_set_state(HenState.Running)

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	_set_state(HenState.Running)

	var flee_vector = (body.global_position - self.global_position) * -1.0
	flee_vector = flee_vector.rotated( deg_to_rad(randf_range(-45, 45)))
	flee_vector = flee_vector.normalized() * running_area_size

#	var target_x = randf_range(-walking_area_size/2, walking_area_size/2)
#	var target_y = randf_range(-walking_area_size/2, walking_area_size/2)
#	target_position = self.global_position + flee_vector
