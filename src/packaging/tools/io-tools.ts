import chalk from "chalk";
import prettier from "prettier";
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "fs";
import { fileURLToPath } from 'url';
import path from 'path';
import fse from "fs-extra";
import AdmZip from 'adm-zip';
import { ObjectState, Save, UP_DIR } from "../../models";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function getFolderList(folderPath: string) {
  return readdirSync(folderPath, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory())
    .map(dirent => dirent.name);
}

export function getFileList(folderPath: string) {
  return readdirSync(folderPath, { withFileTypes: true })
    .filter(file => file.isFile())
    .map(file => file.name);
}

export function readJSONFile(folderPath: string) {
  const data = readFileSync(folderPath);
  return JSON.parse(data.toString());
}

export function readFileAsString(folderPath: string) {
  const data = readFileSync(folderPath);
  return data.toString();
}

export function writeFile(filePath: string, content: any) {
  try {
    writeFileSync(filePath, content);
  } catch (e) {
    console.error(e);
  }
}

export function writeJsonFile(filePath: string, content: any) {
  const data = JSON.stringify(content);
  writeFileSync(filePath, data);
}

export function getSafeName(objectState: ObjectState) {
  return objectState.Nickname?.replace(/[^a-z0-9]/gi, '_').toLowerCase();
}

export function getSafeNameS(str: string) {
  return str.replace(/[^a-z0-9]/gi, '_').toLowerCase();
}

export function readInSaveFile() {
  const saveFile = getFileList(UP_DIR + '../saves/').filter((file) => !file.includes('.bak'))[0];
  console.log(chalk.cyan('Reading in save file: ') + chalk.yellow(saveFile));
  let save: Save | null = null;
  try {
    save = readJSONFile(UP_DIR + '../saves/' + saveFile);
  } catch (e) {
    console.error(e);
    return null;
  }
  return save;
}

// Returns list of [fileName, fileContents]
export function readInFolder(dir: string): string[][] {
  let res: string[][] = [];
  getFileList(dir).map((file) => {
    res.push([file, readFileAsString(dir + '/' + file)])
  });
  return res;
}

export function readInFiles(dirs: string[]): string[][] {
  let res: string[][] = [];
  for(const dir of dirs) {
    res.push([dir, readFileAsString(dir)]);
  }
  return res;
}

export function safeMakeDir(dirPath: string) {
  try {
    if(!existsSync(dirPath)) {
      mkdirSync(dirPath);
    }
  } catch(e) {
    console.error(e);
  }
}

export function fileExists(filePath: string) {
  return existsSync(filePath);
}

export function copyFolder(source: string, destination: string) {
  try {
    fse.copySync(source, destination, { overwrite: false })
    return true;
  } catch (err) {
    console.error(err);
    return false;
  }  
}

// Note nickname not unique!
export function findObjectStateByNickname(save: Save, nickname: string) {
  for(let objectState of save.ObjectStates) {
    if(objectState.Nickname === nickname) {
      return objectState;
    }
  }
}

// Note nickname not unique!
export function setObjectStateByNickname(save: Save, nickname: string, objectState: ObjectState) {
  for(let index in save.ObjectStates) {
    if(save.ObjectStates[index].Nickname === nickname) {
      save.ObjectStates[index] = objectState;
      return;
    }
  }
}

export function zipFiles(files: string[], output: string) {
  const zipFile = new AdmZip();
  
  for(const file of files) {
    zipFile.addLocalFile(file);
  }

  zipFile.writeZip(output + '.zip');
}

export function formatLuaPrettier(content: string) {
  try {
    return prettier.format(content, { semi: false, parser: "lua" })
  } catch(e) {
    console.error("Lua auto-formatting failed!");
    return content;
  }
}
