local mq = require('mq')
local utils = require('utils')
local commands = require('commands')
local gui = require('gui')
local spells = require('spells')
local healing = require('healing')
local res = require('res')
local nav = require('nav')
local buffer = require('buffer')

local DEBUG_MODE = false
-- Debug print helper function
local function debugPrint(...)
    if DEBUG_MODE then
        print(...)
    end
end

local class = mq.TLO.Me.Class()
if class ~= "Cleric" then
    print("This script is only for Clerics.")
    mq.exit()
end

local charLevel = mq.TLO.Me.Level() or 0

utils.PluginCheck()

mq.imgui.init('clericControlGUI', gui.clericControlGUI)

commands.init()
commands.initALL()

mq.event('ConsentError', 'You do not have consent to summon that corpse.', res.consentErrorCallback)

local startupRun = false

-- Function to check the botOn status and run startup once
local function checkBotOn(currentLevel)
    if gui.botOn and not startupRun then
        nav.setCamp()
        spells.startup(currentLevel)
        startupRun = true  -- Set flag to prevent re-running
        printf("Bot has been turned on. Running startup.")

        if gui.buffsOn then
            buffer.buffRoutine()
        end
    elseif not gui.botOn and startupRun then
        -- Optional: Reset the flag if bot is turned off
        startupRun = false
    end
end

-- Persistent toggle state to track changes in gui.botOn
local toggleboton = gui.botOn or false

local function returnChaseToggle()
    if gui.botOn and gui.returntocamp and not toggleboton then
        -- Run setCamp only once when gui.botOn is checked
        nav.setCamp()
        toggleboton = true
    elseif not gui.botOn and toggleboton then
        -- Run clearCamp only once when gui.botOn is unchecked
        nav.clearCamp()
        toggleboton = false
    end
end

while gui.clericControlGUI do

    returnChaseToggle()

    if gui.botOn then

        checkBotOn(charLevel)

        debugPrint("Checking for navigation.")
        utils.monitorNav()

        debugPrint("Checking for healing.")
        healing.healRoutine()

        if gui.useRez then
            debugPrint("Checking for resurrection.")
            utils.monitorRes()
        end

        if gui.sitMed then
            debugPrint("Checking for sit/med.")
            utils.sitMed()
        end

        if gui.useKarn then
            debugPrint("Checking for Karn's Touch.")
            utils.monitorAttack()
        end

        if gui.buffsOn then
            debugPrint("Checking for buffs.")
            utils.monitorBuffs()
        end

        if gui.useCures then
            debugPrint("Checking for cures.")
            utils.monitorCures()
        end

        local newLevel = mq.TLO.Me.Level()
        if newLevel ~= charLevel then
            printf(string.format("Cleric level has changed from %d to %d. Updating spells.", charLevel, newLevel))
            spells.startup(newLevel)
            charLevel = newLevel
        end
    end

    mq.doevents()
    mq.delay(100)
end