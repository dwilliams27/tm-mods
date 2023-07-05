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