extends CanvasLayer

@onready var score_label := $ScoreLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.score_updated.connect(_update_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_score(new_score:int) -> void:
	score_label.text = "Score: %s" % [new_score]
