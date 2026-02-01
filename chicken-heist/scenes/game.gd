extends Node2D

func _ready() -> void:
	GameManager.time_is_up.connect(_on_game_over)
	self.fade_bus("BackgroundMusicBus", 0.2, 2)


func _process(delta: float) -> void:
	pass

func _on_game_over() -> void:
	print("Time is up! Going to Name Entry...")
	await self.fade_bus("BackgroundMusicBus", 1, 2)
	get_tree().change_scene_to_file("res://scenes/game_over/game_over.tscn")

func fade_bus(bus_name: String, target_linear_vol: float, duration: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	
	# Get current volume
	var current_db = AudioServer.get_bus_volume_db(bus_index)
	var current_linear = db_to_linear(current_db)
	
	var tween = create_tween()
	
	# Tween the volume
	tween.tween_method(
		func(val): AudioServer.set_bus_volume_db(bus_index, linear_to_db(val)),
		current_linear,
		target_linear_vol,
		duration
	)
	
	# Return the 'finished' signal specifically
	return tween.finished
