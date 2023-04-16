cardUxLibrary = {}
cardUxLibrary.addOffset = function(object, v2)
    local v1 = object.position
    object.position = {(v1[1] or v1.x) + (v2[1] or v2.x), (v1[2] or v1.y) + (v2[2] or v2.y),
                       (v1[3] or v1.z) + (v2[3] or v2.z)}
end

scriptVersion = 1
activateButtonColor = {0 / 255, 255 / 255, 130 / 255, 0.75}
activateButtonDefaultPosition = {0, 0.25, 0.12}
spawnedButtons = 0
defaultCardState = {
    active = false,
    isBasicScriptingCard = false,
    inActivatonZone = false,
    owner = nil,
    wasUpdated = true
}
cardProperties = {}
function onload(saved_data)
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        if loaded_data.scriptVersion ~= scriptVersion then
            saved_data = ""
        end
    end
    if saved_data ~= "" then
        local loaded_data = JSON.decode(saved_data)
        cardState = loaded_data.cardState
    else
        cardState = defaultCardState
    end
    if saved_data ~= "" and loadCallback ~= nil then
        loadCallback(true)
    end
    createButtons()
end
function onSave()
    if not cardState.wasUpdated then
        return
    end
    cardState.wasUpdated = false
    saved_data = JSON.encode({
        cardState = cardState,
        scriptVersion = scriptVersion
    })
    return saved_data
end
function createButtons()
    if not cardState.active then
        createActivateButtons()
    end
end
function activateCard(_, playerColor)
    if not Global.call("getExtendedScriptingState") then
        onCardActivated(playerColor)
        return
    end
    if eventHandlers ~= nil then
        cardProperties.eventHandlers = eventHandlers
    end
    Global.call("objectActivationSystem_activateObject", {
        playerColor = playerColor,
        object = self,
        sourceName = self.getName(),
        activationEffects = cardProperties,
        description = self.getDescription()
    })
end
function isProjectCard()
    return Global.call("descriptionInterpreter_isProjectCard", self.getDescription())
end
function hasRequirements()
    return Global.call("descriptionInterpreter_hasRequirements", self.getDescription())
end
function getTags()
    return Global.call("descriptionInterpreter_getValues", {
        description = self.getDescription(),
        pattern = "Tags?:"
    })
end
function getProductionValues()
    return cardProperties.productionValues
end
function getResourceValues()
    return cardProperties.resourceValues
end
function getEffects()
    return cardProperties.effects
end
function onCardActivated(playerColor)
    cardState.active = true
    cardState.owner = playerColor
    if setupBlueCard ~= nil then
        setupBlueCard(playerColor)
    end
    removeButtons()
    createButtons()
    if onCardActivatedExtended ~= nil then
        Wait.frames(function()
            onCardActivatedExtended(playerColor)
        end, 3)
    end
    updateDebugInfos()
    cardState.wasUpdated = true
    self.script_state = onSave()
end
function updateDebugInfos()
    local gameState = Global.call("getGameState")
    if cardState.debug == nil then
        cardState.debug = {}
    end
    cardState.debug.cardActivatedInGeneration = gameState.currentGeneration
    cardState.debug.cardActivatedInPhase = gameState.currentPhase
    cardState.debug.dates = {"cardActivated: " .. os.date()}
end
function removeButtons()
    local buttons = self.getButtons()
    if buttons ~= nil then
        for i = #buttons, 1, -1 do
            self.removeButton(buttons[i].index)
            spawnedButtons = spawnedButtons - 1
        end
    end
end
function createActivateButtons()
    if not Global.call("getExtendedScriptingState") and not cardState.isBasicScriptingCard then
        return
    end
    for i, button in pairs(buttonSetup.activateButtons) do
        if button.index == nil then
            button.index = spawnedButtons
            self.createButton(button)
            spawnedButtons = spawnedButtons + 1
        end
    end
end
function setInActivatonZone(newValue)
    cardState.inActivatonZone = newValue
end
buttonSetup = {}
buttonSetup.activateButtons = {}
buttonSetup.activateButtons[1] = {
    label = "",
    click_function = "activateCard",
    tooltip = "Click to activate Card Code.",
    function_owner = self,
    position = activateButtonDefaultPosition,
    height = 175,
    width = 350,
    alignment = 3,
    scale = {
        x = 1.5,
        y = 1.5,
        z = 1.5
    },
    font_size = 1,
    font_color = {95 / 255, 120 / 255, 0 / 255, 1},
    color = activateButtonColor
}

actionCardInterpreter = {}
actionCardInterpreter.translateRawData = function(input)
    local counterType = "Other"
    if next(input.counterTypeTable) ~= nil then
        counterType = input.counterTypeTable[1]
    end
    local actionDefinitions = translateActions(input.rawActions, input.rawActionButtonProperties)
    local actionButtonProperties = translateActionButtonProperties(input.rawActionButtonProperties)
    local eventHandlers = translateEventHandlers(input.rawEventHandlers)
    local counters = translateCounters(input.rawCounters)
    local intermediateActions = {}
    for actionIndex, actionDefinition in pairs(actionDefinitions) do
        local propertiesIndex = -1
        for foundIndex, buttonInfo in pairs(actionButtonProperties) do
            if tonumber(buttonInfo.actionIndex) == tonumber(actionIndex) then
                propertiesIndex = foundIndex
            end
        end
        if propertiesIndex ~= -1 then
            intermediateActions[actionIndex] = {
                actionDefinition = actionDefinition,
                buttonInfo = actionButtonProperties[propertiesIndex]
            }
        else
            intermediateActions[actionIndex] = {
                actionDefinition = actionDefinition
            }
        end
    end
    return {
        actions = intermediateActions,
        counters = counters,
        counterType = counterType,
        eventHandlers = eventHandlers
    }
end
function translateCounters(rawCounters)
    local counterDefinitions = {}
    for _, rawCounter in pairs(rawCounters) do
        local definition = {
            name = rawCounter[1]
        }
        local size = getVectorFromTable(rawCounter, "Size")
        if size ~= nil and #size ~= 0 then
            definition.width = tonumber(size[1])
            definition.height = tonumber(size[2])
        end
        local position = getVectorFromTable(rawCounter, "Pos")
        if position ~= nil and #position ~= 0 then
            definition.position = {tonumber(position[1]), tonumber(position[2]), tonumber(position[3])}
        end
        local color = getVectorFromTable(rawCounter, "Color")
        if color ~= nil and #color ~= 0 then
            definition.color = {tonumber(color[1]), tonumber(color[2]), tonumber(color[3]), tonumber(color[4])}
        end
        local startingAmount = getVectorFromTable(rawCounter, "StartCount")
        if startingAmount ~= nil and next(startingAmount) ~= nil then
            definition.startCount = {
                simple = 0,
                complex = {}
            }
            for _, entry in pairs(startingAmount) do
                if tonumber(entry) ~= nil then
                    definition.startCount.simple = definition.startCount.simple + entry
                else
                    table.insert(definition.startCount.complex, entry)
                end
            end
        end
        table.insert(counterDefinitions, definition)
    end
    return counterDefinitions
end
function translateActionButtonProperties(rawActionButtonsProperties)
    local actionButtonInfos = {}
    for actionIndex, rawButtonInfos in pairs(rawActionButtonsProperties) do
        local actionButtonInfo = {
            actionIndex = actionIndex
        }
        local size = getVectorFromTable(rawButtonInfos, "Size")
        if size ~= nil and #size ~= 0 then
            actionButtonInfo.width = tonumber(size[1])
            actionButtonInfo.height = tonumber(size[2])
        end
        local position = getVectorFromTable(rawButtonInfos, "Pos")
        if position ~= nil and #position ~= 0 then
            actionButtonInfo.position = {tonumber(position[1]), tonumber(position[2]), tonumber(position[3])}
        end
        local color = getVectorFromTable(rawButtonInfos, "Color")
        if color ~= nil and #color ~= 0 then
            actionButtonInfo.color = {tonumber(color[1]), tonumber(color[2]), tonumber(color[3]), tonumber(color[4])}
        end
        table.insert(actionButtonInfos, actionButtonInfo)
    end
    return actionButtonInfos
end
function getVectorFromTable(rawButtonInfos, vectorIdentifier, filter)
    local isPositionValue = false
    local relevant = false
    result = {}
    for _, value in pairs(rawButtonInfos) do
        if relevant then
            for substring in string.gmatch(value, "[-0-9.A-Za-z)]+") do
                if string.match(substring, "[)]") ~= nil then
                    if string.match(substring, "[-0-9.A-Za-z]+") then
                        table.insert(result, string.match(substring, "[-0-9.A-Za-z]+"))
                    end
                    relevant = false
                else
                    table.insert(result, substring)
                end
            end
        end
        if value == vectorIdentifier then
            relevant = true
        end
    end
    return result
end
function translateEventHandlers(rawEventHandlers)
    local eventHandlers = {}
    for eventHandlerIndex, rawEventHandler in pairs(rawEventHandlers) do
        local actionIndex = string.match(rawEventHandler[4], "[0-9]")
        local allowedPhases = nil
        local allowedPhasesRaw = getVectorFromTable(rawEventHandler, "AllowedPhases")
        if rawEventHandler[5] ~= nil then
            allowedPhases = {}
            for _, phase in pairs(allowedPhasesRaw) do
                table.insert(allowedPhases, phase)
            end
        end
        eventHandlers[eventHandlerIndex] = {
            triggerType = rawEventHandler[2],
            triggerScope = rawEventHandler[1],
            actionIndex = tonumber(actionIndex),
            allowedPhases = allowedPhases
        }
    end
    return eventHandlers
end
function translateActions(rawActions, otherProperties)
    local actionDefinitions = {}
    for actionIndex, rawAction in pairs(rawActions) do
        local halfs = splitStringInTwoHalfs(rawAction, "->")
        local leftSideSorted = sortByKeyValuePairsAndSingleValues(halfs.leftSide)
        local rightSideSorted = sortByKeyValuePairsAndSingleValues(halfs.rightSide)
        local actionPropertiesAndFuncs = createActionProperties(leftSideSorted, rightSideSorted)
        local action = {}
        action.actionIndex = tonumber(actionIndex)
        action.actionProperties = actionPropertiesAndFuncs.actionProperties
        if otherProperties[actionIndex] ~= nil then
            for _, entry in pairs(otherProperties[actionIndex]) do
                if string.match(entry, "isRepeatable") then
                    action.actionProperties.isRepeatable = true
                elseif string.match(entry, "canBeUndone") then
                    action.actionProperties.canBeUndone = true
                end
            end
        end
        if actionPropertiesAndFuncs.actionFuncs.onActivated ~= nil then
            action.onActivated = actionPropertiesAndFuncs.actionFuncs.onActivated
        end
        if actionPropertiesAndFuncs.actionFuncs.preActivation ~= nil then
            action.preActivation = actionPropertiesAndFuncs.actionFuncs.preActivation
        end
        if actionPropertiesAndFuncs.actionFuncs.undoPreCondition ~= nil then
            action.undoPreCondition = actionPropertiesAndFuncs.actionFuncs.undoPreCondition
        end
        if actionPropertiesAndFuncs.actionFuncs.undoActivated ~= nil then
            action.undoActivated = actionPropertiesAndFuncs.actionFuncs.undoActivated
        end
        table.insert(actionDefinitions, action)
    end
    return actionDefinitions
end
function createActionProperties(rawCost, rawEffects)
    local actionProperties = {
        resourceValues = {},
        productionValues = {},
        effects = {}
    }
    local actionFuncs = {}
    for _, effect in pairs(rawCost.singleValues) do
        table.insert(actionProperties.effects, effect)
    end
    for rawKey, value in pairs(rawCost.keyValuePairs) do
        local key = translateKey(rawKey)
        if key.type == "resource" then
            actionProperties.resourceValues[key.value] = -value
        elseif key.type == "production" then
            actionProperties.productionValues[key.value] = -value
        elseif key.type == "counter" then
            actionFuncs.preActivation = function(playerColor)
                return checkCounterAvailabilityCondition(1, value)()
            end
            actionFuncs.onActivated = function(playerColor)
                changeCounterEffect(1, -value)()
            end
            actionFuncs.undoActivated = function(playerColor)
                return changeCounterEffect(1, value)()
            end
        end
    end
    for _, effect in pairs(rawEffects.singleValues) do
        table.insert(actionProperties.effects, effect)
    end
    for rawKey, value in pairs(rawEffects.keyValuePairs) do
        local key = translateKey(rawKey)
        if key.type == "resource" then
            if actionProperties.resourceValues[key.value] ~= nil then
                log(
                    "Warning: Reducing and increasing the same resource storage with the same action is not supported. Check card description.")
            end
            actionProperties.resourceValues[key.value] = value
        elseif key.type == "production" then
            if actionProperties.productionValues[key.value] ~= nil then
                log(
                    "Warning: Reducing and increasing the same production with the same action is not supported. Check card description.")
            end
            actionProperties.productionValues[key.value] = value
        elseif key.type == "counter" then
            if actionFuncs.onActivated ~= nil then
                log(
                    "Warning: Adding and subtracting counters is not supported for the same action. Check card description.")
            end
            actionFuncs.onActivated = function(playerColor)
                changeCounterEffect(1, value)()
            end
            actionFuncs.undoPreCondition = function(playerColor)
                return checkCounterAvailabilityCondition(1, value)()
            end
            actionFuncs.undoActivated = function(playerColor)
                return changeCounterEffect(1, -value)()
            end
        end
    end
    return {
        actionProperties = actionProperties,
        actionFuncs = actionFuncs
    }
end
function translateKey(rawKey)
    if rawKey == "Counter" then
        return {
            type = "counter"
        }
    end
    local isProduction = string.match(rawKey, "Prod")
    if isProduction then
        local truncatedKey = string.sub(rawKey, 0, -5)
        return {
            type = "production",
            value = truncatedKey
        }
    else
        return {
            type = "resource",
            value = rawKey
        }
    end
end
function splitStringInTwoHalfs(inputTable, pattern)
    local leftSide = {}
    local rightSide = {}
    local index = 0
    for i, value in pairs(inputTable) do
        if value == pattern then
            index = index + 1
        elseif index == 0 then
            table.insert(leftSide, value)
        else
            table.insert(rightSide, value)
        end
    end
    return {
        leftSide = leftSide,
        rightSide = rightSide
    }
end
function sortByKeyValuePairsAndSingleValues(half)
    local keyValuePairs = {}
    local singleValues = {}
    local latestNumber = {}
    local nextNumberOffsetExpected = 1
    for i, value in pairs(half) do
        if (i + nextNumberOffsetExpected) % 2 == 0 then
            if tonumber(value) ~= nil then
                latestNumber = tonumber(value)
            else
                nextNumberOffsetExpected = (nextNumberOffsetExpected + 1) % 2
                table.insert(singleValues, value)
            end
        else
            keyValuePairs[value] = latestNumber
        end
    end
    return {
        singleValues = singleValues,
        keyValuePairs = keyValuePairs
    }
end

ownableObjects = {}
ownableObjects.specialTileMappings = {}
ownableObjects.specialTileMappings.aliases = {
    redCity = {"cityTile", "specialTile"},
    newVenice = {"cityTile", "specialTile"},
    capitalCity = {"cityTile", "specialTile"},
    wetlands = {"greenery", "specialTile"},
    commercialDistrict = {"specialTile"}
}
ownableObjects.baseGame = {}
ownableObjects.baseGame.tiles = {
    greenery = "greenery",
    city = "cityTile",
    cityTile = "cityTile",
    capitalCity = "capitalCity",
    mine = "mine",
    preservationArea = "preservationArea",
    mohole = "mohole",
    volcano = "volcano",
    restrictedArea = "restrictedArea",
    commercialDistrict = "commercialDistrict",
    spacePort = "spacePort",
    ganymedColony = "ganymedColony",
    industrialZone = "industrialZone",
    nuclearZone = "nuclearZone",
    naturalPreserve = "naturalPreserve",
    specialTile = "specialTile",
    spaceCityTile = "spaceCityTile"
}
ownableObjects.baseGame.cardResources = {
    animal = "animal",
    microbe = "microbe",
    science = "science",
    fighter = "fighter"
}
ownableObjects.baseGame.friendlyNameMapping = {
    greenery = {"Greenery"},
    cityTile = {"CityTile", "cityTile"},
    specialTile = {"specialTile"}
}
ownableObjects.venus = {}
ownableObjects.venus.tiles = {
    maxwellBase = "maxwellBase",
    stratopolis = "stratopolis",
    lunaMetropolis = "lunaMetropolis",
    dawnCity = "dawnCity"
}
ownableObjects.venus.cardResources = {
    asteroid = "asteroid",
    floater = "floater"
}
ownableObjects.venus.friendlyNameMapping = {
    asteroid = {"Asteroid"},
    floater = {"Floater"}
}
ownableObjects.colonies = {}
ownableObjects.colonies.objects = {
    colony = "colony"
}
ownableObjects.colonies.cardResources = {
    refugee = "refugee"
}
ownableObjects.colonies.friendlyNameMapping = {
    colony = {"Colony", "Colonies"}
}
ownableObjects.turmoil = {}
ownableObjects.turmoil.tiles = {
    stanfordTorus = "stanfordTorus"
}
ownableObjects.turmoil.friendlyNameMapping = {}
ownableObjects.pathfinder = {}
ownableObjects.pathfinder.tiles = {
    redCity = "redCity",
    newVenice = "newVenice",
    crashSite = "crashSite",
    wetlands = "wetlands"
}
ownableObjects.pathfinder.cardResources = {
    habitat = "habitat",
    robot = "robot",
    data = "data"
}
ownableObjects.highOrbit = {}
ownableObjects.highOrbit.cardResources = {
    ore = "ore"
}
ownableObjects.venusPhaseTwo = {}
ownableObjects.venusPhaseTwo.tiles = {
    floatingArray = "floatingArray",
    gasMine = "gasMine",
    venusHabitat = "venusHabitat"
}
ownableObjects.pathfinder.friendlyNameMapping = {}
function createOwnableObjectsCollection()
    local collection = {}
    for _, expansion in pairs(ownableObjects) do
        for _, objectType in pairs(expansion) do
            if objectType ~= "friendlyNameMapping" then
                for key, value in pairs(objectType) do
                    collection[key] = 0
                end
            end
        end
    end
    return collection
end

counterData = {}
counterData = {
    Animal = {
        tokensAccepted = {"Animal", "WildCard"},
        color = {0, 0.5, 0, 1},
        transparentColor = {0, 0.5, 0, 0.85},
        fontColor = {0, 0, 0, 1},
        counterType = ownableObjects.baseGame.cardResources.animal
    },
    Microbe = {
        tokensAccepted = {"Microbe", "WildCard"},
        color = {0.25, 0.94, 0.11, 1},
        transparentColor = {0.25, 0.94, 0.11, 0.8},
        fontColor = {0, 0, 0, 1},
        counterType = ownableObjects.baseGame.cardResources.microbe
    },
    Floater = {
        tokensAccepted = {"Floater", "WildCard"},
        color = {0.918, 0.871, 0, 1},
        transparentColor = {0.918, 0.871, 0, 0.8},
        fontColor = {0, 0, 0, 1},
        counterType = ownableObjects.venus.cardResources.floater
    },
    Science = {
        tokensAccepted = {"Science", "WildCard"},
        color = {1, 1, 1, 1},
        transparentColor = {1, 1, 1, 0.8},
        fontColor = {0, 0, 0, 1},
        counterType = ownableObjects.baseGame.cardResources.science
    },
    Asteroid = {
        tokensAccepted = {"Asteroid", "WildCard"},
        color = {0.1, 0.1, 0.1, 1},
        transparentColor = {0.1, 0.1, 0.1, 0.8},
        fontColor = {1, 1, 1, 1},
        counterType = ownableObjects.venus.cardResources.asteroid
    },
    Data = {
        tokensAccepted = {"Data", "WildCard"},
        color = {255 / 255, 126 / 255, 40 / 255, 1},
        transparentColor = {255 / 255, 126 / 255, 40 / 255, 0.8},
        fontColor = {0, 0, 0, 1},
        counterType = ownableObjects.pathfinder.cardResources.data
    },
    Fighter = {
        tokensAccepted = {"Fighter", "WildCard"},
        color = {0.1, 0.1, 0.1, 1},
        transparentColor = {0.1, 0.1, 0.1, 0.8},
        fontColor = {1, 1, 1, 1},
        counterType = ownableObjects.baseGame.cardResources.fighter
    },
    Robot = {
        tokensAccepted = {"WildCard"},
        color = {1, 1, 1, 1},
        transparentColor = {1, 1, 1, 0.8},
        fontColor = {0, 0, 0, 1},
        counterType = ownableObjects.pathfinder.cardResources.robot
    },
    Habitat = {
        tokensAccepted = {"WildCard"},
        color = {0.1, 0.1, 1, 1},
        transparentColor = {0.1, 0.1, 1, 0.8},
        fontColor = {0, 0, 0, 1},
        counterType = ownableObjects.pathfinder.cardResources.data
    },
    Ore = {
        tokensAccepted = {"Ore,WildCard"},
        color = {141 / 255, 111 / 255, 105 / 255, 0.9},
        transparentColor = {141 / 255, 111 / 255, 105 / 255, 0.8},
        fontColor = {1, 1, 1, 1},
        counterType = ownableObjects.highOrbit.cardResources.ore
    },
    Refugee = {
        tokensAccepted = {"WildCard"},
        color = {255 / 255, 130 / 255, 15 / 255, 0.9},
        transparentColor = {255 / 255, 130 / 255, 15 / 255, 0.8},
        fontColor = {0, 0, 0, 1},
        counterType = ownableObjects.colonies.cardResources.refugee
    },
    Other = {
        tokensAccepted = {},
        color = {0.5, 0.5, 0.5, 1},
        transparentColor = {0.5, 0.5, 0.5, 0.9},
        fontColor = {0, 0, 0, 1},
        counterType = nil
    }
}

eventData = {}
eventData.triggerType = {
    cityPlayed = "cityPlayed",
    spaceCityPlayed = "spaceCityPlayed",
    marsCityPlayed = "marsCityPlayed",
    greeneryPlayed = "greeneryPlayed",
    oceanPlayed = "oceanPlayed",
    colonyPlayed = "colonyPlayed",
    productionChanged = "productionChanged",
    venusTerraformed = "venusTerraformed",
    oxygenIncreased = "oxygenIncreased",
    buildingTagPlayed = "buildingTagPlayed",
    spaceTagPlayed = "spaceTagPlayed",
    powerTagPlayed = "powerTagPlayed",
    scienceTagPlayed = "scienceTagPlayed",
    jovianTagPlayed = "jovianTagPlayed",
    earthTagPlayed = "earthTagPlayed",
    venusTagPlayed = "venusTagPlayed",
    plantTagPlayed = "plantTagPlayed",
    microbeTagPlayed = "microbeTagPlayed",
    animalTagPlayed = "animalTagPlayed",
    noneTagPlayed = "noneTagPlayed",
    eventTagPlayed = "eventTagPlayed",
    marsTagPlayed = "marsTagPlayed",
    infrastructureTagPlayed = "infrastructureTagPlayed",
    vpCardPlayed = "vpCardPlayed",
    animalResourceGained = "animalResourceGained",
    microbeResourceGained = "microbeResourceGained",
    floaterResourceGained = "floaterResourceGained",
    scienceResourceGained = "scienceResourceGained",
    fighterResourceGained = "fighterResourceGained",
    dataResourceGained = "dataResourceGained",
    asteroidResourceGained = "asteroidResourceGained",
    payTwentyCostCard = "payTwentyCostCard",
    standardProjectCity = "standardProjectCity",
    standardProjectGreenery = "standardProjectGreenery",
    standardProjectOcean = "standardProjectOcean",
    standardProjectTemperature = "standardProjectTemperature",
    standardProjectPowerPlant = "standardProjectPowerPlant",
    standardProjectVenus = "standardProjectVenus",
    standardProjectColony = "standardProjectColony",
    buyStandardProject = "buyStandardProject",
    cardWithRequirmentPlayed = "cardWithRequirmentPlayed",
    specialTilePlayed = "specialTilePlayed",
    increasePathfinderVenus = "increasePathfinderVenus",
    increasePathfinderEarth = "increasePathfinderEarth",
    increasePathfinderMars = "increasePathfinderMars",
    increasePathfinderJovian = "increasePathfinderJovian",
    terraformingGained = "terraformingGained",
    marsTilePlaced = "marsTilePlaced",
    venusTilePlaced = "venusTilePlaced",
    turmoilFactionChanged = "turmoilFactionChanged",
    specialTilePlayed = "specialTilePlayed",
    productionPhase = "productionPhase",
    newGeneration = "newGeneration",
    cardPlayed = "cardPlayed",
    turmoilNewGovernment = "turmoilNewGovernment",
    actionPerformed = "actionPerformed",
    playerPerformedAction = "playerPerformedAction",
    payedForCard = "payedForCard",
    conversionRatesUpdated = "conversionRatesUpdated",
    playerTurnBegan = "playerTurnBegan",
    planetWildCardTokenAbsorbed = "planetWildCardTokenAbsorbed",
    colonyTraded = "colonyTraded",
    buyVenusStandardProject = "buyVenusStandardProject",
    venusHabitatPlaced = "venusHabitatPlaced",
    storageChanged = "storageChanged",
    oceanRemoved = "oceanRemoved",
    playerTurnEnd = "playerTurnEnd"
}
eventData.triggerScope = {
    anyPlayer = "anyPlayer",
    playerThemself = "playerThemself",
    otherPlayers = "otherPlayers",
    noPlayer = "noPlayer"
}
eventData.allowedPhasesToTrigger = {
    solarPhase = "solarPhase",
    gameEnd = "gameEnd",
    draft = "draft",
    inRound = "inRound"
}

phases = {
    generationPhase = "generationPhase",
    solarPhase = "solarPhase",
    gameEndPhase = "gameEndPhase",
    draftingPhase = "draftingPhase",
    gameStartPhase = "gameStartPhase",
    gameSetupPhase = "gameSetupPhase"
}

eventHandlers = {}
function registerEventHandlers(owner)
    for _, eventHandler in pairs(eventHandlers) do
        Global.call("eventHandling_subscribeHandler", {
            eventHandler = eventHandler,
            owner = owner
        })
    end
end
function unregisterEventHandlers(triggerTypeToUnsubscribe)
    for _, eventHandler in pairs(eventHandlers) do
        if eventHandler.triggerType == triggerTypeToUnsubscribe then
            Global.call("eventHandling_unsubscribeHandler", {
                eventHandler = eventHandler
            })
        end
    end
end
function setupEventHandler(triggerType, triggerScope, actionIndex, params)
    local callbackName = "triggerActionRemotely"
    local allowedPhases = {phases.generationPhase, phases.gameStartPhase, phases.gameEndPhase, phases.draftingPhase}
    local prettyName = self.getName()
    if params ~= nil then
        if params.callbackName ~= nil then
            callbackName = params.callbackName
        end
        if params.allowedPhases ~= nil then
            allowedPhases = params.allowedPhases
        end
        if params.objectPrettyName ~= nil then
            prettyName = params.objectPrettyName
        end
    end
    local eventHandler = {
        eventHandlerId = self.guid,
        triggerType = triggerType,
        triggerScope = triggerScope,
        actionIndex = actionIndex,
        callbackName = callbackName,
        allowedPhases = allowedPhases,
        objectPrettyName = prettyName
    }
    table.insert(eventHandlers, eventHandler)
end

action = true
spawnedButtons = 0
spentColor = {1, 0, 0, 0.75}
availableColor = {0, 1, 0, 0.75}
repeatableColor = {75 / 255, 1, 1, 0.75}
defaultCardState = {
    counters = {},
    actionUsed = false,
    active = false,
    isBasicScriptingCard = true,
    inActivatonZone = false,
    tokensAccepted = {},
    mainCounterType = nil,
    isAutomatic = true,
    wasUpdated = true,
    customCounterType = "Other"
}
buttonSetup.activateButtons[1].click_function = "activationOverride"
function loadCallback(is_savegame)
    setupFromDescription()
    if cardState.customCounterType ~= nil then
        applyCounterType(cardState.customCounterType)
    end
end
function activationOverride(_, playerColor)
    setupFromDescription()
    activateCard(_, playerColor)
end
function getAcceptedTokenList()
    if cardState.tokensAccepted == nil then
        return {}
    end
    return cardState.tokensAccepted
end
function getMainCounterType()
    setupFromDescription()
    return cardState.mainCounterType
end
function setupFromDescription()
    if #buttonSetup.actions == 0 and #buttonSetup.counters == 0 then
        local rawData = Global.call("descriptionInterpreter_getActionCardInfos", self.getDescription())
        local descriptionActionInfos = actionCardInterpreter.translateRawData(rawData)
        initSimpleActionButtons(#descriptionActionInfos.actions)
        setupDescriptionBasedActionButtons(descriptionActionInfos)
        setupDescriptionBasedCounterButtons(descriptionActionInfos)
        setupDescriptionBasedEventHandlers(descriptionActionInfos)
    end
end
function setupDescriptionBasedEventHandlers(descriptionActionInfos)
    for _, eventHandler in pairs(descriptionActionInfos.eventHandlers) do
        if eventHandler.allowedPhases ~= nil then
            setupEventHandler(eventHandler.triggerType, eventHandler.triggerScope, eventHandler.actionIndex, {
                allowedPhases = eventHandler.allowedPhases
            })
        else
            setupEventHandler(eventHandler.triggerType, eventHandler.triggerScope, eventHandler.actionIndex)
        end
    end
end
function setupDescriptionBasedActionButtons(descriptionActionInfos)
    for actionIndex, actionInfo in pairs(descriptionActionInfos.actions) do
        buttonSetup.actions[actionIndex].actionProperties = actionInfo.actionDefinition.actionProperties
        local actionFuncs = actionInfo.actionDefinition.actionFuncs
        if actionInfo.actionDefinition ~= nil then
            if actionInfo.actionDefinition.onActivated ~= nil then
                buttonSetup.actions[actionIndex].onActivated = actionInfo.actionDefinition.onActivated
            end
            if actionInfo.actionDefinition.preActivation ~= nil then
                buttonSetup.actions[actionIndex].preActivation = actionInfo.actionDefinition.preActivation
            end
            if actionInfo.actionDefinition.actionProperties.canBeUndone then
                if actionInfo.actionDefinition.undoActivated ~= nil then
                    buttonSetup.actions[actionIndex].undoActivated = actionInfo.actionDefinition.undoActivated
                end
                if actionInfo.actionDefinition.undoPreCondition ~= nil then
                    buttonSetup.actions[actionIndex].undoPreCondition = actionInfo.actionDefinition.undoPreCondition
                end
            end
        end
        local buttonInfoOverride = actionInfo.buttonInfo
        if buttonInfoOverride ~= nil then
            applyButtonOverrides(buttonSetup.actions[actionIndex], buttonInfoOverride)
        end
    end
end
function applyCounterFormula(formula, counterIndex, playerColor)
    local output = Global.call("getSpecificPlayerPropertiesRemotely", {
        formula = formula,
        playerColor = playerColor
    })
    changeCounter(counterIndex, output)
end
function setupDescriptionBasedCounterButtons(descriptionActionInfos)
    for _, counter in pairs(descriptionActionInfos.counters) do
        if buttonSetup.counters == nil then
            buttonSetup.counters = {}
        end
        if counter.name == "BaseCounter" then
            buttonSetup.counters[1] = buttonSetup.defaultCounter
            buttonSetup.counters[1].startCount = counter.startCount
            if setupCounters == nil and counter.startCount ~= nil then
                setupCounters = function(playerColor)
                    changeCounter(1, counter.startCount.simple)
                    for _, formula in pairs(counter.startCount.complex) do
                        applyCounterFormula(formula, 1, playerColor)
                    end
                end
            end
            applyButtonOverrides(buttonSetup.counters[1], counter)
        elseif counter.name == "VPCounter" then
            buttonSetup.counters[2] = buttonSetup.defaultVpCounter
            applyButtonOverrides(buttonSetup.counters[2], counter)
        end
    end
    cardState.customCounterType = descriptionActionInfos.counterType
end
function setupBlueCard(playerColor)
    if cardState.mainCounterType == nil then
        applyCounterType(cardState.customCounterType)
    end
    if setupCounters ~= nil then
        setupCounters(playerColor)
    end
    cardState.wasUpdated = true
end
function applyCounterType(counterType)
    if counterType ~= nil then
        local data = counterData[counterType]
        if data == nil then
            data = counterData["Other"]
        end
        cardState.mainCounterType = data.counterType
        if cardState.tokensAccepted == nil or next(cardState.tokensAccepted) == nil then
            cardState.tokensAccepted = data.tokensAccepted
        end
        buttonSetup.defaultCorpCounter.color = data.transparentColor
        buttonSetup.defaultCorpCounter.font_color = data.fontColor
        buttonSetup.defaultCounter.color = data.transparentColor
        buttonSetup.defaultCounter.font_color = data.fontColor
        buttonSetup.defaultVpCounter.color = data.color
        buttonSetup.defaultVpCounter.font_color = data.fontColor
        buttonSetup.defaultTagCounter.color = data.color
        buttonSetup.defaultTagCounter.font_color = data.fontColor
    end
end
function applyButtonOverrides(button, overrides)
    if overrides.width ~= nil then
        button.width = overrides.width
    end
    if overrides.height ~= nil then
        button.height = overrides.height
        button.font_size = 400 * overrides.height / 450
    end
    if overrides.position ~= nil then
        button.position = overrides.position
    end
    if overrides.color ~= nil then
        button.color = overrides.color
    end
end
function createButtons()
    if string.match(self.getDescription(), ":DebugMode:") then
        Wait.frames(createButtonsDebug(), 20)
    else
        if cardState.active then
            createActionButtons()
            if next(eventHandlers) ~= nil then
                createCardModeButton()
            end
            createCounters()
        else
            createActivateButtons()
        end
    end
    cardState.wasUpdated = true
end
function createButtonsDebug()
    function debug()
        removeButtons()
        coroutine.yield(0)
        spawnedButtons = 0
        buttonSetup.actions = {}
        buttonSetup.counters = {}
        buttonSetup.cardMode.index = nil
        coroutine.yield(0)
        setupFromDescription()
        coroutine.yield(0)
        if cardState.active then
            createActionButtons(true)
            coroutine.yield(0)
            if next(eventHandlers) ~= nil then
                createCardModeButton()
                coroutine.yield(0)
            end
            createCounters(true)
            coroutine.yield(0)
        else
            createActivateButtons()
            coroutine.yield(0)
        end
        return 1
    end
    startLuaCoroutine(self, "debug")
end
function initSimpleActionButtons(numberOfNewActions)
    buttonSetup.actions = {}
    local actionIndexOffset = #buttonSetup.actions
    for i = 1, numberOfNewActions do
        local addedActionIndex = i + actionIndexOffset
        local actionName = "actionButtonFunc_" .. addedActionIndex
        local func = function(_, playerColor, altClick)
            actionCheckSimple(addedActionIndex, playerColor, altClick)
        end
        self.setVar(actionName, func)
        local button = {
            click_function = actionName,
            function_owner = self,
            position = vector(0, 0.25, -0.9 + (i - 1) * 0.3),
            height = 170,
            width = 850,
            alignment = 3,
            color = {0, 1, 0, 0.75}
        }
        table.insert(buttonSetup.actions, button)
    end
end
function createCardModeButton()
    if buttonSetup.cardMode == nil or not Global.call("getExtendedScriptingState") then
        return
    end
    if not cardState.isAutomatic then
        buttonSetup.cardMode.label = "Manual Mode"
        buttonSetup.cardMode.color = {1, 1, 0, 0.85}
        buttonSetup.cardMode.tooltip = "Card effects have to be triggered manually."
    end
    local buttonInfo = buttonSetup.cardMode
    if buttonSetup.cardMode.index ~= nil then
        self.editButton(buttonInfo)
    else
        buttonSetup.cardMode.index = spawnedButtons
        self.createButton(buttonInfo)
        spawnedButtons = spawnedButtons + 1
    end
end
function createCounters(isDebug)
    if cardState.counters == nil then
        cardState.counters = {}
    end
    for i = 1, #buttonSetup.counters do
        local buttonInfo = buttonSetup.counters[i]
        if buttonInfo.counterIndex ~= nil then
            if cardState.counters[buttonInfo.counterIndex] == nil then
                cardState.counters[buttonInfo.counterIndex] = 0
            end
            buttonInfo.label = cardState.counters[buttonInfo.counterIndex]
        else
            if cardState.counters[i] == nil then
                cardState.counters[i] = 0
            end
            buttonInfo.label = cardState.counters[i]
        end
        if buttonInfo.index ~= nil and not isDebug then
            self.editButton(buttonInfo)
        else
            buttonSetup.counters[i].index = spawnedButtons
            self.createButton(buttonInfo)
            spawnedButtons = spawnedButtons + 1
        end
    end
end
function createActionButtons(isDebug)
    for i = 1, #buttonSetup.actions do
        if buttonSetup.actions[i].actionProperties == nil then
            buttonSetup.actions[i].actionProperties = {
                resourceValues = {},
                productionValues = {},
                effects = {}
            }
        end
        local buttonInfo = buttonSetup.actions[i]
        if cardState.actionUsed and not buttonSetup.actions[i].actionProperties.isRepeatable then
            if not buttonInfo.customColors then
                buttonInfo.color = spentColor
            end
        else
            if not buttonInfo.customColors then
                if buttonSetup.actions[i].actionProperties.isRepeatable then
                    buttonInfo.color = repeatableColor
                else
                    buttonInfo.color = availableColor
                end
            end
        end
        if buttonSetup.actions[i].index ~= nil and not isDebug then
            self.editButton(buttonInfo)
        else
            buttonSetup.actions[i].index = spawnedButtons
            self.createButton(buttonInfo)
            spawnedButtons = spawnedButtons + 1
        end
    end
end
function addSubtractCounterButtonClick(obj, player_color, altClick)
    addSubtractCounter(altClick, 1)
    if not altClick then
        absorbTokenFromHand()
    end
end
function addSubtractCounter(altClick, index)
    if altClick and cardState.counters[index] > 0 then
        changeCounter(index, -1)
    elseif not altClick then
        changeCounter(index, 1)
    else
        return
    end
    createButtons()
end
function changeCounterRemotely(params)
    changeCounter(params.counterIndex, params.amount)
    createButtons()
end
function changeCounterByCardAction(counterIndex, amount, actionIndex)
    changeCounter(counterIndex, amount)
end
function changeCounter(counterIndex, amount)
    if cardState.counters[counterIndex] == nil then
        cardState.counters[counterIndex] = 0
    end
    local actualAmount = amount
    if cardState.counters[counterIndex] + amount < 0 then
        actualAmount = -cardState.counters[counterIndex]
    end
    cardState.counters[counterIndex] = cardState.counters[counterIndex] + actualAmount
    if cardState.mainCounterType ~= nil and cardState.owner ~= nil and counterIndex == 1 then
        Global.call("updateOwnableObjects", {
            playerColor = cardState.owner,
            ownableObjectName = cardState.mainCounterType,
            delta = actualAmount
        })
    end
end
function defaultAddCounterAction(obj, playerColor, altClick)
    if cardState.actionUsed and altClick then
        cardState.actionUsed = false
        addSubtractCounterButtonClick(nil, nil, altClick)
    elseif cardState.actionUsed and not altClick then
        Global.call("logging_printToColor", {
            message = "Action already used this generation",
            playerColor = playerColor,
            messageColor = {1, 1, 1},
            loggingMode = "essential"
        })
    else
        cardState.actionUsed = true
        addSubtractCounterButtonClick(nil, nil, false)
    end
end
buttonSetup.counters = {}
buttonSetup.defaultCounter = {
    label = "",
    click_function = "addSubtractCounterButtonClick",
    tooltip = "Left click to add 1 to counter\
Right click to remove 1 from counter",
    function_owner = self,
    position = {0, 0.25, 0.1},
    counterIndex = 1,
    height = 450,
    width = 450,
    alignment = 3,
    scale = {
        x = 1.5,
        y = 1.5,
        z = 1.15
    },
    font_size = 400,
    font_color = {0 / 255, 0 / 255, 0 / 255, 1},
    color = defaultCounterColor or {180 / 255, 180 / 255, 180 / 255, 1}
}
buttonSetup.defaultCorpCounter = {
    label = "",
    click_function = "addSubtractCounterButtonClick",
    tooltip = "Left click to add 1 to counter\
Right click to remove 1 from counter",
    function_owner = self,
    position = {-0.2, 0.25, 0.1},
    counterIndex = 1,
    height = 450,
    width = 250,
    alignment = 3,
    scale = {
        x = 1,
        y = 1.5,
        z = 1.15
    },
    font_size = 300,
    font_color = {0 / 255, 0 / 255, 0 / 255, 1},
    color = defaultCounterColor or {180 / 255, 180 / 255, 180 / 255, 1}
}
buttonSetup.defaultVpCounter = {
    label = "",
    click_function = "addSubtractCounterButtonClick",
    tooltip = "Left click to add 1 to counter\
Right click to remove 1 from counter",
    function_owner = self,
    position = {0.5, 0.25, 1.13},
    counterIndex = 1,
    height = 100,
    width = 80,
    alignment = 3,
    scale = {
        x = 1.5,
        y = 1.5,
        z = 1.15
    },
    font_size = 70,
    font_color = {0 / 255, 0 / 255, 0 / 255, 1},
    color = defaultVPCounterColor or {180 / 255, 180 / 255, 180 / 255, 1}
}
buttonSetup.defaultTagCounter = {
    label = "",
    click_function = "addSubtractCounterButtonClick",
    tooltip = "Left click to add 1 to counter\
Right click to remove 1 from counter",
    function_owner = self,
    position = {0.5, 0.25, -0.87},
    counterIndex = 2,
    height = 100,
    width = 80,
    alignment = 3,
    scale = {
        x = 1.5,
        y = 1.5,
        z = 1.15
    },
    font_size = 70,
    font_color = {0 / 255, 0 / 255, 0 / 255, 1},
    color = defaultCounterColor or {180 / 255, 180 / 255, 180 / 255, 1}
}
buttonSetup.actions = {}
function triggerActionRemotely(params)
    if cardState.isAutomatic ~= nil and cardState.isAutomatic then
        actionCheckSimple(params.actionIndex, params.playerColor, false, true)
    end
end
function doAction(actionIndex, playerColor, isAutoTrigger)
    if not cardState.silentActions then
        if isAutoTrigger then
            Global.call("logging_printToAll", {
                message = "<<AUTO>> Effect on " .. self.getName() .. " triggered automatically for " .. playerColor,
                messageColor = playerColor,
                loggingMode = "detail"
            })
        else
            Global.call("logging_printToAll", {
                message = playerColor .. " used card " .. self.getName(),
                messageColor = playerColor,
                loggingMode = "important"
            })
        end
    end
    local action = buttonSetup.actions[actionIndex]
    if action.preActivation ~= nil then
        local canBeActivated = action.preActivation(playerColor)
        if canBeActivated ~= nil and not canBeActivated then
            return false
        end
    end
    if action.actionProperties.productionValues == nil then
        action.actionProperties.productionValues = {}
    end
    if action.actionProperties.resourceValues == nil then
        action.actionProperties.resourceValues = {}
    end
    if action.actionProperties.effects == nil then
        action.actionProperties.effects = {}
    end
    local result = Global.call("objectActivationSystem_doAction", {
        activationEffects = action.actionProperties,
        sourceName = self.getName(),
        playerColor = playerColor,
        object = self
    })
    if result == true and action.onActivated ~= nil then
        action.onActivated(playerColor)
    end
    if action.actionProperties.isRepeatable then
        return false
    end
    return result
end
function undoAction(actionIndex, playerColor)
    local action = buttonSetup.actions[actionIndex]
    if not action.actionProperties.canBeUndone then
        return false
    end
    if action.undoPreCondition ~= nil then
        local canBeActivated = action.undoPreCondition(playerColor)
        if canBeActivated ~= nil and not canBeActivated then
            return false
        end
    end
    Global.call("logging_printToAll", {
        message = playerColor .. " undoes action of card " .. self.getName(),
        messageColor = playerColor,
        loggingMode = "detail"
    })
    if action.actionProperties.productionValues == nil then
        action.actionProperties.productionValues = {}
    end
    if action.actionProperties.resourceValues == nil then
        action.actionProperties.resourceValues = {}
    end
    if action.actionProperties.effects == nil then
        action.actionProperties.effects = {}
    end
    action.actionProperties.resourceValues = invertValues(action.actionProperties.resourceValues)
    action.actionProperties.productionValues = invertValues(action.actionProperties.productionValues)
    local result = Global.call("objectActivationSystem_doAction", {
        activationEffects = action.actionProperties,
        sourceName = self.getName(),
        playerColor = playerColor,
        object = self
    })
    action.actionProperties.resourceValues = invertValues(action.actionProperties.resourceValues)
    action.actionProperties.productionValues = invertValues(action.actionProperties.productionValues)
    if result == true and action.undoActivated ~= nil then
        action.undoActivated(playerColor)
    end
    if action.actionProperties.isRepeatable then
        return true
    end
    return result
end
function invertValues(keyValuePairs)
    local invertedKeyValuePairs = {}
    for key, value in pairs(keyValuePairs) do
        invertedKeyValuePairs[key] = -value
    end
    return invertedKeyValuePairs
end
function actionCheckSimple(actionIndex, playerColor, altClick, isAutoTrigger)
    if not buttonSetup.actions[actionIndex].actionProperties.isRepeatable then
        if cardState.actionUsed and not altClick then
            Global.call("logging_printToColor", {
                message = self.getName() .. " card has already been used this generation!",
                playerColor = playerColor,
                messageColor = {1, 1, 1},
                loggingMode = "important"
            })
        elseif cardState.actionUsed and altClick then
            if undoAction(cardState.whichActionUsed, playerColor) then
                cardState.actionUsed = false
            end
        elseif not cardState.actionUsed and not altClick then
            if doAction(actionIndex, playerColor) then
                cardState.actionUsed = true
                cardState.whichActionUsed = actionIndex
            end
        end
    else
        doAction(actionIndex, playerColor, isAutoTrigger)
        cardState.whichActionUsed = actionIndex
    end
    createButtons()
end
function changeCounterEffect(counterIndex, amount)
    return function()
        changeCounter(counterIndex, amount)
        return true
    end
end
function checkCounterAvailabilityCondition(counterIndex, amount)
    return function()
        if cardState.counters[counterIndex] < amount then
            Global.call("logging_printToAll", {
                message = "Player " .. cardState.owner .. " needs at least " .. amount ..
                    " card resources in order to activate " .. self.getName(),
                messageColor = cardState.owner,
                loggingMode = "detail"
            })
        end
        return cardState.counters[counterIndex] >= amount
    end
end
function setupSimpleCounterAction(actionIndex, counterIndex, amount, canUndo)
    if buttonSetup.actions[actionIndex].actionProperties == nil then
        buttonSetup.actions[actionIndex].actionProperties = {}
    end
    buttonSetup.actions[actionIndex].onActivated = function(playerColor)
        changeCounterByCardAction(counterIndex, amount, actionIndex)
    end
end
function genEnd()
    cardState.actionUsed = false
    createButtons()
end
function addTokensToCard(params)
    for i = 1, params.quantity do
        addSubtractCounter(false, 1)
    end
end
function toggleAutomatic(_, player_color, altClick)
    if cardState.isAutomatic then
        buttonSetup.cardMode.label = "Manual Mode"
        buttonSetup.cardMode.color = {1, 1, 0, 0.85}
        buttonSetup.cardMode.tooltip = "Card effects have to be triggered manually."
    else
        buttonSetup.cardMode.label = "Automatic Mode"
        buttonSetup.cardMode.color = repeatableColor
        buttonSetup.cardMode.tooltip = "Card effects are triggered automatically."
    end
    if cardState.isAutomatic then
        Global.call("logging_printToColor", {
            message = "Switching mode of " .. self.getName() .. " from automatic to manual.",
            playerColor = player_color,
            messageColor = {1, 1, 1},
            loggingMode = "unimportant"
        })
    else
        Global.call("logging_printToColor", {
            message = "Switching mode of " .. self.getName() .. " from manual to automatic.",
            playerColor = player_color,
            messageColor = {1, 1, 1},
            loggingMode = "unimportant"
        })
    end
    cardState.isAutomatic = not cardState.isAutomatic
    createButtons()
end
function absorbTokenFromHand()
    if cardState.owner ~= nil and cardState.tokensAccepted ~= nil then
        for _, tokenName in pairs(cardState.tokensAccepted) do
            for _, obj in pairs(Player[cardState.owner].getHandObjects()) do
                if obj.getVar("getTokenResourceName") ~= nil then
                    if obj.call("getTokenResourceName") == tokenName then
                        obj.destruct()
                        return
                    end
                end
            end
        end
    end
end
buttonSetup.cardMode = {
    click_function = "toggleAutomatic",
    label = "Automatic Mode",
    tooltip = "Card effects have to be triggered manually",
    function_owner = self,
    position = vector(-0.2, 0.25, 1.37),
    height = 150,
    width = 800,
    alignment = 3,
    scale = scale,
    customColors = true,
    color = {0, 1, 0, 0.85}
}

cardProperties = {
    cardType = "Corp"
}

initSimpleActionButtons(1)
buttonSetup.counters[1] = buttonSetup.defaultCounter
buttonSetup.counters[1].width = 250
buttonSetup.counters[1].height = 500
buttonSetup.actions[1].height = 250
buttonSetup.actions[1].width = 400
buttonSetup.actions[1].actionProperties = {
    resourceValues = {
        Credits = 4
    },
    isRepeatable = true
}
buttonSetup.actions[1].onActivated = function(playerColor)
    changeCounterEffect(1, 1)()
end
cardUxLibrary.addOffset(buttonSetup.actions[1], {0.3, 0, 0.93})
cardUxLibrary.addOffset(buttonSetup.counters[1], {-0.68, 0, 0.08})
setupEventHandler(eventData.triggerType.payTwentyCostCard, eventData.triggerScope.playerThemself, 1)
setupEventHandler(eventData.triggerType.standardProjectCity, eventData.triggerScope.playerThemself, 1)
setupEventHandler(eventData.triggerType.standardProjectGreenery, eventData.triggerScope.playerThemself, 1)
