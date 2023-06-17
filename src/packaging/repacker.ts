import chalk from 'chalk';
import { mkdirSync } from 'fs'
import { ObjectState, PATCH_DIR, RP_DIR, Save, UP_DIR } from '../models';
import { GlobalLuaModel } from '../models/globalLuaModel';
import { getFileList, getFolderList, getSafeName, readFileAsString, readInFolder, readJSONFile, safeMakeDir, setObjectStateByNickname, writeJsonFile } from './ioTools';

export class Repacker {
  private save: Save;

  constructor(save: Save) {
    this.save = save;
    safeMakeDir(RP_DIR);
  }

  // TODO: Patch not working for global lua
  repack(repackFromPatch: boolean = false) {
    /* 
      --------------------
      --- Corporations ---
      --------------------
    */
    this.repackCorporations(repackFromPatch);

    /* 
      --------------------
      ---- Global Lua ----
      --------------------
    */
    this.repackGlobalLua(false);

    // Repack save.json
    console.log(chalk.cyan('Packing save file ') + chalk.yellow(RP_DIR + 'save_output.json'));
    writeJsonFile(RP_DIR + 'save_output.json', this.save);
    console.log(chalk.green('Repacking complete! Replace save in Tabletop Simulator/Mods/Workshop'));
  }

  repackCorporations(repackFromPatch: boolean) {
    // TODO: Packs back in wrong order
    safeMakeDir(RP_DIR + '/corporations');
    const sourceFolder = repackFromPatch ? PATCH_DIR : UP_DIR;
    const folderPath = sourceFolder + '/corporations';
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
    const corpDeckObjectState: ObjectState = readJSONFile(sourceFolder + '/corporations/corporations.json');
    const deckFilePath = RP_DIR + 'corporations/' + getSafeName(corpDeckObjectState) + '.json';
    corpDeckObjectState.ContainedObjects = containedObjects.sort((a, b) => {
      const aIndex = corpDeckObjectState.DeckIDs.findIndex((value) => parseInt(a.CardID) === value);
      const bIndex = corpDeckObjectState.DeckIDs.findIndex((value) => parseInt(b.CardID) === value);
      return aIndex < bIndex ? -1 : 1;
    });
    console.log(chalk.cyan('Packing file ') + chalk.yellow(deckFilePath));
    writeJsonFile(deckFilePath, corpDeckObjectState);

    setObjectStateByNickname(this.save, 'Corporations', corpDeckObjectState);
  }

  repackGlobalLua(repackFromPatch: boolean) {
    safeMakeDir(RP_DIR + '/global');
    let res = '';
    const sourceFolder = repackFromPatch ? PATCH_DIR : UP_DIR;
    const folderPath = sourceFolder + '/global';

    for(let k in GlobalLuaModel) {
      const dir = `${folderPath}/${(GlobalLuaModel as any)[k]}`;
      const files = readInFolder(dir);
      res += '\n\n\n' + files.join('\n\n\n');
    }
    console.log(chalk.cyan('Packing global lua script'));
    this.save.LuaScript = res;
  }
}
