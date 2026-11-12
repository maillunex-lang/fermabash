# Stage 2.1: Farm scenery and mobile camera

## Delivered
- Original procedural 3D environment with perimeter grass, batched low-poly trees, planted/mature crop rows, road markings and soft sky lighting.
- Environment geometry is independent of the 16x16 playable construction grid. Existing save format and economy are unchanged.
- Camera logic extracted to `scripts/camera/strategy_camera.gd`: zoom and focus limits, mouse pan/zoom, Q/E rotation, touch drag, two-finger pinch/rotation.
- Scenery instancing uses `MultiMesh` for repeated trees and crops to reduce draw calls on Android.

## Verification
`tests/world_camera.gd` tests camera clamping, panning, wheel zoom, and environment batch creation.
Previous gameplay and persistence tests remain in CI and Android build script.
Android debug APK is built on Lunex, but it has not been physically installed or tested on an Android device.

## Known limits
- Terrain is a deliberately small procedural demo, not yet Bashkortostan geography.
- Visuals are original low-poly procedural art, not photorealistic models.
- The current GUI is from stage 1 and is not yet redesigned for mobile (stage 2.2).
- Actual mobile FPS, multi-touch on hardware, and graphics-driver compatibility need device testing.
- Visual review via real-device screenshots is still pending.
