TriggerActions = {
    SaveClip = 'SaveClip',
    SaveScreenshot = 'SaveScreenshot',
}

Config = {}
Config.LoggingLevel = 1

Config.PublicKey = ''

Config.Commands = {
    ToggleUi = 'MedalUI', -- Command to toggle the Medal UI
    ClipNow = 'MedalClip', -- Command to clip now
    Reset = 'MedalReset' -- Command to reset the event settings
}

-- https://docs.medal.tv/gameapi.html#submit-context
Config.GameContext = {
    ServerId = 'n446av', -- Unique identifier for the server
    ServerName = 'Space Turtles EU', -- Name of the server
    CustomStatus = nil, -- Custom status to show within Medal
    GlobalContextTags = { -- Converted into hashtags on all clips (key is irrelevant, value is the tag)
        Game = 'fivem',
        Game2 = 'gta5',
        Server = 'strp',
        ServerRegion = 'strpeurope',
    },
    GlobalContextData = { -- Invisible data on the clip (maybe used internally by Medal)
        JoinUrl = 'https://cfx.re/join/n446av'
    }
}

Config.Defaults = { -- Defaults that are used when a event is missing a value
    ClipOptions = { -- Default clip options, used when a event is missing clip options.
        -- Lengths are in seconds, the total of the pre and post length will be the total length of the clip.
        -- E.G. <15s Pre buffer> + <Event Triggered> + <15s Post buffer> = 30s clip
        PreLength = 15, -- Default pre length of a clip, how much to grab before the event was invoked.
        PostLength = 15, -- Default post length of a clip, how much to grab after the event was invoked.
        AlertType = 'Default' -- Default alert type; Default, Disabled, SoundOnly, OverlayOnly
    },
    TriggerActions = {
        TriggerActions.SaveClip -- Default trigger action, SaveClip
    }
}

Logger = LoggerFactory.Create('Medal Integration', Config.LoggingLevel)
