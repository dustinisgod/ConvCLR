mq = require('mq')
local gui = require('gui')

local DEBUG_MODE = false
-- Debug print helper function
local function debugPrint(...)
    if DEBUG_MODE then
        print(...)
    end
end

local spells = {
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
    buffaegis = {
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
    buffsymbol = {
        {level = 53, name = "Symbol of Marzin"},
        {level = 41, name = "Symbol of Naltron"},
        {level = 31, name = "Symbol of Pinzarn"},
        {level = 21, name = "Symbol of Ryltan"},
        {level = 11, name = "Symbol of Transal"}
    },
    buffshield = {
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
    buffmagic = {
        {level = 42, name = "Resist Magic"},
        {level = 16, name = "Endure Magic"}
    },
    bufffire = {
        {level = 33, name = "Resist Fire"},
        {level = 8, name = "Endure Fire"}
    },
    buffcold = {
        {level = 38, name = "Resist Cold"},
        {level = 13, name = "Endure Cold"}
    },
    buffpoison = {
        {level = 30, name = "Resist Poison"},
        {level = 6, name = "Endure Poison"}
    },
    buffdisease = {
        {level = 36, name = "Resist Disease"},
        {level = 11, name = "Endure Disease"}
    },
    ReverseDS = {
        {level = 56, name = "Mark of Karn"}
    }
}

-- Function to find the best spell for a given type and level
function spells.findBestSpell(spellType, charLevel)
    local spells = spells[spellType]
    if not spells then
        return nil -- Return nil if the spell type doesn't exist
    end

    -- Skip buffaegis and buffshield if cleric level is 58 or higher, as Aegolism line covers all three buffs
    if charLevel >= 58 and gui.buffaegis and not gui.buffdruidskin and (spellType == "buffsymbol" or spellType == "buffshield") then
        debugPrint("Skipping " .. spellType .. " because cleric level is " .. charLevel .. " and Aegolism line covers this.")
        return nil
    end

    -- Special case for BuffACHP at level 60, preferring "Blessing of Aegolism" if available
    if spellType == "buffaegis" and charLevel == 60 then
        if mq.TLO.Me.Book('Blessing of Aegolism')() and not gui.buffdruidskin then
            debugPrint("Using Blessing of Aegolism for BuffACHP at level 60")
            return "Blessing of Aegolism"
        else
            debugPrint("Falling back to Aegolism for BuffACHP at level 60")
            return "Aegolism" -- Fallback to "Aegolism" if "Blessing of Aegolism" is not in the spellbook
        end
    end

    -- General spell search for other types and levels
    for _, spell in ipairs(spells) do
        if charLevel >= spell.level then
            return spell.name
        end
    end
    return nil
end

function spells.loadDefaultSpells(charLevel)
    local defaultSpells = {}

    -- Slot 1 - Single Target Healing Spells (Heal)
    defaultSpells[1] = spells.findBestSpell("Heal", charLevel)

    -- Slot 2 - Fast Healing Spells (HealFast)
    defaultSpells[2] = spells.findBestSpell("HealFast", charLevel)

    -- Slot 3 - Heal-over-Time Spells (HoT)
    defaultSpells[3] = spells.findBestSpell("HoT", charLevel)

    -- Slot 4 - Big Healing Spells (HealBig)
    defaultSpells[4] = spells.findBestSpell("HealBig", charLevel)

    -- Slot 5 - Group Healing Spells (GroupHeal)
    defaultSpells[5] = spells.findBestSpell("GroupHeal", charLevel)

    -- Slot 6 - Cure Poison (CurePoison)
    defaultSpells[6] = spells.findBestSpell("CurePoison", charLevel)

    -- Slot 7 - Cure Disease (CureDisease))
    defaultSpells[7] = spells.findBestSpell("CureDisease", charLevel)

    -- Slot 8 - BuffAegis
    defaultSpells[8] = spells.findBestSpell("buffaegis", charLevel)

    -- Slot 9 - ReverseDS
    if charLevel >= 56 and gui.useKarn then
        defaultSpells[9] = "Mark of Karn"
    end

    -- Slot 10 - Resurrection
    if gui.useRez and not gui.useEpic then
        defaultSpells[10] = "Reanimation"
    end

    return defaultSpells
end

-- Function to memorize spells in the correct slots with delay
function spells.memorizeSpells(spells)
    for slot, spellName in pairs(spells) do
        if spellName then
            -- Check if the spell is already in the correct slot
            if mq.TLO.Me.Gem(slot)() == spellName then
                printf(string.format("Spell %s is already memorized in slot %d", spellName, slot))
            else
                -- Clear the slot first to avoid conflicts
                mq.cmdf('/memorize "" %d', slot)
                mq.delay(500)  -- Short delay to allow the slot to clear

                -- Issue the /memorize command to memorize the spell in the slot
                mq.cmdf('/memorize "%s" %d', spellName, slot)
                mq.delay(1000)  -- Initial delay to allow the memorization command to take effect

                -- Loop to check if the spell is correctly memorized
                local maxAttempts = 10
                local attempt = 0
                while mq.TLO.Me.Gem(slot)() ~= spellName and attempt < maxAttempts do
                    mq.delay(500)  -- Check every 0.5 seconds
                    attempt = attempt + 1
                end

                -- Check if memorization was successful
                if mq.TLO.Me.Gem(slot)() ~= spellName then
                    printf(string.format("Failed to memorize spell: %s in slot %d", spellName, slot))
                else
                    printf(string.format("Successfully memorized %s in slot %d", spellName, slot))
                end
            end
        end
    end
end


function spells.loadAndMemorizeSpell(spellType, level, spellSlot)

    local bestSpell = spells.findBestSpell(spellType, level)

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

function spells.startup(charLevel)

    local defaultSpells = spells.loadDefaultSpells(charLevel)

    spells.memorizeSpells(defaultSpells)
end

return spells