import { Unpacker } from "./packaging/unpacker.js";
import 'source-map-support/register.js';
import { Repacker } from "./packaging/repacker.js";
import { copyFolder, readInSaveFile } from "./packaging/tools/index.js";
import chalk from "chalk";
import { PATCH_DIR, UP_DIR } from "./models/index.js";
import { ModManager } from "./packaging/mod_manager.js";


const save = readInSaveFile();

if(save !== null) {
  const args = process.argv.slice(2);
  for(const arg of args) {
    switch(arg) {
      case '--pack': {
        console.log(chalk.cyan('Packing patch/ and unpacked/ folders...'));
        const repacker = new Repacker(save);
        repacker.repack();
        break;
      }
      case '--unpack': {
        const unpacker = new Unpacker(save);
        unpacker.unpack();
        break;
      }
      case '--create-patch': {
        copyFolder(UP_DIR, PATCH_DIR);
        console.log(chalk.green('Success! Copied unpacked/ folder to patch/ folder, without overwriting any existing files in patch/'));
        break;
      }
      case '--init-mod': {
        const modManager = new ModManager(save);
        modManager.createModConfig();
        console.log(chalk.green('Success! Created mod_config.json in mod/ folder. Add files to "filesToPatch" then run "npm run sync-mod" to fill mod/ with these files from patch/'));
      }
      case '--sync-mod': {
        
      }
    }
  }
} else {
  console.log(chalk.red('Could not load in save file. Exiting...'));
}
