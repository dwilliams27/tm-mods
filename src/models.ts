import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export interface Save {
  SaveName: string,
  EpochTime: string,
  Date: string,
  VersionNumber: string,
  GameMode: string,
  GameType: string,
  GameComplexity: string,
  PlayingTime: number[],
  PlayerCounts: number[],
  Tags: string[],
  Gravity: number,
  PlayArea: number,
  Table: number,
  TableURL: string,
  Sky: string,
  SkyURL: string,
  Node: string,
  TabStates: {[key: string]: TabState}
  Grid: Grid,
  Lighting: any,
  Hands: any,
  ComponentTags: any,
  Turns: any,
  CameraStates: any,
  DecalPallet: any,
  LuaScript: string,
  LuaScriptState: string,
  XmlUI: string,
  ObjectStates: ObjectState[]
}

export interface ObjectState {
  GUID: string,
  Name: string,
  Transform: Transform,
  Nickname: string,
  Description: string,
  GMNotes: string,
  AltLookAngle: XYZ,
  ColorDiffuse: RGBA,
  LayoutGroupSortIndex: number,
  Value: number,
  Locked: boolean,
  Grid: boolean,
  Snap: boolean,
  IgnoreFoW: boolean,
  MeasureMovement: boolean,
  DragSelectable: boolean,
  Autoraise: boolean,
  Sticky: boolean,
  Tooltip: boolean,
  GridProjection: boolean,
  HideWhenFaceDown: boolean,
  Hands: boolean,
  CardID: string,
  SidewaysCard: boolean,
  DeckIDs: number[],
  CustomDeck: { [key: string]: { 
    FaceURL: string, 
    BackURL: string, 
    NumWidth: number, 
    NumHeight: number, 
    BackIsHidden: boolean, 
    UniqueBack: boolean, 
    Type: number 
  } }
  FogColor: string,
  LuaScript: string,
  LuaScriptState: string,
  XmlUI: string
  ContainedObjects: ObjectState[]
}

export interface XYZ {
  x: number,
  y: number,
  z: number
}

export interface RGB {
  r: number,
  g: number,
  b: number
}

export interface RGBA extends RGB {
  a: number
}

export interface Transform {
  posX: number,
  posY: number,
  posZ: number,
  rotX: number,
  rotY: number,
  rotZ: number,
  scaleX: number,
  scaleY: number,
  scaleZ: number
}

export interface TabState {
  title: string,
  body: string,
  color: string,
  visibleColor: any,
  id: number
}

export interface Grid {
  Type: number,
  Lines: boolean,
  Color: any,
  Opacity: number,
  ThickLines: boolean,
  Snapping: boolean,
  Offset: boolean,
  BothSnapping: boolean,
  xSize: number,
  ySize: number,
  PosOffset: any
}

export interface ModConfig {
  name: string,
  description?: string,
  filesToPatch: string[]
}

export const UP_DIR = __dirname + '/../unpacked/';

export const RP_DIR = __dirname + '/../repacked/';

export const PATCH_DIR = __dirname + '/../patch/';
