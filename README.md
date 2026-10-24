# LAST BELL

An atmospheric first-person horror prototype built with Godot 4.7.2. The playable graybox contains a traversable school corridor connected to a classroom, teachers' room, and storage room; mouse-look; walking, sprinting, and crouching; flashlight; raycast interaction; fuse, electrical panel, locker-code clue, exit key; Hall Monitor patrol/investigate/chase/search/attack states; pause/settings; game-over recovery; and an exit sequence. Sprinting produces noise the Hall Monitor can hear, while walls block its line of sight. The school uses a NavigationAgent3D over an authored corridor and doorway navmesh; fluorescent lights flicker intermittently, generated school-room tone and a distant bell provide basic ambience, and original generated one-shot effects cover footsteps and key progression interactions. All scene geometry and audio effects are generated locally; no third-party assets are included.

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

Godot 4.7.2 is installed. Headless startup, progression, pause/recovery, settings persistence, enemy perception/navigation, and the original ambience resource checks passed before the latest gameplay SFX changes. The scene is procedural graybox geometry with no authored models or animations. No graphical gameplay playthrough has been performed, so the generated audio mix and flicker pacing still need listening and visual QA. Richer rooms and a longer narrative remain incomplete. Godot export templates are not installed in this environment, so no Windows executable was produced.

## Audio assets

Run `python tools/generate_placeholder_audio.py` to regenerate the original WAV assets, including ambience, the distant bell, footsteps, pickup, electrical panel, locker, and exit cues. The one-shot effects use the SFX bus. Their levels and timbre still need a listening pass in a graphical session.
