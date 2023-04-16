
initSimpleActionButtons(1)
buttonSetup.counters[1] = buttonSetup.defaultCorpCounter
cardUxLibrary.addOffset(buttonSetup.counters[1], {-0.2, 0, -0.12})
buttonSetup.actions[1].actionProperties = {
    productionValues = {
        Credits = 1
    },
    isRepeatable = true
}
buttonSetup.actions[1].onActivated = function(playerColor)
    changeCounterEffect(1, 1)()
end
buttonSetup.actions[1].height = 275
buttonSetup.actions[1].width = 400
buttonSetup.counters[1].height = 500
buttonSetup.counters[1].width = 475
cardUxLibrary.addOffset(buttonSetup.actions[1], {0.45, 0, 0.89})
cardUxLibrary.addOffset(buttonSetup.counters[1], {-0.17, 0, 0.28})
function onPlayerTurnBegan(params)
    local activationEffects = {
        resourceValues = {},
        productionValues = {},
        effects = {"Colony"}
    }
    Global.call("objectActivationSystem_doAction", {
        playerColor = params.playerColor,
        object = self,
        sourceName = self.getName(),
        activationEffects = activationEffects
    })
    for _, eventHandler in pairs(eventHandlers) do
        if eventHandler.triggerType == eventData.triggerType.playerTurnBegan then
            Global.call("eventHandling_unsubscribeHandler", {
                eventHandler = eventHandler
            })
        end
    end
end
setupEventHandler(eventData.triggerType.playerTurnBegan, eventData.triggerScope.playerThemself, -1, {
    callbackName = "onPlayerTurnBegan"
})
setupEventHandler(eventData.triggerType.colonyPlayed, eventData.triggerScope.anyPlayer, 1)
