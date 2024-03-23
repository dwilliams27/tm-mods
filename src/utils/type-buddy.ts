import chalk from "chalk";
import readline from 'readline';
import OpenAIService from "./openai.js";
import { readFileAsString, safeMakeDir, writeFile } from "./io-tools.js";
import { MOD_DIR } from "../models/index.js";
import ASTWrapper from "./ast-wrapper.js";

// Generates types for a LUA file using OpenAI's GPT-4 model.
export default class TypeBuddy {
  private _openAIService: OpenAIService;
  private _astWrapper: ASTWrapper;

  private _rawInputLua: string;
  private _filePath: string;
  private _fileName: string;

  constructor(file: string) {
    safeMakeDir(`${MOD_DIR}types/`);
    this._openAIService = new OpenAIService(file);
    this._rawInputLua = readFileAsString(file);
    this._filePath = file;
    this._fileName = file.substring(file.lastIndexOf('/') + 1);
    this._astWrapper = new ASTWrapper(this._fileName, this._rawInputLua);
  }

  async initLuaTypeGenerationFlow() {
    // Should happen after ai response, move later
    this.analyzeLuaFile();

    // Setup readline for user input
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    this._openAIService.estimateCost(this._rawInputLua);

    const question = (query: string) => new Promise((resolve) => rl.question(query, resolve));
    try {
      // Await user input
      const userInput = await question('Proceed? y/n\n');
      if (userInput !== 'y') {
        console.log(chalk.red('Exiting...'));
        return false;
      }
    } finally {
      rl.close(); // Make sure to close the readline interface
    }

    await this._openAIService.generateTypesForLUA(this._filePath, this._rawInputLua);

    return true;
  }

  analyzeLuaFile() {
    this._astWrapper.generateAST();
  }
}
