# LAST BELL

An atmospheric first-person horror prototype built with Godot 4.7.2. The playable graybox contains a traversable abandoned-school corridor, mouse-look, walking/sprinting/crouching, flashlight, raycast interaction, a fuse, electrical panel, locker-code clue, exit key, Hall Monitor patrol/investigate/chase/search/attack states, pause/settings, game-over recovery, and an exit sequence. Sprinting produces noise the Hall Monitor can hear, while walls block its line of sight. The school corridor uses a NavigationAgent3D over a simple authored navmesh; fluorescent lights flicker intermittently, and a generated room-tone loop and timed distant bell provide basic ambience. All scene geometry is generated from built-in primitives at runtime; no third-party assets are included.

## Run

Open this folder in Godot 4.7.2 or later and press **F6/F5** (or run `scenes/main/main.tscn`). The game starts in mouse capture; click the window to recapture after releasing the mouse.

## Controls

- **WASD** move
- **Mouse** look
- **Shift** sprint
- **Ctrl** crouch
- **F** toggle flashlight
- **E** interact
- **Esc** pause / resume

## Prototype route

Explore the corridor and alcoves. Read the note on the right wall for story context and locker code. Find the fuse and use the electrical panel near the far end. Open locker 14 with the code, collect the exit key, and return to the far exit door. Avoid the Hall Monitor; if caught, press Enter to restart.

## Validation and limitations

Godot 4.7.2 is installed. Headless startup, progression, pause/recovery, settings persistence, enemy perception/navigation, and audio resource checks pass. The scene is procedural graybox geometry with no authored models or animations. No graphical gameplay playthrough has been performed, so the generated audio mix and flicker pacing still need listening and visual QA. Footstep and door sound effects, richer rooms, and a longer narrative remain incomplete. Godot export templates are not installed in this environment, so no Windows executable was produced.
