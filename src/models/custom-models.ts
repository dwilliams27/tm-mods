import { ObjectState } from "./game-models";

export interface FriendlyObjectState extends ObjectState {
  friendlyName: string
}

export interface GUIDNode {
  guid: string,
  uguid: string,
  index: number,
  children: GUIDNode[], // Order must be preserved!
  parent: GUIDNode | null
}

export interface GUIDMap { [key: string]: GUIDNode; }
