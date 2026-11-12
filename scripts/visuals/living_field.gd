extends Node3D
## Lightweight visual-only field: one MultiMesh for soil tiles and one for crop stalks.
const Route = preload("res://scripts/systems/field_route.gd")
const CELL := 3.0
var soil: MultiMeshInstance3D
var crops: MultiMeshInstance3D
var last_signature := ""
func _ready() -> void:
 soil = MultiMeshInstance3D.new()
 add_child(soil)
 crops = MultiMeshInstance3D.new()
 add_child(crops)
 var soil_mesh := BoxMesh.new()
 soil_mesh.size = Vector3(2.95,0.08,2.95)
 var soil_batch := MultiMesh.new()
 soil_batch.transform_format = MultiMesh.TRANSFORM_3D
 soil_batch.use_colors = true
 soil_batch.mesh = soil_mesh
 soil_batch.instance_count = 16
 soil.multimesh = soil_batch
 var crop_mesh := BoxMesh.new()
 crop_mesh.size = Vector3(0.12,1.0,0.12)
 var crop_batch := MultiMesh.new()
 crop_batch.transform_format = MultiMesh.TRANSFORM_3D
 crop_batch.use_colors = true
 crop_batch.mesh = crop_mesh
 crop_batch.instance_count = 320
 crops.multimesh = crop_batch
 var mat := StandardMaterial3D.new()
 mat.vertex_color_use_as_albedo = true
 mat.roughness = 1.0
 soil.material_override = mat
 crops.material_override = mat

func update_field(stage: int, prepared: bool, job: String, progress: float) -> void:
 # Rebuild only when a visible milestone changes (16 buckets across a job).
 var bucket := clampi(int(progress*48.0),0,48) if job != "" else clampi(int(progress*10.0),0,10)
 var signature := "%d:%s:%s:%d" % [stage,str(prepared),job,bucket]
 if signature == last_signature:
  return
 last_signature = signature
 var tile := 0
 var stalk := 0
 for x in range(5,9):
  for z in range(3,7):
   var touched := job != "" and Route.completed_fraction(progress,x,z)
   var color := Color("806040")
   if prepared or (job == "prepare" and touched):
    color = Color("51392a")
   if stage == 1 or (job == "sow" and touched):
    color = Color("795c37")
   if stage == 2:
    color = Color("a78b3f")
   if job == "harvest" and touched:
    color = Color("7b6040")
   soil.multimesh.set_instance_transform(tile,Transform3D(Basis(),Vector3((x+0.5)*CELL,0.035,(z+0.5)*CELL)))
   soil.multimesh.set_instance_color(tile,color)
   tile += 1
   var visible_crop := stage > 0 or (job == "sow" and touched)
   if job == "harvest" and touched:
    visible_crop = false
   for row in range(4):
    for col in range(5):
     var height := 0.08
     var crop_color := Color("62a64c")
     if visible_crop:
      height = 0.24 if job == "sow" else (0.55 + 0.3*progress if stage == 1 else 1.05)
      crop_color = Color("65a64c") if stage == 1 or job == "sow" else Color("e2bd51")
     var pos := Vector3((float(x)+0.1+float(row)*0.23)*CELL,height*0.5,(float(z)+0.1+float(col)*0.19)*CELL)
     crops.multimesh.set_instance_transform(stalk,Transform3D(Basis().scaled(Vector3(1,height,1)),pos))
     crops.multimesh.set_instance_color(stalk,crop_color if visible_crop else Color(0,0,0,0))
     stalk += 1
