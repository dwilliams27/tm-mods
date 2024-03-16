import { MOD_DIR, Save } from "../models/index.js";
import { fileExists, safeMakeDir, writeJsonFile } from "./tools/index.js";

export class ModManager {
  private _save: Save;

  constructor(save: Save) {
    this._save = save;
    safeMakeDir(MOD_DIR);
  }

  createModConfig() {
    if(!fileExists(MOD_DIR + 'mod_config.json')) {
      writeJsonFile(MOD_DIR + 'mod_config.json', { name: "Sample_mod", filesToPatch: [] });
    }
  }
}
