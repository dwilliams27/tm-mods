import { Unpacker } from "./packaging/unpacker";
import 'source-map-support/register';
import { Repacker } from "./packaging/repacker";
import { Save } from "./models";
import { readInSaveFile } from "./packaging/ioTools";


const save = readInSaveFile();

if(save !== null) {
  const unpacker = new Unpacker(save);
  unpacker.findAndUnpackBaseCorpDeck();
  const repacker = new Repacker(save);
  repacker.repackCorporationDeck();
}
