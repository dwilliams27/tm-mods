import { FriendlyObjectState, GUIDMap, GUIDNode, GUIDState, ObjectState, Save } from "../../models/index.js";

export const MAX_FRIENDLY_NAME_LEN = 30;

export function generateObjectStateFolderName(state: GUIDState) {
  let name = (state.Name + (state.Nickname ? state.Nickname : ''))
    .replace(/[\/]+/g, '-')
    .replace(/[ ]+/g, '_');
  if(name.length > MAX_FRIENDLY_NAME_LEN) {
    name = name.substring(0, MAX_FRIENDLY_NAME_LEN);
  }
  return name;
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

  generateGUIDMapHelper({ GUID: 'ROOT', Name: 'ROOT', ContainedObjects: save.ObjectStates }, map, node);
  return map;
}

function generateGUIDMapHelper(state: ObjectState, map: GUIDMap, node: GUIDNode) {
  if(state.ContainedObjects) {
    state.ContainedObjects.forEach((obj, index) => {
      let uguid = obj.GUID;
      if(uguid in map) {
        console.log('Duplicate GUID found: ' + uguid);
        console.log('Appending description to key (Will fail if duplicate descriptions as well)');
        uguid = generateUniqueGUID(state);
      }
      map[obj.GUID] = {
        guid: obj.GUID,
        uguid,
        index,
        parent: node,
        children: []
      };
      node.children.push(map[obj.GUID]);

      generateGUIDMapHelper(obj, map, map[obj.GUID]);
    });
  }
  return node;
}

// TODO: Kinda hackey, since a few edge cases with GUIDs not being unique
export function generateUniqueGUID(state: ObjectState) {
  return state.GUID + (state.Description ? '%' + (state.Description.length > 5 ? state.Description.substring(0,5) : state.Description) : '');
}