extends Node2D

@onready var foxy_input := %FoxyInput
@onready var rocky_input := %RockyInput

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var fControls = GameManager.foxy_controls
	var pControls = GameManager.rocky_controls

	self.foxy_input.set_actions(fControls.foxy_d_up, fControls.foxy_d_down, fControls.foxy_d_left, fControls.foxy_d_right, fControls.foxy_accept)	
	self.rocky_input.set_actions(pControls.rocky_d_up, pControls.rocky_d_down, pControls.rocky_d_left, pControls.rocky_d_right, pControls.rocky_accept)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
