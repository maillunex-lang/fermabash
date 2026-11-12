extends RefCounted
## Serpentine passes across the existing 4x4 field; world coordinates in metres.
const CELL := 3.0
const MIN_X := 5.0 * CELL
const MAX_X := 9.0 * CELL
const MIN_Z := 3.0 * CELL
const MAX_Z := 7.0 * CELL
const PASSES := 6
static func waypoints() -> Array[Vector3]:
 var points: Array[Vector3] = []
 for lane in range(PASSES):
  var x := lerpf(MIN_X + 0.8, MAX_X - 0.8, float(lane) / float(PASSES - 1))
  if lane % 2 == 0:
   points.append(Vector3(x,0,MIN_Z + 0.8))
   points.append(Vector3(x,0,MAX_Z - 0.8))
  else:
   points.append(Vector3(x,0,MAX_Z - 0.8))
   points.append(Vector3(x,0,MIN_Z + 0.8))
 return points

static func position_at(t: float) -> Vector3:
 var points := waypoints()
 var segments := points.size()-1
 var scaled := clampf(t,0.0,1.0)*float(segments)
 var index := mini(int(scaled),segments-1)
 return points[index].lerp(points[index+1],scaled-float(index))

static func heading_at(t: float) -> float:
 var a := position_at(clampf(t-0.001,0.0,1.0))
 var b := position_at(clampf(t+0.001,0.0,1.0))
 var direction := b-a
 if direction.length_squared() < 0.000001:
  return 0.0
 return atan2(direction.x,direction.z)

static func completed_fraction(progress: float, x: int, z: int) -> bool:
 # Per-cell visual progression, in the same order as the machine's serpentine passes.
 var lane := clampi(int(round(float(x-5)*float(PASSES-1)/3.0)),0,PASSES-1)
 var local := (float(z-3)+0.5)/4.0
 var travel := local if lane % 2 == 0 else 1.0-local
 return progress >= (float(lane)+travel)/float(PASSES)
