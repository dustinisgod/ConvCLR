local mq = require('mq')
local utils = require('utils')
local commands = require('commands')
local gui = require('gui')
local clericspells = require('clericspells')
local healing = require('healing')
local res = require('res')

local currentLevel = mq.TLO.Me.Level()

utils.PluginCheck()

mq.cmd("/plugin mq2cast load")

mq.imgui.init('clericControlGUI', gui.clericControlGUI)

commands.init()

mq.event('ConsentError', 'You do not have consent to summon that corpse.', res.consentErrorCallback)

clericspells.startup(currentLevel)


local startupRun = false

-- Function to check the botOn status and run startup once
local function checkBotOn(currentLevel)
    if gui.botOn and not startupRun then
        -- Run the startup function once
        clericspells.startup(currentLevel)
        startupRun = true  -- Set flag to prevent re-running
        printf("Bot has been turned on. Running clericspells.startup.")
    elseif not gui.botOn and startupRun then
        -- Optional: Reset the flag if bot is turned off
        startupRun = false
        printf("Bot has been turned off. Ready to run clericspells.startup again.")
    end
end

while gui.clericControlGUI do

    if gui.botOn then

        utils.monitorNav()

        healing.healRoutine()

        utils.monitorRes()

        utils.sitMed()

        utils.monitorAttack()

        utils.monitorBuffs()

        utils.monitorCures()

        checkBotOn(currentLevel)

        local newLevel = mq.TLO.Me.Level()
        if newLevel ~= currentLevel then
            printf(string.format("Cleric level has changed from %d to %d. Updating spells.", currentLevel, newLevel))
            clericspells.startup(newLevel)
            currentLevel = newLevel
        end
    end

    mq.doevents()
    mq.delay(100)
end