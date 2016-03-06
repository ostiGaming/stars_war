extends Node2D

var distance = 10
var resolution = 5
var trail_length = 30
var decay_length = 5.0
var capturing = false
var lifetime = 3000
var decays = []
var trails = []
var collisions = []

export var player_index = 0
export var trail_width = 5
export(Color) var trail_color = Color(1.0, 1.0, 1.0, 1.0)
export(NodePath) var trail_source = null
export(NodePath) var trail_particle = null
onready var _source = get_node(trail_source)

func _ready():
	set_process(true)
	set_fixed_process(true)
	set_process_input(true)
	
	var yes = get_node(trail_particle)
	yes.set_color(trail_color)

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

func _fixed_process(delta):
	for collision in collisions:
		remove_child(collision)
	
	collisions.clear()
	
	for trail in trails:
		for t in range(0, trail.get_point_count() - 1):
			var point1 = trail.get_point_pos(t)
			var point2 = trail.get_point_pos(t + 1)
			
			var body = StaticBody2D.new()
			var shape = RectangleShape2D.new()
			
			shape.set_extents((point2 - point1)/2)
			body.set_pos(trail.interpolatef(t + 0.5))
			body.add_shape(shape)
			
			if player_index == 0:
				body.set_layer_mask(1)
				body.set_collision_mask(1)
			else:
				body.set_layer_mask(2)
				body.set_collision_mask(2)
			
			collisions.append(body)
			add_child(body)

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
	if (motion.length() >= distance):
		# add new control point
		trail.add_point(curpos, Vector2(0,0), Vector2(0,0), 0)
		decay.push_front(OS.get_ticks_msec() + lifetime)
		print("added control point at: ", curpos)
		return true
	return false
	
func decay_trails():
	var decayed = false
	for i in range(0, trails.size()):
		var trail = trails[i]
		var decay = decays[i]
		for t in range(decay.size()-1, -1, -1):
			if (decay[t] <= OS.get_ticks_msec()):
				decayed = true
				trail.remove_point(t)
				decay.remove(t)
				if t == 0 && decays.size() > 1: 
					decays.remove(i)
					trails.remove(i)
			else: break
	return decayed

func set_capturing(value):
	capturing = !capturing
	if (capturing):
		new_trail()
	

func get_trail_pos():
	return _source.get_global_pos()
	
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