# LAST BELL

An atmospheric third-person horror prototype built with Godot 4.7.2. The playable school connects a corridor to classroom alcoves, the teachers' room, and storage room. It includes mouse-look, walking, sprinting, crouching, flashlight, raycast interaction, a fuse/power/locker/exit puzzle, and two threats: the Hall Monitor crawler and a masked missing student. The player uses an optional locally installed Hina character asset; see `assets/characters/hina/README.md`. The Hall Monitor patrols, investigates, chases, searches, and attacks; sprinting can draw its attention, while walls block its line of sight. Both threats use authored navigation regions. The school, enemy meshes, surface textures, ambience, and gameplay sounds are generated locally.

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

Explore the corridor and alcoves. Optional notes in the classroom and storage room reveal more about Student 14 and the final bell; the note on the right wall gives the locker code. Find the fuse and use the electrical panel near the far end. Restoring power rings the final bell and alerts both threats, so plan a route before activating it. Open locker 14 with the code, collect the exit key, and return to the far exit door. Avoid the threats; if caught, press Enter to restart.

## Validation and limitations

Godot 4.7.2 is installed. Headless startup, progression, pause/recovery, settings persistence, enemy perception/navigation, and audio-resource checks passed before the latest visual, input, and bell-escalation changes. Character geometry and school materials are assembled/generated at runtime and still need a graphical playthrough for visual QA. Generated audio mix and flicker pacing also need listening. Richer rooms and a longer narrative remain incomplete. Godot export templates are not installed in this environment, so no Windows executable was produced.

## Audio assets

Run `python tools/generate_placeholder_audio.py` to regenerate the original WAV assets, including ambience, the distant bell, footsteps, pickup, electrical panel, locker, and exit cues. The one-shot effects use the SFX bus. Their levels and timbre still need a listening pass in a graphical session.
