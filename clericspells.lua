mq = require('mq')
local gui = require('gui')

local clericspells = {}

local spellList = {
    Heal = {
        {level = 52, name = "Divine Light"},
        {level = 49, name = "Greater Healing Light"},
        {level = 29, name = "Superior Healing"},
        {level = 20, name = "Greater Healing"},
        {level = 10, name = "Healing"},
        {level = 4, name = "Light Healing"},
        {level = 1, name = "Minor Healing"}
    },
    HealFast = {
        {level = 49, name = "Remedy"}
    },
    HoT = {
        {level = 59, name = "Celestial Elixir"},
        {level = 44, name = "Celestial Healing"},
        {level = 29, name = "Celestial Health"},
        {level = 19, name = "Celestial Remedy"}
    },
    HealBig = {
        {level = 39, name = "Complete Heal"}
    },
    GroupHeal = {
        {level = 45, name = "Word of Healing"},
        {level = 30, name = "Word of Health"}
    },
    BuffACHP = {
        {level = 60, name = "Blessing of Aegolism"},
        {level = 58, name = "Aegolism"},
        {level = 52, name = "Heroic Bond"},
        {level = 41, name = "Resolution"},
        {level = 31, name = "Valor"},
        {level = 22, name = "Bravery"},
        {level = 17, name = "Daring"},
        {level = 7, name = "Center"},
        {level = 1, name = "Courage"}
    },
    BuffHPOnly = {
        {level = 53, name = "Symbol of Marzin"},
        {level = 41, name = "Symbol of Naltron"},
        {level = 31, name = "Symbol of Pinzarn"},
        {level = 21, name = "Symbol of Ryltan"},
        {level = 11, name = "Symbol of Transal"}
    },
    BuffACOnly = {
        {level = 57, name = "Order of Faith"},
        {level = 45, name = "Shield of Words"},
        {level = 35, name = "Armor of Faith"},
        {level = 25, name = "Guard"},
        {level = 15, name = "Spirit Armor"},
        {level = 1, name = "Holy Armor"}
    },
    CurePoison = {
        {level = 57, name = "Antidote"},
        {level = 47, name = "Abolish Poison"},
        {level = 22, name = "Counteract Poison"}
    },
    CureDisease = {
        {level = 28, name = "Counteract Disease"},
        {level = 4, name = "Cure Disease"}
    },
    Rez = {
        {level = 12, name = "Reanimation"}
    },
    BuffMagic = {
        {level = 42, name = "Resist Magic"},
        {level = 16, name = "Endure Magic"}
    },
    BuffFire = {
        {level = 33, name = "Resist Fire"},
        {level = 8, name = "Endure Fire"}
    },
    BuffCold = {
        {level = 38, name = "Resist Cold"},
        {level = 13, name = "Endure Cold"}
    },
    BuffPoison = {
        {level = 30, name = "Resist Poison"},
        {level = 6, name = "Endure Poison"}
    },
    BuffDisease = {
        {level = 36, name = "Resist Disease"},
        {level = 11, name = "Endure Disease"}
    },
    ReverseDS = {
        {level = 56, name = "Mark of Karn"}
    }
}

-- Function to find the best spell for a given type and level
function clericspells.findBestSpell(spellType, charLevel)
    local spells = spellList[spellType]

    if not spells then
        return nil -- Return nil if the spell type doesn't exist
    end

    -- Skip BuffHPOnly and BuffACOnly if cleric level is 58 or higher, as Aegolism line covers all three buffs
    if charLevel >= 58 and (spellType == "BuffHPOnly" or spellType == "BuffACOnly") then
        printf("Skipping " .. spellType .. " because cleric level is " .. charLevel .. " and Aegolism line covers this.")
        return nil
    end

    -- Special case for BuffACHP at level 60, preferring "Blessing of Aegolism" if available
    if spellType == "BuffACHP" and charLevel == 60 then
        if mq.TLO.Me.Book('Blessing of Aegolism')() then
            return "Blessing of Aegolism"
        else
            return "Aegolism" -- Fallback to "Aegolism" if "Blessing of Aegolism" is not in the spellbook
        end
    end

    -- General spell search for other types and levels
    for _, spell in ipairs(spells) do
        if charLevel >= spell.level then
            return spell.name
        end
    end

    return nil -- Return nil if no spell is available for the level
end

-- Function to load best default spells based on cleric level, including custom logic for Slots 6, 7, and 8
function clericspells.loadDefaultSpells(clericLevel)
    local defaultSpells = {}

    -- Slot 1 - Single Target Healing Spells (Heal)
    defaultSpells[1] = clericspells.findBestSpell("Heal", clericLevel)

    -- Slot 2 - Fast Healing Spells (HealFast)
    defaultSpells[2] = clericspells.findBestSpell("HealFast", clericLevel)

    -- Slot 3 - Heal-over-Time Spells (HoT)
    defaultSpells[3] = clericspells.findBestSpell("HoT", clericLevel)

    -- Slot 4 - Big Healing Spells (HealBig)
    defaultSpells[4] = clericspells.findBestSpell("HealBig", clericLevel)

    -- Slot 5 - Group Healing Spells (GroupHeal)
    defaultSpells[5] = clericspells.findBestSpell("GroupHeal", clericLevel)

    -- Slot 6 - Cure Poison (CurePoison)
    defaultSpells[6] = clericspells.findBestSpell("CurePoison", clericLevel)

    -- Slot 7 - Cure Disease (CureDisease))
    defaultSpells[7] = clericspells.findBestSpell("CureDisease", clericLevel)

    -- Slot 8 - Buff AC Only or Resurrection (BuffACOnly, Res)
    if clericLevel >= 56 then
        if gui.useKarn or (gui.useRez and gui.useEpic) then
            defaultSpells[8] = "Mark of Karn"
        elseif gui.useRez and not gui.useKarn and not gui.useEpic then
            defaultSpells[8] = "Reanimation"
        end
    elseif clericLevel >= 12 and gui.useRez and not gui.useEpic then
        defaultSpells[8] = "Reanimation"
    elseif clericLevel >= 2 and clericLevel < 12 then
        defaultSpells[8] = "Holy Armor"
    end

    return defaultSpells
end

-- Function to memorize spells in the correct slots with delay and retries
function clericspells.memorizeSpells(spells)
    for slot = 1, 8 do
        local spellName = spells[slot]

        -- Only attempt if a spell is assigned to the slot for the current level
        if spellName then
            local maxAttempts = 3
            local success = false

            for attempt = 1, maxAttempts do
                -- Check if the spell is already in the correct slot
                if mq.TLO.Me.Gem(slot)() == spellName then
                    printf(string.format("Spell %s is already memorized in slot %d", spellName, slot))
                    success = true
                    break
                else
                    -- Clear the slot first
                    mq.cmdf('/memorize "" %d', slot)
                    mq.delay(500)  -- Delay for slot clearance

                    -- Issue the command to memorize the spell
                    mq.cmdf('/memorize "%s" %d', spellName, slot)
                    mq.delay(1000)  -- Initial delay for memorization

                    -- Wait for spellbook to close, with a timeout
                    local timeout = 10  -- seconds
                    local elapsed = 0
                    local checkInterval = 0.5  -- seconds
                    while mq.TLO.Window("SpellBookWnd").Open() and elapsed < timeout do
                        mq.delay(checkInterval * 1000)
                        elapsed = elapsed + checkInterval
                    end

                    -- Check if the spell is correctly memorized
                    if mq.TLO.Me.Gem(slot)() == spellName then
                        printf(string.format("Successfully memorized %s in slot %d on attempt %d", spellName, slot, attempt))
                        success = true
                        break
                    else
                        printf(string.format("Attempt %d to memorize spell %s in slot %d failed.", attempt, spellName, slot))
                    end
                end
            end

            -- Log a warning if the spell couldn't be memorized after max attempts
            if not success then
                printf(string.format("Warning: Failed to memorize spell %s in slot %d after %d attempts, skipping.", spellName, slot, maxAttempts))
            end
        else
            printf(string.format("No spell assigned for slot %d at this level. Skipping.", slot))
        end
    end
end

function clericspells.loadAndMemorizeSpell(spellType, level, spellSlot)
    -- Skip BuffHPOnly and BuffACOnly if cleric level is 58 or higher
    if level >= 58 and (spellType == "BuffHPOnly" or spellType == "BuffACOnly") then
        printf("Skipping " .. spellType .. " because cleric level is " .. level .. " and Aegolism line covers this.")
        return
    end

    -- Find the best spell for the given type and level
    local bestSpell = clericspells.findBestSpell(spellType, level)

    if not bestSpell then
        printf("No spell found for type: " .. spellType .. " at level: " .. level)
        return
    end

    -- Check if the spell is already in the correct spell gem slot
    if mq.TLO.Me.Gem(spellSlot).Name() == bestSpell then
        printf("Spell " .. bestSpell .. " is already memorized in slot " .. spellSlot)
        return true
    end

    -- Memorize the spell in the correct slot
    mq.cmdf('/memorize "%s" %d', bestSpell, spellSlot)
    mq.delay(1000)  -- Initial delay to allow the memorization command to take effect

    local timeout = 10  -- Timeout in seconds
    local elapsed = 0
    local checkInterval = 0.5  -- Check every 0.5 seconds

    -- While the spellbook is open and the elapsed time is less than the timeout
    while mq.TLO.Window("SpellBookWnd").Open() and elapsed < timeout do
        mq.delay(checkInterval * 1000)  -- Delay in milliseconds
        elapsed = elapsed + checkInterval
    end

    -- Add a delay to wait for the spell to be memorized
    local maxAttempts = 10
    local attempt = 0
    while mq.TLO.Me.Gem(spellSlot).Name() ~= bestSpell and attempt < maxAttempts do
        mq.delay(2000) -- Wait 2 seconds before checking again
        attempt = attempt + 1
    end

    -- Check if the spell is now memorized correctly
    if mq.TLO.Me.Gem(spellSlot).Name() == bestSpell then
        printf("Successfully memorized spell " .. bestSpell .. " in slot " .. spellSlot)
        return true
    else
        printf("Failed to memorize spell " .. bestSpell .. " in slot " .. spellSlot)
        return false
    end
end

-- Startup function to initialize default spell choices and memorize them
function clericspells.startup(clericLevel)
    -- Load the best default spells based on the cleric level
    local defaultSpells = clericspells.loadDefaultSpells(clericLevel)

    clericspells.memorizeSpells(defaultSpells)
end

return clericspells