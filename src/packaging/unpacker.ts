import { ObjectState, Save, UP_DIR } from "../models";
import * as fs from 'fs';
import { getSafeName, safeMakeDir, writeJsonFile } from "./ioTools";

export class Unpacker {
  private save: Save;

  constructor(save: Save) {
    this.save = save;
    safeMakeDir(UP_DIR);
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
        try {
          fs.writeFileSync(cardFolder + safeCorpName + '.lua', this.prepLuaTextForWrite(content.LuaScript));
        } catch (e) {
          console.error(e);
        }
        
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