extends Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.timeout.connect(self._time_callback)
	pass # Replace with function body.

func _time_callback() -> void:
	GameManager.modify_time(-100)
