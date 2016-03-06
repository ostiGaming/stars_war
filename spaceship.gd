extends RigidBody2D

signal on_killed(death_pos)

# called when the entity is being wrapped
func _init():
	add_to_group("wrappable")
	add_to_group("killable")

func wrap(position):
	get_node("../../trail_renderer").new_trail()
	set_global_pos(position)

# motion code
var LINEAR_FORCE = 150
var ANGULAR_FORCE = 5
var MAX_SPEED = 250

export(NodePath) var trail_renderer_path = null
var trail_renderer

export var player_index = 0
var player_actions = [
	{"up":"ui_up", "down":"ui_down", "left":"ui_left", "right":"ui_right", "action":"player1_action"},
	{"up":"player2_up", "down":"player2_down", "left":"player2_left", "right":"player2_right", "action":"player2_action"}
	]

var up_pressed = false
var down_pressed = false
var left_pressed = false
var right_pressed = false

var spring
var initial_pos
var trail_particle

func _draw():
	spring.set_node_b(get_path());
	
	var node_a = spring.get_node_a()
	var node_b = spring.get_node_b()
	
	if (node_a != null && !node_a.is_empty() && node_b != null && !node_b.is_empty()):
		var position = get_transform().basis_xform_inv(get_node(node_a).get_global_pos() - get_global_pos()) 
		draw_line(position, Vector2(0, 0), Color("#000000"), 5)

func _ready():
	spring = get_node("spring")
	trail_particle = get_node("power_particle")
	trail_renderer = get_node(trail_renderer_path)
	
	initial_pos = get_pos()
	
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
	
	for body in get_colliding_bodies():
		if body.has_meta("trail_source") && body.get_meta("trail_source") != player_index:
			kill()

	update()

func _input(event):
	if (event.is_action_pressed(player_actions[player_index]["up"])):
		up_pressed = true
		trail_particle.set_emitting(true)
		trail_renderer.set_capturing(true)
	if (event.is_action_released(player_actions[player_index]["up"])):
		up_pressed = false
		trail_particle.set_emitting(false)
		trail_renderer.set_capturing(false)
	
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
		
	if (event.is_action_pressed(player_actions[player_index]["action"])):
		spring.set_node_a(NodePath(""))

func _integrate_forces(state):
	var velocity = state.get_linear_velocity()
	
	if (velocity.length() > MAX_SPEED):
		velocity = velocity.normalized()
		state.set_linear_velocity(velocity * MAX_SPEED)
	
func kill():
	emit_signal("on_killed", get_global_pos())
	set_pos(initial_pos)
	spring.set_node_a(NodePath(""))