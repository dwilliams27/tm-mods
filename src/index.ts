import { Unpacker } from "./packaging/unpacker.js";
import 'source-map-support/register.js';
import { Repacker } from "./packaging/repacker.js";
import { copyFolderOrFile, readInSaveFile } from "./packaging/tools/index.js";
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
        console.log(chalk.green('Success! Mod repacked'));
        break;
      }
      case '--unpack': {
        const unpacker = new Unpacker(save);
        unpacker.unpack();
        console.log(chalk.green('Success! Mod unpacked'));
        break;
      }
      case '--init-mod': {
        const modManager = new ModManager(save);
        modManager.createModConfig();
        console.log(chalk.green('Success! Created mod_config.json in mod/ folder. Add files to "filesToPatch" then run "npm run sync-mod" to fill mod/ with these files from unpacked/'));
        break;
      }
      case '--sync-mod': {
        const modManager = new ModManager(save);
        modManager.syncModFiles();
        console.log(chalk.green(`Success! Synced files from mod_config.json's "filesToPatch" to mod/ folder (without replacing existing files)`));
        break;
      }
    }
  }
} else {
  console.log(chalk.red('Could not load in save file. Exiting...'));
}
