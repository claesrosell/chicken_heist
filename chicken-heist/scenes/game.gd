extends Node2D

var made_it_out := true		# Only for debugging, we shoud set this depending on if the players actually was able to get out

func _ready() -> void:
	GameManager.time_is_up.connect(_on_game_over)
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func _on_game_over() -> void:
	print("Time is up! Going to Name Entry...")
	if made_it_out:
		get_tree().change_scene_to_file("res://scenes/high_score/great_score.tscn")
