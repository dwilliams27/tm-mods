import chalk from 'chalk';
import path from 'path';
import {
  RP_DIR,
  Save,
  UP_DIR,
  GlobalLuaModel,
  MOD_DIR
} from '../models/index.js';
import {
  readInFiles,
  readInFolder,
  safeMakeDir,
  writeJsonFile,
  zipFiles 
} from './tools/index.js';
import { ObjectStateManager } from './object_state_manager.js';

export class Repacker {
  private _objectStateManager: ObjectStateManager;

  constructor(save: Save) {
    this._objectStateManager = new ObjectStateManager(save, UP_DIR, {}); 
    safeMakeDir(RP_DIR);
  }

  repack() {
    /* 
      --------------------
      -- Object  States --
      --------------------
    */
    this._objectStateManager.packAllObjectsStates();

    /* 
      --------------------
      ---- Global Lua ----
      --------------------
    */
    console.log(chalk.cyan('Packing object states...'));
    this.repackGlobalLua(this._objectStateManager._modConfig.filesToPatch);

    /* 
      --------------------
      - Repack save.json -
      --------------------
    */
    console.log(chalk.cyan('Packing save file ') + chalk.yellow(path.resolve(RP_DIR + 'save_output.json')));
    writeJsonFile(`${RP_DIR}${this._objectStateManager._modConfig.name}.json`, this._objectStateManager._save);
    console.log(chalk.green('Repacking complete! Replace save in ~/Library/Tabletop Simulator/Saves'));
  }

  repackGlobalLua(filesToPatch: string[]) {
    console.log(chalk.cyan('Packing global lua script'));

    safeMakeDir(RP_DIR + 'global');
    let res = '';
    const unpackedFolderPath = UP_DIR + 'global';

    // Read in mod files as [file_name, data]
    const patchFiles = readInFiles(filesToPatch.filter((file) => !file.startsWith('object-states')).map(((file) => `${MOD_DIR}${file}.lua`)));
    const fileSet: { [key: string]: string} = {};
    for(const patchFile of patchFiles) {
      // Chop off path, only use file name for fileSet map
      fileSet[patchFile[0].substring(patchFile[0].lastIndexOf('/') + 1)] = patchFile[1];
    }

    const modContents: string[] = [];
    modContents.push(MOD_DIR + 'mod_config.json');

    for(const k in GlobalLuaModel) {
      const unpackedFiles = readInFolder(`${unpackedFolderPath}/${(GlobalLuaModel as any)[k]}`);
      for(const unpackedFile of unpackedFiles) {
        // If mod_config said to patch file, use that. Otherwise source file from patch/
        if(!(unpackedFile[0] in fileSet)) {
          res += '\n\n\n' + unpackedFile[1];
        } else {
          console.log(chalk.cyan('Patching file ') + chalk.yellow(unpackedFile[0]));

          res += '\n\n\n' + fileSet[unpackedFile[0]];
          modContents.push(`${unpackedFolderPath}/${(GlobalLuaModel as any)[k]}/${unpackedFile[0]}`);
        }
      }
    }
    
    this.createPortableModZip(modContents, this._objectStateManager._modConfig.name);
    this._objectStateManager._save.LuaScript = res;
  }

  createPortableModZip(paths: string[], filename: string) {
    zipFiles(paths, path.resolve(RP_DIR + filename));
    console.log(chalk.cyan('Created mod zip at ') + chalk.yellow(path.resolve(RP_DIR + filename) + '.zip'));
  }
}
