extends Node2D

@onready var high_scores_api:HighScoresApi = $HighScoresApi

@onready var points_label:Label = %PointsLabel
@onready var info_label:Label = %InfoLabel

var force_eligibility :bool = false
var force_eligibility_to:bool = true

var high_score_eligibility:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	var local_finished_in_time = GameManager.finished_in_time

	var current_score = GameManager.get_current_score()
	if !local_finished_in_time:
		self.info_label.text = "You were trapped!"
		self.points_label.text = "0"
	else:
		self.points_label.text = str(int(current_score))

	if current_score > 0 and local_finished_in_time:
		high_scores_api.eligibility_checked.connect(_on_eligibility_result)
		high_scores_api.check_eligibility(current_score)
	else:
		_on_eligibility_result(false)

	# create_timer returns a SceneTreeTimer which cleans itself up automatically
	get_tree().create_timer(7.0).timeout.connect(self._move_to_next_screen)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _move_to_next_screen() -> void:
	# 2. Check if we are still in the scene tree to avoid errors
	if not is_inside_tree():
		return

	if self.high_score_eligibility:
		# QUALIFIED: Go to Name Entry
		get_tree().change_scene_to_file("res://scenes/high_score/great_score.tscn")
	else:
		# FAILED: Go straight to Leaderboard
		get_tree().change_scene_to_file("res://scenes/high_score/high_scores.tscn")

func _on_eligibility_result(is_eligible: bool) -> void:
	# Clean up connection so it doesn't fire twice
	high_scores_api.eligibility_checked.disconnect(_on_eligibility_result)

	print("Passed eligibility is: ", is_eligible)

	if self.force_eligibility:
		is_eligible = self.force_eligibility_to
		print("Forced eligibility is: ", is_eligible)

	self.high_score_eligibility = is_eligible
