local mq = require('mq')
local clericspells = require('clericspells')
local utils = require('utils')
local healing = require('healing')
local gui = require('gui')

local buffer = {}
buffer.buffQueue = {}

-- Helper function: Pre-cast checks for combat, movement, and casting status
local function preCastChecks()
    return not (mq.TLO.Me.Moving() or mq.TLO.Me.Combat() or mq.TLO.Me.Casting())
end

-- Helper function: Check if we have enough mana to cast the spell
local function hasEnoughMana(spellName)
    return spellName and mq.TLO.Me.CurrentMana() >= mq.TLO.Spell(spellName).Mana()
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

-- Function to handle the heal routine and return
local function handleHealRoutineAndReturn()
    healing.healRoutine()
    return true -- Assuming heal routine passes, return to continue buffing
end

-- Buffing routine including self-buffing for the cleric
function buffer.buffRoutine()
    if not gui.botOn then return end

    if not preCastChecks() then
        return
    end

    local clericLevel = mq.TLO.Me.Level()
    local spellTypes = {}

    -- Determine which buffs to apply based on cleric level and GUI settings
    if gui.achpBuff then
        table.insert(spellTypes, clericLevel >= 58 and "BuffACHP" or "BuffACHP")
    elseif gui.hpOnlyBuff and clericLevel < 58 then
        table.insert(spellTypes, "BuffHPOnly")
    elseif gui.acOnlyBuff and clericLevel < 58 then
        table.insert(spellTypes, "BuffACOnly")
    end

    -- Add resist buffs based on GUI checkboxes
    for _, resist in ipairs({
        {type = "BuffMagic", checked = gui.resistMagic},
        {type = "BuffFire", checked = gui.resistFire},
        {type = "BuffCold", checked = gui.resistCold},
        {type = "BuffDisease", checked = gui.resistDisease},
        {type = "BuffPoison", checked = gui.resistPoison}
    }) do
        if resist.checked then table.insert(spellTypes, resist.type) end
    end

    -- Prepare a list of group members and add the cleric's ID for self-buffing
    local groupMembers = {}
    if not mq.TLO.Me.Dead() then table.insert(groupMembers, mq.TLO.Me.ID()) end

    for i = 1, mq.TLO.Group.Members() do
        local member = mq.TLO.Group.Member(i)
        if member.ID() and not member.Dead() then table.insert(groupMembers, member.ID()) end
    end

    -- Process each spell type
    for _, spellType in ipairs(spellTypes) do
        if not gui.botOn then return end

        local bestSpell = clericspells.findBestSpell(spellType, clericLevel)
        if bestSpell then
            buffer.buffQueue = {}

            -- Check each member (including the cleric) for missing buff and add to queue
            for _, memberID in ipairs(groupMembers) do
                if not gui.botOn then return end

                mq.cmdf("/target id %d", memberID)
                mq.delay(500)

                if not mq.TLO.Target.Dead() and not mq.TLO.Target.Buff(bestSpell)() and mq.TLO.Spell(bestSpell).StacksTarget() then
                    table.insert(buffer.buffQueue, {memberID = memberID, spell = bestSpell, spellType = spellType, slot = (spellType == "BuffACHP" and 6 or (spellType == "BuffHPOnly" and 7 or 8))})
                end
            end

            -- Load and memorize the spell only if there are members needing the buff
            if #buffer.buffQueue > 0 then
                clericspells.loadAndMemorizeSpell(spellType, clericLevel, buffer.buffQueue[1].slot)
                buffer.processBuffQueue()
            end
        end
    end
end

function buffer.processBuffQueue()
    while #buffer.buffQueue > 0 do
        if not gui.botOn then
            return  -- Stop processing if bot is turned off
        end

        local buffTask = table.remove(buffer.buffQueue, 1)

        local maxReadyAttempts = 20
        local readyAttempt = 0

        while not mq.TLO.Me.SpellReady(buffTask.spell)() and readyAttempt < maxReadyAttempts do
            if not gui.botOn then return end  -- Stop if bot is turned off mid-wait
            readyAttempt = readyAttempt + 1
            if gui.mainHeal or gui.fastHeal or gui.completeHeal then
                if not handleHealRoutineAndReturn() then
                    return
                end
            end
            mq.delay(1000)  -- Wait 1 second before checking again
        end

        if not mq.TLO.Me.SpellReady(buffTask.spell)() then
            break
        end

        mq.cmdf('/target id %d', buffTask.memberID)
        mq.delay(200)

        if mq.TLO.Target.Buff(buffTask.spell)() then
            break
        end

        if not hasEnoughMana(buffTask.spell) then
            utils.sitMed()
            return
        end

        if not isTargetInRange(buffTask.memberID, buffTask.spell) then
            return
        end

        mq.cmdf('/cast %d', buffTask.slot)
        mq.delay(200)

        while mq.TLO.Me.Casting() do
            if not gui.botOn then
                mq.cmd('/stopcast')  -- Gracefully stop casting if bot is turned off
                return
            end
            mq.delay(50)
        end

        mq.delay(100)

        if mq.TLO.Spawn(buffTask.memberID).Buff(buffTask.spell)() then
            -- Buff was successfully applied
        else
            -- Requeue if buff did not apply
            table.insert(buffer.buffQueue, buffTask)
        end

        mq.delay(100)
    end
end

return buffer