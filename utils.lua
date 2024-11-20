local mq = require('mq')
local gui = require('gui')
local utils = {}
local nav = require('nav')
local attack = require('attack')

function utils.PluginCheck()
    if utils.IsUsingDanNet then
        if not mq.TLO.Plugin('mq2dannet') or not mq.TLO.Plugin('mq2dannet').IsLoaded() then
            printf("Plugin \ayMQ2DanNet\ax is required. Loading it now.")
            mq.cmd('/plugin mq2dannet noauto')
        end
        -- turn off fullname mode in DanNet if it's active
        if mq.TLO.DanNet and mq.TLO.DanNet.FullNames() then
            mq.cmd('/dnet fullnames off')
        end
    end
end

function utils.isInGroup()
    local inGroup = mq.TLO.Group() and (mq.TLO.Group.Members() or 0) > 0
    return inGroup
end

function utils.isInRaid()
    local inRaid = (mq.TLO.Raid.Members() or 0) > 0
    return inRaid
end

local lastCuresTime = 0

function utils.monitorCures()
    if gui.botOn then
        local cures = require('cures')
        if not gui then
            printf("Error: gui is nil")
            return
        end

        local currentTime = os.time()

        if (gui.useCures == true ) and (currentTime - lastCuresTime >= 10) then
            if mq.TLO.Me.PctMana() > 20 then
                cures.curesRoutine()
                lastCuresTime = currentTime
            end
        end
    end
end

local lastResTime = 0

function utils.monitorRes()
    if gui.botOn then
        local res = require('res')
        if not gui then
            printf("Error: gui is nil")
            return
        end

        local currentTime = os.time()

        if (gui.useRez == true ) and (currentTime - lastResTime >= 10) then
            if mq.TLO.Me.PctMana() > 20 then
                res.resRoutine()
                lastResTime = currentTime
            end
        end
    end
end

local lastBuffTime = 0

function utils.monitorBuffs()
    if gui.botOn then
        local buffer = require('buffer')
        if not gui then
            printf("Error: gui is nil")
            return
        end

        local currentTime = os.time()

        if (gui.achpBuff or
            gui.hpOnlyBuff or
            gui.acOnlyBuff or
            gui.resistMagic or
            gui.resistCold or
            gui.resistFire or
            gui.resistDisease or
            gui.resistPoison) and (currentTime >= lastBuffTime) then
            
            if mq.TLO.Me.PctMana() > 20 then
                buffer.buffRoutine()

                -- Set lastBuffTime to the current time + random interval
                local timedDelay = 120 -- Random delay between 240 and 600 seconds
                lastBuffTime = currentTime + timedDelay
            end
        end
    end
end

function utils.sitMed()
    if gui.botOn and gui.sitMed and mq.TLO.Me.PctMana() < 100 and not mq.TLO.Me.Mount() then
        local nearbyNPCs = mq.TLO.SpawnCount(string.format('npc radius %d', gui.assistRange))() or 0

        if mq.TLO.Me.PctHPs() < (gui.mainHealPct or 100) and nearbyNPCs > 0 then
            return
        end

        if nearbyNPCs == 0 or (mq.TLO.Me.PctHPs() >= (gui.mainHealPct or 100)) then
            if not mq.TLO.Me.Casting() and not mq.TLO.Me.Moving() then
                if not mq.TLO.Me.Sitting() then
                    mq.cmd('/sit')
                    mq.delay(100)
                end
            end
        end
    end
end

local lastNavTime = 0

local campSet = false  -- Track if camp is set

function utils.monitorNav()

    -- Additional camp distance or chase check if bot is on
    if gui.botOn then
        if not gui then
            printf("Error: gui is nil")
            return
        end

        local currentTime = os.time()

        if gui.returntocamp and (currentTime - lastNavTime >= 5) then
            nav.checkCampDistance()
            lastNavTime = currentTime
        elseif gui.chaseOn then
            nav.chase()
        end
    end
end


local lastAttackTime = 0

function utils.monitorAttack()
    if gui.botOn then
        if not gui then
            printf("Error: gui is nil")
            return
        end

        local currentTime = os.time()

        if gui.useKarn and currentTime >= lastAttackTime then
            attack.attackRoutine()

        local randomDelay = math.random(1, 5)
        lastAttackTime = currentTime + randomDelay
        end
    end
end

function utils.setMainAssist(charName)
    if charName and charName ~= "" then
        -- Remove spaces, numbers, and symbols
        charName = charName:gsub("[^%a]", "")
        
        -- Capitalize the first letter and make the rest lowercase
        charName = charName:sub(1, 1):upper() .. charName:sub(2):lower()

        -- Check if the cleaned and formatted name matches a valid PC
        local spawn = mq.TLO.Spawn(charName)
        if spawn and spawn.Type() == "PC" then
            gui.mainAssist = charName
        end
    end
end

return utils