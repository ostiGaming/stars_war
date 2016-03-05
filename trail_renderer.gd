extends Node2D

var distance = 8
var resolution = 8
var trail_length = 30
var decay_length = 5.0
var capturing = false
export(Color) var trail_color = Color(1.0, 1.0, 1.0, 1.0)
export(Curve2D) var trail_curve = null
export(NodePath) var trail_source = null
onready var _source = get_node(trail_source)

func _ready():
	set_process(true)
	set_process_input(true)
	pass

func _draw():
	for t in range(0, trail_curve.get_point_count()):
		var curve_pos = trail_curve.interpolatef(t)
		# draw_circle(curve_pos, 3, Color("#FF00FF"))
		for t_f in range(1, resolution):
			var i = t + 0.1*t_f
			var inter_pos = trail_curve.interpolatef(i)
			draw_circle(inter_pos, 3, get_trail_brush(i))

func get_trail_brush(fpos):
	var brush = trail_color
	if (fpos > trail_length):
		var decay_interp = 0.4 - ((fpos - trail_length)/decay_length)
		brush.a = decay_interp
	return brush

func _process(delta):
	var curpos = get_trail_pos()
	if (!capturing):
		return

	# compute actual movement delta from last point
	var motion = get_delta_from_trail()
	# compute new control point length
	var velocity = 100
	# edit last control pointw
	if (motion.length() >= distance):
		# add new control point
		var vec_in = -trail_curve.get_point_out(0)
		trail_curve.add_point(curpos, Vector2(0,0), Vector2(0,0), 0)
		print("added control point at: ", curpos)
		update()
	
	if (trail_curve.get_point_count() > trail_length+decay_length):
		trail_curve.remove_point(trail_length+decay_length)
		update()

func _input(ev):
	if (ev.type == InputEvent.MOUSE_BUTTON && ev.pressed == 0):
		capturing = !capturing
		print("Capturing?: ", capturing)

func get_trail_pos():
	return _source.get_global_pos()

func get_delta_from_trail():
	var curpos = get_trail_pos()
	if (trail_curve.get_point_count() == 0): 
		return curpos # just to be sure it triggers
		
	var head = trail_curve.get_point_pos(0)
	return curpos - head