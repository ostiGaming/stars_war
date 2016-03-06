extends RigidBody2D

var activate_spring_area
export var player_index = 0

func _ready():
	add_to_group("winable")
	activate_spring_area = get_node("activate_spring_area")
	activate_spring_area.connect("body_enter",self,"_on_Area2D_body_enter")

func _on_Area2D_body_enter(body):
	if body.has_node("spring"):
		var spring = body.get_node("spring")
		
		if (spring.get_node_a() == null || spring.get_node_a().is_empty()):
			spring.set_node_a(get_path())
	
	if get_tree().get_nodes_in_group("killable").find(body) != -1:
		if body.player_index != player_index:
			body.kill()
	
