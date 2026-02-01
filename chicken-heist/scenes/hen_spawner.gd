extends Node2D

const HEN = preload("uid://bn6h61u5pr2ou")
@onready var hens: Node2D = $Hens

var time_to_hen : float = 4
var target_hen_count = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_to_hen -= delta

	if hens.get_child_count() < target_hen_count && time_to_hen <= 0:
		var hen_instance = HEN.instantiate() as Hen
		hens.add_child(hen_instance)
		hen_instance.global_position = self.global_position
		hen_instance._set_state(Hen.HenState.Running)
		time_to_hen = 5
