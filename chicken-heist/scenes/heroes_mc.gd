extends CharacterBody2D
@onready var steering_wheel: Sprite2D = $SteeringWheel

# --- CAR SETUP ---
var wheel_base := 65      # Distance from front to rear wheel
var steering_angle := 25  # Max turn angle (in degrees)

# --- PHYSICS ---
var engine_power := 1200   # Forward force
var braking := -650.0     # Braking force
var max_speed_reverse := 450.0

var friction := -55.0     # Ground friction (constant drag)
var drag := -0.06         # Air resistance (increases with speed)

# --- DRIFT & TRACTION ---
var slip_speed := 400     # Speed where normal traction reduces
var traction_fast := 2.5  # Grip at high speeds
var traction_slow := 10.0 # Grip at low speeds
var drift_traction := 0.05 # Grip when handbraking (Very low = Icy)
var handbrake_drag := 5.0  # Deceleration when drifting (prevents infinite slide)

# --- STATE ---
var steer_direction := 0.0
var acceleration := Vector2.ZERO

# --- SKID MARKS SETUP ---
# Adjust these to match your car sprite's tire positions
var tire_offset_y := 30.0  # Distance from center to side (Tire width)
var tire_offset_x := -35.0 # Distance from center to rear axle

var skid_width := 10.0
var skid_color := Color(0.1, 0.1, 0.1, 0.4) # Dark gray, semi-transparent

# We track the current lines being drawn. If null, we aren't skidding.
var skid_left: Line2D
var skid_right: Line2D

func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO

	get_input()
	apply_friction(delta)
	calculate_steering(delta)

	velocity += acceleration * delta
	move_and_slide()
	check_skid_marks()

func get_input() -> void:
	# STEERING
	# Returns a value between -1.0 and 1.0 (Analog stick friendly)
	var turn = Input.get_axis("mc_left", "mc_right")
	steer_direction = turn * deg_to_rad(steering_angle)
	steering_wheel.rotation = turn * 0.6  + PI / 2

	# ACCELERATION
	# get_action_strength returns 0.0 to 1.0 for analog triggers
	var gas_pressure = Input.get_action_strength("mc_accelerate")
	if gas_pressure > 0:
		acceleration = transform.x * engine_power * gas_pressure

	# BRAKING (Reverse/Regular Brake)
	var brake_pressure = Input.get_action_strength("mc_brake")
	if brake_pressure > 0:
		acceleration = transform.x * braking * brake_pressure

func apply_friction(delta: float) -> void:
	# Prevent infinite drift at very low speeds
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO

	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force

func calculate_steering(delta: float) -> void:
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0

	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta

	var new_heading = (front_wheel - rear_wheel).normalized()

	# 1. Choose Traction Level
	var current_traction = traction_slow
	if velocity.length() > slip_speed:
		current_traction = traction_fast

	# 2. Handbrake Override
	if Input.is_action_pressed("mc_handbreak"):
		current_traction = drift_traction
		# Artificial rotation boost (Scandinavian Flick helper)
		# This helps "throw" the car into a slide
		if velocity.length() > 100:	# Only rotate if moving
			new_heading = new_heading.rotated(steer_direction * 2.0 * delta)

		# Apply extra drag so you don't slide forever
		velocity -= velocity.normalized() * handbrake_drag

	# 3. Apply Steering Physics
	var d = new_heading.dot(velocity.normalized())

	if d > 0:
		# LERP velocity towards heading based on traction
		velocity = velocity.lerp(new_heading * velocity.length(), current_traction * delta)
	if d < 0:
		# Reverse logic
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)

	rotation = new_heading.angle()

func check_skid_marks() -> void:
	# 1. Are we drifting?
	# We consider it a drift if we are using the "drift_traction" (Handbrake)
	# OR if our slide angle is extreme (velocity vs heading)
	var is_drifting = false
	var heading = Vector2.RIGHT.rotated(rotation)
	var dot = heading.dot(velocity.normalized())

	# Condition A: Handbrake held
	if Input.is_action_pressed("mc_handbreak") and velocity.length() > 50:
		is_drifting = true
	# Condition B: Natural slide (sharp turn at high speed)
	elif velocity.length() > 100 and abs(dot) < 0.95:
		is_drifting = true

	# 2. Manage Trails
	if is_drifting:
		if skid_left == null:
			start_skidding()
		# Add points to current trails
		add_skid_point()
	else:
		if skid_left != null:
			stop_skidding()

func start_skidding() -> void:
	# Create two new Line2D nodes dynamically
	skid_left = create_skid_line()
	skid_right = create_skid_line()

	# Add them to the PARENT scene (The world), not the car
	# If added to the car, they would move with it!
	get_parent().add_child(skid_left)
	get_parent().add_child(skid_right)

func stop_skidding() -> void:
	# Determine if the lines are too short to keep (cleanup)
	if skid_left.get_point_count() < 2:
		skid_left.queue_free()
		skid_right.queue_free()
	else:
		# Optional: Add a script or tween to fade them out over time
		fade_out_skid(skid_left)
		fade_out_skid(skid_right)

	# Reset references so we create new lines next time
	skid_left = null
	skid_right = null

func create_skid_line() -> Line2D:
	var line = Line2D.new()
	line.width = skid_width
	line.default_color = skid_color
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	# Important: Ensure the lines draw behind the car
	line.z_index = -1
	return line

func add_skid_point() -> void:
	var offset_l = Vector2(tire_offset_x, -tire_offset_y).rotated(rotation)
	var offset_r = Vector2(tire_offset_x, tire_offset_y).rotated(rotation)

	# Convert Global Position -> Local Position relative to the Line2D's parent
	var parent_node = get_parent() # This is the "Heros" node
	var local_pos_l = parent_node.to_local(global_position + offset_l)
	var local_pos_r = parent_node.to_local(global_position + offset_r)

	skid_left.add_point(local_pos_l)
	skid_right.add_point(local_pos_r)

func fade_out_skid(line: Line2D) -> void:
	# Create a tween to fade alpha to 0 over 5 seconds, then delete
	var tween = create_tween()
	tween.tween_property(line, "modulate:a", 0.0, 5.0)
	tween.tween_callback(line.queue_free)
