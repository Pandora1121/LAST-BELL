# Test plan

## Automated / headless checks

- Import project resources and parse all GDScript in Godot headless mode.
- Start the main scene headlessly and check that it exits without script errors.
- As systems are added, add deterministic checks for inventory progression, invalid and valid puzzle states, enemy transitions, settings persistence, pause, restart, and ending.

## Automated checks added

- `tests/test_progression.gd`: fuse requirement, invalid/valid locker code, key, and ending state.
- `tests/test_pause.gd`: pause, resume, and game-over state.
- `tests/test_settings.gd`: settings save/load round trip.
- `tests/test_enemy_perception.gd`: noise range, investigate target, navigation path, forward vision, and wall occlusion.
- `tests/test_audio_setup.gd`: required audio streams and playback setup.

## Manual checks (not yet performed)

- Walk into walls and desks; verify the player cannot pass through geometry.
- Toggle flashlight, crouch, sprint, and interact with each prop.
- Follow the clue and objective sequence to the ending.
- Verify the game-over recovery path and menus after those systems are implemented.

## Current results

- Godot 4.7.2 headless startup passed without parser or runtime errors.
- Progression, pause/recovery, settings persistence, enemy hearing, navigation, and line-of-sight scripts passed.
- Audio resource import, loop configuration, and bus checks passed headlessly; listening quality still needs a graphical session.
- No graphical gameplay check has been performed.
- The Godot export template directory is empty; no Windows build was generated.
- Audio assets are generated locally; their mix and the flicker pacing have not been evaluated in a graphical session.
