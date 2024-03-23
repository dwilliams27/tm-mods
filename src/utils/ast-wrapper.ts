import luaparse from 'luaparse';
import { writeJsonFile } from './io-tools.js';
import { MOD_DIR } from '../models/index.js';

export default class ASTWrapper {
  private _fileName: string;
  private _inputLua: string;

  private _ast: any;

  constructor(fileName: string, lua: string) {
    this._fileName = fileName;
    this._inputLua = lua;
  }

  generateAST() {
    this._ast = luaparse.parse(this._inputLua, {
      onCreateNode: (node) => {
        console.log(node.type);
        console.log(node);
      },
      locations: true,
      scope: true,
    });
    writeJsonFile(`${MOD_DIR}types/${this._fileName.substring(0, this._fileName.lastIndexOf('.'))}.ast.json`, this._ast);
  }
}
