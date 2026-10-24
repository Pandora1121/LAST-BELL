# Hina Blue Neko character asset

The GLB is admitted locally at `assets/characters/hina/model.glb` through the Game Development Studio asset-vendoring workflow. Its package manifest, receipt, validation report, and extracted import files remain local and are excluded from Git.

The source is the [Hina 3D Anime Character Girl for Blender listing on Fab](https://www.fab.com/listings/d5d356ab-e99a-4681-a95b-12d8057db771). Fab lists commercial use as allowed and credit as optional. The governing terms are the [Fab Standard License](https://www.fab.com/eula): the asset may be incorporated into a project and shared with collaborators working on that project, but it must not be redistributed as a standalone asset. For that reason, this public repository contains only this note, not the GLB or its textures. Obtain the asset from Fab and place the GLB at the path above before opening the project.

The admitted model has 14 meshes, 14 textures, a rig, and no animation clips. Godot 4.7.2 imported it headlessly. When the local GLB is present, the player controller displays it from a third-person follow camera. The model is rigid because it has no animation clips.
