import { Unpacker } from "./packaging/unpacker";
import 'source-map-support/register';
import { Repacker } from "./packaging/repacker";
import { copyFolder, readInSaveFile } from "./packaging/ioTools";
import chalk from "chalk";
import { PATCH_DIR, UP_DIR } from "./models";


const save = readInSaveFile();

if(save !== null) {
  const args = process.argv.slice(2);
  for(const arg of args) {
    switch(arg) {
      case '-pack': {
        console.log(chalk.cyan('Packing unpacked/ folder...'));
        const repacker = new Repacker(save);
        repacker.repack();
        break;
      }
      case '-packFromPatch': {
        console.log(chalk.cyan('Packing patch/ folder...'));
        const repacker = new Repacker(save);
        repacker.repack(true);
        break;
      }
      case '-unpack': {
        const unpacker = new Unpacker(save);
        unpacker.findAndUnpackBaseCorpDeck();
        unpacker.unpackGlobalLuaScript();
        break;
      }
      case '-createPatch': {
        copyFolder(UP_DIR, PATCH_DIR);
        console.log(chalk.green('Success! Copied unpacked/ folder to patch/ folder, without overwriting any existing files in patch/'));
        break;
      }
    }
  }
} else {
  console.log(chalk.red('Could not load in save file. Exiting...'));
}
