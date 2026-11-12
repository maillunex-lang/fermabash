# Stage 2.4.1: living fields and machinery passes

This substage preserves the existing single-field agricultural loop, costs, storage, save schema and Android compatibility.

- `scripts/systems/field_route.gd`: deterministic six-lane serpentine route within the original 4x4 field (world coordinates 15..27 x 9..21). Interpolated tractor/combine position and heading depend only on saved job progress.
- `scripts/visuals/living_field.gd`: one 16-instance MultiMesh for soil colors and one 320-instance MultiMesh for wheat. Updates are quantized to 48 progress buckets during jobs and 10 during growth; no per-frame node creation.
- `scripts/main.gd`: renders and restores machine position and progressive field stages, without modifying gameplay logic or save schema.
- `tests/living_field.gd`: route endpoints and bounds, stage changes, batch counts, progress and active-job save/load.
- CI and VPS Android export now include the additional test.

Lunex: seven regression suites passed, Xvfb OpenGL compatibility graphical launch exit 0, Android debug APK export and v2/v3 signature verification succeeded. This is a simplified visual route: turns are polygonal, no wheel animation or soil physics. Actual Android hardware FPS, touch input, screenshots and GPU behavior are not verified yet. The next 2.4.2 substage is not started.
