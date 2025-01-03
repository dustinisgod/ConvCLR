local mq = require('mq')
local gui = require('gui')
local spells = require('spells')
local healing = require('healing')
local utils = require('utils')

local res = {}
res.resQueue = {}

local inRaid, inGroup = mq.TLO.Raid.Members() > 0, mq.TLO.Me.Grouped()
local rezDistance = 5  -- Final distance to attempt rez
local dragDistance = 100         -- Distance to start dragging corpses towards us
local resCooldown = {}  -- Track corpses on cooldown
local consentEvent = false  -- Flag to check if an event was processed
local charName = mq.TLO.Me.Name()
local charLevel = mq.TLO.Me.Level() or 0

local function preCastChecks()
    if mq.TLO.Me.Moving() or mq.TLO.Me.Casting() then
        return false
    elseif mq.TLO.Me.Combat() and not gui.combatRez then
        return false
    end
    return true
end

local function hasEnoughMana(spellName)
    if gui.useEpic == true then
        return true
    else
        if not spellName then
            return false
        elseif mq.TLO.Me.CurrentMana() < mq.TLO.Spell(spellName).Mana() then
            return false
        else
            return true
        end
    end
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

-- Helper function to validate a corpse for rez
local function validateCorpseForRez(corpse)
    return corpse and corpse.ID() and corpse.X() and corpse.Y()
end

-- Check if a corpse belongs to a group or raid member
local function isCorpseEligibleForRez(corpse, inRaid, inGroup)
    local corpseName = corpse.CleanName()
    local corpseSuffix = "'s corpse"
    
    if corpseName == charName .. corpseSuffix then
        return true
    end

    if inRaid then
        local raidSize = mq.TLO.Raid.Members() or 0
        for i = 1, raidSize do
            if mq.TLO.Raid.Member(i).Name() .. corpseSuffix == corpseName then
                return true
            end
        end
    end

    if inGroup and not inRaid then
        local groupSize = mq.TLO.Group.Members() or 0
        for i = 1, groupSize do
            if mq.TLO.Group.Member(i).Name() .. corpseSuffix == corpseName then
                return true
            end
        end
    end

    return false
end

-- Helper function to check if a corpse is on cooldown
local function isOnCooldown(corpseName)
    if resCooldown[corpseName] then
        local timeElapsed = os.time() - resCooldown[corpseName]
        if timeElapsed < 240 then
            return true
        else
            resCooldown[corpseName] = nil  -- Remove from cooldown if time has passed
        end
    end
    return false
end

local function shuffleQueue(queue)
    for i = #queue, 2, -1 do
        local j = math.random(1, i)
        queue[i], queue[j] = queue[j], queue[i]
    end
end

local function queueRez(corpse, resSpell)
    local corpseName = corpse.CleanName()
    if validateCorpseForRez(corpse) and not res.resQueue[corpse.ID()] and not isOnCooldown(corpseName) then
        table.insert(res.resQueue, {corpse = corpse, spell = resSpell, slot = 10})
        shuffleQueue(res.resQueue) -- Shuffle the queue after adding the corpse
    elseif isOnCooldown(corpseName) then
        return
    end
end

-- Function to handle the heal routine and return
local function handleHealRoutineAndReturn()
    healing.healRoutine()
    utils.monitorNav()
    return true -- Assuming heal routine passes, return to continue buffing
end

function res.consentErrorCallback(line)
    consentEvent = true  -- Set the flag to indicate the event was triggered
end

-- Process the rez queue with event checking
local function processRezQueue()
    if gui.botOn then
        while #res.resQueue > 0 do
            if gui.botOn then
                -- Check if the useRez checkbox is still enabled
                if not gui.useRez then
                    return  -- Exit the rez processing if useRez is unchecked
                end

                local resTask = table.remove(res.resQueue, 1)
                local corpse = resTask.corpse
                local resSpell = resTask.spell
                local corpseName = corpse.CleanName()

                -- Check if the corpse is on cooldown
                if resCooldown[corpseName] then
                    local timeElapsed = os.time() - resCooldown[corpseName]
                    if timeElapsed < 120 then  -- 120 seconds cooldown
                        mq.delay(100)
                        goto continue  -- Skip to the next corpse in the queue
                    else
                        resCooldown[corpseName] = nil  -- Remove from cooldown if time has passed
                    end
                end

                if validateCorpseForRez(corpse) and preCastChecks() then
                    if not gui.useEpic then
                        if not hasEnoughMana(resSpell) then
                            utils.sitMed()
                            return
                        end
                    end

                    local retryAttempts = 3  -- Set maximum retries for each member
                    local success = false    -- Track if rez is successful
            
                    for attempt = 1, retryAttempts do
                        -- Exit loop if gui.useRez becomes unchecked mid-rez
                        if not gui.useRez then
                            return
                        end

                        local maxReadyAttempts = 20
                        local readyAttempt = 0

                        if not gui.useEpic then
                            while not mq.TLO.Me.SpellReady(resTask.spell)() and readyAttempt < maxReadyAttempts do
                                readyAttempt = readyAttempt + 1
                                    if gui.mainHeal or gui.fastHeal or gui.completeHeal then
                                        if not handleHealRoutineAndReturn() then
                                            return
                                        end
                                    end
                                mq.delay(1000)  -- Wait 1 second before checking again
                            end

                            if not mq.TLO.Me.SpellReady(resTask.spell)() then
                                break
                            end
                        end

                        local nearbyCorpses = mq.TLO.SpawnCount('pccorpse radius ' .. dragDistance)()
                        if nearbyCorpses == 0 then
                            return
                        end

                        if not corpse and not isCorpseEligibleForRez(corpse, inRaid, inGroup) then
                            return
                        end

                        mq.cmdf('/tar id %d', corpse.ID())
                        mq.delay(200)

                        if mq.TLO.Target() and mq.TLO.Target.CleanName() == corpseName then
                            -- Retry loop for dragging the corpse
                            local dragAttempts = 0
                            local maxDragAttempts = 3
                            while dragAttempts < maxDragAttempts do
                                if mq.TLO.Target() and mq.TLO.Target.Distance() then
                                    if mq.TLO.Target.Distance() > rezDistance and mq.TLO.Target.Distance() <= dragDistance then
                                        mq.cmd('/corpse')
                                        mq.delay(500)
                                    end

                                

                                    -- Process events and check if the consent error occurred
                                    consentEvent = false  -- Reset flag before processing events
                                    mq.doevents()
                                    
                                    if consentEvent then
                                        local memberName = string.gsub(corpseName, "'s corpse$", "")
                                        mq.cmdf('/dgtell All "Error: %s does not have consent to summon %s. Consent ME!"', charName, corpseName)
                                        mq.cmdf('/dexecute %s /consent %s', memberName, charName)
                                        mq.delay(1000)
                                        dragAttempts = dragAttempts + 1  -- Increment attempt count

                                        if dragAttempts >= maxDragAttempts then
                                            resCooldown[corpseName] = os.time()
                                            break  -- Exit drag retry loop after max attempts
                                        end
                                    else
                                        -- Drag was successful, exit drag retry loop
                                        break
                                    end
                                else
                                    -- Exit drag retry loop if corpse is out of drag range
                                    break
                                end
                            end

                            -- If we reached the maximum drag attempts with eventTriggered, move to the next corpse
                            if consentEvent then
                                consentEvent = false
                                break
                            end

                            -- Proceed with rez if within rezDistance
                            if not isTargetInRange(corpseName, resSpell) then
                                break
                            end

                            mq.cmdf('/dgtell All "Resurrecting corpse: %s"', corpseName)

                            if gui.useEpic then
                                mq.cmd('/useitem "Water Sprinkler of Nem Ankh"')
                                while mq.TLO.Me.Casting() do
                                    mq.delay(500)
                                end
                            else
                                mq.cmdf('/cast %s', resTask.spell)
                                while mq.TLO.Me.Casting() do
                                    mq.delay(200)
                                end
                            end
                            mq.cmdf('/dgtell All "Resurrected corpse: %s"', corpseName)
                            
                            resCooldown[corpseName] = os.time()  -- Add to cooldown after successful rez
                            success = true  -- Mark rez as successful
                            mq.delay(50)

                            mq.cmd('/target clear')
                            mq.delay(100)

                            if gui.mainHeal or gui.fastHeal or gui.completeHeal then
                                if not handleHealRoutineAndReturn() then
                                    return
                                end
                            end
                        end
                    end
                end

                ::continue::  -- Label to skip to the next corpse if needed
                mq.delay(100)
            end
        end
    end
end

-- Main function to check nearby corpses and queue rezs
function res.resRoutine()
    charLevel = mq.TLO.Me.Level()
    if gui.botOn then
        if not gui.useRez or charLevel < 12 then
            return
        end

        local bestResSpell = spells.findBestSpell("Rez", charLevel)

        if not gui.useEpic then
            if not bestResSpell then
                return
            elseif mq.TLO.Me.PctMana() < 20 then
                utils.sitMed()
                return
            end
        end

        -- Check for nearby corpses before loading the spell
        local nearbyCorpses = mq.TLO.SpawnCount('pccorpse radius ' .. dragDistance)()
        if nearbyCorpses == 0 then
            return
        end

        -- Load the rez spell if it is not already loaded in Gem 8
        if tostring(mq.TLO.Me.Gem(8)) ~= bestResSpell and not gui.useEpic then
            spells.loadAndMemorizeSpell("Rez", charLevel, 8)
        end

        -- Queue eligible corpses for rez
        local resurrectCount = 0
        for i = 1, nearbyCorpses do
            local corpse = mq.TLO.NearestSpawn(i .. ',pccorpse radius ' .. dragDistance)
            if corpse and isCorpseEligibleForRez(corpse, inRaid, inGroup) then
                queueRez(corpse, bestResSpell)
                resurrectCount = resurrectCount + 1
            end
        end

        -- Process the rez queue if any corpses were added
        if resurrectCount > 0 then
            processRezQueue()
        else
        end
    end
end

function res.manualRez(playerName)
    -- Check if playerName was provided
    if not playerName then
        return
    end

    -- Check if character level is high enough for rez
    if charLevel < 12 then
        return
    end

    -- Find the best available rez spell based on cleric level
    local bestResSpell = spells.findBestSpell("Rez", charLevel)
    if not bestResSpell then
        return
    end

    -- Check for sufficient mana
    if mq.TLO.Me.CurrentMana() < mq.TLO.Spell(bestResSpell).Mana() then
        return
    end

    -- Append "'s corpse" to playerName to target the correct corpse
    local corpseName = playerName .. "'s corpse"

    -- Locate the target corpse by constructed name within spell range
    local corpse = mq.TLO.NearestSpawn('pccorpse "' .. corpseName .. '"')
    if corpse and corpse.ID() then
        -- Target the corpse by ID and confirm in range
        mq.cmdf('/tar id %d', corpse.ID())
        mq.delay(200)

        local targetName = mq.TLO.Target.CleanName() or "nil"

        -- Comparison ignoring case and special characters
        if targetName:lower():gsub("'", "") == corpseName:lower():gsub("'", "") then
            local spellRange = mq.TLO.Spell(bestResSpell).Range()

            if corpse.Distance() <= spellRange then
                -- Cast rez spell
                mq.cmdf('/cast "%s"', bestResSpell)
                mq.delay(200)
                while mq.TLO.Me.Casting() do
                    mq.delay(200)
                end
            end
        end
    end
end

return res