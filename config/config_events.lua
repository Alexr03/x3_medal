Config.Events = {
    PlayerKilled = {                                       -- The unique identifier for the event, will be used for event/export names
        EventId = 'player_killed',                         -- The unique identifier for the event (for medal to identify the event)
        EventName = 'Player Killed',                       -- The name of the event as it appears in the Medal UI
        TriggerActions = { TriggerActions.SaveClip },      -- What actions to trigger when this event is called
        Defaults = {                                       -- Toggle defaults for this event (Users can enable/disable clips from being created via the UI)
            ClipEnabled = true,                            -- Create a clip from this event
            SoundEnabled = false                           -- Play the clip sound when this event is triggered
        },
        UISettings = {                                     -- Settings for the UI
            Name = 'Player Killed',                        -- The name of the event as it appears in the Ingame UI
            Description = 'Occurs when you kill a player', -- The description of the event as it appears in the Ingame UI
            Visible = true,                                -- Show this event in the Ingame UI for the user to enable/disable
            Order = 1                                      -- The order in which the event appears in the Ingame UI
        },
        ClipOptions = {                                    -- Options for the clip
            PreLength = 10,                                -- Length of the clip prior to the event being invoked
            PostLength = 3                                 -- Length of the clip after the event being invoked
        },
        Tags = { 'Kills' },                                -- Tags to add to the event, will automatically add as hashtags.
        Invokes = {
            Export = true,                                 -- Create a export for this event
            NetEvent = true                                -- Create a net event for this event
        }
    },
    PlayerDied = {
        EventId = 'player_died',
        EventName = 'Player Died',
        TriggerActions = { TriggerActions.SaveClip },
        Defaults = {
            ClipEnabled = true,
            SoundEnabled = false
        },
        UISettings = {
            Name = 'Player Died',
            Description = 'Occurs when you die',
            Visible = true,
            Order = 2
        },
        ClipOptions = {
            PreLength = 5,
            PostLength = 5
        },
        Tags = { 'Death' },
        Invokes = {
            Export = true,
            NetEvent = true
        }
    },
    FallOutOfVehicle = {
        EventId = 'fall_out_of_vehicle',
        EventName = 'Fallen Out of Vehicle',
        TriggerActions = { TriggerActions.SaveClip },
        Defaults = {
            ClipEnabled = true,
            SoundEnabled = false
        },
        UISettings = {
            Name = 'Fallen Out of Vehicle',
            Description = 'Occurs when you fall out of a vehicle, e.g. no seatbelt',
            Visible = true,
            Order = 3
        },
        ClipOptions = {
            PreLength = 5,
            PostLength = 5
        },
        Tags = { 'SeatbeltCheck', 'Vehicle' },
        Invokes = {
            Export = true,
            NetEvent = true
        }
    },
    Handcuffed = {
        EventId = 'handcuffed',
        EventName = 'Handcuffed',
        TriggerActions = { TriggerActions.SaveClip },
        Defaults = {
            ClipEnabled = true,
            SoundEnabled = false
        },
        UISettings = {
            Name = 'Handcuffed',
            Description = 'Occurs when you are handcuffed/zipped tied',
            Visible = true,
            Order = 3
        },
        ClipOptions = {
            PreLength = 5,
            PostLength = 5
        },
        Tags = { 'Handcuffed', 'Arrest' },
        Invokes = {
            Export = true,
            NetEvent = true
        }
    }
}
