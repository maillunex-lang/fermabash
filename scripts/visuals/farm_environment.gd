extends RefCounted
## Original procedural scenery. Geometry is intentionally lightweight for mobile.
const CELL := 3.0
const GRID := 16

static func material(color: Color, roughness := 0.84) -> StandardMaterial3D:
 var mat := StandardMaterial3D.new()
 mat.albedo_color = color
 mat.roughness = roughness
 mat.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
 mat.metallic_specular = 0.18
 return mat
static func wheat_material(color: Color) -> ShaderMaterial:
 var mat := ShaderMaterial.new()
 mat.shader = load("res://scripts/visuals/wheat.gdshader")
 # Vertex color path is unused here; tint via albedo uniform fallback by painting the mesh.
 var fallback := StandardMaterial3D.new()
 fallback.albedo_color = color
 fallback.roughness = 0.55
 return mat if mat.shader != null else fallback

static func box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> void:
 var node := MeshInstance3D.new()
 var mesh := BoxMesh.new()
 mesh.size = size
 node.mesh = mesh
 node.material_override = material(color)
 node.position = pos
 parent.add_child(node)

static func instances(parent: Node3D, mesh: Mesh, mat: Material, transforms: Array[Transform3D]) -> void:
 if transforms.is_empty():
  return
 var multi := MultiMesh.new()
 multi.transform_format = MultiMesh.TRANSFORM_3D
 multi.mesh = mesh
 multi.instance_count = transforms.size()
 for i in range(transforms.size()):
  multi.set_instance_transform(i, transforms[i])
 var node := MultiMeshInstance3D.new()
 node.multimesh = multi
 node.material_override = mat
 parent.add_child(node)

static func decorate(parent: Node3D, stage: int) -> void:
 # Surrounding meadow sits outside the interactive 16x16 grid.
 box(parent,Vector3(24,-0.45,24),Vector3(124,0.45,124),Color("6e9450"))
 # Gentle perimeter embankments, never inside playable cells.
 for i in range(16):
  var x := (i+0.5)*CELL
  box(parent,Vector3(x,-0.1,-3.5),Vector3(CELL,0.4,6.5),Color("668a48"))
  box(parent,Vector3(x,-0.1,51.5),Vector3(CELL,0.4,6.5),Color("668a48"))
 # Orchard trees are batched in two draw calls and avoid gameplay cells.
 var trunks: Array[Transform3D] = []
 var crowns: Array[Transform3D] = []
 for i in range(36):
  var ix := i % 12
  var iz := i / 12
  var p := Vector3(-12+ix*6.5,0,-16+iz*3.3)
  if p.x > -3 and p.x < 51:
   p.z = -12.0
  var scale := 0.85 + float(i % 5)*0.08
  trunks.append(Transform3D(Basis().scaled(Vector3(0.45*scale,2.8*scale,0.45*scale)),p+Vector3(0,1.4*scale,0)))
  crowns.append(Transform3D(Basis().scaled(Vector3(2.6*scale,2.6*scale,2.6*scale)),p+Vector3(0,3.5*scale,0)))
 var trunk_mesh := CylinderMesh.new()
 trunk_mesh.top_radius = 0.7
 trunk_mesh.bottom_radius = 0.9
 var crown_mesh := SphereMesh.new()
 crown_mesh.radial_segments = 8
 crown_mesh.rings = 4
 instances(parent,trunk_mesh,material(Color("73543a")),trunks)
 instances(parent,crown_mesh,material(Color("477d3b")),crowns)
 # Parallel crop lines visually distinguish planted and mature fields.
 if stage > 0:
  var crop_mesh := BoxMesh.new()
  crop_mesh.size = Vector3(0.12,0.55 if stage == 1 else 1.05,0.12)
  var crops: Array[Transform3D] = []
  for x in range(5,9):
   for z in range(3,7):
    for row in range(4):
     for col in range(5):
      var px := (float(x)+0.1+float(row)*0.23)*CELL
      var pz := (float(z)+0.1+float(col)*0.19)*CELL
      var h := 0.55 if stage == 1 else 1.05
      crops.append(Transform3D(Basis(),Vector3(px,h*0.5,pz)))
  var crop_mat := ShaderMaterial.new()
  crop_mat.shader = load("res://scripts/visuals/wheat.gdshader")
  crop_mat.set_shader_parameter("albedo_tint", Color("5d9f3f") if stage == 1 else Color("e2bd51"))
  crop_mat.set_shader_parameter("wind", 0.18)
  instances(parent,crop_mesh,crop_mat,crops)
 # Road shoulder and center markings are purely decorative.
 for z in [7,8]:
  for x in range(16):
   if x % 3 == 0:
    box(parent,Vector3((x+0.5)*CELL,0.025,(z+0.5)*CELL),Vector3(1.1,0.025,0.08),Color("d4cba2"))
 var water := MeshInstance3D.new()
 var pond := PlaneMesh.new()
 pond.size = Vector2(11, 7)
 water.mesh = pond
 var water_mat := ShaderMaterial.new()
 water_mat.shader = load("res://scripts/visuals/water.gdshader")
 water.material_override = water_mat
 water.position = Vector3(-8, 0.04, 22)
 parent.add_child(water)

