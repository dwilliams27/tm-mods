import { MOD_DIR, ModConfig, Save, UP_DIR } from "../models/index.js";
import { copyFolderOrFile, fileExists, readJSONFile, safeMakeDir, writeJsonFile } from "./tools/index.js";

export class ModManager {
  private _save: Save;
  private _modConfig?: ModConfig | null = null;

  constructor(save: Save) {
    this._save = save;
    safeMakeDir(MOD_DIR);
  }

  createModConfig() {
    if(!fileExists(MOD_DIR + 'mod_config.json')) {
      writeJsonFile(MOD_DIR + 'mod_config.json', { name: "Sample_mod", filesToPatch: [] });
    }
  }

  syncModFiles() {
    this._modConfig = readJSONFile(MOD_DIR + 'mod_config.json');
    this._modConfig?.filesToPatch.forEach((file) => {
      if(fileExists(`${UP_DIR}${file}.json`)) {
        copyFolderOrFile(`${UP_DIR}${file}.json`, `${MOD_DIR}${file}.json`);
      }
      if(fileExists(`${UP_DIR}${file}.lua`)) {
        copyFolderOrFile(`${UP_DIR}${file}.lua`, `${MOD_DIR}${file}.lua`);
      }
    });
  }
}
