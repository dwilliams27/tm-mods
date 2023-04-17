import chalk from 'chalk';
import { mkdirSync } from 'fs'
import { ObjectState, RP_DIR, Save, UP_DIR } from '../models';
import { getFileList, getFolderList, getSafeName, readFileAsString, readJSONFile, safeMakeDir, writeJsonFile } from './ioTools';

export class Repacker {
  private save: Save;

  constructor(save: Save) {
    this.save = save;
    safeMakeDir(RP_DIR);
  }

  repackCorporationDeck() {
    safeMakeDir(RP_DIR + '/corporations');
    const folderPath = UP_DIR + '/corporations';
    const folderList = getFolderList(folderPath);
    const containedObjects: ObjectState[] = []; 
  
    for(let folder of folderList) {
      const corpFiles = getFileList(folderPath + '/' + folder);
      
      if(corpFiles.length == 1) {
        // No LUA script
        containedObjects.push(readJSONFile(folderPath + '/' + folder + '/' + corpFiles[0]));
      } else {
        // Has LUA script
        const luaIndex = corpFiles[0].charAt(-1) === 'a' ? 0 : 1;
        // Get non-lua file
        const corpObj: ObjectState = readJSONFile(folderPath + '/' + folder + '/' + corpFiles[corpFiles.length - luaIndex - 1]);
  
        corpObj.LuaScript = readFileAsString(folderPath + '/' + folder + '/' + corpFiles[luaIndex]);
  
        console.log(chalk.cyan('Writing to ') + chalk.yellow(getSafeName(corpObj)));
        writeJsonFile(RP_DIR + 'corporations/' + getSafeName(corpObj) + '.json', corpObj);
      }
    }
  }
}
