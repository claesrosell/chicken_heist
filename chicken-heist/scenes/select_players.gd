extends Node2D

# --- CONFIG ---
enum Character { FOXY, ROCKY }

# Update your onready labels to include the new indicators
@onready var options: Array[Label] = [%FoxyPlayerLabel, %RockyPlayerLabel]
@onready var p1_indicators: Array[Label] = [%P1FoxyLabel, %P1RockyLabel]
@onready var p2_indicators: Array[Label] = [%P2FoxyLabel, %P2RockyLabel]

var default_color := Color(0.6, 0.2, 0.2) # Dark Red (Unselected)
var highlight_color := Color(1.0, 1.0, 0.0) # Yellow (Hover)
var ready_color := Color(0.0, 1.0, 0.0)     # Green (Locked In)

# --- STATE ---
# Tracks which option each player is hovering over (Foxy or Rocky)
var p1_choice: Character = Character.FOXY
var p2_choice: Character = Character.ROCKY

var p1_ready := false
var p2_ready := false

func _ready() -> void:
	update_visuals()

func _input(event: InputEvent) -> void:
	# --- PLAYER 1 INPUTS ---
	if not p1_ready:
		if event.is_action_pressed("p1_d_up") or event.is_action_pressed("p1_d_down"):
			change_selection(1)
		elif event.is_action_pressed("p1_button_a"):
			lock_in(1)
	elif event.is_action_pressed("p1_button_b"):
		cancel_ready(1)

	# --- PLAYER 2 INPUTS ---
	if not p2_ready:
		if event.is_action_pressed("p2_d_up") or event.is_action_pressed("p2_d_down"):
			change_selection(2)
		elif event.is_action_pressed("p2_button_a"):
			lock_in(2)
	elif event.is_action_pressed("p2_button_b"):
		cancel_ready(2)

func change_selection(player_id: int) -> void:
	if player_id == 1:
		# P1 can move as long as they aren't ready
		p1_choice = Character.ROCKY if p1_choice == Character.FOXY else Character.FOXY
	else:
		# P2 can only move if they aren't ready AND if they don't land
		# on a character P1 has already locked
		var new_choice = Character.ROCKY if p2_choice == Character.FOXY else Character.FOXY

		if p1_ready and new_choice == p1_choice:
			print("Character is locked by Player 1")
		else:
			p2_choice = new_choice

	update_visuals()

func lock_in(player_id: int) -> void:
	if player_id == 1:
		# P1 can lock in freely
		p1_ready = true
		# Optional: If P1 locks onto P2's current hover,
		# push P2 to the other character automatically
		if p1_choice == p2_choice and not p2_ready:
			p2_choice = Character.ROCKY if p1_choice == Character.FOXY else Character.FOXY

	else:
		# P2 can only lock in if their choice is different from P1's LOCKED choice
		if p1_ready and p2_choice == p1_choice:
			print("Cannot select: Player 1 already locked this character!")
			return # Block the lock-in

		p2_ready = true

	update_visuals()
	check_start()

func cancel_ready(player_id: int) -> void:
	if player_id == 1:
		p1_ready = false
	else:
		p2_ready = false
	update_visuals()

func check_start() -> void:
	if p1_ready and p2_ready:
		print(">>> STARTING GAME <<<")

		# Determine who controls which character based on their choice
		# If P1 chose FOXY, they are "p1" for Foxy. Otherwise, P2 is "p1" for Foxy.
		if p1_choice == Character.FOXY:
			GameManager.foxy_controls.set_player("p1")
			GameManager.rocky_controls.set_player("p2")
		else:
			GameManager.foxy_controls.set_player("p2")
			GameManager.rocky_controls.set_player("p1")

		# Global resets
		GameManager.score = 0
		GameManager.time_left = 90 * 1000	# Set this value to the length
		GameManager.time_up_fired = false

		get_tree().change_scene_to_file("res://scenes/game.tscn")

func update_visuals() -> void:
	# 1. Reset everything to a base state
	for i in range(options.size()):
		# Hide all indicator stars by default
		p1_indicators[i].visible = false
		p2_indicators[i].visible = false

	# 2. Update Player 1 Visuals
	var p1_idx = int(p1_choice)
	p1_indicators[p1_idx].visible = true
	# Optional: Change the indicator color to match the state
	p1_indicators[p1_idx].modulate = ready_color if p1_ready else highlight_color

	# 3. Update Player 2 Visuals
	var p2_idx = int(p2_choice)

	p2_indicators[p2_idx].visible = true
	p2_indicators[p2_idx].modulate = ready_color if p2_ready else highlight_color
