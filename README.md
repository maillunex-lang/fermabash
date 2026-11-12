# Agro Empire Online (FermaBash)

Early 3D agricultural strategy prototype for Godot **4.7.2 stable**. Not yet a public MMO.

## Run locally
Open `project.godot` in Godot 4.7.2 and press F5. Start a new game from the Russian main menu.
Desktop controls: right mouse drag pans, wheel zooms, Q/E rotates, left click selects/builds.

## Test
`godot --headless --path . --editor --quit`
`godot --headless --path . --script res://tests/smoke.gd`
`godot --headless --path . --script res://tests/systems.gd`

## Android debug build
On Lunex, in `/opt/fermabash/project`, run `bash tools/build_android_on_vps.sh`.
Requires Godot 4.7.2 stable, matching export templates, JDK 17 and Android SDK.
Output (not committed): `build/AgroEmpireOnline-debug.apk`. Debug-signed, not a release build.
No Android physical-device playtest has been completed.

## Architecture and scope
See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) and [docs/ROADMAP.md](docs/ROADMAP.md).
