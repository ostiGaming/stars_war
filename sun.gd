extends RigidBody2D

var activate_spring_area

func _ready():
	activate_spring_area = get_node("activate_spring_area")
	activate_spring_area.connect("body_enter",self,"_on_Area2D_body_enter")

func _on_Area2D_body_enter(body):
	var spring = body.get_node("spring")
	
	if (spring != null && (spring.get_node_a() == null || spring.get_node_a().is_empty())):
		spring.set_node_a(get_path())

