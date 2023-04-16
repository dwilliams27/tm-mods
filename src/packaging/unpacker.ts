import { ObjectState, Save } from "../models";
import * as fs from 'fs';

export const UP_DIR = __dirname + '\\..\\unpacked\\';

export class Unpacker {
  private save: Save;

  constructor(filePath: string) {
    const data = fs.readFileSync(__dirname + '\\..\\..\\saves\\2104525488.json');
    this.save = JSON.parse(data.toString());
    fs.mkdirSync(UP_DIR);
    this.findAndUnpackBaseCorpDeck();
  }

  findAndUnpackBaseCorpDeck() {
    for(let objectState of this.save.ObjectStates) {
      if(objectState.Nickname === 'Corporations') {
        this.unpackDeckToFolder(objectState);
      }
    }
  }

  unpackDeckToFolder(objectState: ObjectState, prefix?: string) {
    // Use nickname as folder name, spaces to _
    const folderName = (prefix ? prefix : '') + objectState.Nickname.replace(' ', '_');
    const destinationDir = UP_DIR + folderName;
    fs.mkdirSync(destinationDir);
    for(let obj of objectState.ContainedObjects) {
      const cardFolder = destinationDir + '\\' + obj.GUID + '\\';
      fs.mkdirSync(cardFolder);
      
      let content: ObjectState = obj;
      if(content.LuaScript !== '') {
        try {
          fs.writeFileSync(cardFolder + 'card_script.lua', this.prepLuaTextForWrite(content.LuaScript));
        } catch (e) {
          console.error(e);
        }
        
        content.LuaScript = './card_script.lua';
      }

      try {
        this.writeJsonFile(cardFolder + content.Nickname.replace(/[^a-z0-9]/gi, '_').toLowerCase() + '.json', content);
      } catch (e) {
        console.error(e);
      }
    }
  }

  unpackObjectState(objectState: ObjectState) {
    
  }

  writeJsonFile(filePath: string, content: any) {
    const data = JSON.stringify(content);
    fs.writeFileSync(filePath, data);
  }

  prepLuaTextForWrite(luaText: string) {
    return luaText.substring(1, luaText.length - 1);
  }
}