extends Node2D
class_name Gate
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open1():
	animation_player.play("open")

func open2():
	animation_player.play("open_2")

func close():
	animation_player.play("from_open_to_closed")
