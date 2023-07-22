import { ObjectState, PATCH_DIR, Save, UP_DIR } from "../models/game-models";
import * as fs from 'fs';
import { fileExists, findObjectStateByNickname, formatLuaPrettier, getSafeName, getSafeNameS, readFileAsString, safeMakeDir, writeFile, writeJsonFile } from "./tools/io-tools";
import { fileURLToPath } from 'url';
import path from 'path';
import { GlobalLuaModel } from "../models/global-lua-model";
import { existsSync } from "fs";
import chalk from "chalk";
import prettier from 'prettier';
import { ObjectStateUnpacker } from "./object-state-unpacker";
import { generateGUIDMap } from "./tools/name-tools";

// TODO
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class Unpacker {
  private _save: Save;

  constructor(save: Save) {
    this._save = save;
    safeMakeDir(UP_DIR);
  }

  unpack() {
    /* 
      --------------------
      ---- Global Lua ----
      --------------------
    */
    console.log(chalk.cyan('--- Writing Global Lua ---'));
    this.unpackGlobalLuaScript();
    console.log(chalk.cyan('--- Done Writing Global Lua ---\n'));

    /* 
      --------------------
      ----- GUID Map -----
      --------------------
    */
    console.log(chalk.cyan('--- Generating GUID Map ---'));
    const guidMap = generateGUIDMap(this._save);
    console.log(chalk.cyan('--- Done generating GUID Map ---\n'));

    /* 
      --------------------
      -- Recursive Objs --
      --------------------
    */
    const objectStateDir = UP_DIR + 'object-states/';
    safeMakeDir(objectStateDir);
    const objectStateUnpacker = new ObjectStateUnpacker(this._save.ObjectStates, objectStateDir, guidMap);
    objectStateUnpacker.unpackAll();
  }

  unpackGlobalLuaScript() {
    try {
      fs.writeFileSync(`${UP_DIR}global.lua`, this._save.LuaScript);
      if(this._save.LuaScriptState) {
        fs.writeFileSync(`${UP_DIR}state.json`, this._save.LuaScriptState);
      }
    } catch (e) {
      console.error(e);
    }
    this.chunkGlobalLuaScript();
  }

  chunkGlobalLuaScript() {
    safeMakeDir(UP_DIR + 'global/');
    let sections: string[] = [];
    try {
      sections = readFileAsString(`${UP_DIR}global.lua`).split("\n\n\n");
    } catch (e) {
      console.error(e);
      return null;
    }
    let file: any = {};
    let chunkBufferIndex = -1;
    for(let k in sections) {
      // Next section(s) needs folder
      if(k in GlobalLuaModel) {
        // Write chunk
        let arr = []
        for(let i in [...Array(parseInt(k) - chunkBufferIndex).keys()]) {
          arr.push(sections[Math.max(chunkBufferIndex + parseInt(i), 0)]);
        }
        // TODO: Fix any
        this.writeGlobalLuaChunk((GlobalLuaModel as any)[chunkBufferIndex], arr);
        chunkBufferIndex = parseInt(k);
      }
      file['n' + k] = sections[k];
    }

    // TODO: Off by 1
    let arr = []
    arr.push(sections[chunkBufferIndex]);
    
    // TODO: Fix any
    this.writeGlobalLuaChunk((GlobalLuaModel as any)[chunkBufferIndex], arr);
    
    writeJsonFile(__dirname + '/../../unpacked/global_dump.json', file)
  }

  writeGlobalLuaChunk(folderName: string, sections: string[]) {
    safeMakeDir(`${UP_DIR}global/${folderName}`);
    for(let k in sections) {
      const fileContents = sections[k];
      const fileName = fileContents.substring(0,fileContents.indexOf('='));

      writeFile(`${UP_DIR}global/${folderName}/${getSafeNameS(fileName)}.lua`, formatLuaPrettier(fileContents));
    }
    console.log(chalk.yellow('Wrote Global Lua Chunk ') + chalk.green(folderName));
  }

  saveObjectWithoutContained(objectState: ObjectState, fileName: string) {
    const obj: Omit<ObjectState, "ContainedObjects"> = objectState;
    writeJsonFile(fileName, obj);
  }

  prepLuaTextForWrite(luaText: string) {
    return luaText.substring(1, luaText.length - 1);
  }

  createModConfig() {
    if(!fileExists(PATCH_DIR + 'mod_config.json')) {
      writeJsonFile(PATCH_DIR + 'mod_config.json', { name: "Sample_mod", filesToPatch: [] });
    }
  }
}