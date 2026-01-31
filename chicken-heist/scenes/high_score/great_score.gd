extends Node2D

@onready var high_scores_api: HighScoresApi = $HighScoresApi

@onready var foxy_input := %FoxyInput
@onready var rocky_input := %RockyInput

const NO_SELECTION:String = "<NONE>"

var foxy_submitted_name:String = NO_SELECTION
var rocky_submitted_name:String = NO_SELECTION

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var fControls = GameManager.foxy_controls
	var pControls = GameManager.rocky_controls

	self.foxy_input.set_actions(
		fControls.foxy_d_up,
		fControls.foxy_d_down,
		fControls.foxy_d_left,
		fControls.foxy_d_right,
		fControls.foxy_accept,
		fControls.foxy_cancel)

	self.rocky_input.set_actions(pControls.rocky_d_up,
		pControls.rocky_d_down,
		pControls.rocky_d_left,
		pControls.rocky_d_right,
		pControls.rocky_accept,
		pControls.rocky_cancel)	

	foxy_input.name_submitted.connect(self._player_submitted_named)
	rocky_input.name_submitted.connect(self._player_submitted_named)
	high_scores_api.score_submitted.connect(_on_score_uploaded)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _player_submitted_named(player:String, submitted_name:String) -> void:
	print( "%s submitted name %s" % [player, submitted_name])
	if player == "foxy":
		self.foxy_submitted_name = submitted_name
	if player == "rocky":
		self.rocky_submitted_name = submitted_name

	if self.rocky_submitted_name != NO_SELECTION and self.foxy_submitted_name != NO_SELECTION:
		self.high_scores_api.submit_score(foxy_submitted_name, rocky_submitted_name, GameManager.get_current_score() )

func _on_score_uploaded(new_rank: int) -> void:
	print("Upload Complete! New Rank is: ", new_rank)

	# Save the rank globally, next scene may use it
	GameManager.latest_rank_achieved = new_rank
	get_tree().change_scene_to_file("res://scenes/high_score/high_scores.tscn")
