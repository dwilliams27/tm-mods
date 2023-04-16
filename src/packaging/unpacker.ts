import { ObjectState, Save, UP_DIR } from "../models";
import * as fs from 'fs';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class Unpacker {
  private save: Save;

  constructor(filePath: string) {
    const data = fs.readFileSync(__dirname + '/../../saves/2104525488.json');
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
    const safeNickname = objectState.Nickname.replace(' ', '_');
    const folderName = (prefix ? prefix : '') + safeNickname;
    const destinationDir = UP_DIR + folderName;
    fs.mkdirSync(destinationDir);
    for(let obj of objectState.ContainedObjects) {
      const cardFolder = destinationDir + '/' + obj.GUID + '/';
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

    const deckMetadata: Partial<ObjectState> = objectState;
    delete deckMetadata.ContainedObjects;
    this.writeJsonFile(destinationDir + '/' + safeNickname + '.json', deckMetadata);
  }

  saveObjectWithoutContained(objectState: ObjectState, fileName: string) {
    const obj: Omit<ObjectState, "ContainedObjects"> = objectState;
    this.writeJsonFile(fileName, obj);
  }

  writeJsonFile(filePath: string, content: any) {
    const data = JSON.stringify(content);
    fs.writeFileSync(filePath, data);
  }

  prepLuaTextForWrite(luaText: string) {
    return luaText.substring(1, luaText.length - 1);
  }
}