import { MOD_DIR, ModConfig, PATCH_DIR, Save } from "../models/index.js";
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

  syncModFilesWithPatch() {
    this._modConfig = readJSONFile(PATCH_DIR + 'mod_config.json');
    this._modConfig?.filesToPatch.forEach((file) => {
      if(fileExists(PATCH_DIR + file)) {
        copyFolderOrFile(PATCH_DIR + file, MOD_DIR + file);
      }
    });
  }
}
