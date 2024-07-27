--- STEAMODDED HEADER
--- MOD_NAME: Twitch Blinds
--- MOD_ID: TwitchBlinds
--- MOD_AUTHOR: [SleepyG11, Djynasty]
--- MOD_DESCRIPTION: Let your Twitch chat decide which new boss will end your run ;)

--- DISPLAY_NAME: Twitch Blinds
--- PREFIX: twbl
--- VERSION: 1.0.1-pre
----------------------------------------------
------------MOD CODE -------------------------

local nativefs = require("nativefs")
assert(load(nativefs.read(SMODS.current_mod.path .. "libs/utilities.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "libs/websocket.lua")))()
assert(load(nativefs.read(SMODS.current_mod.path .. "libs/collector.lua")))()

assert(load(nativefs.read(SMODS.current_mod.path .. "core/main.lua")))()

function SMODS.INIT.TwitchBlinds()
    TW_BL:init()
end

----------------------------------------------
------------MOD CODE END----------------------
