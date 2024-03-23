import chalk from "chalk";
import { Unpacker } from "./packaging/unpacker.js";
import 'source-map-support/register.js';
import { Repacker } from "./packaging/repacker.js";
import { readInSaveFile } from "./utils/index.js";
import { ModManager } from "./packaging/mod-manager.js";
import OpenAIService from "./utils/openai.js";
import TypeBuddy from './utils/type-buddy.js';


const save = readInSaveFile();

if(save !== null) {
  const args = process.argv.slice(2);
  const command = args[0];
  const commandArgs = args.slice(1);

  switch(command) {
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
      const modManager = new ModManager();
      modManager.createModConfig();
      console.log(chalk.green('Success! Created mod_config.json in mod/ folder. Add files to "filesToPatch" then run "npm run sync-mod" to fill mod/ with these files from unpacked/'));
      break;
    }
    case '--sync-mod': {
      const modManager = new ModManager();
      modManager.syncModFiles();
      console.log(chalk.green(`Success! Synced files from mod_config.json's "filesToPatch" to mod/ folder (without replacing existing files)`));
      break;
    }
    case '--ai-gen-types': {
      if (commandArgs.length === 0) {
        console.log(chalk.red('Error: Please provide a lua file to generate types for'));
        break;
      }
      
      const tb = new TypeBuddy(commandArgs[0]);
      const success = await tb.initLuaTypeGenerationFlow();
      
      if (success) {
        console.log(chalk.green(`Success! Attempted type generation for lua file ${commandArgs[0]}. Output results to mod/types/`));
      }
      break;
    }
  }
} else {
  console.log(chalk.red('Could not load in save file. Exiting...'));
}
