# tm-mods
Tools for adding onto Terraforming Mars Tabletop Simulator mod (Krymnopht's steam workshop version)

## Usage
1. Install node modules with `npm i`
2. Move TTS TM save .json into `saves/XXXXXXXXXX.json` (ALSO CREATE A `saves/XXXXXXXXXX.bak.json` COPY)
3. Unpack save with `npm run unpack` (will get first non '.bak.json` file it finds in save folder)
4. Create mod folder + mod config with `npm run init-mod`
5. List any files you want to patch in the `mod/mod_config.json`'s filesToPatch (list directory relative to `mod/` and dont inlcude file extension)
6. Run `npm run sync-mod` to have the files moved from `unpacked/` -> `mod/` (without replacing existing files in mod)
7. Make changes to the files in `mod/`
8. Repack save with `npm run pack` (will output new save file to `repacked/mod_name.json`)
9. Place this save file in `Tabletop Simulator/Saves`; this save should now appear in game to load, with the same name as in the mod_config

## Unpacking

Unpacking will split the original save JSON into more manageable sections. The core logic for the game is stored
in the root level lua script, so this is where most focus has gone so far. This script already had sections loosely divided
up by blocks of newlines, so I manually labelled approximately what each block was. This makes up the folder names of the 
`global/` folder.
The files in each of these folders are functions or large blocks of text within each of the larger chunks

## Mod

The `mod/` directory is used to store the files you want to patch the save with.
Setup a new mod by running
```
npm run init-mod
```
Add name of mod and what files to patch in `mod/mod_config.json`
Then run
```
npm run sync-mod
```
To have the files listed be copied from `unpacked/` -> `mod/` (without replacing existing files)

## Repacking

After changing files in `mod/` and configuring `mod_config.json`, run
```
npm run pack
```
To generate a mod zip and playable save file.
