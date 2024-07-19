local function getEventExportName(configId, eventData)
    if (type(eventData.Invokes.Export) == "string") then
        return eventData.Invokes.Export
    end

    return 'Invoke' .. configId
end

local function getNetEventName(configId, eventData)
    if (type(eventData.Invokes.NetEvent) == "string") then
        return eventData.Invokes.NetEvent
    end

    return 'x3_medal:Invoke:' .. configId
end

local function deepCopyTable(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == 'table' then
            v = deepCopyTable(v)
        end
        copy[k] = v
    end
    return copy
end

local middlewares = {}

function RegisterMedalEvent(configId, eventData)
    local function invokeMedalWithEvent(data)
        Citizen.CreateThread(function()
            data = data or {}
            local eventDataClone = deepCopyTable(eventData)
            Logger:Debug('Invoking event: ', eventDataClone.EventName)
            local eventMiddlewares = GetMiddlewaresForEvent(eventDataClone.EventId)
            if (eventMiddlewares and #eventMiddlewares > 0) then
                for middlewareIndex, middleware in ipairs(eventMiddlewares) do
                    local proceed, modifiedEventData = middleware.cb(eventDataClone, data)

                    if (not proceed) then
                        Logger:Info(middlewareIndex, 'Middleware returned false, skipping event: ', eventDataClone.EventName)
                        return
                    end

                    if (modifiedEventData) then
                        if (type(modifiedEventData) ~= 'table') then
                            Logger:Error('Middleware returned an invalid type: ', type(modifiedEventData), ' for event: ', eventDataClone.EventName, 'expected table, skipping...')
                            goto nextMiddleware
                        end
                        eventDataClone = modifiedEventData
                    end

                    ::nextMiddleware::
                end
            end

            local clipOptions = eventDataClone.ClipOptions or Config.Defaults.ClipOptions
            if (clipOptions.PreLength > 1) then
                Logger:Debug('Delaying event: ', eventDataClone.EventName, ' for ', clipOptions.PreLength, ' seconds')
                Citizen.Wait(clipOptions.PreLength * 1000)
            end

            local medalGameEvent = ConvertToMedalGameEvent(eventDataClone)
            if (not medalGameEvent) then
                Logger:Error('Failed to convert event: ', eventDataClone.EventName, ' to MedalGameEvent')
                return
            end

            InvokeGameEventRaw(medalGameEvent)
        end)
    end

    if (eventData.Invokes.Export) then
        local exportName = getEventExportName(configId, eventData)
        exports(exportName, invokeMedalWithEvent)
        Logger:Trace('Exported event: ', exportName, ' for event: ' .. configId)
    end

    if (eventData.Invokes.NetEvent) then
        local eventName = getNetEventName(configId, eventData)
        RegisterNetEvent(eventName, invokeMedalWithEvent)
        Logger:Trace('Registered net event: ', eventName, ' for event: ' .. configId)
    end

    Logger:Info('Event setup: ' .. eventData.EventName)
end

function AddMiddleware(eventId, cb, order)
    local eventIds = {}
    if(type('eventId') == 'table') then
        eventIds = eventId
    else
        table.insert(eventIds, eventId)
    end

    for _, eventId in ipairs(eventIds) do
        if (not middlewares[eventId]) then
            middlewares[eventId] = {}
        end

        Logger:Debug('Adding middleware for event: ', eventId)

        table.insert(middlewares[eventId], {
            cb = cb,
            order = order or 0
        })

        table.sort(middlewares[eventId], function(a, b)
            return a.order < b.order
        end)
    end
end

function GetMiddlewaresForEvent(eventId)
    local eventMiddlewares = middlewares[eventId] or {}
    local globalMiddlewares = middlewares['*'] or {}

    local allMiddlewares = {}
    for _, middleware in ipairs(globalMiddlewares) do
        table.insert(allMiddlewares, middleware)
    end

    for _, middleware in ipairs(eventMiddlewares) do
        table.insert(allMiddlewares, middleware)
    end

    -- Sort by order
    table.sort(allMiddlewares, function(a, b)
        return a.order < b.order
    end)

    return allMiddlewares
end

Citizen.CreateThread(function()
    for configId, eventData in pairs(Config.Events) do
        RegisterMedalEvent(configId, eventData)
    end
end)
