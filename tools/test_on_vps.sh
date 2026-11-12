#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/smoke.gd
if command -v xvfb-run >/dev/null; then
  xvfb-run -a -s '-screen 0 1280x720x24' godot --path . --rendering-method gl_compatibility --audio-driver Dummy --quit-after 60
fi
