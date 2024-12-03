local mq = require('mq')
local gui = require('gui')
local spells = require('spells')

local attack = {}

local charLevel = mq.TLO.Me.Level() or 0

-- Helper function: Check if we have enough mana to cast the spell
local function hasEnoughMana(spellName)
    return spellName and mq.TLO.Me.CurrentMana() >= mq.TLO.Spell(spellName).Mana()
end

-- Helper function: Pre-cast checks for movement and casting status
local function preCastChecks()
    return not (mq.TLO.Me.Moving() or mq.TLO.Me.Casting())
end

-- Check if target is within spell range
local function isTargetInRange(targetID, spellName)
    local target = mq.TLO.Spawn(targetID)
    local spellRange = mq.TLO.Spell(spellName).Range()

    if target and target.Distance() and spellRange then
        return target.Distance() <= spellRange
    else
        return false
    end
end

-- Function to cast spell on the target
local function castOnTarget(targetID, spellName)
    -- Ensure we are targeting the right ID
    if not mq.TLO.Target() or (mq.TLO.Target() and targetID ~= mq.TLO.Target.ID()) then
        mq.cmdf('/tar id %d', targetID)
        mq.delay(200)
    end

    -- Cast the spell
    mq.cmdf('/cast %s', spellName)
    mq.delay(100)

    -- Monitor casting and conditions
    while mq.TLO.Me.Casting() do
        -- Check if there is a valid target and the buff exists on the target
        if mq.TLO.Target() and (mq.TLO.Target.Buff(spellName)() ~= nil or (mq.TLO.Target.PctHPs() < 40 and not mq.TLO.Target.Named())) then
            mq.cmd('/stopcast')
            break
        end
        mq.delay(10)
    end
end

function attack.attackRoutine()
    charLevel = mq.TLO.Me.Level()
    -- Ensure bot is active, useKarn is enabled, and mainAssist is in zone
    if not gui.botOn or not gui.useKarn then
        return
    end

    -- Check if mainAssist is in the same zone
    if not mq.TLO.Spawn(gui.mainAssist)() then
        return
    end

    if mq.TLO.Me.PctMana() < 20 then
        local utils = require('utils')
        utils.sitMed()
        return
    end

    -- Find the best Reverse Damage Shield spell
    local bestAttackSpell = spells.findBestSpell("ReverseDS", charLevel)

    -- Only proceed if we have a valid spell to cast
    if not bestAttackSpell then
        return
    end

    -- Load the resurrection spell if it is not already loaded in Gem 8
    if tostring(mq.TLO.Me.Gem(8)) ~= bestAttackSpell and gui.useKarn then
        spells.loadAndMemorizeSpell("ReverseDS", charLevel, 8)
    end

    -- Assist main assist to obtain target
    mq.cmdf('/assist %s', gui.mainAssist)
    mq.delay(400)

    if mq.TLO.Target() and mq.TLO.Target.Type() == "NPC" and mq.TLO.Target.Distance() and mq.TLO.Target.Distance() <= gui.assistRange and mq.TLO.Target.PctHPs() and mq.TLO.Target.PctHPs() <= gui.assistPercent and (mq.TLO.Target.PctHPs() > 40 or mq.TLO.Target.Named()) then
        local targetID = mq.TLO.Target.ID()
        if mq.TLO.Target() and not mq.TLO.Target.Buff(bestAttackSpell)() then
            if hasEnoughMana(bestAttackSpell) and mq.TLO.Me.SpellReady(bestAttackSpell)() and isTargetInRange(targetID, bestAttackSpell) and preCastChecks() then
                castOnTarget(targetID, bestAttackSpell)
            end
        end
    end
end

return attack