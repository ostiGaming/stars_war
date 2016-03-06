extends Node

signal on_wrap(position)

onready var bounds = get_node("bounds")

func connect_on_wrap(wrapper):
	self.connect("on_wrap", wrapper)
	
func _ready():
	bounds.connect("body_exit", self, "_body_exit")
	get_tree().call_group(0, "wrapable", "connect_on_wrap", self)
	
func _body_exit(body):
	print("Where do you think you are going?", body)
	emit_signal("on_wrap", body, body.get_global_pos())
	var center_to_body = bounds.get_pos() - body.get_global_pos()
	var new_pos = bounds.get_pos() + center_to_body
	body.wrap(new_pos)