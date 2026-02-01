extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var start_level_area_2d: Area2D = $StartLevelArea2D
@onready var end_level_area_2d: Area2D = $EndLevelArea2D
@onready var gate: Gate = $Gate
@onready var hurry_up_label: Label = $CanvasLayer/HurryUpLabel

var show_hurry_up_time : float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("start")
	hurry_up_label.visible = false
	GameManager.time_is_short.connect(time_is_short)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if show_hurry_up_time < 0:
		hurry_up_label.visible = false
	else:
		show_hurry_up_time -= delta

func _on_start_level_area_2d_body_entered(body: Node2D) -> void:
	if !GameManager.level_is_started:
		gate.close()
		GameManager.start_level()
		animation_player.play("zoom_to_level")

func _on_end_level_area_2d_body_entered(body: Node2D) -> void:
	if GameManager.level_is_started:
		gate.close()
		GameManager.stop_level()

func time_is_short() -> void:
	hurry_up_label.visible = true
	show_hurry_up_time = 3
	gate.open2()
