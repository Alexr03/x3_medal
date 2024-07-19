Citizen.CreateThread(function()
    AddMiddleware('*', function(eventData, additionalData) -- Middleware for all events, check if event is enabled, if not, skip
        local eventSettings = GetEventSetting(eventData.EventId)

        if (additionalData.BypassEventSettings) then
            Logger:Debug('Bypassing event settings for event: ', eventData.EventName)
            return true
        end

        if (eventSettings and eventSettings.ClipEnabled == false) then
            Logger:Debug('Event: ', eventData.EventName, ' has clips disabled, skipping...')
            return false
        end

        return true
    end, -1000)

    AddMiddleware('*', function(eventData, additionalData) -- Middleware for all events, check if sound is enabled, if not, disable sound
        local eventSettings = GetEventSetting(eventData.EventId)

        if (eventSettings and eventSettings.SoundEnabled == false) then
            Logger:Debug('Event: ', eventData.EventName, ' has sound disabled.')
            eventData.ClipOptions.AlertType = 'OverlayOnly'
        end

        return true, eventData
    end, -999)

    AddMiddleware('*', function(eventData, additionalData) -- Middleware for all events, add additional data tags to all events
        if (additionalData and additionalData.Tags and #additionalData.Tags > 0) then
            eventData.Tags = eventData.Tags or {}
            -- Merge the tags
            for _, tag in ipairs(additionalData.Tags) do
                Logger:Debug('Adding tag: ', tag)
                table.insert(eventData.Tags, tag)
            end

            return true, eventData
        end

        return true
    end, -990)

    AddMiddleware('player_killed', function(eventData, additionalData) -- Middleware for PlayerKilled event, add CloseCall tags if player is below 20% health
        -- Get player HP
        local playerPed = PlayerPedId()
        local playerHP = GetEntityHealth(playerPed)
        local maxHP = GetEntityMaxHealth(playerPed)

        local percentage = (playerHP / maxHP) * 100

        if (percentage < 20) then
            table.insert(eventData.Tags, 'LowHealth')
        end

        return true, eventData
    end, 50)
end)
