# tm-mods
Attempting to make custom corps for Terraforming Mars

## Usage
1. Install node modules with `npm i`
2. Move save .json into `saves/XXXXXXXXXX.json` (ALSO CREATE A `saves/XXXXXXXXXX.bak.json` COPY)
3. Unpack save with `npm run unpack` (will get first non '.bak.json` file it finds in save folder)
4. Make changes to the files
5. Repack save with `npm run pack` (will output new save file to `repacked/save_output.json`)
