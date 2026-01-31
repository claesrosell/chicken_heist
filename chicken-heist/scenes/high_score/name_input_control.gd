extends Control

signal name_submitted(player_id:String, player_name: String)

# Configurable by instance
@export var player_id := "player"
@export var up_action := "ui_up"
@export var down_action := "ui_down"
@export var right_action := "ui_right"
@export var left_action := "ui_left"
@export var accept_action := "ui_accept"

# The available characters
const CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .!?"
var current_slot := 0     # Which letter are we editing? (0, 1, or 2)
var letter_indices := [0, 0, 0] # Index of the character for each slot
var max_slots := 3

@onready var slots: Array[Label] = [%Letter1, %Letter2, %Letter3]

func _ready() -> void:
	update_visuals()

func _input(event: InputEvent) -> void:
	# We use 'just_pressed' so holding the stick doesn't spin the letters too fast
	
	# 1. Change Letter (Up/Down)
	if event.is_action_pressed(self.up_action):
		change_letter(1)
	elif event.is_action_pressed(self.down_action):
		change_letter(-1)
		
	# 2. Change Slot (Left/Right)
	elif event.is_action_pressed(self.right_action):
		change_slot(1)
	elif event.is_action_pressed(self.left_action):
		change_slot(-1)
		
	# 3. Submit (Accept/Start)
	elif event.is_action_pressed(self.accept_action):
		submit_name()

func change_letter(direction: int) -> void:
	# Update the index for the currently active slot
	var current_char_idx = letter_indices[current_slot]
	current_char_idx += direction
	
	# Wrap around logic (Z -> A, or A -> Z)
	if current_char_idx >= CHARACTERS.length():
		current_char_idx = 0
	elif current_char_idx < 0:
		current_char_idx = CHARACTERS.length() - 1
		
	letter_indices[current_slot] = current_char_idx
	update_visuals()

func change_slot(direction: int) -> void:
	current_slot += direction
	
	# Wrap around slots (Slot 3 -> Slot 1)
	if current_slot >= max_slots:
		current_slot = 0
	elif current_slot < 0:
		current_slot = max_slots - 1
		
	update_visuals()

func update_visuals() -> void:
	for i in range(max_slots):
		# 1. Update the Text
		var char_index = letter_indices[i]
		slots[i].text = CHARACTERS[char_index]
		
		# 2. Highlight the active slot
		if i == current_slot:
			slots[i].modulate = Color.YELLOW # Active Color
			#slots[i].scale = Vector2(1.2, 1.2) # Pop effect
		else:
			slots[i].modulate = Color.WHITE # Inactive Color
			#slots[i].scale = Vector2(1.0, 1.0)

func submit_name() -> void:
	# Construct the final string
	var final_name = ""
	for i in range(max_slots):
		final_name += CHARACTERS[letter_indices[i]]
	
	print("Submitted Name: ", final_name)
	# Emit signal so the Main Menu or Game knows we are done
	name_submitted.emit(self.player_id, final_name)
	
	# Optional: Disable input so they can't submit twice
	set_process_input(false)
