local mq = require('mq')
local clericspells = require('clericspells')
local utils = require('utils')
local gui = require('gui')

local cures = {}

-- Configuration
local cureCooldowns = {}  -- Track cooldowns for casting cures on members
local cureQueue = {}  -- Queue for curing members
local MAX_CURE_RETRIES = 3  -- Maximum retries for each cure attempt
local charLevel = mq.TLO.Me.Level()

local function isGroupMember(targetID)
    for i = 1, mq.TLO.Group.Members() do
        if mq.TLO.Group.Member(i).ID() == targetID then
            return true
        end
    end
    return false
end

-- Function to check if a target is afflicted and return the best cure spell
local function getCureSpell(afflictionType)
    if afflictionType == "Poison" then
        return clericspells.findBestSpell("CurePoison", charLevel)
    elseif afflictionType == "Disease" then
        return clericspells.findBestSpell("CureDisease", charLevel)
    end
end

-- Function to check if the cure spell is ready and mana is sufficient
local function preCureChecks(spellName)
    return not mq.TLO.Me.Moving() and not mq.TLO.Me.Casting() and mq.TLO.Me.PctMana() >= 20
end

-- Helper function: Check if we have enough mana to cast the spell
local function hasEnoughMana(spellName)
    if not spellName then return false end
    return mq.TLO.Me.CurrentMana() >= mq.TLO.Spell(spellName).Mana()
end

-- Check if target is within spell range, safely handling nil target
local function isTargetInRange(targetID, spellName)
    local target = mq.TLO.Spawn(targetID)
    local spellRange = mq.TLO.Spell(spellName).Range()

    -- Check if both target and spell range exist to avoid nil errors
    if target and target.Distance() and spellRange then
        return target.Distance() <= spellRange
    else
        return false  -- Return false if the target doesn't exist or range can't be determined
    end
end


local function queueAfflictedMembers()
    local clericLevel = mq.TLO.Me.Level()  -- Get cleric level once for all checks

    -- Loop through each group member
    for i = 1, mq.TLO.Group.Members() do
        local member = mq.TLO.Group.Member(i)
        local memberID = member and member.ID()

        if not memberID then
            goto continue
        end

        -- Target the member and check for poison or disease afflictions
        mq.cmdf('/target id %s', memberID)
        mq.delay(100)

        -- Only add to cureQueue if cleric meets the required level for each affliction
        if mq.TLO.Target.Poisoned() and clericLevel >= 22 then
            table.insert(cureQueue, {name = member.Name(), type = "Poison"})
        elseif mq.TLO.Target.Diseased() and clericLevel >= 4 then
            table.insert(cureQueue, {name = member.Name(), type = "Disease"})
        end

        ::continue::
    end

    -- Loop through each extended target slot if enabled in GUI
    for extIndex = 1, 5 do
        if gui["ExtTargetCure" .. extIndex] then
            local extTarget = mq.TLO.Me.XTarget(extIndex)
            local extID = extTarget and extTarget.ID()

            -- Only check if valid and not a group member
            if extID and not isGroupMember(extID) then
                mq.cmdf('/target id %s', extID)
                mq.delay(200)

                -- Only add to cureQueue if cleric meets the required level for each affliction
                if mq.TLO.Target.Poisoned() and clericLevel >= 22 then
                    table.insert(cureQueue, {name = extTarget.CleanName(), type = "Poison"})
                elseif mq.TLO.Target.Diseased() and clericLevel >= 4 then
                    table.insert(cureQueue, {name = extTarget.CleanName(), type = "Disease"})
                end
            end
        end
    end
end

-- Process the queue by affliction type using the cureQueue generated in queueAfflictedMembers
local function processCureQueueByType(afflictionType)
    if gui.botOn then
        for i = #cureQueue, 1, -1 do
            local entry = cureQueue[i]
            if entry.type == afflictionType then
                local memberName = entry.name
                local spell = getCureSpell(afflictionType)

                -- Target the member to check if they are still afflicted
                mq.cmdf('/target %s', memberName)
                mq.delay(200)  -- Short delay to ensure targeting is complete

                -- Verify if the target is still afflicted with the specific type
                local stillAfflicted = (afflictionType == "Poison" and mq.TLO.Target.Poisoned()) or 
                                       (afflictionType == "Disease" and mq.TLO.Target.Diseased())
                
                -- Remove from queue if no longer afflicted
                if not stillAfflicted then
                    table.remove(cureQueue, i)
                    goto continue  -- Skip to the next member if not afflicted
                end

                -- Proceed to cast if they are still afflicted
                if spell and preCureChecks(spell) then
                    -- Determine the gem slot based on the affliction type
                    local gemSlot = afflictionType == "Poison" and 6 or 7
                    
                    -- Memorize the spell if it is not already memorized in the correct slot
                    if mq.TLO.Me.Gem(gemSlot).Name() ~= spell then
                        clericspells.loadAndMemorizeSpell(afflictionType == "Poison" and "CurePoison" or "CureDisease", charLevel, gemSlot)
                    end

                    -- Wait for the spell to be ready
                    local maxReadyAttempts = 10
                    local readyAttempt = 0
                    while not mq.TLO.Me.SpellReady(spell)() and readyAttempt < maxReadyAttempts do
                        mq.delay(1000) -- Wait 1 second before checking again
                        readyAttempt = readyAttempt + 1
                    end
                    
                    if not mq.TLO.Me.SpellReady(spell)() then
                        break
                    end

                    -- Attempt to cure the member
                    local retryCount = 0
                    while retryCount < MAX_CURE_RETRIES do
                        if not hasEnoughMana(spell) then
                            break
                        elseif not isTargetInRange(memberName, spell) then
                            break
                        end

                        mq.cmdf('/target %s', memberName)
                        mq.delay(200)
                        if mq.TLO.Target.CleanName() == memberName then
                            -- Cast using the determined slot (6 for Poison, 7 for Disease)
                            mq.cmdf('/cast %d', gemSlot)
                            while mq.TLO.Me.Casting() do
                                mq.delay(50)
                            end
                            mq.delay(100)
                            cureCooldowns[memberName] = os.time()
                            table.remove(cureQueue, i)  -- Remove cured member from queue
                            break
                        else
                            retryCount = retryCount + 1
                        end
                    end
                end
            end
            ::continue::
        end
    end
end

-- Main function to monitor and cure afflicted members
function cures.curesRoutine()
    if gui.botOn then
        if gui.useCures then
            
            if mq.TLO.Me.PctMana() < 20 then
                utils.sitMed()
                return
            end

            -- Queue all afflicted members and randomize the queue
            queueAfflictedMembers()
            
            -- Process each affliction type in turn
            processCureQueueByType("Poison")
            processCureQueueByType("Disease")
        else
            mq.delay(50)
            return
        end
    end
end

return cures