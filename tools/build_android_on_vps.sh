#!/usr/bin/env bash
set -euo pipefail
PROJECT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BIN:-/opt/game-tools/godot/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64}"
export ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
cd "$PROJECT"
mkdir -p build
"$GODOT" --headless --path . --editor --quit
"$GODOT" --headless --path . --script res://tests/smoke.gd
"$GODOT" --headless --path . --script res://tests/systems.gd
"$GODOT" --headless --path . --script res://tests/world_camera.gd
"$GODOT" --headless --path . --script res://tests/ui.gd
"$GODOT" --headless --path . --script res://tests/construction.gd
"$GODOT" --headless --path . --script res://tests/production.gd
"$GODOT" --headless --path . --script res://tests/living_field.gd
"$GODOT" --headless --path . --script res://tests/android_controls.gd
"$GODOT" --headless --path . --script res://tests/region_navigation.gd
"$GODOT" --headless --path . --script res://tests/beta_city_map.gd
"$GODOT" --headless --path . --script res://tests/territory.gd
"$GODOT" --headless --path . --export-debug Android build/AgroEmpireOnline-debug.apk
"$ANDROID_HOME/build-tools/36.1.0/apksigner" verify --verbose build/AgroEmpireOnline-debug.apk
sha256sum build/AgroEmpireOnline-debug.apk
