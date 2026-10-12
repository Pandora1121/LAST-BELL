# Test plan

## Automated / headless checks

- Import project resources and parse all GDScript in Godot headless mode.
- Start the main scene headlessly and check that it exits without script errors.
- As systems are added, add deterministic checks for inventory progression, invalid and valid puzzle states, enemy transitions, settings persistence, pause, restart, and ending.

## Automated checks added

- `tests/test_progression.gd`: fuse requirement, invalid/valid locker code, key, and ending state.
- `tests/test_pause.gd`: pause, resume, and game-over state.
- `tests/test_settings.gd`: settings save/load round trip.

## Manual checks (not yet performed)

- Walk into walls and desks; verify the player cannot pass through geometry.
- Toggle flashlight, crouch, sprint, and interact with each prop.
- Follow the clue and objective sequence to the ending.
- Verify the game-over recovery path and menus after those systems are implemented.

## Current results

- Godot 4.7.2 headless startup passed without parser or runtime errors.
- Progression, pause/recovery, and settings persistence scripts passed.
- No graphical gameplay check has been performed.
