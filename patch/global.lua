-- Script version that clears save data if not identical
scriptVersion=11

gameObjectGuidStores=gameObjectGuidStores or {}
gameObjectHelpers=gameObjectHelpers or {}
gameObjectHelpers.getGuidByName=function(name)
for _,store in pairs(gameObjectGuidStores) do
if store[name]~=nil then
return store[name]
end
end
return nil
end
gameObjectHelpers.getObjectByName=function(name)
local guid=gameObjectHelpers.getGuidByName(name)
if guid~=nil then
return getObjectFromGUID(guid)
end
return nil
end
gameObjectHelpers.addDecks=function(deckToAddTo,deckToAdd)
local deckToAddObj=gameObjectHelpers.getObjectByName(deckToAdd)
if deckToAddObj==nil then
logging.broadcastToAll("Did not find deck "..deckToAdd..",may have been already added to "..deckToAddTo..". Doing nothing.")
return
end
gameObjectHelpers.getObjectByName(deckToAddTo).putObject(deckToAddObj)
end
gameObjectHelpers.cleanOutDeck=function(deckToCleanOut,guidsToRemove,skip)
if skip then
return
end
for _,guid in pairs(guidsToRemove) do
local deck=gameObjectHelpers.getObjectByName(deckToCleanOut)
deck.takeObject({guid=guid,position={-53.30,-6.8,-64.37},rotation={180,270,0}})
end
end
gameObjectHelpers.removeObjGracefully=function(guid)
local obj=getObjectFromGUID(guid)
if obj~=nil then
if obj.getVar("selfDestruct") then
obj.call("selfDestruct")
else
obj.destruct()
end
end
end


tableHelpers=tableHelpers or {}
tableHelpers.getIndexInTable=function(tableToCheck,value)
for i,tableValue in pairs(tableToCheck) do
if tableValue==value then
return i
end
end
return nil
end
tableHelpers.removeValueFromTable=function(tableToCheck,value)
index=tableHelpers.getIndexInTable(tableToCheck,value)
while index~=nil do
table.remove(tableToCheck,index)
index=tableHelpers.getIndexInTable(tableToCheck,value)
end
end
tableHelpers.isValueInTable=function(tableToCheck,value)
return tableHelpers.getIndexInTable(tableToCheck,value)~=nil
end
tableHelpers.contains=function(tableToCheck,value)
return tableHelpers.isValueInTable(tableToCheck,value)
end
tableHelpers.isTableValueInTable=function(tableToCheck,tableValue,predicate)
for _,entry in pairs(tableToCheck) do
if predicate(entry,tableValue) then
return true
end
end
return false
end
tableHelpers.getCount=function(tableToCheck)
local count=0
for _,entry in pairs(tableToCheck) do
count=count + 1
end
return count
end
tableHelpers.getKeyValueFromIndex=function(tableToCheck,index)
local count=1
local result={}
for key,value in pairs(tableToCheck) do
if count==index then
result[key]=value
return result
end
count=count + 1
end
return nil
end
tableHelpers.removeKeyValuePairByIndex=function(tableToCheck,index)
local count=1
for key,value in pairs(tableToCheck) do
if count==index then
tableToCheck[key]=nil
return
end
count=count + 1
end
end
tableHelpers.combineSingleValueTables=function(tablesList)
local combinedTable={}
local index=1
for _,table in ipairs(tablesList) do
for _,tableEntry in ipairs(table) do
combinedTable[index]=tableEntry
index=index + 1
end
end
return combinedTable
end
tableHelpers.cloneTable=function(table)
local copy={}
for key,value in pairs(table) do
copy[key]=value
end
return copy
end
tableHelpers.cloneTableRecursively=function(table)
return tableHelpers.deepCloneTable(table)
end
tableHelpers.deepClone=function(table)
return tableHelpers.deepCloneTable(table)
end
tableHelpers.deepCloneTable=function(table)
if type(table)~="table" then
return table
end
local copy={}
for key,value in pairs(table) do
if type(value)=="table" then
copy[key]=tableHelpers.deepCloneTable(value)
else
copy[key]=value
end
end
return copy
end
tableHelpers.getHashLength=function(table)
local index=0
for i,_ in pairs(table) do
index=index + 1
end
return index
end
tableHelpers.findNearestMatch=function(table,targetValue)
local closestMatch={index=1,fitness=math.abs(table[1] - targetValue),value=table[1]}
for index,value in pairs(table) do
if math.abs(targetValue - value) < closestMatch.fitness then
closestMatch={index=index,fitness=math.abs(targetValue - value),value=value}
end
end
return closestMatch
end
tableHelpers.changeNumericValue=function(tableIn,tableKey,delta,lowerLimit,upperLimit,rollOver)
rollOver=rollOver or false
tableIn[tableKey]=tableIn[tableKey] + delta
if not rollOver then
if lowerLimit and tableIn[tableKey] < lowerLimit then
tableIn[tableKey]=lowerLimit
elseif upperLimit and tableIn[tableKey] > upperLimit then
tableIn[tableKey]=upperLimit
end
if math.abs(tableIn[tableKey]) < 10e-4 then
tableIn[tableKey]=0
end
else
if lowerLimit and tableIn[tableKey] < lowerLimit then
tableIn[tableKey]=upperLimit
elseif upperLimit and tableIn[tableKey] > upperLimit then
tableIn[tableKey]=lowerLimit
end
end
end
tableHelpers.getValueFromString=function(inputString,includeSubResults)
local result={}
local tmp1=nil
local tmp2=nil
local level=1
local atStart=true
inputString,returnTableSize=inputString:gsub("#","")
for subString in string.gmatch(inputString,"[^%.]+") do
if atStart then
result[1]=Global.getVar(subString)
atStart=false
elseif result~=nil then
if string.match(subString,"%[")~=nil then
local counter=1
for sub in string.gmatch(subString,"[^%[]+") do
if counter==1 then
result[level]=result[level][sub]
else
level=level + 1
if string.match(sub,"%]")~=nil then
sub,count=sub:gsub("%]","")
result[level]=Global.getVar(sub)
if result[level]==nil then result[level]=tonumber(sub) end
for i=count,1,-1 do
level=level - 1
result[level]=result[level][result[level + 1]]
end
else
result[level]=Global.getVar(sub)
end
end
counter=counter + 1
end
elseif string.match(subString,"%]")~=nil then
subString,count=subString:gsub("%]","")
result[level]=result[level][subString]
for i=count,1,-1 do
level=level - 1
result[level]=result[level][result[level + 1]]
end
else
result[level]=result[level][subString]
end
end
if result[level]==nil then return nil end
end
if includeSubResults then
return result
elseif returnTableSize~=0 then
return tableHelpers.getCount(result[1])
else
return result[1]
end
end


bagProtector=bagProtector or {}
bagProtectorGuidStores=bagProtectorGuidStores or {
generalStore={}
}
bagProtectorAllowedList=bagProtectorAllowedList or {}
bagProtector.addToAllowList=function(containerId,objectId)
if bagProtectorAllowedList[containerId]==nil then
bagProtectorAllowedList[containerId]={}
end
if not tableHelpers.isValueInTable(bagProtectorAllowedList[containerId],objectId) then
table.insert(bagProtectorAllowedList[containerId],objectId)
end
end
bagProtector.addBagToProtectedList=function(bagGuid)
table.insert(bagProtectorGuidStores.generalStore,bagGuid)
end
bagProtector.isProtectedContainer=function(enteredContainerGuid)
for _,store in pairs(bagProtectorGuidStores) do
if tableHelpers.isValueInTable(store,enteredContainerGuid) then
--log("Bag protector,protected container")
return true
end
end
--log("Bag protector,not a protected container")
return false
end
bagProtector.isOnAllowedListForContainer=function(enteredContainerGuid,enteredObjectGuid)
if bagProtectorAllowedList[enteredContainerGuid]~=nil then
if tableHelpers.isValueInTable(bagProtectorAllowedList[enteredContainerGuid],enteredObjectGuid) then
return true
end
end
return false
end
bagProtector.objectLeaveContainer=function(leftContainer,leavingObject)
if bagProtector.isProtectedContainer(leftContainer.getGUID()) then
bagProtector.addToAllowList(leftContainer.getGUID(),leavingObject.getGUID())
end
end
bagProtector.filterObjectEnter=function(enteredContainer,enteringObject)
if bagProtector.isProtectedContainer(enteredContainer.getGUID()) then
if bagProtector.isOnAllowedListForContainer(enteredContainer.getGUID(),enteringObject.getGUID()) then
--log("Bag protected. Please pass.")
return true
end
return false
end
return nil
end


vectorHelpers=vectorHelpers or {}
vectorHelpers.addVectors=function(v1,v2)
return {
(v1[1] or v1.x) + (v2[1] or v2.x),
(v1[2] or v1.y) + (v2[2] or v2.y),
(v1[3] or v1.z) + (v2[3] or v2.z)
}
end
vectorHelpers.subtractVectors=function(v1,v2)
return {
(v1[1] or v1.x) - (v2[1] or v2.x),
(v1[2] or v1.y) - (v2[2] or v2.y),
(v1[3] or v1.z) - (v2[3] or v2.z)
}
end
vectorHelpers.scaleVector=function(v1,scale)
return {
(v1[1] or v1.x)*scale,
(v1[2] or v1.y)*scale,
(v1[3] or v1.z)*scale
}
end
vectorHelpers.scaleVectorByVector=function(v1,v2)
return {
(v1[1] or v1.x) * (v2[1] or v2.x),
(v1[2] or v1.y) * (v2[2] or v2.y),
(v1[3] or v1.z) * (v2[3] or v2.z)
}
end
vectorHelpers.divideVectorByVector=function(v1,v2)
return {
(v1[1] or v1.x) / (v2[1] or v2.x),
(v1[2] or v1.y) / (v2[2] or v2.y),
(v1[3] or v1.z) / (v2[3] or v2.z)
}
end
vectorHelpers.vectorMagnitude=function(v1)
return math.sqrt( v1[1]*v1[1] + v1[2]*v1[2] + v1[3]*v1[3] )
end
vectorHelpers.rotateVectorY=function(vector,rotateAngle)
local cos=math.cos(rotateAngle * math.pi/180)
local sin=math.sin(rotateAngle * math.pi/180)
local resultVector={}
resultVector[1]=cos*vector[1] + sin*vector[3]
resultVector[2]=vector[2]
resultVector[3]=-sin*vector[1] + cos*vector[3]
return resultVector
end
vectorHelpers.multiplyVectorWithScalar=function(vector,scalar)
return {vector[1]*scalar,vector[2]*scalar,vector[3]*scalar}
end
vectorHelpers.print=function(v)
Global.call("logging_printToAll",{
message="{" .. (v[1] or v.x) .. "," .. (v[2] or v.y) .. "," ..(v[3] or v.z) .. "}",
messageColor={1,1,1},
loggingMode="unimportant",
})
end
vectorHelpers.fromLocalToWorld=function(gameObject,localDeltaVector,flip)
if flip then localDeltaVector[1]=-localDeltaVector[1] end
localDeltaVector=vectorHelpers.rotateVectorY(localDeltaVector,gameObject.getRotation()[2])
local scaledDeltaVector=vectorHelpers.scaleVectorByVector(localDeltaVector,gameObject.getScale())
vector=vectorHelpers.addVectors(gameObject.getPosition(),scaledDeltaVector)
return vector
end
vectorHelpers.fromWorldToLocal=function(gameObject,worldPosition,flip)
local localUnscaledUnrotatedVector=vectorHelpers.subtractVectors(worldPosition,gameObject.getPosition())
local downScale={1/gameObject.getScale()[1],1/gameObject.getScale()[2],1/gameObject.getScale()[3]}
local localScaledUnrotatedVector=vectorHelpers.scaleVectorByVector(localUnscaledUnrotatedVector,downScale)
vector=vectorHelpers.rotateVectorY(localScaledUnrotatedVector,-gameObject.getRotation()[2])
if flip then vector[1]=-vector[1] end
return vector
end
vectorHelpers.truncateVectorEntries=function(inputVector,keepDecimals)
local factor=1
for i=1,keepDecimals do
factor=factor * 10
end
local tmpVec=vectorHelpers.scaleVector(inputVector,factor)
tmpVec={math.floor(tmpVec[1]),math.floor(tmpVec[2]),math.floor(tmpVec[3])}
return vectorHelpers.scaleVector(tmpVec,1/factor)
end
vectorHelpers.isInsideRange=function(targetPosition,testPosition,radius)
local deltaVector=vectorHelpers.subtractVectors(targetPosition,testPosition)
return vectorHelpers.vectorMagnitude(deltaVector) <= radius
end


matrixTwoDHelpers=matrixTwoDHelpers or {}
matrixTwoDHelpers.createGrid=function(baseOffset,gridSizes,gridVectors,rotationAngle)
if type(gridSizes)~="table" or #gridSizes==0 then
return {baseOffset}
end
local subSizes={}
local subVectors={}
for i=2,#gridSizes do
table.insert(subSizes,gridSizes[i])
table.insert(subVectors,gridVectors[i])
end
local previousGrid=matrixTwoDHelpers.createGrid(baseOffset,subSizes,subVectors)
local newGrid={}
for index,previousGridPoint in pairs(previousGrid) do
for i=1,gridSizes[1] do
newGrid[((index -1)*gridSizes[1]) + i]=vectorHelpers.addVectors(vectorHelpers.scaleVector(gridVectors[1],(i - 1)),previousGridPoint)
end
end
if rotationAngle~=nil then
newGrid=matrixTwoDHelpers.rotateGridAroundPointY(baseOffset,newGrid,rotationAngle)
end
return newGrid
end
matrixTwoDHelpers.createGridWithExceptions=function(startPos,gridSizes,gridVectors,rotationAngle,exceptions)
local grid=matrixTwoDHelpers.createGrid(startPos,gridSizes,gridVectors,rotationAngle)
for i=#exceptions,1,-1 do
local exceptionIndex=(exceptions[i][2]-1)*gridSizes[1] + exceptions[i][1]
table.remove(grid,exceptionIndex)
end
return grid
end
matrixTwoDHelpers.fromLocalToWorld=function(parentObject,grid)
local newGrid={}
for i,entry in pairs(grid) do
table.insert(newGrid,vectorHelpers.fromLocalToWorld(parentObject,entry))
end
return newGrid
end
matrixTwoDHelpers.createScaledGrid=function(baseOffset,gridSizes,gridVectorsIn,rotationAngle,scale)
local offset=vectorHelpers.scaleVectorByVector(baseOffset,scale)
local gridVectors={}
gridVectors[1]=vectorHelpers.scaleVectorByVector(gridVectorsIn[1],scale)
gridVectors[2]=vectorHelpers.scaleVectorByVector(gridVectorsIn[2],scale)
local grid=matrixTwoDHelpers.createGrid(offset,gridSizes,gridVectors)
local rotatedGrid=matrixTwoDHelpers.rotateGridAroundPointY(offset,grid,rotationAngle)
return rotatedGrid
end
matrixTwoDHelpers.rotateGridAroundPointY=function(point,grid,rotation)
local result={}
for index,gridEntry in pairs(grid) do
local offset=vectorHelpers.subtractVectors(gridEntry,point)
local rotatedOffset=vectorHelpers.rotateVectorY(offset,rotation)
result[index]=vectorHelpers.addVectors(point,rotatedOffset)
end
return result
end
matrixTwoDHelpers.createSnapGrid=function(object,baseOffset,gridSizes,gridVectors,rotationAngle,rotationSnap,rotationVectorSnap,scale)
if scale~=nil then
baseOffset=vectorHelpers.scaleVectorByVector(baseOffset,scale)
gridVectors[1]=vectorHelpers.scaleVectorByVector(gridVectors[1],scale)
gridVectors[2]=vectorHelpers.scaleVectorByVector(gridVectors[2],scale)
end
local grid=matrixTwoDHelpers.createGrid(baseOffset,gridSizes,gridVectors)
local rotatedGrid=matrixTwoDHelpers.rotateGridAroundPointY(baseOffset,grid,rotationAngle)
local snapInformation={}
for index,gridPoint in pairs(rotatedGrid) do
snapInformation[index]={
position=gridPoint,
rotation=rotationVectorSnap,
rotation_snap=rotationSnap
}
end
return snapInformation
end
matrixTwoDHelpers.scaledCoordinatesFrom1DIndexForIrregularMatrix=function(index,row_starting_offset,column_starting_offset,row_length,scaling)
local row_index=math.floor((index - 1) / row_length)
local column_index=(index - 1) % row_length
return {row_starting_offset + row_index * scaling[1],column_starting_offset + column_index * scaling[2]}
end
matrixTwoDHelpers.totalOffsetFromPositionMatrixAnd1DIndex=function(index,positionMatrix,scaling)
local offset2D=matrixTwoDHelpers.scaledCoordinatesFrom1DIndexForIrregularMatrix(
index,positionMatrix.rowStartingOffset,positionMatrix.columnStartingOffset,positionMatrix.rowLength,scaling or {1,1})
return {offset2D[1],positionMatrix.heightStartingOffset,offset2D[2]}
end
matrixTwoDHelpers.computeBoundsFromGrid=function(inputData)
local grid=inputData.grid
local computeMiddlePoint=inputData.computeMiddlePoint or false
local lowestX=grid[1][1]
local highestX=grid[1][1]
local lowestZ=grid[1][3]
local highestZ=grid[1][3]
for _,entry in pairs(grid) do
if lowestX > entry[1] then
lowestX=entry[1]
end
if highestX < entry[1] then
highestX=entry[1]
end
if lowestZ > entry[3] then
lowestZ=entry[3]
end
if highestZ < entry[3] then
highestZ=entry[3]
end
end
local deltaX=highestX - lowestX
local deltaZ=highestZ - lowestZ
if computeMiddlePoint then
local middlePoint={x=lowestX + 1/2 * deltaX,y=grid[1][2],z=lowestZ + 1/2 * deltaZ}
return {xSize=deltaX,zSize=deltaZ,middlePoint=middlePoint}
else
return {xSize=deltaX,zSize=deltaZ}
end
end


zoneHelpers={}
zoneHelpers.createScriptingZoneForEachGridPoint=function(parentObject,grid,operationId,heightIn)
local zoneGuids={}
local height=heightIn or 0.6
volatileData.operations[operationId]={}
volatileData.operations[operationId].isDone=false
function coroutineSpawnZoneForEachGridPoint()
local zoneSetup={}
zoneSetup.scale={0.1,height,0.1}
zoneSetup.rotation={0,0,0}
zoneSetup.type="ScriptingTrigger"
for i=1,#grid do
local pos=vectorHelpers.addVectors(grid[i],{0,height/2,0})
if parentObject~=nil then
pos=vectorHelpers.fromLocalToWorld(parentObject,pos)
end
zoneSetup.position=pos
zoneSetup.callback_function=function(spawned_object)
table.insert(zoneGuids,spawned_object.getGUID())
end
spawnObject(zoneSetup)
end
for i=1,3 do
coroutine.yield(0)
end
volatileData.operations[operationId].result=zoneGuids
volatileData.operations[operationId].isDone=true
return 1
end
startLuaCoroutine(self,"coroutineSpawnZoneForEachGridPoint")
end
zoneHelpers.createScriptingZoneFromGrid=function(parentObject,grid,operationId,borderIn,heightIn)
local border=borderIn or {0.0,0.0}
local height=heightIn or 0.6
volatileData.operations[operationId]={}
volatileData.operations[operationId].isDone=false
function coroutineSpawnZoneFromTransform()
local zoneSetup={}
local bounds=matrixTwoDHelpers.computeBoundsFromGrid({grid=grid,computeMiddlePoint=true,scale=object.getScale()})
zoneSetup.scale={bounds.xSize,height,bounds.zSize}
zoneSetup.rotation={0,0,0}
zoneSetup.type="ScriptingTrigger"
local pos=vectorHelpers.addVectors(bounds.middlePoint,{0,height/2,0})
if parentObject~=nil then
pos=vectorHelpers.fromLocalToWorld(parentObject,pos)
zoneSetup.scale=vectorHelpers.scaleVectorByVector(zoneSetup.scale,parentObject.getScale())
end
zoneSetup.scale=vectorHelpers.addVectors(zoneSetup.scale,{2*border[1],0,2*border[2]})
zoneSetup.position=pos
local zone=spawnObject(zoneSetup)
for i=1,3 do
coroutine.yield(0)
end
volatileData.operations[operationId].result=zone.getGUID()
volatileData.operations[operationId].isDone=true
return 1
end
startLuaCoroutine(self,"coroutineSpawnZoneFromTransform")
end
zoneHelpers.createScriptingZoneFromTransform=function(parentObject,transform,operationId,heightIn,scale)
local zoneGuids={}
local height=heightIn or 0.6
local scale=scale or {0.1,0.1,0.1}
volatileData.operations[operationId]={}
volatileData.operations[operationId].isDone=false
function coroutineSpawnZoneForEachGridPoint()
local zoneSetup={}
zoneSetup.scale=vectorHelpers.addVectors({0,height,0},scale)
zoneSetup.rotation={0,0,0}
zoneSetup.type="ScriptingTrigger"
local pos=vectorHelpers.addVectors(transform.pos,{0,height/2,0})
if parentObject~=nil then
pos=vectorHelpers.fromLocalToWorld(parentObject,pos)
end
zoneSetup.position=pos
local zone=spawnObject(zoneSetup)
for i=1,3 do
coroutine.yield(0)
end
volatileData.operations[operationId].result=zone.getGUID()
volatileData.operations[operationId].isDone=true
return 1
end
startLuaCoroutine(self,"coroutineSpawnZoneForEachGridPoint")
end
--


hexMapHelpers={}
hexMapHelpers.getNeighboursFromWorldCoordinates=function(map,worldCoordinates,mapTile)
local indices=worldCoordinatesToIndices(map.metadata,worldCoordinates,mapTile)
return hexMapHelpers.getNeighboursFromIndices(map,indices)
end
hexMapHelpers.getNeighboursFromIndices=function(map,indices)
if #indices==0 then
return {}
end
local neighbourTiles={}
local probingVectors={{0,-1,0},{0,0,-1},{1,0,0},{0,1,0},{0,0,1},{-1,0,0}}
for _,vec in pairs(probingVectors) do
local neighbourIndices=vectorHelpers.addVectors(indices,vec)
neighbourIndices=normalizeIndices(neighbourIndices)
if tileExists(map,neighbourIndices) then
table.insert(neighbourTiles,map.tiles[neighbourIndices[1]][neighbourIndices[2]][neighbourIndices[3]])
end
end
return neighbourTiles
end
hexMapHelpers.getNeighboursIndicesFromWorldCoordinates=function(map,worldCoordinates,mapTile)
local indices=worldCoordinatesToIndices(map.metadata,worldCoordinates,mapTile)
return hexMapHelpers.getNeighboursIndicesFromIndices(map,indices)
end
hexMapHelpers.getNeighboursIndicesFromIndices=function(map,indices)
if #indices==0 then
return {}
end
local neighbourTilesIndices={}
local probingVectors={{0,-1,0},{0,0,-1},{1,0,0},{0,1,0},{0,0,1},{-1,0,0}}
for _,vec in pairs(probingVectors) do
local neighbourIndices=vectorHelpers.addVectors(indices,vec)
neighbourIndices=normalizeIndices(neighbourIndices)
if tileExists(map,neighbourIndices) then
table.insert(neighbourTilesIndices,{neighbourIndices[1],neighbourIndices[2],neighbourIndices[3]})
end
end
return neighbourTilesIndices
end
hexMapHelpers.getTileFromWorldCoordinates=function(map,worldCoordinates,mapTile)
local indices=worldCoordinatesToIndices(map.metadata,worldCoordinates,mapTile)
if #indices==0 then
return nil
end
if not tileExists(map,indices) then
return nil
end
return map.tiles[indices[1]][indices[2]][indices[3]]
end
hexMapHelpers.getTileFromArbitraryHexCoords=function(map,coords)
local normalizedCoords=normalizeIndices(coords)
if not tileExists(map,normalizedCoords) then
return nil
end
return map.tiles[normalizedCoords[1]][normalizedCoords[2]][normalizedCoords[3]]
end
hexMapHelpers.getMapBounds=function(map,mapTile)
local leftMostIndices={0,0,0}
local rightMostIndices={0,0,0}
local iRightMost=0
local iLeftMost=0
local topMostIndices={0,0,0}
local bottomMostIndices={0,0,0}
for i,jkMatrix in pairs(map.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,_ in pairs(kMatrix) do
if j + i >= vectorHelpers.vectorMagnitude(rightMostIndices) then
if i >= iRightMost then
iRightMost=i
rightMostIndices={i,j,0}
end
end
if k - i >= vectorHelpers.vectorMagnitude(leftMostIndices) then
if i <= iLeftMost then
iLeftMost=i
leftMostIndices={-i,0,k}
end
end
if k + j > vectorHelpers.vectorMagnitude(bottomMostIndices) then
bottomMostIndices={0,j,k}
end
end
end
end
local topMostWorldCoordinates=indicesToWorldCoordinates(map.metadata,topMostIndices,mapTile)
local leftMostWorldCoordinates=indicesToWorldCoordinates(map.metadata,leftMostIndices,mapTile)
local bottomMostWorldCoordinates=indicesToWorldCoordinates(map.metadata,bottomMostIndices,mapTile)
local rightMostWorldCoordinates=indicesToWorldCoordinates(map.metadata,rightMostIndices,mapTile)
local topMostWorldCoordinates=vectorHelpers.addVectors(topMostWorldCoordinates,{0,0,map.metadata.hexDistance/1.7})
local leftMostWorldCoordinates=vectorHelpers.addVectors(leftMostWorldCoordinates,{-map.metadata.hexDistance/2,0,0})
local bottomMostWorldCoordinates=vectorHelpers.addVectors(bottomMostWorldCoordinates,{0,0,-map.metadata.hexDistance/1.7})
local rightMostWorldCoordinates=vectorHelpers.addVectors(rightMostWorldCoordinates,{map.metadata.hexDistance/2,0,0})
return {top=topMostWorldCoordinates,left=leftMostWorldCoordinates,bottom=bottomMostWorldCoordinates,right=rightMostWorldCoordinates}
end
hexMapHelpers.isOnMapTile=function(map,position,mapTile)
local ind=worldCoordinatesToIndices(map.metadata,position,mapTile)
return map.tiles[ind[1]]~=nil and
map.tiles[ind[1]][ind[2]]~=nil and
map.tiles[ind[1]][ind[2]][ind[3]]~=nil
end
hexMapHelpers.isOnMars=function(map,position)
local mapTile=gameObjectHelpers.getObjectByName("gameMap")
local ind=worldCoordinatesToIndices(map.metadata,position,mapTile)
return map.tiles[ind[1]]~=nil and
map.tiles[ind[1]][ind[2]]~=nil and
map.tiles[ind[1]][ind[2]][ind[3]]~=nil
end
hexMapHelpers.indicesToWorldCoordinates=function(map,indices,mapTile)
return indicesToWorldCoordinates(map.metadata,indices,mapTile)
end
hexMapHelpers.makeMapSerializable=function(map)
if map==nil then
return {}
end
local serializableMap={}
serializableMap.metadata=map.metadata
serializableMap.tiles=convertToSerializableTiles(map.tiles)
return serializableMap
end
hexMapHelpers.makeMapComputeFriendly=function(map)
if map==nil then
return {}
end
local computeFriendlyMap={}
computeFriendlyMap.metadata=map.metadata
computeFriendlyMap.tiles=convertToComputeFriendlyTiles(map.tiles)
return computeFriendlyMap
end
hexMapHelpers.computeDistanceBetweenIndices=function(indicesA,indicesB,absolute)
absolute=absolute or true
local nia=normalizeIndices(indicesA)
local nib=normalizeIndices(indicesB)
local ctrlFunc=function(a,b)
if a * b~=0 then
return 1
else
return 0
end
end
if nia[3]==0 and nib[3]==0 then
if (nia[1] - nib[1]) * (nia[2] - nib[2]) >= 0 then
return math.abs(nia[1] - nib[1]) + math.abs(nia[2] - nib[2])
elseif math.abs(nia[1] - nib[1]) > math.abs(nia[2] - nib[2]) then
return math.abs(nia[1] - nib[1])
else
return math.abs(nia[1] - nib[1]) + math.abs(nia[2] - nib[2] + nia[1] - nib[1])
end
elseif nia[1]==0 and nib[1]==0 then
if (nia[3] - nib[3]) * (nia[2] - nib[2]) >= 0 then
return math.abs(nia[2] - nib[2]) + math.abs(nia[3] - nib[3])
elseif math.abs(nia[2] - nib[2]) > math.abs(nia[3] - nib[3]) then
return math.abs(nia[2] - nib[2])
else
return math.abs(nia[2] - nib[2]) + math.abs(nia[3] - nib[3] + nia[2] - nib[2])
end
else
if nia[1] > 0 then
if math.abs(nia[1] + nia[2]) < nib[2] then
return nib[3] + math.abs(nia[2] - nib[2])
else
return nib[3] + nia[1]
end
else
if math.abs(nib[1] + nib[2]) < nia[2] then
return nia[3] + math.abs(nib[2] - nia[2])
else
return nia[3] + nib[1]
end
end
end
end
hexMapHelpers.walkMapHorizontally=function(map,stepsToWalk,direction,startingIndices,skipMapFeatures,forbiddenIndices)
local indices=tableHelpers.cloneTable(startingIndices)
local rowStartingIndices=tableHelpers.cloneTable(startingIndices)
for i=0,stepsToWalk do
if i~=0 then
indices[1]=indices[1] + direction
indices=normalizeIndices(indices)
end
local skipTile=true
local outCond=0
while skipTile and outCond < 100 do
if not tileExists(map,indices) then
local potentialIndices=normalizeIndices({rowStartingIndices[1],rowStartingIndices[2],rowStartingIndices[3] + direction})
if not tileExists(map,potentialIndices) then
potentialIndices=normalizeIndices({rowStartingIndices[1],rowStartingIndices[2] + direction,rowStartingIndices[3]})
if not tileExists(map,potentialIndices) then
potentialIndices=tableHelpers.cloneTable(startingIndices)
end
end
rowStartingIndices=potentialIndices
indices=tableHelpers.cloneTable(rowStartingIndices)
end
local tile=map.tiles[indices[1]][indices[2]][indices[3]]
if isTileSkipped(tile,skipMapFeatures,true,indices,forbiddenIndices) then
indices[1]=indices[1] + direction
end
indices=normalizeIndices(indices)
outCond=outCond + 1
end
end
return indices
end
hexMapHelpers.walkAroundTile=function(map,stepsToWalk,tileIndices,skipMapFeatures,forbiddenIndices)
local neighbouringTiles=hexMapHelpers.getNeighboursFromIndices(map,tileIndices)
local tilesCounting=0
local probingVectors={{0,-1,0},{0,0,-1},{1,0,0},{0,1,0},{0,0,1},{-1,0,0}}
for i,tile in pairs(neighbouringTiles) do
local neighbourIndices=normalizeIndices(vectorHelpers.addVectors(tileIndices,probingVectors[i]))
if not isTileSkipped(tile,skipMapFeatures,true,neighbourIndices,forbiddenIndices) then
tilesCounting=tilesCounting + 1
end
end
if tilesCounting==0 then
return nil
end
stepsToWalk=stepsToWalk % tilesCounting
local neighbourIndices=hexMapHelpers.getNeighboursIndicesFromIndices(map,tileIndices)
for i,tile in pairs(neighbouringTiles) do
if not isTileSkipped(tile,skipMapFeatures,true,neighbourIndices[i],forbiddenIndices) then
if stepsToWalk==0 then
return neighbourIndices[i]
end
stepsToWalk=stepsToWalk - 1
end
end
end
function isTileSkipped(tile,skipMapFeatures,skipTileObjects,indices,forbiddenIndices)
if skipTileObjects and tile.tileObjects~=nil and next(tile.tileObjects)~=nil then
return true
end
for _,skipMapFeature in pairs(skipMapFeatures) do
for _,tileFeature in pairs(tile.features) do
if skipMapFeature==tileFeature then
return true
end
end
end
for _,fi in pairs(forbiddenIndices) do
if fi[1]==indices[1] and fi[2]==indices[2] and fi[3]==indices[3] then
return true
end
end
return false
end
function convertToComputeFriendlyTiles(rawTiles)
local tiles={}
for i,tile in pairs(rawTiles) do
if tiles[tile.coords[1]]==nil then
tiles[tile.coords[1]]={}
end
if tiles[tile.coords[1]][tile.coords[2]]==nil then
tiles[tile.coords[1]][tile.coords[2]]={}
end
tiles[tile.coords[1]][tile.coords[2]][tile.coords[3]]={features=tile.features,placementProperties=tile.placementProperties,adjacenyEffects=tile.adjacenyEffects,tileObjects=tile.tileObjects}
end
return tiles
end
function convertToSerializableTiles(tiles)
local serializableTiles={}
for i,jkMatrix in pairs(tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
local newTile={features=tile.features,placementProperties=tile.placementProperties,adjacenyEffects=tile.adjacenyEffects,tileObjects=tile.tileObjects}
newTile.coords={i,j,k}
table.insert(serializableTiles,newTile)
end
end
end
return serializableTiles
end
function worldCoordinatesToIndices(mapMetadata,worldCoordinates,mapTile)
local mapWorldLocation=mapTile.getPosition()
local mapStartWorldCoords=vectorHelpers.addVectors(mapMetadata.offset,mapWorldLocation)
worldCoordinates[2]=mapStartWorldCoords[2]
local indices={0,0,0}
local probingVector=vectorHelpers.subtractVectors(worldCoordinates,mapStartWorldCoords)
local lastNearestCoordinates=mapStartWorldCoords
local iProbingVector={}
local i=0
while (vectorHelpers.vectorMagnitude(probingVector) > (mapMetadata.hexDistance / 2) and not (i > 100)) do
local iProbingVector=vectorHelpers.addVectors(lastNearestCoordinates,{mapMetadata.hexDistance,0,0})
local jProbingVector=vectorHelpers.addVectors(lastNearestCoordinates,{mapMetadata.hexDistance * math.cos(60 * math.pi/180),0,-mapMetadata.hexDistance * math.sin(60 * math.pi/180)})
local kProbingVector=vectorHelpers.addVectors(lastNearestCoordinates,{-mapMetadata.hexDistance * math.cos(60 * math.pi/180),0,-mapMetadata.hexDistance * math.sin(60 * math.pi/180)})
local indicesDelta={1,0,0}
local iProbe=vectorHelpers.subtractVectors(worldCoordinates,iProbingVector)
local jProbe=vectorHelpers.subtractVectors(worldCoordinates,jProbingVector)
local kProbe=vectorHelpers.subtractVectors(worldCoordinates,kProbingVector)
lastNearestCoordinates=iProbingVector
if vectorHelpers.vectorMagnitude(jProbe) < vectorHelpers.vectorMagnitude(iProbe) then
lastNearestCoordinates=jProbingVector
indicesDelta={0,1,0}
if vectorHelpers.vectorMagnitude(kProbe) < vectorHelpers.vectorMagnitude(jProbe) then
lastNearestCoordinates=kProbingVector
indicesDelta={0,0,1}
end
end
probingVector=vectorHelpers.subtractVectors(worldCoordinates,lastNearestCoordinates)
indices=vectorHelpers.addVectors(indices,indicesDelta)
i=i + 1
end
return normalizeIndices(indices)
end
function indicesToWorldCoordinates(mapMetadata,indices,mapTile)
if mapTile==nil then
mapTile=gameObjectHelpers.getObjectByName("gameMap")
end
local mapWorldLocation=mapTile.getPosition()
local mapStartWorldCoords=vectorHelpers.addVectors(mapMetadata.offset,mapWorldLocation)
local x=mapMetadata.hexDistance * (indices[1] + math.cos(60 * math.pi/180) * (indices[2] - indices[3]))
local y=0
local z=-mapMetadata.hexDistance * math.sin(60 * math.pi/180) * (indices[2] + indices[3])
local worldCoordinates=vectorHelpers.addVectors({x,y,z},mapStartWorldCoords)
return worldCoordinates
end
function normalizeIndices(indices)
local normalizedIndices=indices
local modifier=1
local i=0
while modifier~=0 and i < 10 do
if normalizedIndices[2] * normalizedIndices[3] < 0 then
if normalizedIndices[2] < 0 and normalizedIndices[3] > 0 then
if -normalizedIndices[2] < normalizedIndices[3] then
modifier=normalizedIndices[2]
else
modifier=-normalizedIndices[3]
end
else
if normalizedIndices[2] < -normalizedIndices[3] then
modifier=normalizedIndices[2]
else
modifier=-normalizedIndices[3]
end
end
elseif normalizedIndices[1] * normalizedIndices[3] > 0 then
if normalizedIndices[1] < 0 and normalizedIndices[3] < 0 then
if -normalizedIndices[1] < -normalizedIndices[3] then
modifier=-normalizedIndices[1]
else
modifier=-normalizedIndices[3]
end
else
if normalizedIndices[1] < normalizedIndices[3] then
modifier=-normalizedIndices[1]
else
modifier=-normalizedIndices[3]
end
end
elseif normalizedIndices[1] * normalizedIndices[2] < 0 then
if normalizedIndices[1] < 0 and normalizedIndices[2] > 0 then
if -normalizedIndices[1] < normalizedIndices[2] then
modifier=-normalizedIndices[1]
else
modifier=normalizedIndices[2]
end
else
if normalizedIndices[1] < -normalizedIndices[2] then
modifier=-normalizedIndices[1]
else
modifier=normalizedIndices[2]
end
end
else
modifier=0
end
normalizedIndices=vectorHelpers.addVectors(normalizedIndices,{modifier,-modifier,modifier})
i=i + 1
end
return normalizedIndices
end
function tileExists(map,indices)
if map.tiles[indices[1]]==nil then
return false
elseif map.tiles[indices[1]][indices[2]]==nil then
return false
elseif map.tiles[indices[1]][indices[2]][indices[3]]==nil then
return false
else
return true
end
end


function descriptionInterpreter_getActionCardInfos(cardDescription)
local rawActions=getIndexBasedLinesFromInput(cardDescription,"Action[0-9]:")
local rawActionButtonProperties=getIndexBasedLinesFromInput(cardDescription,"Action[0-9]Props:")
local rawEventHandlers=getIndexBasedLinesFromInput(cardDescription,"EventHandler[0-9]:")
local rawCounters=getIndexBasedLinesFromInput(cardDescription,"Counter[0-9]:")
local counterTypeTable=getSpecifiedValuesFromInput(cardDescription,"CounterType:")
return {rawActions=rawActions,
rawActionButtonProperties=rawActionButtonProperties,
rawEventHandlers=rawEventHandlers,
rawCounters=rawCounters,
counterTypeTable=counterTypeTable}
end
function descriptionInterpreter_isProjectCard(input)
return descriptionInterpreter.isProjectCard(input)
end
function descriptionInterpreter_hasRequirements(input)
return next(descriptionInterpreter.getKeyValuePairsFromInput(input,"Reqs:"))~=nil
end
function descriptionInterpreter_getValues(params)
return descriptionInterpreter.getValuesFromInput(params.description,params.pattern)
end
descriptionInterpreter={}
descriptionInterpreter.getValuesFromInput=function(input,pattern)
return getSpecifiedValuesFromInput(input,pattern)
end
descriptionInterpreter.getKeyValuePairsFromInput=function(input,pattern)
return getKeyValuePairsFromInput(input,pattern)
end
descriptionInterpreter.isProjectCard=function(input)
if string.match(input,":Corporation:") or string.match(input,":Prelude:") then
return false
end
return true
end
descriptionInterpreter.contains=function(input,pattern)
return string.match(input,pattern)
end
function getKeyValuePairsFromInput(input,pattern)
local rawValues=getSpecifiedValuesFromInput(input,pattern)
if rawValues==nil then
return {}
end
local lastNumber=nil
local returnValues={}
for i,value in ipairs(rawValues) do
local possibleNumber=tonumber(value)
if possibleNumber~=nil then
lastNumber=possibleNumber
else
if lastNumber~=nil then
returnValues[value]=lastNumber
end
end
end
return returnValues
end
function getIndexBasedLinesFromInput(inputString,searchPattern)
local isValue=false
local valueList={}
local lines={}
local index=1
local innerIndex=1
for subString in string.gmatch(inputString,"%S+") do
if string.find(subString,":")~=nil then
isValue=false
end
if isValue then
if valueList[index]==nil then
valueList[index]={}
end
valueList[index][innerIndex]=subString
innerIndex=innerIndex + 1
end
if (string.match(subString,searchPattern)) then
isValue=true
index=string.match(subString,"[0-9]")
innerIndex=1
end
end
return valueList
end
function getSpecifiedValuesFromInput(inputString,searchPattern)
local isValue=false
local valueList={}
local index=1
for subString in string.gmatch(inputString,"%S+") do
if string.find(subString,":")~=nil then
isValue=false
end
if isValue then
valueList[index]=subString
index=index + 1
end
if (string.match(subString,searchPattern)) then
isValue=true
end
end
return valueList
end


snapPointHelpers={}
snapPointHelpers.createSingleSnapPoint=function(obj,transform,rotationSnapIn)
local rotationSnap=rotationSnapIn or true
local snapPoints={}
if obj==nil then
snapPoints=Global.getSnapPoints()
else
snapPoints=obj.getSnapPoints()
end
local snapPoint={
position=transform.pos,
rotation=transform.rot,
rotation_snap=rotationSnap
}
table.insert(snapPoints,snapPoint)
if obj==nil then
Global.setSnapPoints(snapPoints)
else
obj.setSnapPoints(snapPoints)
end
end


buttonFunctions={}
buttonFunctions.createButtons=function(parentObject,buttons)
local createFromScratch=parentObject.getButtons()==nil
local buttonAmount=0
for i=1,#buttons do
buttonFunctions.adaptButtonColor(buttons[i])
buttonFunctions.adaptButtonLabel(buttons[i])
buttonFunctions.adaptButtonTooltip(buttons[i])
buttons[i].index=buttonAmount
if createFromScratch then
parentObject.createButton(buttons[i])
else
parentObject.editButton(buttons[i])
end
buttonAmount=buttonAmount + 1
end
end
buttonFunctions.adaptButtonColor=function(buttonInfo)
local enabledColor=buttonInfo.enabledColorOverride or gameSetupColors.toggleButtonOnColor
if buttonInfo.onIndex~=nil then
if tableHelpers.getValueFromString(buttonInfo.onIndex) then
buttonInfo.color=enabledColor
else
buttonInfo.color=gameSetupColors.toggleButtonOffColor
end
elseif buttonInfo.onIndices~=nil then
local isEnabled=true
for _,value in pairs(buttonInfo.onIndices) do
isEnabled=isEnabled and tableHelpers.getValueFromString(value)
end
if isEnabled then
buttonInfo.color=enabledColor
else
buttonInfo.color=gameSetupColors.toggleButtonOffColor
end
elseif buttonInfo.onIndicesOr~=nil then
local isEnabled=false
for _,value in pairs(buttonInfo.onIndicesOr) do
isEnabled=isEnabled or tableHelpers.getValueFromString(value)
end
if isEnabled then
buttonInfo.color=enabledColor
else
buttonInfo.color=gameSetupColors.toggleButtonOffColor
end
elseif buttonInfo.onIndexInversed~=nil then
if not gameConfig.setup[buttonInfo.onIndexInversed] and not tableHelpers.getValueFromString(buttonInfo.onIndex) then
buttonInfo.color=enabledColor
else
buttonInfo.color=gameSetupColors.toggleButtonOffColor
end
end
end
buttonFunctions.adaptButtonLabel=function(buttonInfo)
if buttonInfo.dynamicLabel==nil then
return
end
local value=0
if type(buttonInfo.dynamicLabel.value)=="table" then
for _,entry in pairs(buttonInfo.dynamicLabel.value) do
value=tableHelpers.getValueFromString(entry)
if value~=nil then break end
end
else
value=tableHelpers.getValueFromString(buttonInfo.dynamicLabel.value)
end
local newLabel=""
local prefix=buttonInfo.dynamicLabel.prefix or buttonInfo.dynamicLabel.base or ""
local suffix=buttonInfo.dynamicLabel.suffix or ""
if buttonInfo.dynamicLabel.format~=nil then
newLabel=prefix..string.format(buttonInfo.dynamicLabel.format,value)..suffix
else
newLabel=prefix..value..suffix
end
buttonInfo.label=newLabel
end
buttonFunctions.adaptButtonTooltip=function(buttonInfo)
if buttonInfo.dynamicTooltip==nil then
return
end
local value=tableHelpers.getValueFromString(buttonInfo.dynamicTooltip.value)
local newTooltip=""
local prefix=buttonInfo.dynamicTooltip.prefix or buttonInfo.dynamicTooltip.base or ""
local suffix=buttonInfo.dynamicTooltip.suffix or ""
if buttonInfo.dynamicTooltip.format~=nil then
newTooltip=prefix..string.format(buttonInfo.dynamicTooltip.format,value)..suffix
else
newTooltip=prefix..value..suffix
end
buttonInfo.tooltip=newTooltip
end


colors={}
gameSetupColors={
toggleButtonOnColor={255/255,150/255,0,1},
toggleButtonOffColor={100/255,100/255,100/255,1}
}
colors.buttons={
toggleButtonOn={255/255,150/255,0,1},
toggleButtonOff={100/255,100/255,100/255,1},
toggleButtonSignal={255/255,0/255,155/255,1}
}
colors.gameSetupColors={
toggleButtonOnColor={255/255,150/255,0,1},
toggleButtonOffColor={100/255,100/255,100/255,1},
clickButtonColor={200/255,200/255,200/255,1}
}
colors.tableauColors={
tagCounterColor={180/255,180/255,180/255,0.95},
creditsCounterColor={253/255,231/255,46/255,0.95},
steelCounterColor={168/255,120/255,74/255,0.95},
titaniumCounterColor={67/255,67/255,67/255,0.95},
heatColor={236/255,96/255,51/255,0.95},
textColor={0,0,0,1}
}
colors.resourceToColorMap={
Credits=colors.tableauColors.creditsCounterColor,
Steel=colors.tableauColors.steelCounterColor,
Titanium=colors.tableauColors.titaniumCounterColor,
Heat=colors.tableauColors.heatColor,
}
colors.messageColors={
importantInfo={1,0.85,0.85,1}
}
colors.gameActionButtons={
standardProject={0.5,0.5,0.5,0.75},
plantsToGreenery={0,0.8,0,0.75},
heatToTemp={0.8,0,0,0.75},
}


marsSenate={}
marsSenate.parties={
marsFirst="MarsFirst",
scientists="Scientists",
unity="Unity",
greens="Greens",
reds="Reds",
kelvinists="Kelvinists"
}
marsSenate.partiesById={
"MarsFirst",
"Scientists",
"Unity",
"Greens",
"Reds",
"Kelvinists"
}


ownableObjects={}
ownableObjects.specialTileMappings={}
ownableObjects.specialTileMappings.aliases={
redCity={"cityTile","specialTile"},
newVenice={"cityTile","specialTile"},
capitalCity={"cityTile","specialTile"},
wetlands={"greenery","specialTile"},
commercialDistrict={"specialTile"}
}
ownableObjects.baseGame={}
ownableObjects.baseGame.tiles={
greenery="greenery",
city="cityTile",
cityTile="cityTile",
capitalCity="capitalCity",
mine="mine",
preservationArea="preservationArea",
mohole="mohole",
volcano="volcano",
restrictedArea="restrictedArea",
commercialDistrict="commercialDistrict",
spacePort="spacePort",
ganymedColony="ganymedColony",
industrialZone="industrialZone",
nuclearZone="nuclearZone",
naturalPreserve="naturalPreserve",
specialTile="specialTile",
spaceCityTile="spaceCityTile",
}
ownableObjects.baseGame.cardResources={
animal="animal",
microbe="microbe",
science="science",
fighter="fighter",
}
ownableObjects.baseGame.friendlyNameMapping={
greenery={"Greenery"},
cityTile={"CityTile","cityTile"},
specialTile={"specialTile"}
}
ownableObjects.venus={}
ownableObjects.venus.tiles={
maxwellBase="maxwellBase",
stratopolis="stratopolis",
lunaMetropolis="lunaMetropolis",
dawnCity="dawnCity",
}
ownableObjects.venus.cardResources={
asteroid="asteroid",
floater="floater",
}
ownableObjects.venus.friendlyNameMapping={
asteroid={"Asteroid"},
floater={"Floater"}
}
ownableObjects.colonies={}
ownableObjects.colonies.objects={
colony="colony",
}
ownableObjects.colonies.cardResources={
refugee="refugee",
}
ownableObjects.colonies.friendlyNameMapping={
colony={"Colony","Colonies"},
}
ownableObjects.turmoil={}
ownableObjects.turmoil.tiles={
stanfordTorus="stanfordTorus",
}
ownableObjects.turmoil.friendlyNameMapping={}
ownableObjects.pathfinder={}
ownableObjects.pathfinder.tiles={
redCity="redCity",
newVenice="newVenice",
crashSite="crashSite",
wetlands="wetlands"
}
ownableObjects.pathfinder.cardResources={
habitat="habitat",
robot="robot",
data="data",
}
ownableObjects.highOrbit={}
ownableObjects.highOrbit.cardResources={
ore="ore",
}
ownableObjects.venusPhaseTwo={}
ownableObjects.venusPhaseTwo.tiles={
floatingArray="floatingArray",
gasMine="gasMine",
venusHabitat="venusHabitat",
}
ownableObjects.pathfinder.friendlyNameMapping={}
function createOwnableObjectsCollection()
local collection={}
for _,expansion in pairs(ownableObjects) do
for _,objectType in pairs(expansion) do
if objectType~="friendlyNameMapping" then
for key,value in pairs(objectType) do
collection[key]=0
end
end
end
end
return collection
end


resources={}
resources.baseGame={
"credits",
"steel",
"titanium",
"plants",
"energy",
"heat"
}


icons={}
icons.baseIconNames={
"Building",
"Space",
"Power",
"Science",
"Jovian",
"Earth",
"Venus",
"Plant",
"Microbe",
"Animal",
"City",
}
icons.specialIconNames={
"WildCard",
"None",
"Event"
}
icons.anyTagNames={
"All"
}
icons.pathfinder={
"Mars",
}
icons.highOrbit={
"Infrastructure",
}


eventData={}
eventData.triggerType={
cityPlayed="cityPlayed",
spaceCityPlayed="spaceCityPlayed",
marsCityPlayed="marsCityPlayed",
greeneryPlayed="greeneryPlayed",
oceanPlayed="oceanPlayed",
colonyPlayed="colonyPlayed",
productionChanged="productionChanged",
venusTerraformed="venusTerraformed",
oxygenIncreased="oxygenIncreased",
buildingTagPlayed="buildingTagPlayed",
spaceTagPlayed="spaceTagPlayed",
powerTagPlayed="powerTagPlayed",
scienceTagPlayed="scienceTagPlayed",
jovianTagPlayed="jovianTagPlayed",
earthTagPlayed="earthTagPlayed",
venusTagPlayed="venusTagPlayed",
plantTagPlayed="plantTagPlayed",
microbeTagPlayed="microbeTagPlayed",
animalTagPlayed="animalTagPlayed",
noneTagPlayed="noneTagPlayed",
eventTagPlayed="eventTagPlayed",
marsTagPlayed="marsTagPlayed",
infrastructureTagPlayed="infrastructureTagPlayed",
vpCardPlayed="vpCardPlayed",
animalResourceGained="animalResourceGained",
microbeResourceGained="microbeResourceGained",
floaterResourceGained="floaterResourceGained",
scienceResourceGained="scienceResourceGained",
fighterResourceGained="fighterResourceGained",
dataResourceGained="dataResourceGained",
asteroidResourceGained="asteroidResourceGained",
payTwentyCostCard="payTwentyCostCard",
standardProjectCity="standardProjectCity",
standardProjectGreenery="standardProjectGreenery",
standardProjectOcean="standardProjectOcean",
standardProjectTemperature="standardProjectTemperature",
standardProjectPowerPlant="standardProjectPowerPlant",
standardProjectVenus="standardProjectVenus",
standardProjectColony="standardProjectColony",
buyStandardProject="buyStandardProject",
cardWithRequirmentPlayed="cardWithRequirmentPlayed",
specialTilePlayed="specialTilePlayed",
increasePathfinderVenus="increasePathfinderVenus",
increasePathfinderEarth="increasePathfinderEarth",
increasePathfinderMars="increasePathfinderMars",
increasePathfinderJovian="increasePathfinderJovian",
terraformingGained="terraformingGained",
marsTilePlaced="marsTilePlaced",
venusTilePlaced="venusTilePlaced",
turmoilFactionChanged="turmoilFactionChanged",
specialTilePlayed="specialTilePlayed",
productionPhase="productionPhase",
newGeneration="newGeneration",
cardPlayed="cardPlayed",
turmoilNewGovernment="turmoilNewGovernment",
actionPerformed="actionPerformed",
playerPerformedAction="playerPerformedAction",
payedForCard="payedForCard",
conversionRatesUpdated="conversionRatesUpdated",
playerTurnBegan="playerTurnBegan",
planetWildCardTokenAbsorbed="planetWildCardTokenAbsorbed",
colonyTraded="colonyTraded",
buyVenusStandardProject="buyVenusStandardProject",
venusHabitatPlaced="venusHabitatPlaced",
storageChanged="storageChanged",
oceanRemoved="oceanRemoved",
playerTurnEnd="playerTurnEnd",
}
eventData.triggerScope={
anyPlayer="anyPlayer",
playerThemself="playerThemself",
otherPlayers="otherPlayers",
noPlayer="noPlayer",
}
eventData.allowedPhasesToTrigger={
solarPhase="solarPhase",
gameEnd="gameEnd",
draft="draft",
inRound="inRound",
}


mapping={}
function mapping:new(ownableObjectName,triggerTypeName)
local obj={}
obj.ownableObjectName=ownableObjectName
obj.triggerTypeName=triggerTypeName
return obj
end
tagMapping={}
function tagMapping:new(value,mappedValue)
local obj={}
obj.value=value
obj.mappedValue=mappedValue
return obj
end
eventDataMappings={}
eventDataMappings.ownableObjectsToTriggerTypeMap={
mapping:new("greenery",eventData.triggerType.greeneryPlayed),
mapping:new("specialTile",eventData.triggerType.specialTilePlayed),
mapping:new("redCity",eventData.triggerType.specialTilePlayed),
mapping:new("capitalCity",eventData.triggerType.specialTilePlayed),
mapping:new("commercialDistrict",eventData.triggerType.specialTilePlayed),
mapping:new("newVenice",eventData.triggerType.specialTilePlayed),
mapping:new("wetlands",eventData.triggerType.specialTilePlayed),
mapping:new("animal",eventData.triggerType.animalResourceGained),
mapping:new("microbe",eventData.triggerType.microbeResourceGained),
mapping:new("floater",eventData.triggerType.floaterResourceGained),
mapping:new("science",eventData.triggerType.scienceResourceGained),
mapping:new("figther",eventData.triggerType.fighterResourceGained),
mapping:new("data",eventData.triggerType.dataResourceGained),
mapping:new("asteroid",eventData.triggerType.asteroidResourceGained),
}
eventDataMappings.tagToTriggerTypeMap={
tagMapping:new("Building",eventData.triggerType.buildingTagPlayed),
tagMapping:new("Space",eventData.triggerType.spaceTagPlayed),
tagMapping:new("Power",eventData.triggerType.powerTagPlayed),
tagMapping:new("Science",eventData.triggerType.scienceTagPlayed),
tagMapping:new("Jovian",eventData.triggerType.jovianTagPlayed),
tagMapping:new("Earth",eventData.triggerType.earthTagPlayed),
tagMapping:new("Venus",eventData.triggerType.venusTagPlayed),
tagMapping:new("Plant",eventData.triggerType.plantTagPlayed),
tagMapping:new("Microbe",eventData.triggerType.microbeTagPlayed),
tagMapping:new("Animal",eventData.triggerType.animalTagPlayed),
tagMapping:new("None",eventData.triggerType.noneTagPlayed),
tagMapping:new("Event",eventData.triggerType.eventTagPlayed),
tagMapping:new("Mars",eventData.triggerType.marsTagPlayed),
tagMapping:new("Infrastructure",eventData.triggerType.infrastructureTagPlayed),
}


phases={
generationPhase="generationPhase",
solarPhase="solarPhase",
gameEndPhase="gameEndPhase",
draftingPhase="draftingPhase",
gameStartPhase="gameStartPhase",
gameSetupPhase="gameSetupPhase",
}


mapFeatures={}
mapFeatures.tileType=
{
volcano="volcano",
ocean="ocean",
oceanOptional="ocean",
nocticsCity="nocticsCity",
maxwellBase="maxwellBase",
stratopolis="stratopolis",
gas="gas",
}
mapFeatures.tileFeature={}
mapFeatures.tileFeature.baseGame={
city="city",
greenery="greenery",
ocean="ocean",
commercialDistrict="commercialDistrict",
capital="capital",
specialTile="specialTile",
}
mapFeatures.tileFeature.pathfinder={
wetlands="wetlands",
newVenice="newVenice",
redCity="redCity",
crashSite="crashSite",
}


mapSizes={
tiny=37,
small=49,
normal=61,
big=73,
large=91,
huge=127,
gigantic=159
}
function printMapSizes(prefix,suffix)
local stringBuilder=""
for sizeName,numberOfTiles in pairs(mapSizes) do
stringBuilder=prefix..stringBuilder..sizeName:gsub("^%l",string.upper)..numberOfTiles..suffix
end
return stringBuilder
end


tile={}
function tile:new(coords,features,placementProperties)
local obj={}
obj.coords=coords
obj.features=features
obj.placementProperties=placementProperties
return obj
end
predefinedMaps={}
predefinedMaps.baseMap={}
predefinedMaps.baseMap.metadata={offset={-5,1.4,8.6},hexDistance=2.475,imageUrl="http://cloud-3.steamusercontent.com/ugc/1651097841909243604/A21040391F43461161B277122EA1293A532E4A1E/",scale={6.02,1,6.02}}
predefinedMaps.baseMap.tiles={
tile:new({0,0,0},{},{resourceValues={Steel=2}}),
tile:new({1,0,0},{mapFeatures.tileType.ocean},{resourceValues={Steel=2}}),
tile:new({2,0,0},{},{}),
tile:new({3,0,0},{mapFeatures.tileType.ocean},{effects={"DrawCard"}}),
tile:new({4,0,0},{mapFeatures.tileType.ocean},{}),
tile:new({0,0,1},{},{}),
tile:new({0,1,0},{mapFeatures.tileType.volcano},{resourceValues={Steel=1}}),
tile:new({1,1,0},{},{}),
tile:new({2,1,0},{},{}),
tile:new({3,1,0},{},{}),
tile:new({4,1,0},{mapFeatures.tileType.ocean},{effects={"DrawCard","DrawCard"}}),
tile:new({0,0,2},{mapFeatures.tileType.volcano},{effects={"DrawCard"}}),
tile:new({0,1,1},{},{}),
tile:new({0,2,0},{},{}),
tile:new({1,2,0},{},{}),
tile:new({2,2,0},{},{}),
tile:new({3,2,0},{},{}),
tile:new({4,2,0},{},{resourceValues={Steel=1}}),
tile:new({0,0,3},{mapFeatures.tileType.volcano},{resourceValues={Titanium=1,Plants=1}}),
tile:new({0,1,2},{},{resourceValues={Plants=1}}),
tile:new({0,2,1},{},{resourceValues={Plants=1}}),
tile:new({0,3,0},{},{resourceValues={Plants=1}}),
tile:new({1,3,0},{},{resourceValues={Plants=2}}),
tile:new({2,3,0},{},{resourceValues={Plants=1}}),
tile:new({3,3,0},{},{resourceValues={Plants=1}}),
tile:new({4,3,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,0,4},{mapFeatures.tileType.volcano},{resourceValues={Plants=2}}),
tile:new({0,1,3},{},{resourceValues={Plants=2}}),
tile:new({0,2,2},{mapFeatures.tileType.nocticsCity},{resourceValues={Plants=2}}),
tile:new({0,3,1},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,4,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({1,4,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({2,4,0},{},{resourceValues={Plants=2}}),
tile:new({3,4,0},{},{resourceValues={Plants=2}}),
tile:new({4,4,0},{},{resourceValues={Plants=2}}),
tile:new({0,1,4},{},{resourceValues={Plants=1}}),
tile:new({0,2,3},{},{resourceValues={Plants=2}}),
tile:new({0,3,2},{},{resourceValues={Plants=1}}),
tile:new({0,4,1},{},{resourceValues={Plants=1}}),
tile:new({0,5,0},{},{resourceValues={Plants=1}}),
tile:new({1,5,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({2,5,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({3,5,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({0,2,4},{},{}),
tile:new({0,3,3},{},{}),
tile:new({0,4,2},{},{}),
tile:new({0,5,1},{},{}),
tile:new({0,6,0},{},{}),
tile:new({1,6,0},{},{resourceValues={Plants=1}}),
tile:new({2,6,0},{},{}),
tile:new({0,3,4},{},{resourceValues={Steel=2}}),
tile:new({0,4,3},{},{}),
tile:new({0,5,2},{},{effects={"DrawCard"}}),
tile:new({0,6,1},{},{effects={"DrawCard"}}),
tile:new({0,7,0},{},{}),
tile:new({1,7,0},{},{resourceValues={Titanium=1}}),
tile:new({0,4,4},{},{resourceValues={Steel=1}}),
tile:new({0,5,3},{},{resourceValues={Steel=2}}),
tile:new({0,6,2},{},{}),
tile:new({0,7,1},{},{}),
tile:new({0,8,0},{mapFeatures.tileType.ocean},{resourceValues={Titanium=2}}),
}
predefinedMaps.hellas={}
predefinedMaps.hellas.metadata={offset={-5,1.4,8.6},hexDistance=2.475,imageUrl="http://cloud-3.steamusercontent.com/ugc/1750191431521699022/FB6D0E691C3F0D62012BEAD76E6ECB0F9751E1E3/",scale={6.02,1,6.02}}
predefinedMaps.hellas.tiles={
tile:new({0,0,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({1,0,0},{},{resourceValues={Plants=2}}),
tile:new({2,0,0},{},{resourceValues={Plants=2}}),
tile:new({3,0,0},{},{resourceValues={Plants=1,Steel=1}}),
tile:new({4,0,0},{},{resourceValues={Plants=1}}),
tile:new({0,0,1},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,1,0},{},{resourceValues={Plants=2}}),
tile:new({1,1,0},{},{resourceValues={Plants=1}}),
tile:new({2,1,0},{},{resourceValues={Plants=1,Steel=1}}),
tile:new({3,1,0},{},{resourceValues={Plants=1}}),
tile:new({4,1,0},{},{resourceValues={Plants=1}}),
tile:new({0,0,2},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({0,1,1},{},{resourceValues={Plants=1}}),
tile:new({0,2,0},{},{resourceValues={Steel=1}}),
tile:new({1,2,0},{},{resourceValues={Steel=1}}),
tile:new({2,2,0},{},{}),
tile:new({3,2,0},{},{resourceValues={Plants=2}}),
tile:new({4,2,0},{},{resourceValues={Plants=1},effects={"DrawCard"}}),
tile:new({0,0,3},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({0,1,2},{},{resourceValues={Plants=1}}),
tile:new({0,2,1},{},{resourceValues={Steel=1}}),
tile:new({0,3,0},{},{resourceValues={Steel=2}}),
tile:new({1,3,0},{},{resourceValues={Steel=1}}),
tile:new({2,3,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({3,3,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({4,3,0},{},{resourceValues={Plants=1}}),
tile:new({0,0,4},{},{effects={"DrawCard"}}),
tile:new({0,1,3},{},{}),
tile:new({0,2,2},{},{}),
tile:new({0,3,1},{},{resourceValues={Steel=2}}),
tile:new({0,4,0},{},{}),
tile:new({1,4,0},{mapFeatures.tileType.ocean},{effects={"DrawCard"}}),
tile:new({2,4,0},{mapFeatures.tileType.ocean},{resourceValues={Heat=3}}),
tile:new({3,4,0},{mapFeatures.tileType.ocean},{}),
tile:new({4,4,0},{},{resourceValues={Plants=1}}),
tile:new({0,1,4},{},{resourceValues={Titanium=1}}),
tile:new({0,2,3},{},{}),
tile:new({0,3,2},{},{resourceValues={Steel=1}}),
tile:new({0,4,1},{},{}),
tile:new({0,5,0},{},{}),
tile:new({1,5,0},{mapFeatures.tileType.ocean},{}),
tile:new({2,5,0},{mapFeatures.tileType.ocean},{resourceValues={Steel=1}}),
tile:new({3,5,0},{},{}),
tile:new({0,2,4},{mapFeatures.tileType.ocean},{resourceValues={Titanium=2}}),
tile:new({0,3,3},{},{}),
tile:new({0,4,2},{},{}),
tile:new({0,5,1},{},{effects={"DrawCard"}}),
tile:new({0,6,0},{},{}),
tile:new({1,6,0},{},{}),
tile:new({2,6,0},{},{resourceValues={Titanium=1}}),
tile:new({0,3,4},{},{resourceValues={Steel=1}}),
tile:new({0,4,3},{},{effects={"DrawCard"}}),
tile:new({0,5,2},{},{resourceValues={Heat=2}}),
tile:new({0,6,1},{},{resourceValues={Heat=2}}),
tile:new({0,7,0},{},{resourceValues={Titanium=1}}),
tile:new({1,7,0},{},{resourceValues={Titanium=1}}),
tile:new({0,4,4},{},{}),
tile:new({0,5,3},{},{resourceValues={Heat=2}}),
tile:new({0,6,2},{},{resourceValues={Credits=-6},effects={"Ocean"}}),
tile:new({0,7,1},{},{resourceValues={Heat=2}}),
tile:new({0,8,0},{},{}),
}
predefinedMaps.elysium={}
predefinedMaps.elysium.metadata={offset={-5,1.4,8.6},hexDistance=2.475,imageUrl="http://cloud-3.steamusercontent.com/ugc/1750191431521690431/6DAAF654B42B1D2043031D73337389063CA41F0F/",scale={6.02,1,6.02}}
predefinedMaps.elysium.tiles={
tile:new({0,0,0},{mapFeatures.tileType.ocean},{}),
tile:new({1,0,0},{mapFeatures.tileType.ocean},{resourceValues={Titanium=1}}),
tile:new({2,0,0},{mapFeatures.tileType.ocean},{effects={"DrawCard"}}),
tile:new({3,0,0},{mapFeatures.tileType.ocean},{resourceValues={Steel=1}}),
tile:new({4,0,0},{},{effects={"DrawCard"}}),
tile:new({0,0,1},{mapFeatures.tileType.volcano},{resourceValues={Titanium=1}}),
tile:new({0,1,0},{},{}),
tile:new({1,1,0},{},{}),
tile:new({2,1,0},{mapFeatures.tileType.ocean},{}),
tile:new({3,1,0},{mapFeatures.tileType.ocean},{}),
tile:new({4,1,0},{},{resourceValues={Steel=2}}),
tile:new({0,0,2},{mapFeatures.tileType.volcano},{resourceValues={Titanium=2}}),
tile:new({0,1,1},{},{}),
tile:new({0,2,0},{},{effects={"DrawCard"}}),
tile:new({1,2,0},{},{}),
tile:new({2,2,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({3,2,0},{mapFeatures.tileType.ocean},{}),
tile:new({4,2,0},{mapFeatures.tileType.volcano},{effects={"DrawCard","DrawCard","DrawCard"}}),
tile:new({0,0,3},{},{resourceValues={Plants=1}}),
tile:new({0,1,2},{},{resourceValues={Plants=1}}),
tile:new({0,2,1},{},{resourceValues={Plants=1}}),
tile:new({0,3,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({1,3,0},{},{resourceValues={Plants=1}}),
tile:new({2,3,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({3,3,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({4,3,0},{},{resourceValues={Steel=1,Plants=1}}),
tile:new({0,0,4},{},{resourceValues={Plants=2}}),
tile:new({0,1,3},{},{resourceValues={Plants=2}}),
tile:new({0,2,2},{},{resourceValues={Plants=2}}),
tile:new({0,3,1},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,4,0},{},{resourceValues={Plants=2}}),
tile:new({1,4,0},{},{resourceValues={Plants=3}}),
tile:new({2,4,0},{},{resourceValues={Plants=2}}),
tile:new({3,4,0},{},{resourceValues={Plants=2}}),
tile:new({4,4,0},{mapFeatures.tileType.volcano},{resourceValues={Plants=1,Titanium=1}}),
tile:new({0,1,4},{},{resourceValues={Steel=1}}),
tile:new({0,2,3},{},{resourceValues={Plants=1}}),
tile:new({0,3,2},{},{resourceValues={Plants=1}}),
tile:new({0,4,1},{},{resourceValues={Plants=1}}),
tile:new({0,5,0},{},{resourceValues={Plants=1}}),
tile:new({1,5,0},{},{resourceValues={Plants=1}}),
tile:new({2,5,0},{},{resourceValues={Plants=1}}),
tile:new({3,5,0},{},{}),
tile:new({0,2,4},{},{resourceValues={Titanium=1}}),
tile:new({0,3,3},{},{resourceValues={Steel=1}}),
tile:new({0,4,2},{},{}),
tile:new({0,5,1},{},{}),
tile:new({0,6,0},{},{resourceValues={Steel=1}}),
tile:new({1,6,0},{},{}),
tile:new({2,6,0},{},{}),
tile:new({0,3,4},{},{resourceValues={Steel=2}}),
tile:new({0,4,3},{},{}),
tile:new({0,5,2},{},{}),
tile:new({0,6,1},{},{}),
tile:new({0,7,0},{},{resourceValues={Steel=2}}),
tile:new({1,7,0},{},{}),
tile:new({0,4,4},{},{resourceValues={Steel=1}}),
tile:new({0,5,3},{},{}),
tile:new({0,6,2},{},{effects={"DrawCard"}}),
tile:new({0,7,1},{},{effects={"DrawCard"}}),
tile:new({0,8,0},{},{resourceValues={Steel=2}}),
}
predefinedMaps.arabiaTerra={}
predefinedMaps.arabiaTerra.metadata={offset={-5,1.4,8.6},hexDistance=2.475,imageUrl="http://cloud-3.steamusercontent.com/ugc/1750191431521673411/5CFB2AC225720C89AA343E070F5626684F1B093F/",scale={6.02,1,6.02}}
predefinedMaps.arabiaTerra.tiles={
tile:new({0,0,0},{mapFeatures.tileType.ocean},{}),
tile:new({1,0,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({2,0,0},{},{}),
tile:new({3,0,0},{},{}),
tile:new({4,0,0},{mapFeatures.tileType.ocean},{effects={"DrawCard","DrawCard"}}),
tile:new({0,0,1},{mapFeatures.tileType.ocean},{effects={"Microbe","Microbe","DrawCard"}}),
tile:new({0,1,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({1,1,0},{},{resourceValues={Plants=2}}),
tile:new({2,1,0},{},{}),
tile:new({3,1,0},{},{resourceValues={Plants=1}}),
tile:new({4,1,0},{},{resourceValues={Plants=1}}),
tile:new({0,0,2},{},{resourceValues={Plants=1,Steel=1}}),
tile:new({0,1,1},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,2,0},{},{effects={"DrawCard","Data","Data"}}),
tile:new({1,2,0},{},{resourceValues={Steel=1}}),
tile:new({2,2,0},{},{resourceValues={Steel=1}}),
tile:new({3,2,0},{},{resourceValues={Steel=1,Plants=1}}),
tile:new({4,2,0},{mapFeatures.tileType.oceanOptional,mapFeatures.tileType.volcano},{resourceValues={Steel=1,Titanium=1}}),
tile:new({0,0,3},{},{resourceValues={Plants=2}}),
tile:new({0,1,2},{},{resourceValues={Plants=1}}),
tile:new({0,2,1},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,3,0},{},{}),
tile:new({1,3,0},{},{}),
tile:new({2,3,0},{},{}),
tile:new({3,3,0},{},{resourceValues={Steel=2}}),
tile:new({4,3,0},{},{}),
tile:new({0,0,4},{},{}),
tile:new({0,1,3},{},{}),
tile:new({0,2,2},{mapFeatures.tileType.ocean},{resourceValues={Steel=1}}),
tile:new({0,3,1},{mapFeatures.tileType.oceanOptional},{productionValues={Energy=1}}),
tile:new({0,4,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({1,4,0},{},{resourceValues={Steel=1},effects={"Science","DrawCard"}}),
tile:new({2,4,0},{},{}),
tile:new({3,4,0},{},{}),
tile:new({4,4,0},{},{}),
tile:new({0,1,4},{},{resourceValues={Plants=1}}),
tile:new({0,2,3},{},{resourceValues={Plants=1}}),
tile:new({0,3,2},{mapFeatures.tileType.ocean},{resourceValues={Steel=2}}),
tile:new({0,4,1},{},{resourceValues={Plants=1}}),
tile:new({0,5,0},{},{resourceValues={Steel=1}}),
tile:new({1,5,0},{},{}),
tile:new({2,5,0},{mapFeatures.tileType.oceanOptional},{resourceValues={Plants=1,Titanium=1}}),
tile:new({3,5,0},{},{resourceValues={Plants=1}}),
tile:new({0,2,4},{mapFeatures.tileType.oceanOptional},{resourceValues={Titanium=1,Plants=1}}),
tile:new({0,3,3},{mapFeatures.tileType.oceanOptional},{resourceValues={Plants=2}}),
tile:new({0,4,2},{mapFeatures.tileType.oceanOptional},{resourceValues={Plants=2}}),
tile:new({0,5,1},{},{resourceValues={Plants=1}}),
tile:new({0,6,0},{},{resourceValues={Steel=1}}),
tile:new({1,6,0},{},{resourceValues={Titanium=1,Plants=1}}),
tile:new({2,6,0},{},{resourceValues={Titanium=2}}),
tile:new({0,3,4},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,4,3},{},{resourceValues={Plants=1}}),
tile:new({0,5,2},{mapFeatures.tileType.volcano},{resourceValues={Steel=1},effects={"DrawCard"}}),
tile:new({0,6,1},{},{resourceValues={Steel=2}}),
tile:new({0,7,0},{},{resourceValues={Steel=1}}),
tile:new({1,7,0},{mapFeatures.tileType.volcano},{effects={"DrawCard"}}),
tile:new({0,4,4},{},{}),
tile:new({0,5,3},{},{}),
tile:new({0,6,2},{},{}),
tile:new({0,7,1},{},{}),
tile:new({0,8,0},{mapFeatures.tileType.volcano},{resourceValues={Steel=1}}),
}
predefinedMaps.arcadiaPlanitia={}
predefinedMaps.arcadiaPlanitia.metadata={
offset={-5.96,1.4,10.3},
hexDistance=2.385,
imageUrl="http://cloud-3.steamusercontent.com/ugc/1750191431521834562/70F4A02D0CB53A40C73DA3ACB499ED5E94F05104/",
scale={7.05,1,7.1},
globalParameterDefaultMappings={temperature={mappingIndex=5}},
size=91
}
predefinedMaps.arcadiaPlanitia.tiles={
tile:new({0,0,0},{},{}),
tile:new({1,0,0},{},{resourceValues={Heat=1}}),
tile:new({2,0,0},{},{resourceValues={Heat=2}}),
tile:new({3,0,0},{},{resourceValues={Heat=2}}),
tile:new({4,0,0},{},{resourceValues={Heat=1}}),
tile:new({5,0,0},{},{}),
tile:new({0,0,1},{},{resourceValues={Steel=1}}),
tile:new({0,1,0},{},{}),
tile:new({1,1,0},{},{effects={"DrawCard","DrawCard","DrawCard"}}),
tile:new({2,1,0},{},{}),
tile:new({3,1,0},{},{}),
tile:new({4,1,0},{},{}),
tile:new({5,1,0},{},{}),
tile:new({0,0,2},{},{resourceValues={Steel=1,Plants=1}}),
tile:new({0,1,1},{mapFeatures.tileType.ocean},{effects={"Microbe"}}),
tile:new({0,2,0},{},{resourceValues={Plants=1}}),
tile:new({1,2,0},{},{resourceValues={Plants=1}}),
tile:new({2,2,0},{},{}),
tile:new({3,2,0},{},{resourceValues={Plants=1}}),
tile:new({4,2,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({5,2,0},{mapFeatures.tileType.ocean},{effects={"Microbe","Microbe"}}),
tile:new({0,0,3},{},{resourceValues={Plants=1}}),
tile:new({0,1,2},{},{resourceValues={Plants=3}}),
tile:new({0,2,1},{mapFeatures.tileType.ocean},{effects={"DrawCard"}}),
tile:new({0,3,0},{},{resourceValues={Plants=2}}),
tile:new({1,3,0},{},{}),
tile:new({2,3,0},{mapFeatures.tileType.ocean},{effects={"DrawCard"}}),
tile:new({3,3,0},{},{resourceValues={Titanium=1}}),
tile:new({4,3,0},{},{resourceValues={Plants=2}}),
tile:new({5,3,0},{},{resourceValues={Plants=2}}),
tile:new({0,0,4},{},{resourceValues={Plants=1}}),
tile:new({0,1,3},{},{resourceValues={Plants=1}}),
tile:new({0,2,2},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,3,1},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({0,4,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({1,4,0},{mapFeatures.tileType.ocean},{resourceValues={Titanium=1}}),
tile:new({2,4,0},{mapFeatures.tileType.volcano},{resourceValues={Titanium=2}}),
tile:new({3,4,0},{},{}),
tile:new({4,4,0},{},{}),
tile:new({5,4,0},{},{resourceValues={Steel=2}}),
tile:new({0,0,5},{},{}),
tile:new({0,1,4},{},{resourceValues={Plants=1}}),
tile:new({0,2,3},{},{resourceValues={Plants=1}}),
tile:new({0,3,2},{mapFeatures.tileType.ocean},{resourceValues={Plants=1}}),
tile:new({0,4,1},{},{resourceValues={Plants=1}}),
tile:new({0,5,0},{},{}),
tile:new({1,5,0},{},{}),
tile:new({2,5,0},{},{}),
tile:new({3,5,0},{},{}),
tile:new({4,5,0},{mapFeatures.tileType.ocean},{resourceValues={Steel=1}}),
tile:new({5,5,0},{mapFeatures.tileType.ocean},{}),
tile:new({0,1,5},{},{resourceValues={Plants=1}}),
tile:new({0,2,4},{},{}),
tile:new({0,3,3},{},{}),
tile:new({0,4,2},{},{resourceValues={Plants=2}}),
tile:new({0,5,1},{},{resourceValues={Steel=1}}),
tile:new({0,6,0},{},{resourceValues={Titanium=1}}),
tile:new({1,6,0},{},{}),
tile:new({2,6,0},{},{}),
tile:new({3,6,0},{mapFeatures.tileType.volcano},{resourceValues={Steel=2}}),
tile:new({4,6,0},{mapFeatures.tileType.ocean},{resourceValues={Steel=2}}),
tile:new({0,2,5},{},{resourceValues={Plants=1}}),
tile:new({0,3,4},{},{resourceValues={Plants=1}}),
tile:new({0,4,3},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,5,2},{},{resourceValues={Titanium=1}}),
tile:new({0,6,1},{mapFeatures.tileType.volcano},{}),
tile:new({0,7,0},{},{resourceValues={Steel=1}}),
tile:new({1,7,0},{},{}),
tile:new({2,7,0},{},{resourceValues={Steel=1}}),
tile:new({3,7,0},{mapFeatures.tileType.volcano},{resourceValues={Steel=1},effects={"DrawCard"}}),
tile:new({0,3,5},{},{resourceValues={Steel=1}}),
tile:new({0,4,4},{mapFeatures.tileType.ocean},{effects={"DrawCard"}}),
tile:new({0,5,3},{},{resourceValues={Plants=1}}),
tile:new({0,6,2},{},{resourceValues={Steel=1}}),
tile:new({0,7,1},{},{resourceValues={Titanium=1}}),
tile:new({0,8,0},{},{}),
tile:new({1,8,0},{mapFeatures.tileType.volcano},{resourceValues={Titanium=1}}),
tile:new({2,8,0},{},{}),
tile:new({0,4,5},{},{resourceValues={Titanium=1}}),
tile:new({0,5,4},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,6,3},{},{}),
tile:new({0,7,2},{},{}),
tile:new({0,8,1},{mapFeatures.tileType.volcano},{resourceValues={Titanium=1}}),
tile:new({0,9,0},{mapFeatures.tileType.volcano},{resourceValues={Titanium=1},effects={"DrawCard"}}),
tile:new({1,9,0},{},{}),
tile:new({0,5,5},{},{}),
tile:new({0,6,4},{},{}),
tile:new({0,7,3},{},{resourceValues={Steel=1}}),
tile:new({0,8,2},{},{resourceValues={Steel=1}}),
tile:new({0,9,1},{},{}),
tile:new({0,10,0},{},{}),
}
predefinedMaps.aresPlaneta={}
predefinedMaps.aresPlaneta.metadata={
offset={-5,1.4,8.6},
hexDistance=2.475,
imageUrl="http://cloud-3.steamusercontent.com/ugc/1750191431522157718/AA7F672A7E83BCB68ACF0398B6357269A25D736F/",
scale={6.02,1,6.02},
globalParameterDefaultMappings={temperature={mappingIndex=1}},
size=61
}
predefinedMaps.aresPlaneta.tiles={
tile:new({0,0,0},{mapFeatures.tileType.ocean},{}),
tile:new({1,0,0},{},{}),
tile:new({2,0,0},{},{}),
tile:new({3,0,0},{},{resourceValues={Steel=2}}),
tile:new({4,0,0},{},{resourceValues={Credits=8}}),
tile:new({0,0,1},{},{resourceValues={Steel=-4,Titanium=1},effects={"Ocean"}}),
tile:new({0,1,0},{},{}),
tile:new({1,1,0},{},{}),
tile:new({2,1,0},{},{resourceValues={Steel=1}}),
tile:new({3,1,0},{},{resourceValues={Steel=1}}),
tile:new({4,1,0},{},{resourceValues={Steel=1,Plants=1}}),
tile:new({0,0,2},{},{resourceValues={Steel=1}}),
tile:new({0,1,1},{},{}),
tile:new({0,2,0},{},{resourceValues={Plants=1}}),
tile:new({1,2,0},{mapFeatures.tileType.ocean},{resourceValues={Steel=1,Titanium=1}}),
tile:new({2,2,0},{},{resourceValues={Titanium=2}}),
tile:new({3,2,0},{},{resourceValues={Plants=1}}),
tile:new({4,2,0},{},{resourceValues={Plants=1}}),
tile:new({0,0,3},{mapFeatures.tileType.ocean},{resourceValues={Steel=2},productionValues={Heat=1}}),
tile:new({0,1,2},{},{resourceValues={Steel=1,Plants=1}}),
tile:new({0,2,1},{},{resourceValues={Plants=1}}),
tile:new({0,3,0},{mapFeatures.tileType.ocean},{}),
tile:new({1,3,0},{},{}),
tile:new({2,3,0},{mapFeatures.tileType.ocean},{effects={"TradeToken"}}),
tile:new({3,3,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({4,3,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,0,4},{mapFeatures.tileType.ocean},{resourceValues={Heat=3}}),
tile:new({0,1,3},{},{resourceValues={Steel=1,Heat=1}}),
tile:new({0,2,2},{},{resourceValues={Plants=1}}),
tile:new({0,3,1},{},{resourceValues={Steel=1,Plants=1}}),
tile:new({0,4,0},{mapFeatures.tileType.ocean},{effects={"DrawCard","DrawCard"}}),
tile:new({1,4,0},{mapFeatures.tileType.ocean},{effects={"DrawCard"},resourceValues={Plants=1}}),
tile:new({2,4,0},{mapFeatures.tileType.oceanOptional},{}),
tile:new({3,4,0},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({4,4,0},{},{resourceValues={Steel=-3,Plants=1},effects={"TradeToken"}}),
tile:new({0,1,4},{mapFeatures.tileType.oceanOptional},{resourceValues={Heat=2}}),
tile:new({0,2,3},{},{}),
tile:new({0,3,2},{},{}),
tile:new({0,4,1},{},{}),
tile:new({0,5,0},{},{}),
tile:new({1,5,0},{},{}),
tile:new({2,5,0},{},{resourceValues={Plants=2}}),
tile:new({3,5,0},{},{resourceValues={Plants=1}}),
tile:new({0,2,4},{},{}),
tile:new({0,3,3},{},{resourceValues={Titanium=1}}),
tile:new({0,4,2},{},{}),
tile:new({0,5,1},{},{}),
tile:new({0,6,0},{},{}),
tile:new({1,6,0},{},{resourceValues={Plants=1}}),
tile:new({2,6,0},{},{resourceValues={Plants=1},effects={"Microbe","Microbe"}}),
tile:new({0,3,4},{},{resourceValues={Credits=-6},effects={"Colony"}}),
tile:new({0,4,3},{},{resourceValues={Titanium=1}}),
tile:new({0,5,2},{},{effects={"DrawCard"},resourceValues={Titanium=1}}),
tile:new({0,6,1},{},{resourceValues={Plants=3}}),
tile:new({0,7,0},{mapFeatures.tileType.oceanOptional},{resourceValues={Plants=1}}),
tile:new({1,7,0},{},{resourceValues={Plants=1},effects={"Microbe"}}),
tile:new({0,4,4},{},{effects={"TradeToken"}}),
tile:new({0,5,3},{},{}),
tile:new({0,6,2},{},{effects={"DrawCard"}}),
tile:new({0,7,1},{mapFeatures.tileType.ocean},{effects={"DrawCard"},resourceValues={Plants=1}}),
tile:new({0,8,0},{},{resourceValues={Plants=1}}),
}
predefinedMaps.olympiaPlanitia={}
predefinedMaps.olympiaPlanitia.metadata={
offset={-5,1.4,8.6},
hexDistance=2.475,
imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647892574050692/CA973CE28B1BC55D80F27B53904999FB4976660D/",
scale={6.02,1,6.02},
globalParameterDefaultMappings={temperature={mappingIndex=1}},
size=61
}
predefinedMaps.olympiaPlanitia.tiles={
tile:new({0,0,0},{},{resourceValues={Plants=1,Steel=1}}),
tile:new({1,0,0},{},{resourceValues={Plants=1}}),
tile:new({2,0,0},{},{effects={"DrawCard"}}),
tile:new({3,0,0},{},{resourceValues={Plants=1}}),
tile:new({4,0,0},{},{resourceValues={Plants=1,Steel=1}}),
tile:new({0,0,1},{},{resourceValues={Plants=1}}),
tile:new({0,1,0},{},{}),
tile:new({1,1,0},{},{resourceValues={Steel=1}}),
tile:new({2,1,0},{},{resourceValues={Steel=1,Titanium=1}}),
tile:new({3,1,0},{},{}),
tile:new({4,1,0},{},{resourceValues={Plants=1,Steel=1}}),
tile:new({0,0,2},{},{resourceValues={Plants=1}}),
tile:new({0,1,1},{},{effects={"DrawCard"}}),
tile:new({0,2,0},{mapFeatures.tileType.ocean},{resourceValues={Titanium=1}}),
tile:new({1,2,0},{mapFeatures.tileType.ocean},{}),
tile:new({2,2,0},{},{}),
tile:new({3,2,0},{},{}),
tile:new({4,2,0},{},{resourceValues={Plants=1}}),
tile:new({0,0,3},{},{resourceValues={Plants=2}}),
tile:new({0,1,2},{},{}),
tile:new({0,2,1},{mapFeatures.tileType.ocean},{resourceValues={Steel=1}}),
tile:new({0,3,0},{mapFeatures.tileType.ocean},{resourceValues={Heat=-6},effects={"Temp"}}),
tile:new({1,3,0},{mapFeatures.tileType.ocean},{resourceValues={Heat=-3,Steel=2},effects={"DrawCard"}}),
tile:new({2,3,0},{mapFeatures.tileType.ocean},{resourceValues={Titanium=1}}),
tile:new({3,3,0},{},{resourceValues={Steel=1}}),
tile:new({4,3,0},{},{resourceValues={Plants=1,Steel=1}}),
tile:new({0,0,4},{},{resourceValues={Plants=2}}),
tile:new({0,1,3},{},{}),
tile:new({0,2,2},{},{resourceValues={Titanium=1}}),
tile:new({0,3,1},{},{resourceValues={Heat=-3,Steel=2},effects={"DrawCard"}}),
tile:new({0,4,0},{},{}),
tile:new({1,4,0},{},{resourceValues={Heat=-6},effects={"Temp"}}),
tile:new({2,4,0},{},{effects={"DrawCard"}}),
tile:new({3,4,0},{},{}),
tile:new({4,4,0},{},{resourceValues={Steel=2}}),
tile:new({0,1,4},{},{resourceValues={Plants=2}}),
tile:new({0,2,3},{},{}),
tile:new({0,3,2},{mapFeatures.tileType.ocean},{resourceValues={Titanium=1,Steel=1}}),
tile:new({0,4,1},{mapFeatures.tileType.ocean},{resourceValues={Titanium=1,Steel=1,Heat=-3},effects={"DrawCard"}}),
tile:new({0,5,0},{},{resourceValues={Heat=-6},effects={"Temp"}}),
tile:new({1,5,0},{},{effects={"DrawCard"}}),
tile:new({2,5,0},{},{resourceValues={Titanium=1}}),
tile:new({3,5,0},{},{resourceValues={Plants=1}}),
tile:new({0,2,4},{mapFeatures.tileType.ocean},{resourceValues={Plants=2}}),
tile:new({0,3,3},{mapFeatures.tileType.ocean},{}),
tile:new({0,4,2},{},{}),
tile:new({0,5,1},{},{resourceValues={Titanium=1}}),
tile:new({0,6,0},{},{}),
tile:new({1,6,0},{},{}),
tile:new({2,6,0},{},{resourceValues={Plants=1}}),
tile:new({0,3,4},{mapFeatures.tileType.ocean},{resourceValues={Plants=1},effects={"DrawCard"}}),
tile:new({0,4,3},{mapFeatures.tileType.ocean},{effects={"DrawCard"}}),
tile:new({0,5,2},{},{}),
tile:new({0,6,1},{},{}),
tile:new({0,7,0},{},{resourceValues={Titanium=1}}),
tile:new({1,7,0},{},{resourceValues={Steel=2}}),
tile:new({0,4,4},{},{resourceValues={Plants=2}}),
tile:new({0,5,3},{},{resourceValues={Steel=1},effects={"DrawCard"}}),
tile:new({0,6,2},{},{resourceValues={Plants=1}}),
tile:new({0,7,1},{},{resourceValues={Plants=1}}),
tile:new({0,8,0},{},{resourceValues={Plants=1}}),
}
predefinedMaps.template={}
predefinedMaps.template.metadata={offset={-5,1.4,8.6},hexDistance=2.475,size=61}
predefinedMaps.template.tiles={
tile:new({0,0,0},{},{}),
tile:new({1,0,0},{},{}),
tile:new({2,0,0},{},{}),
tile:new({3,0,0},{},{}),
tile:new({4,0,0},{},{}),
tile:new({0,0,1},{},{}),
tile:new({0,1,0},{},{}),
tile:new({1,1,0},{},{}),
tile:new({2,1,0},{},{}),
tile:new({3,1,0},{},{}),
tile:new({4,1,0},{},{}),
tile:new({0,0,2},{},{}),
tile:new({0,1,1},{},{}),
tile:new({0,2,0},{},{}),
tile:new({1,2,0},{},{}),
tile:new({2,2,0},{},{}),
tile:new({3,2,0},{},{}),
tile:new({4,2,0},{},{}),
tile:new({0,0,3},{},{}),
tile:new({0,1,2},{},{}),
tile:new({0,2,1},{},{}),
tile:new({0,3,0},{},{}),
tile:new({1,3,0},{},{}),
tile:new({2,3,0},{},{}),
tile:new({3,3,0},{},{}),
tile:new({4,3,0},{},{}),
tile:new({0,0,4},{},{}),
tile:new({0,1,3},{},{}),
tile:new({0,2,2},{},{}),
tile:new({0,3,1},{},{}),
tile:new({0,4,0},{},{}),
tile:new({1,4,0},{},{}),
tile:new({2,4,0},{},{}),
tile:new({3,4,0},{},{}),
tile:new({4,4,0},{},{}),
tile:new({0,1,4},{},{}),
tile:new({0,2,3},{},{}),
tile:new({0,3,2},{},{}),
tile:new({0,4,1},{},{}),
tile:new({0,5,0},{},{}),
tile:new({1,5,0},{},{}),
tile:new({2,5,0},{},{}),
tile:new({3,5,0},{},{}),
tile:new({0,2,4},{},{}),
tile:new({0,3,3},{},{}),
tile:new({0,4,2},{},{}),
tile:new({0,5,1},{},{}),
tile:new({0,6,0},{},{}),
tile:new({1,6,0},{},{}),
tile:new({2,6,0},{},{}),
tile:new({0,3,4},{},{}),
tile:new({0,4,3},{},{}),
tile:new({0,5,2},{},{}),
tile:new({0,6,1},{},{}),
tile:new({0,7,0},{},{}),
tile:new({1,7,0},{},{}),
tile:new({0,4,4},{},{}),
tile:new({0,5,3},{},{}),
tile:new({0,6,2},{},{}),
tile:new({0,7,1},{},{}),
tile:new({0,8,0},{},{}),
}
predefinedVenusMaps={}
predefinedVenusMaps.baseMap={}
predefinedVenusMaps.baseMap.metadata={offset={-3.64,1.4,6.32},hexDistance=2.45,imageUrl="http://cloud-3.steamusercontent.com/ugc/1800854953427071872/95B75013E7E751FAFCF1D59B093AF6AB02BF9059/"}
predefinedVenusMaps.baseMap.tiles={
tile:new({0,2,0},{mapFeatures.tileType.stratopolis},{}),
tile:new({1,4,0},{mapFeatures.tileType.maxwellBase},{}),
}
predefinedVenusMaps.venusPhaseTwo={}
predefinedVenusMaps.venusPhaseTwo.metadata={offset={-3.64,1.4,6.32},
hexDistance=2.45,
imageUrl="http://cloud-3.steamusercontent.com/ugc/1651097841909490253/FAA3E53922C5634C15086438CCDDACFEAC5B1569/",
globalParameterDefaultMappings={venus={mappingIndex=2}},
bonusDefaultMappings={venus={mappingIndex=2}}}
predefinedVenusMaps.venusPhaseTwo.tiles={
tile:new({0,0,0},{mapFeatures.tileType.gas},{resourceValues={Heat=1}}),
tile:new({1,0,0},{},{}),
tile:new({2,0,0},{},{resourceValues={Energy=1}}),
tile:new({3,0,0},{},{}),
tile:new({0,0,1},{},{}),
tile:new({0,1,0},{},{}),
tile:new({1,1,0},{mapFeatures.tileType.gas},{resourceValues={Heat=1}}),
tile:new({2,1,0},{mapFeatures.tileType.gas},{resourceValues={Heat=3}}),
tile:new({3,1,0},{},{resourceValues={Energy=1}}),
tile:new({0,0,2},{},{effects={"DrawCard","DrawCard"}}),
tile:new({0,1,1},{mapFeatures.tileType.gas},{resourceValues={Heat=2}}),
tile:new({0,2,0},{mapFeatures.tileType.stratopolis},{}),
tile:new({1,2,0},{},{resourceValues={Energy=1}}),
tile:new({2,2,0},{mapFeatures.tileType.gas},{resourceValues={Heat=1}}),
tile:new({3,2,0},{},{}),
tile:new({0,1,2},{mapFeatures.tileType.gas},{resourceValues={Heat=1}}),
tile:new({0,2,1},{},{}),
tile:new({0,3,0},{},{}),
tile:new({1,3,0},{},{resourceValues={Energy=1}}),
tile:new({2,3,0},{},{}),
tile:new({0,1,3},{},{resourceValues={Energy=2}}),
tile:new({0,2,2},{},{resourceValues={Energy=1}}),
tile:new({0,3,1},{mapFeatures.tileType.gas},{resourceValues={Heat=2}}),
tile:new({0,4,0},{},{resourceValues={Energy=1}}),
tile:new({1,4,0},{mapFeatures.tileType.maxwellBase},{}),
tile:new({2,4,0},{mapFeatures.tileType.gas},{resourceValues={Heat=2}}),
tile:new({0,2,3},{},{}),
tile:new({0,3,2},{mapFeatures.tileType.gas},{resourceValues={Heat=1}}),
tile:new({0,4,1},{mapFeatures.tileType.gas},{resourceValues={Heat=1}}),
tile:new({0,5,0},{},{resourceValues={Energy=1}}),
tile:new({1,5,0},{mapFeatures.tileType.gas},{resourceValues={Heat=2}}),
tile:new({0,3,3},{},{resourceValues={Energy=1},effects={"DrawCard"}}),
tile:new({0,4,2},{mapFeatures.tileType.gas},{resourceValues={Heat=1}}),
tile:new({0,5,1},{},{}),
tile:new({0,6,0},{},{effects={"DrawCard","DrawCard"}}),
}


randomMapBaseImage="http://cloud-3.steamusercontent.com/ugc/1691647137526176806/F192EE4EF76ECE242559FF17E09F0549D95523FF/"
randomizerTemplates={}
randomizerTemplates.tiny={}
randomizerTemplates.tiny.metadata={
hexDistance=2.385,
offset={-3.5,1.4,6.3},
mapSize=mapSizes.tiny,
scale={4.8,1,4.8},
}
randomizerTemplates.tiny.tiles={
tile:new({0,0,0},{"empty"},{}),
tile:new({1,0,0},{"empty"},{}),
tile:new({2,0,0},{"empty"},{}),
tile:new({3,0,0},{"empty"},{}),
tile:new({0,0,1},{"empty"},{}),
tile:new({0,1,0},{"empty"},{}),
tile:new({1,1,0},{"empty"},{}),
tile:new({2,1,0},{"empty"},{}),
tile:new({3,1,0},{"empty"},{}),
tile:new({0,0,2},{"empty"},{}),
tile:new({0,1,1},{"empty"},{}),
tile:new({0,2,0},{"empty"},{}),
tile:new({1,2,0},{"empty"},{}),
tile:new({2,2,0},{"empty"},{}),
tile:new({3,2,0},{"empty"},{}),
tile:new({0,0,3},{"empty"},{}),
tile:new({0,1,2},{"empty"},{}),
tile:new({0,2,1},{"empty"},{}),
tile:new({0,3,0},{"empty"},{}),
tile:new({1,3,0},{"empty"},{}),
tile:new({2,3,0},{"empty"},{}),
tile:new({3,3,0},{"empty"},{}),
tile:new({0,1,3},{"empty"},{}),
tile:new({0,2,2},{"empty"},{}),
tile:new({0,3,1},{"empty"},{}),
tile:new({0,4,0},{"empty"},{}),
tile:new({1,4,0},{"empty"},{}),
tile:new({2,4,0},{"empty"},{}),
tile:new({0,2,3},{"empty"},{}),
tile:new({0,3,2},{"empty"},{}),
tile:new({0,4,1},{"empty"},{}),
tile:new({0,5,0},{"empty"},{}),
tile:new({1,5,0},{"empty"},{}),
tile:new({0,3,3},{"empty"},{}),
tile:new({0,4,2},{"empty"},{}),
tile:new({0,5,1},{"empty"},{}),
tile:new({0,6,0},{"empty"},{}),
}
randomizerTemplates.small={}
randomizerTemplates.small.metadata={
hexDistance=2.385,
offset={-5.96,1.4,6.3},
mapSize=mapSizes.small,
scale={5.55,1,5.55},
}
randomizerTemplates.small.tiles={
tile:new({0,0,0},{"empty"},{}),
tile:new({1,0,0},{"empty"},{}),
tile:new({2,0,0},{"empty"},{}),
tile:new({3,0,0},{"empty"},{}),
tile:new({4,0,0},{"empty"},{}),
tile:new({5,0,0},{"empty"},{}),
tile:new({0,0,1},{"empty"},{}),
tile:new({0,1,0},{"empty"},{}),
tile:new({1,1,0},{"empty"},{}),
tile:new({2,1,0},{"empty"},{}),
tile:new({3,1,0},{"empty"},{}),
tile:new({4,1,0},{"empty"},{}),
tile:new({5,1,0},{"empty"},{}),
tile:new({0,0,2},{"empty"},{}),
tile:new({0,1,1},{"empty"},{}),
tile:new({0,2,0},{"empty"},{}),
tile:new({1,2,0},{"empty"},{}),
tile:new({2,2,0},{"empty"},{}),
tile:new({3,2,0},{"empty"},{}),
tile:new({4,2,0},{"empty"},{}),
tile:new({5,2,0},{"empty"},{}),
tile:new({0,1,2},{"empty"},{}),
tile:new({0,2,1},{"empty"},{}),
tile:new({0,3,0},{"empty"},{}),
tile:new({1,3,0},{"empty"},{}),
tile:new({2,3,0},{"empty"},{}),
tile:new({3,3,0},{"empty"},{}),
tile:new({4,3,0},{"empty"},{}),
tile:new({0,1,3},{"empty"},{}),
tile:new({0,2,2},{"empty"},{}),
tile:new({0,3,1},{"empty"},{}),
tile:new({0,4,0},{"empty"},{}),
tile:new({1,4,0},{"empty"},{}),
tile:new({2,4,0},{"empty"},{}),
tile:new({3,4,0},{"empty"},{}),
tile:new({4,4,0},{"empty"},{}),
tile:new({0,2,3},{"empty"},{}),
tile:new({0,3,2},{"empty"},{}),
tile:new({0,4,1},{"empty"},{}),
tile:new({0,5,0},{"empty"},{}),
tile:new({1,5,0},{"empty"},{}),
tile:new({2,5,0},{"empty"},{}),
tile:new({3,5,0},{"empty"},{}),
tile:new({0,3,3},{"empty"},{}),
tile:new({0,4,2},{"empty"},{}),
tile:new({0,5,1},{"empty"},{}),
tile:new({0,6,0},{"empty"},{}),
tile:new({1,6,0},{"empty"},{}),
tile:new({2,6,0},{"empty"},{}),
}
randomizerTemplates.normal={}
randomizerTemplates.normal.metadata={
offset={-5,1.4,8.6},
hexDistance=2.475,
size=61,
mapSize=mapSizes.normal,
scale={6.29,1,6.29},
}
randomizerTemplates.normal.tiles={
tile:new({0,0,0},{"empty"},{}),
tile:new({1,0,0},{"empty"},{}),
tile:new({2,0,0},{"empty"},{}),
tile:new({3,0,0},{"empty"},{}),
tile:new({4,0,0},{"empty"},{}),
tile:new({0,0,1},{"empty"},{}),
tile:new({0,1,0},{"empty"},{}),
tile:new({1,1,0},{"empty"},{}),
tile:new({2,1,0},{"empty"},{}),
tile:new({3,1,0},{"empty"},{}),
tile:new({4,1,0},{"empty"},{}),
tile:new({0,0,2},{"empty"},{}),
tile:new({0,1,1},{"empty"},{}),
tile:new({0,2,0},{"empty"},{}),
tile:new({1,2,0},{"empty"},{}),
tile:new({2,2,0},{"empty"},{}),
tile:new({3,2,0},{"empty"},{}),
tile:new({4,2,0},{"empty"},{}),
tile:new({0,0,3},{"empty"},{}),
tile:new({0,1,2},{"empty"},{}),
tile:new({0,2,1},{"empty"},{}),
tile:new({0,3,0},{"empty"},{}),
tile:new({1,3,0},{"empty"},{}),
tile:new({2,3,0},{"empty"},{}),
tile:new({3,3,0},{"empty"},{}),
tile:new({4,3,0},{"empty"},{}),
tile:new({0,0,4},{"empty"},{}),
tile:new({0,1,3},{"empty"},{}),
tile:new({0,2,2},{"empty"},{}),
tile:new({0,3,1},{"empty"},{}),
tile:new({0,4,0},{"empty"},{}),
tile:new({1,4,0},{"empty"},{}),
tile:new({2,4,0},{"empty"},{}),
tile:new({3,4,0},{"empty"},{}),
tile:new({4,4,0},{"empty"},{}),
tile:new({0,1,4},{"empty"},{}),
tile:new({0,2,3},{"empty"},{}),
tile:new({0,3,2},{"empty"},{}),
tile:new({0,4,1},{"empty"},{}),
tile:new({0,5,0},{"empty"},{}),
tile:new({1,5,0},{"empty"},{}),
tile:new({2,5,0},{"empty"},{}),
tile:new({3,5,0},{"empty"},{}),
tile:new({0,2,4},{"empty"},{}),
tile:new({0,3,3},{"empty"},{}),
tile:new({0,4,2},{"empty"},{}),
tile:new({0,5,1},{"empty"},{}),
tile:new({0,6,0},{"empty"},{}),
tile:new({1,6,0},{"empty"},{}),
tile:new({2,6,0},{"empty"},{}),
tile:new({0,3,4},{"empty"},{}),
tile:new({0,4,3},{"empty"},{}),
tile:new({0,5,2},{"empty"},{}),
tile:new({0,6,1},{"empty"},{}),
tile:new({0,7,0},{"empty"},{}),
tile:new({1,7,0},{"empty"},{}),
tile:new({0,4,4},{"empty"},{}),
tile:new({0,5,3},{"empty"},{}),
tile:new({0,6,2},{"empty"},{}),
tile:new({0,7,1},{"empty"},{}),
tile:new({0,8,0},{"empty"},{}),
}
randomizerTemplates.big={}
randomizerTemplates.big.metadata={
hexDistance=2.385,
offset={-7.1,1.4,8.3},
mapSize=mapSizes.big,
scale={6.85,1,6.85},
}
randomizerTemplates.big.tiles={
tile:new({0,0,0},{"empty"},{}),
tile:new({1,0,0},{"empty"},{}),
tile:new({2,0,0},{"empty"},{}),
tile:new({3,0,0},{"empty"},{}),
tile:new({4,0,0},{"empty"},{}),
tile:new({5,0,0},{"empty"},{}),
tile:new({6,0,0},{"empty"},{}),
tile:new({0,0,1},{"empty"},{}),
tile:new({0,1,0},{"empty"},{}),
tile:new({1,1,0},{"empty"},{}),
tile:new({2,1,0},{"empty"},{}),
tile:new({3,1,0},{"empty"},{}),
tile:new({4,1,0},{"empty"},{}),
tile:new({5,1,0},{"empty"},{}),
tile:new({6,1,0},{"empty"},{}),
tile:new({0,0,2},{"empty"},{}),
tile:new({0,1,1},{"empty"},{}),
tile:new({0,2,0},{"empty"},{}),
tile:new({1,2,0},{"empty"},{}),
tile:new({2,2,0},{"empty"},{}),
tile:new({3,2,0},{"empty"},{}),
tile:new({4,2,0},{"empty"},{}),
tile:new({5,2,0},{"empty"},{}),
tile:new({6,2,0},{"empty"},{}),
tile:new({0,1,2},{"empty"},{}),
tile:new({0,2,1},{"empty"},{}),
tile:new({0,3,0},{"empty"},{}),
tile:new({1,3,0},{"empty"},{}),
tile:new({2,3,0},{"empty"},{}),
tile:new({3,3,0},{"empty"},{}),
tile:new({4,3,0},{"empty"},{}),
tile:new({5,3,0},{"empty"},{}),
tile:new({0,1,3},{"empty"},{}),
tile:new({0,2,2},{"empty"},{}),
tile:new({0,3,1},{"empty"},{}),
tile:new({0,4,0},{"empty"},{}),
tile:new({1,4,0},{"empty"},{}),
tile:new({2,4,0},{"empty"},{}),
tile:new({3,4,0},{"empty"},{}),
tile:new({4,4,0},{"empty"},{}),
tile:new({5,4,0},{"empty"},{}),
tile:new({0,2,3},{"empty"},{}),
tile:new({0,3,2},{"empty"},{}),
tile:new({0,4,1},{"empty"},{}),
tile:new({0,5,0},{"empty"},{}),
tile:new({1,5,0},{"empty"},{}),
tile:new({2,5,0},{"empty"},{}),
tile:new({3,5,0},{"empty"},{}),
tile:new({4,5,0},{"empty"},{}),
tile:new({0,2,4},{"empty"},{}),
tile:new({0,3,3},{"empty"},{}),
tile:new({0,4,2},{"empty"},{}),
tile:new({0,5,1},{"empty"},{}),
tile:new({0,6,0},{"empty"},{}),
tile:new({1,6,0},{"empty"},{}),
tile:new({2,6,0},{"empty"},{}),
tile:new({3,6,0},{"empty"},{}),
tile:new({4,6,0},{"empty"},{}),
tile:new({0,3,4},{"empty"},{}),
tile:new({0,4,3},{"empty"},{}),
tile:new({0,5,2},{"empty"},{}),
tile:new({0,6,1},{"empty"},{}),
tile:new({0,7,0},{"empty"},{}),
tile:new({1,7,0},{"empty"},{}),
tile:new({2,7,0},{"empty"},{}),
tile:new({3,7,0},{"empty"},{}),
tile:new({0,4,4},{"empty"},{}),
tile:new({0,5,3},{"empty"},{}),
tile:new({0,6,2},{"empty"},{}),
tile:new({0,7,1},{"empty"},{}),
tile:new({0,8,0},{"empty"},{}),
tile:new({1,8,0},{"empty"},{}),
tile:new({2,8,0},{"empty"},{}),
}
randomizerTemplates.large={}
randomizerTemplates.large.metadata={
hexDistance=2.385,
offset={-5.96,1.4,10.3},
size=91,
mapSize=mapSizes.large,
scale={7.34,1,7.34},
}
randomizerTemplates.large.tiles={
tile:new({0,0,0},{"empty"},{}),
tile:new({1,0,0},{"empty"},{}),
tile:new({2,0,0},{"empty"},{}),
tile:new({3,0,0},{"empty"},{}),
tile:new({4,0,0},{"empty"},{}),
tile:new({5,0,0},{"empty"},{}),
tile:new({0,0,1},{"empty"},{}),
tile:new({0,1,0},{"empty"},{}),
tile:new({1,1,0},{"empty"},{}),
tile:new({2,1,0},{"empty"},{}),
tile:new({3,1,0},{"empty"},{}),
tile:new({4,1,0},{"empty"},{}),
tile:new({5,1,0},{"empty"},{}),
tile:new({0,0,2},{"empty"},{}),
tile:new({0,1,1},{"empty"},{}),
tile:new({0,2,0},{"empty"},{}),
tile:new({1,2,0},{"empty"},{}),
tile:new({2,2,0},{"empty"},{}),
tile:new({3,2,0},{"empty"},{}),
tile:new({4,2,0},{"empty"},{}),
tile:new({5,2,0},{"empty"},{}),
tile:new({0,0,3},{"empty"},{}),
tile:new({0,1,2},{"empty"},{}),
tile:new({0,2,1},{"empty"},{}),
tile:new({0,3,0},{"empty"},{}),
tile:new({1,3,0},{"empty"},{}),
tile:new({2,3,0},{"empty"},{}),
tile:new({3,3,0},{"empty"},{}),
tile:new({4,3,0},{"empty"},{}),
tile:new({5,3,0},{"empty"},{}),
tile:new({0,0,4},{"empty"},{}),
tile:new({0,1,3},{"empty"},{}),
tile:new({0,2,2},{"empty"},{}),
tile:new({0,3,1},{"empty"},{}),
tile:new({0,4,0},{"empty"},{}),
tile:new({1,4,0},{"empty"},{}),
tile:new({2,4,0},{"empty"},{}),
tile:new({3,4,0},{"empty"},{}),
tile:new({4,4,0},{"empty"},{}),
tile:new({5,4,0},{"empty"},{}),
tile:new({0,0,5},{"empty"},{}),
tile:new({0,1,4},{"empty"},{}),
tile:new({0,2,3},{"empty"},{}),
tile:new({0,3,2},{"empty"},{}),
tile:new({0,4,1},{"empty"},{}),
tile:new({0,5,0},{"empty"},{}),
tile:new({1,5,0},{"empty"},{}),
tile:new({2,5,0},{"empty"},{}),
tile:new({3,5,0},{"empty"},{}),
tile:new({4,5,0},{"empty"},{}),
tile:new({5,5,0},{"empty"},{}),
tile:new({0,1,5},{"empty"},{}),
tile:new({0,2,4},{"empty"},{}),
tile:new({0,3,3},{"empty"},{}),
tile:new({0,4,2},{"empty"},{}),
tile:new({0,5,1},{"empty"},{}),
tile:new({0,6,0},{"empty"},{}),
tile:new({1,6,0},{"empty"},{}),
tile:new({2,6,0},{"empty"},{}),
tile:new({3,6,0},{"empty"},{}),
tile:new({4,6,0},{"empty"},{}),
tile:new({0,2,5},{"empty"},{}),
tile:new({0,3,4},{"empty"},{}),
tile:new({0,4,3},{"empty"},{}),
tile:new({0,5,2},{"empty"},{}),
tile:new({0,6,1},{"empty"},{}),
tile:new({0,7,0},{"empty"},{}),
tile:new({1,7,0},{"empty"},{}),
tile:new({2,7,0},{"empty"},{}),
tile:new({3,7,0},{"empty"},{}),
tile:new({0,3,5},{"empty"},{}),
tile:new({0,4,4},{"empty"},{}),
tile:new({0,5,3},{"empty"},{}),
tile:new({0,6,2},{"empty"},{}),
tile:new({0,7,1},{"empty"},{}),
tile:new({0,8,0},{"empty"},{}),
tile:new({1,8,0},{"empty"},{}),
tile:new({2,8,0},{"empty"},{}),
tile:new({0,4,5},{"empty"},{}),
tile:new({0,5,4},{"empty"},{}),
tile:new({0,6,3},{"empty"},{}),
tile:new({0,7,2},{"empty"},{}),
tile:new({0,8,1},{"empty"},{}),
tile:new({0,9,0},{"empty"},{}),
tile:new({1,9,0},{"empty"},{}),
tile:new({0,5,5},{"empty"},{}),
tile:new({0,6,4},{"empty"},{}),
tile:new({0,7,3},{"empty"},{}),
tile:new({0,8,2},{"empty"},{}),
tile:new({0,9,1},{"empty"},{}),
tile:new({0,10,0},{"empty"},{}),
}
randomizerTemplates.huge={}
randomizerTemplates.huge.metadata={
hexDistance=2.385,
offset={-7.1,1.4,12.2},
mapSize=mapSizes.huge,
scale={8.86,1,8.86},
}
randomizerTemplates.huge.tiles={
tile:new({0,0,0},{"empty"},{}),
tile:new({1,0,0},{"empty"},{}),
tile:new({2,0,0},{"empty"},{}),
tile:new({3,0,0},{"empty"},{}),
tile:new({4,0,0},{"empty"},{}),
tile:new({5,0,0},{"empty"},{}),
tile:new({6,0,0},{"empty"},{}),
tile:new({0,0,1},{"empty"},{}),
tile:new({0,1,0},{"empty"},{}),
tile:new({1,1,0},{"empty"},{}),
tile:new({2,1,0},{"empty"},{}),
tile:new({3,1,0},{"empty"},{}),
tile:new({4,1,0},{"empty"},{}),
tile:new({5,1,0},{"empty"},{}),
tile:new({6,1,0},{"empty"},{}),
tile:new({0,0,2},{"empty"},{}),
tile:new({0,1,1},{"empty"},{}),
tile:new({0,2,0},{"empty"},{}),
tile:new({1,2,0},{"empty"},{}),
tile:new({2,2,0},{"empty"},{}),
tile:new({3,2,0},{"empty"},{}),
tile:new({4,2,0},{"empty"},{}),
tile:new({5,2,0},{"empty"},{}),
tile:new({6,2,0},{"empty"},{}),
tile:new({0,0,3},{"empty"},{}),
tile:new({0,1,2},{"empty"},{}),
tile:new({0,2,1},{"empty"},{}),
tile:new({0,3,0},{"empty"},{}),
tile:new({1,3,0},{"empty"},{}),
tile:new({2,3,0},{"empty"},{}),
tile:new({3,3,0},{"empty"},{}),
tile:new({4,3,0},{"empty"},{}),
tile:new({5,3,0},{"empty"},{}),
tile:new({6,3,0},{"empty"},{}),
tile:new({0,0,4},{"empty"},{}),
tile:new({0,1,3},{"empty"},{}),
tile:new({0,2,2},{"empty"},{}),
tile:new({0,3,1},{"empty"},{}),
tile:new({0,4,0},{"empty"},{}),
tile:new({1,4,0},{"empty"},{}),
tile:new({2,4,0},{"empty"},{}),
tile:new({3,4,0},{"empty"},{}),
tile:new({4,4,0},{"empty"},{}),
tile:new({5,4,0},{"empty"},{}),
tile:new({6,4,0},{"empty"},{}),
tile:new({0,0,5},{"empty"},{}),
tile:new({0,1,4},{"empty"},{}),
tile:new({0,2,3},{"empty"},{}),
tile:new({0,3,2},{"empty"},{}),
tile:new({0,4,1},{"empty"},{}),
tile:new({0,5,0},{"empty"},{}),
tile:new({1,5,0},{"empty"},{}),
tile:new({2,5,0},{"empty"},{}),
tile:new({3,5,0},{"empty"},{}),
tile:new({4,5,0},{"empty"},{}),
tile:new({5,5,0},{"empty"},{}),
tile:new({6,5,0},{"empty"},{}),
tile:new({0,0,6},{"empty"},{}),
tile:new({0,1,5},{"empty"},{}),
tile:new({0,2,4},{"empty"},{}),
tile:new({0,3,3},{"empty"},{}),
tile:new({0,4,2},{"empty"},{}),
tile:new({0,5,1},{"empty"},{}),
tile:new({0,6,0},{"empty"},{}),
tile:new({1,6,0},{"empty"},{}),
tile:new({2,6,0},{"empty"},{}),
tile:new({3,6,0},{"empty"},{}),
tile:new({4,6,0},{"empty"},{}),
tile:new({5,6,0},{"empty"},{}),
tile:new({6,6,0},{"empty"},{}),
tile:new({0,1,6},{"empty"},{}),
tile:new({0,2,5},{"empty"},{}),
tile:new({0,3,4},{"empty"},{}),
tile:new({0,4,3},{"empty"},{}),
tile:new({0,5,2},{"empty"},{}),
tile:new({0,6,1},{"empty"},{}),
tile:new({0,7,0},{"empty"},{}),
tile:new({1,7,0},{"empty"},{}),
tile:new({2,7,0},{"empty"},{}),
tile:new({3,7,0},{"empty"},{}),
tile:new({4,7,0},{"empty"},{}),
tile:new({5,7,0},{"empty"},{}),
tile:new({0,2,6},{"empty"},{}),
tile:new({0,3,5},{"empty"},{}),
tile:new({0,4,4},{"empty"},{}),
tile:new({0,5,3},{"empty"},{}),
tile:new({0,6,2},{"empty"},{}),
tile:new({0,7,1},{"empty"},{}),
tile:new({0,8,0},{"empty"},{}),
tile:new({1,8,0},{"empty"},{}),
tile:new({2,8,0},{"empty"},{}),
tile:new({3,8,0},{"empty"},{}),
tile:new({4,8,0},{"empty"},{}),
tile:new({0,3,6},{"empty"},{}),
tile:new({0,4,5},{"empty"},{}),
tile:new({0,5,4},{"empty"},{}),
tile:new({0,6,3},{"empty"},{}),
tile:new({0,7,2},{"empty"},{}),
tile:new({0,8,1},{"empty"},{}),
tile:new({0,9,0},{"empty"},{}),
tile:new({1,9,0},{"empty"},{}),
tile:new({2,9,0},{"empty"},{}),
tile:new({3,9,0},{"empty"},{}),
tile:new({0,4,6},{"empty"},{}),
tile:new({0,5,5},{"empty"},{}),
tile:new({0,6,4},{"empty"},{}),
tile:new({0,7,3},{"empty"},{}),
tile:new({0,8,2},{"empty"},{}),
tile:new({0,9,1},{"empty"},{}),
tile:new({0,10,0},{"empty"},{}),
tile:new({1,10,0},{"empty"},{}),
tile:new({2,10,0},{"empty"},{}),
tile:new({0,5,6},{"empty"},{}),
tile:new({0,6,5},{"empty"},{}),
tile:new({0,7,4},{"empty"},{}),
tile:new({0,8,3},{"empty"},{}),
tile:new({0,9,2},{"empty"},{}),
tile:new({0,10,1},{"empty"},{}),
tile:new({0,11,0},{"empty"},{}),
tile:new({1,11,0},{"empty"},{}),
tile:new({0,6,6},{"empty"},{}),
tile:new({0,7,5},{"empty"},{}),
tile:new({0,8,4},{"empty"},{}),
tile:new({0,9,3},{"empty"},{}),
tile:new({0,10,2},{"empty"},{}),
tile:new({0,11,1},{"empty"},{}),
tile:new({0,12,0},{"empty"},{}),
}
randomizerTemplates.gigantic={}
randomizerTemplates.gigantic.metadata={
hexDistance=2.385,
offset={-8.365,1.4,14.2},
mapSize=mapSizes.gigantic,
scale={8.97,1,8.97},
}
randomizerTemplates.gigantic.tiles={
tile:new({1,0,0},{"empty"},{}),
tile:new({2,0,0},{"empty"},{}),
tile:new({3,0,0},{"empty"},{}),
tile:new({4,0,0},{"empty"},{}),
tile:new({5,0,0},{"empty"},{}),
tile:new({6,0,0},{"empty"},{}),
tile:new({0,0,1},{"empty"},{}),
tile:new({0,1,0},{"empty"},{}),
tile:new({1,1,0},{"empty"},{}),
tile:new({2,1,0},{"empty"},{}),
tile:new({3,1,0},{"empty"},{}),
tile:new({4,1,0},{"empty"},{}),
tile:new({5,1,0},{"empty"},{}),
tile:new({6,1,0},{"empty"},{}),
tile:new({7,1,0},{"empty"},{}),
tile:new({0,0,2},{"empty"},{}),
tile:new({0,1,1},{"empty"},{}),
tile:new({0,2,0},{"empty"},{}),
tile:new({1,2,0},{"empty"},{}),
tile:new({2,2,0},{"empty"},{}),
tile:new({3,2,0},{"empty"},{}),
tile:new({4,2,0},{"empty"},{}),
tile:new({5,2,0},{"empty"},{}),
tile:new({6,2,0},{"empty"},{}),
tile:new({7,2,0},{"empty"},{}),
tile:new({0,0,3},{"empty"},{}),
tile:new({0,1,2},{"empty"},{}),
tile:new({0,2,1},{"empty"},{}),
tile:new({0,3,0},{"empty"},{}),
tile:new({1,3,0},{"empty"},{}),
tile:new({2,3,0},{"empty"},{}),
tile:new({3,3,0},{"empty"},{}),
tile:new({4,3,0},{"empty"},{}),
tile:new({5,3,0},{"empty"},{}),
tile:new({6,3,0},{"empty"},{}),
tile:new({7,3,0},{"empty"},{}),
tile:new({0,0,4},{"empty"},{}),
tile:new({0,1,3},{"empty"},{}),
tile:new({0,2,2},{"empty"},{}),
tile:new({0,3,1},{"empty"},{}),
tile:new({0,4,0},{"empty"},{}),
tile:new({1,4,0},{"empty"},{}),
tile:new({2,4,0},{"empty"},{}),
tile:new({3,4,0},{"empty"},{}),
tile:new({4,4,0},{"empty"},{}),
tile:new({5,4,0},{"empty"},{}),
tile:new({6,4,0},{"empty"},{}),
tile:new({7,4,0},{"empty"},{}),
tile:new({0,0,5},{"empty"},{}),
tile:new({0,1,4},{"empty"},{}),
tile:new({0,2,3},{"empty"},{}),
tile:new({0,3,2},{"empty"},{}),
tile:new({0,4,1},{"empty"},{}),
tile:new({0,5,0},{"empty"},{}),
tile:new({1,5,0},{"empty"},{}),
tile:new({2,5,0},{"empty"},{}),
tile:new({3,5,0},{"empty"},{}),
tile:new({4,5,0},{"empty"},{}),
tile:new({5,5,0},{"empty"},{}),
tile:new({6,5,0},{"empty"},{}),
tile:new({7,5,0},{"empty"},{}),
tile:new({0,1,5},{"empty"},{}),
tile:new({0,2,4},{"empty"},{}),
tile:new({0,3,3},{"empty"},{}),
tile:new({0,4,2},{"empty"},{}),
tile:new({0,5,1},{"empty"},{}),
tile:new({0,6,0},{"empty"},{}),
tile:new({1,6,0},{"empty"},{}),
tile:new({2,6,0},{"empty"},{}),
tile:new({3,6,0},{"empty"},{}),
tile:new({4,6,0},{"empty"},{}),
tile:new({5,6,0},{"empty"},{}),
tile:new({6,6,0},{"empty"},{}),
tile:new({0,1,6},{"empty"},{}),
tile:new({0,2,5},{"empty"},{}),
tile:new({0,3,4},{"empty"},{}),
tile:new({0,4,3},{"empty"},{}),
tile:new({0,5,2},{"empty"},{}),
tile:new({0,6,1},{"empty"},{}),
tile:new({0,7,0},{"empty"},{}),
tile:new({1,7,0},{"empty"},{}),
tile:new({2,7,0},{"empty"},{}),
tile:new({3,7,0},{"empty"},{}),
tile:new({4,7,0},{"empty"},{}),
tile:new({5,7,0},{"empty"},{}),
tile:new({6,7,0},{"empty"},{}),
tile:new({0,2,6},{"empty"},{}),
tile:new({0,3,5},{"empty"},{}),
tile:new({0,4,4},{"empty"},{}),
tile:new({0,5,3},{"empty"},{}),
tile:new({0,6,2},{"empty"},{}),
tile:new({0,7,1},{"empty"},{}),
tile:new({0,8,0},{"empty"},{}),
tile:new({1,8,0},{"empty"},{}),
tile:new({2,8,0},{"empty"},{}),
tile:new({3,8,0},{"empty"},{}),
tile:new({4,8,0},{"empty"},{}),
tile:new({5,8,0},{"empty"},{}),
tile:new({0,2,7},{"empty"},{}),
tile:new({0,3,6},{"empty"},{}),
tile:new({0,4,5},{"empty"},{}),
tile:new({0,5,4},{"empty"},{}),
tile:new({0,6,3},{"empty"},{}),
tile:new({0,7,2},{"empty"},{}),
tile:new({0,8,1},{"empty"},{}),
tile:new({0,9,0},{"empty"},{}),
tile:new({1,9,0},{"empty"},{}),
tile:new({2,9,0},{"empty"},{}),
tile:new({3,9,0},{"empty"},{}),
tile:new({4,9,0},{"empty"},{}),
tile:new({5,9,0},{"empty"},{}),
tile:new({0,3,7},{"empty"},{}),
tile:new({0,4,6},{"empty"},{}),
tile:new({0,5,5},{"empty"},{}),
tile:new({0,6,4},{"empty"},{}),
tile:new({0,7,3},{"empty"},{}),
tile:new({0,8,2},{"empty"},{}),
tile:new({0,9,1},{"empty"},{}),
tile:new({0,10,0},{"empty"},{}),
tile:new({1,10,0},{"empty"},{}),
tile:new({2,10,0},{"empty"},{}),
tile:new({3,10,0},{"empty"},{}),
tile:new({4,10,0},{"empty"},{}),
tile:new({0,4,7},{"empty"},{}),
tile:new({0,5,6},{"empty"},{}),
tile:new({0,6,5},{"empty"},{}),
tile:new({0,7,4},{"empty"},{}),
tile:new({0,8,3},{"empty"},{}),
tile:new({0,9,2},{"empty"},{}),
tile:new({0,10,1},{"empty"},{}),
tile:new({0,11,0},{"empty"},{}),
tile:new({1,11,0},{"empty"},{}),
tile:new({2,11,0},{"empty"},{}),
tile:new({3,11,0},{"empty"},{}),
tile:new({0,5,7},{"empty"},{}),
tile:new({0,6,6},{"empty"},{}),
tile:new({0,7,5},{"empty"},{}),
tile:new({0,8,4},{"empty"},{}),
tile:new({0,9,3},{"empty"},{}),
tile:new({0,10,2},{"empty"},{}),
tile:new({0,11,1},{"empty"},{}),
tile:new({0,12,0},{"empty"},{}),
tile:new({1,12,0},{"empty"},{}),
tile:new({2,12,0},{"empty"},{}),
tile:new({0,6,7},{"empty"},{}),
tile:new({0,7,6},{"empty"},{}),
tile:new({0,8,5},{"empty"},{}),
tile:new({0,9,4},{"empty"},{}),
tile:new({0,10,3},{"empty"},{}),
tile:new({0,11,2},{"empty"},{}),
tile:new({0,12,1},{"empty"},{}),
tile:new({0,13,0},{"empty"},{}),
tile:new({1,13,0},{"empty"},{}),
tile:new({0,8,6},{"empty"},{}),
tile:new({0,9,5},{"empty"},{}),
tile:new({0,10,4},{"empty"},{}),
tile:new({0,11,3},{"empty"},{}),
tile:new({0,12,2},{"empty"},{}),
tile:new({0,13,1},{"empty"},{}),
}


randomizerTiles={}
randomizerTiles.volcanoTiles={
{remaining=1,features={mapFeatures.tileType.volcano},placementProperties={resourceValues={Plants=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276174476/69EFF6BFFA3053DBE06173A1F81FDAA44522601C/"},
{remaining=1,features={mapFeatures.tileType.volcano},placementProperties={resourceValues={Plants=1,Titanium=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276174203/B1FB2D4D44B2701EBCD2C9C4BBFCF555A66F2C13/"},
{remaining=1,features={mapFeatures.tileType.volcano},placementProperties={resourceValues={Steel=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276174020/7DE5A3ECC5199F459EE66E3CA7FEC666EF09D6A2/"},
{remaining=1,features={mapFeatures.tileType.volcano},placementProperties={effects={"DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276174356/1DCB0D3CFB0EA4CEA4392B3D778CA6E173DEEA36/"},
}
randomizerTiles.reservedTiles={
{remaining=1,features={mapFeatures.tileType.nocticsCity},placementProperties={resourceValues={Plants=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173866/A36AC575A6DE51FEC13529786E6D93A79AB4FBCC/"},
}
randomizerTiles.oceanTiles={
{remaining=6,features={mapFeatures.tileType.ocean},placementProperties={resourceValues={Plants=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276172714/A97E5F3A99AC132CD303F8D7A7F9BBB209D9B18C/"},
{remaining=4,features={mapFeatures.tileType.ocean},placementProperties={resourceValues={Plants=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276172565/2E14B3403D5D083CCBF4119915181F92EF850EA9/"},
{remaining=1,features={mapFeatures.tileType.ocean},placementProperties={resourceValues={Heat=3}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276171463/F299153F83871938FC8129FD19F57B413CB17C75/"},
{remaining=1,features={mapFeatures.tileType.ocean},placementProperties={},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276171626/E165D401D1E549E3C0349998489C6D7B83DBE1B8/"},
{remaining=1,features={mapFeatures.tileType.ocean},placementProperties={resourceValues={Titanium=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276171743/0985449E915581E48BE21BED2CDC8944C0E26420/"},
{remaining=1,features={mapFeatures.tileType.ocean},placementProperties={resourceValues={Titanium=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276171844/0068DB58F95659EAC7035BBADF8C1321A3FF6804/"},
{remaining=1,features={mapFeatures.tileType.ocean},placementProperties={resourceValues={Steel=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276172145/648F7FF808250F39AA5F8AA72F6EC4DE704F786D/"},
{remaining=1,features={mapFeatures.tileType.ocean},placementProperties={resourceValues={Steel=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276171968/65EE0E46075C156419F3F5132625E7E6893A4501/"},
{remaining=1,features={mapFeatures.tileType.ocean},placementProperties={effects={"DrawCard","DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276172276/664D6FAA3EAF07C6192861827C45D12A6B15E3C3/"},
{remaining=1,features={mapFeatures.tileType.ocean},placementProperties={effects={"DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276172398/4C4CB43FE8B651FD75D10FA6F204F61D1A616DF6/"},
}
randomizerTiles.blockedTiles={
{remaining=1,features={mapFeatures.tileType.ocean},placementProperties={},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276172398/4C4CB43FE8B651FD75D10FA6F204F61D1A616DF6/"}
}
randomizerTiles.emptyTiles={
{remaining=24,features={},placementProperties={},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173555/05B1F3924752F711D9525674ECC1AB208BB81CA8/"},
}
randomizerTiles.bonusTiles={
{remaining=2,features={},placementProperties={effects={"DrawCard","DrawCard","DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170256704/5BCFAB470630D7AA88AF76B730394F157ECE6C6A/"},
{remaining=1,features={},placementProperties={effects={"DrawCard","DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/773980614477046158/92CD8A5A35B90CB782C72A7D27A2A63B4F47B037/"},
{remaining=3,features={},placementProperties={effects={"DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173140/9370071D162613CF37F0E8FF1A92E4268348A1FC/"},
{remaining=1,features={},placementProperties={resourceValues={Titanium=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173243/CB918F242EC4907838BC79CA4D8D621114BF4DBA/"},
{remaining=1,features={},placementProperties={resourceValues={Titanium=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173363/ABECC4CF05A2DD2396C4E21512F64BDFCF59FC52/"},
{remaining=3,features={},placementProperties={resourceValues={Steel=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276172944/D1F0D0D7470754942FC405077D0E0B803715BFCC/"},
{remaining=3,features={},placementProperties={resourceValues={Steel=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276172839/9351906A06DAA9DAE11DEB23B8E18458F4A965A3/"},
{remaining=1,features={},placementProperties={resourceValues={Plants=3}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173750/C99FFD8D10BEE02F0F64C1434B8F2BA1645FEDB2/"},
{remaining=9,features={},placementProperties={resourceValues={Plants=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173454/E923B227C2DBE946E354CB5C5ADEFE37914430EE/"},
{remaining=13,features={},placementProperties={resourceValues={Plants=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173043/91C3BF9DEC7D0C6168938370769D5993B8F44CC0/"},
{remaining=1,features={},placementProperties={resourceValues={Heat=3}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173655/FAB7A7854CD970B64442630CF90FB930FBFBD0E5/"},
}
randomizerTiles.regularTiles={
{remaining=2,features={},placementProperties={effects={"DrawCard","DrawCard","DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170256704/5BCFAB470630D7AA88AF76B730394F157ECE6C6A/"},
{remaining=1,features={},placementProperties={effects={"DrawCard","DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/773980614477046158/92CD8A5A35B90CB782C72A7D27A2A63B4F47B037/"},
{remaining=3,features={},placementProperties={effects={"DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173140/9370071D162613CF37F0E8FF1A92E4268348A1FC/"},
{remaining=1,features={},placementProperties={resourceValues={Titanium=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173243/CB918F242EC4907838BC79CA4D8D621114BF4DBA/"},
{remaining=1,features={},placementProperties={resourceValues={Titanium=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173363/ABECC4CF05A2DD2396C4E21512F64BDFCF59FC52/"},
{remaining=3,features={},placementProperties={resourceValues={Steel=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276172944/D1F0D0D7470754942FC405077D0E0B803715BFCC/"},
{remaining=3,features={},placementProperties={resourceValues={Steel=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276172839/9351906A06DAA9DAE11DEB23B8E18458F4A965A3/"},
{remaining=1,features={},placementProperties={resourceValues={Plants=3}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173750/C99FFD8D10BEE02F0F64C1434B8F2BA1645FEDB2/"},
{remaining=9,features={},placementProperties={resourceValues={Plants=2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173454/E923B227C2DBE946E354CB5C5ADEFE37914430EE/"},
{remaining=13,features={},placementProperties={resourceValues={Plants=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173043/91C3BF9DEC7D0C6168938370769D5993B8F44CC0/"},
{remaining=1,features={},placementProperties={resourceValues={Heat=3}},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173655/FAB7A7854CD970B64442630CF90FB930FBFBD0E5/"},
{remaining=24,features={},placementProperties={},imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276173555/05B1F3924752F711D9525674ECC1AB208BB81CA8/"},
}
randomizerTiles.randomizerTileExpansion={
{remaining=1,features={mapFeatures.tileType.oceanOptional},placementProperties={effects={"DrawCard","Microbe","Microbe"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170252910/CAF687BCE77E8EF2FAACC64493489E3C138A6137/"},
{remaining=0,features={},placementProperties={effects={"DrawCard","Data","Data"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170254771/029537720DD6F8653580BCA2DB72CDCFDD2B5329/"},
{remaining=1,features={},placementProperties={effects={"TR"},resourceValues={Credits=-4}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170259469/9899983B222F087F18BC8A5334771A0757763727/"},
{remaining=1,features={},placementProperties={effects={"Ocean"},resourceValues={Plants=-3}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170261128/70C5814D27E16C1FB46BD08D64A4990477E4FD93/"},
{remaining=1,features={},placementProperties={effects={"Temp","DrawCard"},resourceValues={Energy=-3}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170265759/424EA49E902B71144645A6D4CC17789E79D5D27F/"},
{remaining=1,features={},placementProperties={resourceValues={Steel=2,Titanium=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170255817/6F6722BD68D0C83057390D2D9F174C5391FA6C35/"},
{remaining=1,features={},placementProperties={resourceValues={Steel=1},effects={"DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170264590/17EF527183A2220F001E0090DFC0914B70F3A43E/"},
{remaining=1,features={},placementProperties={resourceValues={Steel=1},effects={"DrawCard","Science"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170258729/B3FA06FD5FE098B382323D0F0C2ABA5EEAFB3F98/"},
{remaining=1,features={},placementProperties={effects={"WildCardToken","WildCardToken"},resourceValues={Credits=-2}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170457551/D629787C2E005F75E4C0A04D5998333CA61DB93A/"},
{remaining=1,features={},placementProperties={effects={"DrawCard"},resourceValues={Titanium=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170262189/1300E76B9DAA18FBD2D0251333805F085AEF78E8/"},
{remaining=1,features={mapFeatures.tileType.oceanOptional},placementProperties={resourceValues={Credits=-5}},adjacenyEffects={resourceValues={Plants=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1665730758170257517/329D1B6BC14F96CAD847E918FEEFD86B1F62B80D/"},
}
randomizerTiles.mapOceansPositions={
{{1,0,0},{2,0,0},{0,0,2},{0,0,3},{4,2,0},{4,3,0},{1,2,0},{1,3,0},{0,3,0},{0,4,0},{0,3,1},{0,4,1},{0,3,2},{0,4,2},{0,3,3},{0,4,3},{0,3,4},{0,4,4}},
{{2,0,0},{2,1,0},{1,2,0},{1,3,0},{0,3,0},{0,4,0},{0,2,2},{0,3,1},{1,4,0},{2,4,0},{0,5,0},{0,4,1},{0,5,1},{0,6,1},{0,6,2},{0,8,0},{4,4,0},{0,0,4}},
{{2,0,0},{2,1,0},{1,2,0},{1,3,0},{0,3,0},{0,4,0},{0,2,2},{0,3,1},{1,4,0},{2,4,0},{0,5,0},{0,4,1},{0,5,1},{0,6,1},{0,6,2},{0,8,0},{4,4,0},{0,0,4}},
{{0,0,0},{1,0,0},{0,0,1},{3,0,0},{4,0,0},{4,1,0},{0,0,3},{0,1,2},{0,1,3},{0,2,2},{0,3,1},{0,4,0},{1,4,0},{0,4,1},{1,5,0},{2,5,0},{0,4,4},{0,8,0}},
{{3,0,0},{4,0,0},{4,1,0},{0,2,0},{0,3,0},{1,3,0},{0,3,1},{0,5,0},{0,5,1},{3,5,0},{2,6,0},{1,7,0},{0,7,1},{0,6,2},{0,5,3},{0,2,4},{0,1,4},{0,0,4}},
{{0,0,1},{0,0,2},{3,0,0},{2,1,0},{3,1,0},{2,2,0},{3,2,0},{2,3,0},{3,3,0},{3,4,0},{3,5,0},{1,7,0},{0,8,0},{0,5,2},{0,5,3},{0,4,4},{0,3,4},{0,3,3}},
{{4,3,0},{4,4,0},{3,5,0},{0,6,0},{0,7,0},{0,6,1},{0,7,1},{0,2,3},{0,3,2},{0,1,3},{0,2,2},{0,3,1},{0,2,1},{0,1,2},{2,1,0},{2,2,0},{3,0,0},{3,1,0}},
{{4,1,0},{4,2,0},{3,1,0},{3,2,0},{2,3,0},{2,4,0},{1,3,0},{1,4,0},{0,4,0},{0,5,0},{1,5,0},{0,5,1},{0,4,2},{0,5,2},{0,6,1},{0,6,2},{0,4,3},{0,5,3}},
{{0,0,0},{1,0,0},{2,0,0},{3,0,0},{0,0,1},{0,0,2},{0,0,3},{0,0,4},{0,1,4},{0,2,4},{0,3,4},{0,4,4},{0,5,3},{0,6,2},{0,7,1},{0,8,0},{1,7,0},{2,6,0}},
{{0,0,0},{1,0,0},{2,0,0},{3,0,0},{4,0,0},{4,1,0},{4,2,0},{4,3,0},{4,4,0},{3,5,0},{2,6,0},{1,7,0},{0,8,0},{0,7,1},{0,6,2},{0,5,3},{0,4,4},{0,3,4}},
{{1,1,0},{2,1,0},{0,2,0},{2,2,0},{0,1,2},{0,2,1},{0,1,3},{0,2,3},{0,3,2},{0,4,2},{0,5,2},{0,6,1},{0,6,0},{1,5,0},{2,5,0},{3,4,0},{3,3,0},{2,3,0}},
{{0,0,0},{0,0,1},{0,1,0},{3,0,0},{4,0,0},{3,1,0},{4,3,0},{3,4,0},{4,4,0},{1,6,0},{2,6,0},{1,7,0},{0,5,2},{0,5,3},{0,6,2},{0,0,4},{0,1,3},{0,1,4}},
{{2,1,0},{2,2,0},{2,3,0},{2,4,0},{2,5,0},{1,4,0},{0,2,0},{1,2,0},{0,2,1},{0,3,0},{0,1,2},{0,2,2},{0,4,0},{0,5,0},{0,3,2},{0,4,1},{0,4,2},{0,5,2}},
{{2,0,0},{1,1,0},{2,1,0},{1,2,0},{1,3,0},{0,0,4},{0,1,3},{0,2,2},{0,3,1},{0,4,0},{1,4,0},{2,4,0},{3,4,0},{4,4,0},{0,4,1},{0,5,1},{0,5,2},{1,6,0}},
{{3,0,0},{4,0,0},{3,1,0},{4,1,0},{0,2,0},{0,0,3},{0,1,2},{0,2,1},{0,3,0},{0,3,1},{0,5,0},{0,6,0},{1,6,0},{0,7,0},{1,7,0},{0,3,4},{0,4,4},{0,5,3}},
}
randomizerTiles.baseTileGuids={"99b130","99b131"}


standardProjectTileData={}
standardProjectTileData.default={
imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317853416866731/A4954EB24622A576517EA5A36182F2C336214D25/",
buttons={{click_function="cityStandardProject",tooltip="Place a city tile"},
{click_function="greeneryStandardProject",tooltip="Place a greenery tile"},
{click_function="oceanStandardProject",tooltip="Place one ocean"},
{click_function="temperatureStandardProject",tooltip="Increase temperature one step"},
{click_function="energyStandardProject",tooltip="Increase energy production by one"},
{click_function="sellPatentsStandardProject",tooltip="Discard all cards in your first hand and gain 1 ME for each card discarded."},}
}
standardProjectTileData.venus={
imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317853416867099/0C2B51F5891F5A07B7BCCC2C9DA4D3726B422C28/",
buttons={{click_function="cityStandardProject",tooltip="Place a city tile"},
{click_function="greeneryStandardProject",tooltip="Place a greenery tile"},
{click_function="oceanStandardProject",tooltip="Place one ocean"},
{click_function="airScrappingStandardProject",tooltip="Increase Venus TF by one step"},
{click_function="temperatureStandardProject",tooltip="Increase temperature one step"},
{click_function="energyStandardProject",tooltip="Increase energy production by one"},
{click_function="sellPatentsStandardProject",tooltip="Discard all cards in your first hand and gain 1 ME for each card discarded."},}
}
standardProjectTileData.colonies={
imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317853416866893/7F5738084407BF2AADEBEAFBA38EB6FB04C2AC1B/",
buttons={{click_function="cityStandardProject",tooltip="Place a city tile"},
{click_function="greeneryStandardProject",tooltip="Place a greenery tile"},
{click_function="oceanStandardProject",tooltip="Place one ocean"},
{click_function="colonyStandardProject",tooltip="Place one colony marker"},
{click_function="temperatureStandardProject",tooltip="Increase temperature one step"},
{click_function="energyStandardProject",tooltip="Increase energy production by one"},
{click_function="sellPatentsStandardProject",tooltip="Discard all cards in your first hand and gain 1 ME for each card discarded."},}
}
standardProjectTileData.venusAndColonies={
imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317853416867310/87C7F0846CFC9BB72A3B5DC84FDE7C30B82E68FD/",
buttons={{click_function="cityStandardProject",tooltip="Place a city tile"},
{click_function="greeneryStandardProject",tooltip="Place a greenery tile"},
{click_function="oceanStandardProject",tooltip="Place one ocean"},
{click_function="colonyStandardProject",tooltip="Place one colony marker"},
{click_function="airScrappingStandardProject",tooltip="Increase Venus TF by one step"},
{click_function="temperatureStandardProject",tooltip="Increase temperature one step"},
{click_function="energyStandardProject",tooltip="Increase energy production by one"},
{click_function="sellPatentsStandardProject",tooltip="Discard all cards in your first hand and gain 1 ME for each card discarded."},}
}
standardProjectTileData.venusPhaseTwo={
imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317853416866524/68156279060D4273995D24C4020CA50690395D58/",
buttons={{click_function="venusHabitatStandardProject",tooltip="Place a venus habitat tile on venus and increase Venus TF (any floaters on cards are worth 3 ME)"},
{click_function="cityStandardProject",tooltip="Place a city tile"},
{click_function="greeneryStandardProject",tooltip="Place a greenery tile"},
{click_function="gasMineStandardProject",tooltip="Place a gas mine tile on venus and increase Venus TF (any floaters on cards are worth 3 ME)"},
{click_function="floatingArrayStandardProject",tooltip="Place a floating array tile on venus and increase Venus TF (any floaters on cards are worth 3 ME)"},
{click_function="oceanStandardProject",tooltip="Place one ocean"},
{click_function="colonyStandardProject",tooltip="Place one colony marker"},
{click_function="airScrappingStandardProject",tooltip="Increase Venus TF by one step"},
{click_function="temperatureStandardProject",tooltip="Increase temperature one step"},
{click_function="energyStandardProject",tooltip="Increase energy production by one"},
{click_function="sellPatentsStandardProject",tooltip="Discard all cards in your first hand and gain 1 ME for each card discarded."},}
}


loggingModes={
exception="exception",
essential="essential",
important="important",
detail="detail",
unimportant="unimportant",
debugging="debugging",
}
loggingRules={
{name="Silent",modes={loggingModes.exception}},
{name="Essential",modes={loggingModes.exception,loggingModes.essential}},
{name="Important",modes={loggingModes.exception,loggingModes.essential,loggingModes.important}},
{name="Detail",modes={loggingModes.exception,loggingModes.essential,loggingModes.important,loggingModes.detail}},
{name="Everything",modes={loggingModes.exception,loggingModes.essential,loggingModes.important,loggingModes.detail,loggingModes.unimportant}},
{name="Debugging",modes={loggingModes.exception,loggingModes.essential,loggingModes.important,loggingModes.detail,loggingModes.unimportant,loggingModes.debugging}},
}


programableActionTokenData={}
programableActionTokenData.types={
tradeToken="tradeToken",
colonyTrackUp="colonyTrackUp",
colonyTrackDown="colonyTrackDown",
aresProductionMalus="aresProductionMalus",
butterflyEffectToken="butterflyEffectToken",
makeTileIndestructibleToken="makeTileIndestructibleToken",
}


expansionCrossoverCards={}
expansionCrossoverCards.pathfinderProjects={}
expansionCrossoverCards.pathfinderProjects.turmoil={
"f8a042","3720fa","ae9499","70d2be","4bec9b","45f122"
}
expansionCrossoverCards.pathfinderProjects.venus={
"cf31e6"
}
expansionCrossoverCards.pathfinderProjects.colonies={
"2921b5","70ad9b","04041d"
}
expansionCrossoverCards.pathfinderPreludes={}
expansionCrossoverCards.pathfinderPreludes.venus={
"1b0ef1","1b0ee5"
}
expansionCrossoverCards.pathfinderPreludes.colonies={
"1b0eef","1b0ef0"
}
expansionCrossoverCards.pathfinderCorps={}
expansionCrossoverCards.pathfinderCorps.venus={
"e91b1d","8bacee"
}
expansionCrossoverCards.ares={}
expansionCrossoverCards.ares.projects={}
expansionCrossoverCards.ares.projects.baseGameReplacements={
"d6508f","edfac2","990ff3","886f23","68b260","98870f","f14441","e253f2","e7d192","3dbf55","a789cf"
}
expansionCrossoverCards.solaris={}
expansionCrossoverCards.solaris.projects={}
expansionCrossoverCards.solaris.projects.removeCards={
"519963","5f49a3","40cf1d","46b000","88674f","d95a03","6e9cec","2712b0","f1a299"
}


awardData={}
awardData.infos={
Landlord={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026326592/8108E35BBC547D86C498B025F2A7FD6BDD783207/",
description="Most owned tiles (space cities are counted as well).\n:Award:",
tooltip="Click to sponsor the 'Landlord' award.\nMost owned tiles (space cities are counted as well).",
name="Landlord"},
Banker={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026326060/878CC2D06E56EBD70D7DE4CCED507C7CA60AC9F4/",
description="Highest ME production.\n:Award:",
tooltip="Click to sponsor the 'Banker' award.\nHighest ME production.",
name="Banker"},
Scientist={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026325704/477B3E519ADBF5B6446E2F61F0B5A03EA0F4ABF2/",
description="Most sciene tags in play.\n:Award:",
tooltip="Click to sponsor the 'Scientist' award.\nMost sciene tags in play (wild card tags and science tags on event cards do not count).",
name="Scientist"},
Thermalist={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026325293/C60C0DF3CBDAD2EDBAB650D30FD7F845CF86593B/",
description="Most heat in storage.\n:Award:",
tooltip="Click to sponsor the 'Thermalist' award.\nMost heat in storage.",
name="Thermalist"},
Miner={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026324520/8894263603EACCF9AC25416D747EA30FA771CCC6/",
description="Most steel and titanium in storage.\n:Award:",
tooltip="Click to sponsor the 'Miner' award.\nMost steel and titanium in storage.",
name="Miner"},
Cultivator={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026323559/3C7F681438875824BEC716EFFDDF88C7B068F178/",
description="Most greeneries in play.\n:Award:",
tooltip="Click to sponsor the 'Cultivator' award.\nMost greeneries in play.",
name="Cultivator"},
Magnate={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026323071/43F3CF36E658F6CC150FC9B9E755C2223201780E/",
description="Most green cards in play.\n:Award:",
tooltip="Click to sponsor the 'Magnate' award.\nMost green cards in play.",
name="Magnate"},
SpaceBaron={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026322524/D116F8452F28F1765C463B71F13DEF0C53A2BC26/",
description="Most space tags in play (events with a space tag do not count).\n:Award:",
tooltip="Click to sponsor the 'Space Baron' award.\nMost space tags in play (wild card tags and events with a space tag do not count).",
name="Space Baron"},
Excentric={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026321870/4FF1F89DC7B4CEB32F8E0DE3227F34C29348311A/",
description="Most card resources (Floaters,Animals,Microbes,etc.).\n:Award:",
tooltip="Click to sponsor the 'Excentric' award.\nMost card resources (Floaters,Animals,Microbes,etc.).",
name="Excentric"},
Contractor={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026321267/90C98013D369DFE46E8C90D240D88E6F58C30FF3/",
description="Most building tags in play (events with a building tag do not count).\n:Award:",
tooltip="Click to sponsor the 'Contractor' award.\nMost building tags in play (wild card tags and events with a building tag do not count).",
name="Contractor"},
Celebrity={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026320789/C6F80887CC2F89F82603DD2EB42D0850449F3542/",
description="Most cards which have a base cost of 20 or more (events that cost 20 or more do not count).\n:Award:",
tooltip="Click to sponsor the 'Celebrity' award.\nMost cards which have a base cost of 20 or more (events that cost 20 or more do not count).",
name="Celebrity"},
Industrialist={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026320271/1DE8E97B3FD9A859D78B3B20974DA97C3AE07DC5/",
description="Most steel and energy in storage.\n:Award:",
tooltip="Click to sponsor the 'Industrialist' award.\nMost steel and energy in storage.",
name="Industrialist"},
DesertSettler={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026319581/26011501113C7E67A4678507EA532FFE803B71D2/",
description="Most owned tiles on the 4 most southern map rows.\n:Award:",
tooltip="Click to sponsor the 'Desert Settler' award.\nMost owned tiles on the 4 most southern map rows.",
name="Desert Settler"},
EstateDealer={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026319112/B53DE6005B6E509AB570B87ACCA58F3435A6B8C3/",
description="Most owned tiles adjacent to ocean tiles.\n:Award:",
tooltip="Click to sponsor the 'Estate Dealer' award.\nMost owned tiles adjacent to ocean tiles.",
name="Estate Dealer"},
Benefactor={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026318525/354EF8256333282CDF77EE217F79AACD958D727D/",
description="Highest terraforming rating.\n:Award:",
tooltip="Click to sponsor the 'Benefactor' award.\nHighest terraforming rating.",
name="Benefactor"},
CosmicSettler={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026317905/3E5E7A2ACD9C797D893CDC0F0130AD460B55E3D5/",
description="Most city tiles in space.\n:Award:",
tooltip="Click to sponsor the 'Cosmic Settler' award.\nMost city tiles in space.",
name="Cosmic Settler",
expansions={"pathfinders"}},
Botanist={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026317421/3B8EEF4F114F27E31F86DFCBEF8116897A03367B/",
description="Highest plant production.\n:Award:",
tooltip="Click to sponsor the 'Botanist' award.\nHighest plant production.",
name="Botanist",
expansions={"pathfinders"}},
Coordinator={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026316689/3F39E1FBD6519FACACBD64B125E500E065231D98/",
description="Most events played.\n:Award:",
tooltip="Click to sponsor the 'Coordinator' award.\nMost events played.",
name="Coordinator",
expansions={"pathfinders"}},
Zoologist={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026316112/71A184D4B3A25F23D1BF226429D2BFC10C87C17D/",
description="Most animal card resources.\n:Award:",
tooltip="Click to sponsor the 'Zoologist' award.\nMost animal card resources.",
name="Zoologist",
expansions={"pathfinders"}},
Manufacturer={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970118026304099/F23F6CAA6418D67FB5A80F8BD2FC74C9C03152C4/",
description="Most blue cards.\n:Award:",
tooltip="Click to sponsor the 'Manufacturer' award.\nMost blue cards.",
name="Manufacturer",
expansions={"pathfinders"}},
Venuphile={imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276163811/3FB78672EE3677EDE6947003D5E17A925E27A5F7/",
description="Most owned Venus tags in play.\n:Award:",
tooltip="Click to sponsor the 'Venuphile' award.\nMost Venus tags (events with a Venus tag do not count).",
name="Venuphile",
expansions={"venus"}}
}
awardData.sets={{"Landlord","Banker","Scientist","Thermalist","Miner"},
{"Cultivator","Magnate","SpaceBaron","Excentric","Contractor"},
{"Celebrity","Industrialist","DesertSettler","EstateDealer","Benefactor"},
{"CosmicSettler","Botanist","Coordinator","Zoologist","Manufacturer"}}
awardData.tiles={
{position={2.32,1.07,-12.09},guid="ca6fe0"},
{position={5.42,1.07,-12.09},guid="ca6fdf"},
{position={8.52,1.07,-12.09},guid="ca6fde"},
{position={11.62,1.07,-12.09},guid="ca6fdd"},
{position={14.72,1.07,-12.09},guid="ca6fdc"},
}
awardData.costTable={
{-8,-14,-20,},
{-8,-12,-16,-20},
{-8,-11,-14,-17,-20}
}
awardData.images={
"http://cloud-3.steamusercontent.com/ugc/1691647690039309315/EE4D0DE9CC12A100DC2DB88DAB857934462A631F/",
"http://cloud-3.steamusercontent.com/ugc/1691647690039309592/22C1EC78B1A374AF571A720E6B9441EEFC8DC5D7/",
"http://cloud-3.steamusercontent.com/ugc/1691647690039309967/1BA061386CDA9CCDB2B258D3AE2AFDA80E2F1699/"
}
awardData.getAwardInfoByName=function(name)
for key,info in pairs(awardData.infos) do
if key==name then
return info
end
end
end


timerData={}
timerData.timeoutActions={
"endTurn",
"doNothing",
"giveNegativeVPs",
}


globalParameters={}
globalParameters.temperature={
startTransform={pos={-0.525,0.325,-3.075},rot={0,315,0}},
finalTransform={pos={-0.525,0.325,3.075},rot={0,225,0}},
trackRotation={0,180,0},
bonusMarkerOffset={-0.45,0.0,0},
objectGuid="420ec7",
markerGuid="f1bfac"
}
globalParameters.temperature.mappings={
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524119091/69D8DEA32C672C5ABFA9D6959D8A10538EA6C269/",
steps={-30,-28,-26,-24,-22,-20,-18,-16,-14,-12,-10,-8,-6,-4,-2,0,2,4,6,8}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524118123/28E635F51540A7E4D70B0822031DBF7C9CEAFD2A/",
steps={-30,-28,-26,-24,-22,-20,-18,-16,-14,-13,-12,-11,-10,-9,-8,-6,-4,-2,0,2,4,6,8}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524117190/389C3CAADD75C5F427D707C5C7D22274B4DE9E63/",
steps={-30,-28,-26,-24,-22,-20,-18,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-4,-2,0,2,4,6,8}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524115147/E4EE3281B4275D23D187C51948BA778FEBE06D54/",
steps={-30,-28,-26,-24,-22,-20,-18,-17,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-2,0,2,4,6,8}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524112802/EB10CC842CFA077C8FC73A073B5D4511A6A6A3BC/",
steps={-30,-28,-26,-24,-22,-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,0,2,4,6,8}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524113944/90370B3674235D9ACCD05599CB7DFE24A56BED22/",
steps={-30,-28,-26,-24,-22,-21,-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,2,4,6,8}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524110449/8A24171589ACA18A140D0D600BCE3F8CD7F881C7/",
steps={-30,-28,-26,-24,-23,-22,-21,-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,4,6,8}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524109265/11D5FF733CCB5781BABBD680AF1D1C556E972036/",
steps={-30,-28,-26,-25,-24,-23,-22,-21,-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,-9,-8,
-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,6,8}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524107957/3D4F696C75615798F03430B14769399CCA7AB1A7/",
steps={-30,-28,-27,-26,-25,-24,-23,-22,-21,-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,-9,
-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,8}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524107012/295CB87A763310B82895EDF9318D08942021E6A6/",
steps={-30,-29,-28,-27,-26,-25,-24,-23,-22,-21,-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,
-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1755812632524089315/2E803F52CBAA3FBBE38C777E6732900C1591D033/",
steps={-30,-29,-28,-27,-26,-25,-24,-23,-22,-21,-20,-19,-18,-17,-16,-15,-14,-13,-12,-11,-10,
-9,-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10}},
}
globalParameters.temperature.bonus={
{
{activationEffects={productionValues={Heat=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077007702/B1992DF97C4B4CD0723D55626D073A9BF62F63F8/" ,value=-24},
{activationEffects={productionValues={Heat=1}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077007702/B1992DF97C4B4CD0723D55626D073A9BF62F63F8/" ,value=-20},
{activationEffects={effects={"Ocean"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077007797/537986DC839C7A0BFD80CE6C49EBB791688A4A40/" ,value=0},
},
}
globalParameters.temperature.ares={
{
{activationEffects={effects={"FlipErosions"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317611193585913/BAD154E4C994399FB22066B7B3510E5B666453AB/",value=-4,type="hazard"}},
{
{activationEffects={effects={"RandomDuststorm"}},imageUrl="",value=-16},
{activationEffects={effects={"RandomDuststorm"}},imageUrl="",value=-6},
},
}
globalParameters.temperature.buttons={
increaseTemp={
click_function='increaseTempButtonClick',
label='+',
function_owner=self,
position={-0.15,0,-3.35},
rotation={0,0,0},
width=800,
height=400,
font_size=550,
scale={0.2,0.2,0.2},
color={255/255,115/255,0}},
decreaseTemp={
click_function='decreaseTempButtonClick',
label='-',
function_owner=self,
position={-0.15,0,3.35},
rotation={0,0,0},
width=800,
height=400,
font_size=550,
scale={0.2,0.2,0.2},
color={255/255,166/255,106/255}
}
}
globalParameters.oxygen={
startTransform={pos={0.525,0.325,-3.075},rot={0,45,0}},
finalTransform={pos={0.525,0.325,3.075},rot={0,135,0}},
trackRotation={0,180,0},
bonusMarkerOffset={-0.45,0.0,0},
objectGuid="76f704",
markerGuid="ca3d95",
}
globalParameters.oxygen.mappings={
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1752435791408246917/FCE9C51AD3937C21FB4C1161EAE1CEC1543D79C5/",
steps={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647550721632800/4F96DD2BDBA5965C95C93C21514D55A6D4C69AB0/",
steps={0,1,2,3,4,5,6,6.5,7,7.5,8,9,10,11,12,13,14}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647550721633099/7667CE9F992A02E94E9C28A94B6EBB21717B9F17/",
steps={0,1,2,3,4,5,5.5,6,6.5,7,7.5,8,8.5,9,10,11,12,13,14}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647550721633348/8441D6A37FCC76B597A5073476D8195CCFB26DE3/",
steps={0,1,2,3,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,11,12,13,14}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647550721633598/53B3D5312F63EEF1F3AE83D2CD8E7BA951AB780A/",
steps={0,1,2,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,12,13,14}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647550721633916/6765E0B0D0C45895873D05F8336326CEEC4F2230/",
steps={0,1,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,13,14}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647550721634079/E386AFC9A0274FA0808365ADCCB2B4B8C227749F/",
steps={0,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,14}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647550721634462/B80724A6C0ABA2694B8F31BF9D658D70DB1B6149/",
steps={0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647550721634865/9AA380A99FE419B0BA6B60482120191A10539634/",
steps={0,0.5,1,1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,8.5,9,9.5,10,10.5,11,11.5,12,12.5,13,13.5,14,14.5,15}},
}
globalParameters.oxygen.bonus={
{
{activationEffects={effects={"Temp"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077007880/349C51FC62734F704F6DACFCB35B44D1810D920C/",value=8},
}
}
globalParameters.oxygen.ares={
{
{activationEffects={effects={"FlipDuststorms"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317611193585460/8AE90EFF2F79C50122595B2231F1D351A8AD8FC5/",value=5,type="hazard"}},
{
{activationEffects={effects={"RandomErosion"}},imageUrl="",value=4},
{activationEffects={effects={"RandomErosion"}},imageUrl="",value=12}
}
}
globalParameters.oxygen.buttons={
increaseO2={
click_function='increaseO2ButtonClick',
label='+',
function_owner=self,
position={0.15,0,-3.35},
rotation={0,0,0},
width=800,
height=400,
font_size=550,
scale={0.2,0.2,0.2},
color={255/255,115/255,0}},
decreaseO2={
click_function='decreaseO2ButtonClick',
label='-',
function_owner=self,
position={0.15,0,3.35},
rotation={0,0,0},
width=800,
height=400,
font_size=550,
scale={0.2,0.2,0.2},
color={255/255,166/255,106/255}
}
}
globalParameters.venus={
startTransform={pos={0.22,0.325,-4.2},rot={0,77,0}},
finalTransform={pos={0.22,0.325,4.2},rot={0,103,0}},
trackRotation={0,270,0},
bonusMarkerOffset={-0.8,0.0,0},
objectGuid="59dd23",
markerGuid="ca3d97"
}
globalParameters.venus.mappings={
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1800854953427114347/200C0B3A238B2427EBA8A7F5BF26C18FC4957CC3/",
steps={0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30},
id="default"},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317853416523147/96BF19F861F1F1A46ABA503234FA1FA4C71D338F/",
steps={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30},
id="venusPhaseTwo"}
}
globalParameters.venus.bonus={
{
{activationEffects={effects={"DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1750191221387707923/F86585C954C7DA2DFE60BA6DC146405442EAFEB4/",value=8},
{activationEffects={effects={"TR"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077007954/2D2DEB510B43987AAAD2D04C4F4FAA13C4B47F04/",value=16},
},
{
{value=2,activationEffects={effects={"Floater","ResourceWildCardToken"},effectsOthers={"ResourceWildCardToken"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008045/9AD5145286D187BBBEACC5BC0E8CDA778014E47D/"},
{value=4,activationEffects={effects={"DrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077007541/03DF85B11E3C964528B8A31DE0FFBF33E264FB23/"},
{value=8,activationEffects={effects={"TR","DrawCard","OthersDrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008119/7441A3538CDD0783CD23D4B0C234D7DA9281DE3F/"},
{value=10,activationEffects={effects={"Floater","Floater","Floater"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008203/EB8D4C1EC6D4ADE303AD90BD204E14CED4BDBC12/"},
{value=14,activationEffects={effects={"ResourceWildCardToken"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008288/495E4440ACDA0E1CE317494A7D9AA4FF59BDBABF/"},
{value=16,activationEffects={effects={"ResourceWildCardToken"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008288/495E4440ACDA0E1CE317494A7D9AA4FF59BDBABF/"},
{value=18,activationEffects={effects={"Colony"},resourceValuesOthers={Credits=5}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077173886/0FF30BCA4B23B305672AFA0B0032D097B187218B/"},
{value=20,activationEffects={effects={"ResourceWildCardToken"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008288/495E4440ACDA0E1CE317494A7D9AA4FF59BDBABF/"},
{value=22,activationEffects={effects={"ResourceWildCardToken"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008288/495E4440ACDA0E1CE317494A7D9AA4FF59BDBABF/"},
{value=24,activationEffects={effects={"ResourceWildCardToken","DrawCard","OthersDrawCard"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008377/B771A578D974BC88FAACC006501B2FEEC2C70075/"},
{value=26,activationEffects={effects={"ResourceWildCardToken"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008288/495E4440ACDA0E1CE317494A7D9AA4FF59BDBABF/"},
{value=28,activationEffects={effects={"ResourceWildCardToken"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008288/495E4440ACDA0E1CE317494A7D9AA4FF59BDBABF/"},
{value=30,activationEffects={effects={"ResourceWildCardToken","WildCardToken"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164276077008472/5FAAA8C4DA5FC27EAC9E9349D8D3E667E6DA151A/"},
},
}
globalParameters.venus.buttons={
increaseVenus={
click_function='increaseVenusButtonClick',
label='+',
function_owner=self,
position={4.95,0,0.275},
rotation={0,105,0},
width=800,
height=500,
font_size=550,
scale={0.35,0.35,0.35},
color={255/255,115/255,0}},
decreaseVenus={
click_function='decreaseVenusButtonClick',
label='-',
function_owner=self,
position={-4.95,0,0.275},
rotation={0,75,0},
width=800,
height=500,
font_size=550,
scale={0.35,0.35,0.35},
color={255/255,166/255,106/255}
}
}
globalParameters.ocean={
startTransform={pos={0.525,0.325,-3.00},rot={0,45,0}},
finalTransform={pos={0.525,0.325,3.00},rot={0,135,0}},
trackRotation={0,270,0},
bonusMarkerOffset={-0.5,0.0,0},
objectGuid="cf4f00",
markerGuid="ca3d96"
}
globalParameters.ocean.mappings={
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647719961516971/F4E568B809E452574298B371B3D9B491C7A4C8D4/",
steps={0,1,2,3,4,5,6,7,8,9}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647719961517167/90689BBAA2631A17FFAC13B2265F19A32CEEA209/",
steps={0,1,2,3,4,5,6,7,8,9,10}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647719961517350/238840B43982DA781452ED1FD90EFDD1F46A4EC7/",
steps={0,1,2,3,4,5,6,7,8,9,10,11}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647719961517495/6BB0544FFFA177563D46E5514BBEA7FF8EDD3D7C/",
steps={0,1,2,3,4,5,6,7,8,9,10,11,12}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647719961517686/C60AEB01F5DD54C7822B1EFD3731EEC5697EDEF3/",
steps={0,1,2,3,4,5,6,7,8,9,10,11,12,13}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647719961517924/1ED2BB10570693DBB6C79C80993E471C2F918149/",
steps={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647719961518132/24A4E8925CCCB38357F589398FCF5620B066F71A/",
steps={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647719961518401/0A505400457F4008DA9DFA33623A720D8A8489DC/",
steps={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19}},
{imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647719961518615/830A679834DFB54F711C74153C9DB4FD2757D51C/",
steps={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21}}
}
globalParameters.ocean.bonus={
{}
}
globalParameters.ocean.ares={
{
{activationEffects={effects={"PlaceTwoErosions"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317611193786619/7D6A39A9C04A5CBC33A8EA508D73DD64E8AC7A07/",value=3,type="hazard"},
{activationEffects={effects={"RemoveAllDuststorms","TR"}},imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317611193586533/1A5444BB36471DCB8C0A3F624663F6EA84798FCF/",value=6}
}
}
-- offset=vectorHelpers.scaleVectorByVector({0,0.325,4.425},tempToken.getScale())


boardgameTileProperties={
allExpansions={imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317900889200914/1257B74A0D524D73BBB0F630A00B813E2F511605/"},
withoutPathfinders={imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317900889203890/963A74F96CDCB80DB4C87117C570EE7C81810E72/"},
baseGame={imageUrl="http://cloud-3.steamusercontent.com/ugc/1751317900889206465/F21F964D784242CF88FD6F3E64E9F85A442F34B8/"}
}


turmoilPartyData={}
turmoilPartyData.defaultConfig={
startingPartyId="Greens",
parties={"MarsFirst","Scientists","Unity","Greens","Reds","Kelvinists"}
}
turmoilPartyData.parties={
MarsFirst={
id="MarsFirst",
tileImageUrl="http://cloud-3.steamusercontent.com/ugc/1007062784836152030/15C66E2D9CBF82F1B51A31908FBFC8BAE293ADDF/",
onFactionTakesOver=
function(players)
for _,player in pairs(players) do
local amount=player.tagSystem.tagCounts["Building"]
logging.printToAll("Player "..player.color.." got "..amount.." credit(s) from the Mars First party.")
changePlayerResource({playerColor=player.color,resourceType="credits",resourceAmount=amount})
end
end,
policyBonus={
friendlyName="Mars First agenda",
actionProperties={noAction=true,resourceValues={Steel=1}},
oneTimeEffect=false,
triggerTypes={
eventData.triggerType.marsCityPlayed,
eventData.triggerType.specialTilePlayed,
eventData.triggerType.greeneryPlayed,
eventData.triggerType.oceanPlayed,
},
allowedPhases={
phases.generationPhase
}
}
},
Scientists={
id="Scientists",
tileImageUrl="http://cloud-3.steamusercontent.com/ugc/1007062784835833619/BEF61D321F5ECC05A07BB0D154AD400167761422/",
onFactionTakesOver=
function(players)
for _,player in pairs(players) do
local amount=player.tagSystem.tagCounts["Science"]
logging.printToAll("Player "..player.color.." got "..amount.." credit(s) from the Scientists party.")
changePlayerResource({playerColor=player.color,resourceType="credits",resourceAmount=amount})
end
end,
policyBonus={
friendlyName="Scientists special project",
actionProperties={resourceValues={Credits=-10},effects={"DrawCard","DrawCard","DrawCard"}},
oneTimeEffect=true,
triggerTypes={},
allowedPhases={}
}
},
Unity={
id="Unity",
tileImageUrl="http://cloud-3.steamusercontent.com/ugc/1007062572075999010/11AB480205C1C67846FFD6F834945292D7DD2EA4/",
onFactionTakesOver=
function(players)
for _,player in pairs(players) do
local tagCount=player.tagSystem.tagCounts["Earth"]
tagCount=tagCount + player.tagSystem.tagCounts["Venus"]
tagCount=tagCount + player.tagSystem.tagCounts["Jovian"]
if player.tagSystem.tagCounts["Mars"]~=nil then
tagCount=tagCount + player.tagSystem.tagCounts["Mars"]
end
logging.printToAll("Player "..player.color.." got "..tagCount.." credit(s) from the Unity party.")
changePlayerResource({playerColor=player.color,resourceType="credits",resourceAmount=tagCount})
end
end,
onRulingPartyChanged=function(newRulingParty,players)
local delta=1
if newRulingParty.partyId~="Unity" then
delta=-1
end
for _,player in pairs(players) do
paymentSystem_updateConversionRate({playerColor=player.color,resourceType="Titanium",delta=delta})
end
end,
policyBonus={}
},
Greens={
id="Greens",
tileImageUrl="http://cloud-3.steamusercontent.com/ugc/1007062572076148666/64B835574371543BFE02FD711ABA5CE68446BC23/",
onFactionTakesOver=
function(players)
for _,player in pairs(players) do
local tagCount=player.tagSystem.tagCounts["Microbe"]
tagCount=tagCount + player.tagSystem.tagCounts["Plant"]
tagCount=tagCount + player.tagSystem.tagCounts["Animal"]
logging.printToAll("Player "..player.color.." got "..tagCount.." credit(s) from the Greens party.")
changePlayerResource({playerColor=player.color,resourceType="credits",resourceAmount=tagCount})
end
end,
policyBonus={
friendlyName="Greens agenda",
actionProperties={noAction=true,resourceValues={Credits=4}},
oneTimeEffect=false,
triggerTypes={eventData.triggerType.greeneryPlayed},
allowedPhases={phases.generationPhase}
}
},
Reds={
id="Reds",
tileImageUrl="http://cloud-3.steamusercontent.com/ugc/1007062572076071119/FE579E6A79A24B3F2A101189BA637BC098C4927F/",
onFactionTakesOver=
function(players)
local minTR=math.huge
for _,player in pairs(players) do
if player.terraformingRating < minTR and not player.neutral then
minTR=player.terraformingRating
end
end
for _,player in pairs(players) do
if gameState.isSoloGame and minTR > 20 then
return
end
if player.terraformingRating==minTR then
logging.printToAll(player.name.." got 1 terrforming rating from the Reds party!",player.color,loggingModes.essential)
increasePlayerTerraforming(getPlayerIndexByColor(player.color),"of the Reds party")
end
end
end,
policyBonus={
friendlyName="Reds agenda",
actionProperties={noAction=true,resourceValues={Credits=-3}},
oneTimeEffect=false,
triggerTypes={eventData.triggerType.terraformingGained},
allowedPhases={phases.generationPhase}
},
onPolicyActionNotAllowed=
function(player)
logging.broadcastToAll(
"Player "..player.color.." doesn't have enough credits to satisfy the Reds agenda and doesn't gain a TR for the last action.",
player.color,
"essential"
)
Wait.frames(|| Global.call("decreasePlayerTRByColor",player.color),10)
end
},
Kelvinists={
id="Kelvinists",
tileImageUrl="http://cloud-3.steamusercontent.com/ugc/1007062822775452820/427B130AD3407BE8B24712EE6CA6B55BC62ECB9F/",
onFactionTakesOver=
function(players)
for _,player in pairs(players) do
local amount=getPlayerProduction({playerColor=player.color,resourceType="Heat"})
logging.printToAll("Player "..player.color.." got "..amount.." credit(s) from the Kelvinists party.")
changePlayerResource({playerColor=player.color,
resourceType="credits",
resourceAmount=amount})
end
end,
policyBonus={
friendlyName="Kelvinists special project",
actionProperties={resourceValues={Credits=-10},productionValues={Heat=1,Energy=1}},
oneTimeEffect=false,
triggerTypes={},
allowedPhases={}
}
}
}


playMatButtons={}
playMatButtons.mainMat={
increaseTR={
click_function='increaseTRButtonClick',
label='+',
function_owner=self,
position={-1.58,0.15,-0.145},
rotation={0,0,0},
width=800,
height=400,
font_size=450,
scale={0.03,0.03,0.03},
color={255/255,115/255,0}},
decreaseTR={
click_function='decreaseTRButtonClick',
label='-',
function_owner=self,
position={-1.58,0.15,-0.125},
rotation={0,0,0},
width=800,
height=400,
font_size=550,
scale={0.0225,0.0225,0.0225},
color={255/255,166/255,106/255}
}
}
playMatButtons.tradingTile={
tradeViaCredits={
click_function='tradeViaCredits',
tooltip="Pay 9 credits to trade with a colony",
function_owner=Global,
position={-1.6,0.15,1.025},
rotation={0,0,0},
width=750,
height=750,
color={0,1,0,0.5},
scale={0.4,0.2,0.4},
},
tradeViaTitanium={
click_function='tradeViaTitanium',
tooltip="Pay 3 titanium to trade with a colony",
function_owner=Global,
position={-0.7,0.15,1.025},
rotation={0,0,0},
width=750,
height=750,
color={0,1,0,0.5},
scale={0.4,0.2,0.4},
},
tradeViaEnergy={
click_function='tradeViaEnergy',
tooltip="Pay 3 energy to trade with a colony",
function_owner=Global,
position={0.2,0.15,1.025},
rotation={0,0,0},
width=750,
height=750,
color={0,1,0,0.5},
scale={0.4,0.2,0.4},
}
}


predefinedMapSettings={}
predefinedMapSettings.default={
prettyName="Default",
description="The default settings.",
config={
mapGeneratorConfig={
mapSizeSelection=3,
deltaFactor=0.1,
bonusTilesRatio=8/10,
totallyRandomTilesRatio=0.1,
tileEffects={
Plants={weighting=10,averageTileYield=1.8,yieldDiffusion=0.25,maxYield=3,seedPoints=3,shapeFactor=2,seedDistance=4},
Titanium={weighting=2,averageTileYield=1,yieldDiffusion=0.4,maxYield=2,seedPoints=5,shapeFactor=0.6,seedDistance=4},
Steel={weighting=5,averageTileYield=1.7,yieldDiffusion=0.25,maxYield=3,seedPoints=5,shapeFactor=0.8,seedDistance=4},
DrawCard={weighting=3,averageTileYield=1.45,yieldDiffusion=0.25,maxYield=3,seedPoints=200,shapeFactor=0.2,seedDistance=4},
Heat={weighting=0,averageTileYield=2,yieldDiffusion=0.5,maxYield=4,seedPoints=3,shapeFactor=2,seedDistance=4},
Energy={weighting=0,averageTileYield=1.5,yieldDiffusion=0.25,maxYield=4,seedPoints=2,shapeFactor=2,seedDistance=4},
Credits={weighting=0,averageTileYield=5,yieldDiffusion=0.5,maxYield=6,seedPoints=5,shapeFactor=0.2,seedDistance=1},
OtherEffects={weighting=0,averageTileYield=0.0,yieldDiffusion=0.0,maxYield=0,seedPoints=200,shapeFactor=0.2,seedDistance=1}},
oceanSettings={
oceanSeedPoints=4,
oceanSeedMinDistance=4,
oceanShapeFactor=1,-- values >= 1 --> bulky cluster,values < 1 --> snakey ocean lines
},
absoluteTiles={
volcanoTiles=3,
blockedTiles=0,-- blocked tiles give adjancency bonuses (e.g. draw 1 card,gain 1 plant,etc)
initialErosions=0,
initialDuststorms=3,
}
}
}
}
predefinedMapSettings.firstExplorers={
prettyName="First Explorers",
description="Lots of card draw bonuses. Besides that only few other bonsuses.",
config={
mapGeneratorConfig={
mapSizeSelection=3,
deltaFactor=0.1,
bonusTilesRatio=16/10,
totallyRandomTilesRatio=0.05,
tileEffects={
Plants={weighting=3,averageTileYield=1.5,yieldDiffusion=0.25,maxYield=3,seedPoints=3,shapeFactor=2,seedDistance=4},
Titanium={weighting=1,averageTileYield=1,yieldDiffusion=0.25,maxYield=2,seedPoints=5,shapeFactor=0.6,seedDistance=4},
Steel={weighting=2,averageTileYield=1,yieldDiffusion=0.25,maxYield=3,seedPoints=5,shapeFactor=0.8,seedDistance=4},
DrawCard={weighting=11,averageTileYield=1.8,yieldDiffusion=0.25,maxYield=3,seedPoints=5,shapeFactor=0.1,seedDistance=4},
Heat={weighting=1,averageTileYield=1.8,yieldDiffusion=0.25,maxYield=4,seedPoints=3,shapeFactor=2,seedDistance=4},
Energy={weighting=0,averageTileYield=1.5,yieldDiffusion=0.5,maxYield=4,seedPoints=2,shapeFactor=2,seedDistance=4},
Credits={weighting=0,averageTileYield=5,yieldDiffusion=0.5,maxYield=6,seedPoints=200,shapeFactor=0.2,seedDistance=1},
OtherEffects={weighting=2,averageTileYield=0.0,yieldDiffusion=0.0,maxYield=0,seedPoints=200,shapeFactor=0.2,seedDistance=1}},
oceanSettings={
oceanSeedPoints=3,
oceanSeedMinDistance=4,
oceanShapeFactor=0.5,-- values >= 1 --> bulky cluster,values < 1 --> snakey ocean lines
},
absoluteTiles={
volcanoTiles=4,
blockedTiles=0,-- blocked tiles give adjancency bonuses (e.g. draw 1 card,gain 1 plant,etc)
initialErosions=0,
initialDuststorms=3,
}
}
}
}
predefinedMapSettings.martianDesert={
prettyName="Martian Desert",
description="Few bonus spaces at all. Also additional erosions and duststorms"..
"if you play with the Ares fan expansion.",
config={
mapGeneratorConfig={
mapSizeSelection=3,
deltaFactor=0.1,
bonusTilesRatio=1/10,
totallyRandomTilesRatio=0.01,
tileEffects={
Plants={weighting=1,averageTileYield=2,yieldDiffusion=0.5,maxYield=3,seedPoints=3,shapeFactor=2,seedDistance=4},
Titanium={weighting=3,averageTileYield=1,yieldDiffusion=0.5,maxYield=2,seedPoints=5,shapeFactor=0.6,seedDistance=4},
Steel={weighting=5,averageTileYield=1.7,yieldDiffusion=0.5,maxYield=3,seedPoints=5,shapeFactor=0.8,seedDistance=4},
DrawCard={weighting=1,averageTileYield=1.5,yieldDiffusion=0.5,maxYield=3,seedPoints=5,shapeFactor=0.2,seedDistance=4},
Heat={weighting=0,averageTileYield=2,yieldDiffusion=0.5,maxYield=4,seedPoints=3,shapeFactor=2,seedDistance=4},
Energy={weighting=0,averageTileYield=1.5,yieldDiffusion=0.5,maxYield=4,seedPoints=2,shapeFactor=2,seedDistance=4},
Credits={weighting=0,averageTileYield=5,yieldDiffusion=0.5,maxYield=6,seedPoints=200,shapeFactor=0.2,seedDistance=1},
OtherEffects={weighting=0,averageTileYield=0.0,yieldDiffusion=0.0,maxYield=0,seedPoints=200,shapeFactor=0.2,seedDistance=1}},
oceanSettings={
oceanSeedPoints=2,
oceanSeedMinDistance=4,
oceanShapeFactor=1,-- values >= 1 --> bulky cluster,values < 1 --> snakey ocean lines
},
absoluteTiles={
volcanoTiles=4,
blockedTiles=0,-- blocked tiles give adjancency bonuses (e.g. draw 1 card,gain 1 plant,etc)
initialErosions=4,
initialDuststorms=5,
}
}
}
}
predefinedMapSettings.richDeposits={
prettyName="Rich Deposits",
description="Few plants and card draw locations. Lots of high steel and titanium yield tiles. One single ocean area.",
config=
{
mapGeneratorConfig={
mapSizeSelection=3,
deltaFactor=0.1,
bonusTilesRatio=14/10,
totallyRandomTilesRatio=0.01,
tileEffects={
Plants={weighting=1,averageTileYield=2,yieldDiffusion=0.5,maxYield=3,seedPoints=3,shapeFactor=2,seedDistance=4},
Titanium={weighting=10,averageTileYield=1.7,yieldDiffusion=0.5,maxYield=2,seedPoints=5,shapeFactor=0.6,seedDistance=4},
Steel={weighting=15,averageTileYield=2.7,yieldDiffusion=0.5,maxYield=3,seedPoints=5,shapeFactor=0.8,seedDistance=4},
DrawCard={weighting=1,averageTileYield=1.5,yieldDiffusion=0.5,maxYield=3,seedPoints=5,shapeFactor=0.2,seedDistance=4},
Heat={weighting=0,averageTileYield=2,yieldDiffusion=0.5,maxYield=4,seedPoints=3,shapeFactor=2,seedDistance=4},
Energy={weighting=0,averageTileYield=1.5,yieldDiffusion=0.5,maxYield=4,seedPoints=2,shapeFactor=2,seedDistance=4},
Credits={weighting=0,averageTileYield=5,yieldDiffusion=0.5,maxYield=6,seedPoints=200,shapeFactor=0.2,seedDistance=1},
OtherEffects={weighting=0,averageTileYield=0.0,yieldDiffusion=0.0,maxYield=0,seedPoints=200,shapeFactor=0.2,seedDistance=1}},
oceanSettings={
oceanSeedPoints=4,
oceanSeedMinDistance=4,
oceanShapeFactor=0.5,-- values >= 1 --> bulky cluster,values < 1 --> snakey ocean lines
},
absoluteTiles={
volcanoTiles=3,
blockedTiles=0,-- blocked tiles give adjancency bonuses (e.g. draw 1 card,gain 1 plant,etc)
initialErosions=0,
initialDuststorms=3,
}
}
}
}
predefinedMapSettings.fastTerraformers={
prettyName="Fast Terraformers",
description="Lots of plants and heat bonuses. Very few card draw locations. No titanium,a bit of steel.",
config=
{
mapGeneratorConfig={
mapSizeSelection=3,
deltaFactor=0.1,
bonusTilesRatio=4,
totallyRandomTilesRatio=0.01,
tileEffects={
Plants={weighting=13,averageTileYield=2.5,yieldDiffusion=0.25,maxYield=3,seedPoints=3,shapeFactor=2,seedDistance=4},
Titanium={weighting=0,averageTileYield=1,yieldDiffusion=0.5,maxYield=2,seedPoints=5,shapeFactor=0.6,seedDistance=4},
Steel={weighting=2,averageTileYield=1.7,yieldDiffusion=0.5,maxYield=3,seedPoints=5,shapeFactor=0.8,seedDistance=4},
DrawCard={weighting=1,averageTileYield=1.5,yieldDiffusion=0.5,maxYield=3,seedPoints=5,shapeFactor=0.2,seedDistance=4},
Heat={weighting=13,averageTileYield=3,yieldDiffusion=0.5,maxYield=4,seedPoints=3,shapeFactor=2,seedDistance=4},
Energy={weighting=0,averageTileYield=1.5,yieldDiffusion=0.5,maxYield=4,seedPoints=2,shapeFactor=2,seedDistance=4},
Credits={weighting=0,averageTileYield=5,yieldDiffusion=0.5,maxYield=6,seedPoints=200,shapeFactor=0.2,seedDistance=1},
OtherEffects={weighting=0,averageTileYield=0.0,yieldDiffusion=0.0,maxYield=0,seedPoints=200,shapeFactor=0.2,seedDistance=1}},
oceanSettings={
oceanSeedPoints=3,
oceanSeedMinDistance=4,
oceanShapeFactor=0,-- values >= 1 --> bulky cluster,values < 1 --> snakey ocean lines
},
absoluteTiles={
volcanoTiles=3,
blockedTiles=0,-- blocked tiles give adjancency bonuses (e.g. draw 1 card,gain 1 plant,etc)
initialErosions=0,
initialDuststorms=3,
}
}
}
}
predefinedMapSettings.jungleWorld={
prettyName="Jungle World",
description="Lots of small oceans. Lots of high yield plant bonuses. Few other bonuses.",
config={
mapGeneratorConfig={
mapSizeSelection=3,
deltaFactor=0.1,
bonusTilesRatio=16/10,
totallyRandomTilesRatio=0.05,
tileEffects={
Plants={weighting=15,averageTileYield=2.5,yieldDiffusion=0.25,maxYield=3,seedPoints=4,shapeFactor=2,seedDistance=4},
Titanium={weighting=1,averageTileYield=1,yieldDiffusion=0.5,maxYield=2,seedPoints=5,shapeFactor=0.6,seedDistance=4},
Steel={weighting=2,averageTileYield=1.7,yieldDiffusion=0.5,maxYield=3,seedPoints=5,shapeFactor=0.8,seedDistance=4},
DrawCard={weighting=1,averageTileYield=1.5,yieldDiffusion=0.5,maxYield=3,seedPoints=5,shapeFactor=0.2,seedDistance=4},
Heat={weighting=0,averageTileYield=2,yieldDiffusion=0.5,maxYield=4,seedPoints=3,shapeFactor=2,seedDistance=4},
Energy={weighting=0,averageTileYield=1.5,yieldDiffusion=0.5,maxYield=4,seedPoints=2,shapeFactor=2,seedDistance=4},
Credits={weighting=0,averageTileYield=5,yieldDiffusion=0.5,maxYield=6,seedPoints=200,shapeFactor=0.2,seedDistance=1},
OtherEffects={weighting=1,averageTileYield=0.0,yieldDiffusion=0.0,maxYield=0,seedPoints=200,shapeFactor=0.2,seedDistance=1}},
oceanSettings={
oceanSeedPoints=8,
oceanSeedMinDistance=2,
oceanShapeFactor=0,-- values >= 1 --> bulky cluster,values < 1 --> snakey ocean lines
},
absoluteTiles={
volcanoTiles=0,
blockedTiles=0,-- blocked tiles give adjancency bonuses (e.g. draw 1 card,gain 1 plant,etc)
initialErosions=0,
initialDuststorms=3,
}
}
}
}


draftingData={}
draftingData.researchPhase={}
draftingData.researchPhase.defaultRule={
prettyName="Default",
tooltip="The day to day drafting rules for research phases after the first generation.",
considerForPayment=4,
draftingSteps={
{
cardsToDeal={projects={amount=4,targetHandIndex=1}},
subSteps={3,2,1}
}
}
}
draftingData.initialResearchPhase={}
draftingData.initialResearchPhase.freeDraft={
prettyName="Free Draft",
tooltip="Draft as you want. Default setting.",
considerForPayment=10,
freeDraft=true,
draftingSteps={
{
cardsToDeal={projects={amount=10,targetHandIndex=2}},
subSteps={{projects=0}},
}
}
}
draftingData.initialResearchPhase.d_4_3_3={
prettyName="4-3-3",
tooltip="Draft 4 out of 10 project cards and then 3 out of 6.",
considerForPayment=10,
draftingSteps={
{
cardsToDeal={projects={amount=10,targetHandIndex=2}},
subSteps={{projects=6},{projects=3}}
}
}
}
draftingData.initialResearchPhase.wbc={
prettyName="WBC",
tooltip="Get 5 projects,draft them one by one clockwise. Then draft 4 preludes anti-clockwise. After that draw 5 projects and draft them counter-clockwise one by one.",
considerForPayment=10,
draftingSteps={
{
cardsToDeal={projects={amount=5,targetHandIndex=1}},
subSteps={{projects=4},{projects=3},{projects=2},{projects=1}},
directionOverride=1},
{
cardsToDeal={projects={amount=5,targetHandIndex=1}},
subSteps={{projects=4},{projects=3},{projects=2},{projects=1}},
directionOverride=-1},
{
cardsToDeal={preludes={amount=4,targetHandIndex=1}},
subSteps={{preludes=3},{preludes=2},{preludes=1}},
directionOverride=-1
}
}
}
draftingData.initialResearchPhase.d_5_4P_5={
prettyName="5-4P-5",
tooltip="Get 5 projects,draft them one by one clockwise. After that get 5 other projects and draft them counter-clockwise one by one.",
considerForPayment=10,
draftingSteps={
{
cardsToDeal={projects={amount=5,targetHandIndex=1}},
subSteps={{projects=4},{projects=3},{projects=2},{projects=1}},
directionOverride=-1},
{
cardsToDeal={preludes={amount=4,targetHandIndex=1}},
subSteps={{preludes=3},{preludes=2},{preludes=1}},
directionOverride=1},
{
cardsToDeal={projects={amount=5,targetHandIndex=1}},
subSteps={{projects=4},{projects=3},{projects=2},{projects=1}},
directionOverride=1
}
}
}



tp_ares={classic={},redesign={}}
tp_ares.classic.erosionBag={pos={13.38,1.13,-22.41},rot={0,270,0}}
tp_ares.classic.duststormBag={pos={16.20,1.13,-22.41},rot={0,270,0}}
tp_ares.redesign.erosionBag={pos={13.38,1.13,-22.41},rot={0,270,0}}
tp_ares.redesign.duststormBag={pos={16.20,1.13,-22.41},rot={0,270,0}}


tp_colonies={classic={},redesign={}}
tp_colonies.classic.tradingTile={pos={37.37,1.15,-4.65},rot={0,180,0}}
tp_colonies.classic.colonyTransforms={
{pos={22.28,1.15,12.33},rot={0,180,0}},
{pos={25.38,1.15,5.72},rot={0,180,0}},
{pos={26.62,1.15,-1.10},rot={0,180,0}},
{pos={26.45,1.15,-7.91},rot={0,180,0}},
{pos={24.94,1.15,-14.45},rot={0,180,0}},
{pos={22.43,1.15,-20.62},rot={0,180,0}},
{pos={34.42,1.15,7.26},rot={0,180,0}},
{pos={35.78,1.15,1.43},rot={0,180,0}},
{pos={-29.18,1.15,13.38},rot={0,180,0}},
}
tp_colonies.classic.coloniesBagTransform={pos={29.40,-3.5,-20.60},rot={0,270,0}}
tp_colonies.classic.shipBagTransform={pos={32.50,1.00,-5.25},rot={0,270,270.01}}
tp_colonies.classic.tradeShipPositionMatrix={
rowStartingOffset=-2,
heightStartingOffset=0.07,
columnStartingOffset=0,
rowLength=3
}
tp_colonies.classic.tradeMarkerActiveOffset={0,0.32,0}
tp_colonies.classic.tradeMarkerInactiveOffset={-1.5,0.32,2.00}
tp_colonies.classic.tradeShipTradedOffset={-0.85,0.05,0}
tp_colonies.redesign.tradingTile={pos={37.37,1.15,-4.65},rot={0,180,0}}
tp_colonies.redesign.colonyTransforms={
{pos={22.28,1.15,12.33},rot={0,180,0}},
{pos={25.38,1.15,5.72},rot={0,180,0}},
{pos={26.62,1.15,-1.10},rot={0,180,0}},
{pos={26.45,1.15,-7.91},rot={0,180,0}},
{pos={24.94,1.15,-14.45},rot={0,180,0}},
{pos={22.43,1.15,-20.62},rot={0,180,0}},
{pos={34.42,1.15,7.26},rot={0,180,0}},
{pos={35.78,1.15,1.43},rot={0,180,0}},
{pos={-29.18,1.15,13.38},rot={0,180,0}},
}
tp_colonies.redesign.coloniesBagTransform={pos={29.40,-3.5,-20.60},rot={0,270,0}}
tp_colonies.redesign.shipBagTransform={pos={32.50,1.00,-5.25},rot={0,270,270.01}}
tp_colonies.redesign.tradeShipPositionMatrix={
rowStartingOffset=-2,
heightStartingOffset=0.07,
columnStartingOffset=0,
rowLength=3
}
tp_colonies.redesign.tradeMarkerActiveOffset={0,0.32,0}
tp_colonies.redesign.tradeMarkerInactiveOffset={-1.5,0.32,2.00}
tp_colonies.redesign.tradeShipTradedOffset={-0.85,0.05,0}


tp_gameBoardAssets={classic={},redesign={}}
tp_gameBoardAssets.classic.trTrackPositions={
bottomLeftCorner={-42.45,1.57,-24.83},
topLeftCorner={-42.45,1.57,24.83},
topRightCorner={42.2,1.57,24.83},
bottomRightCorner={42.2,1.57,-24.83},
}
tp_gameBoardAssets.classic.cardResourceTokensPositions={
bottom={p={-1.55,1.13,-22.45},r={0,180,0}},
}
tp_gameBoardAssets.classic.cardResourceTokensSpacing={-1.738,0,0}
tp_gameBoardAssets.classic.drawPile={pos={-39.10,1.29,-15.75},rot={0,0,0}}
tp_gameBoardAssets.classic.discardPile={pos={-39.10,1.29,-21.25},rot={0,0,0}}
tp_gameBoardAssets.classic.cardRevealTransform={pos={-47.00,1.08,-15.40},rot={0,180,0}}
tp_gameBoardAssets.classic.timerTile={pos={-107.00,4.0,74.0},rot={20,0,0}}
tp_gameBoardAssets.classic.awardTile={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.milestoneTile={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.standardProjectTile={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.citiesOnMarsCounter={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.citiesInPlayCounter={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.cityBag={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.greeneryBag={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.specialTilesBag={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.oceanBag={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.extraOceanCounter={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.marsTile={pos={0,10,0},rot={0,0,0}}
tp_gameBoardAssets.classic.loggingTile={pos={0,10,0},rot={0,180,0}}
tp_gameBoardAssets.classic.globalParameters={
temperature={marker={pos={13.90,1.64,-14.22},rot={0,0,0}},track={pos={15.50,1.15,-3.00},rot={0,180,0}}},
oxygen={marker={pos={-13.90,1.64,-14.22},rot={0,0,0}},track={pos={-15.50,1.15,-3.00},rot={0,180,0}}},
ocean={marker={pos={-10.40,1.64,11.68},rot={320.71,49.73,78.70}},track={pos={0,1.15,13.15},rot={0,180,0}}},
venus={marker={pos={-38.50,1.70,7.00},rot={0,0,0}},track={pos={-30.81,1.15,7.40},rot={0,180,0}}},
}
tp_gameBoardAssets.classic.gameConfigTile={
start={pos={35.00,8.00,0.00},rot={20,90,0}}
}
tp_gameBoardAssets.redesign.trTrackPositions={
bottomLeftCorner={-42.45,1.57,-24.83},
topLeftCorner={-42.45,1.57,24.83},
topRightCorner={42.2,1.57,24.83},
bottomRightCorner={42.2,1.57,-24.83},
}
tp_gameBoardAssets.redesign.cardResourceTokensPositions={
bottom={p={-1.55,1.13,-22.45},r={0,180,0}},
}
tp_gameBoardAssets.redesign.cardResourceTokensSpacing={-1.738,0,0}
tp_gameBoardAssets.redesign.drawPile={pos={-39.10,1.29,-15.75},rot={0,180,180}}
tp_gameBoardAssets.redesign.discardPile={pos={-39.10,1.29,-21.25},rot={0,180,180}}
tp_gameBoardAssets.redesign.drawPileTile={pos={-39.10,1.205,-15.75},rot={0,0,0}}
tp_gameBoardAssets.redesign.discardPileTile={pos={-39.10,1.205,-21.25},rot={0,0,0}}
tp_gameBoardAssets.redesign.cardRevealTransform={pos={-47.00,1.08,-15.40},rot={0,180,0}}
tp_gameBoardAssets.redesign.timerTile={pos={-107.00,4.0,74.0},rot={20,0,0}}
tp_gameBoardAssets.redesign.awardTile={pos={33.00,1.10,20.75},rot={0,180,0}}
tp_gameBoardAssets.redesign.milestoneTile={pos={-33.00,1.10,20.75},rot={0,180,0}}
tp_gameBoardAssets.redesign.standardProjectTile={pos={36.20,1.10,-15.90},rot={0,180,0}}
tp_gameBoardAssets.redesign.citiesOnMarsCounter={pos={39.00,0.59,12.20},rot={0,0,0}}
tp_gameBoardAssets.redesign.citiesInPlayCounter={pos={39.00,0.59,16.00},rot={0,0,0}}
tp_gameBoardAssets.redesign.cityBag={pos={-6.70,1.13,-22.41},rot={0,270,0}}
tp_gameBoardAssets.redesign.greeneryBag={pos={-3.90,1.13,-22.41},rot={0,270,0}}
tp_gameBoardAssets.redesign.specialTilesBag={pos={7.69,1.13,-22.41},rot={0,270,0}}
tp_gameBoardAssets.redesign.oceanBag={pos={10.54,1.13,-22.41},rot={0,270,0}}
tp_gameBoardAssets.redesign.extraOceanCounter={pos={12.00,0.59,15.60},rot={0,0,0}}
tp_gameBoardAssets.redesign.marsTile={pos={0,1.15,-3.00},rot={0,180,0}}
tp_gameBoardAssets.redesign.loggingTile={pos={-39.90,0.65,16.30},rot={0,180,0}}
tp_gameBoardAssets.redesign.globalParameters={
temperature={marker={pos={13.90,1.64,-14.22},rot={0,0,0}},track={pos={15.50,1.15,-3.00},rot={0,180,0}}},
oxygen={marker={pos={-13.90,1.64,-14.22},rot={0,0,0}},track={pos={-15.50,1.15,-3.00},rot={0,180,0}}},
ocean={marker={pos={-10.40,1.64,11.68},rot={320.71,49.73,78.70}},track={pos={0,1.15,13.15},rot={0,180,0}}},
venus={marker={pos={-38.50,1.70,7.00},rot={0,0,0}},track={pos={-30.81,1.15,7.40},rot={0,180,0}}},
}
tp_gameBoardAssets.redesign.gameConfigTile={
start={pos={35.00,8.00,0.00},rot={20,90,0}}
}


tp_highOrbit={classic={},redesign={}}
tp_highOrbit.classic.spawnLocation={pos={0,10,0},rot={0,90,0}}
tp_highOrbit.redesign.spawnLocation={pos={0,10,0},rot={0,90,0}}


tp_pathfinder={classic={},redesign={}}
tp_pathfinder.classic.pathfinderBoard={pos={-27.05,1.10,-18.45},rot={0,180,0}}
tp_pathfinder.classic.pathfinderPlanetTracks={
venus={
{0.635,0.5,0.91},
{0.6375,0.5,0.82},
{0.64,0.5,0.73},
{0.645,0.5,0.64},
{0.655,0.5,0.55},
{0.6675,0.5,0.46},
{0.685,0.5,0.37},
{0.705,0.5,0.28},
{0.730,0.5,0.195},
{0.755,0.5,0.11},
{0.780,0.5,0.02},
{0.810,0.5,-0.06},
{0.840,0.5,-0.15},
{0.875,0.5,-0.23},
{0.915,0.5,-0.31},
{0.960,0.5,-0.39},
{1.005,0.5,-0.47},
{1.050,0.5,-0.55},},
earth={
{0.11,0.5,0.91},
{0.1125,0.5,0.825},
{0.115,0.5,0.74},
{0.12,0.5,0.65},
{0.1275,0.5,0.56},
{0.1375,0.5,0.47},
{0.1475,0.5,0.38},
{0.165,0.5,0.30},
{0.185,0.5,0.21},
{0.205,0.5,0.125},
{0.230,0.5,0.04},
{0.255,0.5,-0.045},
{0.280,0.5,-0.125},
{0.315,0.5,-0.205},
{0.340,0.5,-0.29},
{0.375,0.5,-0.37},
{0.410,0.5,-0.45},
{0.445,0.5,-0.53},
{0.485,0.5,-0.61},
{0.525,0.5,-0.69},
{0.565,0.5,-0.765},
{0.6125,0.5,-0.84},
{0.665,0.5,-0.92},},
mars={
{-0.7,0.5,0.91},
{-0.6975,0.5,0.815},
{-0.695,0.5,0.725},
{-0.69,0.5,0.635},
{-0.685,0.5,0.545},
{-0.68,0.5,0.455},
{-0.675,0.5,0.365},
{-0.665,0.5,0.275},
{-0.645,0.5,0.18},
{-0.625,0.5,0.09},
{-0.605,0.5,0.00},
{-0.575,0.5,-0.09},
{-0.55,0.5,-0.175},
{-0.525,0.5,-0.26},
{-0.49,0.5,-0.35},
{-0.47,0.5,-0.44},
{-0.44,0.5,-0.525},
{-0.4,0.5,-0.61},},
jovian={
{-1.465,0.5,0.91},
{-1.4625,0.5,0.79},
{-1.4575,0.5,0.68},
{-1.4525,0.5,0.57},
{-1.445,0.5,0.46},
{-1.435,0.5,0.355},
{-1.420,0.5,0.25},
{-1.405,0.5,0.145},
{-1.385,0.5,0.04},
{-1.365,0.5,-0.06},
{-1.345,0.5,-0.165},
{-1.32,0.5,-0.27},
{-1.29,0.5,-0.375},
{-1.26,0.5,-0.48},
{-1.23,0.5,-0.58},
{-1.19,0.5,-0.68},
{-1.15,0.5,-0.775},
}
}
tp_pathfinder.redesign.pathfinderBoard={pos={-27.05,1.10,-18.45},rot={0,180,0}}
tp_pathfinder.redesign.pathfinderPlanetTracks=tp_pathfinder.classic.pathfinderPlanetTracks


tp_player={classic={},redesign={}}
tp_player.classic.trCubeSpawn={pos={0,10,0},rot={0,0,0}}
tp_player.classic.playerSpawnPositions={
White={pos={70.00,1.00,0.00},rot={0,90,0},isLeftRightFlipped=true},
Red={pos={20.00,1.00,-36.00},rot={0,180,0},isLeftRightFlipped=true},
Yellow={pos={-20.00,1.00,-36.00},rot={0,180,0},isLeftRightFlipped=false},
Orange={pos={-70.00,1.00,0.00},rot={0,270,0},isLeftRightFlipped=false},
Green={pos={-20.00,1.00,36.00},rot={0,0,0},isLeftRightFlipped=true},
Blue={pos={20.00,1.00,36.00},rot={0,0,0},isLeftRightFlipped=false},
}
tp_player.redesign.trCubeSpawn={pos={0,10,0},rot={0,0,0}}
tp_player.redesign.playerSpawnPositions={
White={pos={70.00,1.00,0.00},rot={0,90,0},isLeftRightFlipped=true},
Red={pos={20.00,1.00,-36.00},rot={0,180,0},isLeftRightFlipped=true},
Yellow={pos={-20.00,1.00,-36.00},rot={0,180,0},isLeftRightFlipped=false},
Orange={pos={-70.00,1.00,0.00},rot={0,270,0},isLeftRightFlipped=false},
Green={pos={-20.00,1.00,36.00},rot={0,0,0},isLeftRightFlipped=true},
Blue={pos={20.00,1.00,36.00},rot={0,0,0},isLeftRightFlipped=false},
}


tp_reservedTiles={classic={},redesign={}}
tp_reservedTiles.classic.spaceTiles={}
tp_reservedTiles.classic.spaceTiles.baseGame={
phobosSpacePort={pos={20.42,1.10,-9.64},rot={0,270,0}},
ganymedeColony={pos={34.12,1.10,13.04},rot={0,270,0}}
}
tp_reservedTiles.classic.spaceTiles.venus={
dawnCity={pos={-35.75,1.10,14.26},rot={0,270,0}},
lunaMetropolis={pos={-19.55,1.10,15.11},rot={0,270,0}}
}
tp_reservedTiles.classic.spaceTiles.turmoil={
stanfordTorus={pos={-15.39,1.10,-18.13},rot={0,270,0}}
}
tp_reservedTiles.classic.spaceTiles.pathfinder={
dysonScreens={pos={-38.13,1.10,10.63},rot={0,270,0}},
ceresSpaceport={pos={29.07,1.10,15.31},rot={0,270,0}},
veneraBase={pos={-20.85,1.10,-7.73},rot={0,270,0}},
gatewayStation={pos={18.82,1.10,-13.50},rot={0,270,0}},
lunarEmbassy={pos={-16.33,1.10,13.58},rot={0,270,0}},
martianTranshipmentStation={pos={16.59,1.10,-17.14},rot={0,270,0}},
}
tp_reservedTiles.redesign.spaceTiles={}
tp_reservedTiles.redesign.spaceTiles.baseGame={
phobosSpacePort={pos={20.42,1.10,-9.64},rot={0,270,0}},
ganymedeColony={pos={34.12,1.10,13.04},rot={0,270,0}}
}
tp_reservedTiles.redesign.spaceTiles.venus={
dawnCity={pos={-35.75,1.10,14.26},rot={0,270,0}},
lunaMetropolis={pos={-19.55,1.10,15.11},rot={0,270,0}}
}
tp_reservedTiles.redesign.spaceTiles.turmoil={
stanfordTorus={pos={-15.39,1.10,-18.13},rot={0,270,0}}
}
tp_reservedTiles.redesign.spaceTiles.pathfinder={
dysonScreens={pos={-38.13,1.10,10.63},rot={0,270,0}},
ceresSpaceport={pos={29.07,1.10,15.31},rot={0,270,0}},
veneraBase={pos={-20.85,1.10,-7.73},rot={0,270,0}},
gatewayStation={pos={18.82,1.10,-13.50},rot={0,270,0}},
lunarEmbassy={pos={-16.33,1.10,13.58},rot={0,270,0}},
martianTranshipmentStation={pos={16.59,1.10,-17.14},rot={0,270,0}},
}


tp_turmoil={classic={},redesign={}}
tp_turmoil.classic.turmoilTile={position={0.00,1.21,20.75},rotation= {0,180,0}}
tp_turmoil.redesign.turmoilTile={position={0.00,1.21,20.75},rotation= {0,180,0}}


tp_venus={classic={},redesign={}}
tp_venus.classic.venusTrack={pos={-30.81,1.15,7.40},rot={0.00,180.00,0.00}}
tp_venus.classic.venusMarker={pos={-38.50,1.70,7.00},rot={0,0,0}}
tp_venus.classic.venusMapTile={pos={-30.78,1.15,-2.00},rot={0,180,0}}
tp_venus.redesign.venusTrack={pos={-30.81,1.15,7.40},rot={0.00,180.00,0.00}}
tp_venus.redesign.venusMarker={pos={-38.50,1.70,7.00},rot={0,0,0}}
tp_venus.redesign.venusMapTile={pos={-30.78,1.15,-2.00},rot={0,180,0}}


tp_venusPhaseTwo={classic={},redesign={}}
tp_venusPhaseTwo.classic.floatingArrayBag={pos={-9.58,1.13,-22.41},rot={0,90,0}}
tp_venusPhaseTwo.classic.gasMineBag={pos={-12.42,1.13,-22.41},rot={0,90,0}}
tp_venusPhaseTwo.classic.venusHabitatBag={pos={-15.26,1.13,-22.41},rot={0,90,0}}
tp_venusPhaseTwo.redesign.floatingArrayBag={pos={-9.58,1.13,-22.41},rot={0,90,0}}
tp_venusPhaseTwo.redesign.gasMineBag={pos={-12.42,1.13,-22.41},rot={0,90,0}}
tp_venusPhaseTwo.redesign.venusHabitatBag={pos={-15.26,1.13,-22.41},rot={0,90,0}}

tablePositions={}
tablePositions.design={}
tablePositions.design.ares=tp_ares
tablePositions.design.colonies=tp_colonies
tablePositions.design.gameBoardAssets=tp_gameBoardAssets
tablePositions.design.highOrbit=tp_highOrbit
tablePositions.design.pathfinder=tp_pathfinder
tablePositions.design.player=tp_player
tablePositions.design.reservedTiles=tp_reservedTiles
tablePositions.design.turmoil=tp_turmoil
tablePositions.design.venus=tp_venus
tablePositions.design.venusPhaseTwo=tp_venusPhaseTwo
tablePositions.update=function()
local classicBoardActive=gameState.activeExpansions.classicBoard
if classicBoardActive==nil then
classicBoardActive=gameConfig.setup.classicBoard
end
if classicBoardActive then
tablePositions.ares=tablePositions.design.ares.classic
tablePositions.colonies=tablePositions.design.colonies.classic
tablePositions.gameBoardAssets=tablePositions.design.gameBoardAssets.classic
tablePositions.highOrbit=tablePositions.design.highOrbit.classic
tablePositions.pathfinder=tablePositions.design.pathfinder.classic
tablePositions.player=tablePositions.design.player.classic
tablePositions.reservedTiles=tablePositions.design.reservedTiles.classic
tablePositions.turmoil=tablePositions.design.turmoil.classic
tablePositions.venus=tablePositions.design.venus.classic
tablePositions.venusPhaseTwo=tablePositions.design.venusPhaseTwo.classic
else
tablePositions.ares=tablePositions.design.ares.redesign
tablePositions.colonies=tablePositions.design.colonies.redesign
tablePositions.gameBoardAssets=tablePositions.design.gameBoardAssets.redesign
tablePositions.highOrbit=tablePositions.design.highOrbit.redesign
tablePositions.pathfinder=tablePositions.design.pathfinder.redesign
tablePositions.player=tablePositions.design.player.redesign
tablePositions.reservedTiles=tablePositions.design.reservedTiles.redesign
tablePositions.turmoil=tablePositions.design.turmoil.redesign
tablePositions.venus=tablePositions.design.venus.redesign
tablePositions.venusPhaseTwo=tablePositions.design.venusPhaseTwo.redesign
end
end



boardProperties={}
boardProperties.classic={
trTrack={firstCorner=25,secondCorner=50,thirdCorner=75,fourthCorner=100}
}
boardProperties.redesign={
trTrack={firstCorner=35,secondCorner=85,thirdCorner=120,fourthCorner=170}
}

board={}
board.design={}
board.design.properties=boardProperties
board.update=function(refreshPlayers)
local classicBoardActive=gameState.activeExpansions.classicBoard
if classicBoardActive==nil then
classicBoardActive=gameConfig.setup.classicBoard
end
if classicBoardActive then
board.properties=board.design.properties.classic
else
board.properties=board.design.properties.redesign
end
if gameState.started then return end
board.internal.moveGameAssets(refreshPlayers)
end
board.internal={}
board.internal.moveGameAssets=function(refreshPlayers)
local transforms=tablePositions.gameBoardAssets
board.internal.positionMarsTile(transforms)
board.internal.positionGlobalParameterTracksAndMarkers(transforms)
board.internal.positionAwardAndMilestoneTiles(transforms)
board.internal.positionStandardProjectTile(transforms)
board.internal.positionDrawAndDiscardPiles(transforms)
board.internal.positionPlayerMaterial(refreshPlayers)
board.internal.positionLoggingConfigTile(transforms)
board.internal.positionGameConfigTile(transforms)
board.internal.positionTileBags(transforms)
end
board.internal.positionMarsTile=function(transforms)
local marsTile=gameObjectHelpers.getObjectByName("marsMapTile")
marsTile.setPosition(transforms.marsTile.pos)
marsTile.setRotation(transforms.marsTile.rot)
end
board.internal.positionGlobalParameterTracksAndMarkers=function(transforms)
local tempTrack=getObjectFromGUID(globalParameters.temperature.objectGuid)
local tempMarker=getObjectFromGUID(globalParameters.temperature.markerGuid)
tempTrack.setPosition(transforms.globalParameters.temperature.track.pos)
tempTrack.setRotation(transforms.globalParameters.temperature.track.rot)
tempMarker.setPosition(transforms.globalParameters.temperature.marker.pos)
tempMarker.setRotation(transforms.globalParameters.temperature.marker.rot)
local oxygenTrack=getObjectFromGUID(globalParameters.oxygen.objectGuid)
local oxygenMarker=getObjectFromGUID(globalParameters.oxygen.markerGuid)
oxygenTrack.setPosition(transforms.globalParameters.oxygen.track.pos)
oxygenTrack.setRotation(transforms.globalParameters.oxygen.track.rot)
oxygenMarker.setPosition(transforms.globalParameters.oxygen.marker.pos)
oxygenMarker.setRotation(transforms.globalParameters.oxygen.marker.rot)
local oceanTrack=getObjectFromGUID(globalParameters.ocean.objectGuid)
local oceanMarker=getObjectFromGUID(globalParameters.ocean.markerGuid)
oceanTrack.setPosition(transforms.globalParameters.ocean.track.pos)
oceanTrack.setRotation(transforms.globalParameters.ocean.track.rot)
oceanMarker.setPosition(transforms.globalParameters.ocean.marker.pos)
oceanMarker.setRotation(transforms.globalParameters.ocean.marker.rot)
end
board.internal.positionAwardAndMilestoneTiles=function(transforms)
local milestoneTile=gameObjectHelpers.getObjectByName("milestonePlate")
local awardTile=gameObjectHelpers.getObjectByName("awardPlate")
milestoneTile.setPosition(transforms.milestoneTile.pos)
milestoneTile.setRotation(transforms.milestoneTile.rot)
awardTile.setPosition(transforms.awardTile.pos)
awardTile.setRotation(transforms.awardTile.rot)
end
board.internal.positionStandardProjectTile=function(transforms)
local standardProjectTile=gameObjectHelpers.getObjectByName("standardProjectTile")
standardProjectTile.setPosition(transforms.standardProjectTile.pos)
standardProjectTile.setRotation(transforms.standardProjectTile.rot)
end
board.internal.positionDrawAndDiscardPiles=function(transforms)
local drawPileTile=gameObjectHelpers.getObjectByName("projectStackTile")
local discardPileTile=gameObjectHelpers.getObjectByName("projectDiscardTile")
local projectDeck=gameObjectHelpers.getObjectByName("projectDeck")
discardPileTile.setPosition(transforms.discardPileTile.pos)
discardPileTile.setRotation(transforms.discardPileTile.rot)
drawPileTile.setPosition(transforms.drawPileTile.pos)
drawPileTile.setRotation(transforms.drawPileTile.rot)
projectDeck.setPosition(transforms.drawPile.pos)
projectDeck.setRotation(transforms.drawPile.rot)
end
board.internal.positionPlayerMaterial=function(refreshPlayers)
if refreshPlayers then
local playerEssentialInfos={}
for playerIndex,player in pairs(gameState.allPlayers) do
table.insert(playerEssentialInfos,{playerIndex=playerIndex,playerColor=player.color})
end
for _,info in pairs(playerEssentialInfos) do
removePlayerFromGame(info.playerIndex)
createPlayerInGame(info.playerColor,false)
end
end
end
board.internal.positionLoggingConfigTile=function(transforms)
local loggingTile=gameObjectHelpers.getObjectByName("loggingTile")
loggingTile.setPosition(transforms.loggingTile.pos)
loggingTile.setRotation(transforms.loggingTile.rot)
end
board.internal.positionGameConfigTile=function(transforms)
local gameConfigTile=gameObjectHelpers.getObjectByName("gameConfigTile")
gameConfigTile.setPosition(transforms.gameConfigTile.start.pos)
gameConfigTile.setRotation(transforms.gameConfigTile.start.rot)
end
board.internal.positionTileBags=function(transforms)
local genericCityBag=gameObjectHelpers.getObjectByName("genericCityBag")
local genericGreeneryBag=gameObjectHelpers.getObjectByName("genericGreeneryBag")
local specialsBag=gameObjectHelpers.getObjectByName("specialsBag")
local oceanBag=gameObjectHelpers.getObjectByName("oceanBag")
genericCityBag.setPosition(transforms.cityBag.pos)
genericCityBag.setRotation(transforms.cityBag.rot)
genericGreeneryBag.setPosition(transforms.greeneryBag.pos)
genericGreeneryBag.setRotation(transforms.greeneryBag.rot)
specialsBag.setPosition(transforms.specialTilesBag.pos)
specialsBag.setRotation(transforms.specialTilesBag.rot)
oceanBag.setPosition(transforms.oceanBag.pos)
oceanBag.setRotation(transforms.oceanBag.rot)
end


colonySetup={}
colonySetup.setup=function()
colonySetup.createSnapPoints()
colonySetup.setupBags()
colonySetup.setupColonies()
colonySetup.setupTradingTile()
Wait.time(function() colonySetup.initialize() end,3)
end
colonySetup.createSnapPoints=function()
for _,transform in pairs(tablePositions.colonies.colonyTransforms) do
snapPointHelpers.createSingleSnapPoint(nil,transform,true)
end
end
colonySetup.setupBags=function()
local coloniesBag=gameObjectHelpers.getObjectByName("coloniesBag")
coloniesBag.setPositionSmooth(tablePositions.colonies.coloniesBagTransform.pos)
coloniesBag.setRotation(tablePositions.colonies.coloniesBagTransform.rot)
local coloniesShipBag=gameObjectHelpers.getObjectByName("coloniesShipBag")
coloniesShipBag.setPositionSmooth(tablePositions.colonies.shipBagTransform.pos)
coloniesShipBag.setRotation(tablePositions.colonies.shipBagTransform.rot)
coloniesShipBag.interactable=true
end
colonySetup.setupColonies=function()
local bag=gameObjectHelpers.getObjectByName("coloniesBag")
if not gameState.activeExpansions.pathfinders then
local pathfinderColonies={"534eee","534eef"}
for _,guid in pairs(pathfinderColonies) do
local plate=bag.takeObject({guid=guid})
plate.destruct()
end
end
bag.shuffle()
local coloniesToSpawn=5
if gameState.numberOfPlayers==1 then
coloniesToSpawn=4
end
if gameState.numberOfPlayers + 2 > coloniesToSpawn then
coloniesToSpawn=gameState.numberOfPlayers + 2
end
log("Spawning a total of "..tostring(coloniesToSpawn).." colonies")
for i=1,coloniesToSpawn do
function spawnSubroutine()
coroutine.yield(0)
local transform=tablePositions.colonies.colonyTransforms[i]
local colonyPlate=bag.takeObject({position=transform.pos,rotation=transform.rot})
colonyPlate.lock()
return 1
end
startLuaCoroutine(self,"spawnSubroutine")
end
if gameState.isSoloGame then
logging.broadcastToAll("Solo player has to choose three out of four colonies! Please initialize those you want to use and discard the last!",{1,0,0},loggingModes.exception)
end
end
colonySetup.setupTradingTile=function()
local tradingTile=gameObjectHelpers.getObjectByName("coloniesTradingTile")
tradingTile.setPositionSmooth(tablePositions.colonies.tradingTile.pos)
tradingTile.setRotation(tablePositions.colonies.tradingTile.rot)
end
colonySetup.initializeButtons=function()
local tradingTile=gameObjectHelpers.getObjectByName("coloniesTradingTile")
for buttonName,buttonInfo in pairs(playMatButtons.tradingTile) do
tradingTile.createButton(buttonInfo)
end
end
colonySetup.initialize=function()
colonySetup.initializeButtons()
local tradingTile=gameObjectHelpers.getObjectByName("coloniesTradingTile")
log("Spawning tradeships for players")
for _,player in pairs(gameState.allPlayers) do
if not player.neutral then
colonySystem.spawnFleet(player.color)
end
end
local zoneOffsetTransform={pos={0,0,-0.55},rot=tradingTile.getRotation}
local operationId="colonyTradingTileZone"
zoneHelpers.createScriptingZoneFromTransform(
tradingTile,
zoneOffsetTransform,
operationId,
1,
{7.5,2,4.0}
)
Wait.condition(
function()
gameState.static.coloniesGameData.fleetZone=volatileData.operations[operationId].result
volatileData.operations[operationId]=nil
end,
function() return volatileData.operations[operationId].isDone end
)
end




gameConfigBasicSettingsView={
{
click_function='ToggleVenusWin',
label='Toggle Venus Win',
tooltip='Toggle whether Venus must be terraformed as well before the game ends.',
function_owner=self,
position={-0.4,0.15,0.6},
rotation={0,0,0},
onIndex="gameConfig.setup.venusWin",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ChangeCorpAmount',
label='',
tooltip="Important Note (ignore it if you didn't touch the drafting settings):\n"..
"Drawing corps during any drafting phase will override this value.",
function_owner=Global,
position={0.35,0.15,0.6},
rotation={0,0,0},
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2},
color={0,200/255,255/255},
dynamicLabel={base="Corps to draw: ",value="gameConfig.setup.corpsToDraw"}},
{
click_function='ToggleSolarPhase',
label='Toggle Solar Phase',
function_owner=self,
position={1.1,0.15,0.6},
rotation={0,0,0},
onIndex="gameConfig.setup.solarPhase",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleClassicBoard',
label='Classic Board',
tooltip="Not implemented. Does nothing yet.",
function_owner=self,
position={-0.4,0.15,0.2},
rotation={0,0,0},
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2},
onIndex="gameConfig.setup.classicBoard"},
{
click_function='ToggleDraft',
label='Toggle Drafting',
function_owner=self,
position={0.35,0.1,0.2},
rotation={0,0,0},
onIndex="gameConfig.setup.drafting",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleTimer',
label='Toggle Timer',
function_owner=self,
position={1.1,0.15,0.2},
rotation={0,0,0},
onIndex="gameConfig.setup.timer",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleColonies',
label='Toggle Colonies',
function_owner=self,
position={-0.4,0.15,-0.2},
rotation={0,0,0},
onIndex="gameConfig.setup.colonies",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleTurmoil',
label='Toggle Turmoil',
function_owner=self,
position={0.35,0.15,-0.2},
rotation={0,0,0},
onIndex="gameConfig.setup.turmoil",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleBigBox',
label='Toggle Big Box',
function_owner=self,
position={1.1,0.15,-0.2},
rotation={0,0,0},
onIndex="gameConfig.setup.bigBox",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleCorpEra',
label='Toggle Corporate Era',
function_owner=self,
position={-0.4,0.1,-0.6},
rotation={0,0,0},
onIndex="gameConfig.setup.corpEra",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleVenus',
label='Toggle Venus',
function_owner=self,
position={0.35,0.15,-0.6},
rotation={0,0,0},
onIndex="gameConfig.setup.venus",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='TogglePrelude',
label='Toggle Prelude',
function_owner=self,
position={1.1,0.15,-0.6},
rotation={0,0,0},
onIndex="gameConfig.setup.prelude",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}
}
}


gameConfigFanExpansionsView={
{
click_function='ToggleAres',
label='Toggle Ares',
function_owner=self,
position={-0.4,0.15,0.2},
rotation={0,0,0},
onIndex="gameConfig.setup.ares",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleVenusPhaseTwo',
label='Toggle Venus Phase II',
function_owner=self,
position={0.35,0.15,0.2},
rotation={0,0,0},
onIndex="gameConfig.setup.venusPhaseTwo",
width=1500,
height=500,
font_size=130,
scale={0.2,1,0.2}},
{
click_function='ToggleXenos',
label='Toggle Xenos Corps',
function_owner=self,
position={-0.4,0.15,-0.2},
rotation={0,0,0},
onIndex="gameConfig.setup.xenosCorps",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='TogglePathfinders',
label='Toggle Pathfinders',
function_owner=self,
position={0.35,0.15,-0.2},
rotation={0,0,0},
onIndex="gameConfig.setup.pathfinders",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleHighOrbit',
label='Toggle High Orbit',
function_owner=self,
position={1.1,0.15,-0.2},
rotation={0,0,0},
onIndex="gameConfig.setup.highOrbit",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleShowFanMadeMaps',
label='Toggle Fan Made Maps',
function_owner=self,
position={-0.4,0.15,-0.6},
rotation={0,0,0},
onIndex="gameConfig.setup.showFanMadeMaps",
width=1500,
height=500,
font_size=130,
scale={0.2,1,0.2}},
{
click_function='ToggleBGGCorps',
label='Toggle BGG Corps',
function_owner=self,
position={0.35,0.15,-0.6},
rotation={0,0,0},
onIndex="gameConfig.setup.bggCorps",
width=1500,
height=500,
font_size=165,
scale={0.2,1,0.2}},
{
click_function='ToggleFanMadeProjects',
label='Toggle Fan Made Projects',
function_owner=self,
position={1.1,0.15,-0.6},
rotation={0,0,0},
onIndex="gameConfig.setup.fanMadeProjects",
width=1500,
height=500,
font_size=130,
scale={0.2,1,0.2}
}
}


gameConfigGlobalParametersView={
{
click_function='ChangeTemperatureTrack',
label='',
function_owner=self,
position={-0.4,0.1,-0.6},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
color={240/255,50/255,0,0.95},
dynamicLabel={
prefix="Toggle Temperature\nTrack - Steps: ",
value="#globalParameters.temperature.mappings[gameConfig.globalParameters.temperature.selection].steps"},},
{
click_function='ChangeTemperatureBonusTrack',
label='Toggle Temperature\nBonuses',
tooltip="Not implemented yet.",
function_owner=self,
position={0.35,0.1,-0.6},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
color={240/255,50/255,0,0.95},
onIndex="disableMarker"},
{
click_function='ChangeTemperatureAresTrack',
label='Toggle Temperature\nAres Effects',
tooltip="Not implemented yet.",
function_owner=self,
position={1.1,0.1,-0.6},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
onIndices={"gameConfig.setup.ares","disableMarker"}},
{
click_function='ChangeOxygenTrack',
label='',
function_owner=self,
position={-0.4,0.1,-0.2},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
color={100/255,255/255,0,0.95},
dynamicLabel={
prefix="Toggle Oxygen\nTrack - Steps: ",
value="#globalParameters.oxygen.mappings[gameConfig.globalParameters.oxygen.selection].steps"},},
{
click_function='ChangeOxygenBonusTrack',
label='Toggle Oxygen\nBonuses',
tooltip="Not implemented yet.",
function_owner=self,
position={0.35,0.1,-0.2},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
color={100/255,255/255,0,0.95},
onIndex="disableMarker"},
{
click_function='ChangeOxygenAresTrack',
label='Toggle Oxygen\nAres Effects',
tooltip="Not implemented yet.",
function_owner=self,
position={1.1,0.1,-0.2},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
onIndices={"gameConfig.setup.ares","disableMarker"}},
{
click_function='ChangeOceanTrack',
label='Toggle Ocean\nTrack (9)',
function_owner=self,
position={-0.4,0.1,0.2},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
color={0/255,240/255,200/255,0.95},
dynamicLabel={
prefix="Toggle Ocean\nTrack - Steps: ",
value="#globalParameters.ocean.mappings[gameConfig.globalParameters.ocean.selection].steps"},},
{
click_function='ChangeOceanBonusTrack',
label='Toggle Ocean\nBonuses',
tooltip="Not implemented yet.",
function_owner=self,
position={0.35,0.1,0.2},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
color={0/255,240/255,200/255,0.95},
onIndex="disableMarker"},
{
click_function='ChangeOceanAresTrack',
label='Toggle Ocean\nAres Effects',
tooltip="Not implemented yet.",
function_owner=self,
position={1.1,0.1,0.2},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
onIndices={"gameConfig.setup.ares","disableMarker"}},
{
click_function='ChangeVenusTrack',
label='Toggle Venus\nTrack (15)',
function_owner=self,
position={-0.4,0.1,0.6},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
color={230/255,230/255,0,0.95},
enabledColor={230/255,230/255,0,0.95},
onIndex="gameConfig.setup.venus",
dynamicLabel={
prefix="Toggle Venus\nTrack - Steps: ",
value="#globalParameters.venus.mappings[gameConfig.globalParameters.venus.selection].steps"},},
{
click_function='ChangeVenusBonusTrack',
label='Toggle Venus\nBonuses',
tooltip="Not implemented yet.",
function_owner=self,
position={0.35,0.1,0.6},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
onIndex="disableMarker"
}
}


gameConfigMapGeneratorView={
{
click_function="toggleRandomizedMap",
label="Random Map",
function_owner=self,
position={-0.275,0.15,-0.65},
rotation={0,0,0},
width=1300,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndex="gameConfig.setup.randomMap"},
{
click_function="changeMapSize",
label="Map Size: Normal",
tooltip="Available map sizes:\n"..
"Tiny - 37 Tiles\n"..
"Small - 49 Tiles\n"..
"Normal - 61 Tiles\n"..
"Big - 73 Tiles\n"..
"Large - 91 Tiles\n"..
"Huge - 127 Tiles\n"..
"Gigantic - 159 Tiles",
function_owner=self,
position={-0.275,0.15,-0.5},
rotation={0,0,0},
width=1300,
height=300,
font_size=145,
scale={0.2,1,0.2},
color={0.95,0.6,0.0,0.95},
id="mapSize",
onIndex="gameConfig.setup.randomMap"},
--   tooltip="About 'Map Settings':\n\n"..
--     "About the big table:\n\n"..
--     "The base tile yield defines how much a tile will give most likely. Non-integer values work as well "..
--     "specific tile yield will be rolled and 'n' that tile yield. "..
--     ",meaning you won't see any tiles that give any amount of credits yet because I didn't create that tile yet. ",
--   width=500,
--   color={1,155/255,25/255},},
{
click_function="createMap",
label="Create Map",
function_owner=self,
position={-0.275,0.15,-0.35},
rotation={0,0,0},
width=1300,
height=300,
font_size=145,
scale={0.2,1,0.2},
color={0.95,0.6,0.0,0.95},
onIndex="gameConfig.setup.randomMap"},
{
click_function="loadMapGenPreconfig",
label="Default",
tooltip="A selection of predefined map configurations.\nWarning: Changing this will override all of your current map settings.",
function_owner=self,
position={-0.275,0.15,-0.2},
rotation={0,0,0},
width=1300,
height=300,
font_size=145,
scale={0.2,1,0.2},
color={0.95,0.6,0.0,0.95},
id="mapPreconfig",
onIndex="gameConfig.setup.randomMap"},
{
click_function="changeDeltaFactor",
label="0.1",
tooltip="Delta by which the values in this table shall be changed. Allowed values: 0.01,0.10,1.00",
function_owner=self,
position={-0.425,0.15,-0.025},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.deltaFactor",format="%.2f"}},
{
click_function="changeVolcanoTileAmount",
label="",
tooltip="Number of volcano tiles",
function_owner=self,
position={0.795,0.15,-0.6},
rotation={0,0,0},
width=700,
height=350,
font_size=200,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.absoluteTiles.volcanoTiles"}},
{
click_function="changeBlockedTileAmount",
label="",
tooltip="Not implemented yet.",
function_owner=self,
position={0.795,0.15,-0.5},
rotation={0,0,0},
width=700,
height=350,
font_size=200,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="disableMarker",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.absoluteTiles.blockedTiles"}},
{
click_function="changeBonusTileRatio",
label="",
tooltip="Changes ratio of tiles with bonuses to empty tiles. The higher this number the more tiles with bonuses the map will have.",
function_owner=self,
position={1.25,0.15,-0.51},
rotation={0,0,0},
width=700,
height=350,
font_size=200,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.bonusTilesRatio",format="%.2f"}},
{
click_function="changeInitialErosions",
label="",
tooltip="Not implemented yet.",
function_owner=self,
position={0.795,0.15,-0.3125},
rotation={0,0,0},
width=700,
height=350,
font_size=200,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndices={"gameConfig.setup.randomMap","disableMarker"},
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.absoluteTiles.initialErosions"}},
{
click_function="changeInitialDustorms",
label="",
tooltip="Not implemented yet.",
function_owner=self,
position={0.795,0.15,-0.235},
rotation={0,0,0},
width=700,
height=350,
font_size=200,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndices={"gameConfig.setup.randomMap","disableMarker"},
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.absoluteTiles.initialDuststorms"}},
{
click_function="changeOceanSeedPointsAmount",
label="",
tooltip="Number of seeding tiles for spawning oceans.\n"..
"The higher this number the more ocean chunks you will get.\n"..
"A value of 1 will result in one connected ocean area.",
function_owner=self,
position={1.5,0.15,-0.3125},
rotation={0,0,0},
width=700,
height=350,
font_size=200,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.oceanSettings.oceanSeedPoints"}},
{
click_function="changeSeedMinDistance",
label="",
tooltip="Minium distance between two ocean seed tiles.",
function_owner=self,
position={1.5,0.15,-0.235},
rotation={0,0,0},
width=700,
height=350,
font_size=200,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.oceanSettings.oceanSeedMinDistance"}},
{
click_function="changeShapeFactor",
label="",
tooltip="Controls if ocean areas will have a bulk or more like a snake form.\n"..
"A high value results in a bulk like form.\n"..
"A low value (goes to 0==guranteed no more than 2 ocean tiles adjacent to each other) results in a snake like form.",
function_owner=self,
position={1.5,0.15,-0.1575},
rotation={0,0,0},
width=700,
height=350,
font_size=200,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.oceanSettings.oceanShapeFactor",format="%.2f"}},
{
click_function="changeCreditsWeighting",
label="",
function_owner=self,
position={-0.025,0.15,0.1},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Credits.weighting",format="%.2f"}},
{
click_function="changeCreditsAverageTileYield",
label="",
function_owner=self,
position={0.46,0.15,0.1},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Credits.averageTileYield",format="%.2f"}},
{
click_function="changeCreditsYieldDiffusion",
label="",
function_owner=self,
position={0.945,0.15,0.1},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Credits.yieldDiffusion",format="%.2f"}},
{
click_function="changeCreditsMaxYield",
label="",
function_owner=self,
position={1.425,0.15,0.1},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Credits.maxYield"}},
{
click_function="changeSteelWeighting",
label="",
function_owner=self,
position={-0.025,0.15,0.20678},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Steel.weighting",format="%.2f"}},
{
click_function="changeSteelAverageTileYield",
label="",
function_owner=self,
position={0.46,0.15,0.20678},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Steel.averageTileYield",format="%.2f"}},
{
click_function="changeSteelYieldDiffusion",
label="",
function_owner=self,
position={0.945,0.15,0.20678},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Steel.yieldDiffusion",format="%.2f"}},
{
click_function="changeSteelMaxYield",
label="",
function_owner=self,
position={1.425,0.15,0.20678},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Steel.maxYield"}},
{
click_function="changeTitaniumWeighting",
label="",
function_owner=self,
position={-0.025,0.15,0.31357},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Titanium.weighting",format="%.2f"}},
{
click_function="changeTitaniumAverageTileYield",
label="",
function_owner=self,
position={0.46,0.15,0.31357},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Titanium.averageTileYield",format="%.2f"}},
{
click_function="changeTitaniumYieldDiffusion",
label="",
function_owner=self,
position={0.945,0.15,0.31357},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Titanium.yieldDiffusion",format="%.2f"}},
{
click_function="changeTitaniumMaxYield",
label="",
function_owner=self,
position={1.425,0.15,0.31357},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Titanium.maxYield"}},
{
click_function="changePlantsWeighting",
label="",
function_owner=self,
position={-0.025,0.15,0.42035},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Plants.weighting",format="%.2f"}},
{
click_function="changePlantsAverageTileYield",
label="",
function_owner=self,
position={0.46,0.15,0.42035},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Plants.averageTileYield",format="%.2f"}},
{
click_function="changePlantsYieldDiffusion",
label="",
function_owner=self,
position={0.945,0.15,0.42035},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Plants.yieldDiffusion",format="%.2f"}},
{
click_function="changePlantsMaxYield",
label="",
function_owner=self,
position={1.425,0.15,0.42035},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Plants.maxYield"}},
{
click_function="changeEnergyWeighting",
label="",
function_owner=self,
position={-0.025,0.15,0.52714},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Energy.weighting",format="%.2f"}},
{
click_function="changeEnergyAverageTileYield",
label="",
function_owner=self,
position={0.46,0.15,0.52714},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Energy.averageTileYield",format="%.2f"}},
{
click_function="changeEnergyYieldDiffusion",
label="",
function_owner=self,
position={0.945,0.15,0.52714},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Energy.yieldDiffusion",format="%.2f"}},
{
click_function="changeEnergyMaxYield",
label="",
function_owner=self,
position={1.425,0.15,0.52714},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Energy.maxYield"}},
{
click_function="changeHeatWeighting",
label="",
function_owner=self,
position={-0.025,0.15,0.63392},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Heat.weighting",format="%.2f"}},
{
click_function="changeHeatAverageTileYield",
label="",
function_owner=self,
position={0.46,0.15,0.63392},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Heat.averageTileYield",format="%.2f"}},
{
click_function="changeHeatYieldDiffusion",
label="",
function_owner=self,
position={0.945,0.15,0.63392},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Heat.yieldDiffusion",format="%.2f"}},
{
click_function="changeHeatMaxYield",
label="",
function_owner=self,
position={1.425,0.15,0.63392},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.Heat.maxYield"}},
{
click_function="changeDrawCardWeighting",
label="",
function_owner=self,
position={-0.025,0.15,0.74071},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.DrawCard.weighting",format="%.2f"}},
{
click_function="changeDrawCardAverageTileYield",
label="",
function_owner=self,
position={0.46,0.15,0.74071},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.DrawCard.averageTileYield",format="%.2f"}},
{
click_function="changeDrawCardYieldDiffusion",
label="",
function_owner=self,
position={0.945,0.15,0.74071},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.DrawCard.yieldDiffusion",format="%.2f"}},
{
click_function="changeDrawCardMaxYield",
label="",
function_owner=self,
position={1.425,0.15,0.74071},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.DrawCard.maxYield"}},
{
click_function="changeEffectsWeighting",
label="",
function_owner=self,
position={-0.025,0.15,0.8475},
rotation={0,0,0},
width=1000,
height=400,
font_size=280,
scale={0.1,1,0.1},
enabledColorOverride={0.7,0.6,0.4,0.85},
onIndex="gameConfig.setup.randomMap",
dynamicLabel={base="",value="gameConfig.mapGeneratorConfig.tileEffects.OtherEffects.weighting",format="%.2f"}
}
}


gameConfigAwardsAndMilestonesView={
{
click_function="gameConfigAwardsAndMilestones_swapAwards",
label="Swap Awards",
function_owner=self,
position={0.90,0.15,-0.65},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
color=gameSetupColors.toggleButtonOnColor,
scale={0.2,1,0.2}},
{
click_function="gameConfigAwardsAndMilestones_toggleRandomAwards",
label="Random Awards",
function_owner=self,
position={0.90,0.15,-0.45},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndex="gameConfig.awards.randomizer.enabled"},
{
click_function="gameConfigAwardsAndMilestones_changeNumberOfAwards",
label="Number Of Awards: -1",
function_owner=self,
position={0.90,0.15,-0.25},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndex="gameConfig.awards.randomizer.enabled",
dynamicLabel={base="Number Of Awards: ",value="gameConfig.awards.randomizer.numberOfAwards"}},
{
click_function="gameConfigAwardsAndMilestones_changeMaxNumberOfAwardsPerCategory",
label="Max Awards Per Category: -1",
tooltip="Not implemented yet.",
function_owner=self,
position={0.90,0.15,-0.05},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndices={"gameConfig.awards.randomizer.enabled","disableMarker"},
dynamicLabel={base="Max Awards Per Category: ",value="gameConfig.awards.randomizer.maxAwardsPerCategory"}},
{
click_function="gameConfigAwardsAndMilestones_maxFunders",
label="Max Funders: -1",
function_owner=self,
position={0.90,0.15,0.15},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndex="gameConfig.awards.randomizer.enabled",
dynamicLabel={base="Max Funders: ",value="gameConfig.awards.randomizer.maxFunders"}},
{
click_function="gameConfigAwardsAndMilestones_toggleGuranteeVenuphile",
label="Gurantee Venuphile",
tooltip="Determines whether the Venuphile award will be guranteed if awards are randomized.",
function_owner=self,
position={0.90,0.15,0.35},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndices={"gameConfig.awards.randomizer.enabled",
"gameConfig.awards.randomizer.guranteeVenuphile",
"gameConfig.setup.venus"}},
{
click_function="gameConfigAwardsAndMilestones_randomizeAwards",
label="Randomize Awards",
function_owner=self,
position={0.9,0.15,0.55},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndex="gameConfig.awards.randomizer.enabled",},
{
click_function="gameConfigAwardsAndMilestones_swapMilestones",
label="Swap Milestones",
function_owner=self,
position={-0.2,0.15,-0.65},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
color=gameSetupColors.toggleButtonOnColor,
scale={0.2,1,0.2}},
{
click_function="gameConfigAwardsAndMilestones_toggleRandomMilestones",
label="Random Milestones",
function_owner=self,
position={-0.2,0.15,-0.45},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndex="gameConfig.milestones.randomizer.enabled"},
{
click_function="gameConfigAwardsAndMilestones_changeNumberOfMilestones",
label="Number Of Milestones: -1",
function_owner=self,
position={-0.2,0.15,-0.25},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndex="gameConfig.milestones.randomizer.enabled",
dynamicLabel={base="Number Of Milestones: ",value="gameConfig.milestones.randomizer.numberOfMilestones"}},
{
click_function="gameConfigAwardsAndMilestones_changeMaxNumberOfMilestonesPerCategory",
label="Max Milestones Per Category: -1",
tooltip="Not implemented yet.",
function_owner=self,
position={-0.2,0.15,-0.05},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndices={"gameConfig.milestones.randomizer.enabled","disableMarker"},
dynamicLabel={base="Max Milestones Per Category: ",value="gameConfig.milestones.randomizer.maxMilestonesPerCategory"}},
{
click_function="gameConfigAwardsAndMilestones_maxClaims",
label="Max Claims: -1",
function_owner=self,
position={-0.2,0.15,0.15},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndex="gameConfig.milestones.randomizer.enabled",
dynamicLabel={base="Max Claims: ",value="gameConfig.milestones.randomizer.maxClaims"}},
{
click_function="gameConfigAwardsAndMilestones_toggleGuranteeHoverlord",
label="Gurantee Hoverlord",
tooltip="Determines whether the Hoverlord milestone will be guranteed if milestones are randomized.",
function_owner=self,
position={-0.2,0.15,0.35},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndices={"gameConfig.milestones.randomizer.enabled",
"gameConfig.milestones.randomizer.guranteeHoverlord",
"gameConfig.setup.venus"}},
{
click_function="gameConfigAwardsAndMilestones_randomizeMilestones",
label="Randomize Milestones",
function_owner=self,
position={-0.2,0.15,0.55},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndex="gameConfig.milestones.randomizer.enabled",},
{
click_function="gameConfigAwardsAndMilestones_randomize",
label="Randomize Both",
function_owner=self,
position={0.35,0.15,0.75},
rotation={0,0,0},
width=2400,
height=300,
font_size=165,
scale={0.2,1,0.2},
onIndices={"gameConfig.milestones.randomizer.enabled","gameConfig.awards.randomizer.enabled"},
}
}


gameConfigDraftingView={
{
click_function='gameConfigDraftingFunctions_ChangePreset',
label='',
function_owner=self,
position={-0.3,0.1,-0.6},
rotation={0,0,0},
width=1500,
height=500,
font_size=120,
scale={0.2,1,0.2},
color=gameSetupColors.toggleButtonOnColor,
dynamicLabel={
prefix="Preset: ",
value="gameConfig.drafting.presetDraftingRule.prettyName"},
dynamicTooltip={value="gameConfig.drafting.presetDraftingRule.tooltip"}},
{
click_function='gameConfigDraftingFunctions_ToggleCustomDraftingRules',
label='Custom Drafting Rule',
function_owner=self,
position={0.5,0.1,-0.6},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.2,1,0.2},
onIndex="gameConfig.drafting.custom.active",},
{
click_function='gameConfigDraftingFunctions_StepsPageLeft',
label='<',
function_owner=self,
position={-0.5,0.1,-0.3},
rotation={0,0,0},
width=500,
height=500,
font_size=400,
scale={0.125,1,0.125},
onIndex="gameConfig.drafting.custom.active",},
{
click_function='gameConfigDraftingFunctions_StepsPageRight',
label='>',
function_owner=self,
position={-0.1,0.1,-0.3},
rotation={0,0,0},
width=500,
height=500,
font_size=400,
scale={0.125,1,0.125},
onIndex="gameConfig.drafting.custom.active",},
{
click_function='gameConfigDraftingFunctions_StepsAddRemove',
label='+/-',
tooltip="Left-click to append a draft phase. Right-click to remove the last draft phase.",
function_owner=self,
position={-0.3,0.1,-0.3},
rotation={0,0,0},
width=650,
height=500,
font_size=400,
scale={0.125,1,0.125},
onIndex="gameConfig.drafting.custom.active",},
{
click_function='gameConfigDraftingFunctions_ChangeDrawProjectsAmount',
label='',
function_owner=self,
position={-0.3,0.1,-0.1},
rotation={0,0,0},
width=1500,
height=400,
font_size=150,
scale={0.2,1,0.2},
onIndex="gameConfig.drafting.custom.active",
dynamicLabel={
base="Projects to draw: ",
value="gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.projects.amount"},},
{
click_function='gameConfigDraftingFunctions_ChangeDrawPreludesAmount',
label='',
function_owner=self,
position={0.4,0.1,-0.1},
rotation={0,0,0},
width=1500,
height=400,
font_size=155,
scale={0.2,1,0.2},
onIndex="gameConfig.drafting.custom.active",
dynamicLabel={
base="Preludes to draw: ",
value="gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.preludes.amount"},},
{
click_function='gameConfigDraftingFunctions_ChangeDrawCorpsAmount',
label='',
function_owner=self,
position={1.1,0.1,-0.1},
rotation={0,0,0},
width=1500,
height=400,
font_size=155,
scale={0.2,1,0.2},
onIndex="gameConfig.drafting.custom.active",
dynamicLabel={
base="Corps to draw: ",
value="gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.corps.amount"}},
{
click_function='gameConfigDraftingFunctions_ChangeDrawProjectsTargetHandIndex',
label='',
function_owner=self,
position={-0.3,0.1,0.1},
rotation={0,0,0},
width=1500,
height=400,
font_size=155,
scale={0.2,1,0.2},
onIndex="gameConfig.drafting.custom.active",
dynamicLabel={
base="Target hand index\nProjects: ",
value="gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.projects.targetHandIndex"},},
{
click_function='gameConfigDraftingFunctions_ChangeDrawPreludesTargetHandIndex',
label='',
function_owner=self,
position={0.4,0.1,0.1},
rotation={0,0,0},
width=1500,
height=400,
font_size=155,
scale={0.2,1,0.2},
onIndex="gameConfig.drafting.custom.active",
dynamicLabel={
base="Target hand index\nPreludes: ",
value="gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.preludes.targetHandIndex"},},
{
click_function='gameConfigDraftingFunctions_ChangeDrawCorpsTargetHandIndex',
label='',
function_owner=self,
position={1.1,0.1,0.1},
rotation={0,0,0},
width=1500,
height=400,
font_size=155,
scale={0.2,1,0.2},
onIndex="gameConfig.drafting.custom.active",
dynamicLabel={
base="Target hand index\nCorps: ",
value="gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.corps.targetHandIndex"}},
{
click_function='gameConfigDraftingFunctions_SubStepPageLeft',
label='<',
function_owner=self,
position={-0.1,0.1,0.35},
rotation={0,0,0},
width=500,
height=500,
font_size=500,
scale={0.1,1,0.1},
onIndex="gameConfig.drafting.custom.active",},
{
click_function='gameConfigDraftingFunctions_SubStepPageRight',
label='>',
function_owner=self,
position={0.2,0.1,0.35},
rotation={0,0,0},
width=500,
height=500,
font_size=500,
scale={0.1,1,0.1},
onIndex="gameConfig.drafting.custom.active",},
{
click_function='gameConfigDraftingFunctions_SubStepAddRemove',
label='+/-',
tooltip="Left-click to append a draft step. Right-click to remove the last draft step.",
function_owner=self,
position={0.05,0.1,0.35},
rotation={0,0,0},
width=650,
height=500,
font_size=400,
scale={0.1,1,0.1},
onIndex="gameConfig.drafting.custom.active",},
{
click_function='gameConfigDraftingFunctions_ChangeSubStepHandOverProjects',
label='',
function_owner=self,
position={0.05,0.1,0.525},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.15,1,0.15},
tooltip="Number of projects that have to be passed to the next player for this draft step.",
onIndex="gameConfig.drafting.custom.active",
dynamicLabel={
base="Nr. of projects\nto pass: ",
value="gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].subSteps[gameConfig.drafting.custom.selectedSubStep].projects"},
},
{
click_function='gameConfigDraftingFunctions_ChangeSubStepHandOverPreludes',
label='',
function_owner=self,
position={0.55,0.1,0.525},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.15,1,0.15},
tooltip="Number of preludes that have to be passed to the next player for this draft step.",
onIndex="gameConfig.drafting.custom.active",
dynamicLabel={
base="Nr. of preludes\nto pass: ",
value="gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].subSteps[gameConfig.drafting.custom.selectedSubStep].preludes"},
},
{
click_function='gameConfigDraftingFunctions_ChangeSubStepHandOverCorps',
label='',
function_owner=self,
position={1.05,0.1,0.525},
rotation={0,0,0},
width=1500,
height=500,
font_size=155,
scale={0.15,1,0.15},
tooltip="Number of corps that have to be passed to the next player for this draft step.",
onIndex="gameConfig.drafting.custom.active",
dynamicLabel={
base="Nr. of corps\nto pass: ",
value="gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].subSteps[gameConfig.drafting.custom.selectedSubStep].corps"
}},
{
click_function='noOperation',
label='',
function_owner=self,
position={1.35,0.1,-0.3},
rotation={0,0,0},
width=500,
height=500,
font_size=300,
scale={0.125,1,0.125},
color={100/255,160/255,170/255,0.9},
tooltip="Number of drafting phases.",
dynamicLabel={value="#gameConfig.drafting.custom.steps"}},
{
click_function='noOperation',
label='',
function_owner=self,
position={1.2,0.1,-0.3},
rotation={0,0,0},
width=500,
height=500,
font_size=300,
scale={0.125,1,0.125},
color={100/255,160/255,170/255,0.9},
tooltip="Currently selected drafting phase.",
dynamicLabel={value="gameConfig.drafting.custom.selectedStep"}},
{
click_function='noOperation',
label='',
function_owner=self,
position={1.235,0.1,0.35},
rotation={0,0,0},
width=500,
height=500,
font_size=300,
scale={0.1,1,0.1},
color={100/255,160/255,170/255,0.9},
tooltip="Number of drafting steps for currently selected phase.",
dynamicLabel={value="#gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].subSteps"}},
{
click_function='noOperation',
label='',
function_owner=self,
position={1.115,0.1,0.35},
rotation={0,0,0},
width=500,
height=500,
font_size=300,
scale={0.1,1,0.1},
color={100/255,160/255,170/255,0.9},
tooltip="Currently selected drafting step.",
dynamicLabel={value="gameConfig.drafting.custom.selectedSubStep"},},
{
click_function='gameConfigDraftingFunctions_ExportSettings',
label='|->',
function_owner=self,
position={1.55,0.1,-0.85},
rotation={0,0,0},
width=500,
height=500,
font_size=200,
scale={0.15,1,0.15},
color=gameSetupColors.toggleButtonOnColor,
tooltip="Export drafting settings. (Copy from notes for reuse)"},
{
click_function='gameConfigDraftingFunctions_ImportSettings',
label='->|',
function_owner=self,
position={1.55,0.1,-0.65},
rotation={0,0,0},
width=500,
height=500,
font_size=200,
scale={0.15,1,0.15},
color=gameSetupColors.toggleButtonOnColor,
tooltip="Import draft settings from notes.",
}
}

gameConfigMatViews={}
gameConfigMatViews.mainButtons={
{
click_function='printConfig',
label="Show Config",
tooltip="Shows the current configuration in the notes text box.\n"..
"In order to copy the contents,click on the 'Edit Note' button in the bottom right corner\n"..
"Click into the notes text box and press 'CTRL + a' to select everything\n"..
"Remarks:\n"..
" - 'CTRL + a' is the only way that everything from the config will be selected and copied.\n"..
" - if you miss a part of the config you won't be able to load the config later on.\n",
function_owner=self,
position={-1.3,0.3,-0.85},
rotation={0,0,0},
width=2800,
height=600,
font_size=450,
scale={0.1,0.1,0.1},
color={255/255,115/255,0,0.95},},
{
click_function='loadConfig',
label="Load Config",
tooltip="Replace the current game config if there is one in the notes text block in the bottom right corner.\n"..
"To copy a game config into the notes text block,just press the 'Edit Notes' button in the bottom right corner to start editing the notes,"..
"click somewhere into the text block field and paste the new game config into the notes field.\n"..
"If loading the config failed you've probably missed a part when you initially copied the game config.",
function_owner=self,
position={-1.3,0.3,-0.65},
rotation={0,0,0},
width=2800,
height=600,
font_size=450,
scale={0.1,0.1,0.1},
color={255/255,115/255,0,0.95},},
{
click_function='clearNotes',
label="Clear Notes",
tooltip="Clears any text from the notes text block.",
function_owner=self,
position={-1.3,0.3,-0.45},
rotation={0,0,0},
width=2800,
height=600,
font_size=450,
scale={0.1,0.1,0.1},
color={255/255,115/255,0,0.95}},
{
click_function='toggleGameConfigSettings',
label="Basic Settings",
tooltip="Toggle between settings.",
function_owner=self,
position={0.35,0.3,-0.85},
rotation={0,0,0},
width=9000,
height=600,
font_size=450,
scale={0.1,0.1,0.1},
color={255/255,115/255,0,0.95},
buttonType="toggleGameConfigSettings",},
{
click_function='ChangeBoard',
label='Change Map',
function_owner=self,
position={-1.3,0.3,0.35},
rotation={0,0,0},
width=2800,
height=600,
font_size=450,
scale={0.1,0.1,0.1},
color={255/255,115/255,0,0.95}},
{
click_function='FinishSetup',
label='Finish Setup',
function_owner=self,
position={-1.3,0.3,0.55},
rotation={0,0,0},
width=2800,
height=600,
font_size=450,
scale={0.1,0.1,0.1},
color={255/255,115/255,0,0.95},
buttonType="finishSetupButton",},
{
click_function='initialResearch',
label='Start Game',
function_owner=self,
position={-1.3,0.3,0.75},
rotation={0,0,0},
width=2800,
height=600,
font_size=450,
scale={0.1,0.1,0.1},
color={50/255,50/255,50/255,0.95},
buttonType="startGameButton",
}
}
gameConfigMatViews.views={
{buttons=gameConfigBasicSettingsView,toggleLabel="Basic Settings",imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164339050293427/423FB195C762CFFCA4C57707819EC35AE20D4DB7/"},
{buttons=gameConfigFanExpansionsView,toggleLabel="Fan Expansions",imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164339050293427/423FB195C762CFFCA4C57707819EC35AE20D4DB7/"},
{buttons=gameConfigGlobalParametersView,toggleLabel="Global Parameter Settings",imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164339050293427/423FB195C762CFFCA4C57707819EC35AE20D4DB7/"},
{buttons=gameConfigMapGeneratorView,toggleLabel="Map Settings",imageUrl="http://cloud-3.steamusercontent.com/ugc/1691647367269739152/D70A25A864C12D08B6F4C1F255B306815ECF5E44/"},
{buttons=gameConfigAwardsAndMilestonesView,toggleLabel="Awards & Milestones Settings",imageUrl="http://cloud-3.steamusercontent.com/ugc/1714164339050293427/423FB195C762CFFCA4C57707819EC35AE20D4DB7/"},
{buttons=gameConfigDraftingView,toggleLabel="Drafting Settings",imageUrl="http://cloud-3.steamusercontent.com/ugc/1691648342676700524/E1DB0539577AB8B6500C45A035AF532F766C2C40/"},
}
gameConfigMatViews.currentView=1


function ToggleTimer()
gameConfig.setup.timer=not gameConfig.setup.timer
createAllSetupButtons()
end
function ToggleShowFanMadeMaps()
gameConfig.setup.showFanMadeMaps=not gameConfig.setup.showFanMadeMaps
createAllSetupButtons()
end
function ToggleSolarPhase()
if gameConfig.setup.turmoil then return end
gameConfig.setup.solarPhase=not gameConfig.setup.solarPhase
createAllSetupButtons()
end
function ToggleVenus()
gameConfig.setup.venus=not gameConfig.setup.venus
if gameConfig.setup.venus==false and gameConfig.setup.venusPhaseTwo==true then
gameConfig.setup.venusPhaseTwo=false
end
createAllSetupButtons()
end
function ToggleClassicBoard()
if true then return end
if isDoubleClick("ToggleClassicBoard") then return end
function toggleClassicBoardCoroutine()
local waitCounter=0
while waitCounter < 30 do
for _,isOngoing in pairs(cloningOngoingTable) do
if isOngoing==true then return 1 end
end
if transientState.removingPlayer or cloningOngoing then return 1 end
waitCounter=waitCounter + 1
coroutine.yield(0)
end
gameConfig.setup.classicBoard=not gameConfig.setup.classicBoard
tablePositions.update()
board.update(true)
createAllSetupButtons()
return 1
end
startLuaCoroutine(self,"toggleClassicBoardCoroutine")
end
function ToggleTurmoil()
gameConfig.setup.turmoil=not gameConfig.setup.turmoil
if gameConfig.setup.turmoil then
gameConfig.setup.solarPhase=true
end
createAllSetupButtons()
end
function ToggleColonies()
gameConfig.setup.colonies=not gameConfig.setup.colonies
createAllSetupButtons()
end
function TogglePrelude()
gameConfig.setup.prelude=not gameConfig.setup.prelude
createAllSetupButtons()
end
function ToggleCorpEra()
gameConfig.setup.corpEra=not gameConfig.setup.corpEra
createAllSetupButtons()
end
function ToggleBGGCorps()
gameConfig.setup.bggCorps=not gameConfig.setup.bggCorps
createAllSetupButtons()
end
function ToggleBigBox()
gameConfig.setup.bigBox=not gameConfig.setup.bigBox
createAllSetupButtons()
end
function ToggleVenusWin()
gameConfig.setup.venusWin=not gameConfig.setup.venusWin
if gameConfig.setup.venus==false and gameConfig.setup.venusWin then
gameConfig.setup.venus=true
end
createAllSetupButtons()
end
function ToggleExtendedScripting()
gameConfig.setup.extendedScripting=not gameConfig.setup.extendedScripting
createAllSetupButtons()
end
function ToggleDraft()
gameConfig.setup.drafting=not gameConfig.setup.drafting
createAllSetupButtons()
end
function ToggleXenos()
gameConfig.setup.xenosCorps=not gameConfig.setup.xenosCorps
createAllSetupButtons()
end
function ToggleFanMadeProjects()
gameConfig.setup.fanMadeProjects=not gameConfig.setup.fanMadeProjects
createAllSetupButtons()
end
function ToggleRandomizer()
gameConfig.setup.randomizer=not gameConfig.setup.randomizer
createAllSetupButtons()
end
function ToggleHighOrbit()
gameConfig.setup.highOrbit=not gameConfig.setup.highOrbit
createAllSetupButtons()
end
function ToggleVenusPhaseTwo()
gameConfig.setup.venusPhaseTwo=not gameConfig.setup.venusPhaseTwo
if gameConfig.setup.venus==false and gameConfig.setup.venusPhaseTwo==true then
gameConfig.setup.venus=true
end
createAllSetupButtons()
end
function ToggleAres()
gameConfig.setup.ares=not gameConfig.setup.ares
createAllSetupButtons()
end
function TogglePathfinders()
gameConfig.setup.pathfinders=not gameConfig.setup.pathfinders
createAllSetupButtons()
end
function readGameConfigOnGameLoad()
if getNotes()~="" and string.find(getNotes(),"{") then
gameConfigFunctions_loadConfig()
end
end
function gameConfigFunctions_loadConfig()
gameConfig=JSON.decode(getNotes())
if gameConfig.setup.randomMap then
gameConfigMapGeneratorFunctions.updateMapSettingsPreConfigButton()
end
createAllSetupButtons()
setNotes("")
end
function gameConfigFunctions_publishConfig()
setNotes(JSON.encode(gameConfig))
end
function ChangeCorpAmount(obj,_,altClick)
local delta=1
if altClick then
delta=-1
end
gameConfig.setup.corpsToDraw=gameConfig.setup.corpsToDraw + delta
if gameConfig.setup.corpsToDraw > 10 then
gameConfig.setup.corpsToDraw=10
elseif gameConfig.setup.corpsToDraw < 0 then
gameConfig.setup.corpsToDraw=0
end
for _,buttonInfo in pairs(gameConfigBasicSettingsView) do
if buttonInfo.buttonType=="corpCounter" then
buttonInfo.label= "Corps to draw: "..gameConfig.setup.corpsToDraw
end
end
createAllSetupButtons()
end
function gameConfigFunctions_clearNotes()
setNotes("")
end
function gameConfigFunctions_toggleMapSize()
local newSelection=gameConfig.mapGeneratorConfig.mapSizeSelection + 1
if gameConfig.mapGeneratorConfig.mapSizeSelection > #mapSizes then
gameConfig.mapGeneratorConfig.mapSizeSelection=1
elseif gameConfig.mapGeneratorConfig.mapSizeSelection < 0 then
gameConfig.mapGeneratorConfig.mapSizeSelection=#mapSizes
end
gameConfig.mapGeneratorConfig.mapSizeSelection=newSelection
end
function gameConfigFunctions_changeMapGeneratorTileAverageTileYield(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.tileEffects[params.resourceType],"averageTileYield",params.delta,1,20)
end
function gameConfigFunctions_changeMapGeneratorTileYieldDiffusion(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.tileEffects[params.resourceType],"yieldDiffusion",params.delta,0,1)
end
function gameConfigFunctions_changeMapGeneratorTileMaxYield(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.tileEffects[params.resourceType],"maxYield",params.delta,1,10)
end
function gameConfigFunctions_changeTileEffectWeightings(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.tileEffects[params.resourceType],"weighting",params.delta,0,20)
end
function gameConfigFunctions_changeNumberOfVolcanoTiles(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.absoluteTiles,"volcanoTiles",params.delta,0,5)
end
function gameConfigFunctions_changeNumberOfBlockedTiles(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.absoluteTiles,"blockedTiles",params.delta,0,5)
end
function gameConfigFunctions_changeNumberOfInitialErosions(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.absoluteTiles,"initialErosions",params.delta,0,50)
end
function gameConfigFunctions_changeNumberOfInitialDuststorms(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.absoluteTiles,"initialDuststorms",params.delta,0,50)
end
function gameConfigFunctions_changeBonusTileRatio(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig,"bonusTilesRatio",params.delta,0,1000)
end
function gameConfigFunctions_changeOceanSeedPoints(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.oceanSettings,"oceanSeedPoints",params.delta,1,30)
end
function gameConfigFunctions_changeOceanSeedMinDistance(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.oceanSettings,"oceanSeedMinDistance",params.delta,1,15)
end
function gameConfigFunctions_changeOceanShapeFactor(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig.oceanSettings,"oceanShapeFactor",params.delta,0,20)
end
function gameConfigFunctions_changeMapSize(params)
tableHelpers.changeNumericValue(gameConfig.mapGeneratorConfig,"mapSizeSelection",params.delta,1,tableHelpers.getCount(randomizerTemplates))
end
function gameConfigFunctions_changeGlobalParameterSelection(params)
local newSelection=gameConfig.globalParameters[params.what].selection + params.delta
if newSelection > #globalParameters[params.what].mappings then
newSelection=1
elseif newSelection < 1 then
newSelection=#globalParameters[params.what].mappings
end
local selectionInfo={}
gameConfig.globalParameters[params.what].selection=newSelection
adaptGlobalParameter(nil,nil,nil)
end
function gameConfigFunctions_changeGlobalParameterBonusesSelection(params)
local newSelection=gameConfig.globalParameters[params.what].bonusSelection + params.delta
if newSelection > #globalParameters[params.what].bonus then
newSelection=1
elseif newSelection < 1 then
newSelection=#globalParameters[params.what].bonus
end
gameConfig.globalParameters[params.what].bonusSelection=newSelection
end
function gameConfigFunctions_changeGlobalParameterAresSelection(params)
if globalParameters[params.what].ares==nil then
logging.broadcastToAll(params.what.." does not have an ares track. Doing nothing.")
return
end
local newSelection=gameConfig.globalParameters[params.what].aresSelection + params.delta
if newSelection > #globalParameters[params.what].ares then
newSelection=1
elseif newSelection < 1 then
newSelection=#globalParameters[params.what].ares
end
gameConfig.globalParameters[params.what].aresSelection=newSelection
end
function loadExpansionBoardgameTile()
local properties=boardgameTileProperties.baseGame
if gameConfig.setup.pathfinders then
properties=boardgameTileProperties.allExpansions
elseif gameConfig.setup.turmoil or gameConfig.setup.colonies then
properties=boardgameTileProperties.withoutPathfinders
end
local gameBoardTile=gameObjectHelpers.getObjectByName("gameBoardTile")
local customization={}
local scale=gameBoardTile.getScale()
customization.image=properties.imageUrl
gameBoardTile.setCustomObject(customization)
local reloadedTile=gameBoardTile.reload()
reloadedTile.interactable=false
Wait.time(function()
Wait.condition(function()
reloadedTile.setLock(true)
reloadedTile.setScale(scale)
end,function() return reloadedTile.resting end)
end,2)
end
function DisableSolarPhase()
if gameState.turmoil==true then
logging.broadcastToAll("Turmoil requires solar phase",{1,1,1},loggingModes.exception)
else
gameState.solarPhase=false
end
end
function EnableDraft()
logging.broadcastToAll("Drafting enabled.",{1,1,1},loggingModes.exception)
gameState.draftingEnabled=true
end
function ChangeBoard(_,_,altClick)
local delta=1
if altClick then
delta=-1
end
ChangeBoardInternal(delta)
end
function ChangeBoardInternal(delta)
gameState.selectedMap=gameState.selectedMap + delta
if gameConfig.setup.showFanMadeMaps and gameState.selectedMap > tableHelpers.getCount(predefinedMaps) - 1 then
gameState.selectedMap=1
elseif gameConfig.setup.showFanMadeMaps and gameState.selectedMap < 1 then
gameState.selectedMap=tableHelpers.getCount(predefinedMaps) - 1
elseif not gameConfig.setup.showFanMadeMaps and gameState.selectedMap > 3 then
gameState.selectedMap=1
elseif not gameConfig.setup.showFanMadeMaps and gameState.selectedMap < 1 then
gameState.selectedMap=3
end
local customization={}
local scale={1,1,1}
local index=1
for name,mapData in pairs(predefinedMaps) do
if gameState.selectedMap==index then
log("Map selected: "..name)
gameMap=hexMapHelpers.makeMapComputeFriendly(mapData)
customization.image=mapData.metadata.imageUrl
scale=mapData.metadata.scale
adaptGlobalParametersFromMapMetadata(mapData.metadata)
break
end
index=index + 1
end
local marsMapTile=gameObjectHelpers.getObjectByName("marsMapTile")
marsMapTile.setCustomObject(customization)
local reloadedTile=marsMapTile.reload()
Wait.frames(|| reloadedTile.setScale(scale),4)
if gameMap~=nil then
gameMap.metadata.wasUpdated=true
end
end
--Spawn Button to Set No of Corps
function ChooseCorpAmount()
local object=gameObjectHelpers.getObjectByName("corpAmountToken")
local setupMat=gameObjectHelpers.getObjectByName("setupMat")
for index,buttonInfo in pairs(gameSetupMatButtons.setup) do
if buttonInfo.label=="Set No. of Corps" then
local targetPosition=vectorHelpers.fromLocalToWorld(setupMat,buttonInfo.position)
object.setPosition(targetPosition)
object.setRotation({0,180,0})
object.setScale({0.5,1,0.5})
object.lock()
gameSetupMatButtons.setup[index].scale={0,0,0}
end
end
createAllSetupButtons()
end
function adaptGlobalParametersFromMapMetadata(metadata)
local globalParametersSelectionInfo=metadata.globalParameterDefaultMappings
local bonusSelectionInfo=metadata.bonusDefaultMappings
local aresSelectionInfo=metadata.aresDefaultMappings
adaptGlobalParameter(globalParametersSelectionInfo,bonusSelectionInfo,aresSelectionInfo)
end
function adaptGlobalParameter(globalParametersSelectionInfo,bonusSelectionInfo,aresSelectionInfo)
for name,globalParameterInfo in pairs(globalParameters) do
if type(globalParameterInfo)=="table" then
local newStepsMappingSelection=gameConfig.globalParameters[name].selection
local newBonusMappingSelection=gameConfig.globalParameters[name].bonusSelection
local newAresMappingSelection=gameConfig.globalParameters[name].aresSelection
if globalParametersSelectionInfo~=nil and globalParametersSelectionInfo[name]~=nil then
newStepsMappingSelection=globalParametersSelectionInfo[name].mappingIndex
end
if bonusSelectionInfo~=nil and bonusSelectionInfo[name]~=nil then
newBonusMappingSelection=bonusSelectionInfo[name].mappingIndex
end
if aresSelectionInfo~=nil and aresSelectionInfo[name]~=nil then
newAresMappingSelection=aresSelectionInfo[name].mappingIndex
end
globalParameterSystem.values[name].bonusSelection=newBonusMappingSelection
globalParameterSystem.values[name].aresSelection=newAresMappingSelection
if newStepsMappingSelection~=globalParameterSystem.values[name].selection then
globalParameterSystem.values[name].selection=newStepsMappingSelection
changeGlobalParameterTrack(name,newStepsMappingSelection)
end
end
end
end
function changeGlobalParameterTrack(globalParameterName,selection)
if transientState.changingGlobalParameters==nil then
transientState.changingGlobalParameters={globalParameterName={inProgress=false,latestSelection=selection}}
elseif transientState.changingGlobalParameters[globalParameterName]==nil then
transientState.changingGlobalParameters[globalParameterName]={inProgress=false,latestSelection=selection}
else
transientState.changingGlobalParameters[globalParameterName].latestSelection=selection
end
function changeGlobalParameterTrackCoroutine()
while transientState.changingGlobalParameters[globalParameterName].inProgress do
coroutine.yield(0)
end
transientState.changingGlobalParameters[globalParameterName].inProgress=true
local trackObject=getObjectFromGUID(globalParameters[globalParameterName].objectGuid)
customization={}
customization.image=globalParameters[globalParameterName].mappings[transientState.changingGlobalParameters[globalParameterName].latestSelection].imageUrl
trackObject.setCustomObject(customization)
local counter=20
while counter > 0 do
if not trackObject.resting then
counter=20
end
counter=counter - 1
coroutine.yield(0)
end
trackObject.reload()
for i=1,5 do
coroutine.yield(0)
end
transientState.changingGlobalParameters[globalParameterName].inProgress=false
return 1
end
startLuaCoroutine(self,"changeGlobalParameterTrackCoroutine")
end


function ChangeTemperatureTrack(_,_,altClick)
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterSelection({what="temperature",delta=delta})
updateGlobalParameterSelectionButtonLabel("changeTemperatureTrackButton","Toggle Temperature\nTrack","temperature")
end
function ChangeOxygenTrack(_,_,altClick)
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterSelection({what="oxygen",delta=delta})
updateGlobalParameterSelectionButtonLabel("changeOxygenTrackButton","Toggle Oxygen\nTrack","oxygen")
end
function ChangeOceanTrack(_,_,altClick)
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterSelection({what="ocean",delta=delta})
updateGlobalParameterSelectionButtonLabel("changeOceanTrackButton","Toggle Ocean\nTrack","ocean")
end
function ChangeVenusTrack(_,_,altClick)
if gameConfig.setup.venus then
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterSelection({what="venus",delta=delta})
updateGlobalParameterSelectionButtonLabel("changeVenusTrackButton","Toggle Venus\nTrack","venus")
end
end
function ChangeTemperatureBonusTrack(_,_,altClick)
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterBonusesSelection({what="temperature",delta=delta})
end
function ChangeOxygenBonusTrack(_,_,altClick)
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterBonusesSelection({what="oxygen",delta=delta})
end
function ChangeOceanBonusTrack(_,_,altClick)
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterBonusesSelection({what="ocean",delta=delta})
end
function ChangeVenusBonusTrack(_,_,altClick)
if gameConfig.setup.venus then
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterBonusesSelection({what="venus",delta=delta})
end
end
function ChangeTemperatureAresTrack(_,_,altClick)
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterAresSelection({what="temperature",delta=delta})
end
function ChangeOxygenAresTrack(_,_,altClick)
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterAresSelection({what="oxygen",delta=delta})
end
function ChangeOceanAresTrack(_,_,altClick)
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeGlobalParameterAresSelection({what="ocean",delta=delta})
end
function updateGlobalParameterSelectionButtonLabel(buttonId,baseLabel,globalParameterName)
for i,buttonInfo in pairs(gameConfigGlobalParametersView) do
if buttonInfo.id==buttonId then
local stepCount=#globalParameters[globalParameterName].mappings[gameConfig.globalParameters[globalParameterName].selection].steps - 1
buttonInfo.label=baseLabel.." ("..stepCount..")"
end
end
createAllSetupButtons()
end


gameConfigMapGeneratorFunctions={}
gameConfigMapGeneratorFunctions.getDeltaValue=function(isNegative,amount)
local delta=amount or 1
if isNegative then
return -delta
else
return delta
end
end
gameConfigMapGeneratorFunctions.initializeMapGeneratorCounters=function()
createAllSetupButtons()
end
gameConfigMapGeneratorFunctions.adaptButtonLabel=function(id,newValue,isCustomLabel,tooltip)
isEnabled=isEnabled or true
isCustomLabel=isCustomLabel or false
for _,view in pairs(gameConfigMatViews.views) do
for _,buttonInfo in pairs(view.buttons) do
if buttonInfo.id~=nil and buttonInfo.id==id then
if isCustomLabel then
buttonInfo.label=newValue
else
buttonInfo.label=string.format("%.2f",newValue)
end
if tooltip~=nil then
buttonInfo.tooltip=tooltip
end
end
end
end
end
gameConfigMapGeneratorFunctions.changeValue=function(resourceType,setting,id,altClick)
if not gameConfig.setup.randomMap then
return
end
local delta=gameConfigMapGeneratorFunctions.getDeltaValue(altClick,gameConfig.mapGeneratorConfig.deltaFactor)
if setting=="weighting" then
gameConfigFunctions_changeTileEffectWeightings({resourceType=resourceType,delta=delta})
elseif setting=="averageTileYield" then
gameConfigFunctions_changeMapGeneratorTileAverageTileYield({resourceType=resourceType,delta=delta})
elseif setting=="yieldDiffusion" then
gameConfigFunctions_changeMapGeneratorTileYieldDiffusion({resourceType=resourceType,delta=delta})
elseif setting=="maxYield" then
delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeMapGeneratorTileMaxYield({resourceType=resourceType,delta=delta})
end
createAllSetupButtons()
end
function toggleRandomizedMap(_,_,altClick)
gameConfig.setup.randomMap=not gameConfig.setup.randomMap
if not gameConfig.setup.randomMap then
mapGenerator.destroyMap()
ChangeBoardInternal(0)
else
updateRandomMapTile()
end
createAllSetupButtons()
end
function updateRandomMapTile()
local marsMapTile=gameObjectHelpers.getObjectByName("marsMapTile")
marsMapTile.setCustomObject({image=randomMapBaseImage})
local reloadedTile=marsMapTile.reload()
local scale={1,1,1}
local index=1
for _,templateInfo in pairs(randomizerTemplates) do
if index==gameConfig.mapGeneratorConfig.mapSizeSelection then
scale=templateInfo.metadata.scale
break
end
index=index + 1
end
Wait.frames(|| reloadedTile.setScale(scale),4)
end
function changeDeltaFactor(_,_,altClick)
if not gameConfig.setup.randomMap then
return
end
local factor=10
if altClick then
factor=0.1
end
gameConfig.mapGeneratorConfig.deltaFactor=gameConfig.mapGeneratorConfig.deltaFactor * factor
if gameConfig.mapGeneratorConfig.deltaFactor < 0.01 then
gameConfig.mapGeneratorConfig.deltaFactor=0.01
elseif gameConfig.mapGeneratorConfig.deltaFactor > 1 then
gameConfig.mapGeneratorConfig.deltaFactor=1
end
createAllSetupButtons()
end
function changeMapSize(_,_,altClick)
if not gameConfig.setup.randomMap then
return
end
local delta=1
if altClick then delta=-1 end
local customLabel=""
local counter=1
gameConfigFunctions_changeMapSize({delta=delta})
for templateName,_ in pairs(randomizerTemplates) do
if counter==gameConfig.mapGeneratorConfig.mapSizeSelection then
customLabel="Map Size: "..(templateName:gsub("^%l",string.upper))
end
counter=counter + 1
end
gameConfigMapGeneratorFunctions.adaptButtonLabel("mapSize",customLabel,true)
updateRandomMapTile()
mapGenerator.destroyMap(gameMap)
createAllSetupButtons()
end
function changeVolcanoTileAmount(_,_,altClick)
if not gameConfig.setup.randomMap then
return
end
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeNumberOfVolcanoTiles({delta=delta})
createAllSetupButtons()
end
function changeBlockedTileAmount(_,_,altClick)
if not gameConfig.setup.randomMap then
return
end
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeNumberOfBlockedTiles({delta=delta})
createAllSetupButtons()
end
function changeBonusTileRatio(_,_,altClick)
if not gameConfig.setup.randomMap then
return
end
local delta=gameConfig.mapGeneratorConfig.deltaFactor
if altClick then delta=-gameConfig.mapGeneratorConfig.deltaFactor end
if gameConfig.mapGeneratorConfig.bonusTilesRatio >= 10 then delta=delta * 10 end
if gameConfig.mapGeneratorConfig.bonusTilesRatio >= 100 then delta=delta * 10 end
gameConfigFunctions_changeBonusTileRatio({delta=delta})
createAllSetupButtons()
end
function changeInitialErosions(_,_,altClick)
if not gameConfig.setup.randomMap and gameConfig.setup.ares then
return
end
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeNumberOfInitialErosions({delta=delta})
createAllSetupButtons()
end
function changeInitialDustorms(_,_,altClick)
if not gameConfig.setup.randomMap and gameConfig.setup.ares then
return
end
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeNumberOfInitialDuststorms({delta=delta})
createAllSetupButtons()
end
function changeOceanSeedPointsAmount(_,_,altClick)
if not gameConfig.setup.randomMap then
return
end
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeOceanSeedPoints({delta=delta})
createAllSetupButtons()
end
function changeSeedMinDistance(_,_,altClick)
if not gameConfig.setup.randomMap then
return
end
local delta=1
if altClick then delta=-1 end
gameConfigFunctions_changeOceanSeedMinDistance({delta=delta})
createAllSetupButtons()
end
function changeShapeFactor(_,_,altClick)
if not gameConfig.setup.randomMap then
return
end
local delta=gameConfig.mapGeneratorConfig.deltaFactor
if altClick then delta=-gameConfig.mapGeneratorConfig.deltaFactor end
gameConfigFunctions_changeOceanShapeFactor({delta=delta})
createAllSetupButtons()
end
function loadMapGenPreconfig(_,_,altClick)
if not gameConfig.setup.randomMap then
return
end
local delta=1
if altClick then delta=-1 end
gameConfig.setup.mapPredefinedSettings=gameConfig.setup.mapPredefinedSettings + delta
if gameConfig.setup.mapPredefinedSettings > tableHelpers.getCount(predefinedMapSettings) then
gameConfig.setup.mapPredefinedSettings=1
elseif gameConfig.setup.mapPredefinedSettings < 1 then
gameConfig.setup.mapPredefinedSettings=tableHelpers.getCount(predefinedMapSettings)
end
local counter=1
for name,setting in pairs(predefinedMapSettings) do
if counter==gameConfig.setup.mapPredefinedSettings then
gameConfig.mapGeneratorConfig=tableHelpers.deepClone(setting.config.mapGeneratorConfig)
end
counter=counter + 1
end
gameConfigMapGeneratorFunctions.updateMapSettingsPreConfigButton()
end
gameConfigMapGeneratorFunctions.updateMapSettingsPreConfigButton=function()
local counter=1
local customLabel=""
for _,setting in pairs(predefinedMapSettings) do
if counter==gameConfig.setup.mapPredefinedSettings then
customLabel=setting.prettyName
tooltip="A selection of predefined map configurations.\n\n"..
"Warning: Changing this will override all of your current map settings.\n\n"..
"Details:\n"..
setting.description
gameConfigMapGeneratorFunctions.adaptButtonLabel("mapPreconfig",customLabel,true,tooltip)
break
end
counter=counter + 1
end
gameConfigMapGeneratorFunctions.initializeMapGeneratorCounters()
end
function changeCreditsWeighting(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Credits","weighting","creditsWeighting",altClick) end
function changeCreditsAverageTileYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Credits","averageTileYield","creditsAverageTileYield",altClick) end
function changeCreditsYieldDiffusion(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Credits","yieldDiffusion","creditsYieldDiffusion",altClick) end
function changeCreditsMaxYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Credits","maxYield","creditsMaxYield",altClick) end
function changeSteelWeighting(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Steel","weighting","steelWeighting",altClick) end
function changeSteelAverageTileYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Steel","averageTileYield","steelAverageTileYield",altClick) end
function changeSteelYieldDiffusion(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Steel","yieldDiffusion","steelYieldDiffusion",altClick) end
function changeSteelMaxYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Steel","maxYield","steelMaxYield",altClick) end
function changeTitaniumWeighting(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Titanium","weighting","titaniumWeighting",altClick) end
function changeTitaniumAverageTileYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Titanium","averageTileYield","titaniumAverageTileYield",altClick) end
function changeTitaniumYieldDiffusion(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Titanium","yieldDiffusion","titaniumYieldDiffusion",altClick) end
function changeTitaniumMaxYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Titanium","maxYield","titaniumMaxYield",altClick) end
function changePlantsWeighting(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Plants","weighting","plantsWeighting",altClick) end
function changePlantsAverageTileYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Plants","averageTileYield","plantsAverageTileYield",altClick) end
function changePlantsYieldDiffusion(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Plants","yieldDiffusion","plantsYieldDiffusion",altClick) end
function changePlantsMaxYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Plants","maxYield","plantsMaxYield",altClick) end
function changeEnergyWeighting(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Energy","weighting","energyWeighting",altClick) end
function changeEnergyAverageTileYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Energy","averageTileYield","energyAverageTileYield",altClick) end
function changeEnergyYieldDiffusion(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Energy","yieldDiffusion","energyYieldDiffusion",altClick) end
function changeEnergyMaxYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Energy","maxYield","energyMaxYield",altClick) end
function changeHeatWeighting(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Heat","weighting","heatWeighting",altClick) end
function changeHeatAverageTileYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Heat","averageTileYield","heatAverageTileYield",altClick) end
function changeHeatYieldDiffusion(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Heat","yieldDiffusion","heatYieldDiffusion",altClick) end
function changeHeatMaxYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("Heat","maxYield","heatMaxYield",altClick) end
function changeDrawCardWeighting(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("DrawCard","weighting","drawCardWeighting",altClick) end
function changeDrawCardAverageTileYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("DrawCard","averageTileYield","drawCardAverageTileYield",altClick) end
function changeDrawCardYieldDiffusion(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("DrawCard","yieldDiffusion","drawCardYieldDiffusion",altClick) end
function changeDrawCardMaxYield(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("DrawCard","maxYield","drawCardMaxYield",altClick) end
function changeEffectsWeighting(_,_,altClick) gameConfigMapGeneratorFunctions.changeValue("OtherEffects","weighting","effectsWeighting",altClick) end


--- Milestones
function gameConfigAwardsAndMilestones_swapMilestones(_,_,altClick)
local delta=altClick and -1 or 1
tableHelpers.changeNumericValue(gameConfig.milestones,"currentSelection",delta,1,4,true)
milestoneSystem_toggleMilestones({nextSet=gameConfig.milestones.currentSelection})
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_toggleRandomMilestones(_,_,_)
gameConfig.milestones.randomizer.enabled=not gameConfig.milestones.randomizer.enabled
if gameConfig.milestones.randomizer.enabled then
if gameConfig.milestones.randomizer.numberOfMilestones~=#gameState.milestoneGuids then
milestoneSystem.setupMilestones()
end
milestoneSystem.randomize()
else
milestoneSystem_toggleMilestones({nextSet=gameConfig.milestones.currentSelection})
end
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_changeNumberOfMilestones(_,_,altClick)
if not gameConfig.milestones.randomizer.enabled then return end
local delta=altClick and -1 or 1
tableHelpers.changeNumericValue(gameConfig.milestones.randomizer,"numberOfMilestones",delta,3,10)
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_changeMaxNumberOfMilestonesPerCategory(_,_,altClick)
if not gameConfig.milestones.randomizer.enabled then return end
local delta=altClick and -1 or 1
tableHelpers.changeNumericValue(gameConfig.milestones.randomizer,"maxMilestonesPerCategory",delta,1,10)
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_maxClaims(_,_,altClick)
if not gameConfig.milestones.randomizer.enabled then return end
local delta=altClick and -1 or 1
tableHelpers.changeNumericValue(gameConfig.milestones.randomizer,"maxClaims",delta,3,5)
local milestonePlate=gameObjectHelpers.getObjectByName("milestonePlate")
local customization={image=milestoneData.images[gameConfig.milestones.randomizer.maxClaims - 2]}
milestonePlate.setCustomObject(customization)
milestonePlate.reload()
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_toggleGuranteeHoverlord(_,_,_)
if not gameConfig.milestones.randomizer.enabled then return end
gameConfig.milestones.randomizer.guranteeHoverlord=not gameConfig.milestones.randomizer.guranteeHoverlord
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_randomizeMilestones(_,_,_)
if not gameConfig.milestones.randomizer.enabled then return end
if gameConfig.milestones.randomizer.numberOfMilestones~=#gameState.milestoneGuids then
milestoneSystem.setupMilestones()
end
milestoneSystem.randomize()
createAllSetupButtons()
end
--- Awards ---
function gameConfigAwardsAndMilestones_swapAwards(_,_,altClick)
local delta=altClick and -1 or 1
tableHelpers.changeNumericValue(gameConfig.awards,"currentSelection",delta,1,4,true)
awardSystem_toggleAwards({nextSet=gameConfig.awards.currentSelection})
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_toggleRandomAwards(_,_,_)
gameConfig.awards.randomizer.enabled=not gameConfig.awards.randomizer.enabled
if gameConfig.awards.randomizer.enabled then
if gameConfig.awards.randomizer.numberOfAwards~=#gameState.awardGuids then
awardSystem.setupAwards()
end
awardSystem.randomize()
else
awardSystem_toggleAwards({nextSet=gameConfig.awards.currentSelection})
end
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_changeNumberOfAwards(_,_,altClick)
if not gameConfig.awards.randomizer.enabled then return end
local delta=altClick and -1 or 1
tableHelpers.changeNumericValue(gameConfig.awards.randomizer,"numberOfAwards",delta,3,10)
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_changeMaxNumberOfAwardsPerCategory(_,_,altClick)
if not gameConfig.awards.randomizer.enabled then return end
local delta=altClick and -1 or 1
tableHelpers.changeNumericValue(gameConfig.awards.randomizer,"maxAwardsPerCategory",delta,1,10)
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_maxFunders(_,_,altClick)
if not gameConfig.awards.randomizer.enabled then return end
local delta=altClick and -1 or 1
tableHelpers.changeNumericValue(gameConfig.awards.randomizer,"maxFunders",delta,3,5)
local awardPlate=gameObjectHelpers.getObjectByName("awardPlate")
local customization={image=awardData.images[gameConfig.awards.randomizer.maxFunders - 2]}
awardPlate.setCustomObject(customization)
awardPlate.reload()
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_toggleGuranteeVenuphile(_,_,_)
if not gameConfig.awards.randomizer.enabled then return end
gameConfig.awards.randomizer.guranteeVenuphile=not gameConfig.awards.randomizer.guranteeVenuphile
createAllSetupButtons()
end
function gameConfigAwardsAndMilestones_randomizeAwards(_,_,_)
if not gameConfig.awards.randomizer.enabled then return end
if gameConfig.awards.randomizer.numberOfAwards~=#gameState.awardGuids then
awardSystem.setupAwards()
end
awardSystem.randomize()
createAllSetupButtons()
end
--- Generic ---
function gameConfigAwardsAndMilestones_randomize(_,_,_)
if not gameConfig.awards.randomizer.enabled or not gameConfig.milestones.randomizer.enabled then return end
if gameConfig.milestones.randomizer.enabled then
if gameConfig.milestones.randomizer.numberOfMilestones~=#gameState.milestoneGuids then
milestoneSystem.setupMilestones()
end
milestoneSystem.randomize()
end
if gameConfig.awards.randomizer.enabled then
if gameConfig.awards.randomizer.numberOfAwards~=#gameState.awardGuids then
awardSystem.setupAwards()
end
awardSystem.randomize()
end
createAllSetupButtons()
end


gameConfigDraftingFunctions={}
function gameConfigDraftingFunctions_ToggleCustomDraftingRules(_,_,altClick)
gameConfig.drafting.custom.active=not gameConfig.drafting.custom.active
if gameConfig.drafting.custom.active then
gameConfigDraftingFunctions.updateCustomSettingsFromPreset(gameState.drafting.currentDraftingRule.draftingSteps)
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_ExportSettings(_,_,_)
setNotes(JSON.encode(gameConfig.drafting))
end
function gameConfigDraftingFunctions_ImportSettings(_,_,_)
local settingsString=getNotes()
if string.match(settingsString,"{\"custom")~=nil and string.match(settingsString,"mapGeneratorConfig")==nil then
local importedDraftingSettings=JSON.decode(getNotes())
gameConfig.drafting=importedDraftingSettings
setNotes("")
createAllSetupButtons()
else
logging.printToAll("Unable to import draft settings. Invalid format/settings.")
end
end
function gameConfigDraftingFunctions_ChangePreset(_,_,altClick)
local delta=altClick and -1 or 1
gameConfig.drafting.initialDraftingSelection=gameConfig.drafting.initialDraftingSelection + delta
if gameConfig.drafting.initialDraftingSelection > tableHelpers.getCount(draftingData.initialResearchPhase) then
gameConfig.drafting.initialDraftingSelection=1
elseif gameConfig.drafting.initialDraftingSelection < 1 then
gameConfig.drafting.initialDraftingSelection=tableHelpers.getCount(draftingData.initialResearchPhase)
end
local counter=1
for ruleName,ruleDefinition in pairs(draftingData.initialResearchPhase) do
if counter==gameConfig.drafting.initialDraftingSelection then
gameConfig.drafting.presetDraftingRule=ruleDefinition
gameState.drafting.currentDraftingRule=ruleDefinition
if gameConfig.drafting.custom.active then
gameConfigDraftingFunctions.updateCustomSettingsFromPreset(ruleDefinition.draftingSteps)
end
break
end
counter=counter + 1
end
createAllSetupButtons()
end
gameConfigDraftingFunctions.updateCustomSettingsFromPreset=function(stepsInput)
gameConfig.drafting.custom.selectedStep=1
gameConfig.drafting.custom.selectedSubStep=1
gameConfig.drafting.custom.steps=tableHelpers.deepClone(stepsInput)
for _,step in pairs(gameConfig.drafting.custom.steps) do
if step.directionOverride==nil then step.directionOverride=1 end
if step.cardsToDeal.corps==nil then step.cardsToDeal.corps={amount=0,targetHandIndex=1}  end
if step.cardsToDeal.preludes==nil then step.cardsToDeal.preludes={amount=0,targetHandIndex=1} end
if step.cardsToDeal.projects==nil then step.cardsToDeal.projects={amount=0,targetHandIndex=1} end
for _,subStep in pairs(step.subSteps) do
if subStep.projects==nil then subStep.projects=0 end
if subStep.preludes==nil then subStep.preludes=0 end
if subStep.corps==nil then subStep.corps=0 end
end
end
end
function gameConfigDraftingFunctions_StepsPageLeft(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local newSelectedStep=gameConfig.drafting.custom.selectedStep - 1
if newSelectedStep < 1 then
return
end
gameConfig.drafting.custom.selectedStep=newSelectedStep
createAllSetupButtons()
end
function gameConfigDraftingFunctions_StepsPageRight(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local newSelectedStep=gameConfig.drafting.custom.selectedStep + 1
if newSelectedStep > #gameConfig.drafting.custom.steps then
return
end
gameConfig.drafting.custom.selectedStep=newSelectedStep
createAllSetupButtons()
end
function gameConfigDraftingFunctions_StepsAddRemove(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
if altClick then
if #gameConfig.drafting.custom.steps < 2 then
return
end
table.remove(gameConfig.drafting.custom.steps,#gameConfig.drafting.custom.steps)
else
table.insert(gameConfig.drafting.custom.steps,{
cardsToDeal={
corps={amount=0,targetHandIndex=1},
preludes={amount=0,targetHandIndex=1},
projects={amount=0,targetHandIndex=1},},
subSteps={{projects=0,corps=0,preludes=0}},
directionOverride=1
})
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_ChangeDrawProjectsAmount(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local delta=altClick and -1 or 1
local newValue=gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.projects.amount + delta
if newValue < 0 then
return
else
gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.projects.amount=newValue
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_ChangeDrawPreludesAmount(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local delta=altClick and -1 or 1
local newValue=gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.preludes.amount + delta
if newValue < 0 then
return
else
gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.preludes.amount=newValue
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_ChangeDrawCorpsAmount(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local delta=altClick and -1 or 1
local newValue=gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.corps.amount + delta
if newValue < 0 then
return
else
gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.corps.amount=newValue
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_ChangeDrawProjectsTargetHandIndex(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local delta=altClick and -1 or 1
local newValue=gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.projects.targetHandIndex + delta
if newValue < 0 then
return
elseif newValue > 8 then
gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.projects.targetHandIndex=8
else
gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.projects.targetHandIndex=newValue
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_ChangeDrawPreludesTargetHandIndex(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local delta=altClick and -1 or 1
local newValue=gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.preludes.targetHandIndex + delta
if newValue < 0 then
return
elseif newValue > 8 then
gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.preludes.targetHandIndex=8
else
gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.preludes.targetHandIndex=newValue
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_ChangeDrawCorpsTargetHandIndex(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local delta=altClick and -1 or 1
local newValue=gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.corps.targetHandIndex + delta
if newValue < 0 then
return
elseif newValue > 8 then
gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.corps.targetHandIndex=8
else
gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].cardsToDeal.corps.targetHandIndex=newValue
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_SubStepPageLeft(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local newSelectedStep=gameConfig.drafting.custom.selectedSubStep - 1
if newSelectedStep < 1 then
return
end
gameConfig.drafting.custom.selectedSubStep=newSelectedStep
createAllSetupButtons()
end
function gameConfigDraftingFunctions_SubStepPageRight(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local newSelectedStep=gameConfig.drafting.custom.selectedSubStep + 1
if newSelectedStep > #gameConfig.drafting.custom.steps[gameConfig.drafting.custom.selectedStep].subSteps then
return
end
gameConfig.drafting.custom.selectedSubStep=newSelectedStep
createAllSetupButtons()
end
function gameConfigDraftingFunctions_SubStepAddRemove(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local currentStep=gameConfig.drafting.custom.selectedStep
if altClick then
if #gameConfig.drafting.custom.steps[currentStep].subSteps < 2 then
return
end
table.remove(gameConfig.drafting.custom.steps[currentStep].subSteps,#gameConfig.drafting.custom.steps[currentStep].subSteps)
else
table.insert(gameConfig.drafting.custom.steps[currentStep].subSteps,{projects=0,corps=0,preludes=0})
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_ChangeSubStepHandOverProjects(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local delta=altClick and -1 or 1
local currentStep=gameConfig.drafting.custom.selectedStep
local currentSubStep=gameConfig.drafting.custom.selectedSubStep
local newValue=gameConfig.drafting.custom.steps[currentStep].subSteps[currentSubStep].projects + delta
if newValue < 0 then
return
else
gameConfig.drafting.custom.steps[currentStep].subSteps[currentSubStep].projects=newValue
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_ChangeSubStepHandOverPreludes(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local delta=altClick and -1 or 1
local currentStep=gameConfig.drafting.custom.selectedStep
local currentSubStep=gameConfig.drafting.custom.selectedSubStep
local newValue=gameConfig.drafting.custom.steps[currentStep].subSteps[currentSubStep].preludes + delta
if newValue < 0 then
return
else
gameConfig.drafting.custom.steps[currentStep].subSteps[currentSubStep].preludes=newValue
end
createAllSetupButtons()
end
function gameConfigDraftingFunctions_ChangeSubStepHandOverCorps(_,_,altClick)
if not gameConfig.drafting.custom.active then return end
local delta=altClick and -1 or 1
local currentStep=gameConfig.drafting.custom.selectedStep
local currentSubStep=gameConfig.drafting.custom.selectedSubStep
local newValue=gameConfig.drafting.custom.steps[currentStep].subSteps[currentSubStep].corps + delta
if newValue < 0 then
return
else
gameConfig.drafting.custom.steps[currentStep].subSteps[currentSubStep].corps=newValue
end
createAllSetupButtons()
end

disableMarker=false
gameConfig={}
gameConfig.version=1
gameConfig.mapSizeSelection=3
gameConfig.setup={
solarPhase=true,
classicBoard=false,
prelude=false,
colonies=false,
venus=false,
turmoil=false,
bggCorps=false,
corpEra=true,
drafting=true,
extendedScripting=true,
randomizer=false,
xenosCorps=false,
fanMadeProjects=false,
pathfinders=false,
bigBox=false,
timer=false,
highOrbit=false,
venusPhaseTwo=false,
ares=false,
showFanMadeMaps=false,
corpsToDraw=2,
randomMap=false,
mapPredefinedSettings=1,
venusWin=false,
}
gameConfig.drafting={}
gameConfig.drafting.initialDraftingSelection=1
gameConfig.drafting.presetDraftingRule=draftingData.initialResearchPhase.freeDraft
gameConfig.drafting.custom={
active=false,
selectedStep=1,
selectedSubStep=1,
considerForPayment=10,
steps=
{
{
cardsToDeal=
{
corps={amount=2,targetHandIndex=1},
preludes={amount=4,targetHandIndex=3},
projects={amount=10,targetHandIndex=2},
},
subSteps={{projects=8,corps=0,preludes=0},
{projects=6,corps=0,preludes=0},
{projects=4,corps=0,preludes=0},
{projects=2,corps=0,preludes=0}
},
directionOverride=1
}
}
}
gameConfig.mapGeneratorConfig={}
gameConfig.mapGeneratorConfig.mapSizeSelection=3
gameConfig.mapGeneratorConfig.deltaFactor=0.1
gameConfig.mapGeneratorConfig.bonusTilesRatio=8/10
gameConfig.mapGeneratorConfig.totallyRandomTilesRatio=0.1
gameConfig.mapGeneratorConfig.tileEffects={
Plants={weighting=10,averageTileYield=1.8,yieldDiffusion=0.25,maxYield=3,seedPoints=3,shapeFactor=2,seedDistance=4},
Titanium={weighting=2,averageTileYield=1,yieldDiffusion=0.4,maxYield=2,seedPoints=5,shapeFactor=0.6,seedDistance=4},
Steel={weighting=5,averageTileYield=1.7,yieldDiffusion=0.25,maxYield=3,seedPoints=5,shapeFactor=0.8,seedDistance=4},
DrawCard={weighting=3,averageTileYield=1.45,yieldDiffusion=0.25,maxYield=3,seedPoints=200,shapeFactor=0.2,seedDistance=4},
Heat={weighting=0,averageTileYield=2,yieldDiffusion=0.5,maxYield=4,seedPoints=3,shapeFactor=2,seedDistance=4},
Energy={weighting=0,averageTileYield=1.5,yieldDiffusion=0.25,maxYield=4,seedPoints=2,shapeFactor=2,seedDistance=4},
Credits={weighting=0,averageTileYield=5,yieldDiffusion=0.5,maxYield=6,seedPoints=5,shapeFactor=0.2,seedDistance=1},
OtherEffects={weighting=0,averageTileYield=0.0,yieldDiffusion=0.0,maxYield=0,seedPoints=200,shapeFactor=0.2,seedDistance=1}
}
gameConfig.mapGeneratorConfig.oceanSettings={
oceanSeedPoints=4,
oceanSeedMinDistance=4,
oceanShapeFactor=1,-- values >= 1 --> bulky cluster,values < 1 --> snakey ocean lines
}
gameConfig.mapGeneratorConfig.absoluteTiles={
volcanoTiles=3,
blockedTiles=0,-- blocked tiles give adjancency bonuses (e.g. draw 1 card,gain 1 plant,etc)
initialErosions=0,
initialDuststorms=3,
}
gameConfig.milestones={}
gameConfig.milestones.currentSelection=1
gameConfig.milestones.randomizer={}
gameConfig.milestones.randomizer.enabled=false
gameConfig.milestones.randomizer.numberOfMilestones=5
gameConfig.milestones.randomizer.maxMilestonesPerCategory=2
gameConfig.milestones.randomizer.guranteeHoverlord=true
gameConfig.milestones.randomizer.maxClaims=3
gameConfig.awards={}
gameConfig.awards.currentSelection=1
gameConfig.awards.randomizer={}
gameConfig.awards.randomizer.enabled=false
gameConfig.awards.randomizer.numberOfAwards=5
gameConfig.awards.randomizer.maxAwardsPerCategory=2
gameConfig.awards.randomizer.guranteeVenuphile=true
gameConfig.awards.randomizer.maxFunders=3
gameConfig.globalParameters={}
gameConfig.globalParameters.temperature={
selection=1,
bonusSelection=1,
aresSelection=1,
}
gameConfig.globalParameters.oxygen={
selection=1,
bonusSelection=1,
aresSelection=1,
}
gameConfig.globalParameters.ocean={
selection=1,
bonusSelection=1,
aresSelection=1,
}
gameConfig.globalParameters.venus={
selection=1,
bonusSelection=1,
aresSelection=1,-- just a dummy value for symmetry reasons - venus should never have an effect on Mars hazards
}
gameConfig.timerConfiguration={
isPaused=false,
secondsPlusPerGeneration=120,
secondsPlusPerEndTurn=15,
secondsInitial=1200,
secondsPerNegativeVp=10,-- minimum
negativeVpThreshold=0,
delta=1,
pauseOnDraft=false,
timeoutAction="doNothing",
}
gameConfigFunctions={}
gameConfigFunctions.refreshView=function()
if gameState.setupIsDone and gameConfigMatViews.currentView < 3 then
gameConfigMatViews.currentView=3
updateGameConfigSettingsView()
end
end
function changeView(newView)
local gameConfigMat=gameObjectHelpers.getObjectByName("gameConfigTile")
if gameConfigMat.getButtons()~=nil then
for i=#gameConfigMat.getButtons()-1,0,-1 do
gameConfigMat.removeButton(i)
end
end
local buttons=tableHelpers.combineSingleValueTables({gameConfigMatViews.mainButtons,newView.buttons})
createSetupButtonsInternal(gameConfigMat,buttons)
end
function createAllSetupButtons()
local gameConfigMat=gameObjectHelpers.getObjectByName("gameConfigTile")
local currentView=gameConfigMatViews.views[gameConfigMatViews.currentView]
local buttons=tableHelpers.combineSingleValueTables({gameConfigMatViews.mainButtons,currentView.buttons})
createSetupButtonsInternal(gameConfigMat,buttons)
end
function createSetupButtonsInternal(parentObject,buttons)
local createFromScratch=parentObject.getButtons()==nil
local buttonAmount=0
for i=1,#buttons do
buttonFunctions.adaptButtonColor(buttons[i])
buttonFunctions.adaptButtonLabel(buttons[i])
buttonFunctions.adaptButtonTooltip(buttons[i])
buttons[i].index=buttonAmount
if transientState.finishSetupButtonDisabled and buttons[i].buttonType=="finishSetupButton" then
buttons[i].color={50/255,50/255,50/255,0.95}
end
if gameState.setupIsDone and buttons[i].buttonType=="startGameButton" then
buttons[i].color={255/255,115/255,0,0.95}
end
if createFromScratch then
parentObject.createButton(buttons[i])
else
parentObject.editButton(buttons[i])
end
buttonAmount=buttonAmount + 1
end
end
function printConfig(_,playerColor,_)
Global.call("gameConfigFunctions_publishConfig")
end
function loadConfig(_,playerColor,_)
local notes=getNotes()
if string.find(notes,"{") and string.find(notes,"}") then
Global.call("gameConfigFunctions_loadConfig")
else
broadcastToAll("No game config to load.")
end
end
function clearNotes(_,playerColor,_)
setNotes("")
end
function toggleGameConfigSettings(_,_,altClick)
local delta=1
if altClick then
delta=-1
end
gameConfigMatViews.currentView=gameConfigMatViews.currentView + delta
updateGameConfigSettingsView()
end
function updateGameConfigSettingsView()
if gameState.setupIsDone then
if gameConfigMatViews.currentView > #gameConfigMatViews.views then
gameConfigMatViews.currentView=3
elseif gameConfigMatViews.currentView < 3 then
gameConfigMatViews.currentView=#gameConfigMatViews.views
end
else
if gameConfigMatViews.currentView > #gameConfigMatViews.views then
gameConfigMatViews.currentView=1
elseif gameConfigMatViews.currentView < 1 then
gameConfigMatViews.currentView=#gameConfigMatViews.views
end
end
local gameConfigMat=gameObjectHelpers.getObjectByName("gameConfigTile")
local customization={}
customization.image=gameConfigMatViews.views[gameConfigMatViews.currentView].imageUrl
gameConfigMat.setCustomObject(customization)
local reloadedTile=gameConfigMat.reload()
for _,buttonInfo in pairs(gameConfigMatViews.mainButtons) do
if buttonInfo.buttonType=="toggleGameConfigSettings" then
buttonInfo.label=gameConfigMatViews.views[gameConfigMatViews.currentView].toggleLabel
end
end
Wait.frames(|| changeView(gameConfigMatViews.views[gameConfigMatViews.currentView]),1)
end


function AddBigBox()
gameObjectHelpers.addDecks("projectDeck","bigBoxProjects")
gameObjectHelpers.addDecks("corpDeck","bigBoxCorps")
end
function AddPathfinders()
local bag=gameObjectHelpers.getObjectByName("pathFinderBag")
local targetTransform=tablePositions.pathfinder.pathfinderBoard
local board=bag.takeObject({position=targetTransform.pos,rotation=targetTransform.rot})
board.lock()
Wait.time(function()
Wait.condition(function()
bag.takeObject({position=vectorHelpers.fromLocalToWorld(board,tablePositions.pathfinder.pathfinderPlanetTracks.venus[1])})
bag.takeObject({position=vectorHelpers.fromLocalToWorld(board,tablePositions.pathfinder.pathfinderPlanetTracks.earth[1])})
bag.takeObject({position=vectorHelpers.fromLocalToWorld(board,tablePositions.pathfinder.pathfinderPlanetTracks.mars[1])})
bag.takeObject({position=vectorHelpers.fromLocalToWorld(board,tablePositions.pathfinder.pathfinderPlanetTracks.jovian[1])})
end,function() return board.resting end)
end,1)
gameObjectHelpers.addDecks("projectDeck","pathFinderProjects")
gameObjectHelpers.addDecks("corpDeck","pathFinderCorps")
gameObjectHelpers.addDecks("preludeDeck","pathFinderPreludes")
Wait.frames(function()
gameObjectHelpers.cleanOutDeck("projectDeck",expansionCrossoverCards.pathfinderProjects.venus,gameConfig.setup.venus)
gameObjectHelpers.cleanOutDeck("projectDeck",expansionCrossoverCards.pathfinderProjects.colonies,gameConfig.setup.colonies)
gameObjectHelpers.cleanOutDeck("projectDeck",expansionCrossoverCards.pathfinderProjects.turmoil,gameConfig.setup.turmoil)
gameObjectHelpers.cleanOutDeck("preludeDeck",expansionCrossoverCards.pathfinderPreludes.venus,gameConfig.setup.venus)
gameObjectHelpers.cleanOutDeck("preludeDeck",expansionCrossoverCards.pathfinderPreludes.colonies,gameConfig.setup.colonies)
gameObjectHelpers.cleanOutDeck("corpDeck",expansionCrossoverCards.pathfinderCorps.venus,gameConfig.setup.venus)
end,20)
Wait.time(function() board.call("activatePathfinderMatFeatures") end,2)
end
function AddAres()
gameState.ares=true
gameObjectHelpers.addDecks("projectDeck","aresDeck")
gameObjectHelpers.cleanOutDeck("projectDeck",expansionCrossoverCards.ares.projects.baseGameReplacements,false)
positionAsset("duststormBag",tablePositions.ares.duststormBag)
positionAsset("erosionBag",tablePositions.ares.erosionBag)
end
function AddHighOrbit()
local highOrbitDeck=gameObjectHelpers.getObjectByName("highOrbitInfrastructureDeck")
local baseLocation={54.50,1.03,-21.25}
local nextFreePosition=tableHelpers.deepClone(baseLocation)
local locationMap={}
local locationMapLength=0
for i,card in pairs(highOrbitDeck.getObjects()) do
local continue=false
for name,position in pairs(locationMap) do
if name==card.name then
continue=true
end
end
if not continue then
locationMap[card.name]=tableHelpers.deepClone(nextFreePosition)
nextFreePosition=vectorHelpers.addVectors(nextFreePosition,{0,0,5})
locationMapLength=locationMapLength + 1
end
if locationMapLength%9==0 then
local factor=math.floor(locationMapLength/9)
nextFreePosition=vectorHelpers.addVectors(baseLocation,{-7*factor,0,0})
end
end
for i=1,#highOrbitDeck.getObjects() - 1 do
local card=highOrbitDeck.takeObject()
card.setPosition(locationMap[card.getName()])
card.setRotation({0,270,0})
end
Wait.frames( function()
local obj=getObjectFromGUID("f2855f")
if obj~=nil then
obj.setRotation({0,270,0})
obj.setPosition(locationMap[obj.getName()])
end
end
,12)
end
function AddXenos()
gameObjectHelpers.addDecks("corpDeck","xenosCorps")
end
function AddFanMadeProjects()
gameObjectHelpers.addDecks("projectDeck","fanMadeProjects")
end
function AddVenus()
gameState.venus=true
if gameState.solarPhase~=false then
logging.printToAll("Solar Phase enabled with Venus. Click on Button to disable again",{1,1,1},loggingModes.exception)
gameState.solarPhase=true
else
logging.printToAll("Solar phase was already disabled. Not enabling.",{1,1,1},loggingModes.exception)
end
AddVenusAssets()
local customization={}
if gameConfig.setup.venusPhaseTwo then
AddVenusPhaseTwoAssets()
venusMap=hexMapHelpers.makeMapComputeFriendly(predefinedVenusMaps.venusPhaseTwo)
customization.image=predefinedVenusMaps.venusPhaseTwo.metadata.imageUrl
else
venusMap=hexMapHelpers.makeMapComputeFriendly(predefinedVenusMaps.baseMap)
customization.image=predefinedVenusMaps.baseMap.metadata.imageUrl
end
local venusMapTile=gameObjectHelpers.getObjectByName("venusMapTile")
venusMapTile.setCustomObject(customization)
venusMapTile.reload()
Wait.frames(|| positionAsset("venusMapTile",tablePositions.venus.venusMapTile),10)
venusMap.metadata.wasUpdated=true
end
function AddVenusAssets()
gameObjectHelpers.addDecks("projectDeck","venusProjects")
gameObjectHelpers.addDecks("corpDeck","venusCorps")
if not gameConfig.awards.randomizer.enabled then
awardSystem.spawnAwardTile(awardData.infos.Venuphile)
end
if not gameConfig.milestones.randomizer.enabled then
milestoneSystem.spawnMilestoneTile(milestoneData.infos.Hoverlord)
end
positionAsset("venusTerraformingTrack",tablePositions.venus.venusTrack)
positionAsset("venusTerraformingMarker",tablePositions.venus.venusMarker)
end
function positionAsset(assetName,targetTransform)
local asset=gameObjectHelpers.getObjectByName(assetName)
asset.setPositionSmooth(targetTransform.pos)
asset.setRotation(targetTransform.rot)
end
function AddPrelude()
gameState.prelude=true
gameObjectHelpers.addDecks("projectDeck","preludeProjects")
gameObjectHelpers.addDecks("corpDeck","preludeCorps")
end
function AddColonies()
gameState.colonies=true
--add the cards
gameObjectHelpers.addDecks("projectDeck","coloniesProjects")
gameObjectHelpers.addDecks("corpDeck","coloniesCorps")
end
function AddTurmoil()
gameState.turmoil=true
gameState.solarPhase=true
milestoneSystem.turmoilSpecialHandling()
gameObjectHelpers.addDecks("projectDeck","turmoilProjects")
gameObjectHelpers.addDecks("corpDeck","turmoilCorps")
end
function AddBGGCorps()
gameObjectHelpers.addDecks("corpDeck","bggCorps")
end
function AddCorpEra()
gameObjectHelpers.addDecks("projectDeck","corpEraProjects")
gameObjectHelpers.addDecks("corpDeck","corpEraCorps")
end
function SpawnTableaus()
for index,player in pairs(gameState.allPlayers) do
if player.playerArea.activationTableau==nil or getObjectFromGUID(player.playerArea.activationTableau)==nil then
player.playerArea.activationTableau=nil
createActivationTableau(player)
end
objectActivationSystem_enableAllActivationRules({playerColor=player.color})
if player.playerArea.iconTableaus==nil or next(player.playerArea.iconTableaus)==nil then
createIconTableaus(player)
end
end
end
function AddVenusPhaseTwoAssets()
gameObjectHelpers.addDecks("projectDeck","venusPhaseTwoDeck")
adaptGlobalParametersFromMapMetadata(predefinedVenusMaps.venusPhaseTwo.metadata)
positionAsset("floatingArrayBag",tablePositions.venusPhaseTwo.floatingArrayBag)
positionAsset("gasMineBag",tablePositions.venusPhaseTwo.gasMineBag)
positionAsset("venusHabitatBag",tablePositions.venusPhaseTwo.venusHabitatBag)
end
function spawnCardResourceCounters()
local guidsOfObjectsToSpawn={
setupGuids.animalWildSource,
setupGuids.microbeFloaterSource,
setupGuids.scienceFighterSource,
setupGuids.dataAsteroidSource,
setupGuids.actionMarkersSource,
}
for location,posAndRot in pairs(tablePositions.gameBoardAssets.cardResourceTokensPositions) do
for i,guid in ipairs(guidsOfObjectsToSpawn) do
local rotatedSpacing=vectorHelpers.rotateVectorY(tablePositions.gameBoardAssets.cardResourceTokensSpacing,posAndRot.r[2])
local pos=vectorHelpers.addVectors(posAndRot.p,vectorHelpers.multiplyVectorWithScalar(rotatedSpacing,(i-1)))
createClonableObject(guid,pos,posAndRot.r)
end
end
end
--Finish Setup
function FinishSetup()
if gameState.setupIsDone then
return
end
transientState.finishSetupButtonDisabled=true
createAllSetupButtons()
function finishCoroutine()
gameState.activeExpansions=tableHelpers.deepClone(gameConfig.setup)
updatePlayerSettings()
if gameConfigMatViews.currentView < 3 then
gameConfigMatViews.currentView=3
for i=1,5 do coroutine.yield(0) end
updateGameConfigSettingsView()
end
gameState.extendedScriptingEnabled=gameConfig.setup.extendedScripting
if gameConfig.setup.venus then
if gameConfig.setup.venusWin then
gameState.venusIsWin=true
end
AddVenus()
end
if gameConfig.setup.colonies then
AddColonies()
end
if gameConfig.setup.prelude then
AddPrelude()
end
if gameConfig.setup.timer then
AddTimerAssets()
end
if gameConfig.setup.bggCorps then
AddBGGCorps()
end
if gameConfig.setup.corpEra then
AddCorpEra()
end
if gameConfig.setup.turmoil then
AddTurmoil()
end
if gameConfig.setup.xenosCorps then
AddXenos()
end
if gameConfig.setup.fanMadeProjects then
AddFanMadeProjects()
end
if gameConfig.setup.pathfinders then
AddPathfinders()
end
if gameConfig.setup.ares then
AddAres()
end
if gameConfig.setup.highOrbit then
AddHighOrbit()
end
if gameConfig.setup.drafting then
EnableDraft()
end
if gameState.extendedScriptingEnabled then
SpawnTableaus()
end
if gameConfig.setup.bigBox then
AddBigBox()
end
if not gameConfig.setup.solarPhase then
DisableSolarPhase()
end
for i=1,30 do
coroutine.yield(0)
end
if gameState.turmoil then
local turmoilDeck=gameObjectHelpers.getObjectByName("turmoilDeck")
if gameState.venus then
gameObjectHelpers.addDecks("turmoilDeck","turmoilVenusCards")
end
if gameState.colonies then
gameObjectHelpers.addDecks("turmoilDeck","turmoilColonyCards")
end
if gameState.colonies and gameState.venus then
gameObjectHelpers.addDecks("turmoilDeck","turmoilColonyVenusCards")
end
turmoilDeck.shuffle()
end
gameState.corporationsToDeal=gameConfig.setup.corpsToDraw
broadcastToAll("Make Mars Green Again!",{0,2,0})
broadcastToAll("Click Research to Begin",{1,1,0})
if gameConfig.setup.randomizer then
broadcastToAll("Use a randomizer to generate a map",{1,1,0})
CreateRandomizerButton()
initializeRandomizerAwardsAndMilestones()
end
loadExpansionBoardgameTile()
for _,player in pairs(gameState.allPlayers) do
if player.playerArea.iconTableaus[1]~=nil and getObjectFromGUID(player.playerArea.iconTableaus[1])~=nil then
toggleIconTableaus(player.color)
Wait.condition(|| toggleIconTableaus(player.color),function() return getObjectFromGUID(player.playerArea.iconTableaus[1])==nil end)
end
end
setupMapButtons()
setupStandardProjectMat()
ensureBagOceans()
spawnCardResourceCounters()
local counter=180
while counter > 0 do
counter=counter - 1
if cloningOngoing then counter=180 end
if dealingInProgress then counter=180 end
for _,ongoing in pairs(cloningOngoingTable) do
if ongoing then
counter=180
end
end
coroutine.yield(0)
end
gameState.setupIsDone=true
createAllSetupButtons()
gameState.wasUpdated=true
return 1
end
startLuaCoroutine(self,"finishCoroutine")
end
function AddTimerAssets()
timerFunctions.setupTimer()
end
function updatePlayerSettings()
for _,player in pairs(gameState.allPlayers) do
local discountTags=tableHelpers.combineSingleValueTables({icons.baseIconNames,icons.specialIconNames,icons.anyTagNames})
local tags=tableHelpers.combineSingleValueTables({icons.baseIconNames,icons.specialIconNames})
if gameConfig.setup.pathfinders then
discountTags=tableHelpers.combineSingleValueTables({discountTags,icons.pathfinder})
tags=tableHelpers.combineSingleValueTables({discountTags,icons.pathfinder})
end
if gameConfig.setup.highOrbit then
discountTags=tableHelpers.combineSingleValueTables({discountTags,icons.highOrbit})
tags=tableHelpers.combineSingleValueTables({discountTags,icons.highOrbit})
end
player.paymentSystemConfig=paymentSystemConfig:new(discountTags)
player.tagSystem=tagSystem:new(tags)
end
end
function setupStandardProjectMat()
local spMat=gameObjectHelpers.getObjectByName("standardProjectTile")
local spButtonInfos=standardProjectTileData.default.buttons
local customization={image=standardProjectTileData.default.imageUrl}
if gameConfig.setup.venusPhaseTwo then
spButtonInfos=standardProjectTileData.venusPhaseTwo.buttons
customization={image=standardProjectTileData.venusPhaseTwo.imageUrl}
elseif gameConfig.setup.venus and gameConfig.setup.colonies then
spButtonInfos=standardProjectTileData.venusAndColonies.buttons
customization={image=standardProjectTileData.venusAndColonies.imageUrl}
elseif gameConfig.setup.colonies then
spButtonInfos=standardProjectTileData.colonies.buttons
customization={image=standardProjectTileData.colonies.imageUrl}
elseif gameConfig.setup.venus then
spButtonInfos=standardProjectTileData.venus.buttons
customization={image=standardProjectTileData.venus.imageUrl}
end
spMat.setCustomObject(customization)
Wait.frames(|| Wait.condition(function()
local reloadedTile=spMat.reload()
for i,buttonInfo in pairs(spButtonInfos) do
reloadedTile.createButton({
click_function=buttonInfo.click_function,
tooltip=buttonInfo.tooltip,
function_owner=self,
position={0.00,0.11,0.87 -(i-1) * 0.3435 * (5/(#spButtonInfos-1))},
rotation={0,0,0},
width=1100,
height=400,
scale={0.5,0.1,0.15},
color={1,0.25,0.25,0.2}
})
end
end,function() return spMat.resting end),20)
end
function setupMapButtons()
local mainBoardTile=gameObjectHelpers.getObjectByName("mainBoardTile")
for _,buttonInfo in pairs(playMatButtons.mainMat) do
mainBoardTile.createButton(buttonInfo)
end
end
function setupBoard()
colonySetup.initializeButtons()
end
creatingOceans=false
function ensureBagOceans()
gameState.oceansNeeded=#globalParameters.ocean.mappings[globalParameterSystem.values.ocean.selection].steps-1
local oceansToCreate=gameState.oceansNeeded
local oceansKnown=#gameState.oceanTileGuids
log("Need to create oceans")
log(oceansToCreate)
log("Know about oceans")
log(oceansKnown)
function ensureCoroutine()
while creatingOceans do
coroutine.yield(0)
end
creatingOceans=true
local oceansKnown=#gameState.oceanTileGuids
oceansToCreate=oceansToCreate - oceansKnown
for i=1,oceansToCreate do
cloneOceanCoroutine()
end
creatingOceans=false
return 1
end
startLuaCoroutine(self,"ensureCoroutine")
end
function cloneOceanCoroutine()
local genericOceanTile=gameObjectHelpers.getObjectByName("genericOcean")
local copiedTile=genericOceanTile.clone()
coroutine.yield(0)
while copiedTile.getGUID()==genericOceanTile.getGUID() do
coroutine.yield(0)
end
copiedTile.setLock(false)
gameObjectHelpers.recordOcean(copiedTile.getGUID())
local oceanBag=gameObjectHelpers.getObjectByName("oceanBag")
local position=oceanBag.getPosition()
position[2]=position[2] + math.random()
copiedTile.setPositionSmooth(position,false,false)
bagProtector.addToAllowList(oceanBag.getGUID(),copiedTile.getGUID())
coroutine.yield(0)
return 1
end
function ToggleGlobalParameters()
local tempToken=getObjectFromGUID(globalParameters.temperature.objectGuid)
gameState.globalParameterSelection=gameState.globalParameterSelection + 1
if gameState.globalParameterSelection > #globalParameters.temperature.mappings then
gameState.globalParameterSelection=1
end
local customization={}
customization.image=globalParameters.temperature.mappings[gameState.globalParameterSelection].imageUrl
tempToken.setCustomObject(customization)
tempToken.reload()
end
function gameSetup_research()
initialResearch()
end
function rollFirstPlayer(numberOfPlayers,numberOfRolls)
local randomTable={}
local maxValue=0
local firstPlayerIndex=-1
local i=0
local tie=false
while i < numberOfRolls or tie==true do
local playerIndex=math.random(1,numberOfPlayers)
if randomTable[playerIndex]==nil then
randomTable[playerIndex]=1
else
randomTable[playerIndex]=randomTable[playerIndex] + 1
end
if maxValue==randomTable[playerIndex] then
tie=true
elseif maxValue < randomTable[playerIndex] then
firstPlayerIndex=playerIndex
maxValue=randomTable[playerIndex]
tie=false
end
i=i + 1
end
log("Rolled "..i.." times first player with the following distribution (not ordered):")
log(randomTable)
return firstPlayerIndex
end
function initialResearch()
if not gameState.setupIsDone then
return
end
gameState.firstPlayer=rollFirstPlayer(gameState.numberOfPlayers,100)
if gameConfig.setup.timer then
timerFunctions.initializeTimer(gameConfig.timerConfiguration)
end
gameObjectHelpers.getObjectByName("gameConfigTile").destruct()
gameState.started=true
updatePlayerSettings()
ensureBagOceans()
globalParameterSystem.bonusSetup()
globalParameterSystem.setupButtons()
local projectDeck=tryToFindProjectStack()
local preludeDeck=gameObjectHelpers.getObjectByName("preludeDeck")
local corpDeck=gameObjectHelpers.getObjectByName("corpDeck")
log("Setting first player token")
passFirstPlayer()
log("Shuffling decks")
projectDeck.shuffle()
preludeDeck.shuffle()
if gameState.corporationsToDeal==0 then
broadcastToAll("Not shuffling corps because we are not dealing any")
else
corpDeck.shuffle()
end
if not gameConfig.setup.corpEra then
for _,player in pairs(gameState.allPlayers) do
local playerStartProduction={productionValues={Credits=1,Steel=1,Titanium=1,Plants=1,Energy=1,Heat=1},
resourceValues={},effects={}}
Wait.time(|| objectActivationSystem.doAction(player,nil,"non corp era setup",playerStartProduction),4)
end
end
if gameState.colonies then
colonySetup.setup()
if gameState.numberOfPlayers==1 then
getObjectFromGUID(gameState.allPlayers[1].playerArea.playerMat).call("changeProduction",{
key="credits",
amount=-2,
})
end
end
if gameState.turmoil then
turmoilSetup()
end
Wait.frames(function()
dealStartingCards(projectDeck,preludeDeck,corpDeck)
if gameState.numberOfPlayers==1 then
soloPlaySetup(projectDeck)
end
end,3)
gameState.currentPhase=phases.gameStartPhase
log("Updating player UI")
updatePlayerUI()
gameObjectHelpers.getObjectByName("milestonePlate").call("setupFinished")
gameObjectHelpers.getObjectByName("awardPlate").call("setupFinished")
awardAndMilestoneFunctions.finalizeRandomizer()
local marsMapTile=gameObjectHelpers.getObjectByName("gameMap")
setupMapSnapPoints(gameMap,marsMapTile)
if gameConfig.setup.venus then
local venusMapTile=gameObjectHelpers.getObjectByName("venusMapTile")
setupMapSnapPoints(venusMap,venusMapTile)
end
setupSpaceTileSnapPoints()
if gameConfig.setup.ares then
Wait.time(|| aresFunctions.finishSetup(),0.25)
end
gameState.wasUpdated=true
end
function setupMapSnapPoints(map,mapTile)
local snapPoints=Global.getSnapPoints()
for i,jkMatrix in pairs(map.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
local pos=hexMapHelpers.indicesToWorldCoordinates(map,{i,j,k},mapTile)
local snapPoint={}
snapPoint.position=vectorHelpers.addVectors(pos,{0,-1,0})
snapPoint.rotation={0,270,0}
snapPoint.rotation_snap=true
table.insert(snapPoints,snapPoint)
end
end
end
Global.setSnapPoints(snapPoints)
end
function setupSpaceTileSnapPoints()
for tableName,spaceTileTable in pairs(tablePositions.reservedTiles.spaceTiles) do
local skip=true
if tableName=="baseGame" then
skip=false
elseif tableName=="venus" and gameConfig.setup.venus then
skip=false
elseif tableName=="turmoil" and gameConfig.setup.turmoil then
skip=false
elseif tableName=="pathfinder" and gameConfig.setup.pathfinders then
skip=false
end
if not skip then
local snapPoints=Global.getSnapPoints()
for _,entry in pairs(spaceTileTable) do
local snapPoint={}
snapPoint.position=entry.pos
snapPoint.rotation=entry.rot
snapPoint.rotation_snap=true
table.insert(snapPoints,snapPoint)
end
Global.setSnapPoints(snapPoints)
end
end
end
function dealStartingCards(projectDeck,preludeDeck,corpDeck)
if gameConfig.drafting.custom.active then
researchPhaseFunctions.beginResearchPhase({draftingSteps=gameConfig.drafting.custom.steps})
else
local counter=1
for ruleName,ruleDefinition in pairs(draftingData.initialResearchPhase) do
if counter==gameConfig.drafting.initialDraftingSelection then
researchPhaseFunctions.beginResearchPhase(ruleDefinition)
break
end
counter=counter + 1
end
end
local numberOfCorps=0
local numberOfPreludes=0
for _,step in pairs(gameState.drafting.currentDraftingRule.draftingSteps) do
if step.cardsToDeal.corps~=nil then
numberOfCorps=numberOfCorps + step.cardsToDeal.corps.amount
end
if step.cardsToDeal.preludes~=nil then
numberOfPreludes=numberOfPreludes + step.cardsToDeal.preludes.amount
end
end
if numberOfCorps==0 then
local corpDeck=gameObjectHelpers.getObjectByName("corpDeck")
if #gameState.allPlayers * gameConfig.setup.corpsToDraw > #corpDeck.getObjects() then
gameConfig.setup.corpsToDraw=math.lower(#corpDeck.getObjects() / #gameState.allPlayers)
end
corpDeck.deal(gameConfig.setup.corpsToDraw)
end
if numberOfPreludes==0 and gameState.activeExpansions.prelude then
gameObjectHelpers.getObjectByName("preludeDeck").deal(4)
end
end
function deleteMilestonesAndAwards()
for _,guid in pairs(gameState.milestoneGuids) do
getObjectFromGUID(guid).destruct()
end
for _,guid in pairs(gameState.awardGuids) do
getObjectFromGUID(guid).destruct()
end
gameObjectHelpers.getObjectByName("milestonePlate").destruct()
gameObjectHelpers.getObjectByName("awardPlate").destruct()
end
function soloPlaySetup(projectDeck)
function soloPlaySetupCoroutine()
deleteMilestonesAndAwards()
gameState.isSoloGame=true
gameState.maxGeneration=14
if gameState.prelude then
gameState.maxGeneration=12
end
local neutralPlayerColor="White"
if gameState.allPlayers[1].color==neutralPlayerColor then
neutralPlayerColor="Red"
else
gameState.currentPlayer=2
gameState.firstPlayer=2
end
createPlayerInGame(neutralPlayerColor,true)
local neutralPlayer=nil
local humanPlayer=nil
while neutralPlayer==nil do
for _,player in pairs(gameState.allPlayers) do
if player.neutral then
neutralPlayer=player
neutralPlayer.terraformingRating=gameState.maxGeneration
else
humanPlayer=player
player.terraformingRating=14
end
end
coroutine.yield(0)
end
local neutralPlayerStartResources={productionValues={Credits=5,Steel=5,Titanium=5,Plants=5,Energy=5,Heat=5},
resourceValues={Credits=20,Steel=20,Titanium=20,Plants=20,Energy=20,Heat=20},effects={}}
Wait.time(|| objectActivationSystem.doAction(neutralPlayer,nil,"neutral player setup",neutralPlayerStartResources),4)
updateCubePositionsOnTerraformingBar()
placeAllNeutralPlayerTiles(neutralPlayer)
broadcastToAll("Solo play started. You have until generation "..gameState.maxGeneration.." to terraform everything! Good luck!",{0,1,0})
if gameState.venus then
broadcastToAll("Solo play started. You have to terraform Venus as well!",{0,1,0})
gameState.venusIsWin=true
end
return 1
end
startLuaCoroutine(self,"soloPlaySetupCoroutine")
end
function placeAllNeutralPlayerTiles(neutralPlayer)
logging.broadcastToAll("Sologame setup: Placing neutral cities and greeneries.")
local citySource=gameObjectHelpers.getObjectByName("genericCityBag")
local greenerySource=gameObjectHelpers.getObjectByName("genericGreeneryBag")
gameSetup.sologameSetup.placeNeutralPlayerTile(neutralPlayer,citySource,"City",1,{0,0,0})
gameSetup.sologameSetup.placeNeutralPlayerTile(neutralPlayer,greenerySource,"Greenery",1,{0,0,0})
gameSetup.sologameSetup.placeNeutralPlayerTile(neutralPlayer,citySource,"City",-1,{0,#gameMap.tiles[0],0})
gameSetup.sologameSetup.placeNeutralPlayerTile(neutralPlayer,greenerySource,"Greenery",1,{0,0,0})
end
gameSetup={}
gameSetup.sologameSetup={}
gameSetup.sologameSetup.placeNeutralPlayerTile=function(neutralPlayer,tileSource,tileType,walkDirection,startIndices)
function placeSoloGameTileCoroutine()
if randomizer.isDone~=nil then
while not randomizer.isDone or randomizer.mapGenerationInProgress do
coroutine.yield(0)
end
end
while transientState.spawningTile do
coroutine.yield(0)
end
transientState.spawningTile=true
searchForCard({amountToSearchFor=1,callbackInfo={callbackFuncName="onSoloSetupCardRevealed"}})
while transientState.solo.stepsToWalk==-1 do
coroutine.yield(0)
end
local transform=gameSetup.sologameSetup.getTargetTransform(transientState.solo.stepsToWalk,tileType,walkDirection,startIndices)
local tile=tileSource.takeObject({position=transform.pos,rotation=transform.rot})
local waitFrames=0
while waitFrames < 30 do
if tile.resting then
waitFrames=waitFrames + 1
else
waitFrames=0
end
coroutine.yield(0)
end
tile.call("activateObjectRemotely",{playerColor=neutralPlayer.color})
transientState.solo.stepsToWalk=-1
transientState.spawningTile=false
return 1
end
startLuaCoroutine(self,"placeSoloGameTileCoroutine")
end
gameSetup.sologameSetup.getTargetTransform=function(stepsToWalk,tileType,walkDirection,startIndices)
local targetIndices={0,0,0}
if tileType=="City" then
targetIndices=hexMapHelpers.walkMapHorizontally(
gameMap,
stepsToWalk - 1,
walkDirection,
startIndices,
{mapFeatures.tileType.ocean,mapFeatures.tileType.nocticsCity},
{}
)
transientState.solo.lastNeutralCityIndices=targetIndices
else
targetIndices=hexMapHelpers.walkAroundTile(
gameMap,
stepsToWalk - 1,
transientState.solo.lastNeutralCityIndices,
{mapFeatures.tileType.ocean,mapFeatures.tileType.nocticsCity},
{}
)
end
local marsMapTile=gameObjectHelpers.getObjectByName("gameMap")
return {pos=hexMapHelpers.indicesToWorldCoordinates(gameMap,targetIndices,marsMapTile),rot={0,270,0}}
end
function onSoloSetupCardRevealed(params)
local card=getObjectFromGUID(params.cardGuid)
transientState.solo.stepsToWalk=tonumber(descriptionInterpreter.getValuesFromInput(card.getDescription(),"Cost:")[1])
end


mapGenerator={}
randomizerTilesInPlay={}
randomizer={mapGenerationInProgress=false,isDone=true}
function createMap(_,_,_)
if not gameConfig.setup.randomMap then
return
end
mapGenerator.createMap()
end
mapGenerator.createMap=function()
if randomizer.mapGenerationInProgress then
return
end
randomizer.mapGenerationInProgress=true
local counter=1
for name,template in pairs(randomizerTemplates) do
if counter==gameConfig.mapGeneratorConfig.mapSizeSelection then
gameMap=hexMapHelpers.makeMapComputeFriendly(template)
gameMap.metadata.wasUpdated=true
break
end
counter=counter + 1
end
math.randomseed(os.time())
local validIndices=getValidMapIndices(gameMap)
mapGenerator.spawnOceanTiles(gameMap,validIndices)
mapGenerator.spawnSpecialTiles(gameMap,validIndices)
mapGenerator.spawnTiles(gameMap,validIndices,gameConfig.mapGeneratorConfig.absoluteTiles.volcanoTiles,randomizerTiles.volcanoTiles)
mapGenerator.spawnTiles(gameMap,validIndices,gameConfig.mapGeneratorConfig.absoluteTiles.blockedTiles,randomizerTiles.blockedTiles)
local randomTiles=#validIndices * gameConfig.mapGeneratorConfig.totallyRandomTilesRatio
if math.ceil(randomTiles) - randomTiles > 0.5 then
randomTiles=math.floor(randomTiles)
else
randomTiles=math.ceil(randomTiles)
end
local fixedTilesDistribution={empty=0,bonus=0}
if not (gameConfig.mapGeneratorConfig.bonusTilesRatio <= 1e-4) then
local bonusTilesRatio=1/gameConfig.mapGeneratorConfig.bonusTilesRatio
local emptyTilesRatio=1
for i=1,#validIndices - randomTiles do
if bonusTilesRatio < emptyTilesRatio then
bonusTilesRatio=bonusTilesRatio + 1/gameConfig.mapGeneratorConfig.bonusTilesRatio
fixedTilesDistribution.bonus=fixedTilesDistribution.bonus + 1
else
emptyTilesRatio=emptyTilesRatio + 1
fixedTilesDistribution.empty=fixedTilesDistribution.empty + 1
end
end
else
fixedTilesDistribution={empty=#validIndices - randomTiles,bonus=0}
end
for i=1,randomTiles do
local r=math.random(1,2)
if r==1 then
fixedTilesDistribution.empty=fixedTilesDistribution.empty + 1
else
fixedTilesDistribution.bonus=fixedTilesDistribution.bonus + 1
end
end
mapGenerator.spawnTiles(gameMap,validIndices,fixedTilesDistribution.empty,randomizerTiles.emptyTiles)
local bonusTileYields={}
for i=1,fixedTilesDistribution.bonus do
local yield=mapGenerator.rollTileEffect()
if bonusTileYields[yield.tileEffectType]==nil then
bonusTileYields[yield.tileEffectType]={yield.yield}
else
table.insert(bonusTileYields[yield.tileEffectType],yield.yield)
end
end
mapGenerator.spawnBonusTiles(gameMap,validIndices,bonusTileYields,randomizerTiles.bonusTiles)
function waitForMapCreationToFinish()
local index=0
while #randomizerTilesInPlay < gameMap.metadata.mapSize and index < 3600 do
index=index + 1
coroutine.yield(0)
end
transientState.randomizerTilesUpdatesInProgress=0
updateVisualMap()
for i=1,30 do
coroutine.yield(0)
end
local counter=0
while counter < 10 do
counter=counter + 1
if transientState.randomizerTilesUpdatesInProgress~=0 then
counter=0
end
coroutine.yield(0)
end
randomizer.mapGenerationInProgress=false
return 1
end
startLuaCoroutine(self,"waitForMapCreationToFinish")
end
mapGenerator.spawnBonusTiles=function(map,validIndices,bonusTileYields,referenceBonusTiles)
local spawnIndices={}
for yieldName,potentialYields in pairs(bonusTileYields) do
spawnIndices[yieldName]={}
mapGenerator.internal.findSeedIndices(validIndices,
spawnIndices[yieldName],
gameConfig.mapGeneratorConfig.tileEffects[yieldName].seedPoints,
gameConfig.mapGeneratorConfig.tileEffects[yieldName].seedDistance,
#potentialYields)
local amountToFind=#potentialYields - #spawnIndices[yieldName]
if amountToFind > 0 then
local shapeFactor=gameConfig.mapGeneratorConfig.tileEffects[yieldName].shapeFactor
mapGenerator.internal.findIndices(map,validIndices,spawnIndices[yieldName],amountToFind,shapeFactor)
end
for i,yield in pairs(potentialYields) do
if spawnIndices[yieldName]==nil then
break
end
local r=math.random(1,#spawnIndices[yieldName])
mapGenerator.internal.spawnBonusTile(map,spawnIndices[yieldName][r],yield,yieldName,referenceBonusTiles)
table.remove(spawnIndices[yieldName],r)
end
end
end
mapGenerator.destroyMap=function(map)
function destroyMapCoroutine()
if randomizer.mapGenerationInProgress then
logging.broadcastToAll("Randomized map will be removed as soon as map creation is finished and finalized (5-10 seconds).")
end
while randomizer.mapGenerationInProgress do
coroutine.yield(0)
end
for _,objInfo in pairs(randomizerTilesInPlay) do
local obj=getObjectFromGUID(objInfo.guid)
if obj~=nil then
obj.destruct()
end
end
randomizerTilesInPlay={}
return 1
end
startLuaCoroutine(self,"destroyMapCoroutine")
end
mapGenerator.rollTileEffect=function()
local potentialEffects={}
for resourceType,settings in pairs(gameConfig.mapGeneratorConfig.tileEffects) do
table.insert(potentialEffects,{weight=settings.weighting,value=resourceType})
end
local result=rollFromTable(potentialEffects,10000)
local yield=mapGenerator.rollYield(gameConfig.mapGeneratorConfig.tileEffects[result])
return {tileEffectType=result,yield=yield}
end
mapGenerator.rollYield=function(tileEffects)
local x0=tileEffects.averageTileYield
local f_x0=(math.ceil(x0) - x0) + tileEffects.yieldDiffusion * (x0 - math.floor(x0))
local f_x1=(math.ceil(x0) - x0) * tileEffects.yieldDiffusion + (x0 - math.floor(x0))
local potentialYields={}
local chanceSum=0
if math.abs(f_x0) < 1e-4 then
f_x0=1
f_x1=1
chanceSum=1
table.insert(potentialYields,{weight=f_x0,value=x0})
else
chanceSum=f_x0 + f_x1
table.insert(potentialYields,{weight=f_x0,value=math.floor(x0)})
table.insert(potentialYields,{weight=f_x1,value=math.ceil(x0)})
end
for i=math.floor(x0)-1,1,-1 do
local f_x=f_x0 * math.pow(tileEffects.yieldDiffusion,math.floor(x0) - i)
if f_x > 0.05 then
chanceSum=chanceSum + f_x
table.insert(potentialYields,{weight=f_x,value=i})
else
break
end
end
for i=math.ceil(x0)+1,tileEffects.maxYield do
local f_x=f_x1 * math.pow(tileEffects.yieldDiffusion,i - math.ceil(x0))
if f_x > 0.05 then
chanceSum=chanceSum + f_x
table.insert(potentialYields,{weight=f_x,value=i})
else
break
end
end
return rollFromTable(potentialYields,1000)
end
mapGenerator.internal={}
mapGenerator.internal.findOceanSeedIndices=function(validIndices,oceanIndices)
local numberOfSeedPoints=gameConfig.mapGeneratorConfig.oceanSettings.oceanSeedPoints
if numberOfSeedPoints > #globalParameters.ocean.mappings[globalParameterSystem.values.ocean.selection].steps - 1 then
numberOfSeedPoints=#globalParameters.ocean.mappings[globalParameterSystem.values.ocean.selection].steps - 1
end
mapGenerator.internal.findSeedIndices(validIndices,oceanIndices,numberOfSeedPoints,gameConfig.mapGeneratorConfig.oceanSettings.oceanSeedMinDistance)
end
mapGenerator.internal.findSeedIndices=function(validIndices,spawnIndices,numberOfSeedPoints,seedMinDistance,upperLimit)
upperLimit=upperLimit or numberOfSeedPoints
for i=1,numberOfSeedPoints do
if i > upperLimit then
return
end
local distanceToNearestSeed=-1
local r=-1
local retriesLeft=500
while distanceToNearestSeed < seedMinDistance and retriesLeft > 0 do
r=math.random(1,#validIndices)
distanceToNearestSeed=9999
for _,indices in pairs(spawnIndices) do
local distance=hexMapHelpers.computeDistanceBetweenIndices(indices,validIndices[r])
if distance < distanceToNearestSeed then
distanceToNearestSeed=distance
end
end
retriesLeft=retriesLeft - 1
end
table.insert(spawnIndices,validIndices[r])
table.remove(validIndices,r)
end
end
mapGenerator.internal.spawnBonusTile=function(map,tileIndices,yield,yieldName,referenceBonusTiles)
if yieldName=="DrawCard" then
local foundYield=false
while not foundYield do
for _,tile in pairs(randomizerTiles.bonusTiles) do
if tile.placementProperties.effects~=nil then
local checkAgainstYield=#tile.placementProperties.effects
if checkAgainstYield~=nil and checkAgainstYield==yield then
placeTile(map,tileIndices,tile)
return
end
end
end
if yield <= 1 then
placeTile(map,tileIndices,randomizerTiles.emptyTiles[1])
return
else
yield=yield - 1
end
end
elseif yieldName=="OtherEffects" then
local r=math.random(1,#randomizerTiles.randomizerTileExpansion)
placeTile(map,tileIndices,randomizerTiles.randomizerTileExpansion[r])
else
local foundYield=false
while not foundYield do
for _,tile in pairs(randomizerTiles.bonusTiles) do
if tile.placementProperties.resourceValues~=nil then
local checkAgainstYield=tile.placementProperties.resourceValues[yieldName]
if checkAgainstYield~=nil and checkAgainstYield==yield then
placeTile(map,tileIndices,tile)
return
end
end
end
if yield <= 1 then
placeTile(map,tileIndices,randomizerTiles.emptyTiles[1])
return
else
yield=yield - 1
end
end
end
end
mapGenerator.internal.indicesIdentical=function(a,b)
return a[1]==b[1] and a[2]==b[2] and a[3]==b[3]
end
mapGenerator.internal.findOceanIndices=function(validIndices,oceanIndices,map)
if #oceanIndices==0 then
return
end
local extraOceanTiles=3
if gameConfig.setup.fanMadeProjects then
extraOceanTiles=extraOceanTiles + 1
end
local amountToFind=#globalParameters.ocean.mappings[globalParameterSystem.values.ocean.selection].steps - 1 - #oceanIndices + extraOceanTiles
mapGenerator.internal.findIndices(map,validIndices,oceanIndices,amountToFind,gameConfig.mapGeneratorConfig.oceanSettings.oceanShapeFactor)
end
mapGenerator.internal.findIndices=function(map,validIndices,spawnIndices,amountToFind,shapeFactor)
if #spawnIndices==0 then
return
end
for i=1,amountToFind do
local potentialIndices={}
local retries=100
while next(potentialIndices)==nil do
local r=math.random(1,#spawnIndices)
for _,nti in pairs(hexMapHelpers.getNeighboursIndicesFromIndices(map,spawnIndices[r])) do
local chance=1
local freeTileConsidered=false
if tableHelpers.isTableValueInTable(validIndices,nti,mapGenerator.internal.indicesIdentical) then
for _,ntiInner in pairs(hexMapHelpers.getNeighboursIndicesFromIndices(map,nti)) do
if tableHelpers.isTableValueInTable(spawnIndices,ntiInner,mapGenerator.internal.indicesIdentical) then
if freeTileConsidered then
chance=chance * shapeFactor
else
freeTileConsidered=true
end
end
end
if chance > 1e-5 then
table.insert(potentialIndices,{value=nti,weight=chance})
end
end
end
retries=retries - 1
if retries <= 0 then
local r=math.random(1,#validIndices)
table.insert(spawnIndices,validIndices[r])
table.remove(validIndices,r)
break
end
end
if retries > 0 then
local indices=rollFromTable(potentialIndices,10000)
local index=-1
for i,checkedIndices in pairs(validIndices) do
if mapGenerator.internal.indicesIdentical(checkedIndices,indices) then
index=i
break
end
end
table.insert(spawnIndices,validIndices[index])
table.remove(validIndices,index)
end
end
end
mapGenerator.spawnOceanTiles=function(map,validIndices)
local oceanIndices={}
local tilesToPlace= tableHelpers.deepClone(randomizerTiles.oceanTiles)
mapGenerator.internal.findOceanSeedIndices(validIndices,oceanIndices)
mapGenerator.internal.findOceanIndices(validIndices,oceanIndices,map)
for i,tileIndices in pairs(oceanIndices) do
local poppedTile=popRandomTile(tilesToPlace)
if poppedTile==nil then
regularTiles=tableHelpers.deepClone(randomizerTiles.oceanTiles)
poppedTile=popRandomTile(regularTiles)
end
placeTile(map,tileIndices,poppedTile)
end
end
mapGenerator.spawnSpecialTiles=function(map,validIndices)
local specialTileIndices={}
for _,tileInfo in pairs(randomizerTiles.reservedTiles) do
local r=math.random(1,#validIndices)
specialTileIndices=validIndices[r]
table.remove(validIndices,r)
placeTile(map,specialTileIndices,tileInfo)
end
end
mapGenerator.spawnTiles=function(map,validIndices,numberOfTiles,tiles)
local tilesToPlace=tableHelpers.deepClone(tiles)
local tilesIndices={}
for i=1,numberOfTiles do
local r=math.random(1,#validIndices)
table.insert(tilesIndices,validIndices[r])
table.remove(validIndices,r)
end
for i,tileIndices in pairs(tilesIndices) do
if next(tilesIndices)~=nil then
local poppedTile=popRandomTile(tilesToPlace)
if poppedTile==nil then
tilesToPlace=tableHelpers.deepClone(tiles)
poppedTile=popRandomTile(tilesToPlace)
end
placeTile(map,tileIndices,poppedTile)
end
end
end
--
--     table.insert(specialTilesIndices,validIndices[r])
--
-- end
function getValidMapIndices(map)
local validIndices={}
for i,jkMatrix in pairs(map.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
if next(tile.features)~=nil and tile.features[1]=="empty" then
table.insert(validIndices,{i,j,k})
end
end
end
end
return validIndices
end
function rollFromTable(inputTable,rollTableSize,weightName,valueName)
weightName=weightName or "weight"
valueName=valueName or "value"
local randomFriendlyTable=makeRandomFriendly(inputTable,rollTableSize,weightName,valueName)
local num=math.random(1,rollTableSize)
local indices={}
for _,entry in pairs(randomFriendlyTable) do
if num >= entry.startValue and num <= entry.endValue then
return entry.value
end
end
end
function makeRandomFriendly(inputTable,size,weightName,valueName)
weightName=weightName or "weight"
valueName=valueName or "value"
local sum=0
for _,entry in pairs(inputTable) do
sum=sum + entry[weightName]
end
local sizeFactor=size/sum
local offset=1
local outputTable={}
for _,entry in pairs(inputTable) do
local startValue=offset
local deltaValue=entry[weightName] * sizeFactor
if math.ceil(deltaValue) - deltaValue >= 0.5 then
deltaValue=math.ceil(deltaValue)
else
deltaValue=math.floor(deltaValue)
end
local endValue=startValue + deltaValue
if endValue > size then
endValue=size
end
if endValue~=startValue then
table.insert(outputTable,{startValue=startValue,endValue=endValue,value=entry[valueName]})
offset=endValue + 1
end
if offset > size then
break
end
end
return outputTable
end
function updateVisualMap()
for _,tileInfo in pairs(randomizerTilesInPlay) do
updateTile(tileInfo)
end
end
function updateTile(tileInfo)
function updateTileCoroutine()
transientState.randomizerTilesUpdatesInProgress=transientState.randomizerTilesUpdatesInProgress + 1
local tile=getObjectFromGUID(tileInfo.guid)
local customization={}
customization.image=tileInfo.imageUrl
tile.setCustomObject(customization)
local reloadedTile=tile.reload()
coroutine.yield(0)
reloadedTile.interactable=false
for i=1,20 do coroutine.yield(0) end
while not reloadedTile.resting do
coroutine.yield(0)
end
reloadedTile.setLock(true)
reloadedTile.setScale({1.31,1,1.31})
tileInfo.guid=reloadedTile.guid
transientState.randomizerTilesUpdatesInProgress=transientState.randomizerTilesUpdatesInProgress - 1
return 1
end
startLuaCoroutine(self,"updateTileCoroutine")
end
function popRandomTile(tiles)
local totalAmountOfTiles=0
for _,tile in pairs(tiles) do
totalAmountOfTiles=totalAmountOfTiles + tile.remaining
end
if totalAmountOfTiles==0 then
return nil
end
local whichTileToPop=math.random(1,totalAmountOfTiles)
local currentIndex=0
for i,tile in pairs(tiles) do
currentIndex=currentIndex + tile.remaining
if whichTileToPop <= currentIndex + tile.remaining then
return tile
end
end
end
spawnIndex=1
function spawnTileObject(targetPosition,imageUrl,indices)
local cloneCallback=function(clonedGuid)
local clonedTile=getObjectFromGUID(clonedGuid)
clonedTile.setLock(false)
clonedTile.interactable=false
Wait.time(function()
clonedTile.setLock(true)
clonedTile.setScale({1.31,1,1.31})
table.insert(randomizerTilesInPlay,{guid=clonedTile.guid,indices=indices,imageUrl=imageUrl})
end,2)
end
local potentialCloningGuids=randomizerTiles.baseTileGuids
spawnIndex=spawnIndex + 1
if spawnIndex > #potentialCloningGuids then
spawnIndex=1
end
fastCreateClonableObject(potentialCloningGuids[spawnIndex],targetPosition,{0,270,0},cloneCallback)
end
function placeTile(map,tileIndices,rawTile)
local gameMapTile={features=rawTile.features,placementProperties=rawTile.placementProperties,adjacenyEffects=rawTile.adjacenyEffects or {}}
map.tiles[tileIndices[1]][tileIndices[2]][tileIndices[3]]=gameMapTile
local tileAlreadyExists=false
for _,tileInfo in pairs(randomizerTilesInPlay) do
if tileInfo.indices[1]==tileIndices[1] and tileInfo.indices[2]==tileIndices[2] and tileInfo.indices[3]==tileIndices[3] then
tileInfo.imageUrl=rawTile.imageUrl
tileAlreadyExists=true
end
end
if not tileAlreadyExists then
local marsMapTile=gameObjectHelpers.getObjectByName("gameMap")
local targetPosition=hexMapHelpers.indicesToWorldCoordinates(map,tileIndices,marsMapTile)
spawnTileObject(targetPosition,rawTile.imageUrl,tileIndices)
end
end


uninteractable_guids={
--table
'9354f9',
--table extenders
'6a8317',
'd68373',
'961278',
'4265e6',
'1f1736',
'0b4feb',
"10523e",
"1628e9",
"25a388",
"06e0c1",
"116beb",
"0cbc93",
"0b4feb",
"466281",
"3761bd",
"d8abda",
"909a34",
"1bd753",
"dd3511",
"b4bd71",
"12dce1",
"f62096",
turmoilBoard="12612d",
turmoilEventBoard="fc9a89",
"091112",
"ec4e45",-- gameplay variants
--the rest
'ca3d95',
'f1bfac',
'7db564',
'5458b5',
'5c06aa',
'fab25e',
'94efa5',
'b1cfa0',
'c48e12',
'583d53',
'75192e',
'31b4c1',
'988125',
'c4938b',
'1c4a11',
'456200',
'1e3ee1',
'e76803',
'd5bd4c',
'136760',
'8df3e7',
'8a9df9',
'cb244a',
'adbbbe',
'cb4ffd',
'6480c1',
'c9adc5',
'4fdd36',
'67a37b',
'2d8b29',
'a09130',
'0818d8',
'5bd29d',
'dc4b3f',
'28588f',
'42b9e7',
'2bd7cb',
'323d14',
'e260a7',
'2c06c3',
'8a0903',
'a140d8',
'ecaa6c',
'943859',
'7ddd14',
'a40a0b',
'c1fd7a',
'b0beba',
'270e01',
--Randomizer button
'fb5a32',
'c0ee0f',
'e5b496',
'28091f',
'332dcf',
'9c4b18',
'fe23fb',
'ff0395',
'efab72',
'290822',
'849ab1',
'8484d8',
'5168e1',
'9b4c37',
'009718',
'c8a4b6',
'64abda',
'04ad36',
'4c561a',
'35a17f',
'772467',
'c290b9',
'b27a13',
'6a1319',
'e72b70',
'4c5add',
'76a492',
'39361c',
'ebcf60',
'7e8037',
'691263',
'f7f3c1',
'c2f052',
'a0b629',
'd1ecbb',
'53dc16',
'd74656',
'1b503f',
'2378a0',
'e319da',
'c14cf3',
'505189',
'5bc390',
'aeab5d',
'180c02',
'cf8a7e',
'c5247e',
'9f9d1e',
'990b7f',
'035fd0',
'19c3bb',
'd02091',
'a79721',
'b64a5c',
'a0e376',
'b10b90',
'b33276',
'187d04',
'5ad2d0',
'772eaf',
'58db6e',
'ca30dc',
'9784e6',
'3c2f97',
'79282f',
"d3845f",
'466282',-- table left panel
'466283',-- game setup subtable
'ca6fe5',
'ca6fe4',
'ca6fe3',
'ca6fe2',
'ca6fe1',
'ca6fe0',
'ca6fdf',
'ca6fde',
'ca6fdd',
'ca6fdc',
'466284',
'e0de83',
globalParameters.oxygen.objectGuid,
'76225d',
globalParameters.temperature.objectGuid,
'9a571f',
'cf4f00',-- ocean track
'71ca01',-- game mat tile
'71ca02',-- standard project tile
'8f1595',-- milestone tile
'8f1596',-- awards tile
'fa0471',-- turmoil tile
'2baba5',-- turmoil party tile
'cb2a6c',-- game config tile
'9460b1',-- timer config tile
}
function makeObjectsUninteractable()
for _,guid in pairs(uninteractable_guids) do
object=getObjectFromGUID(guid)
if object then
object.interactable=false
end
end
end


bags={
venusBag="0818d8",
coloniesBag="ebe13a",
coloniesShipBag="b176ad",
coloniesMarkersBag="b308cf",
pathFinderBag="323d14",
oceanBag="d6af9e",
specialsBag="0d97f2",
genericDelegateBag="deb215",
}
bagProtectorGuidStores.normalBags=bags
referenceBags={
containerOne="3340b2",
containerTwo="9ee3f2"
}
bagProtectorGuidStores.referenceBags=referenceBags
cardAutomaton={
baseCard="e77dbd",
baseBlueCard="e77dbe",
baseGreenCard="e77dbf",
baseEventCard="e77dc0",
baseInfrastructureCard="e77dc1",
baseCorporationCard="e77dc2",
}
turmoilPartyPlates={
MarsFirst="ad4d18",
Scientists="ce0555",
Unity="35bec1",
Greens="99259c",
Reds="995445",
Kelvinists="dafd56",
}
expansions={
venusProjects="b530b4",
venusCorps="d76fa5",
venuphileAwardTile="d4e451",
hoverlordMilestoneTile="404512",
venusTerraformingTrack="59dd23",
venusTerraformingMarker="ca3d97",
coloniesTradingTile="3e7af8",
coloniesProjects="211e80",
coloniesCorps="cdef51",
coloniesTradeFleetTile="9ba254",
preludeProjects="400808",
preludeCorps="4b4231",
turmoilPartyTile="2baba5",
turmoilProjects="160ff4",
turmoilCorps="2be67c",
turmoilDeck="87a219",
turmoilGlobalEventDeck="87a219",
turmoilColonyCards="f8b2f4",
turmoilVenusCards="899f9f",
turmoilColonyVenusCards="192cfa",
turmoilTMToken="a9aaf0",
turmoilTile="fa0471",
turmoilBoard="12612d",
turmoilEventBoard="fc9a89",
turmoilNeutralDelegates="7caf29",
turmoilBasePartyPlate="99259c",
turmoilDominanceMarker="578734",
turmoilGenericDelegate="2b66ef",
venusPhaseTwoDeck="23d12e",
solarisDeck="d1001d",
aresDeck="aed180",
bigBoxCorps="fcd67e",
bigBoxProjects="c632e8",
bggCorps="3e7abf",
corpEraProjects="f34f65",
corpEraCorps="1a43a4",
pathFinderProjects="f0cf60",
pathFinderCorps="bf570f",
pathFinderPreludes="56f4b8",
highOrbitInfrastructureDeck="8bf4f7",
xenosCorps="97b1d0",
fanMadeProjects="95f620",
}
setupGuids={
playmat="9a571f",
draftBag="b0beba",
setupMat="2bd7cb",
standardProjects="270e01",
boardZone="afc408",
tradeFleetZone="41343b",
generationCounter="1c4a11",
cityCounter="8df3e7",
citiesOnMarsCounter="c6c23e",
oceanCounter="e260a7",
capitalCityToken="0e17f3",
oceanCityToken="4cfb25",
genericScoreBoard="091112",
genericTRCube="7ddd14",
genericClassicPlayerBoard="583d53",
genericPlayerBoard="13d3bb",
genericPlayerBoardFlipped="13d3be",
genericDraftingToKeepTile="7a62d8",
genericDraftingCheckToken="25ad34",
genericIconTableau="0adaf2",
genericPathfinderIconTableau="e4ebb6",
genericHighOrbitIconTableau="e4ebb7",
genericActivationTableau="52f95e",
generationMarker="a63f90",
genericPlayerAntiLagBoard="bd6888",
genericPlayerOrgHelpBoard="081edb",
milestonePlate="8f1595",
milestoneDefaultTile="ca6fe4",
milestoneAndAwardDefaultTile="ca6fe4",
awardPlate="8f1596",
baseBonusTokenGuid="a4d4c3",
mainBoardTile="71ca01",
firstPlayerToken="2f276a",
genericOcean="e3a5e4",
genericCityBag="f38446",
genericGreeneryBag="e4c505",
animalWildSource="716168",
microbeFloaterSource="4499d3",
scienceFighterSource="411a07",
oreSource="716169",
dataAsteroidSource="9dec75",
actionMarkersSource="3cc625",
resourceWildTokenSource="3cc626",
programableActionTokenSource="3cc627",
floatingArrayBag="bb5da3",
gasMineBag="080f86",
venusHabitatBag="7f9cef",
duststormBag="d749f0",
erosionBag="fe18b7",
extraOceansCounter="e260a7",
oxygenToken="ca3d95",
temperatureToken="f1bfac",
oceanToken="ca3d96",
scrappingToken="ca3d97",
venusPathfinderToken="0683d4",
earthPathfinderToken="92ae13",
marsPathfinderToken="d45204",
jovianPathfinderToken="6a30b4",
oxygenMax="2cc3ab",
tempMax="ef3cb2",
scoreCounterBag="c1fd7a",
projectStackTile='b550fe',
projectDiscardTile="f7e628",
projectZone="1ae58d",
revealZone="1ae58e",
discardStackTile='0e0cb2',
corpAmountToken="c1af2b",
loggingTile="9a5720",
pathfinderBoard="9ebcf8",
projectDeck="5a3113",
corpDeck="7f05e7",
preludeDeck="501238",
gameObjectsBoard="466283",
gameMap="e0de83",
marsMapTile="e0de83",
venusMapTile="76225d",
gameBoardTile="71ca01",
standardProjectTile="71ca02",
gameConfigTile="cb2a6c",
timerConfigTile="9460b1",
}
specialTiles={
preserve="8617b9",
miningArea="617acd",
miningRights="3de716",
nuclear="8df758",
restricted="59c9a4",
capital="0e17f3",
lavaFlows="a40228",
ecologicalZone="c58448",
industrial="676cf5",
mohole="b69b74",
commercial="11528c",
crashSite="e56912",
newVenice="4cfb25",
oceanGreenery="919a9d",
wetlands="919a9d",
redCity="4bab93",
MenagerieTile="80c18b",
AresCapital="be9df4",
AresCommercialDistrict="c66e48",
AresEcologicalZone="b46a9e",
AresFertilizerFactory="1c6b35",
AresIndustrialCenter="793527",
AresMeteorCrater="9b23ce",
AresMiningAreaSteel="2627ee",
AresMiningAreaTitanium="568ea3",
AresMiningRightsSteel="697619",
AresMiningRightsTitanium="b212e7",
AresMoholeArea="eef791",
AresNaturalPreserve="7ee900",
AresNuclearZone="3ea477",
AresOceanFarm="943c58",
AresOceanicCity="ea6814",
AresOceanSanctuary="223447",
AresRestrictedArea="2b26f1",
AresSolarFarm="6ae25b",
AresVolcano="87136d",
}
gameObjectGuidStores.expansions=expansions
gameObjectGuidStores.setupGuids=setupGuids
gameObjectGuidStores.bags=bags
gameObjectGuidStores.cardAutomaton=cardAutomaton
gameObjectGuidStores.specialTiles=specialTiles


gameState={
extendedScriptingEnabled=false,
temperatureDone=false,
venusDone=false,
venusIsWin=false,
oxygenDone=false,
oceansDone=false,
globalParameterSelection=1,
oceansNeeded=9,
prelude=false,
colonies=false,
venus=false,
turmoil=false,
ares=false,
solarPhase=nil,
draftingEnabled=false,
shuffleBackAfterSearch=false,
randomizeMap=false,
initialProjectsToDeal=10,
corporationsToDeal=2,
preludesToDeal=4,
projectsPerGeneration=4,
started=false,
setupIsDone=false,
ended=false,
selectedMap=1,
currentPhase=phases.gameSetupPhase,
automaticSpaceTilePlacement=true,
wasUpdated=true,
}
gameState.drafting={
draftingDirection=1,
currentStep=1,
currentSubStep=1,
done=false,
ignoreRules=false,
currentDraftingRule=draftingData.initialResearchPhase.d_4_3_3,
}
gameState.aresData={
erosionTilesFlipped=false,
duststormTilesFlipped=false,
markers={},
}
gameState.turmoilData={
oneTimeEffectTable={}
}
gameState.milestones={
maxClaims=3
}
gameState.awards={
maxFunders=3
}
gameState.allPlayers={}
gameState.numberOfPlayers=0
gameState.rawPlayerOrder={
"White",
"Red",
"Yellow",
"Orange",
"Green",
"Blue",
"Purple",
"Pink"
}
gameState.currentGeneration=1
gameState.firstPlayer=nil
gameState.currentPlayer=nil
gameState.citiesInSpace=0
gameState.citiesOnMars=0
gameState.citiesInSpaceGuids={}
gameState.oceanTileGuids={}
gameState.activeExpansions={}
gameState.claimedMilestones={}
gameState.claimedAwards={}
gameState.static={}
gameState.static.coloniesGameData={}
gameState.timerConfiguration={
pauseOnDraft=false,
timeoutAction="doNothing",
}
transientState={
spawningTile=false
}
transientState.solo={
lastNeutralCityIndices={0,0,0},
stepsToWalk=-1
}
transientState.aresData={
stepsToWalk=0,
}
transientState.turmoilActions={
trRevisionInProgress=false,
globalEventInProgress=false,
newGovInProgress=false,
changingTimesInProgress=false,
}
transientState.autoPassData={
inProgress=false,
tilesToPlace={},
}
transientState.changingGlobalParameters={}
function getGameState()
return gameState
end
function changeCityCount(params)
if hexMapHelpers.isOnMars(gameMap,params.position) then
gameState.citiesOnMars=gameState.citiesOnMars + params.delta
else
if gameState.citiesInSpaceGuids==nil then
gameState.citiesInSpaceGuids={}
end
if params.delta==1 then
table.insert(gameState.citiesInSpaceGuids,params.guid)
elseif params.delta==-1 then
local index=1
for i,guid in pairs(gameState.citiesInSpaceGuids) do
if guid==params.guid then
index=i
break
end
end
table.remove(gameState.citiesInSpaceGuids,index)
end
gameState.citiesInSpace=gameState.citiesInSpace + params.delta
end
updateCityCounters()
end
gameObjectHelpers.isCity=function(guid)
local object=getObjectFromGUID(guid)
if object==nil then
return false
end
local cityNames={"City","New Venice","Red City","Capital"}
for _,name in pairs(cityNames) do
if name==object.getName() then
return true
end
end
return false
end
gameObjectHelpers.isOcean=function(guid)
if guid==nil then return false end
return tableHelpers.isValueInTable(gameState.oceanTileGuids,guid)
end
gameObjectHelpers.isGreenery=function(guid)
local object=getObjectFromGUID(guid)
if object==nil then
return false
end
return object.getName()=="Greenery"
end
gameObjectHelpers.isEmpty=function(guid)
return guid==nil or guid=="8b4c4f"
end
gameObjectHelpers.recordOcean=function(guid)
globalParameterSystem.values.ocean.value=globalParameterSystem.values.ocean.value + 1
table.insert(gameState.oceanTileGuids,guid)
end
gameObjectHelpers.oceanDestroyed=function(guid)
globalParameterSystem.values.ocean.value=globalParameterSystem.values.ocean.value - 1
tableHelpers.removeValueFromTable(gameState.oceanTileGuids,guid)
end
gameObjectHelpers.oceanStashed=function(guid)
globalParameterSystem.values.ocean.value=globalParameterSystem.values.ocean.value - 1
end
gameObjectHelpers.oceanRetrieved=function(guid)
globalParameterSystem.values.ocean.value=globalParameterSystem.values.ocean.value + 1
end
function isSupportedColor(color)
for _,supportedColor in pairs(gameState.rawPlayerOrder) do
if supportedColor==color then
return true
end
end
return false
end
function isColorPlaying(color)
for _,player in pairs(gameState.allPlayers) do
if player.color==color then
return true
end
end
return false
end
gameStateFunctions={}
gameStateFunctions.addPlayer=function(playerColor,isNeutralPlayer)
local positionToInsert=1
local positionInRawOrder=-1
for i=1,#gameState.rawPlayerOrder do
if gameState.rawPlayerOrder[i]==playerColor then
positionInRawOrder=i
end
end
if positionInRawOrder==-1 then
logging.broadcastToAll("Player Color "..playerColor.." not in Turn order. Report this issue",playerColor,loggingModes.exception)
return
end
for i=1,positionInRawOrder do
if gameState.allPlayers[positionToInsert]==nil then
break
end
if gameState.allPlayers[positionToInsert].color==gameState.rawPlayerOrder[i] then
positionToInsert=positionToInsert + 1
end
end
table.insert(gameState.allPlayers,positionToInsert,TMPlayer:new(playerColor,20,isNeutralPlayer) )
gameState.numberOfPlayers=gameState.numberOfPlayers + 1
gameState.allPlayers[positionToInsert].wasUpdated=true
end


uiNames={}
uiNames.solarPhase="solarPhase"
uiNames.genStart="genStart"
uiNames.playerNames={
"Player1",
"Player2",
"Player3",
"Player4",
"Player5",
"Player6"
}
uiNames.activePlayerIndicator={
"Turn1",
"Turn2",
"Turn3",
"Turn4",
"Turn5",
"Turn6"
}
uiNames.endTurnButtons={
White="WhiteEndTurn",
Blue="BlueEndTurn",
Yellow="YellowEndTurn",
Red="RedEndTurn",
Green="GreenEndTurn",
Orange="OrangeEndTurn"
}




function toggleAntiLag(playerColor)
local playerIndex=getPlayerIndexByColor(playerColor)
if gameState.allPlayers[playerIndex].playerArea.playerAntiLagBoard~=nil then
getObjectFromGUID(gameState.allPlayers[playerIndex].playerArea.playerAntiLagBoard).destruct()
gameState.allPlayers[playerIndex].playerArea.playerAntiLagBoard=nil
else
if Player[playerColor].seated then
broadcastToColor("To use anti lag board just move cards from your hand there. It will lag less if enough players do this. They are hidden there from other players.",playerColor,{0,1,0})
end
createPlayerAntiLagBoard(gameState.allPlayers[playerIndex])
end
gameState.allPlayers[playerIndex].wasUpdated=true
end
function toggleOrg(playerColor)
local player=getPlayerByColor(playerColor)
if player.playerArea.playerOrgHelpBoard~=nil then
getObjectFromGUID(player.playerArea.playerOrgHelpBoard).destruct()
player.playerArea.playerOrgHelpBoard=nil
else
createPlayerOrgHelpBoard(player)
end
end
function toggleIconTableaus(playerColor)
local playerIndex=getPlayerIndexByColor(playerColor)
local player=gameState.allPlayers[playerIndex]
if player.playerArea.iconTableaus~=nil and #player.playerArea.iconTableaus > 0 then
for _,iconTableauGuid in pairs(player.playerArea.iconTableaus) do
local iconTableau=getObjectFromGUID(iconTableauGuid)
if iconTableau~=nil then
iconTableau.destruct()
end
end
player.playerArea.iconTableaus={}
else
createIconTableaus(player)
end
player.wasUpdated=true
end
function toggleActivationTableau(playerColor)
local player=getPlayerByColor(playerColor)
if player.playerArea.activationTableau~=nil then
local object=getObjectFromGUID(player.playerArea.activationTableau)
player.playerArea.activationTableau=nil
if object~=nil then
object.destruct()
else
createActivationTableau(player)
end
else
createActivationTableau(player)
end
player.wasUpdated=true
end
function togglePersonalScoreBoard(playerColor)
local player=getPlayerByColor(playerColor)
if player.playerArea.personalScoreBoard~=nil then
local object=getObjectFromGUID(player.playerArea.personalScoreBoard)
player.playerArea.personalScoreBoard=nil
if object~=nil then
object.destruct()
else
createPersonalScoreBoard(player)
end
else
createPersonalScoreBoard(player)
end
player.wasUpdated=true
end
function createTRCube(player)
function coroutineCloneCube()
coroutine.yield(0)
local genericCube=gameObjectHelpers.getObjectByName("genericTRCube")
local newCube=genericCube.clone()
while newCube.getGUID()==genericCube.getGUID() do
coroutine.yield(0)
end
newCube.setName(player.color .. " TR Cube")
newCube.setLock(true)
newCube.setColorTint(stringColorToRGB(player.color))
player.playerArea.trCube=newCube.getGUID()
updateCubePositionsOnTerraformingBar()
coroutine.yield(0)
coroutine.yield(0)
updateCubePositionsOnTerraformingBar()
player.wasUpdated=true
return 1
end
startLuaCoroutine(self,"coroutineCloneCube")
end
function createPlayerBoard(player)
log("Creating player board for "..player.color)
local transform=tablePositions.player.playerSpawnPositions[player.color]
local genericBoard=gameObjectHelpers.getObjectByName("genericPlayerBoard")
if transform.isLeftRightFlipped then
genericBoard=gameObjectHelpers.getObjectByName("genericPlayerBoardFlipped")
end
createClonableObject(
genericBoard,
transform.pos,
transform.rot,
function(clonedObjectGuid)
player.playerArea.playerMat=genericBoard.getVar("lastClonedSelfGuid")
local clonedBoard=getObjectFromGUID(player.playerArea.playerMat)
clonedBoard.call("initialize",{playerColor=player.color,playerName=player.name})
playerActionFuncs_toggleAutoPassOption({playerColor=player.color,delta=0})
player.wasUpdated=true
end
)
end
function createPlayerAntiLagBoard(player)
local genericBoard=	gameObjectHelpers.getObjectByName("genericPlayerAntiLagBoard")
local offsetTransform=tableHelpers.deepClone(getObjectFromGUID(player.playerArea.playerMat).call("getAntiLagBoardTransform"))
createClonableObject(
genericBoard,
offsetTransform.pos,
offsetTransform.rot,
function(clonedObjectGuid)
player.playerArea.playerAntiLagBoard=clonedObjectGuid
local clonedBoard=getObjectFromGUID(player.playerArea.playerAntiLagBoard)
clonedBoard.call("setPlayerColor",player.color)
clonedBoard.call("activateBoard")
player.wasUpdated=true
end
)
end
function createPlayerOrgHelpBoard(player)
local genericBoard=	gameObjectHelpers.getObjectByName("genericPlayerOrgHelpBoard")
local offsetTransform=tableHelpers.deepClone(getObjectFromGUID(player.playerArea.playerMat).call("getOrgBoardTransform"))
createClonableObject(
genericBoard,
offsetTransform.pos,
offsetTransform.rot,
function(clonedObjectGuid)
player.playerArea.playerOrgHelpBoard=clonedObjectGuid
local clonedBoard=getObjectFromGUID(player.playerArea.playerOrgHelpBoard)
clonedBoard.setVar("playerColor",player.color)
player.wasUpdated=true
end
)
end
function createIconTableaus(player)
log("Creating icon tableau for "..player.color)
function createIconTableausCoroutine()
local tableau=gameObjectHelpers.getObjectByName("genericIconTableau")
while player.playerArea==nil or getObjectFromGUID(player.playerArea.playerMat)==nil do
coroutine.yield(0)
end
local offsetTransform=tableHelpers.deepClone(getObjectFromGUID(player.playerArea.playerMat).call("getIconTableuTransform"))
createClonableObject(tableau,
offsetTransform.pos,
offsetTransform.rot,
function(clonedObjectGuid)
if player.playerArea.iconTableaus==nil then
player.playerArea.iconTableaus={}
end
table.insert(player.playerArea.iconTableaus,clonedObjectGuid)
local clonedIconTableau=getObjectFromGUID(clonedObjectGuid)
clonedIconTableau.call("setPlayerColor",player.color)
end)
local offset={-7.45,0,0}
if gameState.activeExpansions.pathfinders then
local basePathfinderTableau=gameObjectHelpers.getObjectByName("genericPathfinderIconTableau")
local pathfinderOffset=vectorHelpers.addVectors(offsetTransform.pos,vectorHelpers.rotateVectorY(offset,offsetTransform.rot[2]))
offset=vectorHelpers.addVectors(offset,{-1.45,0,0})
createClonableObject(basePathfinderTableau,
pathfinderOffset,
offsetTransform.rot,
function(clonedObjectGuid)
if player.playerArea.iconTableaus==nil then
player.playerArea.iconTableaus={}
end
table.insert(player.playerArea.iconTableaus,clonedObjectGuid)
local clonedIconTableau=getObjectFromGUID(clonedObjectGuid)
clonedIconTableau.call("setPlayerColor",player.color)
player.wasUpdated=true
end)
end
if gameState.activeExpansions.highOrbit then
local highOrbitTableau=gameObjectHelpers.getObjectByName("genericHighOrbitIconTableau")
local highOrbitOffset=vectorHelpers.addVectors(offsetTransform.pos,vectorHelpers.rotateVectorY(offset,offsetTransform.rot[2]))
offset=vectorHelpers.addVectors(offset,{-1.45,0,0.0})
createClonableObject(highOrbitTableau,
highOrbitOffset,
offsetTransform.rot,
function(clonedObjectGuid)
if player.playerArea.iconTableaus==nil then
player.playerArea.iconTableaus={}
end
table.insert(player.playerArea.iconTableaus,clonedObjectGuid)
local clonedIconTableau=getObjectFromGUID(clonedObjectGuid)
clonedIconTableau.call("setPlayerColor",player.color)
player.wasUpdated=true
end)
end
return 1
end
startLuaCoroutine(self,"createIconTableausCoroutine")
end
function createActivationTableau(player)
function createActivationTableauCoroutine()
local genericActivationTableau=gameObjectHelpers.getObjectByName("genericActivationTableau")
while player.playerArea==nil or getObjectFromGUID(player.playerArea.playerMat)==nil do
coroutine.yield(0)
end
local offsetTransform=tableHelpers.deepClone(getObjectFromGUID(player.playerArea.playerMat).call("getActivationTableuTransform"))
createClonableObject(genericActivationTableau,offsetTransform.pos,offsetTransform.rot,
function(clonedObjectGuid)
player.playerArea.activationTableau=clonedObjectGuid
local clonedActivationTableau=getObjectFromGUID(player.playerArea.activationTableau)
clonedActivationTableau.call("setPlayerColor",player.color)
player.wasUpdated=true
end)
return 1
end
startLuaCoroutine(self,"createActivationTableauCoroutine")
end
function createPersonalScoreBoard(player)
if player.neutral then return end
function cloneScoreBoardCoroutine()
local playerMat=getObjectFromGUID(player.playerArea.playerMat)
local targetTransform=tableHelpers.deepClone(getObjectFromGUID(player.playerArea.playerMat).call("getPersonalScoreBoardTransform"))
local object=gameObjectHelpers.getObjectByName("genericScoreBoard")
newObject=object.clone()
newObject.lock()
while(object.getGUID()==newObject.getGUID()) do
coroutine.yield(0)
end
for i=1,5 do
coroutine.yield(0)
end
local playerIndex=getPlayerIndexByColor(player.color)
player.playerArea.personalScoreBoard=newObject.getGUID()
newObject.setPositionSmooth(targetTransform.pos,false,false)
newObject.setRotation(targetTransform.rot)
newObject.setScale({1.45,1,1.45})
newObject.call("setOwner",player.color)
newObject.call("registerEventHandlers")
newObject.call("setPlayerIndex",playerIndex)
updatePlayerStats(playerIndex)
return 1
end
startLuaCoroutine(self,"cloneScoreBoardCoroutine")
end
cloningOngoing=false
function isCloningOngoing()
for guid,status in pairs(cloningOngoingTable) do
if status then
return true
end
end
return false
end
cloningOngoingTable={}
function createClonableObject(object,targetPosition,targetRotation,callback,exclusiveCloningRequested)
function coroutineCloneObject()
local guid=object
local clonableObject=nil
if type(object)=="userdata" then
clonableObject=object
guid=clonableObject.getGUID()
else
clonableObject=getObjectFromGUID(object)
end
coroutine.yield(0)
if clonableObject.tag=="Bag" then
exclusiveCloningRequested=true
end
while exclusiveCloningRequested and exclusiveCloning do
coroutine.yield(0)
end
if exclusiveCloningRequested then
exclusiveCloning=true
while isCloningOngoing() do
coroutine.yield(0)
end
end
--log("Enter clone object coroutine")
while cloningOngoingTable[guid] or (exclusiveCloning and not exclusiveCloningRequested) do
coroutine.yield(0)
end
cloningOngoingTable[guid]=true
--log("Starting clonable object creation for object with guid "..clonableObject.getGUID())
clonableObject.call("copySelf",{position=targetPosition,rotation=targetRotation})
while clonableObject.getVar("lastClonedSelfGuid")==nil do
coroutine.yield(0)
end
local clonedObjectGuid=clonableObject.getVar("lastClonedSelfGuid")
if type(callback)=="function" then
callback(clonedObjectGuid)
end
--log("Finished cloning object")
if exclusiveCloningRequested then
exclusiveCloning=false
end
cloningOngoingTable[guid]=false
return 1
end
startLuaCoroutine(self,"coroutineCloneObject")
end
function fastCreateClonableObject(object,targetPosition,targetRotation,callback,exclusiveCloningRequested)
function coroutineCloneObject()
local guid=object
local clonableObject=nil
if type(object)=="userdata" then
clonableObject=object
guid=clonableObject.getGUID()
else
clonableObject=getObjectFromGUID(object)
end
while cloningOngoingTable[guid] do
coroutine.yield(0)
end
cloningOngoingTable[guid]=true
clonableObject.call("copySelf",{position=targetPosition,rotation=targetRotation})
while clonableObject.getVar("lastClonedSelfGuid")==nil do
coroutine.yield(0)
end
local clonedObjectGuid=clonableObject.getVar("lastClonedSelfGuid")
if type(callback)=="function" then
callback(clonedObjectGuid)
end
cloningOngoingTable[guid]=false
return 1
end
startLuaCoroutine(self,"coroutineCloneObject")
end
--
--   obj.owningPlayer=owningPlayer
--   obj.genericToBeClonedObjectName=genericToBeClonedObjectName
--
--
--
-- 		-- Make sure only one cloning is going on at one time
--
--
--
--
--
--
--
--  return toBeClonedObject.clonedObject


function genStart()
if isDoubleClick("genStart") then
return
end
gameState.currentPhase=phases.generationPhase
eventHandling_triggerEvent( {
triggeredByColor=gameState.allPlayers[gameState.firstPlayer].color,
triggerType=eventData.triggerType.playerTurnBegan} )
notifyCurrentPlayer()
updatePlayerUI()
end
function endTurnRemotely(params)
local triggeredByColor=params.playerColor
if gameState.currentPhase==phases.draftingPhase then
gameState.currentPhase=phases.generationPhase
end
for i,player in pairs(gameState.allPlayers) do
if player.color==triggeredByColor then
if i==gameState.currentPlayer then
if params.hasPassed then
player.hasPassedGeneration=true
end
endTurn()
end
end
end
end
function endTurnHandleTimer(nextPlayerToCheck)
local currentPlayer=gameState.allPlayers[gameState.currentPlayer]
if gameState.activeExpansions.timer then
if gameState.currentPlayer~=nextPlayerToCheck then
if currentPlayer.playerActions.actionDone==0 then
local playerMat=getObjectFromGUID(currentPlayer.playerArea.playerMat)
playerMat.call("passGenerationRemotely")
timerFunctions.onPlayerTurnEnd(gameState.currentPlayer)
return true
else
timerFunctions.onPlayerTurnEnd(gameState.currentPlayer)
end
else
if currentPlayer.timer.time==0 then
local playerMat=getObjectFromGUID(currentPlayer.playerArea.playerMat)
playerMat.call("passGenerationRemotely")
timerFunctions.onPlayerTurnEnd(gameState.currentPlayer)
return true
end
end
gameState.allPlayers[nextPlayerToCheck].timer.isRunning=true
end
return false
end
function endTurn()
if isDoubleClick("endTurn") then
return
end
if gameState.started then
local nextPlayerFound=false
if gameState.turmoil then
recalculateDominance()
recalculatePartyLeads()
end
for i=1,gameState.numberOfPlayers do
local nextPlayerToCheck=gameState.currentPlayer + i
if nextPlayerToCheck > gameState.numberOfPlayers then
nextPlayerToCheck=nextPlayerToCheck - gameState.numberOfPlayers
end
local hasPassed=gameState.allPlayers[nextPlayerToCheck].hasPassedGeneration
if not hasPassed and not gameState.allPlayers[nextPlayerToCheck].neutral and Player[gameState.allPlayers[nextPlayerToCheck].color].seated then
local exit=endTurnHandleTimer(nextPlayerToCheck)
if exit then
break
end
if gameState.currentPlayer==nextPlayerToCheck then
logging.broadcastToAll(gameState.allPlayers[nextPlayerToCheck].name.." is alone in this gen!",{1,1,1},loggingModes.important)
else
gameState.allPlayers[gameState.currentPlayer].playerActions.actionsDone=0
if gameState.currentPhase==phases.generationPhase then
eventHandling_triggerEvent( {
triggeredByColor=gameState.allPlayers[gameState.currentPlayer].color,
triggerType=eventData.triggerType.playerTurnEnd} )
end
end
gameState.currentPlayer=nextPlayerToCheck
nextPlayerFound=true
notifyCurrentPlayer()
updatePlayerUI()
if gameState.currentPhase==phases.generationPhase then
eventHandling_triggerEvent( {
triggeredByColor=gameState.allPlayers[gameState.currentPlayer].color,
triggerType=eventData.triggerType.playerTurnBegan} )
end
break
end
end
if not nextPlayerFound then
gameState.allPlayers[gameState.currentPlayer].playerActions.actionsDone=0
gameState.currentPlayer=-1
productionPhase()
if not checkEndOfGame() then
if gameState.solarPhase then
gameState.currentPhase=phases.solarPhase
local firstPlayer=gameState.allPlayers[gameState.firstPlayer]
logging.broadcastToAll(firstPlayer.name.." to do solar phase!",firstPlayer.color,loggingModes.essential)
updatePlayerUI()
else
endGeneration()
end
else
logging.printToAll("Game is ending! Thanks for playing!",{1,1,1},loggingModes.exception)
endGame()
end
end
end
end
function solarPhase()
if isDoubleClick("solarPhase") then
return
end
endGeneration()
end
function endGame()
gameState.ended=true
gameState.currentPhase=phases.gameEndPhase
showScoreBoards()
updatePlayerUI()
end
function endGeneration()
gameState.currentGeneration=gameState.currentGeneration + 1
if gameState.isSoloGame and gameState.currentGeneration > gameState.maxGeneration then
logging.broadcastToAll("You should have finished terraforming by now. Unfortunately by official rules game is over now. You can keep playing however",{1,0,0},loggingModes.exception)
end
updateCubePositionsOnTerraformingBar()
passFirstPlayer()
resetPassState()
researchPhaseFunctions.beginResearchPhase(draftingData.researchPhase.defaultRule)
if gameState.activeExpansions.timer then
timerFunctions.onEndGeneration()
end
if gameState.colonies then
resetTradingFleets()
increaseColonyMarkers()
end
updatePlayerUI()
resetActions()
eventHandling_triggerEvent({triggeredByColor=nil,triggerType=eventData.triggerType.newGeneration})
end
function resetActions()
objects=getAllObjects()
for i,v in pairs(objects) do
rotation=v.getRotation()
zAxis=rotation[3]
if v.getDescription()=='Action Marker' and zAxis >= 179 then
v.flip()
elseif v.getVar('action')==true then
v.call('genEnd')
end
end
end
function resetPassState()
for i,player in pairs(gameState.allPlayers) do
if not player.neutral then
player.hasPassedGeneration=false
local playerMat=getObjectFromGUID(player.playerArea.playerMat)
if playerMat~=nil then
playerMat.call("resetRocketPass")
end
end
end
end
function productionPhase()
for _,tmPlayer in pairs(gameState.allPlayers) do
if not tmPlayer.neutral then
logging.printToColor("> > > > > > > > > Production Phase for player: "..tmPlayer.color,tmPlayer.color,tmPlayer.color,loggingModes.debugging)
logging.printToColor("[Stockpile] Creds:"..getPlayerResource({resourceType="credits",playerColor=tmPlayer.color})
.." Steel:"..getPlayerResource({resourceType="steel",playerColor=tmPlayer.color})
.." Titan:"..getPlayerResource({resourceType="titanium",playerColor=tmPlayer.color})
.." Plants:"..getPlayerResource({resourceType="plants",playerColor=tmPlayer.color})
.." Energy:"..getPlayerResource({resourceType="energy",playerColor=tmPlayer.color})
.." Heat:"..getPlayerResource({resourceType="heat",playerColor=tmPlayer.color})
.." TR:"..tmPlayer.terraformingRating,
tmPlayer.color,tmPlayer.color,loggingModes.debugging)
logging.printToColor("[Production] Creds:"..getPlayerProduction({resourceType="credits",playerColor=tmPlayer.color})
.." Steel:"..getPlayerProduction({resourceType="steel",playerColor=tmPlayer.color})
.." Titan:"..getPlayerProduction({resourceType="titanium",playerColor=tmPlayer.color})
.." Plants:"..getPlayerProduction({resourceType="plants",playerColor=tmPlayer.color})
.." Energy:"..getPlayerProduction({resourceType="energy",playerColor=tmPlayer.color})
.." Heat:"..getPlayerProduction({resourceType="heat",playerColor=tmPlayer.color}),
tmPlayer.color,tmPlayer.color,loggingModes.debugging)
end
getObjectFromGUID(tmPlayer.playerArea.playerMat).call("performProductionPhase",tmPlayer.terraformingRating)
if not tmPlayer.neutral then
logging.printToColor("Production done",tmPlayer.color,tmPlayer.color,loggingModes.debugging)
logging.printToColor("[Stockpile] Creds:"..getPlayerResource({resourceType="credits",playerColor=tmPlayer.color})
.." Steel:"..getPlayerResource({resourceType="steel",playerColor=tmPlayer.color})
.." Titan:"..getPlayerResource({resourceType="titanium",playerColor=tmPlayer.color})
.." Plants:"..getPlayerResource({resourceType="plants",playerColor=tmPlayer.color})
.." Energy:"..getPlayerResource({resourceType="energy",playerColor=tmPlayer.color})
.." Heat:"..getPlayerResource({resourceType="heat",playerColor=tmPlayer.color}),
tmPlayer.color,tmPlayer.color,loggingModes.debugging)
logging.printToColor("< < < < < < < < <",tmPlayer.color,tmPlayer.color,loggingModes.debugging)
end
end
eventHandling_triggerEvent({triggeredByColor=nil,triggerType=eventData.triggerType.productionPhase})
end
function checkEndOfGame()
local soloGameEnd=true
if gameState.isSoloGame then
soloGameEnd=gameState.currentGeneration >= gameState.maxGeneration
end
if globalParameterSystem.values.temperature.isDone then
logging.printToAll("Temperature is Done! Keep going!",{1,1,1},loggingModes.exception)
end
if globalParameterSystem.values.oxygen.isDone then
logging.printToAll("Oxygen is Done! Keep going!",{1,1,1},loggingModes.exception)
end
if oceanEndGameConditionFulfilled() then
logging.printToAll("All oceans placed! Keep going!",{1,1,1},loggingModes.exception)
end
if gameState.venusIsWin and gameState.venus then
if globalParameterSystem.values.venus.isDone then
logging.printToAll("Venus is Done! Keep going!",{1,1,1},loggingModes.exception)
else
logging.broadcastToAll("Remember Venus is a Win Condition!",{1,1,1},loggingModes.exception)
end
return globalParameterSystem.values.temperature.isDone and globalParameterSystem.values.oxygen.isDone and oceanEndGameConditionFulfilled() and globalParameterSystem.values.venus.isDone and soloGameEnd
else
return globalParameterSystem.values.temperature.isDone and globalParameterSystem.values.oxygen.isDone and oceanEndGameConditionFulfilled() and soloGameEnd
end
end
function oceanEndGameConditionFulfilled()
return #getObjectFromGUID(bags.oceanBag).getObjects()==0
end


gameObjectHelpers.findPlaymat=function()
for k,obj in pairs(getAllObjects()) do
if obj.getName()=="PlayMatTile" then
return obj
end
end
logging.broadcastToAll('Playmat not found,report the issue!',{1,0.1,0.1},loggingModes.exception)
end
function increaseTempButtonClick(obj,playerColor)
increaseTemp(playerColor)
end
function decreaseTempButtonClick(obj,playerColor)
decreaseTemp(playerColor)
end
function increaseO2ButtonClick(obj,playerColor)
increaseO2(playerColor)
end
function decreaseO2ButtonClick(obj,playerColor)
decreaseO2(playerColor)
end
function increaseVenusButtonClick(obj,playerColor)
increaseVenus(playerColor)
end
function decreaseVenusButtonClick(obj,playerColor)
decreaseVenus(playerColor)
end
function increaseTRButtonClick(obj,playerColor)
increasePlayerTRByColor(playerColor,"manual button click")
end
function decreaseTRButtonClick(obj,playerColor)
decreasePlayerTRByColor(playerColor,"manual button click")
end
function increaseVenus(playerColor)
globalParameterSystem.changeParameter(globalParameters.venus,globalParameterSystem.values.venus,1,playerColor,eventData.triggerType.venusTerraformed)
end
function decreaseVenus(playerColor)
globalParameterSystem.changeParameter(globalParameters.venus,globalParameterSystem.values.venus,-1,playerColor)
end
function increaseTemp(playerColor)
globalParameterSystem.changeParameter(globalParameters.temperature,globalParameterSystem.values.temperature,1,playerColor)
end
function decreaseTemp(playerColor)
globalParameterSystem.changeParameter(globalParameters.temperature,globalParameterSystem.values.temperature,-1,playerColor)
end
function increaseO2(playerColor)
globalParameterSystem.changeParameter(globalParameters.oxygen,globalParameterSystem.values.oxygen,1,playerColor,eventData.triggerType.oxygenIncreased)
end
function decreaseO2(playerColor)
globalParameterSystem.changeParameter(globalParameters.oxygen,globalParameterSystem.values.oxygen,-1,playerColor)
end
function increaseOcean(playerColor)
globalParameterSystem.changeParameter(globalParameters.ocean,globalParameterSystem.values.ocean,1,playerColor,nil)
end
function decreaseOcean(playerColor)
globalParameterSystem.changeParameter(globalParameters.ocean,globalParameterSystem.values.ocean,-1,playerColor,nil)
end
function changeExtraOcean(delta)
globalParameterSystem.values.ocean.extra=globalParameterSystem.values.ocean.extra + delta
if globalParameterSystem.values.ocean.extra < 0 then
globalParameterSystem.values.ocean.extra=0
end
local extraOceansCounter=gameObjectHelpers.getObjectByName("extraOceansCounter")
extraOceansCounter.setValue(globalParameterSystem.values.ocean.extra)
end
function updateCityCounters()
local extraCities=0
for _,specialCityName in pairs({"capitalCityToken","oceanCityToken","redCity"}) do
if gameObjectHelpers.getObjectByName(specialCityName)~=nil then
extraCities=extraCities + 1
end
end
gameObjectHelpers.getObjectByName("cityCounter").setValue(gameState.citiesOnMars + gameState.citiesInSpace)
gameObjectHelpers.getObjectByName("citiesOnMarsCounter").setValue(gameState.citiesOnMars)
end
function energyStandardProject(obj,color)
local tmPlayer=getPlayerByColor(color)
local creditsNeeded=11
if gameState.extendedScriptingEnabled and tmPlayer.paymentSystemConfig.discounts.permanent["PowerStandardProject"]~=nil then
creditsNeeded=creditsNeeded + tmPlayer.paymentSystemConfig.discounts.permanent["PowerStandardProject"]
end
if getPlayerResource({resourceType="credits",playerColor=color}) >= creditsNeeded then
logging.printToAll(color.." used standard project 'Power Plant'",color,loggingModes.detail)
changePlayerProduction({resourceType="energy",playerColor=color,resourceAmount= 1})
changePlayerResource({resourceType="credits",playerColor=color,resourceAmount= -creditsNeeded})
eventHandling_triggerEvent({triggeredByColor=color,triggerType=eventData.triggerType.standardProjectPowerPlant})
playerActionFuncs.playerHasPerformedAction(color)
end
end
function sellPatentsStandardProject(obj,playerColor)
local effects={}
local resourceValues={Credits=0}
for _,object in pairs(Player[playerColor].getHandObjects()) do
if object.tag=="Card" then
table.insert(effects,"DiscardCard")
resourceValues["Credits"]=resourceValues["Credits"] + 1
end
end
local actionProperties={effects=effects,resourceValues=resourceValues,productionValues={}}
logging.printToAll(playerColor.." used standard project 'Sell Patent'",playerColor,loggingModes.detail)
Global.call("objectActivationSystem_doAction",{
activationEffects=actionProperties,
sourceName="selling patents",
playerColor=playerColor,
object=nil,
})
end
function temperatureStandardProject(obj,color)
if getPlayerResource({resourceType="credits",playerColor=color}) >= 14 and not gameState.temperatureDone then
logging.printToAll(color.." used standard project 'Asteroid'",color,loggingModes.detail)
increaseTempButtonClick(obj,color,nil)
changePlayerResource({resourceType="credits",playerColor=color,resourceAmount= -14})
eventHandling_triggerEvent({triggeredByColor=color,triggerType=eventData.triggerType.standardProjectTemperature})
playerActionFuncs.playerHasPerformedAction(color)
end
end
function oceanStandardProject(obj,color)
if getPlayerResource({resourceType="credits",playerColor=color}) >= 18 and not globalParameterSystem.values.ocean.isDone then
logging.printToAll(color.." used standard project 'Aquifier'",color,loggingModes.detail)
dealOceanToPlayer(getPlayerIndexByColor(color))
changePlayerResource({resourceType="credits",playerColor=color,resourceAmount= -18})
eventHandling_triggerEvent({triggeredByColor=color,triggerType=eventData.triggerType.standardProjectOcean})
playerActionFuncs.playerHasPerformedAction(color)
end
end
function greeneryStandardProject(obj,color)
local tmPlayer=getPlayerByColor(color)
local creditsNeeded=23
if gameState.extendedScriptingEnabled and tmPlayer.paymentSystemConfig.discounts.permanent["GreeneryStandardProject"]~=nil then
creditsNeeded=creditsNeeded + tmPlayer.paymentSystemConfig.discounts.permanent["GreeneryStandardProject"]
end
if getPlayerResource({resourceType="credits",playerColor=color}) >= creditsNeeded then
logging.printToAll(color.." used standard project 'Greenery'",color,loggingModes.detail)
dealGreeneryTileToPlayer(getPlayerIndexByColor(color))
changePlayerResource({resourceType="credits",playerColor=color,resourceAmount= -creditsNeeded})
eventHandling_triggerEvent({triggeredByColor=color,triggerType=eventData.triggerType.standardProjectGreenery})
playerActionFuncs.playerHasPerformedAction(color)
end
end
function cityStandardProject(obj,playerColor)
local tmPlayer=getPlayerByColor(playerColor)
local creditsNeeded=25
if gameState.extendedScriptingEnabled and tmPlayer.paymentSystemConfig.discounts.permanent["CityStandardProject"]~=nil then
creditsNeeded=creditsNeeded + tmPlayer.paymentSystemConfig.discounts.permanent["CityStandardProject"]
end
local isAllowed=buyStandardProject(playerColor,creditsNeeded,"City",{eventData.triggerType.standardProjectCity})
if isAllowed then
dealCityTileToPlayer(getPlayerIndexByColor(playerColor))
changePlayerProduction({resourceType="credits",playerColor=playerColor,resourceAmount=1})
end
end
function venusSp15(obj,playerColor)
if not gameState.activeExpansions.venus then
return
end
local isAllowed=buyStandardProject(playerColor,15,"Air Scrapping",{eventData.triggerType.standardProjectVenus,eventData.triggerType.buyVenusStandardProject})
if isAllowed then
increaseVenusButtonClick(obj,playerColor)
end
end
function coloniesSp17(obj,playerColor)
local isAllowed=buyStandardProject(playerColor,17,"Colony",{eventData.triggerType.standardProjectColony})
if isAllowed then
dealPlayerMarkerToPlayer(getPlayerIndexByColor(playerColor))
end
end
function airScrappingStandardProject(_,playerColor)
venusSp15(nil,playerColor)
end
function colonyStandardProject(_,playerColor)
coloniesSp17(nil,playerColor)
end
function floatingArrayStandardProject(_,playerColor)
local isAllowed=buyStandardProject(playerColor,19,"Floating Array",{eventData.triggerType.buyVenusStandardProject})
if isAllowed then
dealFloatingArrayTileToPlayer(getPlayerIndexByColor(playerColor))
end
end
function gasMineStandardProject(_,playerColor)
local isAllowed=buyStandardProject(playerColor,21,"Gas Mine",{eventData.triggerType.buyVenusStandardProject})
if isAllowed then
dealGasMineTileToPlayer(getPlayerIndexByColor(playerColor))
end
end
function venusHabitatStandardProject(_,playerColor)
local isAllowed=buyStandardProject(playerColor,25,"Cloud City",{eventData.triggerType.buyVenusStandardProject})
if isAllowed then
changePlayerProduction({resourceType="credits",playerColor=playerColor,resourceAmount=1})
dealVenusHabitatTileToPlayer(getPlayerIndexByColor(playerColor))
end
end
function buyStandardProject(playerColor,cost,standardProjectName,customEventTriggerTypes)
if getPlayerResource({resourceType="credits",playerColor=playerColor}) >= cost then
logging.printToAll(playerColor.." used standard project '"..standardProjectName.."'",playerColor,loggingModes.detail)
changePlayerResource({resourceType="credits",playerColor=playerColor,resourceAmount=-cost})
eventHandling_triggerEvent({triggeredByColor=playerColor,triggerType=eventData.triggerType.buyStandardProject})
if customEventTriggerTypes then
for _,trigger in pairs(customEventTriggerTypes) do
eventHandling_triggerEvent({triggeredByColor=playerColor,triggerType=trigger})
end
end
playerActionFuncs.playerHasPerformedAction(color)
return true
else
logging.printToColor("Cannot buy standard project '"..standardProjectName.."''. You need "..cost.." credits.",playerColor,playerColor)
return false
end
end


scoringFunctions={}
scoringFunctions.venusPhaseTwo=function(playerColor)
if venusMap==nil then
return 0
end
local vpCount=0
for i,jkMatrix in pairs(venusMap.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
if tile.tileObjects~=nil then
for _,tileObject in pairs(tile.tileObjects) do
if tileObject.owner==playerColor then
local objectName=tileObject.objectName
if objectName=="venusHabitat" or objectName=="gasMine" then
for _,neighbourTile in pairs(hexMapHelpers.getNeighboursFromIndices(venusMap,{i,j,k})) do
if neighbourTile.tileObjects~=nil then
for _,neighbourTileObject in pairs(neighbourTile.tileObjects) do
if neighbourTileObject.objectName=="floatingArray" then
vpCount=vpCount + 1
end
end
end
end
end
end
end
end
end
end
end
return vpCount
end
scoringFunctions.timer=function(player)
if gameState.timerConfiguration.timeoutAction~="giveNegativeVPs" or player.neutral then return 0 end
local timeToConsider=player.timer.time - gameState.timerConfiguration.negativeVpThreshold
if timeToConsider > 0 then
return 0
end
return math.ceil(timeToConsider/gameState.timerConfiguration.secondsPerNegativeVp)
end
scoringFunctions.pathfinder=function(playerColor)
if not gameState.activeExpansions.pathfinders then
return 0
end
local vpCount=0
local pathfinderBoard=gameObjectHelpers.getObjectByName("pathfinderBoard")
for _,trackId in pairs({"Mars","Venus","Earth","Jovian"}) do
if pathfinderBoard.call("hasReachedVpThreshold",trackId) then
local maxValue=0
for _,player in pairs(gameState.allPlayers) do
if not player.neutral then
if player.tagSystem.tagCounts[trackId] > maxValue then
maxValue=player.tagSystem.tagCounts[trackId]
end
end
end
if getPlayerByColor(playerColor).tagSystem.tagCounts[trackId]==maxValue then
vpCount=vpCount + pathfinderBoard.call("getVPFromTrack",trackId)
end
end
end
return vpCount
end
function calculateGreeneryScoreForPlayer(player_color)
local greeneryVPCount=0
for i,jkMatrix in pairs(gameMap.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
if tile.tileObjects~=nil then
for _,tileObject in pairs(tile.tileObjects) do
if (tileObject.objectName=="greenery" or tileObject.objectName=="wetlands") and player_color==tileObject.owner then
greeneryVPCount=greeneryVPCount + 1
end
end
end
end
end
end
return greeneryVPCount
end
function calculateCityScoreForPlayer(player_color)
local cityVPCount=0
for i,jkMatrix in pairs(gameMap.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
if tile.tileObjects~=nil then
for _,tileObject in pairs(tile.tileObjects) do
if tileObject.owner==player_color then
local objectName=tileObject.objectName
if objectName=="cityTile" or objectName=="newVenice" or objectName=="capitalCity" then
for _,neighbourTile in pairs(hexMapHelpers.getNeighboursFromIndices(gameMap,{i,j,k})) do
if neighbourTile.tileObjects~=nil then
for _,neighbourTileObject in pairs(neighbourTile.tileObjects) do
if neighbourTileObject.objectName=="greenery" then
cityVPCount=cityVPCount + 1
elseif objectName~="capitalCity" and neighbourTileObject.objectName=="wetlands" then
cityVPCount=cityVPCount + 1
end
end
end
end
end
end
end
end
end
end
end
return cityVPCount
end
function vpsForSpecialTiles(playerColor)
local specialTilesVPs=0
for i,jkMatrix in pairs(gameMap.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
if tile.tileObjects~=nil then
for _,tileObject in pairs(tile.tileObjects) do
if tileObject.objectName=="commercialDistrict" and playerColor==tileObject.owner then
for _,neighbourTile in pairs(hexMapHelpers.getNeighboursFromIndices(gameMap,{i,j,k})) do
local objectNamesCounting={cityTile="cityTile",redCity="redCity",capitalCity="capitalCity",newVenice="newVenice"}
if neighbourTile.tileObjects~=nil then
for _,neighbourTileObject in pairs(neighbourTile.tileObjects) do
if objectNamesCounting[neighbourTileObject.objectName]~=nil then
specialTilesVPs=specialTilesVPs + 1
end
end
end
end
elseif tileObject.objectName=="redCity" and playerColor==tileObject.owner then
for _,neighbourTile in pairs(hexMapHelpers.getNeighboursFromIndices(gameMap,{i,j,k})) do
if neighbourTile.tileObjects==nil or next(neighbourTile.tileObjects)==nil then
specialTilesVPs=specialTilesVPs + 1
end
end
elseif tileObject.objectName=="capitalCity" and playerColor==tileObject.owner then
for _,neighbourTile in pairs(hexMapHelpers.getNeighboursFromIndices(gameMap,{i,j,k})) do
if neighbourTile.tileObjects~=nil then
for _,neighbourTileObject in pairs(neighbourTile.tileObjects) do
if neighbourTileObject.objectName=="ocean" or neighbourTileObject.objectName=="wetlands" then
specialTilesVPs=specialTilesVPs + 1
end
end
end
end
end
end
end
end
end
end
return specialTilesVPs
end
function calculateMilestones(playerColor)
local scoreCount=0
for _,claimedMilestone in pairs(gameState.claimedMilestones) do
if claimedMilestone.owner==playerColor then
scoreCount=scoreCount + 5
end
end
return scoreCount
end
function calculateAwards(playerColor)
local playerColorsAndVps=awardScoring.calculateAllPlayerAwardScores()
return playerColorsAndVps[playerColor] or 0
end
function calculateDelegateVPs(playerColor)
local scoreCount=0
local chairman=getChairman()
if playerColor==chairman.getDescription() then
scoreCount=scoreCount + 1
end
for _,partyInfo in pairs(gameState.turmoilData.parties) do
if getPartyLeadColor(partyInfo)==playerColor then
scoreCount=scoreCount + 1
end
if getPartyLeadColor(partyInfo)==nil then
Wait.time(|| logging.broadcastToColor("Warning: Ignoring party "..partyInfo.partyId.." for VP counting. No delegates (or party leader) present.",playerColor,{1,0.4,0,1},loggingModes.exception),2)
end
end
return scoreCount
end
function calculateCardsAndEventsForPlayer(tmPlayer)
local scoreCount=tmPlayer.victoryPoints.simple
for _,vpDefinition in pairs(tmPlayer.victoryPoints.complex) do
local resolvedFormula=resolveVictoryPointsFormula(vpDefinition.victoryPointsFormula)
scoreCount=scoreCount + vpsFromCounters(resolvedFormula,vpDefinition.victoryPointsSourceGuid,vpDefinition.sourceFriendlyName,tmPlayer.color)
scoreCount=scoreCount + vpsFromCities(resolvedFormula,tmPlayer.color)
scoreCount=scoreCount + vpsFromColonies(resolvedFormula,tmPlayer.color)
scoreCount=scoreCount + vpsFromTags(resolvedFormula,tmPlayer.tagSystem.tagCounts)
end
scoreCount=scoreCount + vpsForSpecialTiles(tmPlayer.color)
return scoreCount
end
function resolveVictoryPointsFormula(input)
local subStrings={}
for subString in string.gmatch(input,"[0-9]") do
table.insert(subStrings,subString)
end
for subString in string.gmatch(input,"[^0-9]+") do
if subString~="Per" then
table.insert(subStrings,subString)
end
end
return subStrings
end
function vpsFromCounters(resolvedFormula,sourceGuid,sourceFriendlyName,playerColor)
if resolvedFormula[3]~="Counter" and resolvedFormula[3]~="Counters" then
return 0
end
local card=getObjectFromGUID(sourceGuid)
if card==nil then
broadcastToAll(playerColor.." did not get any victory points for counter based card '"..sourceFriendlyName.."'. Card is probably hidden in a stack. Search for the card and place it somewhere on the board to resolve this issue.",playerColor)
return 0
end
local cardState=card.getVar("cardState")
local vpCounterCount=0
if card.getVar("getVpCounterCount")~=nil then
vpCounterCount=card.call("getVpCounterCount")
elseif cardState.counters~=nil or cardState.counters[1]~=nil then
vpCounterCount=cardState.counters[1]
end
return math.floor(resolvedFormula[1] * vpCounterCount / resolvedFormula[2])
end
function vpsFromCities(resolvedFormula,playerColor)
if resolvedFormula[3]~="Cities" and resolvedFormula[3]~="CityTile" then
return 0
end
local allCities=Global.call("getOwnableObjectCount",{
ownableObjectName=ownableObjects.baseGame.tiles.city,
playerColor=playerColor,
cardName="",
who="allPlayers"}
)
return math.floor(resolvedFormula[1] * allCities / resolvedFormula[2])
end
function vpsFromColonies(resolvedFormula,playerColor)
if resolvedFormula[3]~="Colonies" and resolvedFormula[3]~="Colony" then
return 0
end
local allColonies=Global.call("getOwnableObjectCount",{
ownableObjectName=ownableObjects.colonies.objects.colony,
playerColor=playerColor,
cardName="",
who="allPlayers"}
)
return math.floor(resolvedFormula[1] * allColonies / resolvedFormula[2])
end
function vpsFromTags(resolvedFormula,tagCounts)
for tag,count in pairs(tagCounts) do
if tag==resolvedFormula[3] then
return math.floor(resolvedFormula[1] * count / resolvedFormula[2])
end
end
return 0
end
function showScoreBoards()
function cloneScoreBoardCoroutine()
for playerIndex,player in pairs(gameState.allPlayers) do
if not player.neutral then
local playerMat=getObjectFromGUID(player.playerArea.playerMat)
local targetTransform=tableHelpers.deepClone(playerMat.call("getScoreBoardTransform"))
local object=gameObjectHelpers.getObjectByName("genericScoreBoard")
newObject=object.clone()
newObject.lock()
while(object.getGUID()==newObject.getGUID()) do
coroutine.yield(0)
end
for i=1,5 do
coroutine.yield(0)
end
player.playerArea.statsBoard=newObject.getGUID()
newObject.setPositionSmooth(targetTransform.pos,false,false)
newObject.setRotation(targetTransform.rot)
newObject.call("setOwner",player.color)
if gameState.extendedScriptingEnabled and not player.neutral then
newObject.call("registerEventHandlers")
end
for i=1,5 do coroutine.yield(0) end
newObject.call("toggleHidden")
for i=1,5 do coroutine.yield(0) end
newObject.call("setPlayerIndex",playerIndex)
updatePlayerStats(playerIndex)
end
end
return 1
end
startLuaCoroutine(self,"cloneScoreBoardCoroutine")
if gameState.extendedScriptingEnabled then
local vpMessages={
"------------------- Victory Points -------------------",
"Victory points that have to counted manually:",
}
if gameState.turmoil then
table.insert(vpMessages," - 'Law Suit' event card. Does not give any negative points.")
end
if gameState.activeExpansions.xenosCorps then
table.insert(vpMessages," - PuR & KLEEN - manually count victory points for adjacency victory points for oceans")
end
if #vpMessages~=2 then
for index,message in pairs(vpMessages) do
Wait.time(|| broadcastToAll(message,{0.9,0.5,0,1}),index * 2)
end
end
end
end
function updatePlayerStats(playerIndex)
local player=gameState.allPlayers[playerIndex]
for _,objName in pairs({"statsBoard","personalScoreBoard"}) do
local statsBoard=getObjectFromGUID(player.playerArea[objName])
if statsBoard~=nil then
statsBoard.call("setTRValue",player.terraformingRating)
statsBoard.call("setCityValue",calculateCityScoreForPlayer(player.color))
statsBoard.call("setGreeneryValue",calculateGreeneryScoreForPlayer(player.color))
statsBoard.call("setPathfinder",scoringFunctions.pathfinder(player.color))
statsBoard.call("setTimer",scoringFunctions.timer(player))
statsBoard.call("setVenusPhaseTwo",scoringFunctions.venusPhaseTwo(player.color))
statsBoard.call("setCardsAndEvents",calculateCardsAndEventsForPlayer(player))
statsBoard.call("setMilestoneVPs",calculateMilestones(player.color))
statsBoard.call("setAwardsVPs",calculateAwards(player.color))
if gameState.turmoil then
statsBoard.call("setDelegates",calculateDelegateVPs(player.color))
end
if objName=="personalScoreBoard" then
local blueCardsCount=#player.ownedCards.Blue
local greenCardsCount=#player.ownedCards.Green
local infrastructureCardsCount=#player.ownedCards.Infrastructure
local eventCardsCount=#player.ownedCards.Event
local costyCards=findCostyCards(player,20)
statsBoard.call("updatePlayedCards",{
blueCardsCount=blueCardsCount,
greenCardsCount=greenCardsCount,
eventCardsCount=eventCardsCount,
costyCards=costyCards,
totalCardsPlayed=blueCardsCount + greenCardsCount + eventCardsCount + infrastructureCardsCount
})
end
end
end
end
function findCostyCards(player,cost)
local amount=0
local cardsToConsider=tableHelpers.combineSingleValueTables({player.ownedCards["Blue"],player.ownedCards["Green"]})
for _,card in pairs(cardsToConsider) do
local cardObject=getObjectFromGUID(card.guid)
if cardObject==nil then
printToColor("Card "..card.name.." didn't get considered for the "..awardName.." award - card is probably in a stack.",player.color,player.color)
else
local baseCost=getBaseCost(cardObject.getDescription())
if baseCost~=nil and baseCost.value >= cost then
amount=amount + 1
end
end
end
return amount
end
function updatePlayerStatsByColor(playerColor)
local playerIndex=getPlayerIndexByColor(playerColor)
updatePlayerStats(playerIndex)
end


function updateCubePositionsOnTerraformingBar()
cubesAtPosition={}
cubesAtPosition[gameState.currentGeneration]=1
positionCubeRaw(gameObjectHelpers.getObjectByName("generationMarker"),gameState.currentGeneration,1)
for i,player in pairs(gameState.allPlayers) do
if cubesAtPosition[player.terraformingRating]~=nil then
cubesAtPosition[player.terraformingRating]=cubesAtPosition[player.terraformingRating] + 1
else
cubesAtPosition[player.terraformingRating]=1
end
if player.playerArea.trCube~=nil then
positionCubeRaw(getObjectFromGUID(player.playerArea.trCube),player.terraformingRating,cubesAtPosition[player.terraformingRating])
end
end
end
function positionCubeRaw(marker,value,height)
if marker==nil then
return
end
marker.setRotation({0,0,0})
local p=computePosition(value,height)
marker.setPositionSmooth(p)
end
function computePosition(inputValue,height)
local moddedValue=inputValue % 170
local blc=tablePositions.gameBoardAssets.trTrackPositions.bottomLeftCorner
local tlc=tablePositions.gameBoardAssets.trTrackPositions.topLeftCorner
local trc=tablePositions.gameBoardAssets.trTrackPositions.topRightCorner
local brc=tablePositions.gameBoardAssets.trTrackPositions.bottomRightCorner
if moddedValue <= 35 then
return {blc[1],blc[2] + height - 1,blc[3] + (moddedValue * (tlc[3] - blc[3])/35)}
elseif moddedValue <= 85 then
return {tlc[1] + ((moddedValue - 35) * (trc[1] - tlc[1])/50),tlc[2] + height - 1,tlc[3]}
elseif moddedValue <= 120 then
return {trc[1],trc[2] + height - 1,trc[3] + ((moddedValue - 85) * (brc[3] - trc[3])/35)}
elseif moddedValue <= 170 then
return {brc[1] + ((moddedValue - 120) * (blc[1] - brc[1])/50),brc[2] + height - 1,brc[3]}
end
return blc
end



tagToResourceConversionAllowedMap={
Building="Steel",
Space="Titanium",
Infrastructure="Titanium",
}
paymentSystemConfig={}
function paymentSystemConfig:new(icons)
local obj={}
obj.discounts={permanent=createDefaultDiscountTable(icons),transient={}}
obj.baseConversionRates={Steel=2,Titanium=3,HeatToTemp=8,PlantsToGreenery=8}
obj.conversionRates={Steel=2,Titanium=3,HeatToTemp=8,PlantsToGreenery=8}
obj.paymentDistribution={Credits=0,Steel=0,Titanium=0}
obj.conversionsAllowed={Steel=false,Titanium=false}
obj.overpayedCredits=0
obj.resourceExtensions={}
obj.cardActivationInProgress=false
obj.currentObjectGuid=""
return obj
end
function createDefaultDiscountTable(icons)
local discounts={}
for _,icon in ipairs(icons) do
discounts[icon]=0
end
return discounts
end


tagSystem={}
function tagSystem:new(icons)
local obj={}
obj.tagCounts=createDefaultTagCounts(icons)
return obj
end
function createDefaultTagCounts(icons)
local tagCounts={}
for _,tag in ipairs(icons) do
tagCounts[tag]=0
end
return tagCounts
end
function tagSystem_updatePlayerTag(params)
local tmPlayer=getPlayerByColor(params.playerColor)
tagSystem.updateTagCount(tmPlayer,params.tag,params.delta)
end
function tagSystem_updatePlayerTags(params)
local tmPlayer=getPlayerByColor(params.playerColor)
for tag,delta in pairs(params.tagsAndDelta) do
tagSystem.updateTagCount(tmPlayer,tag,delta)
end
end
tagSystem.updateTagCount=function(tmPlayer,tag,delta)
if tmPlayer.tagSystem.tagCounts[tag]==nil then
logging.broadcastToAll("Initializing a new tag: '"..tag.."'. This tag may not be fully supported or should be a different one. Check the last activated card description when in doubt.",{1,1,1,1},loggingModes.detail)
tmPlayer.tagSystem.tagCounts[tag]=0
end
local oldCount=tmPlayer.tagSystem.tagCounts[tag]
tmPlayer.tagSystem.tagCounts[tag]=tmPlayer.tagSystem.tagCounts[tag] + delta
if delta~=0 then
log(tmPlayer.color.."'s tag count for '"..tag.."' changed: "..oldCount.." -> "..tmPlayer.tagSystem.tagCounts[tag])
end
for _,iconTableauGuid in pairs(tmPlayer.playerArea.iconTableaus) do
local iconTableau=getObjectFromGUID(iconTableauGuid)
if iconTableau~=nil then
iconTableau.call("updateTagCountsDisplay",tmPlayer.tagSystem.tagCounts)
end
end
end


objectActivationSystemConfig={}
function objectActivationSystemConfig:new(rules)
local obj={}
obj.rules=rules
obj.ignoreRequirements=false
obj.lastActivationObjectGuid=""
obj.currentObjectGuid=""
return obj
end


cardActivationRules={}
cardActivationRules.rules={}
cardActivationRules.rules.inActivationZoneRule=function(tmPlayer,card)
if tmPlayer.playerArea.activationTableau==nil then
return true
end
local tableauObjectState=getObjectFromGUID(tmPlayer.playerArea.activationTableau).getVar("objectState")
if tableauObjectState.lastEnteredObjectGuid~=card.getGUID() then
logging.printToColor("Cannot activate card "..card.getName()..". It is not in the Activate slot.",tmPlayer.color,colors.messageColors.importantInfo,loggingModes.detail)
return false
end
return true
end
cardActivationRules.rules.notInAnyHandZoneRule=function(tmPlayer,card)
for i,playerColor in ipairs(getSeatedPlayers()) do
local player=Player[playerColor]
for j=1,player.getHandCount() do
for _,object in ipairs(player.getHandObjects(j)) do
if (card==object) then
logging.printToColor("You cannot activate cards in a player's hand.",tmPlayer.color,colors.messageColors.importantInfo,loggingModes.detail)
return false
end
end
end
end
return true
end
cardActivationRules.rules.isActivePlayerRule=function(tmPlayer,card)
local isActivePlayer=true
if (gameState.currentPlayer==-1) then
isActivePlayer=false
else
isActivePlayer=gameState.allPlayers[gameState.currentPlayer]==tmPlayer
end
if not isActivePlayer then
logging.printToColor("You cannot activate "..card.getName().." as you are not the active player.",tmPlayer.color,colors.messageColors.importantInfo,loggingModes.detail)
end
return isActivePlayer
end
cardActivationRules.rules.ignoreRequirements=function(tmPlayer,card)
tmPlayer.objectActivationSystemConfig.ignoreRequirements=true
return true
end
cardActivationRules.configurations={}
cardActivationRules.configurations.allRules={
"inActivationZoneRule",
"isActivePlayerRule"
}
cardActivationRules.configurations.noRules={
"ignoreRequirements"
}
cardActivationRules.configurations.permanentRules={
"notInAnyHandZoneRule"
}


playerActionFuncs={}
playerActionFuncs.playerHasPerformedAction=function(playerColor)
if getPlayerIndexByColor(playerColor)~=gameState.currentPlayer then
return
end
log("Doing action")
local player=getPlayerByColor(playerColor)
player.playerActions.actionsDone=player.playerActions.actionsDone + 1
if player.playerActions.actionsDone < player.playerActions.actionsLimit or transientState.autoPassData.inProgress then
return
end
playerActionFuncs.decideOnEndTurn(player)
eventHandling_triggerEvent({
triggeredByColor=playerColor,
triggerType=eventData.triggerType.playerPerformedAction,
metadata={}
})
end
playerActionFuncs.decideOnEndTurn=function(player)
if gameState.currentPhase~=phases.generationPhase then
player.playerActions.actionsDone=0
return
end
local activePlayers=0
for _,player in pairs(gameState.allPlayers) do
if not player.hasPassedGeneration and not player.neutral then
activePlayers=activePlayers + 1
end
end
if activePlayers < 2 then
return
end
for funcName,funcDef in pairs(playerActionFuncs.autoPassFunctions) do
if funcDef.id==player.playerActions.onLimitReached then
function autoPassCoroutine()
local counter=5
transientState.autoPassData.inProgress=true
while counter > 0 do
counter=counter - 1
if dealingObjectInProgress then
counter=45
end
coroutine.yield(0)
end
local doEndTurn=funcDef.func(player.color,Player[player.color].getHandObjects())
if doEndTurn then
endTurn()
transientState.autoPassData.watchdogActive=false
end
transientState.autoPassData.inProgress=false
return 1
end
startLuaCoroutine(self,"autoPassCoroutine")
return
end
end
end
playerActionFuncs.autoPassFunctions={}
playerActionFuncs.autoPassFunctions.inactive={id="inactive",
prettyName="Auto End Turn:\nInactive",
help="Automatic end turn after two actions is disabled.",
func=function(playerColor,handObjects)
transientState.autoPassData.watchdogActive=false
return false
end
}
playerActionFuncs.autoPassFunctions.emptyHand={id="emptyHand",
prettyName="Auto End Turn:\nIf Hand Empty",
help="Automatic end turn after two actions is enabled.\n\n"..
"Pass automatically if you have no cards,tiles,delegates and tokens in hand."..
"Otherwise you will pass automatically as soon as you have placed all tiles,delegates,"..
"used up any tokens and moved all cards from your main hand zone to another hand zone.",
func=function(playerColor,handObjects)
return playerActionFuncs.autoPassFunctions.actionsFinalized.func(playerColor,handObjects) and #handObjects==0
end
}
playerActionFuncs.autoPassFunctions.actionsFinalized={id="actionsFinalized",
prettyName="Auto End Turn:\nNo Important Objects In Hand",
help="Automatic end turn after two actions is enabled.\n\n"..
"Pass automatically if you have no tiles,delegates and trade/action tokens in hand."..
"Otherwise you will pass automatically as soon as you have placed all tiles,delegates and "..
"used up any trade or action tokens. Card resource tokens (e.g. Floaters) and cards in your main hand are ignored.",
func=function(playerColor,handObjects)
transientState.autoPassData.watchdogActive=true
for _,obj in pairs(handObjects) do
if obj.getVar("activateObject")~=nil then
if transientState.autoPassData.tilesToPlace[obj.getGUID()]==nil then
transientState.autoPassData.tilesToPlace[obj.getGUID()]=1
end
end
end
local allTilesPlaced=true
for guid,value in pairs(transientState.autoPassData.tilesToPlace) do
if value==1 then
allTilesPlaced=false
end
end
if allTilesPlaced then
transientState.autoPassData.tilesToPlace={}
else
return false
end
local handObjects=Player["White"].getHandObjects()
for _,obj in pairs(handObjects) do
if obj.getDescription()=="Cube" then
return false
elseif obj.getDescription()=="Delegate" then
return false
elseif obj.getVar("initializeWithMetdata")~=nil then
return false
end
end
return true
end
}
playerActionFuncs.playerHasPlacedTile=function(playerColor,tileObjectGuid)
if transientState.autoPassData.tilesToPlace[tileObjectGuid]~=nil then
transientState.autoPassData.tilesToPlace[tileObjectGuid]=0
playerActionFuncs.decideOnEndTurn(getPlayerByColor(playerColor))
end
end
playerActionFuncs.playerHasTraded=function(playerColor)
playerActionFuncs.decideOnEndTurn(getPlayerByColor(playerColor))
end
playerActionFuncs.playerHasMovedObjectFromHand=function(playerColor)
playerActionFuncs.decideOnEndTurn(getPlayerByColor(playerColor))
end
playerActionFuncs.playerHasPlacedDelegate=function(playerColor)
playerActionFuncs.decideOnEndTurn(getPlayerByColor(playerColor))
end
function onObjectLeaveZone(zone,leave_object)
if not transientState.autoPassData.watchdogActive then
return
end
local playerColor=gameState.allPlayers[gameState.currentPlayer].color
if #Player[playerColor].getHandObjects()==0 then
transientState.autoPassData.watchdogActive=false
Wait.condition(function()
Wait.frames(|| playerActionFuncs.decideOnEndTurn(getPlayerByColor(playerColor)),40)
end,
function () return leave_object.held_by_color~=playerColor end)
end
end
function playerActionFuncs_toggleAutoPassOption(params)
local player=getPlayerByColor(params.playerColor)
local delta=params.delta
local playerMat=getObjectFromGUID(player.playerArea.playerMat)
local counter=1
for funcName,funcDef in pairs(playerActionFuncs.autoPassFunctions) do
if funcDef.id==player.playerActions.onLimitReached then
break
end
counter=counter + 1
end
counter=counter + delta
if counter > tableHelpers.getCount(playerActionFuncs.autoPassFunctions) then
counter=1
elseif counter < 1 then
counter=tableHelpers.getCount(playerActionFuncs.autoPassFunctions)
end
local i=1
for funcName,funcDef in pairs(playerActionFuncs.autoPassFunctions) do
if i==counter then
player.playerActions.onLimitReached=funcDef.id
playerMat.call("updateAutoPassOption",{label=funcDef.prettyName,help=funcDef.help})
return
end
i=i + 1
end
end

TMPlayer={}
function TMPlayer:new(color,tr,isNeutralPlayer)
local obj={}
obj.neutral=isNeutralPlayer or false
obj.color=color
obj.terraformingRating=tr
obj.name=""
obj.hasDraftPassed=false
obj.hasPassedGeneration=false
obj.ownedObjects=createOwnableObjectsCollection()
obj.paymentSystemConfig=paymentSystemConfig:new(tableHelpers.combineSingleValueTables({icons.baseIconNames,icons.specialIconNames,icons.anyTagNames}))
obj.tagSystem=tagSystem:new(tableHelpers.combineSingleValueTables({icons.baseIconNames,icons.specialIconNames}))
obj.objectActivationSystemConfig=objectActivationSystemConfig:new(cardActivationRules.configurations.noRules)
obj.reqModifiers={permanent={},transient={}}
obj.turmoilInfluence={baseInfluence=0,transientInfluence=0}
obj.delegateIds={}
obj.delegateBagId=nil
obj.victoryPoints={simple=0,complex={}}
obj.ownedCards={Blue={},Event={},Green={},Other={},Corp={},Prelude={},Infrastructure={}}
obj.drafting={purchaseCardCost=3,extraDraftCardsDealt=0}
obj.colonyTradingConfig={tradingCostModifier=0,tradingRewardModifier=0}
obj.wasUpdated=true
obj.playerActions={actionsDone=0,actionsLimit=2,onLimitReached=playerActionFuncs.autoPassFunctions.inactive.id}
obj.playerArea={}
return obj
end
function changePlayerBaseInfluence(params)
local tmPlayer=getPlayerByColor(params.playerColor)
tmPlayer.turmoilInfluence.baseInfluence=tmPlayer.turmoilInfluence.baseInfluence + params.delta
tmPlayer.wasUpdated=true
end
function overrideDraftingConfig(params)
local tmPlayer=getPlayerByColor(params.playerColor)
for key,value in pairs(params.overrides) do
if tmPlayer.drafting[key]~=nil then
tmPlayer.drafting[key]=value
end
end
tmPlayer.wasUpdated=true
end
function changeOwnedObjectAmount(color,key,delta)
local tmPlayer=getPlayerByColor(color)
if tmPlayer==nil then
return
end
if tmPlayer.ownedObjects[key]==nil then
tmPlayer.ownedObjects[key]=0
end
tmPlayer.ownedObjects[key]=tmPlayer.ownedObjects[key] + delta
tmPlayer.wasUpdated=true
end
function getOwnedObjectAmount(color,key)
local tmPlayer=gameState.allPlayers[color]
if tmPlayer.ownedObjects[key]==nil then
tmPlayer.ownedObjects[key]=0
end
return tmPlayer.ownedObjects[key]
end
function createOrUpdatePlayerColors()
if gameState.started then
return
end
log("Creating or Updating Player")
local playerIndicesToRemove={}
for i=0,gameState.numberOfPlayers - 1 do
local playerUnderScrutiny= gameState.allPlayers[gameState.numberOfPlayers - i]
if Player[playerUnderScrutiny.color]==nil or not Player[playerUnderScrutiny.color].seated then
table.insert(playerIndicesToRemove,gameState.numberOfPlayers - i)
end
end
for i=1,#playerIndicesToRemove do
removePlayerFromGame(playerIndicesToRemove[i])
end
local allSeatedPlayers=Player.getPlayers()
for _,player in pairs(allSeatedPlayers) do
local player_color=player.color
if isSupportedColor(player_color) then
if not isColorPlaying(player_color) then
createPlayerInGame(player_color)
end
end
end
end
function removePlayerFromGame(playerIndex)
local player=gameState.allPlayers[playerIndex]
function removePlayerCoroutine()
log("Removing player - waiting...")
local wait=true
local waitCounter=10
while wait or waitCounter > 0 do
wait=false
if cloningOngoing or transientState.removingPlayer then
wait=true
else
for _,isOngoing in pairs(cloningOngoingTable) do
if isOngoing==true then
wait=true
end
end
end
if wait==false then
waitCounter=waitCounter - 1
else
waitCounter=10
end
coroutine.yield(0)
end
transientState.removingPlayer=true
log("Removing player")
gameObjectHelpers.removeObjGracefully(player.playerArea.playerMat)
if player.playerArea.iconTableaus then
for _,iconTableau in pairs(player.playerArea.iconTableaus) do
getObjectFromGUID(iconTableau).destruct()
end
end
gameObjectHelpers.removeObjGracefully(player.playerArea.activationTableau)
gameObjectHelpers.removeObjGracefully(player.playerArea.playerOrgHelpBoard)
gameObjectHelpers.removeObjGracefully(player.playerArea.playerAntiLagBoard)
gameObjectHelpers.removeObjGracefully(player.playerArea.trCube)
local updatedPlayerIndex=getPlayerIndexByColor(player.color)
table.remove(gameState.allPlayers,updatedPlayerIndex)
gameState.numberOfPlayers=gameState.numberOfPlayers - 1
coroutine.yield(0)
transientState.removingPlayer=false
return 1
end
startLuaCoroutine(self,"removePlayerCoroutine")
end
function createPlayerInGame(playerColor,isNeutralPlayer)
function createPlayerInGameCoroutine()
while transientState.creatingPlayer do coroutine.yield(0) end
transientState.creatingPlayer=true
local waitCounter=0
while waitCounter < 15 do
waitCounter=waitCounter + 1
if transientState.removingPlayer then
waitCounter=0
end
coroutine.yield(0)
end
gameStateFunctions.addPlayer(playerColor,isNeutralPlayer)
local player=getPlayerByColor(playerColor)
createMaterial(player)
transientState.creatingPlayer=false
return 1
end
startLuaCoroutine(self,"createPlayerInGameCoroutine")
end
function createMaterial(player)
function createMaterialCoroutine()
local waitCounter=0
while waitCounter < 15 do
waitCounter=waitCounter + 1
if transientState.removingPlayer then
waitCounter=0
end
coroutine.yield(0)
end
createPlayerBoard(player)
createTRCube(player)
for i=1,60 do coroutine.yield(0) end
createActivationTableau(player)
coroutine.yield(0)
createIconTableaus(player)
toggleOrg(player.color)
for i=1,10 do coroutine.yield(0) end
return 1
end
startLuaCoroutine(self,"createMaterialCoroutine")
end
function changeFirstPlayerRemotely(params)
changeFirstPlayer(params.playerColor)
end
function changeFirstPlayer(playerColor)
local token=gameObjectHelpers.getObjectByName("firstPlayerToken")
local nextFirstPlayer=getPlayerIndexByColor(playerColor)
gameState.firstPlayer=nextFirstPlayer
gameState.currentPlayer=nextFirstPlayer
local transform=tableHelpers.deepClone(getObjectFromGUID(getPlayerByColor(playerColor).playerArea.playerMat).call("getFirstPlayerMarkerTransform"))
token.setPositionSmooth(transform.pos)
token.setRotationSmooth(transform.rot)
logging.broadcastToAll('First player is ' .. gameState.allPlayers[gameState.firstPlayer].name,playerColor,loggingModes.important)
gameState.allPlayers[gameState.firstPlayer].wasUpdated=true
notifyCurrentPlayer()
updatePlayerUI()
end
function passFirstPlayer()
local nextFirstPlayer=(gameState.firstPlayer + 1)
if gameState.forcedNextFirstPlayer~=nil then
nextFirstPlayer=gameState.forcedNextFirstPlayer
gameState.forcedNextFirstPlayer=nil
end
if nextFirstPlayer > gameState.numberOfPlayers then
nextFirstPlayer=nextFirstPlayer - gameState.numberOfPlayers
end
local exitCriteria=0
while not Player[gameState.allPlayers[nextFirstPlayer].color].seated and exitCriteria < 10 do
nextFirstPlayer=nextFirstPlayer + 1
if nextFirstPlayer > gameState.numberOfPlayers then
nextFirstPlayer=nextFirstPlayer - gameState.numberOfPlayers
end
exitCriteria=exitCriteria + 1
end
if not gameState.allPlayers[nextFirstPlayer].neutral then
changeFirstPlayer(gameState.allPlayers[nextFirstPlayer].color)
else
changeFirstPlayer(gameState.allPlayers[gameState.firstPlayer].color)
end
end
function notifyCurrentPlayer()
Turns.turn_color=gameState.allPlayers[gameState.currentPlayer].color
Turns.enable=false
end
function sanitizeName(name)
return (name:gsub("[<>]",""))
end
function updatePlayerUI()
for i=1,#uiNames.playerNames do
UI.setAttribute(uiNames.playerNames[i],"active",false)
end
for i=1,gameState.numberOfPlayers do
if not Player[gameState.allPlayers[i].color].seated then
gameState.allPlayers[i].name="Disconnected"
else
gameState.allPlayers[i].name=sanitizeName(Player[gameState.allPlayers[i].color].steam_name)
end
if gameState.started then
if i==gameState.currentPlayer and gameState.currentPhase~=phases.gameStartPhase then
UI.setAttribute(uiNames.activePlayerIndicator[i],"active",true)
UI.setAttribute(uiNames.endTurnButtons[gameState.allPlayers[i].color],"active",true)
else
UI.setAttribute(uiNames.activePlayerIndicator[i],"active",false)
UI.setAttribute(uiNames.endTurnButtons[gameState.allPlayers[i].color],"active",false)
end
end
updatePlayerName(i)
end
if gameState.started and gameState.currentPhase==phases.gameStartPhase or gameState.currentPhase==phases.draftingPhase then
UI.setAttribute(uiNames.genStart,"active",true)
UI.setAttribute(uiNames.genStart,"visibility",gameState.allPlayers[gameState.firstPlayer].color)
else
UI.setAttribute(uiNames.genStart,"active",false)
end
if gameState.started then
if gameState.currentPlayer==-1 and not gameState.ended then
UI.setAttribute(uiNames.solarPhase,"active",true)
UI.setAttribute(uiNames.solarPhase,"visibility",gameState.allPlayers[gameState.firstPlayer].color)
else
UI.setAttribute(uiNames.solarPhase,"active",false)
end
end
end
function updatePlayerName(playerIndex)
local uiElement=UI.getValue(uiNames.playerNames[playerIndex])
local player=gameState.allPlayers[playerIndex]
if player.neutral then
return
end
UI.setAttribute(uiNames.playerNames[playerIndex],"active",true)
local mainUIName=player.name
if gameState.activeExpansions.timer then
local remainingTime=timerFunctions.getFormattedRemainingTimeForPlayer(gameState.allPlayers[playerIndex])
mainUIName=mainUIName.." "..remainingTime
end
UI.setValue(uiNames.playerNames[playerIndex],mainUIName)
if player.hasPassedGeneration then
UI.setAttribute(uiNames.playerNames[playerIndex],"color","Gray")
else
UI.setAttribute(uiNames.playerNames[playerIndex],"color",player.color)
end
if string.len(mainUIName) >= 20 then
UI.setAttribute(uiNames.playerNames[playerIndex],"fontSize",16)
end
local playerMat=getObjectFromGUID(player.playerArea.playerMat)
if playerMat~=nil then
playerMat.call("setPlayerName",player.name)
end
end
function getPlayerIndexByColor(playerColor)
for i=1,gameState.numberOfPlayers do
if gameState.allPlayers[i].color==playerColor then
return i
end
end
end
function getPlayerByColor(playerColor)
return gameState.allPlayers[getPlayerIndexByColor(playerColor)]
end
function updateOwnableObjects(params)
local tmPlayer=getPlayerByColor(params.playerColor)
local ownableObjectName=params.ownableObjectName
local delta=params.delta
if tmPlayer.ownedObjects[ownableObjectName]==nil then
tmPlayer.ownedObjects[ownableObjectName]=0
end
if delta < 0 and tmPlayer.ownedObjects[ownableObjectName]==0 then
log("Invalid action detected. Trying to remove "..ownableObjectName.." from player's ownable objects collection "..tmPlayer.color.." even though he has nothing left.")
return
end
tmPlayer.ownedObjects[ownableObjectName]=tmPlayer.ownedObjects[ownableObjectName] + delta
local triggerType=nil
if delta > 0 then
for _,mapping in pairs(eventDataMappings.ownableObjectsToTriggerTypeMap) do
if mapping.ownableObjectName==ownableObjectName then
triggerType=mapping.triggerTypeName
end
end
if triggerType~=nil then
for i=1,delta do
eventHandling_triggerEvent({triggeredByColor=tmPlayer.color,triggerType=triggerType})
end
end
end
tmPlayer.wasUpdated=true
end
function placePlayerMarker(input)
local markers=getObjectFromGUID(getPlayerByColor(input.playerColor).playerArea.playerMat).call("getPlayerMarkerSource")
if markers~=nil then
local marker=markers.takeObject({position=input.position})
local triggerType=""
for _,mapping in pairs(eventDataMappings.ownableObjectsToTriggerTypeMap) do
if mapping.ownableObjectName==input.objectName then
triggerType=mapping.triggerTypeName
end
end
eventHandling_triggerEvent({triggeredByColor=input.playerColor,triggerType=triggerType})
return marker
end
end
function placePlayerCityMarker(input)
local markers=getObjectFromGUID(getPlayerByColor(input.playerColor).playerArea.playerMat).call("getPlayerCityMarkerSource")
if markers~=nil then
local marker=markers.takeObject({position=input.position})
local triggerType=nil
if hexMapHelpers.isOnMars(gameMap,input.position) then
triggerType=eventData.triggerType.marsCityPlayed
else
triggerType=eventData.triggerType.spaceCityPlayed
end
changeCityCount({delta=1,position=input.position,guid=input.objectGuid})
eventHandling_triggerEvent({triggeredByColor=input.playerColor,triggerType=triggerType})
return marker
end
end
function plantsToGreenery(playerColor)
local tmPlayer=getPlayerByColor(playerColor)
local playerMat=getObjectFromGUID(tmPlayer.playerArea.playerMat)
local plantsStockpile=getPlayerResource({playerColor=playerColor,resourceType="plants"})
local plantsNeeded=tmPlayer.paymentSystemConfig.conversionRates["PlantsToGreenery"]
if plantsStockpile < plantsNeeded then
logging.printToColor("Not enough plants for a greenery.",playerColor,colors.messageColors.importantInfo,loggingModes.essential)
return
end
changePlayerResource({playerColor=playerColor,resourceType="plants",resourceAmount=-plantsNeeded})
dealGreeneryTileToPlayer(getPlayerIndexByColor(playerColor))
playerActionFuncs.playerHasPerformedAction(playerColor)
end
function heatToTemp(playerColor)
if gameState.temperatureDone then
logging.printToColor("Unable to convert heat into temperature. Temperature is at maximum.",playerColor,colors.messageColors.importantInfo,loggingModes.essential)
return
end
local tmPlayer=getPlayerByColor(playerColor)
local playerMat=getObjectFromGUID(tmPlayer.playerArea.playerMat)
local heatStockpile=getPlayerResource({playerColor=playerColor,resourceType="heat"})
local heatNeeded=tmPlayer.paymentSystemConfig.conversionRates["HeatToTemp"]
if heatStockpile < heatNeeded then
logging.printToColor("Not enough heat to increase temperature",playerColor,colors.messageColors.importantInfo,loggingModes.essential)
return
end
changePlayerResource({playerColor=playerColor,resourceType="heat",resourceAmount=-heatNeeded})
increaseTempButtonClick(nil,playerColor)
playerActionFuncs.playerHasPerformedAction(playerColor)
end
function increasePlayerTRByColor(playerColor,reason)
increasePlayerTerraforming(getPlayerIndexByColor(playerColor),reason)
eventHandling_triggerEvent({triggeredByColor=playerColor,triggerType=eventData.triggerType.terraformingGained})
getPlayerByColor(playerColor).wasUpdated=true
end
function decreasePlayerTRByColor(playerColor,reason)
decreasePlayerTerraforming(getPlayerIndexByColor(playerColor),reason)
getPlayerByColor(playerColor).wasUpdated=true
end
function updatePlayersPlayedTags(playerColor,updateTagsAndDelta,playedTags)
local player=getPlayerByColor(playerColor)
tagSystem.updateTags(updateTagsAndDelta,player)
gameState.allPlayers[playerIndex].wasUpdated=true
end
function decreasePlayerTerraforming(playerIndex,reason)
local playerColor=gameState.allPlayers[playerIndex].color
if gameState.allPlayers[playerIndex].terraformingRating > 0 then
gameState.allPlayers[playerIndex].terraformingRating=gameState.allPlayers[playerIndex].terraformingRating  - 1
else
logging.printToAll("Terraforming can't drop below 0 for player "..playerColor,colors.messageColors.importantInfo,loggingModes.exception)
end
local message=gameState.allPlayers[playerIndex].name.." decreased their TR by 1"
if reason~=nil then
message=gameState.allPlayers[playerIndex].name.." decreased their TR by 1 because of '"..reason.."'"
end
logging.printToAll(message,{1,0,0},loggingModes.important)
updateCubePositionsOnTerraformingBar()
gameState.allPlayers[playerIndex].wasUpdated=true
end
function increasePlayerTerraforming(playerIndex,reason)
gameState.allPlayers[playerIndex].terraformingRating=gameState.allPlayers[playerIndex].terraformingRating + 1
local message=gameState.allPlayers[playerIndex].name.." increased their TR by 1"
if reason~=nil then
message=gameState.allPlayers[playerIndex].name.." increased their TR by 1 because of '"..reason.."'"
end
logging.printToAll(message,{1,0,0},loggingModes.important)
updateCubePositionsOnTerraformingBar()
gameState.allPlayers[playerIndex].wasUpdated=true
end
function tmPlayer_setPassGenState(params)
getPlayerByColor(params.playerColor).hasPassedGeneration=params.hasPassed
end


dealingInProgress=false
function dealProjectsToPlayer(playerIndex,amountToDeal,fromDiscardPile,targetHandIndex)
function dealCoroutine()
while dealingInProgress do
coroutine.yield(0)
end
dealingInProgress=true
targetHandIndex=targetHandIndex or 1
local cardSource=nil
if fromDiscardPile==nil or fromDiscardPile==false then
cardSource=tryToFindProjectStack()
if cardSource==nil then
shuffleInDiscardPile()
end
cardSource=tryToFindProjectStack()
local objectsRemainingInStack=cardSource.getQuantity()
if (objectsRemainingInStack - amountToDeal) < 2 then
shuffleInDiscardPile()
end
cardSource=tryToFindProjectStack()
else
cardSource=tryToFindDiscardPile()
end
if cardSource~=nil then
objectsRemainingInStack=cardSource.getQuantity()
if objectsRemainingInStack < amountToDeal then
log("Dealing remaining cards")
cardSource.deal(objectsRemainingInStack,gameState.allPlayers[playerIndex].color,targetHandIndex)
else
cardSource.deal(amountToDeal,gameState.allPlayers[playerIndex].color,targetHandIndex)
end
else
logging.printToAll("No cards in project OR discard pile. Cannot deal.",gameState.allPlayers[playerIndex].color,loggingModes.important)
end
dealingInProgress=false
return 1
end
startLuaCoroutine(self,"dealCoroutine")
end
function discardProjectsFromPlayersHand(playerIndex,amountToDiscard)
function discardCardsCoroutine()
while dealingInProgress do
coroutine.yield(0)
end
dealingInProgress=true
local handObjects=Player[gameState.allPlayers[playerIndex].color].getHandObjects(1)
local cardsDiscarded=0
for _,object in pairs(handObjects) do
if object.tag=="Card" then
if object.call("isProjectCard") then
object.setRotation({0,0,180})
local wasSingleCard=putOnDiscardPile(object)
local counter=1
while counter < 12 and object~=nil and not wasSingleCard do
coroutine.yield(0)
counter=counter + 1
end
else
object.setRotation({0.00,180.00,180.00})
object.setPosition( {-68.41,-7.00,-27.61},false,false )
end
cardsDiscarded=cardsDiscarded + 1
end
if cardsDiscarded >= amountToDiscard then
break
end
end
coroutine.yield(0)
dealingInProgress=false
return 1
end
startLuaCoroutine(self,"discardCardsCoroutine")
end
function putOnDiscardPileRemotely(params)
putOnDiscardPile(getObjectFromGUID(params.cardGuid),true)
end
function putOnDiscardPile(card,smooth)
local discardPile=tryToFindDiscardPile()
if discardPile==nil or discardPile.name~="Deck" then
card.setPosition(tablePositions.gameBoardAssets.discardPile.pos)
card.setRotation({0,180,180})
return true
end
local cardsInDiscard=#discardPile.getObjects()
if cardsInDiscard > 214 then
cardsInDiscard=214
end
local yVector=vectorHelpers.scaleVector({0,0.0097806,0},cardsInDiscard)
if smooth then
card.setPositionSmooth(vectorHelpers.addVectors(tablePositions.gameBoardAssets.discardPile.pos,yVector))
else
card.setPosition(vectorHelpers.addVectors(tablePositions.gameBoardAssets.discardPile.pos,yVector))
end
card.setRotation(tablePositions.gameBoardAssets.discardPile.rot)
return false
end
function tryToFindProjectStack()
local projectDeck=gameObjectHelpers.getObjectByName("projectDeck")
if projectDeck~=nil then
return projectDeck
end
local projectStackTile=gameObjectHelpers.getObjectByName("projectZone")
local projects=projectStackTile.getObjects()
for _,object in pairs(projects) do
if object.tag=="Deck" or object.tag=="Card" then
setupGuids.projectDeck=object.getGUID()
return object
end
end
end
function tryToFindDiscardPile()
local discardStack=gameObjectHelpers.getObjectByName("discardStackTile")
local discardObjects=discardStack.getObjects()
local discardCardLikeObjects={}
for _,object in pairs(discardObjects) do
if object.tag=="Deck" or object.tag=="Card" then
table.insert(discardCardLikeObjects,object)
end
end
if #discardCardLikeObjects==0 then
print("Discard pile is empty.")
return nil
end
local discardPile=nil
discardPile=discardCardLikeObjects[1]
return discardPile
end
function shuffleDiscardPile()
local discardPile=tryToFindDiscardPile()
if discardPile==nil then
print("Discard pile is empty,cannot shuffle it.")
return
end
if discardPile.tag=="Deck" then
discardPile.shuffle()
end
end
function shuffleInDiscardPile()
local discardPile=tryToFindDiscardPile()
if discardPile==nil then
print("Discard pile is empty,cannot shuffle it into projects")
return
end
if discardPile.tag=="Deck" then
discardPile.shuffle()
end
local projectDeck=tryToFindProjectStack()
if projectDeck~=nil then
local rotation=projectDeck.getRotation()
if projectDeck.tag=="Card" then
setupGuids.projectDeck=discardPile.getGUID()
projectDeck.setPosition(vectorHelpers.addVectors(gameObjectHelpers.getObjectByName("projectStackTile").getPosition(),{0,3,0}))
discardPile.setPosition(vectorHelpers.addVectors(gameObjectHelpers.getObjectByName("projectStackTile").getPosition(),{0,0.5,0}))
local oldId=projectDeck.getGUID()
local timeout=200
local counter=0
while getObjectFromGUID(oldId)~=nil do
coroutine.yield(0)
if counter > timeout then
break
else
counter=counter + 1
end
end
for i=1,30 do
coroutine.yield(0)
end
else
rotation[2]=180
projectDeck.setRotation(rotation)
discardPile.setRotation(rotation)
projectDeck=projectDeck.putObject(discardPile)
rotation[2]=0
projectDeck.setRotation(rotation)
end
else
setupGuids.projectDeck=discardPile.getGUID()
discardPile.setPosition(vectorHelpers.addVectors(gameObjectHelpers.getObjectByName("projectStackTile").getPosition(),{0,0.5,0}))
end
end
function searchForCard(params)
local tagsToSearchFor=params.tagsToSearchFor or {}
local forbiddenTags=params.forbiddenTags or {}
local counterType=params.counterType or nil
local productionValues=params.productionValues or {}
local resourceValues=params.resourceValues or {}
local amountToSearchFor=params.amountToSearchFor or 1
local playerColor=params.playerColor or "Grey"
local callbackInfo=params.callbackInfo
local onlyTopmost=params.onlyTopmost or false
local criteria=params.criteria
local shuffleBackAfterSearch=params.shuffleBackAfterSearch or gameState.shuffleBackAfterSearch
function searchForCardCoroutine()
while dealingInProgress do
coroutine.yield(0)
end
dealingInProgress=true
local projectDeck=tryToFindProjectStack()
local revealPileSize=0
local cardsSearched=0
searchFunctions.printSearchCriteris(tagsToSearchFor,forbiddenTags)
while amountToSearchFor > 0 do
if projectDeck.getQuantity()==2 then
shuffleInDiscardPile()
for i=1,120 do coroutine.yield(0) end
end
revealPileSize=0
local card=projectDeck.takeObject({
position=vectorHelpers.addVectors(tablePositions.gameBoardAssets.cardRevealTransform.pos,vectorHelpers.scaleVector({0,0.011,0},revealPileSize)),
rotation=tablePositions.gameBoardAssets.cardRevealTransform.rot,
smooth=true,
})
for i=1,20 do coroutine.yield(0) end
local didFindCard=true
if criteria~=nil then
didFindCard=false
for _,crit in pairs(criteria) do
didFindCard=didFindCard or searchFunctions.tagsMatch(crit.tagsToSearchFor,crit.forbiddenTags,card) and
searchFunctions.counterTypeMatches(crit.counterType,card) and
searchFunctions.resourceValuesMatch(crit.resourceValues,card) and
searchFunctions.productionValuesMatch(crit.productionValues,card) and
searchFunctions.effects(crit.effects,card) and
searchFunctions.specialHandling(crit.searchIds,card)
end
else
didFindCard=searchFunctions.tagsMatch(tagsToSearchFor,forbiddenTags,card) and
searchFunctions.counterTypeMatches(counterType,card) and (
searchFunctions.resourceValuesMatch(resourceValues,card) or
searchFunctions.productionValuesMatch(productionValues,card))
end
for i=1,5 do coroutine.yield(0) end
if didFindCard then
logging.printToAll("Revealed "..card.getName().." .. did match search criteria.")
else
logging.printToAll("Revealed "..card.getName().." .. no match.")
end
amountToSearchFor,revealPileSize=searchFunctions.handleCard(didFindCard,callbackInfo,playerColor,card,cardTags,amountToSearchFor,revealPileSize)
if onlyTopmost then amountToSearchFor=0 end
cardsSearched=cardsSearched + 1
if cardsSearched >= 200 then
logging.broadcastToAll("Searched 200 cards. Stopping automatic search.",{200,0,0},loggingModes.exception)
amountToSearchFor=0
end
if shuffleBackAfterSearch then
for i=1,10 do coroutine.yield(0) end
local revealPile=getRevealPile()
if revealPile~=nil then
projectDeck.putObject(revealPile)
for i=1,120 do coroutine.yield(0) end
projectDeck.shuffle()
end
end
end
dealingInProgress=false
return 1
end
startLuaCoroutine(self,"searchForCardCoroutine")
end
function getRevealPile()
local revealZone=gameObjectHelpers.getObjectByName("revealZone")
local revealedProjects=revealZone.getObjects()
for _,object in pairs(revealedProjects) do
if object.tag=="Deck" or object.tag=="Card" then
return object
end
end
return nil
end
function doesFulFillCriteria(criteria,card)
local anyCriteriumFulfilled=false
for _,criterium in pairs(criteria) do
local thisCriteriumFulfilled=searchFunctions.counterTypeMatches(criteria.counterType,card)
end
end
searchFunctions={}
searchFunctions.counterTypeMatches=function(counterTypeToMatch,card)
if counterTypeToMatch~=nil and card.getVar("getMainCounterType")~=nil then
local mainCounterType=card.call("getMainCounterType")
for i=1,5 do
coroutine.yield(0)
end
if mainCounterType==nil then
mainCounterType=card.getVar("cardState").customCounterType
end
return (string.lower(counterTypeToMatch)==string.lower(mainCounterType))
elseif counterTypeToMatch~=nil then
return false
else
return true
end
end
searchFunctions.printSearchCriteris=function(tagsToSearchFor,forbiddenTags)
local tagsAsPrintableString=""
for _,tag in pairs(tagsToSearchFor) do
if tagsAsPrintableString=="" then
tagsAsPrintableString="'"..tag.."'"
else
tagsAsPrintableString=tagsAsPrintableString..",'"..tag.."'"
end
end
for _,tag in pairs(forbiddenTags) do
if tagsAsPrintableString=="" then
tagsAsPrintableString="NOT '"..tag.."'"
else
tagsAsPrintableString=tagsAsPrintableString..",NOT '"..tag.."'"
end
end
logging.printToAll("Searching/revealing card(s) with search criteria: "..tagsAsPrintableString)
end
searchFunctions.tagsMatch=function(tagsToSearchFor,forbiddenTags,card)
tagsToSearchFor=tagsToSearchFor or {}
forbiddenTags=forbiddenTags or {}
local didFindCard=true
local cardTags=card.call("getTags")
local tagSearchResult={}
for _,tag in pairs(tagsToSearchFor) do
tagSearchResult[tag]=false
end
for _,tag in pairs(forbiddenTags) do
tagSearchResult[tag]=true
end
for _,tag in pairs(tagsToSearchFor) do
for _,cardTag in pairs(cardTags) do
if tag==cardTag then
tagSearchResult[tag]=true
break
end
end
end
for _,tag in pairs(forbiddenTags) do
for _,cardTag in pairs(cardTags) do
if tag==cardTag then
tagSearchResult[tag]=false
break
end
end
end
for _,searchResult in pairs(tagSearchResult) do
didFindCard=didFindCard and searchResult
end
return didFindCard
end
searchFunctions.productionValuesMatch=function(productionValues,card)
if productionValues==nil then return true end
local productionCriteriaMatched=true
for criteriumResourceType,signum in pairs(productionValues) do
local wasMatched=false
local productionValues=card.call("getProductionValues")
if productionValues==nil then
productionValues=descriptionInterpreter.getKeyValuePairsFromInput(card.getDescription(),"Prod:")
end
for resourceType,value in pairs(productionValues) do
if string.lower(resourceType)==string.lower(criteriumResourceType) and signum * value > 0 then
wasMatched=true
end
end
if not wasMatched then
productionCriteriaMatched=false
end
end
return productionValuesMatch
end
searchFunctions.resourceValuesMatch=function(resourceValues,card)
if resourceValues==nil then return true end
local resourceCriteriaMatched=true
for criteriumResourceType,signum in pairs(resourceValues) do
local wasMatched=false
local resourceValues=card.call("getResourceValues")
if resourceValues==nil then
resourceValues=descriptionInterpreter.getKeyValuePairsFromInput(card.getDescription(),"Resrc:")
end
for resourceType,value in pairs(resourceValues) do
if string.lower(resourceType)==string.lower(criteriumResourceType) and signum * value > 0 then
wasMatched=true
end
end
if not wasMatched then
resourceCriteriaMatched=false
end
end
return resourceCriteriaMatched
end
searchFunctions.effects=function(effects,card)
if effects==nil then return true end
local effectCriteriaMatched=true
for _,criteriumEffectType in pairs(effects) do
local wasMatched=false
local cardEffects=nil
if card.getVar("getEffects")~=nil then
cardEffects=card.call("getEffects")
end
if cardEffects==nil then
cardEffects=descriptionInterpreter.getValuesFromInput(card.getDescription(),"Effects:")
end
for _,cardEffect in pairs(cardEffects) do
if string.lower(cardEffect)==string.lower(criteriumEffectType) then
wasMatched=true
end
end
if not wasMatched then
effectCriteriaMatched=false
end
end
return effectCriteriaMatched
end
searchFunctions.specialHandling=function(searchIds,card)
if searchIds==nil then return true end
local searchIdsOnCard=card.descriptionInterpreter.getValuesFromInput(card.getDescription(),"SearchIds:")
if searchIdsOnCard==nil then
return true
end
for _,idOnCard in pairs(searchIdsOnCard) do
for _,searchId in pairs(searchIds) do
if idOnCard==serachId then
return true
end
end
end
return false
end
searchFunctions.handleCard=function(didFindCard,callbackInfo,playerColor,card,cardTags,amountToSearchFor,revealPileSize)
if didFindCard then
amountToSearchFor=amountToSearchFor - 1
if callbackInfo~=nil then
local obj=getObjectFromGUID(callbackInfo.callbackObjGuid)
if obj~=nil then
obj.call(
callbackInfo.callbackFuncName,{
playerColor=playerColor,
cardGuid=card.getGUID(),
cardTags=tableHelpers.deepClone(cardTags),
searchIsDone=amountToSearchFor <= 0
}
)
elseif callbackInfo.callbackFuncName~=nil then
Global.call(
callbackInfo.callbackFuncName,{
playerColor=playerColor,
cardGuid=card.getGUID(),
cardTags=tableHelpers.deepClone(cardTags),
searchIsDone=amountToSearchFor <= 0
}
)
else
card.deal(1,playerColor)
end
if callbackInfo.discardCard~=false then
putOnDiscardPile(card,true)
end
else
card.deal(1,playerColor)
end
elseif shuffleBackAfterSearch then
card.setRotation({0,180,180})
revealPileSize=revealPileSize + 1
else
putOnDiscardPile(card,true)
end
return amountToSearchFor,revealPileSize
end


function dealOceanToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("oceanBag")
if #source.getObjects()==0 then
return
end
dealObjectToPlayer(playerIndex,source)
end
function dealCityTileToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("genericCityBag")
dealObjectToPlayer(playerIndex,source,false)
end
function dealGreeneryTileToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("genericGreeneryBag")
dealObjectToPlayer(playerIndex,source,false)
end
function dealAnimalTokenToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("animalWildSource")
dealObjectToPlayer(playerIndex,source,false)
end
function dealMicrobeTokenToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("microbeFloaterSource")
dealObjectToPlayer(playerIndex,source,false)
end
function dealFloaterTokenToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("microbeFloaterSource")
dealObjectToPlayer(playerIndex,source,true)
end
function dealScienceTokenToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("scienceFighterSource")
dealObjectToPlayer(playerIndex,source,false)
end
function dealFighterTokenToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("scienceFighterSource")
dealObjectToPlayer(playerIndex,source,true)
end
function dealOreTokenToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("oreSource")
dealObjectToPlayer(playerIndex,source,false)
end
function dealDataTokenToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("dataAsteroidSource")
dealObjectToPlayer(playerIndex,source,false)
end
function dealAsteroidTokenToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("dataAsteroidSource")
dealObjectToPlayer(playerIndex,source,true)
end
function dealWildCardTokenToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("animalWildSource")
dealObjectToPlayer(playerIndex,source,true)
end
function dealResourceWildCardTokenToPlayer(playerIndex,metadata)
local source=gameObjectHelpers.getObjectByName("resourceWildTokenSource")
dealObjectToPlayer(playerIndex,source,false,{metadata=metadata})
end
function dealProductionWildCardTokenToPlayer(playerIndex,metadata)
local source=gameObjectHelpers.getObjectByName("resourceWildTokenSource")
dealObjectToPlayer(playerIndex,source,true,{metadata=metadata})
end
function dealProgramableActionToken(playerIndex,metadata)
local source=gameObjectHelpers.getObjectByName("programableActionTokenSource")
dealObjectToPlayer(playerIndex,source,false,{metadata=metadata})
end
function dealPlayerMarkerToPlayer(playerIndex)
local tmPlayer=gameState.allPlayers[playerIndex]
local source=getObjectFromGUID(getPlayerByColor(tmPlayer.color).playerArea.playerMat).call("getPlayerMarkerSource")
dealObjectToPlayer(getPlayerIndexByColor(tmPlayer.color),source,true)
end
function dealFloatingArrayTileToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("floatingArrayBag")
dealObjectToPlayer(playerIndex,source,false)
end
function dealGasMineTileToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("gasMineBag")
dealObjectToPlayer(playerIndex,source,false)
end
function dealVenusHabitatTileToPlayer(playerIndex)
local source=gameObjectHelpers.getObjectByName("venusHabitatBag")
dealObjectToPlayer(playerIndex,source,false)
end
function dealDelegateToPlayer(playerIndex)
local player=gameState.allPlayers[playerIndex]
local source=getObjectFromGUID(player.delegateBagId)
if source~=nil and #source.getObjects() > 0 then
dealObjectToPlayer(playerIndex,source,false)
else
logging.printToColor("You didn't get a delegate as there are no delegates in your reserve left.",player.color,player.color,loggingModes.exception)
end
end
function dealSpecialTileToPlayer(playerIndex,objectName)
local container=gameObjectHelpers.getObjectByName("specialsBag")
local objectGuid=gameObjectHelpers.getGuidByName(objectName)
for i,obj in ipairs(container.getObjects()) do
if objectGuid==obj["guid"] then
dealObjectToPlayer(playerIndex,container,false,{specificGuid=objectGuid})
end
end
end
function dealObjectToPlayer(playerIndex,source,flipObject,params)
function dealCoroutine()
while dealingObjectInProgress do
coroutine.yield(0)
end
if source.getQuantity()==0 then
logging.printToAll("Could not deal object to player "..gameState.allPlayers[playerIndex].color..". Container '"..source.getName().."' is empty.")
return 1
end
dealingObjectInProgress=true
local obj={}
local specificGuid=nil
local metadata=nil
if params~=nil then
specificGuid=params.specificGuid
metadata=params.metadata
end
if specificGuid~=nil then
obj=source.takeObject({guid=specificGuid})
else
obj=source.takeObject()
end
coroutine.yield(0)
obj.setRotation(getObjectFromGUID(gameState.allPlayers[playerIndex].playerArea.playerMat).getRotation())
coroutine.yield(0)
coroutine.yield(0)
obj.deal(1,gameState.allPlayers[playerIndex].color)
if flipObject then
obj.flip()
end
if obj.getVar("initializeWithMetdata") and metadata~=nil then
obj.call("initializeWithMetdata",{metadata=metadata})
end
dealingObjectInProgress=false
return 1
end
startLuaCoroutine(self,"dealCoroutine")
end


colonySystem={}
colonySystem.spawnFleet=function(playerColor)
if gameState.coloniesGameData==nil then
gameState.coloniesGameData={}
gameState.wasUpdated=true
end
local data=gameState.coloniesGameData
if data.fleetsInPlay==nil then
data.fleetsInPlay=0
end
data.fleetsInPlay=data.fleetsInPlay + 1
local stateColorMap={Red=1,Yellow=2,Green=3,Blue=4,White=5,Orange=6}
local tradeShipBag=gameObjectHelpers.getObjectByName("coloniesShipBag")
local tradingTile=getObjectFromGUID("3e7af8")
objectFromBag=tradeShipBag.takeObject({
position=vectorHelpers.addVectors(
tradingTile.getPosition(),
matrixTwoDHelpers.totalOffsetFromPositionMatrixAnd1DIndex(data.fleetsInPlay,tablePositions.colonies.tradeShipPositionMatrix)
),
rotation={0,90,0},
callback_function=function(object)
for _,state in pairs(object.getStates()) do
if state.id==stateColorMap[playerColor] then
object.setState(state.id)
end
end
end
})
end
colonySystem.generateTradeTokenMetadata=function(playerColor)
local tmPlayer=getPlayerByColor(playerColor)
local tradeRewardModifier=tmPlayer.colonyTradingConfig.tradingRewardModifier
local metadata={}
metadata.tokenTitle="Trade token. Drop on a colony tile to trade with that colony."
metadata.owner=playerColor
metadata.tokenContext={tokenType=programableActionTokenData.types.tradeToken,tradeModifier=tradeRewardModifier}
metadata.configuration={maxLimit=tmPlayer.colonyTradingConfig.tradingRewardModifier,
minLimit=0,
startValue=tmPlayer.colonyTradingConfig.tradingRewardModifier}
return metadata
end
colonySystem.generateColonyTrackUpTokenMetadata=function(playerColor)
local metadata={}
metadata.tokenTitle="Increase Colony Track. Drop on a colony tile to increase that colony's track marker."
metadata.owner=playerColor
metadata.tokenContext={tokenType=programableActionTokenData.types.colonyTrackUp}
return metadata
end
colonySystem.generateColonyTrackDownTokenMetadata=function(playerColor)
local metadata={}
metadata.tokenTitle="Decrease Colony Track. Drop on a colony tile to decrease that colony's track marker."
metadata.owner=playerColor
metadata.tokenContext={tokenType=programableActionTokenData.types.colonyTrackDown}
return metadata
end
gameState.colonyGuids={}
function getPlayerColors()
local colorTable={}
for _,player in pairs(gameState.allPlayers) do
table.insert(colorTable,player.color)
end
return colorTable
end
function registerColony(parameters)
local index=tableHelpers.getIndexInTable(gameState.colonyGuids,parameters.guid)
if index==nil then
table.insert(gameState.colonyGuids,parameters.guid)
gameState.wasUpdated=true
else
log("registerColony attempted with existing colony "..parameters.guid)
end
end
function unregisterColony(parameters)
local index=tableHelpers.getIndexInTable(gameState.colonyGuids,parameters.guid)
if index~=nil then
table.remove(gameState.colonyGuids,index)
gameState.wasUpdated=true
end
end
function placeColonyMarkerAndInitialize(params)
local colony=getObjectFromGUID(params.colonyGUID)
local discardAllowed=gameState.isSoloGame==true
local colonyMarkers=gameObjectHelpers.getObjectByName("coloniesMarkersBag")
colonyMarkers.takeObject( {
position=vectorHelpers.addVectors(colony.getPosition(),tablePositions.colonies.tradeMarkerActiveOffset),
callback_function=function(obj) colony.call("initializeColony",{marker=obj.getGUID(),discardAllowed=discardAllowed}) end,
rotation={0,0,0}}
)
end
function increaseColonyMarkers()
for _,guid in pairs(gameState.colonyGuids) do
local colony=getObjectFromGUID(guid)
if colony~=nil then
colony.call("increaseColonyMarker")
end
end
end
function getPlayerColonyToPlace(params)
local playerColor=params.player_color
local colonyGuid=params.colonyGuid
log("Player "..playerColor.." trying to place colony on "..colonyGuid)
local handObjects=Player[playerColor].getHandObjects()
for _,object in pairs(handObjects) do
if object.getName()=="Cube" and object.getDescription()==playerColor then
log("Player "..playerColor.." has colony in hand "..colonyGuid)
return object.getGUID()
end
end
return nil
end
function resetTradingFleets()
local index=1
for _,object in pairs(getAllObjects()) do
if string.match(object.getName(),".* Trade Fleet")~=nil and object.getGUID()~=gameObjectHelpers.getGuidByName("coloniesShipBag") then
local totalOffset=matrixTwoDHelpers.totalOffsetFromPositionMatrixAnd1DIndex(index,tablePositions.colonies.tradeShipPositionMatrix)
object.setPositionSmooth(vectorHelpers.addVectors(tablePositions.colonies.tradingTile.pos,totalOffset,false,false))
object.setRotation({0,90,0})
index=index + 1
end
end
end
function tradeViaCredits(_,playerColor,_)
local activationEffects={resourceValues={Credits=-9}}
payUpForTrade(playerColor,activationEffects)
end
function tradeViaTitanium(_,playerColor,_)
local activationEffects={resourceValues={Titanium=-3}}
payUpForTrade(playerColor,activationEffects)
end
function tradeViaEnergy(_,playerColor,_)
local activationEffects={resourceValues={Energy=-3}}
payUpForTrade(playerColor,activationEffects)
end
function payUpForTrade(playerColor,activationEffects)
if not canPlayerTrade(playerColor) then
logging.printToColor("Cannot trade. You do not have any free trade fleets.",playerColor,playerColor,loggingModes.important)
return
end
local tmPlayer=getPlayerByColor(playerColor)
for key,value in pairs(activationEffects.resourceValues) do
activationEffects.resourceValues[key]=value - tmPlayer.colonyTradingConfig.tradingCostModifier
end
activationEffects.effects={"TradeToken"}
local colonyTradingTile=gameObjectHelpers.getObjectByName("coloniesTradingTile")
objectActivationSystem_doAction({playerColor=playerColor,sourceName="Trade Button",object=colonyTradingTile,activationEffects=activationEffects})
end
function canPlayerTrade(player_color)
for _,object in pairs(getObjectFromGUID(gameState.static.coloniesGameData.fleetZone).getObjects()) do
if string.find(object.getName(),"Trade Fleet")~=nil and string.find(object.getName(),player_color)~=nil then
return true
end
end
end
function letPlayerTrade(params)
local playerColor=params.player_color
local target=params.colonyGuid
for _,object in pairs(getObjectFromGUID(gameState.static.coloniesGameData.fleetZone).getObjects()) do
if string.find(object.getName(),"Trade Fleet")~=nil and string.find(object.getName(),playerColor)~=nil then
object.setPositionSmooth(vectorHelpers.addVectors(getObjectFromGUID(target).getPosition(),tablePositions.colonies.tradeShipTradedOffset),false,false)
object.setRotation({0,90,0})
break
end
end
eventHandling_triggerEvent({triggeredByColor=playerColor,
triggerType=eventData.triggerType.colonyTraded,
eventSourceId=params.colonyGuid,
metadata={}})
end
function giveTradingRewards(rewardTable)
for color,rewards in pairs(rewardTable) do
local receiver=gameState.allPlayers[getPlayerIndexByColor(color)]
for index,reward in pairs(rewards) do
colonyRewardFunctions[reward.type](receiver,reward.amount)
logging.printToAll("Player "..receiver.color.." received "..reward.amount.." "..reward.type.." from trading.",{0,0.7,0.8,1},loggingModes.detail)
end
end
end
function updatePlayerColonyCount(params)
local player_color=params.player_color
local delta=params.delta
local player=gameState.allPlayers[getPlayerIndexByColor(player_color)]
player.ownedObjects[ownableObjects.colonies.objects.colony]=player.ownedObjects[ownableObjects.colonies.objects.colony] + delta
log("Player "..player_color.." has now "..player.ownedObjects[ownableObjects.colonies.objects.colony].." colonies in play.")
end
function givePlaceColonyRewards(params)
local playerColor=params.player_color
local type=params.type
local amount=params.amount
local receiver=gameState.allPlayers[getPlayerIndexByColor(playerColor)]
logging.printToAll("Player "..playerColor.." received "..amount.." "..type.." from placing a colony.",{0,0.7,0.8,1},loggingModes.detail)
colonyRewardFunctions[type](receiver,amount)
end
colonyRewardFunctions={}
colonyRewardFunctions.energy=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="energy",amount=amount}
playerMat.call("changeStockpile",paramTable)
end
colonyRewardFunctions.energyProduction=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="energy",amount=amount}
playerMat.call("changeProduction",paramTable)
end
colonyRewardFunctions.plantProduction=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="plants",amount=amount}
playerMat.call("changeProduction",paramTable)
end
colonyRewardFunctions.creditsProduction=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="credits",amount=amount}
playerMat.call("changeProduction",paramTable)
end
colonyRewardFunctions.steel=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="steel",amount=amount}
playerMat.call("changeStockpile",paramTable)
end
colonyRewardFunctions.steelProduction=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="steel",amount=amount}
playerMat.call("changeProduction",paramTable)
end
colonyRewardFunctions.titanium=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="titanium",amount=amount}
playerMat.call("changeStockpile",paramTable)
end
colonyRewardFunctions.heat=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="heat",amount=amount}
playerMat.call("changeStockpile",paramTable)
end
colonyRewardFunctions.heatProduction=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="heat",amount=amount}
playerMat.call("changeProduction",paramTable)
end
colonyRewardFunctions.credits=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="credits",amount=amount}
playerMat.call("changeStockpile",paramTable)
end
colonyRewardFunctions.plants=function(receiver,amount)
local playerMat=getObjectFromGUID(receiver.playerArea.playerMat)
local paramTable={key="plants",amount=amount}
playerMat.call("changeStockpile",paramTable)
end
colonyRewardFunctions.animals=function(receiver,amount)
local source=gameObjectHelpers.getObjectByName("animalWildSource")
source.deal(amount,receiver.color)
end
colonyRewardFunctions.microbes=function(receiver,amount)
local source=gameObjectHelpers.getObjectByName("microbeFloaterSource")
source.deal(amount,receiver.color)
end
colonyRewardFunctions.data=function(receiver,amount)
local source=gameObjectHelpers.getObjectByName("dataAsteroidSource")
source.deal(amount,receiver.color)
end
colonyRewardFunctions.floaters=function(receiver,amount)
local source=gameObjectHelpers.getObjectByName("microbeFloaterSource")
function coroutineGetFloater()
for i=1,amount do
local obj=source.takeObject()
coroutine.yield(0)
coroutine.yield(0)
coroutine.yield(0)
obj.deal(1,receiver.color)
obj.flip()
end
return 1
end
startLuaCoroutine(self,"coroutineGetFloater")
end
colonyRewardFunctions.cards=function(receiver,amount)
dealProjectsToPlayer(getPlayerIndexByColor(receiver.color),amount)
end
colonyRewardFunctions.oceans=function(receiver,amount)
dealOceanToPlayer(getPlayerIndexByColor(receiver.color))
end


function changeRulingParty(newRulingPartyId)
function changeRulingPartyCoroutine()
local previousRulingParty=getRulingParty()
local newRulingParty=nil
for _,partyInfo in pairs(gameState.turmoilData.parties) do
if partyInfo.partyId==newRulingPartyId then
partyInfo.isRuling=true
newRulingParty=partyInfo
else
partyInfo.isRuling=false
end
end
local eventHandler={eventHandlerId="globalEventHandlerTurmoilPolicy"}
eventHandler.triggerScope=eventData.triggerScope.anyPlayer
eventHandler.actionIndex=-1
eventHandler.callbackName="activatePolicy"
eventHandler.objectPrettyName="Turmoil"
if previousRulingParty~=nil then
if turmoilPartyData.parties[previousRulingParty.partyId].policyBonus.triggerTypes~=nil then
eventHandler.allowedPhases=turmoilPartyData.parties[previousRulingParty.partyId].policyBonus.allowedPhases
for _,triggerType in pairs(turmoilPartyData.parties[previousRulingParty.partyId].policyBonus.triggerTypes) do
local tmpEventHandler=tableHelpers.deepClone(eventHandler)
tmpEventHandler.triggerType=triggerType
eventHandling.unsubscribeHandler(tmpEventHandler)
end
end
end
for i=1,4 do coroutine.yield(0) end
if turmoilPartyData.parties[newRulingParty.partyId].policyBonus.triggerTypes~=nil then
eventHandler.allowedPhases=turmoilPartyData.parties[newRulingParty.partyId].policyBonus.allowedPhases
for _,triggerType in pairs(turmoilPartyData.parties[newRulingParty.partyId].policyBonus.triggerTypes) do
local tmpEventHandler=tableHelpers.deepClone(eventHandler)
tmpEventHandler.triggerType=triggerType
eventHandling.subscribeHandler(tmpEventHandler)
end
end
gameState.turmoilData.oneTimeEffectTable={}
if previousRulingParty~=nil then
if turmoilPartyData.parties[previousRulingParty.partyId].onRulingPartyChanged~=nil then
turmoilPartyData.parties[previousRulingParty.partyId].onRulingPartyChanged(newRulingParty,gameState.allPlayers)
end
end
if turmoilPartyData.parties[newRulingParty.partyId].onRulingPartyChanged~=nil then
turmoilPartyData.parties[newRulingParty.partyId].onRulingPartyChanged(newRulingParty,gameState.allPlayers)
end
return 1
end
startLuaCoroutine(self,"changeRulingPartyCoroutine")
end
function getRulingParty()
for _,partyInfo in pairs(gameState.turmoilData.parties) do
if partyInfo.isRuling then
return partyInfo
end
end
return nil
end
function onObjectSpawn(obj)
if obj.getDescription()~="PartyTile" then
return
end
for _,partyPlateGuid in pairs(turmoilPartyPlates) do
if obj.guid==partyPlateGuid then
local stateId=obj.getStateId()
changeRulingParty(marsSenate.partiesById[stateId])
end
end
end
function createDelegatesForBag(bag,amount,description,callback)
local amountDone=0
local delegateIds={}
local callbackFunction=function(clonedObjectGuid)
local object=getObjectFromGUID(clonedObjectGuid)
object.setName("Delegate")
object.setDescription(description)
object.setColorTint(bag.getColorTint())
table.insert(delegateIds,clonedObjectGuid)
amountDone=amountDone + 1
object.setLock(false)
bag.putObject(object)
if amountDone==amount then
if type(callback)=="function" then
callback(delegateIds)
end
end
end
local genericDelegate=gameObjectHelpers.getObjectByName("turmoilGenericDelegate")
for i=1,amount do
createClonableObject(genericDelegate,vectorHelpers.addVectors(bag.getPosition(),{0,1 + i,0}),{0,0,0},callbackFunction)
end
end
function extractPartiesFromDescription(description)
local distantMatch="Distant Party: (%a+)"
local currentMatch="Current Party: (%a+)"
return {
distantParty=string.match(description,distantMatch),
currentParty=string.match(description,currentMatch)
}
end
function zoneContainsDelegate(zoneGuid)
local zone=getObjectFromGUID(zoneGuid)
if zone.getObjects()~=nil then
for _,obj in pairs(zone.getObjects()) do
if obj.getName()=="Delegate" then
return true
end
end
end
return false
end
function getDelegateFromZone(zoneGuid)
local zone=getObjectFromGUID(zoneGuid)
if zone.getObjects()~=nil then
for _,obj in pairs(zone.getObjects()) do
if obj.getName()=="Delegate" then
return obj
end
end
end
return nil
end
function findNextFreePartyPosition(partyInfo)
if not zoneContainsDelegate(partyInfo.partyLead.zoneGuid) then
return partyInfo.partyLead.pos
end
for _,delegate in pairs(partyInfo.delegates) do
if not zoneContainsDelegate(delegate.zone) then
return delegate.pos
end
end
return nil
end
function placeDelegateInPartyRemotely(params)
placeDelegateInParty(params.playerColor,params.partyId,true)
end
function placeDelegateInParty(playerColor,partyId,remotelyTriggered)
for _,obj in pairs(Player[playerColor].getHandObjects(1)) do
if obj.tag=="Figurine" and obj.getName()=="Delegate" then
placeDelegate(obj,partyId)
return
end
end
for _,info in pairs(gameState.turmoilData.lobbyZones) do
local delegate=getDelegateFromZone(info.zone)
if delegate~=nil and delegate.getDescription()==playerColor then
placeDelegate(delegate,partyId)
playerActionFuncs.playerHasPerformedAction(playerColor)
return
end
end
local tmPlayer=getPlayerByColor(playerColor)
local delegateBag=getObjectFromGUID(tmPlayer.delegateBagId)
if delegateBag.getObjects()==nil or #delegateBag.getObjects()==0 then
logging.printToColor("All your delegates are already occupied.",playerColor)
return
end
local activationEffects={resourceValues={Credits=-5}}
local isAllowed=objectActivationSystem_doAction({
playerColor=playerColor,
object=delegateBag,
sourceName="placing a delegate from their reserve.",
activationEffects=activationEffects
})
if isAllowed then
placeDelegateFromBagInParty(delegateBag,partyId)
end
end
function placeDelegateFromBagInParty(delegateBag,partyId)
if delegateBag.getObjects()==nil or #delegateBag.getObjects()==0 then
return false
end
local delegate=delegateBag.takeObject()
placeDelegate(delegate,partyId)
return true
end
function placeDelegate(delegate,partyId)
function placeDelegateCoroutine()
while transientState.delegatePlacingOngoing==true do
coroutine.yield(0)
end
transientState.delegatePlacingOngoing=true
for _,partyInfo in pairs(gameState.turmoilData.parties) do
if partyId==partyInfo.partyId then
local nextFreePosition=findNextFreePartyPosition(partyInfo)
if nextFreePosition==nil then
logging.broadcastToAll("Party "..partyInfo.partyId.." has no free slots left,unable to place a delegate.")
break
end
local delegateRotation=partyInfo.delegateRotation
delegate.setPosition(nextFreePosition,false,false)
delegate.setRotation(delegateRotation)
for i=1,15 do
coroutine.yield(0)
end
while not delegate.resting do
coroutine.yield(0)
end
recalculateDominance()
recalculatePartyLeads()
break
end
end
transientState.delegatePlacingOngoing=false
return 1
end
startLuaCoroutine(self,"placeDelegateCoroutine")
end
function countAllDelegates(zoneGuid)
local count=0
for _,object in pairs(getObjectFromGUID(zoneGuid).getObjects()) do
if object.getName()=="Delegate" and object.resting then
count=count + 1
end
end
return count
end
function recalculateDominance()
local partiesToConsider={}
local highestDelegateCount=0
local dominantPartyIndex=0
for i,partyInfo in pairs(gameState.turmoilData.parties) do
local delegateCount=countAllDelegates(partyInfo.mainPartyZone)
if delegateCount > highestDelegateCount then
partiesToConsider={i}
highestDelegateCount=delegateCount
elseif delegateCount==highestDelegateCount then
table.insert(partiesToConsider,i)
end
if partyInfo.isDominant then
dominantPartyIndex=i
partyInfo.isDominant=false
end
end
local newIndex=findClosestClockwiseIndex(#gameState.turmoilData.parties,dominantPartyIndex,partiesToConsider)
local newDominatingParty=gameState.turmoilData.parties[newIndex]
newDominatingParty.isDominant=true
moveDominanceMarkerToParty(newDominatingParty)
end
function findClosestClockwiseIndex(roundSize,referenceIndex,inputIndicesTable)
for i=referenceIndex,referenceIndex-roundSize+1,-1 do
local normalizedIndex=i
if normalizedIndex < 1 then
normalizedIndex=normalizedIndex + roundSize
end
for _,index in pairs(inputIndicesTable) do
if normalizedIndex==index then
return index
end
end
end
end
function moveDominanceMarkerToParty(partyInfo)
local dominanceMarker=gameObjectHelpers.getObjectByName("turmoilDominanceMarker")
dominanceMarker.setPositionSmooth(partyInfo.dominancePosition)
end
function countDelegatesInPartyAndSortByColor(partyName)
for i,partyInfo in pairs(gameState.turmoilData.parties) do
if partyInfo.partyId==partyName then
return countDelegatesAndSortByColor(partyInfo.mainPartyZone)
end
end
log("Unknown party ... (compared to partyId)"..partyName)
log("Valid parties: "..gameState.turmoilData.parties)
return nil
end
function countDelegatesAndSortByColor(zoneGuid)
local counts={}
for _,object in pairs(getObjectFromGUID(zoneGuid).getObjects()) do
if object.getName()=="Delegate" and object.resting then
if counts[object.getDescription()]==nil then
counts[object.getDescription()]=1
else
counts[object.getDescription()]=counts[object.getDescription()] + 1
end
end
end
return counts
end
function recalculatePartyLeads()
function recalculatePartyLeadsCoroutine()
while transientState.computingPartyLead do
coroutine.yield(0)
end
transientState.computingPartyLead=true
for i,partyInfo in pairs(gameState.turmoilData.parties) do
local counts=countDelegatesAndSortByColor(partyInfo.mainPartyZone)
local partyLeadObject=getFirstDelegateInZone(partyInfo.partyLead.zoneGuid)
local newPartyLeadColor=nil
local maxCount=0
if partyLeadObject~=nil then
local partyLeadColor=partyLeadObject.getDescription()
for color,count in pairs(counts) do
if count > maxCount then
newPartyLeadColor=color
maxCount=count
elseif count==maxCount and color==partyLeadColor then
newPartyLeadColor=color
end
end
if partyLeadColor~=newPartyLeadColor then
local delegate=getFirstDelegateInZone(partyInfo.mainPartyZone,newPartyLeadColor)
switchObjectPositions(partyLeadObject,delegate)
for i=1,10 do coroutine.yield(0) end
while not delegate.resting do coroutine.yield(0) end
end
elseif next(counts)~=nil then
for color,count in pairs(counts) do
if count > maxCount then
newPartyLeadColor=color
maxCount=count
end
end
local delegate=getFirstDelegateInZone(partyInfo.mainPartyZone,newPartyLeadColor)
delegate.setPositionSmooth(partyInfo.partyLead.pos)
for i=1,10 do coroutine.yield(0) end
while not delegate.resting do coroutine.yield(0) end
end
end
transientState.computingPartyLead=false
return 1
end
startLuaCoroutine(self,"recalculatePartyLeadsCoroutine")
end
function switchObjectPositions(objectA,objectB)
local positionA=objectA.getPosition()
objectA.setPositionSmooth(objectB.getPosition())
objectB.setPositionSmooth(positionA)
end
function getDominatingParty()
for _,partyInfo in pairs(gameState.turmoilData.parties) do
if partyInfo.isDominant then
return partyInfo
end
end
return nil
end
function getFirstDelegateInZone(zoneGuid,color)
local zone=getObjectFromGUID(zoneGuid)
for _,obj in pairs(zone.getObjects()) do
if obj.getName()=="Delegate" and obj.resting then
if color==nil then
return obj
else
if obj.getDescription()==color then
return obj
end
end
end
end
return nil
end
function getChairman()
return getFirstDelegateInZone(gameState.turmoilData.chairman.zoneGuid)
end
function getPartyLeadColor(partyInfo)
local delegate=getFirstDelegateInZone(partyInfo.partyLead.zoneGuid)
if delegate==nil then
return nil
else
return delegate.getDescription()
end
end
function calculateInfluence()
local chairman=getChairman()
local dominatingParty=getDominatingParty()
local allDelegateCounts=countDelegatesAndSortByColor(dominatingParty.mainPartyZone)
if dominatingParty==nil or getFirstDelegateInZone(dominatingParty.partyLead.zoneGuid)==nil then
Wait.time(|| broadcastToAll("Warning: There's currently no valid dominating party.",{1,0,0.35}),1)
Wait.time(|| broadcastToAll("This may happen if the global event is processed while the 'new government' turmoil effect is handled.",{1,0,0.35}),3)
Wait.time(|| broadcastToAll("Influence counting for dominating party and chairman was skipped. Please apply influence based effects manually.",{1,0,0.35}),5)
return
end
local leadingDelegate=getFirstDelegateInZone(dominatingParty.partyLead.zoneGuid)
for _,player in pairs(gameState.allPlayers) do
local transientInfluence=0
local hasLeadingDelegate=false
if leadingDelegate.getDescription()==player.color then
transientInfluence=transientInfluence + 1
hasLeadingDelegate=true
end
local delegateCount=allDelegateCounts[player.color]
if delegateCount~=nil then
if hasLeadingDelegate and delegateCount > 1 then
transientInfluence=transientInfluence + 1
elseif delegateCount > 0 then
transientInfluence=transientInfluence + 1
end
end
if chairman==nil then
if not player.neutral then
Wait.time(|| broadcastToColor("Warning: Chairman influence is skipped as there is currently no chairman.",player.color,{1,0,0.35,1}),1)
Wait.time(|| broadcastToColor("Please check the turmoil board if the chairman is positioned correctly.",player.color,{1,0,0.35,1}),3)
Wait.time(|| broadcastToColor("This may also happen if the global event is processed while the 'new government' turmoil effect is handled.",player.color,{1,0,0.35,1}),5)
Wait.time(|| broadcastToColor("Please also check influence based effects from the current global event,errors are very likely.",player.color,{1,0,0.35,1}),7)
end
elseif chairman.getDescription()==player.color then
transientInfluence=transientInfluence + 1
end
if player.turmoilInfluence==nil then
player.turmoilInfluence={}
end
player.turmoilInfluence.transientInfluence=transientInfluence
player.wasUpdated=true
logging.broadcastToColor("Player "..player.color.." has "..player.turmoilInfluence.transientInfluence.." influence from parties.",player.color,player.color,loggingModes.detail)
if player.turmoilInfluence.baseInfluence~=0 then
logging.broadcastToColor("Player "..player.color.." has "..player.turmoilInfluence.baseInfluence.." base influence.",player.color,player.color,loggingModes.detail)
end
end
end
function refreshLobby()
local playerIndex=1
for _,player in pairs(gameState.allPlayers) do
if not player.neutral then
local delegateBag=getObjectFromGUID(player.delegateBagId)
if #delegateBag.getObjects() > 0 then
delegateBag.takeObject({
position=gameState.turmoilData.lobbyPositions[playerIndex],
smooth=true,
})
end
playerIndex=playerIndex + 1
end
end
end
function cleanUpDelegate(delegate)
local playerColor=delegate.getDescription()
local bag=nil
if playerColor=="Neutral" then
bag=getObjectFromGUID(gameState.turmoilData.neutralBagId)
else
local player=getPlayerByColor(playerColor)
bag=getObjectFromGUID(player.delegateBagId)
end
bag.putObject(delegate)
end
function changePartyPlateToParty(partyInfo)
for name,guid in pairs(turmoilPartyPlates) do
if getObjectFromGUID(guid)~=nil then
local currentParty=name
if currentParty==partyInfo.partyId then
return
else
local states=getObjectFromGUID(guid).getStates()
for _,stateInfo in pairs(states) do
if stateInfo.guid==turmoilPartyPlates[partyInfo.partyId] then
getObjectFromGUID(guid).setState(stateInfo.id)
return
end
end
end
end
end
end
function playersPartyDelegateCount(playerColor,partyNameInput)
local delegates=countDelegatesInPartyAndSortByColor(partyNameInput)
if delegates[playerColor]==nil then
return 0
else
return delegates[playerColor]
end
end


function turmoilReduceTR()
if isDoubleClick("turmoilReduceTR") then
return
end
function turmoilReduceTRCoroutine()
transientState.turmoilActions.trRevisionInProgress=true
for i,player in pairs(gameState.allPlayers) do
if not player.neutral then
decreasePlayerTerraforming(i,"TR Revision")
end
end
transientState.turmoilActions.trRevisionInProgress=false
return 1
end
startLuaCoroutine(self,"turmoilReduceTRCoroutine")
end
function turmoilGlobalEvent(_,playerColor,altClick)
if isDoubleClick("turmoilGlobalEvent") then
return
end
function turmoilGlobalEventCoroutine()
while transientState.turmoilActions.trRevisionInProgress do
coroutine.yield(0)
end
transientState.turmoilActions.globalEventInProgress=true
calculateInfluence()
local globalEventZone=getObjectFromGUID(gameState.turmoilData.globalEvents.currentZone)
for _,object in pairs(globalEventZone.getObjects()) do
if object.tag=="Card" and not object.is_face_down then
if object.getVar("activateGlobalEvent")~=nil then
object.call("activateGlobalEvent",{allPlayers=gameState.allPlayers,triggeredByColor=playerColor})
if object.getVar("resolveGlobalEvent")~=nil then
object.call("resolveGlobalEvent",{allPlayers=gameState.allPlayers,triggeredByColor=playerColor})
end
for i=1,120 do
coroutine.yield(0)
end
object.flip()
transientState.turmoilActions.globalEventInProgress=false
return 1
else
logging.broadcastToAll("Global Event not implemented yet. Please do it manually!",{1,0,0},loggingModes.exception)
transientState.turmoilActions.globalEventInProgress=false
return 1
end
end
end
local turmoilCardDeckExists=false
for _,object in pairs(globalEventZone.getObjects()) do
if object.tag=="Deck" then
turmoilCardDeckExists=true
end
end
if turmoilCardDeckExists then
logging.broadcastToAll("Global event cards are stacked face up. This breaks the global event handling during solar phase.",{1,0,0},loggingModes.exception)
end
transientState.turmoilActions.globalEventInProgress=false
return 1
end
startLuaCoroutine(self,"turmoilGlobalEventCoroutine")
end
function turmoilNewGovernment(_,playerColor,_)
if isDoubleClick("turmoilNewGovernment") then
return
end
function turmoilNewGovernmentCoroutine()
while transientState.turmoilActions.globalEventInProgress or
transientState.turmoilActions.trRevisionInProgress do
coroutine.yield(0)
end
transientState.turmoilActions.newGovInProgress=true
local cleanupChairman=function()
local currentChairman=getChairman()
if currentChairman~=nil then
cleanUpDelegate(currentChairman)
end
end
local placeNewChairman=function(partyInfo)
local delegate=getFirstDelegateInZone(partyInfo.partyLead.zoneGuid)
if delegate==nil then
return
end
local delegateColor=delegate.getDescription()
delegate.setPositionSmooth(gameState.turmoilData.chairman.transform.pos)
if delegateColor~="Neutral" then
local leadingPlayer=getPlayerByColor(delegateColor)
logging.broadcastToAll("New chairman of the commitee is "..leadingPlayer.name,leadingPlayer.color,loggingModes.essential)
increasePlayerTerraforming(getPlayerIndexByColor(delegateColor),"player puts up the new chairman.")
else
logging.broadcastToAll("New chairman of the commitee is unaffiliated","Grey",loggingModes.essential)
end
end
local changeGoverningParty=function(partyInfo)
for _,data in pairs(turmoilPartyData.parties) do
if data.id==partyInfo.partyId then
data.onFactionTakesOver(gameState.allPlayers)
gameState.turmoilData.rulingPartyId=data.id
break
end
end
placeNewChairman(partyInfo)
changePartyPlateToParty(partyInfo)
end
local cleanupDominatingPartyDelegates=function(partyInfo)
for _,object in pairs(getObjectFromGUID(partyInfo.mainPartyZone).getObjects()) do
if object.getName()=="Delegate" then
cleanUpDelegate(object)
end
end
end
recalculateDominance()
recalculatePartyLeads()
cleanupChairman()
local dominatingParty=getDominatingParty()
for i=1,45 do coroutine.yield(0) end
changeGoverningParty(dominatingParty)
for i=1,45 do coroutine.yield(0) end
cleanupDominatingPartyDelegates(dominatingParty)
for i=1,30 do coroutine.yield(0) end
refreshLobby()
for i=1,40 do coroutine.yield(0) end
recalculateDominance()
for i=1,40 do coroutine.yield(0) end
transientState.turmoilActions.newGovInProgress=false
return 1
end
startLuaCoroutine(self,"turmoilNewGovernmentCoroutine")
end
function turmoilChangingTimes()
if isDoubleClick("turmoilChangingTimes") then
return
end
function moveComingEventAndPlaceCurrentNeutralDelegate(comingZone,neutralDelegateBag)
for _,object in pairs(comingZone.getObjects()) do
if object.tag=="Card" then
placeDelegateFromBagInParty(neutralDelegateBag,extractPartiesFromDescription(object.getDescription()).currentParty)
local newPosition=vectorHelpers.addVectors(gameState.turmoilData.globalEvents.positions.current,{0,0.5,0})
object.setPositionSmooth(newPosition)
end
end
end
function moveDistantEvent()
local turmoilDeck=gameObjectHelpers.getObjectByName("turmoilDeck")
if turmoilDeck==nil then
return
end
local newPosition=vectorHelpers.addVectors(gameState.turmoilData.globalEvents.positions.coming,{0,0.5,0})
turmoilDeck.takeObject({
position=newPosition
})
end
function placeDistantDelegate(neutralDelegateBag)
local turmoilDeck=gameObjectHelpers.getObjectByName("turmoilDeck")
if turmoilDeck==nil then
return
end
local remainingCards=turmoilDeck.getObjects()
local object=remainingCards[#remainingCards]
placeDelegateFromBagInParty(neutralDelegateBag,extractPartiesFromDescription(object.description).distantParty)
end
function changingTimesCoroutine()
log(transientState.turmoilActions)
while transientState.turmoilActions.newGovInProgress or
transientState.turmoilActions.trRevisionInProgress or
transientState.turmoilActions.globalEventInProgress do
coroutine.yield(0)
end
transientState.turmoilActions.changingTimesInProgress=true
recalculateDominance()
local neutralDelegateBag=getObjectFromGUID(gameState.turmoilData.neutralBagId)
local comingZone=getObjectFromGUID(gameState.turmoilData.globalEvents.comingZone)
moveComingEventAndPlaceCurrentNeutralDelegate(comingZone,neutralDelegateBag)
for i=1,30 do coroutine.yield(0) end
recalculateDominance()
for i=1,50 do coroutine.yield(0) end
moveDistantEvent()
for i=1,40 do coroutine.yield(0) end
placeDistantDelegate(neutralDelegateBag)
for i=1,20 do coroutine.yield(0) end
recalculateDominance()
for i=1,20 do coroutine.yield(0) end
recalculatePartyLeads()
for i=1,20 do coroutine.yield(0) end
transientState.turmoilActions.changingTimesInProgress=false
return 1
end
startLuaCoroutine(self,"changingTimesCoroutine")
end
function activatePolicy(playerColor)
local partyInfo=getRulingParty()
local policyBonus=turmoilPartyData.parties[partyInfo.partyId].policyBonus
if policyBonus.oneTimeEffect then
for _,color in pairs(gameState.turmoilData.oneTimeEffectTable) do
if color==playerColor then
return
end
end
end
local turmoilTile=gameObjectHelpers.getObjectByName("turmoilTile")
local isSuccess=objectActivationSystem_doAction({
playerColor=playerColor,
sourceName=policyBonus.friendlyName,
object=turmoilTile,
activationEffects=policyBonus.actionProperties
})
if policyBonus.oneTimeEffect and isSuccess then
table.insert(gameState.turmoilData.oneTimeEffectTable,playerColor)
end
if not isSuccess and turmoilPartyData.parties[partyInfo.partyId].onPolicyActionNotAllowed~=nil then
turmoilPartyData.parties[partyInfo.partyId].onPolicyActionNotAllowed(getPlayerByColor(playerColor))
end
end


function turmoilSetup()
local turmoilTile=gameObjectHelpers.getObjectByName("turmoilTile")
turmoilTile.setPositionSmooth(tablePositions.turmoil.turmoilTile.position)
turmoilTile.setRotation(tablePositions.turmoil.turmoilTile.rotation)
turmoilTile.interactable=false
turmoilTile.setLock(true)
Wait.frames(function()
Wait.condition(
function()
Wait.time(|| setupTurmoilTile(),1)
Wait.time(|| initializeTurmoil(),2)
end,
function() return turmoilTile.resting end
)
end,15)
end
function setupTurmoilTile()
local turmoilTile=getObjectFromGUID(expansions.turmoilTile)
gameState.turmoilData.parties={}
turmoilTile.setSnapPoints({})
local turmoilTransforms=tableHelpers.deepClone(turmoilTile.call("getTurmoilTransforms"))
local allPartyTransforms=turmoilTransforms.parties
setupDominanceMarker(turmoilTile,allPartyTransforms[1].dominance)
for i,partyId in pairs(turmoilPartyData.defaultConfig.parties) do
for _,partyInfo in pairs(turmoilPartyData.parties) do
if partyInfo.id==partyId then
setupTurmoilParty(turmoilTile,allPartyTransforms,partyInfo,i)
end
end
end
changeRulingParty(turmoilPartyData.defaultConfig.startingPartyId)
gameState.turmoilData.parties[1].isDominant=true
setupReserve(turmoilTile,turmoilTransforms.reserveSlots,turmoilTransforms.neutralReserve)
setupGovernmentArea(turmoilTile,turmoilTransforms.chairman,turmoilTransforms.policyTile)
setupLobbyArea(turmoilTile,turmoilTransforms.lobbySlots)
setupGlobalEventArea(turmoilTile,turmoilTransforms.globalEventTransforms)
end
function initializeTurmoil()
function areAllDelegatesCreated()
for _,player in pairs(gameState.allPlayers) do
if not player.neutral then
local delegateBag=getObjectFromGUID(player.delegateBagId)
if delegateBag==nil then
return false
end
if #delegateBag.getObjects() < 7 then
return false
end
end
end
return true
end
function initializeTurmoilCoroutine()
while not areAllDelegatesCreated() do
for i=1,10 do
coroutine.yield(0)
end
end
local turmoilTile=getObjectFromGUID(expansions.turmoilTile)
turmoilTile.call("initialize")
local neutralDelegateBag=getObjectFromGUID(gameState.turmoilData.neutralBagId)
neutralDelegateBag.takeObject({
position=gameState.turmoilData.chairman.transform.pos,
rotation=gameState.turmoilData.chairman.transform.rot,
})
initialNeutralDelegatePlacing(neutralDelegateBag)
Wait.time(|| refreshLobby(),6)
return 1
end
startLuaCoroutine(self,"initializeTurmoilCoroutine")
end
function initialNeutralDelegatePlacing(neutralDelegateBag)
local neutralDelegateBag=getObjectFromGUID(gameState.turmoilData.neutralBagId)
local turmoilDeck=gameObjectHelpers.getObjectByName("turmoilDeck")
local remainingCards=turmoilDeck.getObjects()
placeDelegateFromBagInParty(neutralDelegateBag,extractPartiesFromDescription(remainingCards[#remainingCards].description).distantParty)
Wait.time(turmoilChangingTimes,2)
end
function setupDominanceMarker(turmoilTile,targetTransform)
local dominanceMarker=gameObjectHelpers.getObjectByName("turmoilDominanceMarker")
dominanceMarker.setPosition(vectorHelpers.fromLocalToWorld(turmoilTile,targetTransform.pos))
end
function createSingleSnapPoint(turmoilTile,inputData)
snapPointHelpers.createSingleSnapPoint(turmoilTile,inputData)
end
function createGridSnapPoints(turmoilTile,inputData)
local snapPoints=turmoilTile.getSnapPoints()
local snapGrid=matrixTwoDHelpers.createSnapGrid(turmoilTile,
inputData.pos,
inputData.size2D,
inputData.gridVectors,
inputData.rot[2],
true,
inputData.rot)
for i,sp in pairs(snapGrid) do
local isException=false
if inputData.exceptions~=nil then
for _,exception in pairs(inputData.exceptions) do
local exceptionIndex=(exception[2]-1)*inputData.size2D[1] + exception[1]
if exceptionIndex==i then
isException=true
end
end
end
if not isException then
table.insert(snapPoints,sp)
end
end
turmoilTile.setSnapPoints(snapPoints)
end
function createPartyZone(turmoilTile,grid,partyData,partyId)
local operationId=partyId.."PartyZone"
zoneHelpers.createScriptingZoneFromGrid(turmoilTile,grid,operationId,{0.5,1.3})
Wait.condition(
function()
partyData.mainPartyZone=volatileData.operations[operationId].result
volatileData.operations[operationId]=nil
end,
function() return volatileData.operations[operationId].isDone end
)
end
function createDelegateData(turmoilTile,grid,partyData,partyId)
local operationId=partyId.."PartyGridZones"
partyData.delegates={}
zoneHelpers.createScriptingZoneForEachGridPoint(turmoilTile,grid,operationId,3)
Wait.condition(
function()
for i=1,#grid do
table.insert(partyData.delegates,{zone=volatileData.operations[operationId].result[i],pos=vectorHelpers.fromLocalToWorld(turmoilTile,grid[i])})
end
volatileData.operations[operationId]=nil
end,
function() return volatileData.operations[operationId].isDone end
)
end
function createPartyLeadData(turmoilTile,partyTransforms,partyData,partyId)
local operationId=partyId.."PartyLead"
zoneHelpers.createScriptingZoneFromTransform(turmoilTile,partyTransforms.partyLead,operationId,3)
Wait.condition(
function()
local partyLeadPos=vectorHelpers.fromLocalToWorld(turmoilTile,partyTransforms.partyLead.pos)
partyData.partyLead={pos=partyLeadPos,zoneGuid=volatileData.operations[operationId].result}
volatileData.operations[operationId]=nil
end,
function() return volatileData.operations[operationId].isDone end
)
end
function spawnPartyTile(turmoilTile,partyInfo,transform)
local partyDefaultTile=gameObjectHelpers.getObjectByName("turmoilPartyTile")
local scale=partyDefaultTile.getScale()
local cloneCallback=function(clonedGuid)
local clonedTile=getObjectFromGUID(clonedGuid)
clonedTile.setLock(false)
Wait.time(function()
clonedTile.setLock(true)
clonedTile.setScale(scale)
clonedTile.interactable=false
local customization={}
customization.image=partyInfo.tileImageUrl
clonedTile.setCustomObject(customization)
local reloadedTile=clonedTile.reload()
Wait.frames(|| reloadedTile.call("initialize",{partyId=partyInfo.id}),5)
end,2)
end
local nextSpawnPositionWorld=vectorHelpers.fromLocalToWorld(turmoilTile,transform.pos)
createClonableObject(partyDefaultTile,nextSpawnPositionWorld,vectorHelpers.addVectors(transform.rot,turmoilTile.getRotation()),cloneCallback,true)
end
function setupTurmoilParty(turmoilTile,allPartyTransforms,partyInfo,partyIndex)
local partyTransforms=allPartyTransforms[partyIndex]
local partyId=partyInfo.id
createGridSnapPoints(turmoilTile,partyTransforms.delegates)
createSingleSnapPoint(turmoilTile,partyTransforms.partyLead)
createSingleSnapPoint(turmoilTile,partyTransforms.tile)
createSingleSnapPoint(turmoilTile,partyTransforms.dominance)
local partyData={}
local grid=matrixTwoDHelpers.createGridWithExceptions(
partyTransforms.delegates.pos,
partyTransforms.delegates.size2D,
partyTransforms.delegates.gridVectors,
partyTransforms.delegates.rot[2],
partyTransforms.delegates.exceptions
)
createPartyZone(turmoilTile,grid,partyData,partyId)
createDelegateData(turmoilTile,grid,partyData,partyId)
createPartyLeadData(turmoilTile,partyTransforms,partyData,partyId)
spawnPartyTile(turmoilTile,partyInfo,partyTransforms.tile)
partyData.partyTile={id=partyId,pos=vectorHelpers.fromLocalToWorld(turmoilTile,partyTransforms.tile.pos)}
partyData.dominancePosition=vectorHelpers.fromLocalToWorld(turmoilTile,partyTransforms.dominance.pos)
if gameState.turmoilData.parties==nil then
gameState.turmoilData.parties={}
end
partyData.partyIndex=partyIndex
partyData.partyId=partyId
partyData.isDominant=false
partyData.delegateRotation=vectorHelpers.addVectors(turmoilTile.getRotation(),partyTransforms.delegates.rot)
table.insert(gameState.turmoilData.parties,partyData)
end
function createNeutralDelegates(turmoilTile,genericBag,neutralReserveTransform)
local bagPosition=vectorHelpers.fromLocalToWorld(turmoilTile,neutralReserveTransform.pos)
local bagRotation=neutralReserveTransform.rot
createClonableObject(genericBag,bagPosition,bagRotation,function(clonedObjectGuid)
gameState.turmoilData.neutralBagId=clonedObjectGuid
local neutralBag=getObjectFromGUID(clonedObjectGuid)
neutralBag.setColorTint({89/255,89/255,89/255})
neutralBag.setName("Neutral Delegates")
local neutralDelegateCreatedCallback=function(neutralDelegateIds)
bagProtector.addBagToProtectedList(neutralBag.getGUID())
gameState.turmoilData.neutralDelegateIds=neutralDelegateIds
for _,guid in pairs(neutralDelegateIds) do
bagProtector.addToAllowList(neutralBag.getGUID(),guid)
end
end
createDelegatesForBag(neutralBag,14,"Neutral",neutralDelegateCreatedCallback)
gameState.wasUpdated=true
end)
end
function createPlayerDelegates(turmoilTile,genericBag,player,localPosition,rotation)
if player.neutral then
return
end
local bagPosition=vectorHelpers.fromLocalToWorld(turmoilTile,localPosition)
local bagRotation=rotation
createClonableObject(
genericBag,
bagPosition,
bagRotation,
function(clonedObjectGuid)
player.delegateBagId=clonedObjectGuid
local playerBag=getObjectFromGUID(clonedObjectGuid)
playerBag.setColorTint(stringColorToRGB(player.color))
playerBag.setName(player.color.." Delegates")
local playerDelegateCreatedCallback=function(playerDelegateIds)
player.delegateIds=playerDelegateIds
bagProtector.addBagToProtectedList(playerBag.getGUID())
for _,guid in pairs(playerDelegateIds) do
bagProtector.addToAllowList(playerBag.getGUID(),guid)
end
end
createDelegatesForBag(playerBag,7,player.color,playerDelegateCreatedCallback)
end
)
end
function setupReserve(turmoilTile,playerReserveTransform,neutralReserveTransform)
createGridSnapPoints(turmoilTile,playerReserveTransform)
createSingleSnapPoint(turmoilTile,neutralReserveTransform)
local grid=matrixTwoDHelpers.createGrid(
playerReserveTransform.pos,
playerReserveTransform.size2D,
playerReserveTransform.gridVectors,
playerReserveTransform.rot[2]
)
local genericBag=gameObjectHelpers.getObjectByName("genericDelegateBag")
createNeutralDelegates(turmoilTile,genericBag,neutralReserveTransform)
local playerIndex=1
for _,player in pairs(gameState.allPlayers) do
if not player.neutral then
createPlayerDelegates(turmoilTile,genericBag,player,grid[playerIndex],playerReserveTransform.rot)
playerIndex=playerIndex + 1
end
end
end
function setupLobbyArea(turmoilTile,lobbyTransform)
createGridSnapPoints(turmoilTile,lobbyTransform)
local grid=matrixTwoDHelpers.createGrid(
lobbyTransform.pos,
lobbyTransform.size2D,
lobbyTransform.gridVectors,
lobbyTransform.rot[2]
)
createLobbyZones(turmoilTile,grid)
gameState.turmoilData.lobbyPositions=matrixTwoDHelpers.fromLocalToWorld(turmoilTile,grid)
end
function createLobbyZones(turmoilTile,grid)
local operationId="LobbyZones"
local lobbyZones={}
local zoneHeight=3
zoneHelpers.createScriptingZoneForEachGridPoint(turmoilTile,grid,operationId,zoneHeight)
Wait.condition(
function()
for i=1,#grid do
table.insert(lobbyZones,{zone=volatileData.operations[operationId].result[i],pos=vectorHelpers.fromLocalToWorld(turmoilTile,grid[i])})
end
gameState.turmoilData.lobbyZones=lobbyZones
volatileData.operations[operationId]=nil
end,
function() return volatileData.operations[operationId].isDone end
)
end
function createGlobalEventZone(turmoilTile,transform,id,dataTable)
local operationId=id.."GlobalEventZone"
zoneHelpers.createScriptingZoneFromTransform(turmoilTile,transform,operationId,1,{3.0,1,4.1})
Wait.condition(
function()
dataTable[id]=volatileData.operations[operationId].result
volatileData.operations[operationId]=nil
end,
function() return volatileData.operations[operationId].isDone end
)
end
function setupGlobalEventArea(turmoilTile,globalEventTransforms)
createSingleSnapPoint(turmoilTile,globalEventTransforms.distant)
createSingleSnapPoint(turmoilTile,globalEventTransforms.coming)
createSingleSnapPoint(turmoilTile,globalEventTransforms.current)
gameState.turmoilData.globalEvents={}
gameState.turmoilData.globalEvents.positions={
distant=vectorHelpers.fromLocalToWorld(turmoilTile,globalEventTransforms.distant.pos),
coming=vectorHelpers.fromLocalToWorld(turmoilTile,globalEventTransforms.coming.pos),
current=vectorHelpers.fromLocalToWorld(turmoilTile,globalEventTransforms.current.pos)
}
createGlobalEventZone(turmoilTile,globalEventTransforms.coming,"comingZone",gameState.turmoilData.globalEvents)
createGlobalEventZone(turmoilTile,globalEventTransforms.current,"currentZone",gameState.turmoilData.globalEvents)
local globalEventDeck=gameObjectHelpers.getObjectByName("turmoilGlobalEventDeck")
globalEventDeck.setPosition(gameState.turmoilData.globalEvents.positions.distant)
globalEventDeck.setRotation(turmoilTile.getRotation())
end
function setupGovernmentArea(turmoilTile,chairmanTransform,policyTileTransform,defaultParty)
createSingleSnapPoint(turmoilTile,chairmanTransform)
createSingleSnapPoint(turmoilTile,policyTileTransform)
gameState.turmoilData.chairman={}
gameState.turmoilData.chairman.transform={
pos=vectorHelpers.fromLocalToWorld(turmoilTile,chairmanTransform.pos),
rot=vectorHelpers.addVectors(turmoilTile.getRotation(),chairmanTransform.rot)
}
local operationId="chairmanSetup"
zoneHelpers.createScriptingZoneFromTransform(turmoilTile,chairmanTransform,operationId,3)
Wait.condition(
function()
gameState.turmoilData.chairman.zoneGuid=volatileData.operations[operationId].result
volatileData.operations[operationId]=nil
end,
function() return volatileData.operations[operationId].isDone end
)
local partyPlate=gameObjectHelpers.getObjectByName("turmoilBasePartyPlate")
partyPlate.setPosition(vectorHelpers.fromLocalToWorld(turmoilTile,policyTileTransform.pos))
partyPlate.setRotation(vectorHelpers.addVectors(turmoilTile.getRotation(),policyTileTransform.rot))
end
--
-- probe.setPosition(vectorHelpers.fromLocalToWorld(turmoilTile,{-1.584223,0.05263865,-0.603043}))




function extendPlayerActivationTableau(params)
local tmPlayer=getPlayerByColor(params.playerColor)
paymentSystem.extendByResource(tmPlayer,params.resourceType,params.defaultConversionRate,params.conversionAllowedTags,params.isConstantConversionRate)
end
function getPlayerResource(params)
local playerColor=params.playerColor
local resourceType=string.lower(params.resourceType)
local player=getPlayerByColor(playerColor)
local playerMat=getObjectFromGUID(player.playerArea.playerMat)
local resources=playerMat.call("getResourceStockpile")
return resources[resourceType]
end
function getPlayerProduction(params)
local playerColor=params.playerColor
local resourceType=string.lower(params.resourceType)
local player=getPlayerByColor(playerColor)
local playerMat=getObjectFromGUID(player.playerArea.playerMat)
local resources=playerMat.call("getResourceProduction")
return resources[resourceType]
end
function changePlayerResource(params)
local playerColor=params.playerColor
local resourceType=string.lower(params.resourceType)
local player=getPlayerByColor(playerColor)
local playerMat=getObjectFromGUID(player.playerArea.playerMat)
local currentAmount=playerMat.call("getResourceStockpile")[resourceType]
local delta=0
if params.resourceAmount < -currentAmount then
delta=-currentAmount
else
delta=params.resourceAmount
end
playerMat.call("changeStockpile",{key=resourceType,amount=delta})
local resourceValues={}
resourceValues[resourceType]=delta
eventHandling_triggerEvent({
triggeredByColor=playerColor,
triggerType=eventData.triggerType.storageChanged,
metadata={resourceValues=resourceValues}
})
end
function changePlayerProduction(params)
local playerColor=params.playerColor
local resourceType=string.lower(params.resourceType)
local player=getPlayerByColor(playerColor)
local playerMat=getObjectFromGUID(player.playerArea.playerMat)
local currentProduction=playerMat.call("getResourceProduction")[resourceType]
local delta=params.resourceAmount
if delta < 0 then
if string.lower(resourceType)=="credits" and -delta > currentProduction + 5 then
delta=-(currentProduction + 5)
elseif string.lower(resourceType)~="credits" and -delta > currentProduction then
delta=-currentProduction
end
end
playerMat.call("changeProduction",{key=resourceType,amount=delta})
end
function giveCardsToPlayer(params)
local playerColor=params.playerColor
local amount=params.amount
local fromDiscardPile=params.fromDiscardPile
dealProjectsToPlayer(getPlayerIndexByColor(playerColor),amount,fromDiscardPile)
end
function discardPlayerCards(params)
local playerColor=params.playerColor
local amount=params.amount
discardProjectsFromPlayersHand(getPlayerIndexByColor(playerColor),amount)
end
function getOwnableObjectCount(params)
local who=params.who or "playerThemself"
if who=="playerThemself" then
local player=getPlayerByColor(params.playerColor)
return player.ownedObjects[params.ownableObjectName]
end
if who=="allPlayers" then
local amount=0
for _,player in pairs(gameState.allPlayers) do
amount=amount + player.ownedObjects[params.ownableObjectName]
end
return amount
end
end
function giveCardsToOtherPlayers(params)
local currentPlayerColor=params.playerColor
local amount=params.amount
for _,player in ipairs(gameState.allPlayers) do
if player.color~=currentPlayerColor then
dealProjectsToPlayer(getPlayerIndexByColor(player.color),amount)
end
end
end
function getExtendedScriptingState()
return gameState.extendedScriptingEnabled
end
function giveObjectToPlayer(params)
local playerColor=params.playerColor
local objectName=params.objectName
local isSpecialTile=params.isSpecialTile
local metadata=params.metadata
if objectName=="city" then
dealCityTileToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="greenery" then
dealGreeneryTileToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="ocean" then
dealOceanToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="animal" then
dealAnimalTokenToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="science" then
dealScienceTokenToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="fighter" then
dealFighterTokenToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="ore" then
dealOreTokenToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="microbe" then
dealMicrobeTokenToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="floater" then
dealFloaterTokenToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="data" then
dealDataTokenToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="asteroid" then
dealAsteroidTokenToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="wildCardToken" then
dealWildCardTokenToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="resourceWildCardToken" then
dealResourceWildCardTokenToPlayer(getPlayerIndexByColor(playerColor),metadata)
elseif objectName=="productionWildCardToken" then
dealProductionWildCardTokenToPlayer(getPlayerIndexByColor(playerColor),metadata)
elseif objectName=="programableActionToken" then
dealProgramableActionToken(getPlayerIndexByColor(playerColor),metadata)
elseif objectName=="colonyMarker" or objectName=="playerMarker" then
dealPlayerMarkerToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="delegate" then
dealDelegateToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="floatingArray" then
dealFloatingArrayTileToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="gasMine" then
dealGasMineTileToPlayer(getPlayerIndexByColor(playerColor))
elseif objectName=="venusHabitat" then
dealVenusHabitatTileToPlayer(getPlayerIndexByColor(playerColor))
elseif isSpecialTile~=nil and isSpecialTile then
dealSpecialTileToPlayer(getPlayerIndexByColor(playerColor),objectName)
end
end
function decreaseGlobalParameter(params)
local playerColor=params.playerColor
local parameter=params.parameterType
local sourceName=params.sourceName
local reason=nil
if sourceName~=nil then
reason="player (de)activated "..sourceName
end
if parameter=="tr" then
decreasePlayerTRByColor(playerColor,reason)
elseif parameter=="ocean" then
decreaseOcean(playerColor)
elseif parameter=="o2" then
decreaseO2ButtonClick(nil,playerColor)
elseif parameter=="venus" then
decreaseVenusButtonClick(nil,playerColor)
elseif parameter=="temp" then
decreaseTempButtonClick(nil,playerColor)
end
end
function increaseGlobalParameter(params)
local playerColor=params.playerColor
local parameter=params.parameterType
local sourceName=params.sourceName
local reason=nil
if sourceName~=nil then
reason="player (de)activated "..sourceName
end
if getPlayerByColor(playerColor).neutral then
return
end
if parameter=="tr" then
increasePlayerTRByColor(playerColor,reason)
elseif parameter=="o2" then
increaseO2ButtonClick(nil,playerColor)
elseif parameter=="temp" then
increaseTempButtonClick(nil,playerColor)
elseif parameter=="venus" then
increaseVenusButtonClick(nil,playerColor)
elseif parameter=="ocean" then
logging.printToAll(getPlayerByColor(playerColor).name.." has placed an ocean",{1,1,1},loggingModes.essential)
increaseOcean(playerColor)
end
end
function getCitiesOnMars()
return gameState.citiesOnMars
end
function getCitiesInPlay()
return gameState.citiesOnMars + gameState.citiesInSpace
end
function getOceansInPlay()
return globalParameterSystem.values.ocean.value + globalParameterSystem.values.ocean.extra
end
function cardSupportFunctions_updatePlayerTags(params)
local playedTags=params.tags
local updateTagsAndCount={}
local allWild=true
for i,tag in ipairs(playedTags) do
if not (tag=="WildCard") then
allWild=false
break
end
end
if allWild then
updateTagsAndCount["None"]=1
end
for i,tag in ipairs(playedTags) do
if tag=="Event" then
updateTagsAndCount={}
updateTagsAndCount[tag]=1
break
end
if updateTagsAndCount[tag]~=nil then
updateTagsAndCount[tag]=updateTagsAndCount[tag] + 1
else
updateTagsAndCount[tag]=1
end
end
tagSystem_updatePlayerTags({playerColor=params.playerColor,tagsAndDelta=updateTagsAndCount})
end
function getPlayerTags(params)
local tmPlayer=getPlayerByColor(params.playerColor)
return tmPlayer.tagSystem.tagCounts[params.tagName] or 0
end
function getAllOtherPlayersTags(params)
local tagName=params.tagName
local currentPlayerColor=params.playerColor
local allPlayers=gameState.allPlayers
local totalTagCount=0
for _,tmPlayer in ipairs(allPlayers) do
if tmPlayer.color~=currentPlayerColor then
totalTagCount=totalTagCount + tmPlayer.tagSystem.tagCounts[tagName]
end
end
return totalTagCount
end


function updatePlayerTagsViaObject(params)
local playerColor=params.playerColor
local tagsAndDelta=params.tagsAndDelta
updatePlayersPlayedTags(playerColor,tagsAndDelta,{tagsAndDelta.tag})
end
function updatePlayersOwnedObjects(params)
local playerColor=params.playerColor
local delta=params.delta
local objectName=params.objectName
changeOwnedObjectAmount(playerColor,objectName,delta)
if ownableObjects.specialTileMappings.aliases[objectName]~=nil then
for _,alias in pairs(ownableObjects.specialTileMappings.aliases[objectName]) do
changeOwnedObjectAmount(playerColor,alias,delta)
end
end
end


researchPhaseFunctions={}
researchPhaseFunctions.drafting={}
function researchPhaseFunctions_updatePlayerDraft(params)
local player=getPlayerByColor(params.playerColor)
player.hasDraftPassed=params.draftPass
if params.draftPass then
researchPhaseFunctions.drafting.performDraftStep(draftingData.researchPhase.defaultRule)
end
if player.hasDraftPassed and gameState.drafting.done then
getObjectFromGUID(player.playerArea.playerMat).call("resetDraft")
if gameState.drafting.done then
logging.printToAll("Drafting is considered done. Nothing else to do.")
end
end
end
function researchPhaseFunctions_changeDraftingDirection(params)
researchPhaseFunctions.drafting.switchDraftingDirection(params.direction)
end
researchPhaseFunctions.beginResearchPhase=function(draftingRule)
gameState.currentPhase=phases.draftingPhase
researchPhaseFunctions.drafting.switchDraftingDirection(-gameState.drafting.draftingDirection)
gameState.drafting.currentStep=1
gameState.drafting.currentSubStep=1
gameState.drafting.done=false
gameState.drafting.currentDraftingRule=draftingRule
if not draftingRule.freeDraft then
if draftingRule.draftingSteps[gameState.drafting.currentStep].directionOverride then
researchPhaseFunctions.drafting.switchDraftingDirection(draftingRule.draftingSteps[gameState.drafting.currentStep].directionOverride)
end
end
researchPhaseFunctions.dealCards()
end
researchPhaseFunctions.drafting.performDraftStep=function()
if gameState.drafting.done then return end
local draftingRule=gameState.drafting.currentDraftingRule
local exit=false
for index,player in pairs(gameState.allPlayers) do
if not player.neutral then
if not player.hasDraftPassed or not researchPhaseFunctions.drafting.passCardsAllowed(player.color,draftingRule) then
exit=true
end
end
end
if exit and not gameState.drafting.ignoreRules then return end
local currentDraftingSteps=draftingRule.draftingSteps[gameState.drafting.currentStep]
local direction=gameState.drafting.draftingDirection
researchPhaseFunctions.drafting.passCards(direction)
if draftingRule.freeDraft then return end
gameState.drafting.currentSubStep=gameState.drafting.currentSubStep + 1
if currentDraftingSteps.subSteps[gameState.drafting.currentSubStep]==nil then
gameState.drafting.currentSubStep=1
gameState.drafting.currentStep=gameState.drafting.currentStep + 1
if draftingRule.draftingSteps[gameState.drafting.currentStep]==nil then
gameState.drafting.done=true
return
end
if draftingRule.draftingSteps[gameState.drafting.currentStep].directionOverride then
researchPhaseFunctions.drafting.switchDraftingDirection(draftingRule.draftingSteps[gameState.drafting.currentStep].directionOverride)
end
Wait.frames(|| researchPhaseFunctions.dealCards(),5)
end
end
researchPhaseFunctions.drafting.passCards=function(direction)
local cardsToMove={}
for index,player in pairs(gameState.allPlayers) do
cardsToMove[index]=Player[player.color].getHandObjects()
end
local updatedCardGuidsInDraft={}
for index,player in pairs(gameState.allPlayers) do
if not player.neutral then
local moveToIndex=index + direction
if not gameState.isSoloGame then
if moveToIndex > #gameState.allPlayers then
moveToIndex=1
elseif moveToIndex < 1 then
moveToIndex=#gameState.allPlayers
end
else
moveToIndex=1
end
updatedCardGuidsInDraft[moveToIndex]={}
for _,card in pairs(cardsToMove[index]) do
local nextPlayer=gameState.allPlayers[moveToIndex]
table.insert(updatedCardGuidsInDraft[moveToIndex],card.getGUID())
card.setRotation(getObjectFromGUID(nextPlayer.playerArea.playerMat).getRotation())
Wait.frames(function() card.setPosition(Player[nextPlayer.color].getHandTransform().position) end,1)
end
getObjectFromGUID(player.playerArea.playerMat).call("resetDraft")
player.hasDraftPassed=false
end
end
gameState.drafting.cardsInDraft=updatedCardGuidsInDraft
end
researchPhaseFunctions.drafting.switchDraftingDirection=function(direction)
if direction==nil or direction==0 then
gameState.drafting.draftingDirection=-gameState.drafting.draftingDirection
else
gameState.drafting.draftingDirection=direction
end
for _,player in pairs(gameState.allPlayers) do
local playerMat=getObjectFromGUID(player.playerArea.playerMat)
playerMat.call("updateDraftingArrowDirection",{direction=gameState.drafting.draftingDirection})
end
end
researchPhaseFunctions.drafting.passCardsAllowed=function(playerColor,draftingRule)
if draftingRule.freeDraft then return true end
local currentDraftingSteps=draftingRule.draftingSteps[gameState.drafting.currentStep]
if currentDraftingSteps==nil then return false end
local draftingCardRule=currentDraftingSteps.subSteps[gameState.drafting.currentSubStep]
if draftingCardRule==nil then return false end
local cardGuids={}
local cardsToHandOver=0
if type(draftingCardRule)=="table" then
for key,amount in pairs(draftingCardRule) do
cardsToHandOver=cardsToHandOver + amount
if key=="preludes" then
cardGuids=tableHelpers.combineSingleValueTables({cardGuids,researchPhaseFunctions.drafting.getSpecificCardsInHand(playerColor,{"%(P%)"})})
elseif key=="corps" then
cardGuids=tableHelpers.combineSingleValueTables({cardGuids,researchPhaseFunctions.drafting.getSpecificCardsInHand(playerColor,{"%(C%)"})})
else
cardGuids=tableHelpers.combineSingleValueTables({cardGuids,researchPhaseFunctions.drafting.getSpecificCardsInHand(playerColor,{"%(G%)","%(E%)","%(B%)"})})
end
end
else
cardGuids=researchPhaseFunctions.drafting.getSpecificCardsInHand(playerColor,{"%(G%)","%(E%)","%(B%)"})
cardsToHandOver=draftingCardRule
end
local counter=0
for _,cardGuid in pairs(cardGuids) do
if tableHelpers.contains(gameState.drafting.cardsInDraft[getPlayerIndexByColor(playerColor)],cardGuid) then
counter=counter + 1
end
end
if counter < cardsToHandOver then
logging.printToAll("Player tried to pass,but can only keep "..(cardsToHandOver-#cardGuids).." of the following cards")
for i,guid in pairs(gameState.drafting.cardsInDraft[getPlayerIndexByColor(playerColor)]) do
if not tableHelpers.contains(cardGuids,guid) then
logging.printToAll(getObjectFromGUID(guid).getName())
end
end
return false
elseif cardsToHandOver~=#cardGuids or counter > cardsToHandOver then
return false
end
return true
end
researchPhaseFunctions.drafting.getSpecificCardsInHand=function(playerColor,filterTable)
local cardGuids={}
for _,object in pairs(Player[playerColor].getHandObjects()) do
if object.tag=="Card" then
for _,pattern in pairs(filterTable) do
if string.match(object.getName(),pattern) then
table.insert(cardGuids,object.getGUID())
break
end
end
end
end
return cardGuids
end
researchPhaseFunctions.dealCards=function()
function researchPhaseFunctions_dealCardsCoroutine()
local waitCounter=0
while waitCounter < 15 do
waitCounter=waitCounter + 1
if transientState.creatingPlayer or transientState.removingPlayer then
waitCounter=0
end
coroutine.yield(0)
end
gameState.drafting.cardsInDraft={}
local draftingRule=gameState.drafting.currentDraftingRule
local draftingStep=draftingRule.draftingSteps[gameState.drafting.currentStep]
for playerIndex,player in pairs(gameState.allPlayers) do
if not player.neutral then
gameState.drafting.cardsInDraft[playerIndex]={}
local blockedHands={}
for type,amountAndTargetIndex in pairs(draftingStep.cardsToDeal) do
table.insert(blockedHands,amountAndTargetIndex.targetHandIndex)
end
for _,blockedIndex in pairs(blockedHands) do
local nonBlockedHandIndex=blockedIndex
while tableHelpers.contains(blockedHands,nonBlockedHandIndex) do
nonBlockedHandIndex=nonBlockedHandIndex + 1
coroutine.yield(0)
end
for _,object in pairs(Player[player.color].getHandObjects(blockedIndex)) do
object.setPosition(Player[player.color].getHandTransform(nonBlockedHandIndex).position)
end
end
for i=1,3 do coroutine.yield(0) end
for type,amountAndTargetIndex in pairs(draftingStep.cardsToDeal) do
local wereCardsDealt=false
if type=="projects" then
for i=1,amountAndTargetIndex.amount + player.drafting.extraDraftCardsDealt do
dealProjectsToPlayer(playerIndex,1,false,amountAndTargetIndex.targetHandIndex)
end
elseif type=="preludes" and gameState.activeExpansions.prelude then
for i=1,amountAndTargetIndex.amount do
local preludeDeck=gameObjectHelpers.getObjectByName("preludeDeck")
preludeDeck.deal(1,player.color,amountAndTargetIndex.targetHandIndex)
end
elseif type=="corps" then
for i=1,amountAndTargetIndex.amount do
local corpDeck=gameObjectHelpers.getObjectByName("corpDeck")
corpDeck.deal(1,player.color,amountAndTargetIndex.targetHandIndex)
end
end
end
end
end
for playerIndex,player in pairs(gameState.allPlayers) do
for type,amountAndTargetIndex in pairs(draftingStep.cardsToDeal) do
if type~="preludes" or gameState.activeExpansions.prelude then
local counter=25
while counter > 1 do
counter=counter - 1
if dealingInProgress or #Player[player.color].getHandObjects(amountAndTargetIndex.targetHandIndex)==0 then counter=25 end
coroutine.yield(0)
end
for _,object in pairs(Player[player.color].getHandObjects(amountAndTargetIndex.targetHandIndex)) do
if not tableHelpers.contains(gameState.drafting.cardsInDraft[playerIndex],object.getGUID()) then
table.insert(gameState.drafting.cardsInDraft[playerIndex],object.getGUID())
else
log("Something broke...")
end
end
end
end
end
return 1
end
startLuaCoroutine(self,"researchPhaseFunctions_dealCardsCoroutine")
end


gameMap=hexMapHelpers.makeMapComputeFriendly(predefinedMaps.baseMap)
venusMap=nil
function hexMap_applyPlacementBonuses(params)
local position=params.position
local playerColor=params.playerColor
local tmPlayer=getPlayerByColor(playerColor)
local tileObject=params.tileObject
local object=params.object
local ignorePlacementEffects=params.ignorePlacementEffects
local ignoreSpecificEffects=params.ignoreEffects or {}
local mapInfos=getMapInfos(position)
if mapInfos==nil then
return true
end
local isAllowed=true
if playerColor==nil then
registerObjectOnTile(mapInfos,position,tileObject)
else
if object~=nil then
local tmPlayer=getPlayerByColor(playerColor)
if not cardActivationRules.rules.notInAnyHandZoneRule(tmPlayer,object) then
return false
end
end
local placementProperties={}
local adjacenyPlacementProperties={}
if not tmPlayer.neutral and gameState.extendedScriptingEnabled and gameState.currentPhase~=phases.solarPhase then
local returnValues=applyTileEffects(mapInfos,position,playerColor,tileObject,ignorePlacementEffects,ignoreSpecificEffects)
isAllowed=returnValues.isAllowed
allPlacementProperties=returnValues.placementProperties
adjacenyPlacementProperties=returnValues.adjacenyPlacementProperties
end
if isAllowed then
registerObjectOnTile(mapInfos,position,tileObject)
eventHandling_triggerEvent({triggeredByColor=playerColor,
triggerType=mapInfos.triggerType,
metadata={placementProperties=allPlacementProperties,
adjacenyPlacementProperties=adjacenyPlacementProperties,
tileObject=tileObject,
position=position}} )
end
end
gameMap.metadata.wasUpdated=true
return isAllowed
end
function getMapInfos(position)
local marsTileMap=gameObjectHelpers.getObjectByName("gameMap")
local venusMapTile=gameObjectHelpers.getObjectByName("venusMapTile")
if gameMap~=nil and hexMapHelpers.isOnMapTile(gameMap,position,marsTileMap)==true then
return {map=gameMap,mapTile=marsTileMap,triggerType=eventData.triggerType.marsTilePlaced}
elseif venusMap~=nil and hexMapHelpers.isOnMapTile(venusMap,position,venusMapTile)==true then
return {map=venusMap,mapTile=venusMapTile,triggerType=eventData.triggerType.venusTilePlaced}
else
return nil
end
end
function hexMap_removeTileObject(params)
local position=params.position
local playerColor=params.playerColor
local tileObject=params.tileObject
local mapInfos=getMapInfos(position)
if mapInfos==nil then
return true
end
local isAllowed=true
if gameState.extendedScriptingEnabled and gameState.currentPhase~=phases.solarPhase and not params.ignorePlacementEffects then
isAllowed=undoTileEffects(mapInfos,position,playerColor)
end
if isAllowed then
unregisterObjectOnTile(mapInfos,position,tileObject)
end
gameMap.metadata.wasUpdated=true
return isAllowed
end
function hexMap_getNeighbours(params)
return hexMapHelpers.getNeighboursFromIndices(gameMap,params.indices)
end
function hexMap_getTiles(params)
if params~=nil then
if params.mapName=="marsMap" then
return gameMap.tiles
elseif params.mapName=="venusMap" then
return venusMap.tiles
end
end
return gameMap.tiles
end
function undoTileEffects(mapInfos,position,playerColor)
local map=mapInfos.map
local mapTile=mapInfos.mapTile
local tile=hexMapHelpers.getTileFromWorldCoordinates(map,position,mapTile)
local placementProperties={}
if tile~=nil and #tile.tileObjects==1 then
placementProperties=tableHelpers.deepCloneTable(tile.placementProperties)
end
if placementProperties.resourceValues==nil then
placementProperties.resourceValues={}
end
if placementProperties.productionValues==nil then
placementProperties.productionValues={}
end
local adjacenyEffects=getAdjacencyEffects(map,position,mapTile)
placementProperties=combinePlacementEffects(placementProperties,adjacenyEffects)
placementProperties.effects={}
for key,value in pairs(placementProperties.resourceValues) do
placementProperties.resourceValues[key]=-value
end
for key,value in pairs(placementProperties.productionValues) do
placementProperties.productionValues[key]=-value
end
local isAllowed=Global.call("objectActivationSystem_doAction",{activationEffects=placementProperties,sourceName="tile placement",playerColor=playerColor,object=nil})
return isAllowed
end
function applyTileEffects(mapInfos,position,playerColor,tileObject,ignorePlacementEffects,ignoreSpecificEffects)
local map=mapInfos.map
local mapTile=mapInfos.mapTile
local tile=hexMapHelpers.getTileFromWorldCoordinates(map,position,mapTile)
log(tile)
local placementProperties={}
if not ignorePlacementEffects then
if tile~=nil and (tile.tileObjects==nil or #tile.tileObjects==0 ) then
placementProperties=tableHelpers.deepCloneTable(tile.placementProperties)
end
end
if placementProperties.resourceValues==nil then
placementProperties.resourceValues={}
end
if placementProperties.productionValues==nil then
placementProperties.productionValues={}
end
if placementProperties.effects==nil then
placementProperties.effects={}
end
local adjacenyEffects=getAdjacencyEffects(map,position,mapTile,ignoreSpecificEffects)
placementProperties=combinePlacementEffects(placementProperties,adjacenyEffects)
if #ignoreSpecificEffects > 0 then
local cleanedUpEffects={}
for _,effect in pairs(placementProperties.effects) do
local ignore=false
for _,ignoredEffect in pairs(ignoreSpecificEffects) do
if effect==ignoredEffect then
ignore=true
end
end
if not ignore then
table.insert(cleanedUpEffects,effect)
end
end
placementProperties.effects=cleanedUpEffects
end
if not handleHazardTiles(map,position,mapTile,playerColor) then
return {isAllowed=false,placementProperties=placementProperties,adjacenyPlacementProperties=adjacenyEffects}
end
local isAllowed=Global.call("objectActivationSystem_doAction",{activationEffects=placementProperties,sourceName="tile placement",playerColor=playerColor,object=nil})
return {isAllowed=isAllowed,placementProperties=placementProperties,adjacenyPlacementProperties=adjacenyEffects}
end
function handleHazardTiles(map,position,mapTile,playerColor)
local tile=hexMapHelpers.getTileFromWorldCoordinates(map,position,mapTile,playerColor)
if tile~=nil and tile.tileObjects~=nil  then
for _,tileObject in pairs(tile.tileObjects) do
if tileObject.objectName=="Duststorm" or tileObject.objectName=="Erosion" then
local result=getObjectFromGUID(tileObject.guid).call("deactivateObjectRemotely",{playerColor=playerColor})
return result
end
end
end
return true
end
function getAdjacencyEffects(map,position,mapTile,ignoreSpecificEffects)
local adjacenyEffects={}
for _,neighbourTile in pairs(hexMapHelpers.getNeighboursFromWorldCoordinates(map,position,mapTile)) do
if neighbourTile.tileObjects~=nil and next(neighbourTile.tileObjects)~=nil then
for _,tileObject in pairs(neighbourTile.tileObjects) do
for effectType,keyValuePairs in pairs(tableHelpers.deepClone(tileObject.adjacenyEffects)) do
addAdjacencyEffect(adjacenyEffects,effectType,keyValuePairs,tileObject.objectName)
end
end
elseif neighbourTile.adjacenyEffects~=nil then
for effectType,keyValuePairs in pairs(tableHelpers.deepClone(neighbourTile.adjacenyEffects)) do
addAdjacencyEffect(adjacenyEffects,effectType,keyValuePairs,"tile")
end
end
end
return adjacenyEffects
end
function addAdjacencyEffect(adjacenyEffects,effectType,keyValuePairs,sourceName)
if adjacenyEffects[sourceName]~=nil then
for key,value in pairs(keyValuePairs) do
if tonumber(key)~=nil then
if adjacenyEffects[sourceName]["effects"]==nil then
adjacenyEffects[sourceName]["effects"]={}
end
table.insert(adjacenyEffects[sourceName]["effects"],value)
else
if adjacenyEffects[sourceName][effectType]==nil then
adjacenyEffects[sourceName][effectType]={}
end
if adjacenyEffects[sourceName][effectType][key]~=nil then
adjacenyEffects[sourceName][effectType][key]=adjacenyEffects[sourceName][effectType][key] + value
else
adjacenyEffects[sourceName][effectType][key]=value
end
end
end
else
adjacenyEffects[sourceName]={}
adjacenyEffects[sourceName][effectType]=keyValuePairs
end
end
function combinePlacementEffects(placementProperties,adjacenyEffects)
local combinedProperties=placementProperties
for tileObjectName,effects in pairs(adjacenyEffects) do
for effectType,keyValuePairs in pairs(effects) do
if combinedProperties[effectType]~=nil then
for key,value in pairs(keyValuePairs) do
if tonumber(key)~=nil then
table.insert(combinedProperties["effects"],value)
else
if combinedProperties[effectType][key]~=nil then
combinedProperties[effectType][key]=combinedProperties[effectType][key] + value
else
combinedProperties[effectType][key]=value
end
end
end
else
combinedProperties[effectType]=keyValuePairs
end
end
end
return combinedProperties
end
function registerObjectOnTile(mapInfos,position,tileObject)
local map=mapInfos.map
local mapTile=mapInfos.mapTile
local tile=hexMapHelpers.getTileFromWorldCoordinates(map,position,mapTile)
if tile==nil then
return
end
if tile.tileObjects==nil then
tile.tileObjects={}
end
table.insert(tile.tileObjects,tileObject)
map.metadata.wasUpdated=true
end
function unregisterObjectOnTile(mapInfos,position,tileObject,mapTile)
local map=mapInfos.map
local mapTile=mapInfos.mapTile
local tile=hexMapHelpers.getTileFromWorldCoordinates(map,position,mapTile)
if tile==nil then
return
end
for index,obj in pairs(tile.tileObjects) do
if obj.guid==tileObject.guid then
table.remove(tile.tileObjects,index)
end
end
end


mapGeneratorFunctions={}
--   choose between custom map or predefined map
--   if predefined:
--
--     - titanium (tileEffect - value between 0 and 100,sum is 100)
--     - energy (tileEffect - value between 0 and 100,sum is 100)
--     - regular tiles (tile - value between 0 and 100,sum is 100 - e.g. only one effect like card draw,plants,etc.)
--     - number of initial erosions (min 0,max 5) if ares
--
--     - number of oxygen steps
--   global parameter bonus configuration:
--         --> bonuses need to be at least 2 steps apart (a practical limitation)
--              (select resourceType and amount,can be negative),can be done several times --> needs custom token with description/tooltip



scriptVersion=1
lastClonedSelfGuid=nil
loadCallback=nil
saveCallback=nil
defaultObjectState={wasUpdated=true}
function onLoad(save_state)
if save_state~=nil and save_state~="" then
local loaded_data=JSON.decode(save_state)
if loaded_data.scriptVersion~=scriptVersion then
save_sate=nil
end
end
if save_state~=nil and save_state~="" then
local loaded_data=JSON.decode(save_state)
objectState=loaded_data.objectState
if type(loadCallback)=="function" then
loadCallback(true)
end
else
objectState=defaultObjectState
if type(loadCallback)=="function" then
loadCallback(false)
end
end
end
function onSave()
if not objectState.wasUpdated then
return
end
if type(saveCallback)=="function" then
saveCallback()
end
objectState.wasUpdated=false
return JSON.encode({objectState=objectState,scriptVersion=scriptVersion})
end



timerButtons={}
timerButtons.buttonInfos={
{
click_function='timerButtons_pauseUnpauseTimer',
label='Pause timer',
function_owner=Global,
position={0.00,0.15,-0.3},
rotation={0,0,0},
width=2500,
height=500,
font_size=200,
scale={0.2,1,0.2},
color={1,155/255,25/255},
id="isPaused"},
{
click_function='timerButtons_changeSecondsPlusPerGeneration',
label='End Generation: 120s',
baseLabel="End Generation: ",
function_owner=Global,
position={-1.4,0.15,0.00},
rotation={0,0,0},
width=2500,
height=500,
font_size=200,
scale={0.2,1,0.2},
color={1,155/255,25/255},
id="secondsPlusPerGeneration"},
{
click_function='timerButtons_changeSecondsPerEndTurn',
label='End Turn: 15s',
baseLabel="End Turn: ",
function_owner=Global,
position={0,0.15,0.00},
rotation={0,0,0},
width=2500,
height=500,
font_size=200,
scale={0.2,1,0.2},
color={1,155/255,25/255},
id="secondsPlusPerEndTurn"},
{
click_function='timerButtons_changeSecondsInitial',
label='Starting Time: 1200s',
baseLabel="Starting Time: ",
function_owner=Global,
position={1.4,0.15,0.00},
rotation={0,0,0},
width=2500,
height=500,
font_size=200,
scale={0.2,1,0.2},
color={1,155/255,25/255},
id="secondsInitial"},
{
click_function='timerButtons_changeNegativeVpThreshold',
label='',
tooltip="Only has an effect with timeout action 'Negative VPs'",
function_owner=Global,
position={1.4,0.15,0.30},
rotation={0,0,0},
width=2500,
height=500,
font_size=200,
scale={0.2,1,0.2},
color={1,155/255,25/255},
dynamicLabel={prefix="Negative VP Threshold:\n",
value={"transientState.timerConfiguration.negativeVpThreshold","gameConfig.timerConfiguration.negativeVpThreshold"},
suffix="s"}},
{
click_function='timerButtons_changeSecondsPerNegativeVp',
label='',
tooltip="Only has an effect with timeout action 'Negative VPs'",
function_owner=Global,
position={0.00,0.15,0.30},
rotation={0,0,0},
width=2500,
height=500,
font_size=200,
scale={0.2,1,0.2},
color={1,155/255,25/255},
dynamicLabel={prefix="Seconds Per Negative VP:\n",
value={"transientState.timerConfiguration.secondsPerNegativeVp","gameConfig.timerConfiguration.secondsPerNegativeVp"},
suffix="s"}},
{
click_function='timerButtons_changeTimeoutAction',
label='On Time Elapsed: Do nothing',
function_owner=Global,
position={1.4,0.15,-0.3},
rotation={0,0,0},
width=2500,
height=500,
font_size=175,
scale={0.2,1,0.2},
color={1,155/255,25/255},
id="timeoutAction"},
{
click_function='timerButtons_changeFactor',
label='1',
baseLabel="",
tooltip="Amount of seconds added/subtracted when modifying timer values.",
function_owner=Global,
position={-1.6,0.15,-0.75},
rotation={0,0,0},
width=850,
height=500,
font_size=300,
scale={0.2,1,0.2},
color={1,155/255,25/255},
id="delta"},
{
click_function='timerButtons_togglePauseOnDraft',
label='Pause on draft',
baseLabel="",
tooltip="",
function_owner=Global,
position={-1.4,0.15,-0.3},
rotation={0,0,0},
width=2500,
height=500,
font_size=200,
scale={0.2,1,0.2},
color={1,155/255,25/255},
onIndex="gameState.timerConfiguration.pauseOnDraft"},
{
click_function="noOperation",
label="i",
tooltip="Remarks about the timer settings:\n"..
"- Sum of 'End Generation' seconds and six times 'End Turn' seconds must add up to at least 120 seconds.\n"..
"    This shall avoid situations where players are completely knocked out of the game.\n"..
"- Timer starts counting for the first player as soon as 'Start Nth generation' is pressed.\n"..
"- After the game has started changes to the timer configuration will only apply with the start of the next generation.\n"..
"    This shall avoid abuse of the timer settings tile.",
function_owner=Global,
position={-2.1,0.15,-0.75},
rotation={0,0,0},
width=500,
height=500,
font_size=420,
scale={0.2,1,0.2},
color={1,155/255,25/255},
}
}
timerButtons.updateButtons=function()
local timerTile=gameObjectHelpers.getObjectByName("timerConfigTile")
local fromScratch=timerTile.getButtons()==nil
local buttonAmount=0
local timerConfiguration=timerFunctions.getTimerConfiguration()
for i,buttonInfo in pairs(timerButtons.buttonInfos) do
buttonInfo.index=buttonAmount
if buttonInfo.id=="timeoutAction" then
if timerConfiguration.timeoutAction=="doNothing" then
buttonInfo.label="Timeout Action: Do Nothing"
buttonInfo.tooltip="Nothing will happen if time runs out for a player.\n"..
"Time will continue ticking away into negative."
elseif timerConfiguration.timeoutAction=="endTurn" then
buttonInfo.label="Timeout Action: End Turn"
buttonInfo.tooltip="If time runs out a player automatically ends their turn.\n"..
"If added time from 'End Turn' is 0 then that player will pass for the remaining generation.\n"
elseif timerConfiguration.timeoutAction=="giveNegativeVPs" then
buttonInfo.label="Timeout Action: Negative VPs"
buttonInfo.tooltip="Get negative VPs at the end of the game if your timer is below the threshold.\n"
end
elseif buttonInfo.id=="isPaused" then
if timerConfiguration.isPaused then
buttonInfo.label="Timer is currently paused"
else
buttonInfo.label="Click to pause the timer"
end
else
for settingName,value in pairs(timerConfiguration) do
if settingName==buttonInfo.id then
buttonInfo.label=buttonInfo.baseLabel..value.."s"
end
end
end
if fromScratch then
timerTile.createButton(buttonInfo)
else
timerTile.editButton(buttonInfo)
end
buttonAmount=buttonAmount + 1
end
buttonFunctions.createButtons(timerTile,timerButtons.buttonInfos)
end
function timerButtons_pauseUnpauseTimer(obj,playerColor,altClick)
timerFunctions.pauseUnpauseTimer()
timerButtons.updateButtons()
end
function timerButtons_changeSecondsPlusPerGeneration(obj,playerColor,altClick)
local sign=altClick and -1 or 1
timerFunctions.changeConfigValue("secondsPlusPerGeneration",sign,0,3600)
timerButtons.updateButtons()
end
function timerButtons_changeSecondsPerEndTurn(obj,playerColor,altClick)
local sign=altClick and -1 or 1
timerFunctions.changeConfigValue("secondsPlusPerEndTurn",sign,0,300)
timerButtons.updateButtons()
end
function timerButtons_changeSecondsInitial(obj,playerColor,altClick)
local sign=altClick and -1 or 1
timerFunctions.changeConfigValue("secondsInitial",sign,120,36000)
timerButtons.updateButtons()
end
function timerButtons_changeFactor(obj,playerColor,altClick)
timerFunctions.changeFactor(altClick)
timerButtons.updateButtons()
end
function timerButtons_changeTimeoutAction(obj,playerColor,altClick)
local sign=altClick and -1 or 1
timerFunctions.toggleTimeoutAction(sign)
timerButtons.updateButtons()
end
function timerButtons_togglePauseOnDraft(_,_,_)
local timerConfiguration=timerFunctions.getTimerConfiguration()
timerConfiguration.pauseOnDraft=not timerConfiguration.pauseOnDraft
if gameState.timerConfiguration==nil then
gameState.timerConfiguration={}
end
gameState.timerConfiguration.pauseOnDraft=timerConfiguration.pauseOnDraft
timerButtons.updateButtons()
end
function timerButtons_changeSecondsPerNegativeVp(_,_,altClick)
local sign=altClick and -1 or 1
timerFunctions.changeConfigValue("secondsPerNegativeVp",sign,10,600)
timerButtons.updateButtons()
end
function timerButtons_changeNegativeVpThreshold(_,_,altClick)
local sign=altClick and -1 or 1
timerFunctions.changeConfigValue("negativeVpThreshold",sign,-3600,0)
timerButtons.updateButtons()
end


timerFunctions={}
timerFunctions.setupTimer=function()
local timerConfigTile=gameObjectHelpers.getObjectByName("timerConfigTile")
timerConfigTile.setPositionSmooth(tablePositions.gameBoardAssets.timerTile.pos)
timerConfigTile.setRotation(tablePositions.gameBoardAssets.timerTile.rot)
timerButtons.updateButtons()
end
timerFunctions.initializeTimer=function(inputConfig)
gameState.timerConfiguration=tableHelpers.deepClone(inputConfig)
transientState.timerConfiguration=tableHelpers.deepClone(inputConfig)
for _,player in pairs(gameState.allPlayers) do
player.timer={time=gameConfig.timerConfiguration.secondsInitial,isRunning=false}
end
gameState.allPlayers[gameState.firstPlayer].timer.isRunning=true
timerFunctions.startTimer()
end
timerFunctions.getFormattedRemainingTimeForPlayer=function(player)
if player.neutral then
return
end
local remainingTime=player.timer.time
local prefix=""
if remainingTime < 0 then
remainingTime=remainingTime * -1
prefix="-"
end
local remainingMinutes=tostring(math.floor(remainingTime/60))
local remainingSeconds=tostring(remainingTime % 60)
return string.format(prefix.."%02d:",remainingMinutes)..string.format("%02d",remainingSeconds)
end
timerFunctions.startTimer=function()
function runTimerCoroutine()
local oldTime=Time.time
while true do
for i=1,10 do
coroutine.yield(0)
end
local newTime=Time.time
if not gameState.timerConfiguration.isPaused then
if gameState.currentPhase==phases.generationPhase then
for i,player in pairs(gameState.allPlayers) do
if not player.neutral and player.timer.isRunning then
player.timer.time=player.timer.time - (newTime - oldTime)
updatePlayerName(i)
if player.timer.time < 0 then
timerFunctions.onTimerRunsOut(player)
end
end
end
elseif gameState.currentPhase==phases.draftingPhase and not gameState.timerConfiguration.pauseOnDraft then
for i,player in pairs(gameState.allPlayers) do
if not player.neutral and not player.hasDraftPassed then
player.timer.time=player.timer.time - (newTime - oldTime)
updatePlayerName(i)
end
end
end
end
oldTime=Time.time
if gameState.currentPhase==phases.gameEndPhase then
return 1
end
end
end
startLuaCoroutine(self,"runTimerCoroutine")
end
timerFunctions.getTimerConfiguration=function()
if gameState.started then
if transientState.timerConfiguration==nil then
transientState.timerConfiguration=tableHelpers.deepClone(gameState.timerConfiguration)
end
return transientState.timerConfiguration
else
return gameConfig.timerConfiguration
end
end
timerFunctions.pauseUnpauseTimer=function()
if gameState.started then
gameState.timerConfiguration.isPaused=not gameState.timerConfiguration.isPaused
transientState.timerConfiguration.isPaused=gameState.timerConfiguration.isPaused
end
end
timerFunctions.changeConfigValue=function(configName,signum,min,max)
min=min or 0
max=max or 36000
local timerConfiguration=timerFunctions.getTimerConfiguration()
local oldValue=timerConfiguration[configName]
timerConfiguration[configName]=timerConfiguration[configName] + timerConfiguration.delta * signum
if timerConfiguration[configName] > max then
timerConfiguration[configName]=max
elseif timerConfiguration[configName] < min then
timerConfiguration[configName]=min
end
if not timerFunctions.checkIfTimerIsReasonable() and signum==-1 then
timerConfiguration[configName]=oldValue
end
end
timerFunctions.changeFactor=function(altClick)
local factor=10
if altClick then factor=1/10 end
local timerConfiguration=timerFunctions.getTimerConfiguration()
local newValue=timerConfiguration.delta * factor
if newValue > 1000 then
newValue=1000
elseif newValue < 1 then
newValue=1
end
timerConfiguration.delta=newValue
end
timerFunctions.checkIfTimerIsReasonable=function()
local timerConfiguration=timerFunctions.getTimerConfiguration()
local time=timerConfiguration.secondsPlusPerGeneration + timerConfiguration.secondsPlusPerEndTurn * 6
if time >= 120 then
return true
else
logging.broadcastToAll("Cannot change timer values.")
logging.broadcastToAll("Sum of gained seconds per generation and 6 times gained seconds per end turn have to be at least 120 seconds.")
end
end
timerFunctions.onEndGeneration=function()
for i,player in pairs(gameState.allPlayers) do
if not player.neutral then
player.timer.time=player.timer.time +
gameState.timerConfiguration.secondsPlusPerGeneration +
gameState.timerConfiguration.secondsPlusPerEndTurn
if i==gameState.firstPlayer then
player.timer.isRunning=true
end
end
end
if transientState.timerConfiguration~=nil then
gameState.timerConfiguration=tableHelpers.deepClone(transientState.timerConfiguration)
end
end
timerFunctions.onPlayerTurnEnd=function(playerIndex)
local player=gameState.allPlayers[playerIndex]
player.timer.isRunning=false
player.timer.time=player.timer.time + gameState.timerConfiguration.secondsPlusPerEndTurn
end
timerFunctions.onTimerRunsOut=function(player)
if gameState.timerConfiguration.timeoutAction=="doNothing" then
return
elseif gameState.timerConfiguration.timeoutAction=="endTurn" then
player.timer.time=0
endTurn()
elseif gameState.timerConfiguration.timeoutAction=="giveNegativeVPs" then
return
end
end
timerFunctions.toggleTimeoutAction=function(delta)
local timerConfiguration=timerFunctions.getTimerConfiguration()
for i,actionName in pairs(timerData.timeoutActions) do
if actionName==timerConfiguration.timeoutAction then
local newSelection=i + delta
if newSelection > #timerData.timeoutActions then
newSelection=1
elseif newSelection < 1 then
newSelection=#timerData.timeoutActions
end
timerConfiguration.timeoutAction=timerData.timeoutActions[newSelection]
return
end
end
end


logging={
currentModeName=loggingRules[5].name,
currentMode=loggingRules[5].modes,
fallbackToSystemLog=true,
}
function changeLoggingMode(params)
logging.currentModeName=params.newModeName
logging.currentMode=params.newMode
end
function toggleFallbackToSystemLog(params)
if logging.fallbackToSystemLog and params.newState==2 then
logging.fallbackToSystemLog=not logging.fallbackToSystemLog
elseif not logging.fallbackToSystemLog and params.newState==1 then
logging.fallbackToSystemLog=not logging.fallbackToSystemLog
end
end
function logging_printToAll(params)
logging.printToAll(params.message,params.messageColor,params.loggingMode)
end
function logging_printToColor(params)
logging.printToColor(params.message,params.playerColor,params.messageColor,params.loggingMode)
end
function logging_broadcastToAll(params)
logging.broadcastToAll(params.message,params.messageColor,params.loggingMode)
end
function logging_broadcastToColor(params)
logging.broadcastToColor(params.message,params.playerColor,params.messageColor,params.loggingMode)
end
logging.printToAll=function(message,messageColor,loggingMode)
if not isLoggingModeActive(loggingMode) then
if logging.fallbackToSystemLog then
log(message)
end
return
end
printToAll(message,messageColor)
end
logging.printToColor=function(message,playerColor,messageColor,loggingMode)
if not isLoggingModeActive(loggingMode) or not Player[playerColor].seated then
if logging.fallbackToSystemLog then
log(message)
end
return
end
printToColor(message,playerColor,messageColor)
end
logging.broadcastToAll=function(message,messageColor,loggingMode)
if not isLoggingModeActive(loggingMode) then
if logging.fallbackToSystemLog then
log(message)
end
return
end
broadcastToAll(message,messageColor)
end
logging.broadcastToColor=function(message,playerColor,messageColor,loggingMode)
if not isLoggingModeActive(loggingMode) or not Player[playerColor].seated then
if logging.fallbackToSystemLog then
log(message)
end
return
end
broadcastToColor(message,playerColor,messageColor)
end
function isLoggingModeActive(loggingMode)
if loggingMode==nil then
loggingMode=loggingModes.unimportant
end
for _,checkValue in pairs(logging.currentMode) do
if loggingMode==checkValue then
return true
end
end
return false
end



objectActivationEffects={}
objectActivationEffects={}
objectActivationEffects.drawCardFunction=function(amount)
return function(playerColor,sourceName)
logging.printToAll(playerColor.." got "..amount.." card(s) from "..sourceName,playerColor,loggingModes.detail)
Global.call("giveCardsToPlayer",{playerColor=playerColor,amount=amount})
end
end
objectActivationEffects.drawCardFromDiscard=function(amount)
return function(playerColor,sourceName)
logging.printToAll(playerColor.." got "..amount.." discarded card(s) from "..sourceName,playerColor,loggingModes.detail)
Global.call("giveCardsToPlayer",{playerColor=playerColor,amount=amount,fromDiscardPile=true})
end
end
objectActivationEffects.shuffleDiscardPile=function()
return function(playerColor,sourceName)
logging.printToAll(playerColor.." shuffled the discard pile because of an effect from "..sourceName,playerColor,loggingModes.detail)
shuffleDiscardPile()
end
end
objectActivationEffects.discardCardFunction=function(amount)
return function(playerColor,sourceName)
logging.printToAll(playerColor.." discarded "..amount.." card(s) for "..sourceName,playerColor,loggingModes.detail)
Global.call("discardPlayerCards",{playerColor=playerColor,amount=amount})
end
end
objectActivationEffects.othersDrawCardFunction=function(amount)
return function(playerColor,sourceName)
for i,player in ipairs(gameState.allPlayers) do
if player.color~=playerColor then
logging.printToAll(player.color.." got "..amount.." cards from "..sourceName,player.color,loggingModes.detail)
Global.call("giveCardsToPlayer",{playerColor=player.color,amount=amount})
end
end
end
end
objectActivationEffects.increaseGlobalParameterFunction=function(parameterType)
return function(playerColor,source)
Global.call("increaseGlobalParameter",{parameterType=parameterType,playerColor=playerColor,sourceName=source})
return true
end
end
objectActivationEffects.decreaseGlobalParameterFunction=function(parameterType)
return function(playerColor,source)
Global.call("decreaseGlobalParameter",{parameterType=parameterType,playerColor=playerColor,sourceName=source})
return true
end
end
objectActivationEffects.drawObjectFunction=function(objectName,isSpecialTile)
return function(playerColor,sourceName,metadata)
logging.printToAll(playerColor.." got a(n) "..objectName.." from "..sourceName,playerColor,loggingModes.detail)
Global.call("giveObjectToPlayer",{playerColor=playerColor,objectName=objectName,isSpecialTile=isSpecialTile,metadata=metadata})
return true
end
end
objectActivationEffects.spawnNewFleet=function()
return function(playerColor,sourceName)
logging.printToAll(playerColor.." got a new fleet from "..sourceName,playerColor,loggingModes.detail)
colonySystem.spawnFleet(playerColor)
end
end
objectActivationEffects.payCard=function()
return function(playerColor,sourceName)
logging.printToColor(playerColor.." bought a card",playerColor,playerColor,loggingModes.unimportant)
end
end
objectActivationEffects.increasePathfinderTrackEvent=function(trackName)
return function(playerColor)
local triggerType=nil
if trackName=="venus" then
triggerType=eventData.triggerType.increasePathfinderVenus
elseif trackName=="earth" then
triggerType=eventData.triggerType.increasePathfinderEarth
elseif trackName=="mars" then
triggerType=eventData.triggerType.increasePathfinderMars
elseif trackName=="jovian" then
triggerType=eventData.triggerType.increasePathfinderJovian
else
return
end
Global.call("eventHandling_triggerEvent",{triggeredByColor=playerColor,triggerType=triggerType})
end
end
objectActivationEffects.modifyColonyTradingConfig=function(modType,delta)
return function(playerColor)
local tmPlayer=getPlayerByColor(playerColor)
tmPlayer.colonyTradingConfig[modType]=tmPlayer.colonyTradingConfig[modType] + delta
end
end
objectActivationEffects.defineAndGiveTradeToken=function()
return function(playerColor,sourceName)
logging.printToAll(playerColor.." got a Trade Token from "..sourceName,playerColor,loggingModes.detail)
local metadata=colonySystem.generateTradeTokenMetadata(playerColor)
Global.call("giveObjectToPlayer",{playerColor=playerColor,objectName="programableActionToken",isSpecialTile=false,metadata=metadata})
return true
end
end
objectActivationEffects.defineAndGiveDecreaseColonyTrackToken=function()
return function(playerColor,sourceName)
logging.printToAll(playerColor.." got a Decrease Colony Track Token from "..sourceName,playerColor,loggingModes.detail)
local metadata=colonySystem.generateColonyTrackDownTokenMetadata(playerColor)
Global.call("giveObjectToPlayer",{playerColor=playerColor,objectName="programableActionToken",isSpecialTile=false,metadata=metadata})
return true
end
end
objectActivationEffects.defineAndGiveIncreaseColonyTrackToken=function()
return function(playerColor,sourceName)
logging.printToAll(playerColor.." got a Increase Colony Track Token from "..sourceName,playerColor,loggingModes.detail)
local metadata=colonySystem.generateColonyTrackUpTokenMetadata(playerColor)
Global.call("giveObjectToPlayer",{playerColor=playerColor,objectName="programableActionToken",isSpecialTile=false,metadata=metadata})
return true
end
end
objectActivationEffects.defineAndGiveProductionMalusToken=function(effectStrength)
return function(playerColor,sourceName)
logging.printToAll(playerColor.." got a Production Malus Token from "..sourceName,playerColor,loggingModes.detail)
local metadata=aresFunctions.generateProductionMalusMetadata(playerColor,effectStrength)
Global.call("giveObjectToPlayer",{playerColor=playerColor,objectName="programableActionToken",isSpecialTile=false,metadata=metadata})
return true
end
end
objectActivationEffects.setNextFirstPlayer=function()
return function(playerColor,sourceName)
logging.printToAll(playerColor.." will be first player next generation.",playerColor,loggingModes.important)
for index,player in pairs(gameState.allPlayers) do
if playerColor==player.color then
gameState.forcedNextFirstPlayer=index
break
end
end
end
end
objectActivationEffects.placeSpaceTile=function(tileId,objectName,tileSourceName)
return function(playerColor,sourceName)
if gameState.automaticSpaceTilePlacement then
local source=gameObjectHelpers.getObjectByName(tileSourceName)
for _,spaceTileTable in pairs(tablePositions.reservedTiles.spaceTiles) do
for entryName,entry in pairs(spaceTileTable) do
if entryName==tileId then
local tileObj=source.takeObject({position=entry.pos,rotation=entry.rot})
Wait.frames(
function() Wait.condition(
function() tileObj.call("activateObjectRemotely",{playerColor=playerColor}) end,
function() return tileObj.resting end )
end,20)
return true
end
end
end
else
logging.printToAll(playerColor.." got a(n) "..objectName.." from "..sourceName,playerColor,loggingModes.detail)
Global.call("giveObjectToPlayer",{playerColor=playerColor,objectName=objectName,isSpecialTile=false,metadata=nil})
end
return true
end
end
objectActivationEffects.effectMapping={}
objectActivationEffects.effectMapping["DrawCard"]=objectActivationEffects.drawCardFunction(1)
objectActivationEffects.effectMapping["DiscardCard"]=objectActivationEffects.discardCardFunction(1)
objectActivationEffects.effectMapping["OthersDrawCard"]=objectActivationEffects.othersDrawCardFunction(1)
objectActivationEffects.effectMapping["Temp"]=objectActivationEffects.increaseGlobalParameterFunction("temp")
objectActivationEffects.effectMapping["O2"]=objectActivationEffects.increaseGlobalParameterFunction("o2")
objectActivationEffects.effectMapping["TFVenus"]=objectActivationEffects.increaseGlobalParameterFunction("venus")
objectActivationEffects.effectMapping["TR"]=objectActivationEffects.increaseGlobalParameterFunction("tr")
objectActivationEffects.effectMapping["TRReduce"]=objectActivationEffects.decreaseGlobalParameterFunction("tr")
objectActivationEffects.effectMapping["Ocean"]=objectActivationEffects.drawObjectFunction("ocean",false)
objectActivationEffects.effectMapping["Greenery"]=objectActivationEffects.drawObjectFunction("greenery",false)
objectActivationEffects.effectMapping["City"]=objectActivationEffects.drawObjectFunction("city",false)
objectActivationEffects.effectMapping["Microbe"]=objectActivationEffects.drawObjectFunction("microbe",false)
objectActivationEffects.effectMapping["Science"]=objectActivationEffects.drawObjectFunction("science",false)
objectActivationEffects.effectMapping["Animal"]=objectActivationEffects.drawObjectFunction("animal",false)
objectActivationEffects.effectMapping["Fighter"]=objectActivationEffects.drawObjectFunction("fighter",false)
objectActivationEffects.effectMapping["WildCardToken"]=objectActivationEffects.drawObjectFunction("wildCardToken",false)
objectActivationEffects.effectMapping["Floater"]=objectActivationEffects.drawObjectFunction("floater",false)
objectActivationEffects.effectMapping["Asteroid"]=objectActivationEffects.drawObjectFunction("asteroid",false)
objectActivationEffects.effectMapping["Colony"]=objectActivationEffects.drawObjectFunction("colonyMarker",false)
objectActivationEffects.effectMapping["PlayerMarker"]=objectActivationEffects.drawObjectFunction("playerMarker",false)
objectActivationEffects.effectMapping["Delegate"]=objectActivationEffects.drawObjectFunction("delegate",false)
objectActivationEffects.effectMapping["PreserveTile"]=objectActivationEffects.drawObjectFunction("preserve",true)
objectActivationEffects.effectMapping["NuclearZone"]=objectActivationEffects.drawObjectFunction("nuclear",true)
objectActivationEffects.effectMapping["RestrictedArea"]=objectActivationEffects.drawObjectFunction("restricted",true)
objectActivationEffects.effectMapping["Capital"]=objectActivationEffects.drawObjectFunction("capital",true)
objectActivationEffects.effectMapping["LavaFlows"]=objectActivationEffects.drawObjectFunction("lavaFlows",true)
objectActivationEffects.effectMapping["EcologicalZone"]=objectActivationEffects.drawObjectFunction("ecologicalZone",true)
objectActivationEffects.effectMapping["MiningRights"]=objectActivationEffects.drawObjectFunction("miningRights",true)
objectActivationEffects.effectMapping["MiningArea"]=objectActivationEffects.drawObjectFunction("miningArea",true)
objectActivationEffects.effectMapping["IndustrialCenter"]=objectActivationEffects.drawObjectFunction("industrial",true)
objectActivationEffects.effectMapping["MoholeArea"]=objectActivationEffects.drawObjectFunction("mohole",true)
objectActivationEffects.effectMapping["CommercialDistrict"]=objectActivationEffects.drawObjectFunction("commercial",true)
objectActivationEffects.effectMapping["Ore"]=objectActivationEffects.drawObjectFunction("ore",false)
objectActivationEffects.effectMapping["Data"]=objectActivationEffects.drawObjectFunction("data",false)
objectActivationEffects.effectMapping["CrashSite"]=objectActivationEffects.drawObjectFunction("crashSite",true)
objectActivationEffects.effectMapping["NewVenice"]=objectActivationEffects.drawObjectFunction("newVenice",true)
objectActivationEffects.effectMapping["Wetlands"]=objectActivationEffects.drawObjectFunction("wetlands",true)
objectActivationEffects.effectMapping["RedCity"]=objectActivationEffects.drawObjectFunction("redCity",true)
objectActivationEffects.effectMapping["VenusPFTrack"]=objectActivationEffects.increasePathfinderTrackEvent("venus")
objectActivationEffects.effectMapping["EarthPFTrack"]=objectActivationEffects.increasePathfinderTrackEvent("earth")
objectActivationEffects.effectMapping["MarsPFTrack"]=objectActivationEffects.increasePathfinderTrackEvent("mars")
objectActivationEffects.effectMapping["JovianPFTrack"]=objectActivationEffects.increasePathfinderTrackEvent("jovian")
objectActivationEffects.effectMapping["ResourceWildCardToken"]=objectActivationEffects.drawObjectFunction("resourceWildCardToken")
objectActivationEffects.effectMapping["ProductionWildCardToken"]=objectActivationEffects.drawObjectFunction("productionWildCardToken")
objectActivationEffects.effectMapping["ProgramableActionToken"]=objectActivationEffects.drawObjectFunction("programableActionToken")
objectActivationEffects.effectMapping["IncreaseTradingReward"]=objectActivationEffects.modifyColonyTradingConfig("tradingRewardModifier",1)
objectActivationEffects.effectMapping["DecreaseTradingCost"]=objectActivationEffects.modifyColonyTradingConfig("tradingCostModifier",-1)
objectActivationEffects.effectMapping["GanymedeColony"]=objectActivationEffects.placeSpaceTile("ganymedeColony","city","genericCityBag")
objectActivationEffects.effectMapping["PhobosSpacePort"]=objectActivationEffects.placeSpaceTile("phobosSpacePort","city","genericCityBag")
objectActivationEffects.effectMapping["StanfordTorus"]=objectActivationEffects.placeSpaceTile("stanfordTorus","city","genericCityBag")
objectActivationEffects.effectMapping["DawnCity"]=objectActivationEffects.placeSpaceTile("dawnCity","city","genericCityBag")
objectActivationEffects.effectMapping["LunaMetropolis"]=objectActivationEffects.placeSpaceTile("lunaMetropolis","city","genericCityBag")
objectActivationEffects.effectMapping["GatewayStation"]=objectActivationEffects.placeSpaceTile("gatewayStation","city","genericCityBag")
objectActivationEffects.effectMapping["MartianTranshipmentStation"]=objectActivationEffects.placeSpaceTile("martianTranshipmentStation","city","genericCityBag")
objectActivationEffects.effectMapping["VeneraBase"]=objectActivationEffects.placeSpaceTile("veneraBase","city","genericCityBag")
objectActivationEffects.effectMapping["DysonScreens"]=objectActivationEffects.placeSpaceTile("dysonScreens","city","genericCityBag")
objectActivationEffects.effectMapping["CeresSpaceport"]=objectActivationEffects.placeSpaceTile("ceresSpaceport","city","genericCityBag")
objectActivationEffects.effectMapping["LunarEmbassy"]=objectActivationEffects.placeSpaceTile("lunarEmbassy","city","genericCityBag")
objectActivationEffects.effectMapping["PayCard"]=objectActivationEffects.payCard()
objectActivationEffects.effectMapping["Fleet"]=objectActivationEffects.spawnNewFleet()
objectActivationEffects.effectMapping["TradeToken"]=objectActivationEffects.defineAndGiveTradeToken()
objectActivationEffects.effectMapping["ProductionMalus"]=objectActivationEffects.defineAndGiveProductionMalusToken(1)
objectActivationEffects.effectMapping["BigProductionMalus"]=objectActivationEffects.defineAndGiveProductionMalusToken(2)
objectActivationEffects.effectMapping["DecreaseColonyTrackToken"]=objectActivationEffects.defineAndGiveDecreaseColonyTrackToken()
objectActivationEffects.effectMapping["IncreaseColonyTrackToken"]=objectActivationEffects.defineAndGiveIncreaseColonyTrackToken()
objectActivationEffects.effectMapping["ShuffleDiscard"]=objectActivationEffects.shuffleDiscardPile()
objectActivationEffects.effectMapping["DrawCardFromDiscard"]=objectActivationEffects.drawCardFromDiscard(1)
objectActivationEffects.effectMapping["NextFirstPlayer"]=objectActivationEffects.setNextFirstPlayer()
objectActivationEffects.effectMapping["VenusHabitat"]=objectActivationEffects.drawObjectFunction("venusHabitat",false)
objectActivationEffects.effectMapping["FloatingArray"]=objectActivationEffects.drawObjectFunction("floatingArray",false)
objectActivationEffects.effectMapping["GasMine"]=objectActivationEffects.drawObjectFunction("gasMine",false)
objectActivationEffects.effectMapping["MenagerieTile"]=objectActivationEffects.drawObjectFunction("MenagerieTile",true)
objectActivationEffects.effectMapping["AresCapital"]=objectActivationEffects.drawObjectFunction("AresCapital",true)
objectActivationEffects.effectMapping["AresCommercialDistrict"]=objectActivationEffects.drawObjectFunction("AresCommercialDistrict",true)
objectActivationEffects.effectMapping["AresEcologicalZone"]=objectActivationEffects.drawObjectFunction("AresEcologicalZone",true)
objectActivationEffects.effectMapping["AresFertilizerFactory"]=objectActivationEffects.drawObjectFunction("AresFertilizerFactory",true)
objectActivationEffects.effectMapping["AresIndustrialCenter"]=objectActivationEffects.drawObjectFunction("AresIndustrialCenter",true)
objectActivationEffects.effectMapping["AresMeteorCrater"]=objectActivationEffects.drawObjectFunction("AresMeteorCrater",true)
objectActivationEffects.effectMapping["AresMiningAreaSteel"]=objectActivationEffects.drawObjectFunction("AresMiningAreaSteel",true)
objectActivationEffects.effectMapping["AresMiningAreaTitanium"]=objectActivationEffects.drawObjectFunction("AresMiningAreaTitanium",true)
objectActivationEffects.effectMapping["AresMiningRightsSteel"]=objectActivationEffects.drawObjectFunction("AresMiningRightsSteel",true)
objectActivationEffects.effectMapping["AresMiningRightsTitanium"]=objectActivationEffects.drawObjectFunction("AresMiningRightsTitanium",true)
objectActivationEffects.effectMapping["AresMoholeArea"]=objectActivationEffects.drawObjectFunction("AresMoholeArea",true)
objectActivationEffects.effectMapping["AresNaturalPreserve"]=objectActivationEffects.drawObjectFunction("AresNaturalPreserve",true)
objectActivationEffects.effectMapping["AresNuclearZone"]=objectActivationEffects.drawObjectFunction("AresNuclearZone",true)
objectActivationEffects.effectMapping["AresOceanFarm"]=objectActivationEffects.drawObjectFunction("AresOceanFarm",true)
objectActivationEffects.effectMapping["AresOceanicCity"]=objectActivationEffects.drawObjectFunction("AresOceanicCity",true)
objectActivationEffects.effectMapping["AresOceanSanctuary"]=objectActivationEffects.drawObjectFunction("AresOceanSanctuary",true)
objectActivationEffects.effectMapping["AresRestrictedArea"]=objectActivationEffects.drawObjectFunction("AresRestrictedArea",true)
objectActivationEffects.effectMapping["AresSolarFarm"]=objectActivationEffects.drawObjectFunction("AresSolarFarm",true)
objectActivationEffects.effectMapping["AresVolcano"]=objectActivationEffects.drawObjectFunction("AresVolcano",true)
objectActivationEffects.effectMapping["PlaceTwoErosions"]=function(playerColor,sourceName) aresFunctions.spawnErosions(2) end
objectActivationEffects.effectMapping["FlipDuststorms"]=function(playerColor,sourceName) aresFunctions.flipDuststorms() end
objectActivationEffects.effectMapping["FlipErosions"]=function(playerColor,sourceName) aresFunctions.flipErosions() end
objectActivationEffects.effectMapping["RemoveAllDuststorms"]=function(playerColor,sourceName) aresFunctions.removeAllDuststorms() end

objectActivationSystem={}
function objectActivationSystem_getCurrentActivationRuleSet(params)
local tmPlayer=getPlayerByColor(params.playerColor)
return tmPlayer.objectActivationSystemConfig.rules
end
function objectActivationSystem_activateObject(params)
local tmPlayer=getPlayerByColor(params.playerColor)
local sourceName=params.sourceName or "Unknown"
local object=params.object
local description=params.description
local activationEffects=params.activationEffects
if description~=nil then
updateActivationEffectsFromDescription(activationEffects,description)
end
local isObjectActivationAllowed=true
tmPlayer.objectActivationSystemConfig.ignoreRequirements=false
local ignoreActivationChecks=activationEffects.isGlobalEvent or activationEffects.ignoreActivationChecks or tmPlayer.playerArea.activationTableau==nil
if not ignoreActivationChecks then
isObjectActivationAllowed=objectActivationSystem.evaluateRules(tmPlayer,object,activationEffects)
if not tmPlayer.objectActivationSystemConfig.ignoreRequirements then
isObjectActivationAllowed=isObjectActivationAllowed and objectActivationSystem.objectRequirementsFulfilled(tmPlayer,activationEffects)
end
isObjectActivationAllowed=isObjectActivationAllowed and objectActivationSystem.playerCanAffordObject(tmPlayer,object,sourceName,activationEffects)
isObjectActivationAllowed=isObjectActivationAllowed and enoughCardsInHandForDiscarding(tmPlayer,sourceName,activationEffects)
end
if isObjectActivationAllowed or tmPlayer.neutral then
if params.object.guid~=tmPlayer.objectActivationSystemConfig.lastActivationObjectGuid then
tmPlayer.objectActivationSystemConfig.lastActivationObjectGuid=params.object.guid
objectActivationSystem.activateObject(tmPlayer,object,sourceName,activationEffects)
end
end
tmPlayer.wasUpdated=true
end
function objectActivationSystem_doAction(params)
local tmPlayer=getPlayerByColor(params.playerColor)
local sourceName=params.sourceName or "Unknown"
local object=params.object
local activationEffects=params.activationEffects
if activationEffects==nil then
if object~=nil and object.getVar("activateObject")~=nil then
playerActionFuncs.playerHasPlacedTile(tmPlayer.color,object.getGUID())
end
return true
end
if activationEffects.productionValues==nil then
activationEffects.productionValues={}
end
if activationEffects.effects==nil then
activationEffects.effects={}
end
if activationEffects.resourceValues==nil then
activationEffects.resourceValues={}
end
local canActivate=checkProductionAvailability(tmPlayer,sourceName,activationEffects)
canActivate=canActivate and checkResourceAvailability(tmPlayer,sourceName,activationEffects)
canActivate=canActivate and enoughCardsInHandForDiscarding(tmPlayer,sourceName,activationEffects)
if not canActivate and not tmPlayer.neutral then
return false
end
objectActivationSystem.doAction(tmPlayer,object,sourceName,activationEffects)
tmPlayer.wasUpdated=true
return true
end
function objectActivationSystem_disableActivationRules(params)
local tmPlayer=getPlayerByColor(params.playerColor)
tmPlayer.objectActivationSystemConfig.rules=cardActivationRules.configurations.noRules
tmPlayer.wasUpdated=true
end
function objectActivationSystem_enableAllActivationRules(params)
local tmPlayer=getPlayerByColor(params.playerColor)
tmPlayer.objectActivationSystemConfig.rules=cardActivationRules.configurations.allRules
tmPlayer.wasUpdated=true
end
objectActivationSystem.evaluateRules=function(tmPlayer,object,activationEffects)
if object.tag~="Card" then
return true
end
if not evaluateRulesInternal(tmPlayer,object,cardActivationRules.configurations.permanentRules) then
return false
end
if not activationEffects.isProjectCard then
return true
end
if not evaluateRulesInternal(tmPlayer,object,tmPlayer.objectActivationSystemConfig.rules) then
return false
end
return true
end
objectActivationSystem.objectRequirementsFulfilled=function(tmPlayer,activationEffects)
local rawRequirementInterpreter=Global.getVar("rawRequirementInterpreter")
local requirementsMet=true
local tagsMissing=0
rawRequirementInterpreter.resetExtrasForPlayer(tmPlayer)
for key,value in pairs(activationEffects.rawRequirements) do
local result=rawRequirementInterpreter.evaluateRequirement(tmPlayer,key,value)
if not result then
logging.printToColor("Cannot play card,requirement unfulfilled: "..value.." "..key,tmPlayer.color,tmPlayer.color,loggingModes.essential)
end
requirementsMet=requirementsMet and result
end
return requirementsMet
end
objectActivationSystem.playerCanAffordObject=function(tmPlayer,object,sourceName,activationEffects)
local paymentSystemConfig=tmPlayer.paymentSystemConfig
local result=true
if object.guid~=paymentSystemConfig.currentObjectGuid then
return true
end
for resourceType,amountNeeded in pairs(paymentSystemConfig.paymentDistribution) do
local playersResourceAmount=Global.call("getPlayerResource",{resourceType=resourceType,playerColor=tmPlayer.color})
if playersResourceAmount < amountNeeded then
logging.printToAll("Player "..tmPlayer.color.." needs at least "..amountNeeded.." "..resourceType.." in order to play "..sourceName,tmPlayer.color,loggingModes.essential)
result=false
end
end
local tmpResult=checkProductionAvailability(tmPlayer,sourceName,activationEffects)
result=result and tmpResult
tmpResult=checkResourceAvailability(tmPlayer,sourceName,activationEffects)
result=result and tmpResult
return result
end
function checkProductionAvailability(tmPlayer,sourceName,activationEffects)
local result=true
for resourceType,productionChange in pairs(activationEffects.productionValues) do
if productionChange < 0 then
local currentPlayerProduction=Global.call("getPlayerProduction",{resourceType=resourceType,playerColor=tmPlayer.color})
if string.lower(resourceType)=="credits" then
currentPlayerProduction=currentPlayerProduction + 5
end
if (-1 * productionChange) > currentPlayerProduction then
local loggedProductionRequired=-1*productionChange
if string.lower(resourceType)=="credits" then
loggedProductionRequired=loggedProductionRequired - 5
end
logging.printToAll("Player "..tmPlayer.color.." needs at least "..loggedProductionRequired.." "..resourceType.." production in order to play/activate "..sourceName,tmPlayer.color,loggingModes.essential)
result=false
end
end
end
return result
end
function checkResourceAvailability(tmPlayer,sourceName,activationEffects)
local result=true
for resourceType,resourceChange in pairs(activationEffects.resourceValues) do
if resourceChange < 0 then
local currentPlayerResourceAmount=Global.call("getPlayerResource",{resourceType=resourceType,playerColor=tmPlayer.color})
if (-1 * resourceChange) > currentPlayerResourceAmount then
logging.printToAll("Player "..tmPlayer.color.." needs at least "..(-1*resourceChange).." "..resourceType.." in storage in order to play/activate "..sourceName,tmPlayer.color,loggingModes.essential)
result=false
end
end
end
return result
end
function enoughCardsInHandForDiscarding(tmPlayer,sourceName,activationEffects)
local cardsInHandNeeded=0
for _,rawEffect in pairs(activationEffects.effects) do
if rawEffect=="DiscardCard" then
cardsInHandNeeded=cardsInHandNeeded + 1
end
end
if cardsInHandNeeded==0 then
return true
end
local cardsInHand=0
for _,object in pairs(Player[tmPlayer.color].getHandObjects(1)) do
if object.tag=="Card" then
cardsInHand=cardsInHand + 1
end
end
if cardsInHand < cardsInHandNeeded then
logging.printToColor("Unable to play/trigger "..sourceName..". You need at least "..cardsInHandNeeded.." cards in your main hand ("..(cardsInHandNeeded - cardsInHand).." more)",tmPlayer.color,tmPlayer.color,loggingModes.essential)
end
return cardsInHand >= cardsInHandNeeded
end
objectActivationSystem.activateObject=function(tmPlayer,object,sourceName,activationEffects)
if object.getVar("onCardActivated") then
object.call("onCardActivated",tmPlayer.color)
end
if not activationEffects.isGlobalEvent then
updateEventHandlers(tmPlayer,activationEffects.eventHandlers)
end
Wait.frames(
function()
payCard(tmPlayer,object,activationEffects)
applyProductionChanges(tmPlayer,sourceName,activationEffects.productionValues)
applyProductionChangesOthers(tmPlayer,sourceName,activationEffects.productionValuesOthers)
applyResourceChanges(tmPlayer,sourceName,activationEffects.resourceValues)
applyResourceChangesOthers(tmPlayer,sourceName,activationEffects.resourceValuesOthers)
applyRawEffects(tmPlayer,sourceName,activationEffects.effects,activationEffects.metadata)
applyRawEffectsOthers(tmPlayer,sourceName,activationEffects.effectsOthers)
applyDiscountEffects(tmPlayer,sourceName,activationEffects.discountEffects)
resetOneTimeDiscounts(tmPlayer,object)
applyOneTimeDiscounts(tmPlayer,sourceName,activationEffects.oneTimeDiscountEffects)
applyConversionRateEffects(tmPlayer,sourceName,activationEffects.conversionRateEffects)
applyRequirementMods(tmPlayer,sourceName,activationEffects.requirementMods)
applyVictoryPoints(tmPlayer,object,activationEffects.victoryPoints)
addCardGuidToPlayer(tmPlayer,object,activationEffects.cardType)
resetOneTimeRequirementMods(tmPlayer,object)
applyOneTimeRequirementMods(tmPlayer,sourceName,activationEffects.oneTimeRequirementMods)
if not activationEffects.isGlobalEvent then
applyTags(tmPlayer,activationEffects.cardTags)
triggerEvents(tmPlayer,object,activationEffects)
playerActionFuncs.playerHasPerformedAction(tmPlayer.color)
end
end,2)
end
objectActivationSystem.doAction=function(tmPlayer,object,sourceName,activationEffects)
applyProductionChanges(tmPlayer,sourceName,activationEffects.productionValues)
applyProductionChangesOthers(tmPlayer,sourceName,activationEffects.productionValuesOthers)
applyResourceChanges(tmPlayer,sourceName,activationEffects.resourceValues)
applyResourceChangesOthers(tmPlayer,sourceName,activationEffects.resourceValuesOthers)
applyRawEffects(tmPlayer,sourceName,activationEffects.effects,activationEffects.metadata)
applyRawEffectsOthers(tmPlayer,sourceName,activationEffects.effectsOthers)
applyDiscountEffects(tmPlayer,sourceName,activationEffects.discountEffects)
applyOneTimeDiscounts(tmPlayer,sourceName,activationEffects.oneTimeDiscountEffects)
applyRequirementMods(tmPlayer,sourceName,activationEffects.requirementMods)
applyOneTimeRequirementMods(tmPlayer,sourceName,activationEffects.oneTimeRequirementMods)
applyTags(tmPlayer,activationEffects.tags)
if object~=nil then
eventHandling_triggerEvent({triggeredByColor=tmPlayer.color,
triggerType=eventData.triggerType.actionPerformed,
eventSourceId=object.guid,
metadata={resourceValues=activationEffects.resourceValues}})
if activationEffects.customEventTriggers~=nil then
for _,eventTrigger in pairs(activationEffects.customEventTriggers) do
eventHandling_triggerEvent({triggeredByColor=tmPlayer.color,triggerType=eventTrigger,eventSourceId=object.guid})
end
end
end
if object~=nil then
if object.getVar("activateObject")~=nil then
playerActionFuncs.playerHasPlacedTile(tmPlayer.color,object.getGUID())
elseif not activationEffects.isRepeatable and not activationEffects.noAction then
playerActionFuncs.playerHasPerformedAction(tmPlayer.color)
end
end
end
function updateActivationEffectsFromDescription(activationEffects,description)
activationEffects.isProjectCard=descriptionInterpreter.isProjectCard(description)
if not activationEffects.cardTags then
activationEffects.cardTags=descriptionInterpreter.getValuesFromInput(description,"Tags?:")
end
if not activationEffects.productionValues then
activationEffects.productionValues=descriptionInterpreter.getKeyValuePairsFromInput(description,"Prod:")
end
if not activationEffects.productionValuesOthers then
activationEffects.productionValuesOthers=descriptionInterpreter.getKeyValuePairsFromInput(description,"ProdOthers:")
end
if not activationEffects.resourceValues then
activationEffects.resourceValues=descriptionInterpreter.getKeyValuePairsFromInput(description,"Resrc:")
end
if not activationEffects.effects then
activationEffects.effects=descriptionInterpreter.getValuesFromInput(description,"Effects:")
end
if not activationEffects.discountEffects then
activationEffects.discountEffects=descriptionInterpreter.getKeyValuePairsFromInput(description,"^Discount:")
end
if not activationEffects.conversionRateEffects then
activationEffects.conversionRateEffects=descriptionInterpreter.getKeyValuePairsFromInput(description,"ConversionRate:")
end
if not activationEffects.rawRequirements then
activationEffects.rawRequirements=descriptionInterpreter.getKeyValuePairsFromInput(description,"Reqs:")
end
if not activationEffects.requirementMods then
activationEffects.requirementMods=descriptionInterpreter.getKeyValuePairsFromInput(description,"^ReqMods:")
end
if not activationEffects.oneTimeRequirementMods then
activationEffects.oneTimeRequirementMods=descriptionInterpreter.getKeyValuePairsFromInput(description,"OneTimeReqMods:")
end
if not activationEffects.oneTimeDiscountEffects then
activationEffects.oneTimeDiscountEffects=descriptionInterpreter.getKeyValuePairsFromInput(description,"OneTimeDiscount:")
end
if not activationEffects.baseCost then
activationEffects.baseCost=getBaseCost(description)
end
if not activationEffects.victoryPoints then
activationEffects.victoryPoints=descriptionInterpreter.getValuesFromInput(description,"VP:")[1]
end
if next(activationEffects.rawRequirements)~=nil then
activationEffects.hasRequirements=true
end
end
function addCardGuidToPlayer(tmPlayer,object,cardType)
if object.tag~="Card" then
return
end
if cardType==nil then
return
end
table.insert(tmPlayer.ownedCards[cardType],{guid=object.guid,name=object.getName()} )
tmPlayer.wasUpdated=true
end
function evaluateRulesInternal(tmPlayer,card,ruleSet)
local countOfReasons=0
local isAllowedToActivate=true
for i,ruleName in ipairs(ruleSet) do
local allActivationRules=cardActivationRules.rules
for activationRuleName,activationRule in pairs(allActivationRules) do
if ruleName==activationRuleName then
local activationRuleResult=activationRule(tmPlayer,card)
if not activationRuleResult then
countOfReasons=countOfReasons + 1
isAllowedToActivate=false
end
end
end
end
if not isAllowedToActivate then
logging.printToColor("You are not allowed to activate "..card.getName().." for the "..countOfReasons.." above reason(s).",tmPlayer.color,tmPlayer.color,loggingModes.essential)
end
return isAllowedToActivate
end
function payCard(tmPlayer,object,activationEffects)
if activationEffects.isProjectCard then
paymentSystem_pay({playerColor=tmPlayer.color,activationEffects=activationEffects,cardGuid=object.guid})
end
end
function applyProductionChanges(tmPlayer,sourceName,rawProductionValues)
for resourceType,amount in pairs(rawProductionValues) do
logging.printToAll("Player "..tmPlayer.color.." got "..amount.." "..resourceType.." production from "..sourceName,tmPlayer.color,loggingModes.detail)
Global.call("changePlayerProduction",{resourceType=resourceType,resourceAmount=amount,playerColor=tmPlayer.color})
end
end
function applyProductionChangesOthers(tmPlayer,sourceName,rawProductionValues)
if rawProductionValues==nil then
return
end
for _,player in pairs(gameState.allPlayers) do
if player.color~=tmPlayer.color then
for resourceType,amount in pairs(rawProductionValues) do
logging.printToAll("Player "..player.color.." got "..amount.." "..resourceType.." production from "..sourceName,player.color,loggingModes.detail)
Global.call("changePlayerProduction",{resourceType=resourceType,resourceAmount=amount,playerColor=player.color})
end
end
end
end
function applyResourceChanges(tmPlayer,sourceName,rawResourceValues)
for resourceType,amount in pairs(rawResourceValues) do
logging.printToAll("Player "..tmPlayer.color.." got "..amount.." "..resourceType.." from "..sourceName,tmPlayer.color,loggingModes.detail)
Global.call("changePlayerResource",{resourceType=resourceType,resourceAmount=amount,playerColor=tmPlayer.color})
end
end
function applyResourceChangesOthers(tmPlayer,sourceName,rawResourceValues)
if rawResourceValues==nil then
return
end
for _,player in pairs(gameState.allPlayers) do
if player.color~=tmPlayer.color then
for resourceType,amount in pairs(rawResourceValues) do
logging.printToAll("Player "..player.color.." got "..amount.." "..resourceType.." from "..sourceName,player.color,loggingModes.detail)
Global.call("changePlayerResource",{resourceType=resourceType,resourceAmount=amount,playerColor=player.color})
end
end
end
end
function applyRequirementMods(tmPlayer,sourceName,requirementMods)
if requirementMods==nil then
return
end
local reqModifiers=tmPlayer.reqModifiers.permanent
for requirementModType,value in pairs(requirementMods) do
if reqModifiers[requirementModType]==nil then
reqModifiers[requirementModType]=0
end
reqModifiers[requirementModType]=reqModifiers[requirementModType] + value
end
tmPlayer.wasUpdated=true
end
function resetOneTimeDiscounts(tmPlayer,object)
if object.tag=="Card" then
tmPlayer.paymentSystemConfig.discounts.transient={}
end
tmPlayer.wasUpdated=true
end
function applyOneTimeDiscounts(tmPlayer,sourceName,discountEffects)
if discountEffects==nil then
return
end
for tag,discount in pairs(discountEffects) do
logging.printToAll(tmPlayer.color.." increased their '"..tag.."' discount for the next card played by "..tostring(-discount).." by activating "..sourceName,tmPlayer.color,loggingModes.unimportant)
paymentSystem.updateTransientTagDiscount(tmPlayer,tag,discount)
end
tmPlayer.wasUpdated=true
end
function resetOneTimeRequirementMods(tmPlayer,object)
if object.tag=="Card" then
tmPlayer.reqModifiers.transient={}
end
tmPlayer.wasUpdated=true
end
function applyOneTimeRequirementMods(tmPlayer,sourceName,requirementMods)
if requirementMods==nil then
return
end
local reqModifiers=tmPlayer.reqModifiers.transient
for requirementModType,value in pairs(requirementMods) do
if reqModifiers[requirementModType]==nil then
reqModifiers[requirementModType]=0
end
reqModifiers[requirementModType]=reqModifiers[requirementModType] + value
end
tmPlayer.wasUpdated=true
end
function applyTags(tmPlayer,tags)
if tags==nil then
return
end
for _,tag in pairs(tags) do
if tag=="NIL" then
return
end
end
Global.call("cardSupportFunctions_updatePlayerTags",{tags=tags,playerColor=tmPlayer.color})
tmPlayer.wasUpdated=true
end
function triggerEvents(tmPlayer,object,activationEffects)
local vp=activationEffects.victoryPoints
if vp~=nil and ((tonumber(vp)~=nil and tonumber(vp) > 0) or string.match(vp,"Per") or string.match(vp,"Trigger")) then
eventHandling_triggerEvent({triggeredByColor=tmPlayer.color,triggerType=eventData.triggerType.vpCardPlayed})
end
if activationEffects.cardTags~=nil then
for _,tag in pairs(activationEffects.cardTags) do
for _,entry in pairs(eventDataMappings.tagToTriggerTypeMap) do
if entry.value==tag then
eventHandling_triggerEvent({triggeredByColor=tmPlayer.color,triggerType=entry.mappedValue,metadata={playedCard=object}})
end
end
end
end
if activationEffects.baseCost.value~=nil and activationEffects.baseCost.type=="Credits" then
if tonumber(activationEffects.baseCost.value) >= 20 then
eventHandling_triggerEvent({triggeredByColor=tmPlayer.color,triggerType=eventData.triggerType.payTwentyCostCard,eventSourceId=object.guid})
end
end
if activationEffects.rawRequirements~=nil and next(activationEffects.rawRequirements)~=nil then
eventHandling_triggerEvent({triggeredByColor=tmPlayer.color,triggerType=eventData.triggerType.cardWithRequirmentPlayed,eventSourceId=object.guid})
end
if activationEffects.customEventTriggers~=nil then
for _,eventTrigger in pairs(activationEffects.customEventTriggers) do
eventHandling_triggerEvent({triggeredByColor=tmPlayer.color,triggerType=eventTrigger,eventSourceId=object.guid})
end
end
if object~=nil and object.tag=="Card" then
eventHandling_triggerEvent({
triggeredByColor=tmPlayer.color,
triggerType=eventData.triggerType.cardPlayed,
eventSourceId=object.guid,
metadata={tagsPlayed=activationEffects.cardTags,card=object}
}
)
end
end
function applyDiscountEffects(tmPlayer,sourceName,discountEffects)
if discountEffects==nil then
return
end
for tag,discount in pairs(discountEffects) do
logging.printToAll(tmPlayer.color.." increased their discount for "..tag.." cards by "..tostring(-discount).." by activating "..sourceName,tmPlayer.color,loggingModes.detail)
Global.call("paymentSystem_updateTagDiscount",{playerColor=tmPlayer.color,tag=tag,delta=discount})
end
end
function applyConversionRateEffects(tmPlayer,sourceName,conversionRateEffects)
for resourceType,change in pairs(conversionRateEffects) do
logging.printToAll(resourceType.." of player "..tmPlayer.color.." is now worth "..change.." more by activating "..sourceName,tmPlayer.color,loggingModes.detail)
Global.call("paymentSystem_updateConversionRate",{playerColor=tmPlayer.color,resourceType=resourceType,delta=change})
end
end
function applyRawEffects(tmPlayer,sourceName,rawEffects,metadata)
for _,rawEffect in pairs(rawEffects) do
objectActivationEffects.effectMapping[rawEffect](tmPlayer.color,sourceName,metadata)
end
end
function applyRawEffectsOthers(tmPlayer,sourceName,rawEffects)
if rawEffects==nil then
return
end
for _,player in pairs(gameState.allPlayers) do
if player.color~=tmPlayer.color then
for _,rawEffect in pairs(rawEffects) do
objectActivationEffects.effectMapping[rawEffect](player.color,sourceName)
end
end
end
end
function updateEventHandlers(tmPlayer,eventHandlers)
if eventHandlers==nil then
return
end
for _,eventHandler in pairs(eventHandlers) do
eventHandling.subscribeHandler(eventHandler,tmPlayer.color)
end
end
function applyVictoryPoints(tmPlayer,object,victoryPoints)
if tonumber(victoryPoints)~=nil then
tmPlayer.victoryPoints.simple=tmPlayer.victoryPoints.simple + victoryPoints
elseif victoryPoints~=nil and #victoryPoints > 0 and string.match(victoryPoints,"Per") then
table.insert(tmPlayer.victoryPoints.complex,{victoryPointsFormula=victoryPoints,victoryPointsSourceGuid=object.guid,sourceFriendlyName=object.getName()})
end
tmPlayer.wasUpdated=true
end


paymentSystem={}
function getBaseCost(description)
local rawCost=descriptionInterpreter.getValuesFromInput(description,"Cost:")
local cost={}
if #rawCost==1 then
cost={type="Credits",value=tonumber(rawCost[1])}
elseif #rawCost==2 then
cost={type=rawCost[2],value=tonumber(rawCost[1])}
elseif #rawCost==0 or rawCost==nil then
cost={type="Credits",value=tonumber(0)}
else
logging.broadcastToAll("Unsupported 'Cost' entry in description. Payment setup has to be done manually.",{1,1,1,1},loggingModes.exception)
cost={type="Credits",value=tonumber(0)}
end
return cost
end
function paymentSystem_getResourceExtensions(params)
local tmPlayer=getPlayerByColor(params.playerColor)
return tmPlayer.paymentSystemConfig.resourceExtensions
end
function paymentSystem_updateTagDiscount(params)
local tmPlayer=getPlayerByColor(params.playerColor)
paymentSystem.updateTagDiscount(tmPlayer,params.tag,params.delta)
tmPlayer.wasUpdated=true
end
function paymentSystem_updatePaymentDistribution(params)
local tmPlayer=getPlayerByColor(params.playerColor)
if tmPlayer.paymentSystemConfig.paymentDistribution[params.resourceType]==nil then
logging.printToAll("PaymentSystem: Unknown resource "..params.resourceType..". Please report as a bug.",{1,0,0},loggingModes.exception)
return
end
paymentSystem.updatePaymentDistribution(tmPlayer,params.resourceType,params.delta)
tmPlayer.wasUpdated=true
end
function paymentSystem_updateConversionRate(params)
local tmPlayer=getPlayerByColor(params.playerColor)
if tmPlayer.paymentSystemConfig.conversionRates[params.resourceType]==nil then
logging.printToAll("PaymentSystem: Unknown resource "..params.resourceType..". Please report as a bug.",{1,0,0},loggingModes.exception)
return
end
paymentSystem.updateConversionRate(tmPlayer,params.resourceType,params.delta)
tmPlayer.wasUpdated=true
end
function paymentSystem_setupPayment(params)
if params.cost==nil then
return
end
local tmPlayer=getPlayerByColor(params.playerColor)
tmPlayer.paymentSystemConfig.cardActivationInProgress=true
tmPlayer.paymentSystemConfig.currentObjectGuid=params.objectInActivationZoneGuid
paymentSystem.setupPayment(tmPlayer,params.cost,params.tagsInput,params.hasRequirements)
tmPlayer.wasUpdated=true
end
function paymentSystem_getPaymentDistribution(params)
local tmPlayer=getPlayerByColor(params.playerColor)
return tmPlayer.paymentSystemConfig.paymentDistribution
end
function paymentSystem_resetPaymentSystem(params)
local tmPlayer=getPlayerByColor(params.playerColor)
tmPlayer.paymentSystemConfig.overpayedCredits=0
for key,value in pairs(tmPlayer.paymentSystemConfig.paymentDistribution) do
tmPlayer.paymentSystemConfig.paymentDistribution[key]=0
end
for key,value in pairs(tmPlayer.paymentSystemConfig.conversionsAllowed) do
tmPlayer.paymentSystemConfig.conversionsAllowed[key]=true
for tag,resourceType in pairs(tagToResourceConversionAllowedMap) do
tmPlayer.paymentSystemConfig.conversionsAllowed[resourceType]=false
end
end
tmPlayer.paymentSystemConfig.cardActivationInProgress=false
tmPlayer.paymentSystemConfig.currentObjectGuid=""
local activationTableau=getObjectFromGUID(tmPlayer.playerArea.activationTableau)
if activationTableau~=nil then
activationTableau.call("updatePaymentDistributionDisplay",tmPlayer.paymentSystemConfig.paymentDistribution)
end
paymentSystem.updateConversionRate(tmPlayer,"Steel",0)
tmPlayer.wasUpdated=true
end
function paymentSystem_pay(params)
local tmPlayer=getPlayerByColor(params.playerColor)
paymentSystem.payUp(tmPlayer,params.cardGuid)
paymentSystem_resetPaymentSystem(params)
tmPlayer.wasUpdated=true
end
paymentSystem.payUp=function(tmPlayer,cardGuid)
local paymentDistribution=tmPlayer.paymentSystemConfig.paymentDistribution
for key,value in pairs(paymentDistribution) do
Global.call("changePlayerResource",{resourceType=key,resourceAmount=-value,playerColor=tmPlayer.color})
end
eventHandling_triggerEvent({
triggeredByColor=tmPlayer.color,
triggerType=eventData.triggerType.payedForCard,
eventSourceId=cardGuid,
metadata={
resourceValues={
Credits=-paymentDistribution["Credits"],
Steel=-paymentDistribution["Steel"],
Titanium=-paymentDistribution["Titanium"]
}
}
})
end
paymentSystem.setupPayment=function(tmPlayer,cost,tags,hasRequirements)
paymentSystem.setupSpecialResourceConversions(tmPlayer,cost,tags)
for _,tagOuter in ipairs(tags) do
for tagInner,resourceType in pairs(tagToResourceConversionAllowedMap) do
if tagInner==tagOuter then
tmPlayer.paymentSystemConfig.conversionsAllowed[resourceType]=true
end
end
end
local resourcesToPay=paymentSystem.applyDiscounts(tmPlayer,cost,tags,hasRequirements)
for key,_ in pairs(tmPlayer.paymentSystemConfig.paymentDistribution) do
if key==resourcesToPay.type then
tmPlayer.paymentSystemConfig.paymentDistribution[resourcesToPay.type]=resourcesToPay.value
end
end
tmPlayer.paymentSystemConfig.overpayedCredits=0
local activationTableau=getObjectFromGUID(tmPlayer.playerArea.activationTableau)
if activationTableau~=nil then
activationTableau.call("updatePaymentDistributionDisplay",tmPlayer.paymentSystemConfig.paymentDistribution)
end
end
paymentSystem.updatePaymentDistribution=function(tmPlayer,resourceType,delta)
local newPaymentDistribution=tmPlayer.paymentSystemConfig.paymentDistribution
local overpayedCredits=tmPlayer.paymentSystemConfig.overpayedCredits
if resourceType~="Credits" then
if not  tmPlayer.paymentSystemConfig.conversionsAllowed[resourceType] then
logging.printToColor("Not allowed to pay with "..resourceType.." for this card",tmPlayer.color,tmPlayer.color,loggingModes.important)
return
end
tmPlayer.paymentSystemConfig.paymentDistribution[resourceType]=newPaymentDistribution[resourceType] + delta
local creditsDelta=- delta * tmPlayer.paymentSystemConfig.conversionRates[resourceType]
if delta >= 0 or overpayedCredits==0 then
newPaymentDistribution["Credits"]=newPaymentDistribution["Credits"] + creditsDelta
if newPaymentDistribution["Credits"] < 0 then
overpayedCredits=overpayedCredits - newPaymentDistribution["Credits"]
newPaymentDistribution["Credits"]=0
end
else
overpayedCredits=overpayedCredits - creditsDelta
if overpayedCredits < 0 then
newPaymentDistribution["Credits"]=-overpayedCredits
overpayedCredits=0
end
end
else
tmPlayer.paymentSystemConfig.paymentDistribution[resourceType]=newPaymentDistribution[resourceType] + delta
if newPaymentDistribution["Credits"] < 0 then
overpayedCredits=overpayedCredits - newPaymentDistribution["Credits"]
newPaymentDistribution["Credits"]=0
end
end
tmPlayer.paymentSystemConfig.paymentDistribution=newPaymentDistribution
tmPlayer.paymentSystemConfig.overpayedCredits=overpayedCredits
local activationTableau= getObjectFromGUID(tmPlayer.playerArea.activationTableau)
if activationTableau~=nil then
activationTableau.call("updatePaymentDistributionDisplay",tmPlayer.paymentSystemConfig.paymentDistribution)
end
end
paymentSystem.updateConversionRate=function(tmPlayer,resourceType,delta)
log("updating conversion rates")
tmPlayer.paymentSystemConfig.baseConversionRates[resourceType]=
tmPlayer.paymentSystemConfig.baseConversionRates[resourceType] + delta
tmPlayer.paymentSystemConfig.conversionRates=tableHelpers.deepClone(tmPlayer.paymentSystemConfig.baseConversionRates)
local activationTableau= getObjectFromGUID(tmPlayer.playerArea.activationTableau)
if activationTableau~=nil then
activationTableau.call("updateConversionRatesDisplay",tmPlayer.paymentSystemConfig.baseConversionRates)
eventHandling_triggerEvent({
triggeredByColor=tmPlayer.color,
triggerType=eventData.triggerType.conversionRatesUpdated,
eventSourceId=activationTableau.guid,
metadata={conversionRates=tmPlayer.paymentSystemConfig.baseConversionRates}
})
end
end
paymentSystem.updateTagDiscount=function(tmPlayer,tag,delta)
local discounts=tmPlayer.paymentSystemConfig.discounts.permanent
if discounts[tag]==nil then
log("updating special discount for tag")
log(tag)
discounts[tag]=0
end
local oldValue=discounts[tag]
discounts[tag]=discounts[tag] + delta
if delta~=0 then
log(tmPlayer.color.."'s discount for '"..tag.."' tag changed: "..oldValue.." -> "..discounts[tag])
end
for _,iconTableauGuid in pairs(tmPlayer.playerArea.iconTableaus) do
local iconTableau= getObjectFromGUID(iconTableauGuid)
if iconTableau~=nil then
iconTableau.call("updateTagDiscountsDisplay",discounts)
end
end
end
paymentSystem.updateTransientTagDiscount=function(tmPlayer,tag,delta)
local discounts=tmPlayer.paymentSystemConfig.discounts.transient
if discounts[tag]==nil then
discounts[tag]=0
end
discounts[tag]=discounts[tag] + delta
if tmPlayer.paymentSystemConfig.cardActivationInProgress then
paymentSystem.updatePaymentDistribution(tmPlayer,"Credits",delta)
end
end
paymentSystem.extendByResource=function(tmPlayer,resourceTypeInput,conversionRateInput,conversionAllowedTagsInput,isConstantConversionRateInput)
local paymentSystemConfig=tmPlayer.paymentSystemConfig
if paymentSystemConfig.resourceExtensions[resourceTypeInput]~=nil then
return
end
paymentSystemConfig.resourceExtensions[resourceTypeInput]={resourceType=resourceTypeInput,conversionRate=conversionRateInput,isConstantConversionRate=isConstantConversionRateInput}
paymentSystemConfig.paymentDistribution[resourceTypeInput]=0
paymentSystemConfig.baseConversionRates[resourceTypeInput]=conversionRateInput
if conversionAllowedTagsInput~=nil then
for i,tag in ipairs(conversionAllowedTagsInput) do
if tagToResourceConversionAllowedMap[tag]==nil then
tagToResourceConversionAllowedMap[tag]=resourceTypeInput
end
end
else
paymentSystemConfig.conversionsAllowed[resourceTypeInput]=true
end
local activationTableau= getObjectFromGUID(tmPlayer.playerArea.activationTableau)
if activationTableau~=nil then
activationTableau.call("activationTableau_extendTableau",{resourceType=resourceTypeInput,defaultConversionRate=conversionRateInput,isConstantConversionRate=isConstantConversionRateInput})
end
tmPlayer.wasUpdated=true
end
paymentSystem.applyDiscounts=function(tmPlayer,cost,tags,hasRequirements)
local discounts=tmPlayer.paymentSystemConfig.discounts.permanent
local transientDiscounts=tmPlayer.paymentSystemConfig.discounts.transient
local resourcesToPay={}
if cost.type=="Credits" then
local creditsToPay=cost.value + discounts[icons.anyTagNames[1]]
if transientDiscounts[icons.anyTagNames[1]]~=nil then
creditsToPay=creditsToPay + transientDiscounts[icons.anyTagNames[1]]
end
for _,tag in ipairs(tags) do
if transientDiscounts[tag]~=nil then
creditsToPay=creditsToPay + discounts[tag] + transientDiscounts[tag]
elseif discounts[tag]~=nil then
creditsToPay=creditsToPay + discounts[tag]
end
end
if hasRequirements and discounts["CardsWithRequirements"]~=nil then
creditsToPay=creditsToPay + discounts["CardsWithRequirements"]
end
if creditsToPay < 0 then
creditsToPay=0
end
resourcesToPay={type=cost.type,value=creditsToPay}
else
resourcesToPay=cost
end
return resourcesToPay
end
paymentSystem.setupSpecialResourceConversions=function(tmPlayer,cost,tags)
local activationTableau= getObjectFromGUID(tmPlayer.playerArea.activationTableau)
for _,tag in pairs(tags) do
if tag=="Infrastructure" then
tmPlayer.paymentSystemConfig.conversionRates["Titanium"]=4
if activationTableau~=nil then
activationTableau.call("updateConversionRatesDisplay",tmPlayer.paymentSystemConfig.conversionRates)
end
return
end
end
tmPlayer.paymentSystemConfig.conversionRates=tableHelpers.deepClone(tmPlayer.paymentSystemConfig.baseConversionRates)
if activationTableau~=nil then
activationTableau.call("updateConversionRatesDisplay",tmPlayer.paymentSystemConfig.conversionRates)
end
end



specialMilestones={}
specialMilestones.evaluateMilestone=function(tmPlayer,milestoneName)
if milestoneName=="Planner" then
return specialMilestones.evaluatePlanner(tmPlayer)
elseif milestoneName=="Diversifier" then
return specialMilestones.evaluateDiversifier(tmPlayer)
elseif milestoneName=="Tactician" then
return specialMilestones.evaluateTactician(tmPlayer)
elseif milestoneName=="Polar Explorer" then
return specialMilestones.evaluatePolarExplorer(tmPlayer)
elseif milestoneName=="Specialist" then
return specialMilestones.evaluateSpecialist(tmPlayer)
elseif milestoneName=="Ecologist" then
return specialMilestones.evaluateEcologist(tmPlayer)
elseif milestoneName=="Tycoon" then
return specialMilestones.evaluateTycoon(tmPlayer)
else
logging.printToAll("Unsupported milestone: '"..milestoneName.."'. Please report this",{1,0.25,0,1},loggingModes.exception)
return true
end
end
specialMilestones.evaluatePlanner=function(tmPlayer)
local ttsPlayer=Player[tmPlayer.color]
local cardsInHand=0
for i=1,ttsPlayer.getHandCount() do
for _,object in pairs(ttsPlayer.getHandObjects(i)) do
if object.tag=="Card" then
cardsInHand=cardsInHand + 1
end
end
end
return cardsInHand >= 16
end
specialMilestones.evaluateDiversifier=function(tmPlayer)
local numberOfTags=0
local wildCardTagCount=tmPlayer.tagSystem.tagCounts["WildCard"]
for tag,amount in pairs(tmPlayer.tagSystem.tagCounts) do
local isIgnoredTag=false
for _,ignoreTag in pairs(tableHelpers.combineSingleValueTables({icons.specialIconNames,icons.anyTagNames})) do
if tag==ignoreTag then
isIgnoredTag=true
end
end
if not isIgnoredTag then
if amount > 0 then
numberOfTags=numberOfTags + 1
elseif wildCardTagCount > 0 then
numberOfTags=numberOfTags + 1
wildCardTagCount=wildCardTagCount - 1
end
end
end
return numberOfTags >= 8
end
specialMilestones.evaluateTactician=function(tmPlayer)
local cardsWithRequirementsCount=0
for _,cardInfo in pairs(tableHelpers.combineSingleValueTables({tmPlayer.ownedCards.Infrastructure,tmPlayer.ownedCards.Blue,tmPlayer.ownedCards.Green})) do
local card=getObjectFromGUID(cardInfo.guid)
if card~=nil then
if card.call("hasRequirements") then
cardsWithRequirementsCount=cardsWithRequirementsCount + 1
end
else
logging.printToColor("Cannot evaluate card '"..cardInfo.name.."' for milestone 'Tactician'. It's probably hidden away in a card stack.",tmPlayer.color,tmPlayer.color,loggingModes.exception)
end
end
return cardsWithRequirementsCount >= 5
end
specialMilestones.evaluatePolarExplorer=function(tmPlayer)
local jStart=#gameMap.tiles[0]-2
local tilesCoordsOfInterest={}
for j=1,2 do
table.insert(tilesCoordsOfInterest,normalizeIndices({0,jStart + j,0}))
for i=1,100,1 do
if hexMapHelpers.getTileFromArbitraryHexCoords(gameMap,{i,jStart + j,0})~=nil then
table.insert(tilesCoordsOfInterest,normalizeIndices({i,jStart + j,0}))
else
break
end
end
for i=-1,-100,-1 do
if hexMapHelpers.getTileFromArbitraryHexCoords(gameMap,{i,jStart + j,0})~=nil then
table.insert(tilesCoordsOfInterest,normalizeIndices({i,jStart + j,0}))
else
break
end
end
end
local ownedTiles=0
for _,tileCoordinates in pairs(tilesCoordsOfInterest) do
local tile=gameMap.tiles[tileCoordinates[1]][tileCoordinates[2]][tileCoordinates[3]]
if tile.tileObjects~=nil then
for _,obj in pairs(tile.tileObjects) do
if obj.owner==tmPlayer.color then
ownedTiles=ownedTiles + 1
break
end
end
end
end
return ownedTiles >= 3
end
specialMilestones.evaluateSpecialist=function(tmPlayer)
for _,resourceType in pairs({"Credits","Steel","Titanium","Plants","Energy","Heat"}) do
local value=Global.call("getPlayerProduction",{resourceType=resourceType,playerColor=tmPlayer.color})
if value >= 10 then
return true
end
end
return false
end
specialMilestones.evaluateEcologist=function(tmPlayer)
local numberOfTags=tmPlayer.tagSystem.tagCounts["WildCard"]
local tagsOfInterest={"Microbe","Plant","Animal"}
for tag,amount in pairs(tmPlayer.tagSystem.tagCounts) do
for _,tagOfInterest in pairs(tagsOfInterest) do
if tagOfInterest==tag then
numberOfTags=numberOfTags + amount
end
end
end
return numberOfTags >= 4
end
specialMilestones.evaluateTycoon=function(tmPlayer)
return #tmPlayer.ownedCards.Blue + #tmPlayer.ownedCards.Green >= 15
end
-- log(specialMilestones.evaluateTactician(getPlayerByColor("White")))
-- log(specialMilestones.evaluateTycoon(getPlayerByColor("White")))


milestoneData={}
milestoneData.infos={
Terraformer={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436810303/D5133DE9481FB91F64BA28DFA98295E90D0D4E97/",
description="Requires a terraforming rating of 35 or higher.\n:Milestone:\nReqs: 35 OwnTR",
tooltip="Click to claim 'Terraformer' milestone.\nRequires a terraforming rating of 35 or higher.",
name="Terraformer",
expansions={"NOTturmoil"}},
TurmoilTerraformer={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649970457130983774/BBAAC5E24EC5F1F085885F8047088ADCED927DB4/",
description="Requires a terraforming rating of 26 or higher.\n:Milestone:\nReqs: 26 OwnTR",
tooltip="Click to claim 'Terraformer' milestone.\nRequires a terraforming rating of 26 or higher.",
name="Terraformer",
expansions={"turmoil"}},
Mayor={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436815440/0A56B8083B5D749C6FEE82F7D67AB4D5174853BA/",
description="Requires at least 3 own cities (Space or Mars) in play.\n:Milestone:\nReqs: 3 OwnCityTile",
tooltip="Click to claim 'Mayor' milestone.\nRequires at least 3 own cities (Space or Mars) in play.",
name="Mayor"},
Gardener={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436819394/E58F3721F062B38BC375303E9BA59C674504952A/",
description="Requires at least 3 own greeneries in play.\n:Milestone:\nReqs: 3 OwnGreenery",
tooltip="Click to claim 'Gardener' milestone.\nRequires at least 3 own greeneries in play.",
name="Gardener"},
Builder={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436793211/A6D551D89CF538B069A7C43EAF83666E17E03792/",
description="Requires at least a building tag count of 8.\n:Milestone:\nReqs: 8 OwnBuilding",
tooltip="Click to claim 'Builder' milestone.\nRequires at least a building tag count of 8.",
name="Builder"},
Planner={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436814280/FD683203361B59ADEB81B0FBB2CE553D948F05AD/",
description="Requires 16 or more project cards in hand.\n:Milestone:\n",
tooltip="Click to claim 'Planner' milestone.\nRequires 16 or more project cards in hand.",
name="Planner"},
Diversifier={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436808636/AAE8943518C6371AC9C5C049268A9CD46121FDC3/",
description="Requires at least 8 different tags in play (Wild tags may replace missing tags).\n:Milestone:\n",
tooltip="Click to claim 'Diversifier' milestone.\nRequires at least 8 different tags in play (Wild tags may replace missing tags).",
name="Diversifier"},
Tactician={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436811070/43C2D77FFCEB2DEAAA3FB85FEC61254C0ADC9563/",
description="Requires at least 5 own cards in play with requirements.\n:Milestone:\n",
tooltip="Click to claim 'Tactician' milestone.\nRequires at least 5 own cards in play with requirements.",
name="Tactician"},
PolarExplorer={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436813593/BC6DF7411BC3BA998A33842B694869710D27B664/",
description="Requires at least 3 own tiles in the bottom two rows of the Mars map.\n:Milestone:\n",
tooltip="Click to claim 'Polar Explorer' milestone.\nRequires at least 3 own tiles in the bottom two rows of the Mars map.",
name="Polar Explorer"},
Energizer={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436819934/7E0C346FA7723A5461657AF965B111F51BE0ECBE/",
description="Requires an energy production of at least 6.\n:Milestone:\nReqs: 6 OwnEnergy",
tooltip="Click to claim 'Energizer' milestone.\nRequires an energy production of at least 6.",
name="Energizer"},
RimSettler={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436812715/3B4976181274CB3566A9F0FA503F138650BD8D57/",
description="Requires at least 3 own Jovian tags in play.\n:Milestone:\nReqs: 3 OwnJovian",
tooltip="Click to claim 'Rim Settler' milestone.\nRequires at least 3 own Jovian tags in play.",
name="Rim Settler"},
Generalist={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436818656/C2ED9812FB095200A4F9666C789AA2D5874A8918/",
description="Requires a production of at least 1 in every base resource.\n:Milestone:\nReqs: 1 OwnSteel 1 OwnCredits 1 OwnTitanium 1 OwnPlants 1 OwnEnergy 1 OwnHeat",
tooltip="Click to claim 'Generalist' milestone.\nRequires a production of at least 1 in every base resource.",
name="Generalist"},
Specialist={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436811945/F57B98E3B04C5DF5F6493F96684D6A685D9067F4/",
description="Requires a production of at least 10 for any base resource.\n:Milestone:\n",
tooltip="Click to claim 'Specialist' milestone.\nRequires a production of at least 10 for any base resource.",
name="Specialist"},
Ecologist={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436822210/B8EFED9313C75F4043F92E90BA82EC171A2B15F1/",
description="Requires at least 4 own Microbe,Animal or Plant tags in play (any combination,wildcard tags count)\n:Milestone:\n",
tooltip="Click to claim 'Ecologist' milestone.\nRequires at least 4 own Microbe,Animal or Plant tags in play (any combination,wildcard tags count)",
name="Ecologist"},
Tycoon={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436809548/3DFA709F4F9CCB8C9662D5549B665234849D843A/",
description="Requires at least 15 own blue and green project cards in play.\n:Milestone:\n",
tooltip="Click to claim 'Tycoon' milestone.\nRequires at least 15 own blue and green project cards in play.",
name="Tycoon"},
Legend={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436817050/17776E2E5A0ECABE62B6DA1CED9DB57120F18F23/",
description="Requires at least 5 own played event cards.\n:Milestone:\nReqs: 5 OwnEvent",
tooltip="Click to claim 'Legend' milestone.\nRequires at least 5 own played event cards.",
name="Legend"},
Economizer={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436821175/A666E81D5CCB66C72D9409A64548E2BA50382166/",
description="Requires a heat production of 5 or more.\n:Milestone:\nReqs: 5 OwnHeat",
tooltip="Click to claim 'Economizer' milestone.\nRequires a heat production of 5 or more.",
name="Economizer",
expansions={"pathfinders"}},
Pioneer={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436814808/3B60A3C1269DFA56FE912A7F20E6129F74B69A3A/",
description="Requires 3 own colonies.\n:Milestone:\nReqs: 3 OwnColony",
tooltip="Click to claim 'Pioneer' milestone.\nRequires 3 own colonies.",
name="Pioneer",
expansions={"colonies","pathfinders"}},
LandSpecialist={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436817663/E9DE57FE0FB25BFF872D9725805C883EED64E871/",
description="Requires 3 own special tiles in play.\n:Milestone:\nReqs: 3 OwnSpecialTile",
tooltip="Click to claim 'Land Specialist' milestone.\nRequires 3 own special tiles in play.",
name="Land Specialist",
expansions={"pathfinders"}},
Martian={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436816054/3EF7460E9DCF55F6FCCA307BBE56E86C371805AA/",
description="Requires at least 4 own Mars tags in play.\n:Milestone:\nReqs: 4 OwnMars",
tooltip="Click to claim 'Martian' milestone.\nRequires at least 4 own Mars tags in play.",
name="Martian",
expansions={"pathfinders"}},
Businessman={imageUrl="http://cloud-3.steamusercontent.com/ugc/1649969935436807962/8047A49D234CE70DF107528136AA68D7B0DBD4E9/",
description="Requires at least 6 own Earth tags in play.\n:Milestone:\nReqs: 6 OwnEarth",
tooltip="Click to claim 'Businessman' milestone.\nRequires at least 6 own Earth tags in play.",
name="Businessman",
expansions={"pathfinders"}},
Hoverlord={imageUrl="http://cloud-3.steamusercontent.com/ugc/797611191276163631/A06B69D04F5B3A9C6F38F82631DF45C58EE1C005/",
description="Requires at least 7 floaters on own cards\n:Milestone:\nReqs: 7 OwnFloater",
tooltip="Click to claim 'Hoverlord' milestone.\nRequires at least 7 floaters on own cards.",
name="Hoverlord",
expansions={"venus"}}
}
milestoneData.sets={{"Terraformer","Mayor","Gardener","Builder","Planner"},
{"Diversifier","Tactician","PolarExplorer","Energizer","RimSettler"},
{"Generalist","Specialist","Ecologist","Tycoon","Legend"},
{"Economizer","Pioneer","LandSpecialist","Martian","Businessman"}}
milestoneData.images={
"http://cloud-3.steamusercontent.com/ugc/1691647690039310389/3D36183648D464CBA3A7A92C0E7F097E8F2774A7/",
"http://cloud-3.steamusercontent.com/ugc/1691647690039310879/80BF8BE87F80082863F5675C278DF43188B6531F/",
"http://cloud-3.steamusercontent.com/ugc/1691647690039311289/ED5FEF20200E13B4BE085024AC5342E05F30500F/"
}
milestoneData.getMilestoneInfoByName=function(name)
for key,info in pairs(milestoneData.infos) do
if key==name then
return info
end
end
end

function milestoneSystem_unclaimMilestone(params)
return milestoneSystem.unclaimMilestone(params.milestoneIndex)
end
function milestoneSystem_toggleMilestones(params)
milestoneSystem.changeMilestoneSet(params.nextSet)
end
milestoneSystem={}
milestoneSystem.milestoneTilesInitialized=false
milestoneSystem.initialize=function()
milestoneSystem.setupMilestones()
Wait.time(function() milestoneSystem.changeMilestoneSet(1) end,5)
end
milestoneSystem.tryClaimMilestone=function(playerColor,milestoneDescription,milestoneName,milestonePosition,tileGuid)
local requirements=descriptionInterpreter.getKeyValuePairsFromInput(milestoneDescription,"Reqs:")
local tmPlayer=getPlayerByColor(playerColor)
if #gameState.claimedMilestones==gameState.milestones.maxClaims then
logging.printToColor("You cannot claim "..milestoneName..". "..gameState.milestones.maxClaims.." milestones have been already claimed.",playerColor,playerColor,loggingModes.important)
return false
end
local hasChimeraCorp=false
for _,card in pairs(tmPlayer.ownedCards.Corp) do
if card.guid=="e91b19" then
tmPlayer.tagSystem.tagCounts["WildCard"]=tmPlayer.tagSystem.tagCounts["WildCard"] - 1
hasChimeraCorp=true
end
end
if next(requirements)==nil then
if not specialMilestones.evaluateMilestone(tmPlayer,milestoneName) then
return false
end
end
local isAllowed=milestoneSystem.checkPrerequisites(tmPlayer,requirements)
if isAllowed then
milestoneSystem.claimMilestone(tmPlayer,milestoneName,milestonePosition,tileGuid)
end
if hasChimeraCorp then
tmPlayer.tagSystem.tagCounts["WildCard"]=tmPlayer.tagSystem.tagCounts["WildCard"] + 1
end
return isAllowed
end
milestoneSystem.checkPrerequisites=function(tmPlayer,requirements)
local requirementsFulfilled=objectActivationSystem.objectRequirementsFulfilled(tmPlayer,{rawRequirements=requirements})
if requirementsFulfilled then
local activationEffects={resourceValues={Credits=-8}}
local canAfford=objectActivationSystem_doAction({playerColor=tmPlayer.color,
sourceName="claiming a milestone",
activationEffects=activationEffects})
if canAfford then
return true
end
end
return false
end
milestoneSystem.setupMilestones=function(override)
function setupMilestonesCoroutine()
while transientState.setupMilestonesOngoing do
coroutine.yield(0)
end
transientState.setupMilestonesOngoing=true
if gameState.milestoneGuids~=nil then
for _,guid in pairs (gameState.milestoneGuids) do
local obj=getObjectFromGUID(guid)
if obj~=nil then
obj.destruct()
end
end
end
gameState.milestoneGuids={}
local milestonePlate=gameObjectHelpers.getObjectByName("milestonePlate")
milestonePlate.call("resetSpawnPositions")
local toSpawn=gameConfig.milestones.randomizer.enabled and gameConfig.milestones.randomizer.numberOfMilestones or 5
if override~=nil then toSpawn=override end
for i=1,toSpawn do
milestoneSystem.spawnMilestoneTile()
end
while #gameState.milestoneGuids < toSpawn do
coroutine.yield(0)
end
for i=1,30 do
coroutine.yield(0)
end
transientState.setupMilestonesOngoing=false
return 1
end
startLuaCoroutine(self,"setupMilestonesCoroutine")
end
milestoneSystem.randomize=function()
function randomizeCoroutine()
while transientState.setupMilestonesOngoing or transientState.milestoneRandomizerWorking do
coroutine.yield(0)
end
transientState.milestoneRandomizerWorking=true
transientState.latestMilestones=tableHelpers.deepClone(milestoneData.infos)
local mustHaves={}
if gameConfig.milestones.randomizer.guranteeHoverlord and gameConfig.setup.venus then
mustHaves={"Hoverlord"}
end
for _,guid in pairs(gameState.milestoneGuids) do
local milestoneInfo=awardAndMilestoneFunctions.getNextRandomInfo(transientState.latestMilestones,mustHaves)
milestoneSystem.changeMilestone(guid,milestoneInfo)
end
transientState.milestoneRandomizerWorking=false
return 1
end
startLuaCoroutine(self,"randomizeCoroutine")
end
milestoneSystem.spawnMilestoneTile=function(milestoneInfo)
local milestonePlate=gameObjectHelpers.getObjectByName("milestonePlate")
local milestoneDefaultTile=gameObjectHelpers.getObjectByName("milestoneDefaultTile")
local scale=milestoneDefaultTile.getScale()
local cloneCallback=function(clonedGuid)
local clonedTile=getObjectFromGUID(clonedGuid)
clonedTile.setLock(false)
clonedTile.interactable=false
Wait.time(function()
clonedTile.setLock(true)
clonedTile.setScale(scale)
table.insert(gameState.milestoneGuids,clonedGuid)
if milestoneInfo~=nil then
milestoneSystem.changeMilestone(clonedGuid,milestoneInfo)
end
end,2)
end
local nextSpawnPositionLocal=milestonePlate.call("getNextSpawnPosition")
if nextSpawnPositionLocal==nil then
logging.broadcastToAll("Unable to spawn milestone tile: All milestone spaces are occupied. This shouldn't happen,please report as a bug in Discord. Please create a save and attach it to the bug message/report.")
return
end
local nextSpawnPositionWorld=vectorHelpers.fromLocalToWorld(milestonePlate,nextSpawnPositionLocal)
createClonableObject(milestoneDefaultTile,nextSpawnPositionWorld,{0,180,0},cloneCallback,true)
end
milestoneSystem.claimMilestone=function(tmPlayer,milestoneName,milestonePosition,tileGuid)
function claimMilestoneCoroutine()
local claimedMilestones=#gameState.claimedMilestones + 1
local milestonePlate=gameObjectHelpers.getObjectByName("milestonePlate")
local localClaimPosition=vectorHelpers.addVectors(milestonePlate.call("getClaimLocalPositions")[claimedMilestones],{0,0.15,0})
local nextFreeClaimPosition=vectorHelpers.fromLocalToWorld(milestonePlate,localClaimPosition,true)
local markers=getObjectFromGUID(getPlayerByColor(tmPlayer.color).playerArea.playerMat).call("getPlayerMarkerSource")
local claimMarker=markers.takeObject({position=nextFreeClaimPosition})
coroutine.yield(0)
coroutine.yield(0)
local milestoneMarker=markers.takeObject({position=vectorHelpers.addVectors(milestonePosition,{0,0.4,0.3})})
milestoneMarker.interactable=false
milestoneMarker.setLock(true)
coroutine.yield(0)
coroutine.yield(0)
logging.printToAll("Player "..tmPlayer.color.." claimed "..milestoneName,{1,1,1,1},loggingModes.important)
table.insert(gameState.claimedMilestones,
{owner=tmPlayer.color,
milestoneName=milestoneName,
index=claimedMilestones,
tileGuid=tileGuid,
cubeGuids={milestoneMarker.getGUID(),claimMarker.getGUID()}} )
milestoneSystem.updateTokens()
gameState.wasUpdated=true
gameObjectHelpers.getObjectByName("milestonePlate").call("addClaim")
return 1
end
startLuaCoroutine(self,"claimMilestoneCoroutine")
end
milestoneSystem.updateTokens=function()
for i,guid in pairs(gameState.milestoneGuids) do
local obj=getObjectFromGUID(guid)
if #gameState.claimedMilestones==gameState.milestones.maxClaims then
obj.call("removeAllButtons")
else
obj.call("updateButtons")
end
end
end
milestoneSystem.unclaimMilestone=function(milestoneIndex)
if milestoneIndex~=#gameState.claimedMilestones then
logging.printToAll("Only allowed to revoke the last claimed milestone.",{1,1,1,1},loggingModes.important)
return false
end
for i,info in pairs(gameState.claimedMilestones) do
if info.index==milestoneIndex then
local  activationEffects={resourceValues={Credits=8}}
objectActivationSystem_doAction({playerColor=info.owner,
sourceName="revoking the claim on a milestone",
activationEffects=activationEffects})
for _,guid in pairs(info.cubeGuids) do
local obj=getObjectFromGUID(guid)
if obj~=nil then
obj.destruct()
end
end
getObjectFromGUID(info.tileGuid).call("unclaim")
gameState.claimedMilestones[i]=nil
logging.printToAll("Player "..info.owner.." revoked claim on '"..info.milestoneName.."'",{1,1,1,1},loggingModes.important)
end
end
milestoneSystem.updateTokens()
gameState.wasUpdated=true
return true
end
milestoneSystem.changeMilestoneSet=function(setIndex)
function changeMilestoneSetCoroutine()
if #gameState.milestoneGuids~=5 then
milestoneSystem.setupMilestones(5)
end
local counter=5
while counter > 0 do
counter=counter - 1
if transientState.setupMilestonesOngoing then
counter=30
end
coroutine.yield(0)
end
if gameConfig.milestones.randomizer.enabled then
transientState.latestMilestones=tableHelpers.deepClone(milestoneData.infos)
else
if gameState.setupIsDone and gameConfig.setup.venus then
milestoneSystem.spawnMilestoneTile(milestoneData.infos.Hoverlord)
end
end
for i=1,5 do
local guid=gameState.milestoneGuids[i]
local milestoneInfo=milestoneData.getMilestoneInfoByName(milestoneData.sets[setIndex][i])
milestoneSystem.changeMilestone(guid,milestoneInfo)
if gameConfig.milestones.randomizer.enabled then
transientState.latestMilestones[milestoneData.sets[setIndex][i]].dealt=true
end
end
return 1
end
startLuaCoroutine(self,"changeMilestoneSetCoroutine")
end
milestoneSystem.changeMilestone=function(guid,milestoneInfo)
local obj=getObjectFromGUID(guid)
obj.setDescription(milestoneInfo.description)
obj.setName(milestoneInfo.name)
local customization={}
customization.image=milestoneInfo.imageUrl
obj.setCustomObject(customization)
local reloadedObj=obj.reload()
if gameConfig.milestones.randomizer.enabled then
Wait.frames(|| reloadedObj.call("enableChangeButton"),2)
end
Wait.frames(|| reloadedObj.call("setClaimButtonTooltip",milestoneInfo.tooltip),2)
end
milestoneSystem.turmoilSpecialHandling=function()
for i,guid in pairs(gameState.milestoneGuids) do
if milestoneData.infos.Terraformer.name==getObjectFromGUID(guid).getName() then
milestoneSystem.changeMilestone(guid,milestoneData.infos.TurmoilTerraformer)
return
end
end
end


function milestonesAndAwards_claim(params)
local position=params.position
if params.positionOffset~=nil then
position=vectorHelpers.addVectors(params.position,params.positionOffset)
end
if descriptionInterpreter.contains(params.description,":Award:") then
return awardSystem.tryclaimAward(params.playerColor,params.description,params.name,position,params.tileGuid)
elseif descriptionInterpreter.contains(params.description,":Milestone:") then
return milestoneSystem.tryClaimMilestone(params.playerColor,params.description,params.name,position,params.tileGuid)
end
end
function awardSystem_unclaimAward(params)
return awardSystem.unclaimAward(params.awardIndex)
end
function awardSystem_toggleAwards(params)
awardSystem.changeAwardSet(params.nextSet)
end
awardSystem={}
awardSystem.initialize=function()
awardSystem.setupAwards()
Wait.time(function() awardSystem.changeAwardSet(1) end,5)
end
awardSystem.setupAwards=function(override)
function setupAwardsCoroutine()
while transientState.setupAwardsOngoing do
coroutine.yield(0)
end
transientState.setupAwardsOngoing=true
if gameState.awardGuids~=nil then
for _,guid in pairs (gameState.awardGuids) do
local obj=getObjectFromGUID(guid)
if obj~=nil then
obj.destruct()
end
end
end
gameState.awardGuids={}
local awardPlate=gameObjectHelpers.getObjectByName("awardPlate")
awardPlate.call("resetSpawnPositions")
local toSpawn=gameConfig.awards.randomizer.enabled and gameConfig.awards.randomizer.numberOfAwards or 5
if override~=nil then toSpawn=override end
for i=1,toSpawn do
awardSystem.spawnAwardTile()
end
while #gameState.awardGuids < toSpawn do
coroutine.yield(0)
end
for i=1,30 do
coroutine.yield(0)
end
transientState.setupAwardsOngoing=false
return 1
end
startLuaCoroutine(self,"setupAwardsCoroutine")
end
awardSystem.randomize=function()
function randomizeCoroutine()
while transientState.setupAwardsOngoing or transientState.awardRandomizerWorking do
coroutine.yield(0)
end
transientState.awardRandomizerWorking=true
transientState.latestAwards=tableHelpers.deepClone(awardData.infos)
local mustHaves={}
if gameConfig.awards.randomizer.guranteeVenuphile and gameConfig.setup.venus then
mustHaves={"Venuphile"}
end
for _,guid in pairs(gameState.awardGuids) do
local awardInfo=awardAndMilestoneFunctions.getNextRandomInfo(transientState.latestAwards,mustHaves)
awardSystem.changeAward(guid,awardInfo)
end
transientState.awardRandomizerWorking=false
return 1
end
startLuaCoroutine(self,"randomizeCoroutine")
end
awardSystem.spawnAwardTile=function(awardInfo)
local awardPlate=gameObjectHelpers.getObjectByName("awardPlate")
local awardDefaultTile=gameObjectHelpers.getObjectByName("milestoneAndAwardDefaultTile")
local scale=awardDefaultTile.getScale()
local cloneCallback=function(clonedGuid)
local clonedTile=getObjectFromGUID(clonedGuid)
clonedTile.setLock(false)
clonedTile.interactable=false
Wait.time(function()
clonedTile.setLock(true)
clonedTile.setScale(scale)
table.insert(gameState.awardGuids,clonedGuid)
if awardInfo~=nil then
awardSystem.changeAward(clonedGuid,awardInfo)
end
end,2)
end
local nextSpawnPositionLocal=awardPlate.call("getNextSpawnPosition")
if nextSpawnPositionLocal==nil then
logging.broadcastToAll("Unable to spawn award tile: All award spaces are occupied. This shouldn't happen,please report as a bug in Discord. Please create a save and attach it to the bug message/report.")
return
end
local nextSpawnPositionWorld=vectorHelpers.fromLocalToWorld(awardPlate,nextSpawnPositionLocal)
createClonableObject(awardDefaultTile,nextSpawnPositionWorld,{0,180,0},cloneCallback,true)
end
awardSystem.tryclaimAward=function(playerColor,awardDescription,awardName,awardPosition,tileGuid)
local tmPlayer=getPlayerByColor(playerColor)
local numberOfClaimedAwards=#gameState.claimedAwards
if numberOfClaimedAwards==gameState.awards.maxFunders then
logging.printToColor("You cannot claim "..awardName..". "..gameState.awards.maxFunders.." awards have been already claimed.",playerColor,playerColor,loggingModes.important)
return false
end
local costTableIndex=gameState.awards.maxFunders - 2
local funded=numberOfClaimedAwards + 1
local activationEffects={resourceValues={Credits=awardData.costTable[costTableIndex][funded]}}
local canAfford=objectActivationSystem_doAction({playerColor=tmPlayer.color,
sourceName="claiming an award",
activationEffects=activationEffects})
if canAfford then
awardSystem.claimAward(tmPlayer,awardName,awardPosition,tileGuid)
end
return canAfford
end
awardSystem.claimAward=function(tmPlayer,awardName,awardPosition,tileGuid)
function claimAwardCoroutine()
local numberOfClaimedAwards=#gameState.claimedAwards + 1
local awardPlate=gameObjectHelpers.getObjectByName("awardPlate")
local offset=5 - gameState.awards.maxFunders
local localClaimPosition=vectorHelpers.addVectors(awardPlate.call("getClaimLocalPositions")[numberOfClaimedAwards + offset],{0,0.15,0})
local nextFreeClaimPosition=vectorHelpers.fromLocalToWorld(awardPlate,localClaimPosition,true)
local markers=getObjectFromGUID(getPlayerByColor(tmPlayer.color).playerArea.playerMat).call("getPlayerMarkerSource")
local claimMarker=markers.takeObject({position=nextFreeClaimPosition})
coroutine.yield(0)
coroutine.yield(0)
local awardMarker=markers.takeObject({position=vectorHelpers.addVectors(awardPosition,{0,0.4,0.3})})
awardMarker.interactable=false
awardMarker.setLock(true)
coroutine.yield(0)
coroutine.yield(0)
logging.printToAll("Player "..tmPlayer.color.." claimed "..awardName,{1,1,1,1},loggingModes.important)
table.insert(gameState.claimedAwards,
{owner=tmPlayer.color,
awardName=awardName,
index=numberOfClaimedAwards,
tileGuid=tileGuid,
cubeGuids={awardMarker.getGUID(),claimMarker.getGUID()}} )
awardSystem.updateTokens()
gameState.wasUpdated=true
gameObjectHelpers.getObjectByName("awardPlate").call("addClaim",offset)
return 1
end
startLuaCoroutine(self,"claimAwardCoroutine")
end
awardSystem.unclaimAward=function(awardIndex)
if awardIndex~=#gameState.claimedAwards then
logging.printToAll("Only allowed to revoke the last claimed award.",{1,1,1,1},loggingModes.important)
return false
end
for i,info in pairs(gameState.claimedAwards) do
if info.index==awardIndex then
local costTableIndex=gameState.awards.maxFunders - 2
local activationEffects={resourceValues={Credits=-awardData.costTable[costTableIndex][awardIndex]}}
objectActivationSystem_doAction({playerColor=info.owner,
sourceName="revoking the claim on an award",
activationEffects=activationEffects})
for _,guid in pairs(info.cubeGuids) do
local obj=getObjectFromGUID(guid)
if obj~=nil then
obj.destruct()
end
end
getObjectFromGUID(info.tileGuid).call("unclaim")
gameState.claimedAwards[i]=nil
logging.printToAll("Player "..info.owner.." revoked claim on '"..info.awardName.."'",{1,1,1,1},loggingModes.important)
end
end
awardSystem.updateTokens()
gameState.wasUpdated=true
return true
end
awardSystem.changeAwardSet=function(setIndex)
function changeAwardSetCoroutine()
if #gameState.awardGuids~=5 then
awardSystem.setupAwards(5)
end
local counter=5
while counter > 0 do
counter=counter - 1
if transientState.setupAwardsOngoing then
counter=30
end
coroutine.yield(0)
end
if gameConfig.awards.randomizer.enabled then
transientState.latestAwards=tableHelpers.deepClone(awardData.infos)
else
if gameState.setupIsDone and gameConfig.setup.venus then
awardSystem.spawnAwardTile(awardData.infos.Venuphile)
end
end
for i=1,5 do
local guid=gameState.awardGuids[i]
local awardInfo=awardData.getAwardInfoByName(awardData.sets[setIndex][i])
awardSystem.changeAward(guid,awardInfo)
if gameConfig.awards.randomizer.enabled then
transientState.latestAwards[awardData.sets[setIndex][i]].dealt=true
end
end
return 1
end
startLuaCoroutine(self,"changeAwardSetCoroutine")
end
awardSystem.changeAward=function(guid,info)
local obj=getObjectFromGUID(guid)
obj.setDescription(info.description)
obj.setName(info.name)
local customization={}
customization.image=info.imageUrl
obj.setCustomObject(customization)
local reloadedObj=obj.reload()
if gameConfig.awards.randomizer.enabled then
Wait.frames(|| reloadedObj.call("enableChangeButton"),2)
end
Wait.frames(|| reloadedObj.call("setClaimButtonTooltip",info.tooltip),2)
end
awardSystem.updateTokens=function()
for i,guid in pairs(gameState.awardGuids) do
local obj=getObjectFromGUID(guid)
if #gameState.claimedAwards==gameState.awards.maxFunders then
obj.call("removeAllButtons")
else
obj.call("updateButtons")
end
end
end


awardAndMilestoneFunctions={}
awardAndMilestoneFunctions.getNextRandomInfo=function(inputTable,mustHaves)
if mustHaves~=nil then
for _,mustHave in pairs(mustHaves) do
if inputTable[mustHave]~=nil and not inputTable[mustHave].dealt then
inputTable[mustHave].dealt=true
return inputTable[mustHave]
end
end
end
local count=0
for key,info in pairs(inputTable) do
if not info.dealt and awardAndMilestoneFunctions.expansionsAreSupported(info) then
count=count + 1
end
end
local r=math.random(1,count)
count=1
for key,info in pairs(inputTable) do
if not info.dealt and awardAndMilestoneFunctions.expansionsAreSupported(info) then
if count==r then
info.dealt=true
return info
end
count=count + 1
end
end
end
awardAndMilestoneFunctions.expansionsAreSupported=function(info)
if info.expansions==nil then
return true
end
for _,expansionName in pairs(info.expansions) do
if string.match(expansionName,"NOT") then
local trimmedExpansionName=expansionName:gsub("NOT","")
if gameConfig.setup[trimmedExpansionName]~=nil and gameConfig.setup[trimmedExpansionName]==true then
return false
end
else
if gameConfig.setup[expansionName]~=nil and gameConfig.setup[expansionName]==false then
return false
end
end
end
return true
end
awardAndMilestoneFunctions.finalizeRandomizer=function()
if gameConfig.milestones.randomizer.enabled then
gameState.milestones.maxClaims=gameConfig.milestones.randomizer.maxClaims
for i,guid in pairs(gameState.milestoneGuids) do
local obj=getObjectFromGUID(guid)
if obj~=nil then
obj.call("disableChangeButtton")
end
end
end
if gameConfig.awards.randomizer.enabled then
gameState.awards.maxFunders=gameConfig.awards.randomizer.maxFunders
for i,guid in pairs(gameState.awardGuids) do
local obj=getObjectFromGUID(guid)
if obj~=nil then
obj.call("disableChangeButtton")
end
end
end
end
function awardAndMilestoneFunctions_changeMilestoneOrAward(params)
local lastName=params.currentName
local isMilestone=descriptionInterpreter.contains(params.description,":Milestone:")
local isAward=descriptionInterpreter.contains(params.description,":Award:")
if isMilestone then
local milestoneInfo=awardAndMilestoneFunctions.getNextRandomInfo(transientState.latestMilestones)
milestoneSystem.changeMilestone(params.guid,milestoneInfo)
for key,info in pairs(transientState.latestMilestones) do
if info.name==lastName then
info.dealt=false
end
end
elseif isAward then
local awardInfo=awardAndMilestoneFunctions.getNextRandomInfo(transientState.latestAwards)
awardSystem.changeAward(params.guid,awardInfo)
for key,info in pairs(transientState.latestAwards) do
if info.name==lastName then
info.dealt=false
end
end
end
end


awardScoring={}
awardScoring.calculateAllPlayerAwardScores=function()
local vps={}
for _,awardInfo in pairs(gameState.claimedAwards) do
local awardResults=awardScoring.evaluateAward(awardInfo.awardName)
for _,result in pairs(awardResults.firstPlaces) do
if vps[result.color]==nil then
vps[result.color]=5
else
vps[result.color]=vps[result.color] + 5
end
end
for _,result in pairs(awardResults.secondPlaces) do
if vps[result.color]==nil then
vps[result.color]=2
else
vps[result.color]=vps[result.color] + 2
end
end
end
return vps
end
awardScoring.evaluateAward=function(awardName)
local scoringFunction=nil
if awardName=="Landlord" then
scoringFunction=awardScoring.scoreLandlord(awardName)
elseif awardName=="Banker" then
scoringFunction=awardScoring.scoreBanker(awardName)
elseif awardName=="Scientist" then
scoringFunction=awardScoring.scoreScientist(awardName)
elseif awardName=="Thermalist" then
scoringFunction=awardScoring.scoreThermalist(awardName)
elseif awardName=="Miner" then
scoringFunction=awardScoring.scoreMiner(awardName)
elseif awardName=="Cultivator" then
scoringFunction=awardScoring.scoreCultivator(awardName)
elseif awardName=="Magnate" then
scoringFunction=awardScoring.scoreMagnate(awardName)
elseif awardName=="Space Baron" then
scoringFunction=awardScoring.scoreSpaceBaron(awardName)
elseif awardName=="Excentric" then
scoringFunction=awardScoring.scoreExcentric(awardName)
elseif awardName=="Contractor" then
scoringFunction=awardScoring.scoreContractor(awardName)
elseif awardName=="Celebrity" then
scoringFunction=awardScoring.scoreCelebrity(awardName)
elseif awardName=="Industrialist" then
scoringFunction=awardScoring.scoreIndustrialist(awardName)
elseif awardName=="Desert Settler" then
scoringFunction=awardScoring.scoreDesertSettler(awardName)
elseif awardName=="Estate Dealer" then
scoringFunction=awardScoring.scoreEstateDealer(awardName)
elseif awardName=="Benefactor" then
scoringFunction=awardScoring.scoreBenefactor(awardName)
elseif awardName=="Cosmic Settler" then
scoringFunction=awardScoring.scoreCosmicSettler(awardName)
elseif awardName=="Botanist" then
scoringFunction=awardScoring.scoreBotanist(awardName)
elseif awardName=="Coordinator" then
scoringFunction=awardScoring.scoreCoordinator(awardName)
elseif awardName=="Zoologist" then
scoringFunction=awardScoring.scoreZoologist(awardName)
elseif awardName=="Manufacturer" then
scoringFunction=awardScoring.scoreManufacturer(awardName)
elseif awardName=="Venuphile" then
scoringFunction=awardScoring.scoreVenuphile(awardName)
end
local comparsionTable={}
if scoringFunction~=nil then
for _,player in pairs(gameState.allPlayers) do
comparsionTable[player.color]=scoringFunction(player)
end
else
logging.broadcastToAll("Unknown award "..awardName..". Please report as a bug and calculate award VPs manually.",{1,0.5,0,1},loggingModes.exception)
end
return awardScoring.determineFirstAndSecondPlaces(comparsionTable,awardName)
end
awardScoring.scoreLandlord=function(awardName)
return function(player)
local amount=0
for _,guid in pairs(gameState.citiesInSpaceGuids) do
local obj=getObjectFromGUID(guid)
if obj~=nil then
if obj.getVar("objectState").ownedByPlayer==player.color then
amount=amount + 1
end
end
end
for i,jkMatrix in pairs(gameMap.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
if tile.tileObjects~=nil then
for _,tileObject in pairs(tile.tileObjects) do
if tileObject.owner==player.color then
amount=amount + 1
break
end
end
end
end
end
end
return amount
end
end
awardScoring.scoreBanker=function(awardName)
return function(player)
return getPlayerProduction({resourceType="credits",playerColor=player.color})
end
end
awardScoring.scoreScientist=function(awardName)
return function(player)
return player.tagSystem.tagCounts.Science
end
end
awardScoring.scoreThermalist=function(awardName)
return function(player)
return getPlayerResource({resourceType="heat",playerColor=player.color})
end
end
awardScoring.scoreMiner=function(awardName)
return function(player)
local amount=getPlayerResource({resourceType="steel",playerColor=player.color})
amount=amount + getPlayerResource({resourceType="titanium",playerColor=player.color})
return amount
end
end
awardScoring.scoreCultivator=function(awardName)
return function(player)
return player.ownedObjects.greenery
end
end
awardScoring.scoreMagnate=function(awardName)
return function(player)
return #player.ownedCards.Green
end
end
awardScoring.scoreSpaceBaron=function(awardName)
return function(player)
return player.tagSystem.tagCounts.Space
end
end
awardScoring.scoreExcentric=function(awardName)
return function(player)
local amount=0
local cardsToConsider=tableHelpers.combineSingleValueTables({player.ownedCards["Blue"],player.ownedCards["Corp"]})
for _,card in pairs(cardsToConsider) do
local cardObject=getObjectFromGUID(card.guid)
if cardObject==nil then
printToColor("Card "..card.name.." didn't get considered for the "..awardName.." award - card is probably in a stack.",player.color,player.color)
else
local tokensAccepted=cardObject.call("getAcceptedTokenList")
if next(tokensAccepted)~=nil then
amount=amount + cardObject.getVar("cardState").counters[1]
if cardObject.getGUID()=="5052f7" then
amount=amount + cardObject.getVar("cardState").counters[2]
end
end
end
end
return amount
end
end
awardScoring.scoreContractor=function(awardName)
return function(player)
return player.tagSystem.tagCounts.Building
end
end
awardScoring.scoreCelebrity=function(awardName)
return function(player)
return findCostyCards(player,20)
end
end
awardScoring.scoreIndustrialist=function(awardName)
return function(player)
local amount=getPlayerResource({resourceType="steel",playerColor=player.color})
amount=amount + getPlayerResource({resourceType="energy",playerColor=player.color})
return amount
end
end
awardScoring.scoreDesertSettler=function(awardName)
return function(player)
local jStart=math.floor((#gameMap.tiles[0]+1)/2)
local tilesCoordsOfInterest={}
for j=1,math.floor((#gameMap.tiles[0]+1)/2) do
table.insert(tilesCoordsOfInterest,normalizeIndices({0,jStart + j,0}))
for i=1,100,1 do
if hexMapHelpers.getTileFromArbitraryHexCoords(gameMap,{i,jStart + j,0})~=nil then
table.insert(tilesCoordsOfInterest,normalizeIndices({i,jStart + j,0}))
else
break
end
end
for i=-1,-100,-1 do
if hexMapHelpers.getTileFromArbitraryHexCoords(gameMap,{i,jStart + j,0})~=nil then
table.insert(tilesCoordsOfInterest,normalizeIndices({i,jStart + j,0}))
else
break
end
end
end
local ownedTiles=0
for _,tileCoordinates in pairs(tilesCoordsOfInterest) do
local tile=gameMap.tiles[tileCoordinates[1]][tileCoordinates[2]][tileCoordinates[3]]
if tile.tileObjects~=nil then
for _,obj in pairs(tile.tileObjects) do
if obj.owner==player.color then
ownedTiles=ownedTiles + 1
break
end
end
end
end
return ownedTiles
end
end
awardScoring.scoreEstateDealer=function(awardName)
return function(player)
local amount=0
for i,jkMatrix in pairs(gameMap.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
if tile.tileObjects~=nil then
local adjacencyFulfilled=false
for _,tileObject in pairs(tile.tileObjects) do
if tileObject.owner==player.color then
for _,neighbourTile in pairs(Global.call("hexMap_getNeighbours",{indices={i,j,k}})) do
if neighbourTile.tileObjects~=nil then
for _,neighbourTileObject in pairs(neighbourTile.tileObjects) do
if neighbourTileObject.objectName=="ocean" and not adjacencyFulfilled then
amount=amount + 1
adjacencyFulfilled=true
end
end
end
end
end
end
end
end
end
end
return amount
end
end
awardScoring.scoreBenefactor=function(awardName)
return function(player)
return player.terraformingRating
end
end
awardScoring.scoreCosmicSettler=function(awardName)
return function(player)
local amount=0
for _,guid in pairs(gameState.citiesInSpaceGuids) do
local obj=getObjectFromGUID(guid)
if obj~=nil then
if obj.getVar("objectState").ownedByPlayer==player.color then
amount=amount + 1
end
end
end
return amount
end
end
awardScoring.scoreBotanist=function(awardName)
return function(player)
return getPlayerProduction({resourceType="plants",playerColor=player.color})
end
end
awardScoring.scoreCoordinator=function(awardName)
return function(player)
return player.tagSystem.tagCounts.Event
end
end
awardScoring.scoreZoologist=function(awardName)
return function(player)
return player.ownedObjects.animal
end
end
awardScoring.scoreManufacturer=function(awardName)
return function(player)
return #player.ownedCards.Blue
end
end
awardScoring.scoreVenuphile=function(awardName)
return function(player)
return player.tagSystem.tagCounts.Venus
end
end
awardScoring.determineFirstAndSecondPlaces=function(comparsionTable,awardName)
local firstPlaces={}
local secondPlaces={}
local playerCount=0
for color,amount in pairs(comparsionTable) do
playerCount=playerCount + 1
if amount <= 0 then
printToColor("You do not compete for the '"..awardName.."' award. (Your contribution is 0)",color,color)
elseif #firstPlaces==0 then
table.insert(firstPlaces,{color=color,amount=amount})
elseif amount < firstPlaces[1].amount and #firstPlaces==1 then
if #secondPlaces==0 then
table.insert(secondPlaces,{color=color,amount=amount})
elseif amount==secondPlaces[1].amount then
table.insert(secondPlaces,{color=color,amount=amount})
elseif amount > secondPlaces[1].amount then
secondPlaces={}
table.insert(secondPlaces,{color=color,amount=amount})
end
elseif amount==firstPlaces[1].amount then
table.insert(firstPlaces,{color=color,amount=amount})
secondPlaces={}
elseif amount > firstPlaces[1].amount then
secondPlaces={}
for _,colorAndAmount in pairs(firstPlaces) do
table.insert(secondPlaces,{color=colorAndAmount.color,amount=colorAndAmount.amount})
end
firstPlaces={}
table.insert(firstPlaces,{color=color,amount=amount})
end
end
if playerCount==2 then
return {firstPlaces=firstPlaces,secondPlaces={}}
elseif playerCount > 2 then
return {firstPlaces=firstPlaces,secondPlaces=secondPlaces}
else
return {firstPlaces={},secondPlaces={}}
end
end


globalParameterSystem={}
globalParameterSystem.values={
temperature={
value=-30,
stepIndex=1,
selection=1,
extra=0,
isDone=false,
friendlyName="Temperature",
tokenName="temperatureToken",
bonusSelection=1,
aresSelection=1,
},
oxygen={
value=0,
stepIndex=1,
selection=1,
extra=0,
isDone=false,
friendlyName="Oxygen",
tokenName="oxygenToken",
bonusSelection=1,
aresSelection=1,
},
venus={
value=0,
stepIndex=1,
selection=1,
extra=0,
isDone=false,
friendlyName="Venus",
tokenName="scrappingToken",
bonusSelection=1,
aresSelection=1,
},
ocean={
value=0,
stepIndex=1,
selection=1,
extra=0,
isDone=false,
friendlyName="Oceans",
tokenName="oceanToken",
bonusSelection=1,
aresSelection=1,
},
}
globalParameterSystem.increaseParameterMax=function(globalParameter)
local steps=globalParameter.mappings[values.selection].steps
steps[#steps+1]=2*steps[#steps] - steps[#steps-1]
end
globalParameterSystem.changeParameter=function(globalParameter,values,delta,playerColor,triggerEventType)
local steps=globalParameter.mappings[values.selection].steps
local currentStep=values.stepIndex
local maxSteps=#steps
local isAllowed=false
if currentStep + delta > maxSteps then
logging.printToAll(values.friendlyName.." is at maximum!",{1,0,0},loggingModes.essential)
elseif currentStep + delta > 0 and currentStep + delta <= maxSteps then
values.stepIndex=currentStep + delta
values.value=steps[values.stepIndex]
globalParameterSystem.updateMarker(globalParameter,steps,steps[currentStep + delta],values.tokenName)
if delta > 0 then
if gameState.currentPhase==phases.generationPhase or gameState.currentPhase==phases.draftingPhase then
for _,entry in pairs(globalParameter.bonus[values.bonusSelection]) do
if entry.value==values.value then
objectActivationSystem_doAction({activationEffects=entry.activationEffects,playerColor=playerColor,sourceName=values.friendlyName.." change"})
break
end
end
end
if gameState.ares and globalParameter.ares~=nil and globalParameter.ares[values.aresSelection]~=nil then
for _,entry in pairs(globalParameter.ares[values.aresSelection]) do
if entry.value==values.value then
local adjustedActivationEffects={}
if gameState.currentPhase~=phases.generationPhase then
adjustedActivationEffects={effects={}}
for _,effect in pairs(entry.activationEffects.effects) do
if effect~="TR" then
table.insert(adjustedActivationEffects.effects,effect)
end
end
else
adjustedActivationEffects=entry.activationEffects
end
objectActivationSystem_doAction({activationEffects=adjustedActivationEffects,playerColor=playerColor,sourceName=values.friendlyName.." change"})
break
end
end
end
end
isAllowed=true
elseif currentStep + delta <= 0 then
logging.printToAll(values.friendlyName.." is at minimum!",{1,0,0},loggingModes.essential)
end
if not values.isDone and ( currentStep==maxSteps or currentStep + delta >= maxSteps ) then
logging.broadcastToAll(values.friendlyName.." is now at maximum!",{1,0,0},loggingModes.essential)
values.isDone=true
elseif values.isDone and ( currentStep~=maxSteps or currentStep + delta < maxSteps ) then
values.isDone=false
end
if isAllowed and delta > 0 then
logging.printToAll(getPlayerByColor(playerColor).name.." has increased "..values.friendlyName.." by "..delta,playerColor,loggingModes.essential)
if gameState.currentPlayer~=-1 then
increasePlayerTRByColor(playerColor,values.friendlyName.." has been increased.")
end
elseif isAllowed and delta < 0 then
logging.printToAll(getPlayerByColor(playerColor).name.." has decreased "..values.friendlyName.." by "..delta,playerColor,loggingModes.essential)
if gameState.currentPlayer~=-1 then
decreasePlayerTRByColor(playerColor,values.friendlyName.." has been decreased.")
end
end
if isAllowed and triggerEventType~=nil then
Global.call("eventHandling_triggerEvent",{triggeredByColor=playerColor,triggerType=triggerEventType})
end
end
globalParameterSystem.setupButtons=function()
for name,globalParameterData in pairs(globalParameters) do
if name~=venus or gameState.activeExpansions.venus then
if globalParameterData.buttons~=nil then
local trackObj=getObjectFromGUID(globalParameterData.objectGuid)
for _,buttonInfo in pairs(globalParameterData.buttons) do
trackObj.createButton(buttonInfo)
end
end
end
end
end
globalParameterSystem.bonusSetup=function()
globalParameterSystem.spawnBonusMarkers(globalParameters.oxygen,
globalParameters.oxygen.mappings[globalParameterSystem.values.oxygen.selection].steps,
globalParameters.oxygen.bonus[globalParameterSystem.values.oxygen.bonusSelection])
globalParameterSystem.spawnBonusMarkers(globalParameters.temperature,
globalParameters.temperature.mappings[globalParameterSystem.values.temperature.selection].steps,
globalParameters.temperature.bonus[globalParameterSystem.values.temperature.bonusSelection])
globalParameterSystem.spawnBonusMarkers(globalParameters.ocean,
globalParameters.ocean.mappings[globalParameterSystem.values.ocean.selection].steps,
globalParameters.ocean.bonus[globalParameterSystem.values.ocean.bonusSelection])
if gameState.venus then
globalParameterSystem.spawnBonusMarkers(globalParameters.venus,
globalParameters.venus.mappings[globalParameterSystem.values.venus.selection].steps,
globalParameters.venus.bonus[globalParameterSystem.values.venus.bonusSelection])
end
if gameState.ares then
globalParameterSystem.spawnHazardMarkers("oxygen",
globalParameters.oxygen.mappings[globalParameterSystem.values.oxygen.selection].steps,
globalParameters.oxygen.ares[globalParameterSystem.values.oxygen.aresSelection])
globalParameterSystem.spawnHazardMarkers("temperature",
globalParameters.temperature.mappings[globalParameterSystem.values.temperature.selection].steps,
globalParameters.temperature.ares[globalParameterSystem.values.temperature.aresSelection])
globalParameterSystem.spawnHazardMarkers("ocean",
globalParameters.ocean.mappings[globalParameterSystem.values.ocean.selection].steps,
globalParameters.ocean.ares[globalParameterSystem.values.ocean.aresSelection])
end
end
globalParameterSystem.updateMarker=function(globalParameter,steps,currentStep,markerObjectName)
local trackObject=getObjectFromGUID(globalParameter.objectGuid)
local localTransform=computeTransformOnCircle(globalParameter.startTransform,globalParameter.finalTransform,
steps,currentStep)
local rotatedTransform=rotateTransformAroundY(localTransform,trackObject.getRotation()[1] - 180,globalParameter.trackRotation[2])
local targetPosition=vectorHelpers.addVectors(vectorHelpers.scaleVectorByVector(rotatedTransform.pos,trackObject.getScale()),trackObject.getPosition())
targetPosition=vectorHelpers.addVectors({0,0.25,0},targetPosition)
local marker=gameObjectHelpers.getObjectByName(markerObjectName)
marker.setPositionSmooth(targetPosition,false,true)
end
globalParameterSystem.spawnHazardMarkers=function(globalParameterName,globalParameterSteps,bonusMap)
local gpm=globalParameters[globalParameterName]
local baseBonusMarker=gameObjectHelpers.getObjectByName("baseBonusTokenGuid")
local trackObj=getObjectFromGUID(gpm.objectGuid)
for _,entry in pairs(bonusMap) do
if gpm.startTransform.rot[2]==gpm.finalTransform.rot[2] then
local localTargetPosition=computeInterpolatedPosition(globalParameterSteps,entry.value,
gpm.startTransform.pos,gpm.startTransform.rot,
gpm.endTransform.pos,gpm.endTransform.rot,
gpm.bonusMarkerOffset,trackObj.getScale())
local targetPosition=vectorHelpers.addVectors(localTargetPosition,trackObj.getPosition())
spawnHazardToken(targetPosition,gpm.startTransform.rot,entry.imageUrl,globalParameterName,entry.value,entry.type)
else
local localTargetTransform=computeTransformOnCircle(gpm.startTransform,gpm.finalTransform,
globalParameterSteps,entry.value,gpm.bonusMarkerOffset)
local rotatedTransform=rotateTransformAroundY(localTargetTransform,trackObj.getRotation()[1] - 180,gpm.trackRotation[2])
local targetPosition=vectorHelpers.addVectors(vectorHelpers.scaleVectorByVector(rotatedTransform.pos,trackObj.getScale()),trackObj.getPosition())
local targetRotation=rotatedTransform.rot
spawnHazardToken(targetPosition,targetRotation,entry.imageUrl,globalParameterName,entry.value,entry.type)
end
end
end
globalParameterSystem.spawnBonusMarkers=function(globalParameterMetadata,globalParameterSteps,bonusMap)
local baseBonusMarker=gameObjectHelpers.getObjectByName("baseBonusTokenGuid")
local trackObj=getObjectFromGUID(globalParameterMetadata.objectGuid)
local gpm=globalParameterMetadata
for _,entry in pairs(bonusMap) do
if globalParameterMetadata.startTransform.rot[2]==globalParameterMetadata.finalTransform.rot[2] then
local localTargetPosition=computeInterpolatedPosition(globalParameterSteps,entry.value,
gpm.startTransform.pos,gpm.startTransform.rot,
gpm.endTransform.pos,gpm.endTransform.rot,
globalParameterMetadata.bonusMarkerOffset,trackObj.getScale())
local targetPosition=vectorHelpers.addVectors(localTargetPosition,trackObj.getPosition())
spawnGlobalParameterToken(targetPosition,gpm.startTransform.rot,entry.imageUrl,entry.type)
else
local localTargetTransform=computeTransformOnCircle(gpm.startTransform,gpm.finalTransform,
globalParameterSteps,entry.value,globalParameterMetadata.bonusMarkerOffset)
local rotatedTransform=rotateTransformAroundY(localTargetTransform,trackObj.getRotation()[1] - 180,gpm.trackRotation[2])
local targetPosition=vectorHelpers.addVectors(vectorHelpers.scaleVectorByVector(rotatedTransform.pos,trackObj.getScale()),trackObj.getPosition())
local targetRotation=rotatedTransform.rot
spawnGlobalParameterToken(targetPosition,targetRotation,entry.imageUrl,entry.type)
end
end
end
function global_getGlobalParameterCurrentValue(params)
return globalParameterSystem.values[params.parameter].value
end
function rotateTransformAroundY(inputTransform,rotation1Angle,rotation2Angle)
local totalRotationAngle=rotation1Angle
if rotation2Angle~=nil then
totalRotationAngle=totalRotationAngle + rotation2Angle
end
local rotation=vectorHelpers.addVectors(inputTransform.rot,{0,totalRotationAngle,0})
local rotatedPositon=vectorHelpers.rotateVectorY(inputTransform.pos,totalRotationAngle)
return {pos=rotatedPositon,rot=rotation}
end
function spawnGlobalParameterToken(targetPositionIn,targetRotationIn,imageUrl)
local targetPosition=targetPositionIn
local targetRotation=vectorHelpers.truncateVectorEntries(targetRotationIn,0)
local targetScale=gameObjectHelpers.getObjectByName("baseBonusTokenGuid").getScale()
local cloneCallback=function(clonedGuid)
local clonedTile=getObjectFromGUID(clonedGuid)
clonedTile.setLock(false)
clonedTile.interactable=false
clonedTile.setCustomObject({image=imageUrl})
local reloadedTile=clonedTile.reload()
Wait.time(function()
local twiceReloadedTile=reloadedTile.reload()
Wait.time(function()
twiceReloadedTile.setLock(true)
twiceReloadedTile.setScale(targetScale)
end,2)
end,1)
end
fastCreateClonableObject(gameObjectHelpers.getGuidByName("baseBonusTokenGuid"),targetPosition,targetRotation,cloneCallback)
end
function spawnHazardToken(targetPositionIn,targetRotationIn,imageUrl,globalParameterName,value,type)
local targetPosition=targetPositionIn
local targetRotation=vectorHelpers.truncateVectorEntries(targetRotationIn,0)
local targetScale=gameObjectHelpers.getObjectByName("baseBonusTokenGuid").getScale()
local cloneCallback=function(clonedGuid)
local clonedTile=getObjectFromGUID(clonedGuid)
clonedTile.setLock(false)
clonedTile.interactable=false
clonedTile.setCustomObject({image=imageUrl})
Wait.time(function()
local reloadedTile=clonedTile.reload()
Wait.time(function()
reloadedTile.setLock(true)
reloadedTile.setScale(targetScale)
if type~=nil then
reloadedTile.call("setType",{bonusType=type})
end
table.insert(gameState.aresData.markers,{globalParameterName=globalParameterName,value=value,markerGuid=reloadedTile.getGUID()})
end,1)
end,2)
end
fastCreateClonableObject(gameObjectHelpers.getGuidByName("baseBonusTokenGuid"),targetPosition,targetRotation,cloneCallback)
end
function computeTransformOnCircle(startTransform,endTransform,steps,value,offset)
if offset==nil then
offset={0,0,0}
end
for i,stepValue in pairs(steps) do
if stepValue==value then
local r=computeRadius(startTransform,endTransform)
local mPoint=computeMiddlePoint(startTransform,endTransform,r)
local angleStepInDegrees=(endTransform.rot[2] - startTransform.rot[2])/(#steps-1)
local targetRot={0,startTransform.rot[2] + (i - 1) * angleStepInDegrees,0}
local sinAngle=math.sin(targetRot[2]*math.pi/180)
local cosAngle=math.cos(targetRot[2]*math.pi/180)
local a=vectorHelpers.vectorMagnitude(offset)
local b=vectorHelpers.scaleVector({sinAngle,0,cosAngle},a)
local rPlusOffset=r + vectorHelpers.vectorMagnitude(b)
local targetPos=vectorHelpers.addVectors(mPoint,vectorHelpers.scaleVector({-sinAngle,0,-cosAngle},rPlusOffset))
return {pos=targetPos,rot=targetRot}
end
end
end
function computeMiddlePoint(startTransform,endTransform,radius)
local p2=endTransform.pos
local sinBeta=math.sin(endTransform.rot[2]*math.pi/180)
local cosBeta=math.cos(endTransform.rot[2]*math.pi/180)
local vec=vectorHelpers.scaleVector({sinBeta,0,cosBeta},radius)
return vectorHelpers.addVectors(vec,p2)
end
function computeRadius(startTransform,endTransform)
local p1=startTransform.pos
local p2=endTransform.pos
local sinAlpha=math.sin(startTransform.rot[2]*math.pi/180)
local cosAlpha=math.cos(startTransform.rot[2]*math.pi/180)
local sinBeta=math.sin(endTransform.rot[2]*math.pi/180)
local cosBeta=math.cos(endTransform.rot[2]*math.pi/180)
local termA=(sinBeta/sinAlpha) + (p2[1] - p1[1])/sinAlpha
return (p2[3]-p1[3])/(termA*cosAlpha - cosBeta)
end


aresFunctions={}
aresFunctions.finishSetup=function()
function finishSetupCoroutine()
if randomizer.isDone~=nil then
while not randomizer.isDone or randomizer.mapGenerationInProgress do
coroutine.yield(0)
end
end
if #gameState.allPlayers < 4 then
aresFunctions.spawnDuststorms(1)
aresFunctions.spawnDuststorms(2)
elseif #gameState.allPlayers==4 then
aresFunctions.spawnDuststorms(2)
else
aresFunctions.spawnDuststorms(1)
end
return 1
end
startLuaCoroutine(self,"finishSetupCoroutine")
end
aresFunctions.spawnErosions=function(numberOfErosions)
transientState.aresData.oppositeCorner=false
transientState.aresData.stepsToWalk=0
if numberOfErosions==1 then
searchForCard({amountToSearchFor=2,callbackInfo={callbackFuncName="spawnErosionsCallback"}})
else
for i=1,numberOfErosions do
searchForCard({amountToSearchFor=1,callbackInfo={callbackFuncName="spawnErosionsCallback"}})
end
end
end
aresFunctions.spawnDuststorms=function(numberOfDuststorms)
transientState.aresData.oppositeCorner=false
transientState.aresData.stepsToWalk=0
if numberOfDuststorms==1 then
searchForCard({amountToSearchFor=2,callbackInfo={callbackFuncName="spawnDuststormsCallback"}})
else
for i=1,numberOfDuststorms do
searchForCard({amountToSearchFor=1,callbackInfo={callbackFuncName="spawnDuststormsCallback"}})
end
end
end
function spawnErosionsCallback(params)
local card=getObjectFromGUID(params.cardGuid)
local searchIsDone=params.searchIsDone
local steps=tonumber(descriptionInterpreter.getValuesFromInput(card.getDescription(),"Cost:")[1])
spawnAresTiles(steps,"erosionBag",searchIsDone)
end
function spawnDuststormsCallback(params)
local card=getObjectFromGUID(params.cardGuid)
local searchIsDone=params.searchIsDone
local steps=tonumber(descriptionInterpreter.getValuesFromInput(card.getDescription(),"Cost:")[1])
spawnAresTiles(steps,"duststormBag",searchIsDone)
end
function spawnAresTiles(steps,sourceBagName,searchIsDone)
function spawnTileCoroutine()
while transientState.spawningTile do
coroutine.yield(0)
end
transientState.spawningTile=true
transientState.aresData.stepsToWalk=transientState.aresData.stepsToWalk + steps
if searchIsDone then
local startingIndices={0,0,0}
local direction=1
if transientState.aresData.oppositeCorner==true then
local i=0
local j=#gameMap.tiles[0]
local k=0
startingIndices={i,j,k}
direction=-1
end
local targetIndices=hexMapHelpers.walkMapHorizontally(
gameMap,
transientState.aresData.stepsToWalk - 1,
direction,
startingIndices,
{mapFeatures.tileType.ocean,mapFeatures.tileType.nocticsCity},
{}
)
local duststormSource=gameObjectHelpers.getObjectByName(sourceBagName)
local duststorm=duststormSource.takeObject({
position=hexMapHelpers.indicesToWorldCoordinates(gameMap,targetIndices,marsMapTile),
rotation={0,270,0}
})
local waitFrames=0
while waitFrames < 30 do
if duststorm.resting then
waitFrames=waitFrames + 1
else
waitFrames=0
end
coroutine.yield(0)
end
duststorm.call("activateObjectRemotely",{playerColor=nil})
for i=1,20 do
coroutine.yield(0)
end
transientState.aresData.stepsToWalk=0
transientState.aresData.oppositeCorner=not transientState.aresData.oppositeCorner
end
transientState.spawningTile=false
return 1
end
startLuaCoroutine(self,"spawnTileCoroutine")
end
aresFunctions.removeAllDuststorms=function()
local waitCounter=0
for i,jkMatrix in pairs(gameMap.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
if tile.tileObjects~=nil then
for _,tileObject in pairs(tile.tileObjects) do
if tileObject.objectName=="Duststorm" then
local obj=getObjectFromGUID(tileObject.guid)
if not obj.getVar("objectState").indestructible then
Wait.frames(|| obj.call("deactivateObjectRemotely",{playerColor=nil}),15 + 30 * waitCounter)
waitCounter=waitCounter + 1
end
end
end
end
end
end
end
end
aresFunctions.flipErosions=function()
gameState.aresData.erosionTilesFlipped=not gameState.aresData.erosionTilesFlipped
flipAresTiles("Erosion")
end
aresFunctions.flipDuststorms=function()
gameState.aresData.duststormTilesFlipped=not gameState.aresData.duststormTilesFlipped
flipAresTiles("Duststorm")
end
aresFunctions.generateProductionMalusMetadata=function(playerColor,effectStrength)
local tmPlayer=getPlayerByColor(playerColor)
if effectStrength > 0 then
effectStrength=-effectStrength
end
local metadata={}
metadata.tokenTitle="Production malus ("..effectStrength.."). Has to be dropped on a production counter you own."
metadata.owner=playerColor
metadata.tokenContext={tokenType=programableActionTokenData.types.aresProductionMalus,malus=effectStrength}
return metadata
end
function flipAresTiles(tileName)
for i,jkMatrix in pairs(gameMap.tiles) do
for j,kMatrix in pairs(jkMatrix) do
for k,tile in pairs(kMatrix) do
if tile.tileObjects~=nil then
for _,tileObject in pairs(tile.tileObjects) do
if tileObject.objectName==tileName then
local obj=getObjectFromGUID(tileObject.guid)
obj.setPosition(vectorHelpers.addVectors(obj.getPosition(),{0,0.2,0}))
obj.setLock(false)
obj.flip()
Wait.frames(function() Wait.condition(function() obj.setLock(true) end,function() return obj.resting end) end,15)
tileObject.adjacenyEffects={effects={"BigProductionMalus"}}
end
end
end
end
end
end
end
function moveAresHazardMarker(params)
local direction=params.direction
local hazardMarkerGuid=params.hazardMarkerGuid
local markerObj=getObjectFromGUID(hazardMarkerGuid)
for _,info in pairs(gameState.aresData.markers) do
if info.markerGuid==hazardMarkerGuid then
local metadata=globalParameters[info.globalParameterName]
local globalParameterSteps=metadata.mappings[globalParameterSystem.values[info.globalParameterName].selection].steps
local value=0
for index,entry in pairs(metadata.ares.Default) do
if entry.value==info.value then
local delta=0
for i,stepValue in pairs(globalParameterSteps) do
if stepValue==entry.value then
delta=globalParameterSteps[i+direction] - globalParameterSteps[i]
end
end
metadata.ares.Default[index].value=metadata.ares.Default[index].value + delta
local trackObj=getObjectFromGUID(metadata.objectGuid)
local localTargetTransform=computeTransformOnCircle(metadata.startTransform,metadata.finalTransform,
globalParameterSteps,entry.value,metadata.bonusMarkerOffset)
local rotatedTransform=rotateTransformAroundY(localTargetTransform,trackObj.getRotation()[1] - 180,metadata.trackRotation[2])
local targetPosition=vectorHelpers.addVectors(vectorHelpers.scaleVectorByVector(rotatedTransform.pos,trackObj.getScale()),trackObj.getPosition())
local targetRotation=rotatedTransform.rot
markerObj.setLock(false)
markerObj.setPosition(targetPosition)
markerObj.setRotation(targetRotation)
Wait.time(|| markerObj.setLock(true),3)
return
end
end
end
end
end


terraformingParametersMap={}
terraformingParametersMap["Ocean"]="Ocean"
terraformingParametersMap["Oceans"]="Ocean"
terraformingParametersMap["Temp"]="Temp"
terraformingParametersMap["Temperature"]="Temp"
terraformingParametersMap["O2"]="O2"
terraformingParametersMap["Oxygen"]="O2"
terraformingParametersMap["TFVenus"]="TFVenus"
requirementType={
globalParameter="globalParameter",
tags="tags",
delegate="delegate",
partyLeader="partyLeader",
chairman="chairman",
infrastructure="infrastructure",
party="party",
terraformingRating="terraformingRating",
production="production",
ownedObjectsInPlay="ownedObjectsInPlay",
}
requirementTarget={
any="any",
own="own",
other="other",
otherSingle="otherSingle",
neutral="neutral",
}
requirementTargetMap={}
requirementTargetMap["Any"]=requirementTarget.any
requirementTargetMap["any"]=requirementTarget.any
requirementTargetMap["Own"]=requirementTarget.own
requirementTargetMap["own"]=requirementTarget.own
requirementTargetMap["Other"]=requirementTarget.other
requirementTargetMap["other"]=requirementTarget.other
requirementTargetMap["OtherSingle"]=requirementTarget.otherSingle
requirementTargetMap["otherSingle"]=requirementTarget.otherSingle
requirementTargetMap["Neutral"]=requirementTarget.neutral
requirementTargetMap["neutral"]=requirementTarget.neutral
rawRequirementInterpreter={}
rawRequirementInterpreter.extras={wildCardTagsAvailable=0}
rawRequirementInterpreter.resetExtrasForPlayer=function(tmPlayer)
rawRequirementInterpreter.extras={wildCardTagsAvailable=getPlayerTags({tagName="WildCard",playerColor=tmPlayer.color})}
end
rawRequirementInterpreter.evaluateRequirement=function(tmPlayer,key,value)
local requirement=translateRawRequirement(key,value)
if requirement==nil then
logging.printToAll("Unknown requirement found - ignoring",{1,0.25,0},{1,0,0},loggingModes.exception)
return true
end
local checkValue=getRequirementCheckAgainstValue(tmPlayer,requirement)
local result=isRequirementFulfilled(tmPlayer,requirement,checkValue)
return result
end
function getSpecificPlayerPropertiesRemotely(params)
local requirement=translateRawRequirement(params.formula,0)
local tmPlayer=getPlayerByColor(params.playerColor)
return getRequirementCheckAgainstValue(tmPlayer,requirement)
end
function translateRawRequirement(rawKey,rawValue)
local target=nil
local isMax=false
local cleanedUpKey=rawKey
if string.find(cleanedUpKey,"Max") then
isMax=true
cleanedUpKey=cleanedUpKey:gsub("Max","")
end
for reqTargetString,translatedTarget in pairs(requirementTargetMap) do
if string.find(cleanedUpKey,reqTargetString) then
target=translatedTarget
cleanedUpKey=cleanedUpKey:gsub(reqTargetString,"")
end
end
if target==nil then
target=requirementTarget.any
end
for _,func in pairs(requirementTranslationFunctions) do
local requirement=func(cleanedUpKey,rawValue)
if requirement~=nil then
requirement.isMax=isMax
requirement.target=target
return requirement
end
end
return nil
end
function getRequirementCheckAgainstValue(tmPlayer,requirement)
for _,func in pairs(getCheckAgainstValueFunctions) do
local checkValue=func(tmPlayer,requirement)
if checkValue~=nil then
return checkValue
end
end
end
function isRequirementFulfilled(tmPlayer,requirement,relevantValue)
local reqModifiers=tmPlayer.reqModifiers
local permanentModifier=reqModifiers.permanent[requirement.key]
local transientModifier=reqModifiers.transient[requirement.key]
local totalModifier=0
if permanentModifier~=nil then
totalModifier=totalModifier + permanentModifier
end
if transientModifier~=nil then
totalModifier=totalModifier + transientModifier
end
if requirement.type~=requirementType.tags then
if requirement.isMax then
return relevantValue <= requirement.value + totalModifier
else
return relevantValue >= requirement.value - totalModifier
end
else
if requirement.isMax then
return relevantValue <= requirement.value + totalModifier
else
local targetValue=requirement.value - totalModifier
if relevantValue >= targetValue then
return true
elseif relevantValue + rawRequirementInterpreter.extras.wildCardTagsAvailable >= targetValue then
rawRequirementInterpreter.extras.wildCardTagsAvailable=rawRequirementInterpreter.extras.wildCardTagsAvailable - (targetValue - relevantValue)
return true
else
return false
end
end
end
end
requirementTranslationFunctions={}
requirementTranslationFunctions.tryTranslateGlobalParametersRequirement=function(inputKey,rawValue)
for key,translatedKey in pairs(terraformingParametersMap) do
if key==inputKey then
local requirement={}
requirement.key=translatedKey
requirement.type=requirementType.globalParameter
local steps=nil
if inputKey=="O2" then
steps=globalParameters.oxygen.mappings[globalParameterSystem.values.oxygen.selection].steps
elseif inputKey=="Temp" then
steps=globalParameters.temperature.mappings[globalParameterSystem.values.temperature.selection].steps
elseif inputKey=="TFVenus" then
steps=globalParameters.venus.mappings[globalParameterSystem.values.venus.selection].steps
elseif string.lower(inputKey)=="oceans" or string.lower(inputKey)=="ocean" then
steps=globalParameters.ocean.mappings[globalParameterSystem.values.ocean.selection].steps
end
for stepIndex,entry in pairs(steps) do
if rawValue==entry then
requirement.value=stepIndex
end
end
if requirement.value==nil then
requirement.value=tableHelpers.findNearestMatch(steps,rawValue).index
end
return requirement
end
end
end
requirementTranslationFunctions.tryTranslateTagsRequirement=function(inputKey,rawValue)
for _,tagCollection in pairs(icons) do
for _,tag in ipairs(tagCollection) do
if inputKey==tag then
local requirement={}
requirement.value=rawValue
requirement.type=requirementType.tags
requirement.key=tag
return requirement
end
end
end
end
requirementTranslationFunctions.tryTranslateDelegateRequirement=function(inputKey,rawValue)
if inputKey=="delegate" or inputKey=="Delegate" then
local requirement={}
requirement.value=rawValue
requirement.type=requirementType.delegate
requirement.key="delegate"
return requirement
end
end
requirementTranslationFunctions.tryTranslatePartyLeaderRequirement=function(inputKey,rawValue)
if inputKey=="partyLeader" or inputKey=="PartyLeader" then
local requirement={}
requirement.value=rawValue
requirement.type=requirementType.partyLeader
requirement.key="partyLeader"
return requirement
end
end
requirementTranslationFunctions.tryTranslateChairmanRequirement=function(inputKey,rawValue)
if inputKey=="chairman" or inputKey=="Chairman" then
local requirement={}
requirement.value=rawValue
requirement.type=requirementType.chairman
requirement.key="chairman"
return requirement
end
end
requirementTranslationFunctions.tryTranslateInfrastructureRequirement=function(inputKey,rawValue)
if inputKey=="infrastructure" or inputKey=="Infrastructure" or inputKey=="SpaceBiggerThanInfrastructure" then
local requirement={}
requirement.value=1
requirement.type=requirementType.infrastructure
requirement.key="infrastructure"
return requirement
end
end
requirementTranslationFunctions.tryTranslatePartyRequirement=function(inputKey,rawValue)
for partyId,partyName in pairs(marsSenate.parties) do
local requirement={}
if partyName==inputKey then
if rawValue~=nil then
requirement.value=rawValue
else
requirement.value=2
end
requirement.type=requirementType.party
requirement.key=partyName
return requirement
end
end
end
requirementTranslationFunctions.tryTranslateTagComparsionRequirement=function(inputKey,rawValue)
for _,tagCollection in pairs(icons) do
for _,tag in ipairs(tagCollection) do
if inputKey==tag then
local requirement={}
requirement.value=rawValue
requirement.type=requirementType.tags
requirement.key=tag
return requirement
end
end
end
end
requirementTranslationFunctions.tryTranslateTerraformingRatingRequirement=function(inputKey,rawValue)
if inputKey=="TR" or inputKey=="tr" then
local requirement={}
requirement.value=rawValue
requirement.type=requirementType.terraformingRating
requirement.key="tr"
return requirement
end
end
requirementTranslationFunctions.tryTranslateProductionRequirement=function(inputKey,rawValue)
for _,productionType in ipairs(resources.baseGame) do
if string.lower(inputKey)==productionType then
local requirement={}
requirement.value=rawValue
requirement.type=requirementType.production
requirement.key=productionType
return requirement
end
end
end
requirementTranslationFunctions.tryTranslateOwnedObjectsRequirement=function(inputKey,rawValue)
for _,expansion in pairs(ownableObjects) do
if expansion.friendlyNameMapping~=nil then
for objectId,objectFriendlyNames in pairs(expansion.friendlyNameMapping) do
for _,name in ipairs(objectFriendlyNames) do
if name==inputKey then
local requirement={}
requirement.value=rawValue
requirement.type=requirementType.ownedObjectsInPlay
requirement.key=objectId
return requirement
end
end
end
end
end
end
getCheckAgainstValueFunctions={}
getCheckAgainstValueFunctions.getGlobalParameterValue=function(tmPlayer,requirement)
if requirement.type==requirementType.globalParameter then
if requirement.key=="TFVenus" then
return globalParameterSystem.values.venus.stepIndex
elseif requirement.key=="O2" then
return globalParameterSystem.values.oxygen.stepIndex
elseif requirement.key=="Temp" then
return globalParameterSystem.values.temperature.stepIndex
elseif requirement.key=="Ocean" then
return globalParameterSystem.values.ocean.stepIndex + globalParameterSystem.values.ocean.extra
end
end
end
getCheckAgainstValueFunctions.getTagCounts=function(tmPlayer,requirement)
if requirement.type==requirementType.tags then
if requirement.target==requirementTarget.own then
return getPlayerTags({tagName=requirement.key,playerColor=tmPlayer.color})
elseif requirement.target==requirementTarget.other then
return getAllOtherPlayersTags({tagName=requirement.key,playerColor=tmPlayer.color})
else
local tagCount=getPlayerTags({tagName=requirement.key,playerColor=tmPlayer.color})
return tagCount + getAllOtherPlayersTags({tagName=requirement.key,playerColor=tmPlayer.color})
end
end
end
getCheckAgainstValueFunctions.getTerraformingCount=function(tmPlayer,requirement)
if requirement.type==requirementType.terraformingRating then
local result=0
for i,player in ipairs(gameState.allPlayers) do
if requirement.target==requirementTarget.own then
result=tmPlayer.terraformingRating
elseif requirement.target==requirementTarget.other then
if player~=tmPlayer then
result=result + player.terraformingRating
end
elseif requirement.target==requirementTarget.otherSingle then
if player~=tmPlayer and player.terraformingRating > result then
result=player.terraformingRating
end
elseif requirement.target==requirementTarget.any then
result=result + player.terraformingRating
end
end
return result
end
end
getCheckAgainstValueFunctions.getActiveDelegates=function(tmPlayer,requirement)
if requirement.type==requirementType.delegate then
return 999
elseif requirement.type==requirementType.partyLeader then
local partyLeaderCount=0
for _,info in pairs(gameState.turmoilData.parties) do
if requirement.target=="own" and getPartyLeadColor(info)==tmPlayer.color then
partyLeaderCount=partyLeaderCount + 1
end
end
return partyLeaderCount
elseif requirement.type==requirementType.chairman then
local chairmanColor=getChairman().getDescription()
if requirement.target=="neutral" and chairmanColor=="Neutral" then
return 1
elseif requirement.target=="own" and tmPlayer.color==chairmanColor then
return 1
end
return 0
end
end
getCheckAgainstValueFunctions.getSpaceAgainstInfrastructureValue=function(tmPlayer,requirement)
if requirement.type==requirementType.infrastructure then
local spaceTags=getPlayerTags({tagName="Space",playerColor=tmPlayer.color})
spaceTags=spaceTags + getPlayerTags({tagName="WildCard",playerColor=tmPlayer.color})
local infrastructureTags=getPlayerTags({tagName="Infrastructure",playerColor=tmPlayer.color})
if spaceTags > infrastructureTags then
return 1
else
return 0
end
end
end
getCheckAgainstValueFunctions.getPoliticalPartyInfluence=function(tmPlayer,requirement)
if requirement.type==requirementType.party then
if requirement.key==getRulingParty().partyId then
return 999
else
return playersPartyDelegateCount(tmPlayer.color,requirement.key)
end
end
end
getCheckAgainstValueFunctions.getProductionValue=function(tmPlayer,requirement)
if requirement.type==requirementType.production then
local productionValue=0
for i,player in ipairs(gameState.allPlayers) do
if requirement.target==requirementTarget.own then
productionValue=Global.call("getPlayerProduction",{resourceType=requirement.key,playerColor=tmPlayer.color})
elseif requirement.target==requirementTarget.other then
if player~=tmPlayer then
productionValue=productionValue + Global.call("getPlayerProduction",{resourceType=requirement.key,playerColor=player.color})
end
elseif requirement.target==requirementTarget.otherSingle then
if player~=tmPlayer and player.ownedObjects[requirement.key] > productionValue then
productionValue=productionValue + Global.call("getPlayerProduction",{resourceType=requirement.key,playerColor=player.color})
end
elseif requirement.target==requirementTarget.any then
productionValue=productionValue + Global.call("getPlayerProduction",{resourceType=requirement.key,playerColor=player.color})
end
end
return productionValue
end
end
getCheckAgainstValueFunctions.getPlayerOwnedObjectsInPlay=function(tmPlayer,requirement)
if requirement.type==requirementType.ownedObjectsInPlay then
local objectsCount=0
for i,player in ipairs(gameState.allPlayers) do
if requirement.target==requirementTarget.own then
objectsCount=tmPlayer.ownedObjects[requirement.key]
elseif requirement.target==requirementTarget.other then
if player~=tmPlayer then
objectsCount=objectsCount + player.ownedObjects[requirement.key]
end
elseif requirement.target==requirementTarget.otherSingle then
if player~=tmPlayer and player.ownedObjects[requirement.key] > objectsCount then
objectsCount=player.ownedObjects[requirement.key]
end
elseif requirement.target==requirementTarget.any then
objectsCount=objectsCount + player.ownedObjects[requirement.key]
end
end
return objectsCount
end
end


gameEventHandling={
eventHandlers={},
latestEventSourceGuid="",
latestEventMetadata=nil,
wasUpdated=true,
eventInProgress=false,
}
function eventHandling_triggerEvent(params)
local triggeredByColor=params.triggeredByColor
local triggerType=params.triggerType
local eventSourceId=params.eventSourceId
local metadata=params.metadata
if metadata==nil then
metadata={}
end
if metadata.triggeredByColor==nil and triggeredByColor~=nil then
metadata.triggeredByColor=triggeredByColor
end
if metadata.eventSourceId==nil then
metadata.eventSourceId=eventSourceId
end
eventHandling.handleEvent(triggeredByColor,triggerType,eventSourceId,metadata)
end
function eventHandling_subscribeHandler(params)
eventHandling.subscribeHandler(params.eventHandler,params.owner)
eventHandling.wasUpdated=true
end
function eventHandling_unsubscribeHandler(params)
eventHandling.unsubscribeHandler(params.eventHandler)
eventHandling.wasUpdated=true
end
eventHandling={}
eventHandling.handleEvent=function(triggeredByColor,triggerType,eventSourceId,metadata)
gameEventHandling.eventInProgress=true
if gameEventHandling.eventHandlers[triggerType]==nil then
gameEventHandling.eventHandlers[triggerType]={}
end
for id,eventHandler in pairs(gameEventHandling.eventHandlers[triggerType]) do
eventHandling.processEventForHandler(eventHandler,triggeredByColor,triggerType,metadata)
end
gameEventHandling.eventInProgress=false
end
eventHandling.subscribeHandler=function(eventHandler,owner)
local triggerType=eventHandler.triggerType
if gameEventHandling.eventHandlers[triggerType]==nil then
gameEventHandling.eventHandlers[triggerType]={}
end
eventHandler.owner=owner
table.insert(gameEventHandling.eventHandlers[triggerType],eventHandler)
gameEventHandling.wasUpdated=true
end
eventHandling.unsubscribeHandler=function(unsubscriber)
Wait.condition(function()
local triggerType=unsubscriber.triggerType
local indicesToRemove={}
for index,eventHandler in pairs(gameEventHandling.eventHandlers[triggerType]) do
if eventHandler.eventHandlerId==unsubscriber.eventHandlerId then
table.insert(indicesToRemove,index)
end
end
for i=#indicesToRemove,1,-1 do
table.remove(gameEventHandling.eventHandlers[triggerType],indicesToRemove[i])
end
gameEventHandling.wasUpdated=true
end,
function()
return not gameEventHandling.eventInProgress
end)
end
eventHandling.processEventForHandler=function(eventHandler,triggeredByColor,triggerType,metadata)
if eventHandler.triggerType~=triggerType then
return
elseif eventHandler.triggerScope==eventData.triggerScope.noPlayer and triggeredByColor~=nil then
return
elseif eventHandler.triggerScope==eventData.triggerScope.playerThemself and triggeredByColor~=eventHandler.owner then
return
elseif eventHandler.triggerScope==eventData.triggerScope.otherPlayers and triggeredByColor==eventHandler.owner then
return
end
if not isSupportedPhase(gameState.currentPhase,eventHandler.allowedPhases) then
return
end
if string.find(eventHandler.eventHandlerId,"globalEventHandler") then
Global.call(eventHandler.callbackName,metadata.triggeredByColor)
elseif eventHandler.eventHandlerId~=nil then
local eventListener=getObjectFromGUID(eventHandler.eventHandlerId)
if eventListener~=nil then
eventListener.call(eventHandler.callbackName,
{actionIndex=eventHandler.actionIndex,
playerColor=eventHandler.owner,
metadata=metadata} )
elseif eventHandler.owner~=nil then
logging.broadcastToColor("Warning: Object '"..eventHandler.objectPrettyName.."' (GUID "..eventHandler.eventHandlerId..") which listens for events is not available and cannot be triggered. Event system does not work with cards that are in a stack.",eventHandler.owner,eventHandler.owner,loggingModes.essential)
end
end
end
function isSupportedPhase(currentPhase,allowedPhases)
local isSupported=false
for _,allowedPhase in pairs(allowedPhases) do
if allowedPhase==currentPhase then
isSupported=true
end
end
return isSupported
end


function onLoad(saved_data)
local loaded_data
if saved_data~="" and saved_data~=nil then
loaded_data=JSON.decode(saved_data)
if loaded_data.scriptVersion~=scriptVersion then
saved_data=nil
end
end
if saved_data~="" and saved_data~=nil then
print("Loading data!")
loaded_data=JSON.decode(saved_data)
gameState=loaded_data.gameState
gameMap=hexMapHelpers.makeMapComputeFriendly(loaded_data.map)
if loaded_data.venusMap~=nil then
venusMap=hexMapHelpers.makeMapComputeFriendly(loaded_data.venusMap)
end
gameEventHandling=loaded_data.gameEventHandling
globalParameterSystem.values=loaded_data.globalParameters
logging.currentMode=loaded_data.loggingMode
gameConfig=loaded_data.gameConfig
bagProtectorAllowedList=loaded_data.bagProtectorAllowedList
bagProtectorGuidStores.generalStore=loaded_data.bagProtectorGeneralStore
if not loaded_data.gameState.started then
broadcastToAll("You have loaded a non started game. This is not officially supported. Get the save game from discord and launch from that. It might still work.")
end
end
tablePositions.update()
board.update()
Wait.time(function()
createOrUpdatePlayerColors()
updatePlayerUI()
end,1)
math.randomseed( os.time() )
if gameState.started~=true then
createAllSetupButtons()
milestoneSystem.initialize()
awardSystem.initialize()
else
setupMapButtons()
setupStandardProjectMat()
globalParameterSystem.setupButtons()
setupBoard()
end
if gameState.activeExpansions.timer then
timerFunctions.initializeTimer()
end
readGameConfigOnGameLoad()
makeObjectsUninteractable()
end
function onSave()
local serializableMap=hexMapHelpers.makeMapSerializable(gameMap)
local data_to_save=nil
if venusMap~=nil then
local serializableVenusMap=hexMapHelpers.makeMapSerializable(venusMap)
data_to_save={scriptVersion=scriptVersion,gameEventHandling=gameEventHandling,gameState=gameState,bagProtectorAllowedList=bagProtectorAllowedList,bagProtectorGeneralStore=bagProtectorGuidStores.generalStore,map=serializableMap,loggingMode=logging.currentMode,globalParameters=globalParameterSystem.values,venusMap=serializableVenusMap,gameConfig=gameConfig}
else
data_to_save={scriptVersion=scriptVersion,gameEventHandling=gameEventHandling,gameState=gameState,bagProtectorAllowedList=bagProtectorAllowedList,bagProtectorGeneralStore=bagProtectorGuidStores.generalStore,map=serializableMap,loggingMode=logging.currentMode,globalParameters=globalParameterSystem.values,gameConfig=gameConfig}
end
return JSON.encode(data_to_save)
end
--   function discardLoopCoroutine()
--       end
--
--           playerColor="White",
--     return 1
function filterObjectEnterContainer(container,enter_object)
local containerGuid=container.getGUID()
local enterObjectGuid=enter_object.getGUID()
local isOcean=gameObjectHelpers.isOcean(enterObjectGuid)
local bagProtectorResult= bagProtector.filterObjectEnter(container,enter_object)
if bagProtectorResult~=nil then
return bagProtectorResult
end
local isCity=gameObjectHelpers.isCity(enterObjectGuid)
if containerGuid==gameObjectHelpers.getGuidByName("specialsBag") and (enterObjectGuid==gameObjectHelpers.getGuidByName("capitalCityToken") or enterObjectGuid==gameObjectHelpers.getGuidByName("oceanCityToken") or enterObjectGuid==gameObjectHelpers.getGuidByName("redCity")) then
return true
end
if containerGuid~=gameObjectHelpers.getGuidByName("genericCityBag") and isCity then
logging.printToAll("Cities only belong on the board or in the city bag",{1,1,1},loggingModes.essential)
return false
end
local isGreenery=gameObjectHelpers.isGreenery(enter_object)
if containerGuid~=gameObjectHelpers.getGuidByName("genericGreeneryBag") and isGreenery then
logging.printToAll("Greenerys only belong on the board or in the city bag",{1,1,1},loggingModes.essential)
return false
end
log("Enter container allowed!")
return true
end
objectsOfInterest={}
objectsEnteredContainer={}
function onObjectEnterContainer(container,enter_object)
local enterGuid=enter_object.getGUID()
if objectsOfInterest[enterGuid]~=nil then
objectsOfInterest[enterGuid]=nil
onContainerDeath(container,enter_object)
else
objectsEnteredContainer[enterGuid]=container
end
end
function onObjectDestroy(dying_object)
if dying_object==nil then
return
end
local dyingGuid=dying_object.getGUID()
if objectsEnteredContainer[dyingGuid]~=nil then
objectsEnteredContainer[dyingGuid]=nil
onContainerDeath(container,dying_object)
else
local objectOfInterestStructure={
timeOfDeath=Time.time
}
Wait.frames(function()
if objectsOfInterest~=nil then
objectsOfInterest[dyingGuid]=objectOfInterestStructure
Wait.time(checkObjectRealDeath,0.1)
end
end,1)
end
end
function checkObjectRealDeath()
for guid,objectStructure in pairs(objectsOfInterest) do
if (Time.time - objectStructure.timeOfDeath) > 0.05 then
objectsOfInterest[guid]=nil
onRealDeath(guid)
end
end
end
function onContainerDeath(container,dying_object)
local dyingGuid=dying_object.getGUID()
if gameObjectHelpers.isOcean(dyingGuid) then
gameObjectHelpers.oceanStashed()
elseif gameObjectHelpers.isCity(dyingGuid) then
gameObjectHelpers.cityDestroyed(dyingGuid)
elseif gameObjectHelpers.isGreenery(dyingGuid) then
gameObjectHelpers.greeneryDestroyed(dyingGuid)
end
end
function onRealDeath(dyingGuid)
if gameObjectHelpers.isOcean(dyingGuid) then
gameObjectHelpers.oceanDestroyed(dyingGuid)
logging.printToAll("Making sure no oceans are lost!",{1,1,1},loggingModes.unimportant)
ensureBagOceans()
end
end
function onObjectLeaveContainer(container,leave_object)
function handleObjectDelayed()
for i=1,10 do
coroutine.yield(0)
end
local containerId=container.getGUID()
local objectId=leave_object.getGUID()
if leave_object==nil then
return 1
elseif containerId==gameObjectHelpers.getGuidByName("specialsBag") then
updateCityCounters()
elseif gameObjectHelpers.isOcean(objectId) then
gameObjectHelpers.oceanRetrieved()
elseif leave_object.name=='Card' then
handleCardLeavingContainer(containerId,leave_object)
end
bagProtector.objectLeaveContainer(container,leave_object)
return 1
end
startLuaCoroutine(self,"handleObjectDelayed")
end
function handleCardLeavingContainer(containerId,leave_object)
if gameObjectHelpers.getGuidByName("turmoilDeck")==containerId then
return
end
if gameObjectHelpers.getGuidByName("corpDeck")==containerId then
leave_object.setDescription(":Corporation:\n"..leave_object.getDescription())
elseif gameObjectHelpers.getGuidByName("preludeDeck")==containerId then
leave_object.setDescription(":Prelude:\n"..leave_object.getDescription())
end
if leave_object.getLuaScript()==nil or leave_object.getLuaScript()=='' then
local baseCardScript=getCardSpecificLuaScript(leave_object)
leave_object.setLuaScript(baseCardScript)
end
end
function getCardSpecificLuaScript(card)
local cardName=card.getName()
if string.match(cardName,"%(B%)") then
return getObjectFromGUID(gameObjectHelpers.getGuidByName("baseBlueCard")).getLuaScript()
elseif string.match(cardName,"%(E%)") then
return getObjectFromGUID(gameObjectHelpers.getGuidByName("baseEventCard")).getLuaScript()
elseif string.match(cardName,"%(G%)") then
return getObjectFromGUID(gameObjectHelpers.getGuidByName("baseGreenCard")).getLuaScript()
elseif string.match(cardName,"%(HO%)") then
return getObjectFromGUID(gameObjectHelpers.getGuidByName("baseInfrastructureCard")).getLuaScript()
elseif string.match(cardName,"%(C%)") then
return getObjectFromGUID(gameObjectHelpers.getGuidByName("baseCorporationCard")).getLuaScript()
else
return getObjectFromGUID(gameObjectHelpers.getGuidByName("baseCard")).getLuaScript()
end
end
function onPlayerChangeColor(player_color)
Wait.frames(function()
if gameState==nil then
return
end
if gameState.started~=true then
createOrUpdatePlayerColors()
end
updatePlayerUI()
end,1)
end


doubleClickTable={}
function isDoubleClick(identifier)
identifier=identifier or "generic"
function catchDoubleClicksCoroutine()
for i=1,60 do
coroutine.yield(0)
end
doubleClickTable[identifier]=false
return 1
end
if doubleClickTable[identifier]==true then
log("Catched a double click for "..identifier)
return true
end
startLuaCoroutine(self,"catchDoubleClicksCoroutine")
doubleClickTable[identifier]=true
return false
end

gigaMap=false
volatileData={operations={}}


randomizer={
latestMilestones={},
latestAwards={},
}
--     milestoneSystem.setupMilestones
--   local lastName=params.currentName
--
--
--       end
--     milestoneSystem.changeMilestone(params.guid,milestoneInfo)
--
--       end
-- function randomizeAwardsAndMilestones(_,playerColor,altClick)
--
--   end
--
--   end
function initializeRandomizerAwardsAndMilestones()
for i,guid in pairs(gameState.milestoneGuids) do
getObjectFromGUID(guid).call("enableChangeButton")
end
for i,guid in pairs(gameState.awardGuids) do
getObjectFromGUID(guid).call("enableChangeButton")
end
end

--
--
--   button.setPositionSmooth({-48.85,1.5,0.00})
--
--     function_owner=self,
--     height=250,
--
--     function_owner=self,
--     height=250,
--
--     function_owner=self,
--     height=250,
--
--     tooltip='Number of randomizer expansion tiles that shall spawn.',
--     height=250,
-- end
--
--       table.remove(t,i)
-- function changeRandomizerExpansionTilesAmount(object,playerColor,altClick)
--     if randomizer.randomizerExpansionTileCount <= 0 then
--     end
--
--  })
--
--
-- end
--
--   end
--
--   for _,randomizerTemplate in pairs(randomizerTemplates) do
--     end
--
--  
--
--       index=index + 1
--
--
--       waitAtLeastFrames=waitAtLeastFrames - 1
--
--   end
--
--   if getObjectFromGUID(RANDOMIZER_CONTAINER_GUID)==nil then
--
--   if getObjectFromGUID(RANDOMIZER_CONTAINER_GUID)==nil then
--
--   local r=math.random(1,#randomizerTiles.mapOceansPositions)
--
--
--     table.insert(finalIndices,possibleIndices[index])
--
--       return
--
-- function placeSpecialTiles(map)
--
--
--         if next(tile.features)~=nil and tile.features[1]=="empty" then
--     end
--
--     table.insert(specialTilesIndices,validIndices[r])
--
-- end
--
--
--       for k,tile in pairs(kMatrix) do
--       end
--
--     table.insert(tilesIndices,validIndices[r])
--
--       expansionTiles=tableHelpers.deepClone(randomizerTiles.randomizerTileExpansion)
--
-- function placeRegularTiles(map)
--
--         if next(tile.features)~=nil and tile.features[1]=="empty" then
--             poppedTile=popRandomTile(regularTiles)
--
--     end

Wait.time(function() broadcastToAll( "This is a preview verison of the TTS MMGA Terraforming Mars mod.",{1,0,0}) end,2)
Wait.time(function() broadcastToAll( "This version will definitely contain bugs. Feedback welcome and have fun.",{0,1,1}) end,10)
Wait.time(function() broadcastToAll( "Report bugs either in the MMGA bug-reports channel or send a Discord DM to Krymnopht#9952.",{0,1,1}) end,10)
function noOperation(_,_,_)
return
end
--
--
--
-- for _,obj in pairs(getAllObjects()) do
