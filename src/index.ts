import { Unpacker } from "./packaging/unpacker";
import 'source-map-support/register';
import { Repacker } from "./packaging/repacker";
import { Save } from "./models";
import { readInSaveFile } from "./packaging/ioTools";


const save = readInSaveFile();

if(save !== null) {
  if(process.argv[2] === '-pack') {
    const repacker = new Repacker(save);
    repacker.repack();
  } else if(process.argv[2] === '-unpack') {
    const unpacker = new Unpacker(save);
    unpacker.findAndUnpackBaseCorpDeck();
    unpacker.unpackGlobalLuaScript();
  }
}
