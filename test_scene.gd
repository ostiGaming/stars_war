extends Node2D

func _ready():
	var player1 = get_node("player1")
	var player2 = get_node("player2")
	
	player1.player_index = 0
	player2.player_index = 1

