extends Node

signal on_wrap(position)

func _ready():
	get_tree.call_group(0, "warpable", self)
