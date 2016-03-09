export var particle_group = "attracted"
export var gravity = 0.5
export var radius = 300
export var absorption = 0

func _ready():
	for emitter in get_tree().get_nodes_in_group(particle_group):
		var attractor = ParticleAttractor2D.new()
		attractor.set_particles_path(emitter.get_path())
		attractor.set_gravity(gravity)
		attractor.set_radius(radius)
		attractor.set_absorption(absorption)
		add_child(attractor)