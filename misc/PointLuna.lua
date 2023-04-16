
initSimpleActionButtons(1)
buttonSetup.counters[1] = buttonSetup.defaultCounter
buttonSetup.actions[1].actionProperties = {
    effects = {"DrawCard"},
    isRepeatable = true
}
buttonSetup.actions[1].onActivated = function(playerColor)
    changeCounterEffect(1, 1)()
end
buttonSetup.actions[1].height = 275
buttonSetup.actions[1].width = 400
buttonSetup.counters[1].height = 500
buttonSetup.counters[1].width = 275
cardUxLibrary.addOffset(buttonSetup.actions[1], {0.4, 0, 1})
cardUxLibrary.addOffset(buttonSetup.counters[1], {-0.5, 0, 0.1})
setupEventHandler(eventData.triggerType.earthTagPlayed, eventData.triggerScope.playerThemself, 1)
