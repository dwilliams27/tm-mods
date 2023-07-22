import { FriendlyObjectState, GUIDMap, GUIDNode } from "../../models/custom-models";
import { GUIDState, ObjectState, Save } from "../../models/game-models";

export function generateObjectStateFolderName(state: GUIDState) {
  return (state.Name + (state.Nickname ? state.Nickname : '')).replace(/[\/]+/g, '-') + '/';
}

// TODO: How to preserve order for repacking?
export function generateFriendlyNameMap(states: ObjectState): FriendlyObjectState[] {
  const existingNames = {};

  return [];
}

export function generateGUIDMap(save: Save) {
  const map: GUIDMap = {};
  const node = {
    parent: null,
    index: 0,
    children: [],
    guid: 'ROOT',
    uguid: 'ROOT'
  };
  map['ROOT'] = node;

  generateGUIDMapHelper({ GUID: 'ROOT', Name: 'ROOT', ContainedObjects: save.ObjectStates }, map, node, {});
  return map;
}

function generateGUIDMapHelper(state: ObjectState, map: GUIDMap, node: GUIDNode, duplicates: { [key: string]: number }) {
  if(state.ContainedObjects) {
    state.ContainedObjects.forEach((obj, index) => {
      let uguid = obj.GUID;
      if(uguid in map) {
        console.log('Duplicate GUID found: ' + uguid);
        if(uguid in duplicates) {
          duplicates[uguid] += 1;
        } else {
          duplicates[uguid] = 0;
        }
        uguid += duplicates[uguid];
      }
      map[obj.GUID] = {
        guid: obj.GUID,
        uguid,
        index,
        parent: node,
        children: []
      };
      node.children.push(map[obj.GUID]);

      generateGUIDMapHelper(obj, map, map[obj.GUID], duplicates);
    });
  }
  return node;
}