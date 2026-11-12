# Stage 1 development environment

Engine: Godot 4.7.2 stable, GDScript. Existing Godot 4.8 beta is not overwritten.
Android SDK: /opt/android-sdk on Lunex; JDK 17. Export templates: 4.7.2.stable.
Project: /opt/fermabash/project (development checkout, no production deployment).

## Architecture boundaries
- `scripts/main.gd`: temporary scene/UI composition and prototype gameplay.
- `scripts/systems/build_rules.gd`: deterministic placement rules.
- `scripts/systems/save_store.gd`: versioned save validation and file IO.
- `scripts/systems/game_clock.gd`: time scale (7 real days = 1 game year).
- `tests/`: headless gameplay and system tests.
- `export_presets.cfg`: Android arm64 debug export.

These are first extraction boundaries, not a completed MMO architecture. Gameplay state remains client-owned in this prototype. Before MMO, move all authoritative game decisions to the server and replace local saves with server persistence.

## Validation
Run `godot --headless --path . --editor --quit`.
Run `godot --headless --path . --script res://tests/smoke.gd`.
Run `godot --headless --path . --script res://tests/systems.gd`.
On Lunex: `bash tools/build_android_on_vps.sh`.

APK is a development build signed with an Android debug key. Do not use as a production release. Never commit signing credentials.
The current prototype has no real online gameplay, geographic map, completed touch UX or physical-device testing.
