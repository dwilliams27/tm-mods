import { GUIDState, ObjectState, PATCH_DIR } from "../models/game-models";
import { safeMakeDir, writeJsonFile } from "./tools/io-tools";
import { generateObjectStateFolderName } from "./tools/name-tools";

export class ObjectStateUnpacker {
  private _objectStates: ObjectState[] = []
  private _basePath = '';

  constructor(objectStates: ObjectState[], basePath: string) {
    this._objectStates = objectStates;
    this._basePath = basePath;
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
  public writeGUID(state: ObjectState, path: string) {
    const guidJSON = state as GUIDState;
    writeJsonFile(path + state.GUID + '.json', guidJSON);
    if(state.LuaScript) writeJsonFile(path + state.GUID + '.lua', state.LuaScript);
    if(state.LuaScriptState) writeJsonFile(path + state.GUID + '.state.json', state.LuaScriptState);
    if(state.ContainedObjects) {
      const workingFolder = path + state.GUID + '/';
      safeMakeDir(workingFolder);
      this.createObjectStateNamedFolder(state, workingFolder);
      for(const obj of state.ContainedObjects) {
        this.writeGUID(obj, workingFolder + generateObjectStateFolderName(state));
      }
    }
  }
}