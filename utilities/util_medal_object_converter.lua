-- local function createLocalPlayer()
--     return {
--         PlayerId = LocalPlayer.state.identifier,
--         PlayerName = LocalPlayer.state.name
--     }
-- end

function ConvertToMedalGameContext()
    local configContext = Config.GameContext
    if (not configContext) then
        Logger:Warning('GameContext is not set in the config, skipping')
        return
    end

    local gameContext = {}
    gameContext.serverId = configContext.ServerId
    gameContext.serverName = configContext.ServerName
    gameContext.customStatus = configContext.CustomStatus
    gameContext.globalContextTags = configContext.GlobalContextTags or {}
    gameContext.globalContextData = configContext.GlobalContextData or {}
    -- gameContext.localPlayer = createLocalPlayer()

    return gameContext
end

function ConvertToMedalGameEvent(gameEvent)
    local medalGameEvent = {}
    if (not gameEvent.EventId or not gameEvent.EventName) then
        Logger:Error('EventId and EventName is required')
        return
    end

    medalGameEvent.eventId = gameEvent.EventId
    medalGameEvent.eventName = gameEvent.EventName
    medalGameEvent.triggerActions = gameEvent.TriggerActions or Config.Defaults.TriggerActions

    local eventClipOptions = gameEvent.ClipOptions or {}
    local defaultClipOptions = Config.Defaults.ClipOptions
    medalGameEvent.clipOptions = {
        duration = (eventClipOptions.PreLength or defaultClipOptions.PreLength) + (eventClipOptions.PostLength or defaultClipOptions.PostLength),
        alertType = eventClipOptions.AlertType or defaultClipOptions.AlertType or 'Default'
    }

    local contextTags = nil -- Default to nil, medal does not expect an empty array
    if (gameEvent.Tags) then
        if (gameEvent.Tags[1]) then -- If the context tags are an array, convert to a map
            contextTags = {}
            for _, tag in ipairs(gameEvent.Tags) do
                contextTags[tag] = tag
            end
        else
            contextTags = gameEvent.Tags
        end
    end
    medalGameEvent.contextTags = contextTags

    return medalGameEvent
end
