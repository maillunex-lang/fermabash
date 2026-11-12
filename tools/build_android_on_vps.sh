#!/usr/bin/env bash
set -euo pipefail
PROJECT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT_BIN:-/opt/game-tools/godot/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64}"
export ANDROID_HOME="${ANDROID_HOME:-/opt/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
cd "$PROJECT"
mkdir -p build assets/vehicles
# Pinned binary asset is hosted separately from the Git repository.
TRACTOR_URL="https://rikagro.ru/agrogame/assets/tractor_mobile.glb"
TRACTOR_SHA256="99bcc67624aff0d831315d1e93c4d61a03b9a1ad2a54caf463dc6cb01e139b16"
if [[ ! -f assets/vehicles/tractor_mobile.glb ]] || ! echo "$TRACTOR_SHA256  assets/vehicles/tractor_mobile.glb" | sha256sum -c --status; then
  curl --fail --location --retry 3 --silent --show-error "$TRACTOR_URL" -o assets/vehicles/tractor_mobile.glb.tmp
  echo "$TRACTOR_SHA256  assets/vehicles/tractor_mobile.glb.tmp" | sha256sum -c
  mv assets/vehicles/tractor_mobile.glb.tmp assets/vehicles/tractor_mobile.glb
fi
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
"$GODOT" --headless --path . --script res://tests/full_stage_4.gd
"$GODOT" --headless --path . --export-debug Android build/AgroEmpireOnline-debug.apk
"$ANDROID_HOME/build-tools/36.1.0/apksigner" verify --verbose build/AgroEmpireOnline-debug.apk
sha256sum build/AgroEmpireOnline-debug.apk
