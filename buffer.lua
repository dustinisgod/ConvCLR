local mq = require('mq')
local spells = require('spells')
local healing = require('healing')
local gui = require('gui')
local utils = require('utils')

local buffer = {}
buffer.buffQueue = {}

local charLevel = mq.TLO.Me.Level() or 0

local DEBUG_MODE = false
-- Debug print helper function
local function debugPrint(...)
    if DEBUG_MODE then
        print(...)
    end
end

-- Define which classes are eligible for each buff type
local buffEligibleClasses = {
    buffaegis = {ALL = true},
    buffshield = {ALL = true},
    buffsymbol = {ALL = true},
    buffmagic = {ALL = true},
    bufffire = {ALL = true},
    buffcold = {ALL = true},
    buffdisease = {ALL = true},
    buffpoison = {ALL = true},
}

-- Helper function to check if a class is eligible for a specific buff type
local function isClassEligibleForBuff(buffType, classShortName)
    local eligibleClasses = buffEligibleClasses[buffType]
    return eligibleClasses and (eligibleClasses[classShortName] or eligibleClasses["ALL"])
end

-- Helper function: Pre-cast checks for combat, movement, and casting status
local function preCastChecks()
    local check = not (mq.TLO.Me.Moving() or mq.TLO.Me.Combat() or mq.TLO.Me.Casting())
    debugPrint("DEBUG: preCastChecks result:", check)
    return check
end

-- Helper function: Check if we have enough mana to cast the spell
local function hasEnoughMana(spellName)
    local enoughMana = spellName and mq.TLO.Me.CurrentMana() >= mq.TLO.Spell(spellName).Mana()
    debugPrint("DEBUG: Checking mana for spell:", spellName, "Result:", enoughMana)
    return enoughMana
end

-- Check if target is within spell range, safely handling nil target and range values
local function isTargetInRange(targetID, spellName)
    local target = mq.TLO.Spawn(targetID)
    local spell = mq.TLO.Spell(spellName)
    
    -- Check for spell range; if not available, use AERange
    local spellRange = spell and spell.Range() or 0
    if spellRange == 0 or spellRange == nil then
        spellRange = spell.AERange() or 0
    end

    -- Validate target and distance, then check if target is within range
    local inRange = target and mq.TLO.Target.LineOfSight() and target.Distance() and (target.Distance() <= spellRange)
    
    -- Improved debug message to handle nil cases
    debugPrint(
        "DEBUG: Target range check for ID:", targetID, 
        " Spell:", spellName, 
        " with Range:", spellRange or "nil", 
        " In Range:", inRange or false
    )

    return inRange
end

-- Function to handle the heal routine and return
local function handleHealRoutineAndReturn()
    healing.healRoutine()
    utils.monitorNav()
    return true
end

-- Helper function to shuffle a table
local function shuffleTable(t)
    for i = #t, 2, -1 do
        local j = math.random(1, i)
        t[i], t[j] = t[j], t[i]
    end
    debugPrint("DEBUG: Shuffled buffQueue order")
end

function buffer.buffRoutine()
    charLevel = mq.TLO.Me.Level()
    debugPrint("DEBUG: Entering buffRoutine")

    if not (gui.botOn and gui.buffsOn) then
        debugPrint("DEBUG: Bot or Buff is off. Exiting buffRoutine.")
        return
    end

    if not preCastChecks() then
        debugPrint("DEBUG: Pre-cast checks failed. Exiting buffRoutine.")
        return
    end

    if mq.TLO.Me.PctMana() < 20 then
        debugPrint("DEBUG: Mana below threshold. Exiting buffRoutine.")
        if gui.sitMed then
            utils.sitMed()
        end
        return
    elseif mq.TLO.Me.PctMana() > 20 and mq.TLO.Me.PctMana() < 99 then
        if gui.sitMed then
            utils.sitMed()
        end
    end

    buffer.buffQueue = {}  -- Clear previous queue
    local queuedBuffs = {}  -- Track buffs already queued for each member

    -- Determine which buffs to apply based on GUI settings
    -- Initialize spellTypes for buffs to cast on group members
    local spellTypes = {}

    if gui.buffaegis and charLevel >= 58 then table.insert(spellTypes, "buffaegis") end
    if gui.buffsymbol and (charLevel < 58 or charLevel >= 58 and gui.buffdruidskin) then table.insert(spellTypes, "buffsymbol") end
    if gui.buffshield and (charLevel < 58 or charLevel >= 58 and gui.buffdruidskin) then table.insert(spellTypes, "buffshield") end

    -- Add group-wide buffs to spellTypes
    if gui.buffmagic then table.insert(spellTypes, "buffmagic") end
    if gui.bufffire then table.insert(spellTypes, "bufffire") end
    if gui.buffcold then table.insert(spellTypes, "buffcold") end
    if gui.buffdisease then table.insert(spellTypes, "buffdisease") end
    if gui.buffpoison then table.insert(spellTypes, "buffpoison") end

    -- Collect group or raid members based on GUI settings
    local groupMembers = {}

    if gui.buffGroup then
        -- Loop through all members, including self (member 0)
        local groupSize = mq.TLO.Group.Members() or 0
    
        for i = 0, groupSize do -- Start from 0 to include self
            local member = mq.TLO.Group.Member(i)
            local memberID = member and member.ID()
    
            if memberID and memberID > 0 and not (member.Dead() or false) then
                table.insert(groupMembers, memberID)
                debugPrint("DEBUG: Added group member with ID:", memberID)
            else
                debugPrint("DEBUG: Skipping invalid or dead group member with ID:", memberID or "nil")
            end
        end
    end

    if gui.buffRaid then
        for i = 1, mq.TLO.Raid.Members() do
            local member = mq.TLO.Raid.Member(i)
            local memberID = member and member.ID()

            -- Only add the member if they are valid, alive, and not the player
            if memberID and memberID > 0 and not member.Dead() then
                table.insert(groupMembers, memberID)
            else
                debugPrint("DEBUG: Skipping invalid or dead raid member with ID:", memberID or "nil")
            end
        end
    end

    -- Target each member, check missing buffs, and build the queue
    for _, memberID in ipairs(groupMembers) do
        if not (gui.botOn and gui.buffsOn) then
            debugPrint("DEBUG: Bot or Buff turned off during buff processing. Exiting buffRoutine.")
            return
        end

        debugPrint("DEBUG: Targeting member ID:", memberID)
        mq.cmdf("/tar id %d", memberID)
        mq.delay(400)

        if not mq.TLO.Target() or mq.TLO.Target.ID() ~= memberID then
            debugPrint("DEBUG: Targeting failed for member ID:", memberID)
            break
        end

        local classShortName = mq.TLO.Target.Class.ShortName()
        queuedBuffs[memberID] = queuedBuffs[memberID] or {}

        -- Check each buff type for the current member and add all missing buffs to the queue
        for _, spellType in ipairs(spellTypes) do
            local bestSpell = spells.findBestSpell(spellType, charLevel)

            if bestSpell and isClassEligibleForBuff(spellType, classShortName) then
                debugPrint("DEBUG: Best spell for", spellType, "is:", bestSpell)
                -- Check if the buff will stack on the target
                if mq.TLO.Spell(bestSpell).StacksTarget() then
                    debugPrint("DEBUG: Checking buff", spellType, "for member ID", memberID, "with spell:", bestSpell)
                    -- Only queue the buff if it is missing and not already queued for this member
                    if not mq.TLO.Target.Buff(bestSpell)() then
                        debugPrint("DEBUG: Buff", spellType, "missing for member ID", memberID)
                        if not queuedBuffs[memberID][spellType] then
                            debugPrint("DEBUG: Adding member ID", memberID, "to buffQueue for spell type:", spellType)
                            table.insert(buffer.buffQueue, {memberID = memberID, spell = bestSpell, spellType = spellType})
                            queuedBuffs[memberID][spellType] = true -- Mark buff as queued for this member
                        else
                            debugPrint("DEBUG: Buff", spellType, "already queued for member ID", memberID, ". Skipping.")
                        end
                    else
                        debugPrint("DEBUG: Buff", spellType, "already active for member ID", memberID, ". Skipping.")
                    end
                else
                    debugPrint("DEBUG: Buff", spellType, "does not stack for member ID", memberID, ". Skipping.")
                end
            end
        end

        if gui.botOn then
            if not handleHealRoutineAndReturn() then return end
        end
        mq.delay(100)  -- Delay between each member to reduce targeting interruptions
    end

    -- Only run processBuffQueue if there are entries in buffer.buffQueue
    if gui.botOn and gui.buffsOn then
        if #buffer.buffQueue > 0 then
            debugPrint("DEBUG: Buffs needed, running processBuffQueue.")
            buffer.processBuffQueue()
        else
            debugPrint("DEBUG: No buffs needed, skipping processBuffQueue.")
            return
        end
    end
end

function buffer.processBuffQueue()
    -- Define slots for each buff type
    local spellSlots = {
        buffaegis = 8,
        buffshield = 8,
        buffsymbol = 8,
        buffmagic = 8,
        bufffire = 8,
        buffcold = 8,
        buffdisease = 8,
        buffpoison = 8,
    }

    -- Group buff tasks by spell type
    local groupedQueue = {}
    for _, buffTask in ipairs(buffer.buffQueue) do
        local spellType = buffTask.spellType
        if not groupedQueue[spellType] then
            groupedQueue[spellType] = {}
        end
        debugPrint("DEBUG: Adding buff task to groupedQueue for spell type:", spellType)
        table.insert(groupedQueue[spellType], buffTask)
    end

    -- Process each group of tasks by spell type
    for spellType, tasks in pairs(groupedQueue) do

        if not gui[spellType] then
            debugPrint("DEBUG: Buff type", spellType, "is no longer enabled. Removing from queue.")
            groupedQueue[spellType] = nil
        else
            shuffleTable(tasks)  -- Randomize the order of tasks
            local spell = tasks[1].spell
            local slot = spellSlots[spellType]  -- Get the designated slot for this buff type

            -- Check if the spell is already memorized in the designated slot
            local isSpellLoadedInSlot = mq.TLO.Me.Gem(slot)() == spell

            if not isSpellLoadedInSlot then
                debugPrint("DEBUG: Loading spell for type: ", spellType, " Spell:", spell, " in slot: ", slot)
                spells.loadAndMemorizeSpell(spellType, charLevel, slot)
            else
                debugPrint("DEBUG: Spell", spell, "is already loaded in slot ", slot, ". Skipping load.")
            end

            -- Set a retry count to avoid infinite loops on failed buffs
            local retryLimit = 2

            -- Process each task for this spell type across all members
            for _, task in ipairs(tasks) do
                local memberID = task.memberID
                local retries = 0
                local buffApplied = false

                if mq.TLO.Me.PctMana() < 20 then
                    debugPrint("DEBUG: Mana below threshold. Exiting buffRoutine.")
                    if gui.sitMed then
                        utils.sitMed()
                    end
                    return
                end

                -- Define a table mapping spell types to their corresponding GUI flags
                local spellGuiFlags = {
                    buffaegis = gui.buffaegis,
                    buffshield = gui.buffshield,
                    buffsymbol = gui.buffsymbol,
                    buffmagic = gui.buffmagic,
                    bufffire = gui.bufffire,
                    buffcold = gui.buffcold,
                    buffdisease = gui.buffdisease,
                    buffpoison = gui.buffpoison,
                }

                -- Unified check for general conditions
                if not (gui.botOn and gui.buffsOn) then
                    debugPrint("DEBUG: Bot or Buff turned off during processBuffQueue.")
                    return
                end

                -- Check if the specific spell type is enabled in the GUI
                if not spellGuiFlags[spellType] then
                    debugPrint("DEBUG: Specific buff type", spellType, "turned off during processBuffQueue.")
                    break
                end

                while retries < retryLimit and not buffApplied do
                    -- Check if bot or buff is turned off during processing
                    if not (gui.botOn and gui.buffsOn) then
                        debugPrint("DEBUG: Bot or Buff turned off during processBuffQueue.")
                        return
                    end

                    debugPrint("DEBUG: Targeting member ID:", memberID)
                    mq.cmdf('/tar id %d', memberID)
                    mq.delay(300)

                    if not mq.TLO.Target() or mq.TLO.Target.ID() ~= memberID then
                        debugPrint("DEBUG: Targeting failed for member ID:", memberID)
                        break
                    end

                    -- Check if the target already has the buff
                    if mq.TLO.Target.Buff(spell)() then
                        debugPrint("DEBUG: Target already has buff. Skipping member ID:", memberID)
                        buffApplied = true  -- No need to re-queue
                        break
                    end

                    -- Ensure enough mana
                    if not hasEnoughMana(spell) then
                        debugPrint("DEBUG: Not enough mana for spell:", spell)
                        if gui.sitMed then
                            utils.sitMed()
                        end
                        break
                    end

                    if not isTargetInRange(memberID, spell) then
                        debugPrint("DEBUG: Target out of range for spell:", spell)
                        break
                    end

                    local maxReadyAttempts = 20
                    local readyAttempt = 0
                    while not mq.TLO.Me.SpellReady(spell)() and readyAttempt < maxReadyAttempts do
                        if not (gui.botOn and gui.buffsOn) then
                            debugPrint("DEBUG: Bot or Buff setting turned off, exiting processBuffQueue.")
                            return
                        end
                        readyAttempt = readyAttempt + 1
                        debugPrint("DEBUG: Waiting for buff spell to be ready, attempt:", readyAttempt)
                        mq.delay(500)
                    end

                    if mq.TLO.Me.SpellReady(spell)() then
                        debugPrint("DEBUG: Casting buff spell:", spell, "on member ID:", memberID)
                        mq.cmdf('/cast %d', slot)
                        mq.delay(200)
                    end

                    -- Check casting status
                    while mq.TLO.Me.Casting() do
                        if mq.TLO.Target.Buff(spell)() or not (gui.botOn and gui.buffsOn) then
                            debugPrint("DEBUG: Buff applied or bot/buff turned off. Exiting processBuffQueue.")
                            mq.cmd('/stopcast')
                            break
                        elseif mq.TLO.Target.ID() ~= memberID then
                            if spell.Range and spell.Range ~= "0" and mq.TLO.Target.Distance() > spell.Range then
                                debugPrint("DEBUG: Target out of range. Stopping cast.")
                                mq.cmd('/stopcast')
                                break
                            elseif spell.AERange and spell.AERange ~= "0" and mq.TLO.Target.Distance() > spell.AERange then
                                debugPrint("DEBUG: Target out of AErange. Stopping cast.")
                                mq.cmd('/stopcast')
                                break
                            end
                        end
                        mq.delay(50)
                    end

                    mq.delay(100)
                    if mq.TLO.Target.Buff(spell)() then
                        debugPrint("DEBUG: Buff successfully applied to member ID:", memberID)
                        buffApplied = true
                    else
                        debugPrint("DEBUG: Buff failed to apply. Retrying for member ID:", memberID)
                        retries = retries + 1
                    end
                end

                -- If buff was not applied after retries, add back to the queue
                if not buffApplied then
                    debugPrint("DEBUG: Max retries reached. Re-queuing task for member ID:", memberID)
                    table.insert(buffer.buffQueue, task)
                end

                mq.delay(100)
            end
        end
    end
    debugPrint("DEBUG: Buff routine completed.")
end

return buffer