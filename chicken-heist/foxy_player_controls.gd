class_name FoxyControls
extends Resource

# The actual string names found in the Input Map
var mc_left: String
var mc_right: String
var mc_accelerate: String
var mc_brake: String
var mc_handbrake: String
var foxy_d_up:String
var foxy_d_down:String
var foxy_d_left:String
var foxy_d_right:String
var foxy_accept: String
var foxy_cancel: String

func _init(prefix: String = "p1") -> void:
	mc_left = prefix + "_ls_left"
	mc_right = prefix + "_ls_right"
	mc_accelerate = prefix + "_r2"
	mc_brake = prefix + "_l2"
	mc_handbrake = prefix + "_button_a"
	foxy_d_up = prefix + "_d_up"
	foxy_d_down = prefix + "_d_down"
	foxy_d_left = prefix + "_d_left"
	foxy_d_right = prefix + "_d_right"
	foxy_accept = prefix + "_button_a"
	foxy_cancel = prefix + "_button_b"
