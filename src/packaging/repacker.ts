import chalk from 'chalk';
import path from 'path';
import {
  ModConfig,
  ObjectState,
  PATCH_DIR,
  RP_DIR,
  Save,
  UP_DIR,
  GlobalLuaModel
} from '../models/index.js';
import {
  getFileList,
  getFolderList,
  getSafeName,
  readFileAsString,
  readInFiles,
  readInFolder,
  readJSONFile,
  safeMakeDir,
  setObjectStateByNickname,
  writeJsonFile,
  zipFiles 
} from './tools/index.js';

export class Repacker {
  private save: Save;
  private modConfig: ModConfig;

  constructor(save: Save) {
    this.save = save;
    this.modConfig = readJSONFile(`${PATCH_DIR}mod_config.json`);
    this.save.SaveName = this.modConfig.name;
    safeMakeDir(RP_DIR);
  }

  // TODO: Patch + Unpacked merge not implemented for Corps; Just pulling from unpacked now
  repack() {
    /* 
      --------------------
      --- Corporations ---
      --------------------
    */
    // this.repackCorporations(false);

    /* 
      --------------------
      ---- Global Lua ----
      --------------------
    */
    this.repackGlobalLua(this.modConfig.filesToPatch);

    /* 
      --------------------
      - Repack save.json -
      --------------------
    */
    console.log(chalk.cyan('Packing save file ') + chalk.yellow(path.resolve(RP_DIR + 'save_output.json')));
    writeJsonFile(`${RP_DIR}${this.modConfig.name}.json`, this.save);
    console.log(chalk.green('Repacking complete! Replace save in ~/Library/Tabletop Simulator/Saves'));
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
    // corpDeckObjectState.ContainedObjects = containedObjects.sort((a, b) => {
    //   const aIndex = corpDeckObjectState.DeckIDs?.findIndex((value) => parseInt(a.CardID ?? '') === value);
    //   const bIndex = corpDeckObjectState.DeckIDs?.findIndex((value) => parseInt(b.CardID ?? '') === value);
    //   return aIndex < bIndex ? -1 : 1;
    // });
    console.log(chalk.cyan('Packing file ') + chalk.yellow(path.resolve(deckFilePath)));
    writeJsonFile(deckFilePath, corpDeckObjectState);

    setObjectStateByNickname(this.save, 'Corporations', corpDeckObjectState);
  }

  repackGlobalLua(filesToPatch: string[]) {
    safeMakeDir(RP_DIR + 'global');
    let res = '';
    const unpackedFolderPath = UP_DIR + 'global';

    const patchFiles = readInFiles(filesToPatch.map(((file) => PATCH_DIR + file)));
    const fileSet: { [key: string]: string} = {};
    for(const patchFile of patchFiles) {
      fileSet[patchFile[0].substring(patchFile[0].lastIndexOf('/') + 1)] = patchFile[1];
    }

    const modContents: string[] = [];
    modContents.push(PATCH_DIR + 'mod_config.json');
    modContents.push(PATCH_DIR + 'global/state.json');

    this.modConfig = readJSONFile(PATCH_DIR + 'mod_config.json');

     
    // TODO: 'Patching file' printed too many times
    for(const k in GlobalLuaModel) {
      const unpackedFiles = readInFolder(`${unpackedFolderPath}/${(GlobalLuaModel as any)[k]}`);
      for(const unpackedFile of unpackedFiles) {
        if(!(unpackedFile[0] in fileSet)) {
          // process.stdout.write(chalk.cyan('Packing with file ') + chalk.yellow(path.resolve(unpackedFile[0])) + '\r');
          res += '\n\n\n' + unpackedFile[1];
        } else {
          console.log(chalk.cyan('Patching file ') + chalk.yellow(unpackedFile[0]));

          res += '\n\n\n' + fileSet[unpackedFile[0]];
          modContents.push(`${unpackedFolderPath}/${(GlobalLuaModel as any)[k]}/${unpackedFile[0]}`);

          // delete fileSet[unpackedFile[0]]
        }
      }
    }
    console.log(chalk.cyan('Packing global lua script'));
    
    this.createPortableModZip(modContents, this.modConfig.name);

    this.save.LuaScript = res;
  }

  createPortableModZip(paths: string[], filename: string) {
    console.log(chalk.cyan('Created mod zip at ') + chalk.yellow(path.resolve(RP_DIR + filename) + '.zip'));
    zipFiles(paths, path.resolve(RP_DIR + filename));
  }
}
