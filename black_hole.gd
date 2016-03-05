extends RigidBody2D

var win_game_area

func _ready():
	win_game_area = get_node("win_game_area")
	win_game_area.connect("body_enter",self,"_on_Area2D_body_enter")

func _on_Area2D_body_enter(body):
	#win_game_area.disconnect("body_enter",self,"_on_Area2D_body_enter")
	print(body)

