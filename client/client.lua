
Citizen.CreateThread(function ()
    Citizen.Wait(500)
    SetupMedal()
    Logger:Info('Medal Integration has been setup')
end)

if(Config.Commands.ClipNow) then
    RegisterCommand(Config.Commands.ClipNow, function (source, args, raw)
		length = tonumber(args[1]) or 30
        InvokeClipNow(length)
    end)
	TriggerEvent('chat:addSuggestion', '/'..string.lower(Config.Commands.ClipNow), 'Trigger Medal clip',{
		{ name = "length", help = "Clip length in seconds. Default 30" }
	})
end

if(Config.Commands.ToggleUi) then
    RegisterCommand(Config.Commands.ToggleUi, function (source, args, raw)
        ToggleUI()
    end)
	TriggerEvent('chat:addSuggestion', '/'..string.lower(Config.Commands.ToggleUi), 'Toggle Medal UI',{})
end

if(Config.Commands.Reset) then
    RegisterCommand(Config.Commands.Reset, function (source, args, raw)
        DeleteResourceKvp('event_settings')
        Logger:Warning('Event settings have been reset.')
        SetupMedal()
    end)
	TriggerEvent('chat:addSuggestion', '/'..string.lower(Config.Commands.Reset), 'Reset STRP Medal settings',{})
end
