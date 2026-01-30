extends Pickable
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_points() -> int:
	return 10

func picked() -> void:
	self.monitorable = false
	sprite_2d.visible = false
	animation_player.play("picked")
