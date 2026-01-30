extends Node2D

signal score_updated(points:int)
var score := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	emit_signal("score_updated", score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func modify_score(points: int) -> void:
	score = score + points
	self.score_updated.emit(score)
