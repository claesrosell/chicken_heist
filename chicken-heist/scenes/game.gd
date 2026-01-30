extends Node

signal score_updated(points:int)
var score := 0

func modify_score(points: int) -> void:
	score = score + points
	self.score_updated.emit(score)
