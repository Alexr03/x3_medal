# x3_medal
This CFX Resource adds Medal integration support for your server. (Only tested on FiveM)

## Installation
1. Download the x3_medal resource from [Github](https://github.com/Alexr03/x3_medal/archive/refs/heads/master.zip)
2. Extract to your resources folder.
3. Ensure the resource in your server.cfg (`ensure x3_medal`)

## Configuration
### `config.lua`
You must setup some basic information first inside of the config file for Medal to correctly clip.

1. Commands
   You are free to leave these as default.
 ```lua
   Config.Commands = {
    ToggleUi = 'MedalUI', -- Command to toggle the Medal UI
    ClipNow = 'MedalClip', -- Command to clip now
    Reset = 'MedalReset' -- Command to reset the event settings
}
```

2. Game Context
   This is needed so Medal can correctly link the clips you create to your FiveM server. You can also add global tags here too.
```lua
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
```

3. Defaults
   These are some defaults that are used in Events if you did not set one in the event itself.
```lua
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
```

`config_events.lua`
You must set up some "Events" for your scripts to call when you want to clip something. Some are included in the file already.
```lua
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
```

## Usage
### Basic Usage
Invoke your `ClipNow` command in chat or F8. `/MedalClip`. This will tell Medal to clip the prior 30s.

### Advanced Usage

This resource only contains exports/events for you to utilize in your own scripts.
When you wish to invoke a clip for an event you have setup you can do the following:

Example:
 - Key of event in config_events: `PlayerKilled`

#### Server
`TriggerClientEvent('x3_medal:Invoke:PlayerKilled', source, additionalArgs)`
*You can also call this from the client side by using `TriggerEvent`*

#### Client
`exports.x3_medal:InvokePlayerKilled(additionalArgs)`

Both of the above examples will find the `PlayerKilled` data in your config and use the settings set there to build the request to send to Medal.

## Middleware
This resource supprots middleware, which basically means that you can hook onto an event being called and change the settings etc before they are set to medal. You can do this to increase the clip length, cancel the clip, add tags etc.
A few middleware snippets are included in the resource. 

### Middleware - Custom Tags
This middleware allows you to set custom tags for the clip when invoked.
```lua
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
```

Invoke example:
```lua
exports.x3_medal:PlayerKilled({Tags = {'Tag1', 'Tag2'}})
```

Output:
Will result in the Global Tags, Event Tags and Custom tags being sent to medal.

### Middleware - Dynamic Tags
This middleware will add #LowHealth as a tag on the clip if the players health was `< 20%` at the time of invocation.
```lua
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
```

