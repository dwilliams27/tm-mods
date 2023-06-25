import { ObjectState, Save, UP_DIR } from "../models";
import * as fs from 'fs';
import { findObjectStateByNickname, getSafeName, getSafeNameS, readFileAsString, safeMakeDir, writeFile, writeJsonFile } from "./ioTools";
import { fileURLToPath } from 'url';
import path from 'path';
import { GlobalLuaModel } from "../models/globalLuaModel";
import { existsSync } from "fs";
import chalk from "chalk";
import prettier from 'prettier';

// TODO
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class Unpacker {
  private save: Save;

  constructor(save: Save) {
    this.save = save;
    safeMakeDir(UP_DIR);
  }

  findAndUnpackBaseCorpDeck() {
    // Little dangerous
    const baseCorpDeck = findObjectStateByNickname(this.save, 'Corporations') as ObjectState;
    
    this.unpackDeckToFolder(baseCorpDeck);
  }

  unpackGlobalLuaScript() {
    try {
      fs.writeFileSync(`${UP_DIR}global.lua`, this.save.LuaScript);
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

      writeFile(`${UP_DIR}global/${folderName}/${getSafeNameS(fileName)}.lua`, this.formatLuaPrettier(fileContents));
    }
    console.log(chalk.yellow('Wrote Global Lua Chunk ') + chalk.green(folderName));
  }

  formatLuaPrettier(content: string) {
    try {
      return prettier.format(content, { semi: false, parser: "lua" })
    } catch(e) {
      console.error("Lua auto-formtatting failed!");
      return content;
    }
  }

  unpackDeckToFolder(objectState: ObjectState, prefix?: string) {
    // Use nickname as folder name, spaces to _
    const safeNickname = getSafeName(objectState);
    const folderName = (prefix ? prefix : '') + safeNickname;
    const destinationDir = UP_DIR + folderName;
    
    safeMakeDir(destinationDir);
    for(let obj of objectState.ContainedObjects) {
      let content: ObjectState = obj;
      const cardFolder = destinationDir + '/' + obj.GUID + '/';
      const safeCorpName = getSafeName(content);

      safeMakeDir(cardFolder);
      
      if(content.LuaScript !== '') {
        writeFile(cardFolder + safeCorpName + '.lua', this.prepLuaTextForWrite(content.LuaScript));
        
        content.LuaScript = `./${safeCorpName}.lua`;
      }

      try {
        writeJsonFile(cardFolder + safeCorpName + '.json', content);
      } catch (e) {
        console.error(e);
      }
    }

    const deckMetadata: Partial<ObjectState> = objectState;
    delete deckMetadata.ContainedObjects;
    writeJsonFile(destinationDir + '/' + safeNickname + '.json', deckMetadata);
  }

  saveObjectWithoutContained(objectState: ObjectState, fileName: string) {
    const obj: Omit<ObjectState, "ContainedObjects"> = objectState;
    writeJsonFile(fileName, obj);
  }

  prepLuaTextForWrite(luaText: string) {
    return luaText.substring(1, luaText.length - 1);
  }
}