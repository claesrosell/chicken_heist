extends Node2D

# --- CONFIG ---
@onready var options: Array[Label] = [%Player1Label, %Player2Label]
var default_color := Color(0.6, 0.2, 0.2) # Dark Red (Unselected)
var highlight_color := Color(1.0, 1.0, 0.0) # Yellow (Hover)
var ready_color := Color(0.0, 1.0, 0.0)     # Green (Locked In)

# --- STATE ---
# Tracks which option each player is hovering over (0 or 1)
var p1_index := 0
var p2_index := 1 

# Tracks if they have locked in
var p1_ready := false
var p2_ready := false

func _ready() -> void:
	update_visuals()

func _input(event: InputEvent) -> void:
	# --- PLAYER 1 INPUTS ---
	if not p1_ready:
		if event.is_action_pressed("p1_up"):
			change_selection(1, -1)
		elif event.is_action_pressed("p1_down"):
			change_selection(1, 1)
		elif event.is_action_pressed("p1_accept"):
			lock_in(1)
	else:
		# If locked, B button cancels status
		if event.is_action_pressed("p1_cancel"):
			cancel_ready(1)

	# --- PLAYER 2 INPUTS ---
	if not p2_ready:
		if event.is_action_pressed("p2_up"):
			change_selection(2, -1)
		elif event.is_action_pressed("p2_down"):
			change_selection(2, 1)
		elif event.is_action_pressed("p2_accept"):
			lock_in(2)
	else:
		# If locked, B button cancels status
		if event.is_action_pressed("p2_cancel"):
			cancel_ready(2)

func change_selection(player_id: int, direction: int) -> void:
	# Update index based on player
	if player_id == 1:
		p1_index = wrapi(p1_index + direction, 0, options.size())
	else:
		p2_index = wrapi(p2_index + direction, 0, options.size())
	
	update_visuals()

func lock_in(player_id: int) -> void:
	if player_id == 1:
		p1_ready = true
		print("Player 1 is READY!")
	else:
		p2_ready = true
		print("Player 2 is READY!")
	
	update_visuals()
	check_start()

func cancel_ready(player_id: int) -> void:
	# If anyone presses B, we unlock that player. Perhaps we should unlock both?
	if player_id == 1:
		p1_ready = false
		print("Player 1 cancelled.")
	else:
		p2_ready = false
		print("Player 2 cancelled.")
		
	update_visuals()

func check_start() -> void:
	if p1_ready and p2_ready:
		print(">>> BOTH PLAYERS READY! STARTING GAME... <<<")
		# Add your scene transition here:
		# get_tree().change_scene_to_file("res://scenes/game.tscn")

func update_visuals() -> void:
	# Reset all to default first
	for label in options:
		label.modulate = default_color
		label.text = label.text.replace(" <", "").replace(" >", "") # Clear cursors

	# Apply Player 1 Visuals
	var p1_label = options[p1_index]
	if p1_ready:
		p1_label.modulate = ready_color
	else:
		p1_label.modulate = highlight_color
		p1_label.text += " <" # P1 Indicator

	# Apply Player 2 Visuals
	var p2_label = options[p2_index]
	if p2_ready:
		p2_label.modulate = ready_color
	else:
		# If both select the same one, blend colors or just keep yellow
		p2_label.modulate = highlight_color 
		p2_label.text += " >" # P2 Indicator
