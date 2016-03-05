extends Node

var LINEAR_FORCE = 150
var ANGULAR_FORCE = 5
var MAX_SPEED = 250

export var player_index = 1
var player_actions = [
	{"up":"ui_up", "down":"ui_down", "left":"ui_left", "right":"ui_right"},
	{"up":"player2_up", "down":"player2_down", "left":"player2_left", "right":"player2_right"}
	]

var up_pressed = false
var down_pressed = false
var left_pressed = false
var right_pressed = false

func _draw():
	draw_circle(get_pos(), 4, Color("#00FF00"))
	update()

func _ready():
	set_fixed_process(true)
	set_process_input(true)

func _fixed_process(delta):
	var forward_force = 0
	var angular_velocity = 0
	
	if (down_pressed):
		forward_force = forward_force + LINEAR_FORCE
	
	if (up_pressed):
		forward_force = forward_force - LINEAR_FORCE
	
	if (right_pressed):
		angular_velocity = ANGULAR_FORCE
	
	if (left_pressed):
		angular_velocity = -ANGULAR_FORCE
	
	var local_force = get_transform().basis_xform(Vector2(0, forward_force))
	set_applied_force(local_force)
	set_angular_velocity(angular_velocity)

func _input(event):
	if (event.is_action_pressed(player_actions[player_index]["up"])):
		up_pressed = true
	if (event.is_action_released(player_actions[player_index]["up"])):
		up_pressed = false
	
	if (event.is_action_pressed(player_actions[player_index]["down"])):
		down_pressed = true
	if (event.is_action_released(player_actions[player_index]["down"])):
		down_pressed = false
	
	if (event.is_action_pressed(player_actions[player_index]["left"])):
		left_pressed = true
	if (event.is_action_released(player_actions[player_index]["left"])):
		left_pressed = false
	
	if (event.is_action_pressed(player_actions[player_index]["right"])):
		right_pressed = true
	if (event.is_action_released(player_actions[player_index]["right"])):
		right_pressed = false

func _integrate_forces(state):
	var velocity = state.get_linear_velocity()
	
	if (velocity.length() > MAX_SPEED):
		velocity = velocity.normalized()
		state.set_linear_velocity(velocity * MAX_SPEED) 