class_name RockyControls
extends Resource

# The actual string names found in the Input Map
var lasso_left: String
var lasso_right: String
var lasso_up: String
var lasso_down: String
var lasso_fire: String
var rocky_horn: String
var rocky_d_up:String
var rocky_d_down:String
var rocky_d_left:String
var rocky_d_right:String
var rocky_accept: String
var rocky_cancel: String

func _init(prefix: String = "p2") -> void:
	lasso_left = prefix + "_ls_left"
	lasso_right = prefix + "_ls_right"
	lasso_up = prefix + "_ls_up"
	lasso_down = prefix + "_ls_down"
	lasso_fire = prefix + "_button_a"
	rocky_horn = prefix + "_button_b"
	rocky_d_up = prefix + "_d_up"
	rocky_d_down = prefix + "_d_down"
	rocky_d_left = prefix + "_d_left"
	rocky_d_right = prefix + "_d_right"
	rocky_accept = prefix + "_button_a"
	rocky_cancel = prefix + "_button_b"
