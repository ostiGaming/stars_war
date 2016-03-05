# called when the entity is being wrapped
func _init():
	add_to_group("wrappable")

func _on_wrapped(position):
	get_node("trail_renderer").new_trail()
	get_node("spaceship_root/spaceship_physics").set_pos(position)