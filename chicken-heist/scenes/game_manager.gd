extends Node

signal score_updated(points:int)
signal time_left_updated(time_left:int)
signal time_is_up()
signal horn_pressed()

var score := 0
var time_left := 10 * 1000		# in millis

var time_up_fired := false

var foxy_controls:FoxyControls
var rocky_controls:RockyControls

var latest_rank_achieved : int = -1

func _ready() -> void:
	self.foxy_controls = FoxyControls.new("p1")
	self.rocky_controls = RockyControls.new("p2")

func modify_score(points: int) -> void:
	self.score = self.score + points
	self.score_updated.emit(score)

func modify_time(time_delta: int) -> void:
	self.time_left = time_left + time_delta
	if self.time_left <= 0:
		self.time_left = 0
		if !self.time_up_fired:
			self.time_up_fired = true
			self.time_is_up.emit()
			

	self.time_left_updated.emit(self.time_left)

func get_current_score() -> int:
	return self.score
