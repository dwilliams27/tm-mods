import { GUIDState, GUIDMap, ObjectState, Save, ModConfig, MOD_DIR } from "../models/index.js";
import {
  generateObjectStateFolderName,
  formatLuaPrettier,
  safeMakeDir,
  writeFile,
  writeJsonFile,
  readJSONFile,
  fileExists,
  readFileAsString
} from "../utils/index.js";
import chalk from "chalk";

export class ObjectStateManager {
  _save: Save;
  _map: GUIDMap;
  _basePath: string;
  _modConfig: ModConfig;

  constructor(save: Save, basePath: string, map: GUIDMap) {
    this._save = save;
    this._basePath = basePath;
    this._map = map;
    this._modConfig = readJSONFile(`${MOD_DIR}mod_config.json`);
  }

  public unpackAll() {
    for(const state of this._save.ObjectStates) {
      this.writeGUID(state, this._basePath);
    }
  }

  public packAllObjectsStates() {
    // Filter for only object states, and remove file extensions
    const files = this._modConfig.filesToPatch.filter((file) => file.startsWith('object-states')).map((file) => MOD_DIR + file);
    this.patchSave(files);
  }

  createObjectStateNamedFolder(state: ObjectState, path: string) {
    safeMakeDir(path + generateObjectStateFolderName(state));
  }

  /**
   * Recursively match and replace GUID states down thru ContainedObjects
   * @param state 
   * @param path 
   */
  patchGUIDStates(statesToSave: { states: GUIDState[], guids: string[] }, curState: GUIDState) {
    // TODO: Need to fix replacement, nondeterministic if any patch files are descendants of other patch files (what if we replace child then parent?)
    // TODO: Make more efficient, store map or smth
    if (statesToSave.guids.includes(curState.GUID)) {
      return true;
    }
    if (!curState.ContainedObjects || statesToSave.states.length === 0) {
      return false;
    }
    curState.ContainedObjects = curState.ContainedObjects.map((obj) => {
      if (this.patchGUIDStates(statesToSave, obj)) {
        const new_state = statesToSave.states.find((state) => state.GUID === obj.GUID);
        statesToSave.states = statesToSave.states.filter((state) => state.GUID === obj.GUID);
        return new_state;
      }

      return obj;
    }) as ObjectState[];

    return false;
  }

  /**
   * Patch files by GUID in given Save object
   * @param state 
   * @param path 
   */
  public patchSave(files: string[]) {
    const guids: string[] = [];
    const states: GUIDState[] = files.map((file) => {
      const state = readJSONFile(`${file}.json`) as GUIDState;
      if (fileExists(`${file}.lua`)) state.LuaScript = readFileAsString(`${file}.lua`);
      guids.push(file.substring(file.length - 6));
      return state;
    });
    const statesToSave = { states, guids };
    this._save.ObjectStates = this._save.ObjectStates.map((state) => {
      // While there are still files yet to be patched, keep searching
      if (statesToSave.states.length > 0) {
        if (this.patchGUIDStates(statesToSave, state)) {
          return statesToSave.states.filter((s) => s.GUID === state.GUID)[0];
        }
      }
      return state;
    });
  }

  /**
   * Recursively write GUID files down thru ContainedObjects
   * @param state 
   * @param path 
   */
  public writeGUID(state: GUIDState, path: string) {
    const folderName = generateObjectStateFolderName(state);
    const readableName =
      generateObjectStateFolderName(state) +
      '_' +
      (state.GUID in this._map
        ? state.GUID
        : (() => { console.log(chalk.white(`Duplicate GUID found: ${state.GUID}`)); return state.GUID })());
    const workingFolder = path + folderName + '/';
    safeMakeDir(workingFolder);
    if(state.LuaScript) writeFile(workingFolder + readableName + '.lua', formatLuaPrettier(state.LuaScript));
    delete state.LuaScript;
    writeJsonFile(workingFolder + readableName + '.json', state);
    if(state.ContainedObjects) {
      state.ContainedObjects.forEach((obj, index) => {
        const stateToWrite: GUIDState = obj;
        // TODO: Revisit need for metadata fields
        stateToWrite._index = index;
        stateToWrite._uid = generateObjectStateFolderName(obj);
        this.writeGUID(stateToWrite, workingFolder);
      });
    }
  }
}