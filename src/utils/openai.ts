import chalk from "chalk";
import OpenAI from "openai";
import { formatLuaPrettier, readFileAsString, safeMakeDir, writeFile } from "./io-tools.js";
import { MOD_DIR } from "../models/index.js";

const model = "gpt-4-0125-preview";
const modelLore = `You are a critically important assitant that needs to generate LUA type definitions.
You will be given the contents of a LUA file. The types you generate should be as accurate as possible.
The types you generate should also exactly match the objects they are describing. DO NOT output anything except the types.`;
const pricePerInputToken = 0.00001; // As of March 2024 for gpt-4-0125-preview
const pricePerOutputToken = 0.00003; // As of March 2024 for gpt-4-0125-preview

export default class OpenAIService {
  private _openAI: OpenAI;

  constructor(file: string) {
    if (!file) {
      console.log(chalk.red('Error: You must provide a file'));
      throw new Error('You must provide a file');
    }
    this._openAI = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
  }

  async generateTypesForLUA(filePath: string, fileContents: string) {
    const fileName = filePath.substring(filePath.lastIndexOf('/') + 1);
    console.log(chalk.red('Consulting with the Oracle...'));
    const completion = await this._openAI.chat.completions.create({
      messages: [
        { 'role': 'system', 'content': modelLore },
        { 'role': 'user', 'content': fileContents },
      ],
      model,
    });

    const result = completion.choices[0].message.content;

    if (!result) {
      console.log(chalk.red('Error: No result from OpenAI'));
      throw new Error('No result from OpenAI');
    }

    const withoutExtension = fileName.substring(0, fileName.lastIndexOf('.'));
    writeFile(`${MOD_DIR}types/${withoutExtension}.txt`, result);
    // Stip formatting
    const cleanResult = result.replace(/```lua/g, '').replace(/```/g, '');
    writeFile(`${MOD_DIR}types/${withoutExtension}.lua`, formatLuaPrettier(cleanResult));
  }

  async estimateCost(fileContents: string) {
    const content = modelLore + fileContents;
  
    // Rough average length of a token in characters.
    const averageTokenLength = 4;

    // Remove extra spaces to improve count accuracy.
    const trimmedText = content.replace(/\s+/g, ' ');

    // Estimate token count.
    const estimatedInputTokenCount = Math.ceil(trimmedText.length / averageTokenLength);
    const estimatedOutputTokenCount = 0.1 * estimatedInputTokenCount;

    // Estimate cost.
    const inputCost = (estimatedInputTokenCount * pricePerInputToken);
    const outputCost = (estimatedOutputTokenCount * pricePerOutputToken);

    console.log(chalk.cyan('Very rough estimate of cost for type generation:'));
    console.log(chalk.yellow(`Input: ~~${estimatedInputTokenCount} tokens, $${inputCost.toFixed(2)}`));
    console.log(chalk.yellow(`Output: ~~${estimatedOutputTokenCount} tokens, $${outputCost.toFixed(2)}`));
    console.log(chalk.green(`Total Cost: $${(inputCost + outputCost).toFixed(2)}`));
  }
}
