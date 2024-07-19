function SetupMedal()
    local gameContext = ConvertToMedalGameContext()

    local events = {}
    for configId, gameEvent in pairs(Config.Events) do
        local eventSettings = GetEventSetting(gameEvent.EventId)
        if (not eventSettings) then
            Logger:Debug('Setting default settings for event: ', gameEvent.EventName)
            SetEventSetting(gameEvent.EventId, gameEvent.Defaults)
            eventSettings = gameEvent.Defaults
        end

        table.insert(events, {
            EventId = gameEvent.EventId,
            EventName = gameEvent.EventName,
            Settings = eventSettings,
            UISettings = gameEvent.UISettings
        })
    end

    SendNUIMessage({
        action = 'Setup',
        data = {
            PublicKey = Config.PublicKey,
            GameContext = gameContext,
            Events = events
        }
    })
end

function InvokeGameEventRaw(data)
    SendNUIMessage({
        action = 'InvokeGameEvent',
        data = data
    })
end

exports('InvokeGameEventRaw', InvokeGameEventRaw)

local isOpen = false
function OpenUI()
    Logger:Trace('Opening UI')
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'OpenUI'
    })
end

exports('OpenUI', OpenUI)

function CloseUI()
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'CloseUI'
    })
end

exports('CloseUI', CloseUI)

function ToggleUI()
    if isOpen then
        CloseUI()
    else
        OpenUI()
    end
end

exports('ToggleUI', ToggleUI)

RegisterNUICallback('Closed', function(data, cb)
    isOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

function GetEventSettings()
    local eventSettings = GetResourceKvpString('event_settings')
    if (eventSettings) then
        return json.decode(eventSettings)
    end

    return {}
end

exports('GetEventSettings', GetEventSettings)

function SetEventSettings(eventSettings)
    SetResourceKvp('event_settings', json.encode(eventSettings))
end

exports('SetEventSettings', SetEventSettings)

function GetEventSetting(eventId)
    local eventSettings = GetEventSettings()
    if (eventSettings) then
        Logger:Trace('EventSettings: ', eventId, json.encode(eventSettings[eventId] or {}))
        return eventSettings[eventId]
    end
end

exports('GetEventSetting', GetEventSetting)

function SetEventSetting(eventId, setting)
    local eventSettings = GetEventSettings() or {}
    eventSettings[eventId] = setting
    SetEventSettings(eventSettings)
end

exports('SetEventSetting', SetEventSetting)

RegisterNUICallback('EventSettingsChanged', function(body, cb)
    SetEventSetting(body.EventId, {
        ClipEnabled = body.ClipEnabled,
        SoundEnabled = body.SoundEnabled
    })

    cb('ok')
end)

RegisterNUICallback('SetUserInfo', function(body, cb)
    LocalPlayer.state:set('medal_active', true, true)
    LocalPlayer.state:set('medal_username', body.Username, true)
    LocalPlayer.state:set('medal_userid', body.UserId, true)

    cb('ok')
end)

RegisterNUICallback('ClipNow', function(body, cb)
    InvokeClipNow(30)

    cb('ok')
end)

function InvokeClipNow(duration)
    duration = duration or 30

    InvokeGameEventRaw({
        eventId = 'clip_now',
        eventName = 'Manual Clip Now',
        triggerActions = { 'SaveClip' },
        clipOptions = {
            duration = duration
        }
    })
end
