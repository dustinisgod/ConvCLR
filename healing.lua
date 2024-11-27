local mq = require('mq')
local gui = require('gui')

local DEBUG_MODE = false
-- Debug print helper function
local function debugPrint(...)
    if DEBUG_MODE then
        print(...)
    end
end

local healing = {}
local charName = mq.TLO.Me.Name() or "Unknown"
local charLevel = mq.TLO.Me.Level() or 0

local mainhealSpell = tostring(mq.TLO.Me.Gem(1))
local fastHealSpell = tostring(mq.TLO.Me.Gem(2))
local hotSpell = tostring(mq.TLO.Me.Gem(3))
local completeHealSpell = tostring(mq.TLO.Me.Gem(4))
local groupHealSpell = tostring(mq.TLO.Me.Gem(5))

-- Queue to track active HoT targets and their expiration times
local hotQueue = {}

-- Helper function: Check if we have enough mana to cast the spell
local function hasEnoughMana(spellName)
    debugPrint("Checking mana for spell: " .. spellName)
    if not spellName then return false end
    return mq.TLO.Me.CurrentMana() >= mq.TLO.Spell(spellName).Mana()
end

-- Function to remove expired entries from the hotQueue
local function clearExpiredHoTs()
    debugPrint("Clearing expired HoTs from the queue")
    local currentTime = os.time()
    for name, expirationTime in pairs(hotQueue) do
        if currentTime >= expirationTime then
            hotQueue[name] = nil
        end
    end
end

local function isGroupMember(targetID)
    debugPrint("Checking if target is a group member: " .. targetID)
    for i = 0, 5 do
        local groupMemberID = mq.TLO.Group.Member(i).ID()
        if groupMemberID and groupMemberID == targetID then
            return true
        end
    end
    return false
end

-- Pre-cast checks for movement and casting status
local function preCastChecks()
    debugPrint("Checking pre-cast conditions")
    return not mq.TLO.Me.Moving() and not mq.TLO.Me.Casting()
end

-- Check if target is within spell range, safely handling nil target
local function isTargetInRange(targetID, spellName)

    local target = mq.TLO.Spawn(targetID)
    local spellRange = mq.TLO.Spell(spellName).Range()

    -- Check if both target and spell range exist to avoid nil errors
    if target and target.Distance() and spellRange then
        debugPrint("Checking if target is in range for spell: " .. spellName)
        return target.Distance() <= spellRange
    else
        debugPrint("Target doesn't exist or spell range is nil")
        return false  -- Return false if the target doesn't exist or range can't be determined
    end
end

-- Helper function to cast a spell on the specified target
local function castSpell(targetID, targetName, spellName)
    if targetID ~= mq.TLO.Target.ID() then
        debugPrint("Setting target to: " .. targetName)
    mq.cmdf('/tar ID %s', targetID)
    end
    mq.delay(200)

    if targetID == mq.TLO.Target.ID() then
        debugPrint("Casting spell: " .. spellName .. " on target: " .. targetName)
    mq.cmdf('/dgtell ALL Casting %s on %s', spellName, targetName)
    mq.cmdf('/cast %s', spellName)
    mq.delay(100)
    end

    while mq.TLO.Me.Casting() do
        if gui.stopCast then
            if mq.TLO.Target() and mq.TLO.Target.PctHPs() >= 95 then
                debugPrint("Stopping cast due to target health being above 95%")
                mq.cmd('/stopcast')
                break
            end
        end
        mq.delay(10)
    end
end

local function processHealsForTarget(targetID, targetName, targetHP, targetClass, isExtendedTarget, extIndex)
    -- Main Heal
    local mainHealThreshold = (isExtendedTarget and gui["ExtTargetMainHeal" .. extIndex .. "Pct"]) or gui.mainHealPct
    if gui.mainHeal and targetHP <= mainHealThreshold then
        debugPrint("Processing heals for target: " .. targetName)
        if preCastChecks() and mq.TLO.Me.SpellReady(mainhealSpell)() and isTargetInRange(targetID, mainhealSpell) and hasEnoughMana(mainhealSpell) then
            debugPrint("Casting main heal on target: " .. targetName)
            castSpell(targetID, targetName, mainhealSpell)
        end
    end

    -- Define HoT conditions and threshold
    local hotThreshold = (isExtendedTarget and gui["ExtTargetHoT" .. extIndex .. "Pct"]) or gui.hotPct
    local hotDuration = mq.TLO.Spell(hotSpell).Duration.TotalSeconds() or 0

    -- Only proceed if target meets all conditions for HoT
    if gui.useHoT and charLevel >= 19 and targetHP <= hotThreshold then
        debugPrint("Checking HoT conditions for target: " .. targetName)
        -- Extended target handling (apply additional checks here if needed)
        local isValidExtendedTarget = isExtendedTarget and gui["ExtTargetHoT" .. extIndex] and targetHP <= gui["ExtTargetHoT" .. extIndex .. "Pct"]
        
        if (isValidExtendedTarget or (not isExtendedTarget and (targetClass == "WAR" or targetClass == "PAL" or targetClass == "SHD"))) and
        not hotQueue[targetName] and hasEnoughMana(hotSpell) then
            debugPrint("Casting HoT on target: " .. targetName)

            if preCastChecks() and mq.TLO.Me.SpellReady(hotSpell)() and isTargetInRange(targetID, hotSpell) then
                debugPrint("Casting HoT on target: " .. targetName)
                castSpell(targetID, targetName, hotSpell)
                hotQueue[targetName] = os.time() + hotDuration
            end
        end
    end

    -- Fast Heal
    local fastHealThreshold = (isExtendedTarget and gui["ExtTargetFastHeal" .. extIndex .. "Pct"]) or gui.fastHealPct
    if gui.fastHeal and charLevel >= 49 and targetHP <= fastHealThreshold and
    (isExtendedTarget or (targetClass == "WIZ" or targetClass == "ENC" or targetClass == "MAG" or targetClass == "NEC" or targetClass == "DRU")) then
        debugPrint("Checking fast heal conditions for target: " .. targetName)

        if preCastChecks() and mq.TLO.Me.SpellReady(fastHealSpell)() and isTargetInRange(targetID, fastHealSpell) and hasEnoughMana(fastHealSpell) then
            debugPrint("Casting fast heal on target: " .. targetName)
            castSpell(targetID, targetName, fastHealSpell)
        end
    end

    -- Complete Heal
    local completeHealThreshold = (isExtendedTarget and gui["ExtTargetCompleteHeal" .. extIndex .. "Pct"]) or gui.completeHealPct
    if gui.completeHeal and charLevel >= 39 and targetHP <= completeHealThreshold and
    (isExtendedTarget or (targetClass == "WAR" or targetClass == "PAL" or targetClass == "SHD")) then
        debugPrint("Checking complete heal conditions for target: " .. targetName)
        if preCastChecks() and mq.TLO.Me.SpellReady(completeHealSpell)() and isTargetInRange(targetID, completeHealSpell) and hasEnoughMana(completeHealSpell) then
            debugPrint("Casting complete heal on target: " .. targetName)
            castSpell(targetID, targetName, completeHealSpell)
        end
    end
end

-- Heal routine that focuses on group members 0 through 5 and optional extended targets
function healing.healRoutine()
    charLevel = mq.TLO.Me.Level()  -- Update cleric level each iteration
    if not gui.botOn then return end
        debugPrint("Starting heal routine")
    local groupHealThreshold = gui.groupHealPct or 80
    local minGroupMembersInjured = gui.groupHealNumber or 3

    -- Clear expired entries from the HoT queue
    clearExpiredHoTs()

    -- Monitor health for group members 0 through 5
    for i = 0, 5 do
        local member = mq.TLO.Group.Member(i)
        local memberID = member and member.ID()
        if memberID and not member.Dead() then  -- Only proceed if the member is alive
            debugPrint("Processing heals for group member: " .. member.Name())
            local memberPctHP = member.PctHPs() or 0
            local memberClass = member.Class.ShortName() or ""

            -- Group heal logic
            if gui.groupHeal and charLevel >= 30 and memberPctHP <= groupHealThreshold then
                debugPrint("Checking group heal conditions for group member: " .. member.Name())
                local injuredCount = mq.TLO.Group.Injured(groupHealThreshold)() or 0
                if injuredCount >= minGroupMembersInjured and preCastChecks() and mq.TLO.Me.SpellReady(groupHealSpell)() and hasEnoughMana(groupHealSpell) then
                   debugPrint("Casting group heal")
                    mq.cmdf('/dgtell ALL %s - Casting Group Heal %s', charName, groupHealSpell)
                    mq.cmdf('/cast %s', groupHealSpell)
                    mq.delay(50)
                    while mq.TLO.Me.Casting() do mq.delay(10) end
                    mq.delay(200)
                end
            end
            processHealsForTarget(memberID, member.Name(), memberPctHP, memberClass, false, i)
        end
    end

    -- Only process extended targets if any extended target healing options are enabled
    local anyExtendedHealEnabled = false
    for extIndex = 1, 5 do
        if gui["ExtTargetMainHeal" .. extIndex] or gui["ExtTargetHoT" .. extIndex] or gui["ExtTargetFastHeal" .. extIndex] or gui["ExtTargetCompleteHeal" .. extIndex] then
           debugPrint("Extended target healing enabled")
            anyExtendedHealEnabled = true
            break
        end
    end

    if anyExtendedHealEnabled then
        for extIndex = 1, 5 do
            local extTarget = mq.TLO.Me.XTarget(extIndex)
            if extTarget and extTarget.ID() and extTarget.ID() ~= 0 and not extTarget.Dead() and (extTarget.Type() == "PC" or extTarget.Type() == "Pet") then
                local extID = extTarget.ID()
                local extName = extTarget.CleanName()
                local extPctHP = extTarget.PctHPs() or 0
                local extClass = extTarget.Class.ShortName() or ""
                debugPrint("Processing heals for extended target: " .. extName)
                -- Check if the extended target is already a group member
                if isGroupMember(extID) then
                    debugPrint("Extended target is already a group member")
                    mq.cmdf('/echo ERROR: Extended Target %s is already a group member.', extName)
                else
                    -- Check Main Heal
                    if gui["ExtTargetMainHeal" .. extIndex] then
                        debugPrint("Checking main heal conditions for extended target: " .. extName)
                        local mainHealThreshold = gui["ExtTargetMainHeal" .. extIndex .. "Pct"]
                        if extPctHP <= mainHealThreshold then
                            debugPrint("Processing main heal for extended target: " .. extName)
                            processHealsForTarget(extID, extName, extPctHP, extClass, true, extIndex)
                        end
                    end
    
                    -- Check HoT
                    if charLevel >= 19 and gui["ExtTargetHoT" .. extIndex] then
                        debugPrint("Checking HoT conditions for extended target: " .. extName)
                        local hotThreshold = gui["ExtTargetHoT" .. extIndex .. "Pct"]
                        if extPctHP <= hotThreshold then
                            debugPrint("Processing HoT for extended target: " .. extName)
                            processHealsForTarget(extID, extName, extPctHP, extClass, true, extIndex)
                        end
                    end
    
                    -- Check Fast Heal
                    if charLevel >= 49 and gui["ExtTargetFastHeal" .. extIndex] then
                        debugPrint("Checking fast heal conditions for extended target: " .. extName)
                        local fastHealThreshold = gui["ExtTargetFastHeal" .. extIndex .. "Pct"]
                        if extPctHP <= fastHealThreshold then
                            debugPrint("Processing fast heal for extended target: " .. extName)
                            processHealsForTarget(extID, extName, extPctHP, extClass, true, extIndex)
                        end
                    end
    
                    -- Check Complete Heal
                    if charLevel >= 39 and gui["ExtTargetCompleteHeal" .. extIndex] then
                        debugPrint("Checking complete heal conditions for extended target: " .. extName)
                        local completeHealThreshold = gui["ExtTargetCompleteHeal" .. extIndex .. "Pct"]
                        if extPctHP <= completeHealThreshold then
                            debugPrint("Processing complete heal for extended target: " .. extName)
                            processHealsForTarget(extID, extName, extPctHP, extClass, true, extIndex)
                        end
                    end
                end
            end
        end
    end

    mq.delay(50)
end

return healing