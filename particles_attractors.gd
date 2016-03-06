export var particle_group = "attracted"

func _ready():
	for emitter in get_tree().get_nodes_in_group(particle_group):
		var attractor = ParticleAttractor2D.new()
		attractor.set_particles_path(emitter.get_path())
		attractor.set_gravity(0.5)
		attractor.set_radius(300)
		attractor.set_absorption(0)
		add_child(attractor)