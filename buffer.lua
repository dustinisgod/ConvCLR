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

    if target and target.Distance() and spellRange then
        return target.Distance() <= spellRange
    else
        return false
    end
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
end

function buffer.buffRoutine()
    if not gui.botOn then return end

    if not preCastChecks() then
        return
    end

    if mq.TLO.Me.PctMana() < 20 then
        utils.sitMed()
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

    -- Collect group or raid members based on GUI settings
    local groupMembers = {}

    -- Include self if not dead
    if not mq.TLO.Me.Dead() then table.insert(groupMembers, mq.TLO.Me.ID()) end

    -- Add group members if buffGroup is enabled
    if gui.buffGroup then
        for i = 1, mq.TLO.Group.Members() do
            local member = mq.TLO.Group.Member(i)
            if member.ID() and not member.Dead() then
                table.insert(groupMembers, member.ID())
            end
        end
    end

    -- Add raid members if buffRaid is enabled
    if gui.buffRaid then
        for i = 1, mq.TLO.Raid.Members() do
            local member = mq.TLO.Raid.Member(i)
            if member.ID() and not member.Dead() then
                table.insert(groupMembers, member.ID())
            end
        end
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
                if not handleHealRoutineAndReturn() then
                    return
                end

                if mq.TLO.Me.PctMana() < 20 then
                    utils.sitMed()
                    return
                end

                -- Target member with retry and verification
                local maxTargetAttempts = 3
                local attempt = 0
                repeat
                    mq.cmdf("/tar id %d", memberID)
                    mq.delay(500)
                    attempt = attempt + 1
                until mq.TLO.Target.ID() == memberID or attempt >= maxTargetAttempts

                -- Skip if targeting failed
                if mq.TLO.Target.ID() ~= memberID then
                    print(string.format("Warning: Unable to target member ID %d after %d attempts.", memberID, maxTargetAttempts))
                    break
                end

                if not mq.TLO.Target.Dead() and not mq.TLO.Target.Buff(bestSpell)() and mq.TLO.Spell(bestSpell).StacksTarget() then
                    table.insert(buffer.buffQueue, {memberID = memberID, spell = bestSpell, spellType = spellType, slot = (spellType == "BuffACHP" and 6 or (spellType == "BuffHPOnly" and 7 or 8))})
                end
            end

            -- Load and memorize the spell only if there are members needing the buff
            if #buffer.buffQueue > 0 then
                -- Shuffle the buff queue to randomize member order
                shuffleTable(buffer.buffQueue)
                
                clericspells.loadAndMemorizeSpell(spellType, clericLevel, buffer.buffQueue[1].slot)
                buffer.processBuffQueue()
            end
        end
    end
end

function buffer.processBuffQueue()
    while #buffer.buffQueue > 0 do
        if not gui.botOn then
            return
        end

        if mq.TLO.Me.PctMana() < 20 then
            utils.sitMed()
            return
        end

        local buffTask = table.remove(buffer.buffQueue, 1)
        local maxReadyAttempts = 20
        local readyAttempt = 0

        -- Ensure spell is ready before proceeding
        while not mq.TLO.Me.SpellReady(buffTask.spell)() and readyAttempt < maxReadyAttempts do
            if not gui.botOn then return end
            readyAttempt = readyAttempt + 1
            if gui.mainHeal or gui.fastHeal or gui.completeHeal then
                if not handleHealRoutineAndReturn() then
                    return
                end
            end
            mq.delay(1000)
        end

        if not mq.TLO.Me.SpellReady(buffTask.spell)() then
            break
        end

        mq.cmdf('/tar id %d', buffTask.memberID)
        print("test8")
        mq.delay(500, function() return mq.TLO.Target.ID() == buffTask.memberID end)

        -- Check if target already has the buff
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
        mq.delay(500)  -- Allow time for casting to start

        -- Wait for casting to complete, or stop if conditions are met
        while mq.TLO.Me.Casting() do
            if mq.TLO.Target.Buff(buffTask.spell)() or not gui.botOn then
                mq.cmd('/stopcast')
                break
            end
            mq.delay(50)
        end

        -- Verify if the buff was applied, and re-queue if not
        mq.delay(300)  -- Extra delay to allow the buff to register
        if not mq.TLO.Target.Buff(buffTask.spell)() then
            table.insert(buffer.buffQueue, buffTask)
        end

        mq.delay(100)
    end
end

return buffer