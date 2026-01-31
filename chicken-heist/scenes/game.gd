extends Node2D

var made_it_out := true		# Only for debugging, we shoud set this depending on if the players actually was able to get out

@onready var high_scores_api:HighScoresApi = $HighScoresApi

var online :bool = false
var force_eligibility :bool = false
var force_eligibility_to:bool = true

func _ready() -> void:
	GameManager.time_is_up.connect(_on_game_over)

func _process(delta: float) -> void:
	pass

func _on_game_over() -> void:
	print("Time is up! Going to Name Entry...")
	if !made_it_out:
		print("We should do something here since the players did succed")

	if self.online:
		high_scores_api.eligibility_checked.connect(_on_eligibility_result)
		high_scores_api.check_eligibility(GameManager.get_current_score())
	else:
		_on_eligibility_result(true)

func _on_eligibility_result(is_eligible: bool) -> void:
	# Clean up connection so it doesn't fire twice
	if self.online:
		high_scores_api.eligibility_checked.disconnect(_on_eligibility_result)

	print("Passed eligibility is: ", is_eligible)

	if self.force_eligibility:
		is_eligible = self.force_eligibility_to
		print("Forced eligibility is: ", is_eligible)

	if is_eligible:
		# QUALIFIED: Go to Name Entry
		get_tree().change_scene_to_file("res://scenes/high_score/great_score.tscn")
	else:
		# FAILED: Go straight to Leaderboard
		get_tree().change_scene_to_file("res://scenes/high_score/high_scores.tscn")
