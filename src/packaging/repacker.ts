import chalk from 'chalk';
import { mkdirSync } from 'fs'
import { ObjectState, RP_DIR, Save, UP_DIR } from '../models';
import { getFileList, getFolderList, getSafeName, readFileAsString, readJSONFile, safeMakeDir, setObjectStateByNickname, writeJsonFile } from './ioTools';

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
        const corpObj: ObjectState = readJSONFile(folderPath + '/' + folder + '/' + corpFiles[0]);
        console.log(chalk.cyan('Adding corp ') + chalk.yellow(getSafeName(corpObj)));
        containedObjects.push(corpObj);
      } else {
        // Has LUA script
        const luaIndex = corpFiles[0].charAt(-1) === 'a' ? 0 : 1;
        // Get non-lua file
        const corpObj: ObjectState = readJSONFile(folderPath + '/' + folder + '/' + corpFiles[corpFiles.length - luaIndex - 1]);
  
        corpObj.LuaScript = readFileAsString(folderPath + '/' + folder + '/' + corpFiles[luaIndex]);
  
        console.log(chalk.cyan('Adding corp ') + chalk.yellow(getSafeName(corpObj)));
        containedObjects.push(corpObj);
      }
    }
    const corpDeckObjectState: ObjectState = readJSONFile(UP_DIR + '/corporations/corporations.json');
    const deckFilePath = RP_DIR + 'corporations/' + getSafeName(corpDeckObjectState) + '.json';
    corpDeckObjectState.ContainedObjects = containedObjects;
    console.log(chalk.cyan('Packing file ') + chalk.yellow(deckFilePath));
    writeJsonFile(deckFilePath, corpDeckObjectState);

    setObjectStateByNickname(this.save, 'Corporations', corpDeckObjectState);
    
    // Repack save.json
    console.log(chalk.cyan('Packing save file ') + chalk.yellow(RP_DIR + 'save_output.json'));
    writeJsonFile(RP_DIR + 'save_output.json', this.save);
    console.log(chalk.green('Repacking complete! Replace save in Tabletop Simulator/Mods/Workshop'));
  }
}
