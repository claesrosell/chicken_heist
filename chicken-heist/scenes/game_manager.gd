extends Node

signal score_updated(points:int)
signal time_left_updated(time_left:int)
signal time_is_short()

signal time_is_up()
signal horn_pressed()

var score := 0
var time_left := 10 * 1000		# in millis

var time_up_fired := false

var foxy_controls:FoxyControls
var rocky_controls:RockyControls

var latest_rank_achieved : int = -1

var timer_started := false
var level_is_started := false
var level_is_exited := false
var finished_in_time := false
var time_is_short_sent := false

func _ready() -> void:
	self.foxy_controls = FoxyControls.new("p1")
	self.rocky_controls = RockyControls.new("p2")

func reset() -> void :
	# Global resets
	score = 0
	time_left = 60 * 1000	# Set this value to the length
	time_up_fired = false
	timer_started = false
	level_is_started = false
	level_is_exited = false
	finished_in_time = false
	time_is_short_sent = false

func modify_score(points: int) -> void:
	self.score = self.score + points
	self.score_updated.emit(score)

func modify_time(time_delta: int) -> void:
	if timer_started:
		self.time_left = time_left + time_delta
		if self.time_left <= 0:
			self.time_left = 0
			if !self.time_up_fired:
				self.time_up_fired = true
				self.time_is_up.emit()

		if self.time_left < 10 * 1000 && !time_is_short_sent:
			time_is_short_sent = true
			self.time_is_short.emit()

	self.time_left_updated.emit(self.time_left)

func start_level():
	timer_started = true
	level_is_started = true

func stop_level():
	level_is_exited = true
	if self.time_left > 0:
		finished_in_time = true

func get_current_score() -> int:
	return self.score
