extends Node2D

func _ready() -> void:
	GameManager.time_is_up.connect(_on_game_over)

func _process(delta: float) -> void:
	pass

func _on_game_over() -> void:
	print("Time is up! Going to Name Entry...")
	get_tree().change_scene_to_file("res://scenes/game_over/game_over.tscn")
