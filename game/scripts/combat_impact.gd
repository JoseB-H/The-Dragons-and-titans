extends Node3D
## Efecto visual aislado del actor alcanzado y de la simulación de daño.

const FLASH_SHADER := preload("res://assets/combat_flash.gdshader")
const SPARK_COUNT := 9
const DURATION := 0.38

var _age := 0.0
var _size := 1.0
var _flash: ShaderMaterial
var _sparks: MultiMesh
var _directions: Array[Vector3] = []


func configure(tint: Color, size_factor: float) -> void:
	_size = size_factor
	_flash = ShaderMaterial.new()
	_flash.shader = FLASH_SHADER
	_flash.set_shader_parameter("tint", tint)

	var face := QuadMesh.new()
	face.size = Vector2.ONE * (3.5 * _size)
	var flash := MeshInstance3D.new()
	flash.mesh = face
	flash.material_override = _flash
	flash.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(flash)

	var shard := BoxMesh.new()
	shard.size = Vector3(0.065, 0.065, 0.28) * _size
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = tint.lerp(Color(1.0, 0.96, 0.69), 0.57)
	shard.material = material
	_sparks = MultiMesh.new()
	_sparks.transform_format = MultiMesh.TRANSFORM_3D
	_sparks.mesh = shard
	_sparks.instance_count = SPARK_COUNT
	var spark_mesh := MultiMeshInstance3D.new()
	spark_mesh.multimesh = _sparks
	spark_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(spark_mesh)

	for index in range(SPARK_COUNT):
		var angle := TAU * float(index) / SPARK_COUNT
		_directions.append(Vector3(cos(angle), 0.18 + 0.24 * sin(index * 1.7), sin(angle)).normalized())
	_render_sparks(0.0)


func _process(delta: float) -> void:
	_age += delta
	var progress := minf(_age / DURATION, 1.0)
	if progress >= 1.0:
		queue_free()
		return
	_flash.set_shader_parameter("progress", progress)
	_render_sparks(progress)


func _render_sparks(progress: float) -> void:
	for index in range(SPARK_COUNT):
		var ray := _directions[index]
		var spread := (0.16 + 1.4 * (1.0 - pow(1.0 - progress, 2.0))) * _size
		var basis := Basis.looking_at(ray).scaled(Vector3.ONE * maxf(0.01, 1.0 - progress))
		_sparks.set_instance_transform(index, Transform3D(basis, ray * spread))
