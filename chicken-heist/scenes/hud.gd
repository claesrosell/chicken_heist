extends CanvasLayer

@onready var score_label := $ScoreLabel
@onready var time_left_label := $TimeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.score_updated.connect(_update_score)
	Game.time_left_updated.connect(_update_time_left)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_score(new_score:int) -> void:
	score_label.text = "Score: %s" % [new_score]

func _update_time_left(new_time_left:int) -> void:
	self.time_left_label.text = "Time: %s" % [self.format_time(new_time_left)]

func format_time(time_in_ms: int) -> String:
	var total_seconds = time_in_ms / 1000
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	var centiseconds = (time_in_ms % 1000) / 10
	
	var time_string = ""
	
	# 1. Only show minutes if we actually have them (>= 60 seconds)
	if minutes > 0:
		time_string += "%02d:" % minutes
	
	# 2. Always show seconds (padded with 0, e.g., "05" or "12")
	time_string += "%02d" % seconds
	
	# 3. Only show centiseconds if time is less than 30 seconds
	if time_in_ms < 30 * 1000:
		time_string += ".%02d" % centiseconds
		
	return time_string
