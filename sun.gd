extends RigidBody2D

var activate_spring_area
var spring

var to_bh = Vector2(0,0)

export var blackhole_pull = 0.75
export var blackhole_push = 0.5

export var player_index = 0
export(NodePath) var blackhole_path = null
var blackhole = null

# called when the entity is being wrapped
func _init():
	add_to_group("wrappable")
	add_to_group("winable")

func wrap(position):
	set_global_pos(position)
	if (spring):
		spring.set_node_a(NodePath(""))

func _ready():
	set_fixed_process(true)
	activate_spring_area = get_node("activate_spring_area")
	activate_spring_area.connect("body_enter",self,"_on_Area2D_body_enter")
	if (blackhole_path): blackhole = get_node(blackhole_path)
	
func _on_Area2D_body_enter(body):
	spring = body.get_node("spring")
	
	if (spring != null && (spring.get_node_a() == null || spring.get_node_a().is_empty())):
		spring.set_node_a(get_path())

	if body.has_node("spring"):
		var spring = body.get_node("spring")
		
		if (spring.get_node_a() == null || spring.get_node_a().is_empty()):
			spring.set_node_a(get_path())
	
	if get_tree().get_nodes_in_group("killable").find(body) != -1:
		if body.player_index != player_index:
			body.kill()

func _fixed_process(delta):
	if (blackhole):
		to_bh = get_global_pos() - blackhole.get_global_pos()
		if (to_bh.length() >= 500):
			set_applied_force(to_bh.normalized() * -blackhole_pull)
		else:
			set_applied_force(to_bh.normalized() * blackhole_pull)
