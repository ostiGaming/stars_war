extends Node2D

var distance = 20
var resolution = 7
var trail_length = 30
var decay_length = 5.0
var capturing = false
var lifetime = 3500
var decays = []
var trails = []
var collisions = []

export var player_index = 0
export var trail_width = 5
export(Color) var trail_color = Color(1.0, 1.0, 1.0, 1.0)
export(NodePath) var trail_source_path = null
onready var trail_source = get_node(trail_source_path)

export(NodePath) var trail_particle_path = null
onready var trail_particle = get_node(trail_particle_path)

func _ready():
	set_process(true)
	set_fixed_process(true)
	set_process_input(true)
	
	trail_particle.set_color(trail_color)

func _draw():
	for trail_idx in range(0, trails.size()):
		var trail = trails[trail_idx]
		for t in range(0, trail.get_point_count()):
			var curve_pos = trail.interpolatef(t)
			# draw_circle(curve_pos, 3, Color("#FF00FF"))
			var step = 1.0 / float(resolution)
			for t_f in range(0, resolution):
				var i = t + step*t_f
				var inter_pos = trail.interpolatef(i)
				draw_circle(inter_pos, trail_width, get_trail_brush(trail_idx, i))

func get_trail_brush(trail_idx, fpos):
	var decay = decays[trail_idx]
	var from = max(int(floor(fpos))-1, 0)
	var to = int(floor(fpos))
	var interp_decay = lerp(decay[from], decay[to], fpos-from)
	var brush = trail_color
	brush.a = (interp_decay - OS.get_ticks_msec()) / lifetime 
	return brush

func add_collision_segment(trail):
	var point1 = trail.get_point_pos(0)
	var point2 = trail.get_point_pos(1)
	
	var body = StaticBody2D.new()
	body.set_meta("trail_source", player_index)
	var shape = RectangleShape2D.new()
	
	shape.set_extents((point2 - point1)/2)
	body.set_pos(trail.interpolatef(0.5))
	body.add_shape(shape)
	
	if player_index == 0:
		body.set_layer_mask(1)
		body.set_collision_mask(1)
	else:
		body.set_layer_mask(2)
		body.set_collision_mask(2)
	
	add_child(body)
	return body

func _process(delta):
	var dirty = false
	
	dirty = dirty || decay_trails()
	if capturing:
		dirty = dirty || generate_trail()
	
	if dirty: 
		update()

func generate_trail():
	var curpos = get_trail_pos()
	
	# compute actual movement delta from last point
	var motion = get_delta_from_trail()
	# compute new control point length
	var velocity = 100
	# edit last control point
	var trail = trails[0]
	var decay = decays[0]
	var collision = collisions[0]
	if (motion.length() >= distance):
		# add new control point
		trail.add_point(curpos, Vector2(0,0), Vector2(0,0), 0)
		decay.push_front(OS.get_ticks_msec() + lifetime)
		if (trail.get_point_count() > 1):
			collision.push_front(add_collision_segment(trail))
		return true
	return false
	
func decay_trails():
	var decayed = false
	var empty_trails = []
	for i in range(0, trails.size()):
		var trail = trails[i]
		var decay = decays[i]
		var collision = collisions[i]
		for t in range(decay.size()-1, -1, -1):
			if (decay[t] <= OS.get_ticks_msec()):
				decayed = true
				trail.remove_point(t)
				decay.remove(t)
				
				# cleanup collision
				if (t > 0):
					var collider = collision[t-1]
					remove_child(collider)
					collider.queue_free()
					collision.remove(t)
				
				if t == 0 && decays.size() > 1:
					empty_trails.append(i)
			else: break
	
	for i in empty_trails:
		decays.remove(i)
		trails.remove(i)
	
	return decayed

func set_capturing(value):
	capturing = value
	if (capturing):
		new_trail()

func get_trail_pos():
	return trail_source.get_global_pos()
	
func get_current_trail():
	return trails[0]

func get_delta_from_trail():
	var curpos = get_trail_pos()
	if (get_current_trail().get_point_count() == 0): 
		return curpos # just to be sure it triggers
	
	var head = get_current_trail().get_point_pos(0)
	return curpos - head

func new_trail():
	trails.push_front(Curve2D.new())
	decays.push_front([])
	collisions.push_front([])