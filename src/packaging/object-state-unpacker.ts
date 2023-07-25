import { GUIDMap } from "../models/custom-models";
import { GUIDState, GUIDStateToWrite, ObjectState, PATCH_DIR } from "../models/game-models";
import { formatLuaPrettier, safeMakeDir, writeFile, writeJsonFile } from "./tools/io-tools";
import { generateObjectStateFolderName, generateUniqueGUID } from "./tools/name-tools";

export class ObjectStateUnpacker {
  private _objectStates: ObjectState[] = [];
  private _map: GUIDMap = {};
  private _basePath = '';

  constructor(objectStates: ObjectState[], basePath: string, map: GUIDMap) {
    this._objectStates = objectStates;
    this._basePath = basePath;
    this._map = map;
  }

  public unpackAll() {
    for(const state of this._objectStates) {
      this.writeGUID(state, this._basePath);
    }
  }

  createObjectStateNamedFolder(state: ObjectState, path: string) {
    safeMakeDir(path + generateObjectStateFolderName(state));
  }

  /**
   * Recursively write GUID files down thru ContainedObjects
   * @param state 
   * @param path 
   */
  public writeGUID(state: GUIDState, path: string) {
    const guidJSON = state as GUIDState;
    const folderName = generateObjectStateFolderName(state);
    const readableName = generateObjectStateFolderName(state) + '_' + (guidJSON.GUID in this._map ? guidJSON.GUID : generateUniqueGUID(state));
    const workingFolder = path + folderName + '/';
    safeMakeDir(workingFolder);
    writeJsonFile(workingFolder + readableName + '.json', guidJSON as GUIDStateToWrite);
    if(state.LuaScript) writeFile(workingFolder + readableName + '.lua', formatLuaPrettier(state.LuaScript));
    if(state.LuaScriptState) writeFile(workingFolder + readableName + '.state.json', formatLuaPrettier(state.LuaScriptState));
    if(state.ContainedObjects) {
      state.ContainedObjects.forEach((obj, index) => {
        const stateToWrite: GUIDState = obj;
        stateToWrite._index = index;
        stateToWrite._uguid = generateUniqueGUID(obj);
        stateToWrite._uid = generateObjectStateFolderName(obj);
        this.writeGUID(stateToWrite, workingFolder);
      });
    }
  }
}