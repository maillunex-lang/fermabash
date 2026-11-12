# Stage 2.2: Russian adaptive interface

The UI is implemented in `scripts/ui/game_ui.gd` and communicates with gameplay through `action_requested(action)` signals. It does not directly modify the farm's money, crops, structures or save format.

## Delivered
- Dark green agricultural theme, amber highlights, readable Russian menu and resource HUD.
- Resource panel: game day, money, grain, field/job state, progress and status feedback.
- Responsive 6-column desktop or 3-column narrow-screen action grid, touch-sized buttons.
- Main menu: new game, continue, settings placeholder, exit.
- Actions remain: sow, harvest, sell, place warehouse, save, menu.
- Buttons are disabled when their corresponding action is currently unavailable.

## Tests and limits
- `tests/ui.gd`: menu transitions, signal-driven sow/save, disabled state and continuation.
- All prior gameplay, world/camera and system tests remain in the CI and Android build script.
- Godot editor import, Xvfb graphical launch and Android debug APK export verified on Lunex.
- Physical Android touch testing, small-screen screenshot review and accessibility assessment are still pending.
- Settings currently display a status message, not a complete preferences screen.
- A detailed field/equipment inspector and construction catalog belong to later gameplay/UI iterations.
