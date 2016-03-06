extends RigidBody2D

var win_game_area

func _ready():
	win_game_area = get_node("win_game_area")
	win_game_area.connect("body_enter",self,"_on_Area2D_body_enter")

func _on_Area2D_body_enter(body):
	if get_tree().get_nodes_in_group("killable").find(body) != -1:
		body.kill()

	if get_tree().get_nodes_in_group("winable").find(body) != -1:
		get_tree().reload_current_scene()