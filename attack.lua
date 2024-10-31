local mq = require('mq')
local gui = require('gui')
local clericspells = require('clericspells')
local attack = {}

local clericLevel = mq.TLO.Me.Level() or 0

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
local function castOnTarget(targetID, targetName, spellName)
    -- Ensure we are targeting the right ID
    if targetID ~= mq.TLO.Target.ID() then
        mq.cmdf('/target id %d', targetID)
        mq.delay(200)
    end

    -- Cast the spell
    mq.cmdf('/cast %s', spellName)
    mq.delay(100)

    -- Monitor casting and conditions
    while mq.TLO.Me.Casting() do
        -- Stop casting if the buff is already on the target or target's HP is below 20%
        if mq.TLO.Target.Buff(spellName)() or (mq.TLO.Target.PctHPs() < 40 and not mq.TLO.Target.Named()) then
            mq.cmd('/stopcast')
            break
        end
        mq.delay(10)
    end
end

function attack.attackRoutine()
    -- Ensure bot is active and the useKarn option is enabled
    if not gui.botOn or not gui.useKarn then
        return
    end

    -- Find the best Reverse Damage Shield spell
    local bestAttackSpell = clericspells.findBestSpell("ReverseDS", clericLevel)

    -- Only proceed if we have a valid spell to cast
    if not bestAttackSpell then
        return
    end
        -- Load the resurrection spell if it is not already loaded in Gem 8
    if tostring(mq.TLO.Me.Gem(8)) ~= bestAttackSpell and gui.useKarn then
        clericspells.loadAndMemorizeSpell("ReverseDS", clericLevel, 8)
    end

    -- Assist main assist to obtain target
    mq.cmdf('/assist %s', gui.mainAssist)
    mq.delay(400)

    -- Verify we have a valid NPC target
    local targetID = mq.TLO.Target.ID()
    if targetID and mq.TLO.Target.Type() == "NPC" and mq.TLO.Target.Distance() <= gui.assistRange and (mq.TLO.Target.PctHPs() > 40 or mq.TLO.Target.Named()) then
        -- Check if target is Tashed and ready for the Reverse Damage Shield
        if mq.TLO.Target.AggroHolder() == gui.mainAssist and not mq.TLO.Target.Buff(bestAttackSpell)() then
            -- Perform checks: mana, spell readiness, range, and pre-cast status
            if hasEnoughMana(bestAttackSpell) and mq.TLO.Me.SpellReady(bestAttackSpell)() and isTargetInRange(targetID, bestAttackSpell) and preCastChecks() then
                castOnTarget(targetID, mq.TLO.Target.CleanName(), bestAttackSpell)
            end
        end
    end
end

return attack