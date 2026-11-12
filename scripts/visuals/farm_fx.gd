extends Node3D
## Visual-only atmosphere. Does not touch gameplay state.
var pollen: GPUParticles3D
var dust: GPUParticles3D

func _ready() -> void:
	pollen = _cloud(Color(0.98, 0.92, 0.75, 0.6), 120, 18.0, Vector3(32, 2.2, 32), 0.28)
	dust = _cloud(Color(0.75, 0.60, 0.40, 0.75), 60, 5.0, Vector3(7, 0.5, 7), 0.85)
	dust.emitting = false
	dust.position = Vector3(18, 0.4, 18)

func set_working(active: bool, at: Vector3 = Vector3(18, 0.4, 18)) -> void:
	if dust == null:
		return
	dust.emitting = active
	if active:
		dust.position = at

func _cloud(color: Color, amount: int, life: float, box: Vector3, speed: float) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.amount = amount
	particles.lifetime = life
	particles.visibility_aabb = AABB(Vector3(-40, -2, -40), Vector3(80, 16, 80))
	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = box
	process.direction = Vector3(0.35, 0.8, 0.1)
	process.spread = 55.0
	process.initial_velocity_min = speed * 0.25
	process.initial_velocity_max = speed
	process.gravity = Vector3(0.05, 0.02, 0)
	process.scale_min = 0.05
	process.scale_max = 0.16
	particles.process_material = process
	var quad := QuadMesh.new()
	quad.size = Vector2(0.22, 0.22)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.billboard_mode = BaseMaterial3D.BILLBOARD_PARTICLES
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.vertex_color_use_as_albedo = true
	quad.material = mat
	particles.draw_pass_1 = quad
	add_child(particles)
	return particles
