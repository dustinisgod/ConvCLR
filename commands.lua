local mq = require 'mq'
local gui = require 'gui'
local nav = require 'nav'
local res = require 'res'
local utils = require 'utils'

local commands = {}

-- Helper function to set on/off values for toggleable options
local function setToggleOption(option, value, name)
    if value == "on" then
        gui[option] = true
        print(name .. " is now enabled.")
    elseif value == "off" then
        gui[option] = false
        print(name .. " is now disabled.")
    else
        print("Usage: /convCLR " .. option .. " on/off")
    end
end

local function toggleExit()
    print("Closing..")
    gui.isOpen = false
end

local function setSave()
    gui.saveConfig()
end

-- Function definitions with on/off control
local function setBotOnOff(value) setToggleOption("botOn", value, "Bot") end
local function setMainHeal(value) setToggleOption("mainHeal", value, "Normal Heal") end
local function setUseHoT(value) setToggleOption("useHoT", value, "HoT") end
local function setFastHeal(value) setToggleOption("fastHeal", value, "Fast Heal") end
local function setCompleteHeal(value) setToggleOption("completeHeal", value, "Complete Heal") end
local function setGroupHeal(value) setToggleOption("groupHeal", value, "Group Heal") end
local function setUseCures(value) setToggleOption("useCures", value, "Use Cures") end
local function setBuffGroup(value) setToggleOption("buffGroup", value, "Buff Group") end
local function setBuffRaid(value) setToggleOption("buffRaid", value, "Buff Raid") end
local function setAchpBuff(value) setToggleOption("achpBuff", value, "Aegis") end
local function setHpOnlyBuff(value) setToggleOption("hpOnlyBuff", value, "Symbol") end
local function setAcOnlyBuff(value) setToggleOption("acOnlyBuff", value, "Shield") end
local function setResistMagic(value) setToggleOption("resistMagic", value, "Resist Magic") end
local function setResistFire(value) setToggleOption("resistFire", value, "Resist Fire") end
local function setResistCold(value) setToggleOption("resistCold", value, "Resist Cold") end
local function setResistDisease(value) setToggleOption("resistDisease", value, "Resist Disease") end
local function setResistPoison(value) setToggleOption("resistPoison", value, "Resist Poison") end
local function setResOn(value) setToggleOption("useRes", value, "Resurrection") end
local function setUseEpic(value) setToggleOption("useEpic", value, "Use Epic") end
local function setCombatRes(value) setToggleOption("combatRes", value, "Combat Res") end
local function setSitMed(value) setToggleOption("sitMed", value, "Sit Med") end
local function setKarn(value) setToggleOption("useKarn", value, "Mark of Karn") end

-- Functions for setting slider values
local function setMainHealPct(value)
    gui.mainhealPct = tonumber(value) or gui.mainhealPct
    print("Normal Heal % Threshold set to", gui.mainhealPct)
end

local function setHotPct(value)
    gui.hotPct = tonumber(value) or gui.hotPct
    print("HoT % Threshold set to", gui.hotPct)
end

local function setFastHealPct(value)
    gui.fastHealPct = tonumber(value) or gui.fastHealPct
    print("Fast Heal % Threshold set to", gui.fastHealPct)
end

local function setCompleteHealPct(value)
    gui.completeHealPct = tonumber(value) or gui.completeHealPct
    print("Complete Heal % Threshold set to", gui.completeHealPct)
end

local function setGroupHealPct(value)
    gui.groupHealPct = tonumber(value) or gui.groupHealPct
    print("Group Heal % Threshold set to", gui.groupHealPct)
end

local function setGroupHealNumber(value)
    gui.groupHealNumber = tonumber(value) or gui.groupHealNumber
    print("Group Members to Heal set to", gui.groupHealNumber)
end

-- Combined function for setting main assist, range, and percent
local function setAssist(name, range, percent)
    if name then
        utils.setMainAssist(name)
        print("Main Assist set to", name)
    else
        print("Error: Main Assist name is required.")
        return
    end

    -- Set the assist range if provided
    if range and string.match(range, "^%d+$") then
        gui.assistRange = tonumber(range)
        print("Assist Range set to", gui.assistRange)
    else
        print("Assist Range not provided or invalid. Current range:", gui.assistRange)
    end

    -- Set the assist percent if provided
    if percent and string.match(percent, "^%d+$") then
        gui.assistPercent = tonumber(percent)
        print("Assist Percent set to", gui.assistPercent)
    else
        print("Assist Percent not provided or invalid. Current percent:", gui.assistPercent)
    end
end

local function setChaseOnOff(value)
    if value == "" then
        print("Usage: /convbard Chase <targetName> <distance> or /convbard Chase off/on")
    elseif value == 'on' then
        gui.chaseOn = true
        gui.returnToCamp = false
        gui.pullOn = false
        print("Chase enabled.")
    elseif value == 'off' then
        gui.chaseOn = false
        print("Chase disabled.")
    else
        -- Split value into targetName and distance
        local targetName, distanceStr = value:match("^(%S+)%s*(%S*)$")
        
        if not targetName then
            print("Invalid input. Usage: /convbard Chase <targetName> <distance>")
            return
        end
        
        -- Convert distance to a number, if it's provided
        local distance = tonumber(distanceStr)
        
        -- Check if distance is valid
        if not distance then
            print("Invalid distance provided. Usage: /ConvBard Chase <targetName> <distance> or /ConvBard Chase off")
            return
        end
        
        -- Pass targetName and valid distance to setChaseTargetAndDistance
        nav.setChaseTargetAndDistance(targetName, distance)
    end
end

-- Combined function for setting camp, return to camp, and chase
local function setCampHere(value1)
    if value1 == "on" then
        gui.chaseOn = false
        gui.campLocation = nav.setCamp()
        gui.returnToCamp = true
        gui.campDistance = gui.campDistance or 10
        print("Camp location set to current spot. Return to Camp enabled with default distance:", gui.campDistance)
    elseif value1 == "off" then
        -- Disable return to camp
        gui.returnToCamp = false
        print("Return To Camp disabled.")
    elseif tonumber(value1) then
        gui.chaseOn = false
        gui.campLocation = nav.setCamp()
        gui.returnToCamp = true
        gui.campDistance = tonumber(value1)
        print("Camp location set with distance:", gui.campDistance)
    else
        print("Error: Invalid command. Usage: /convbard camphere <distance>, /convbard camphere on, /convbard camphere off")
    end
end

-- Define the command handler function
local function commandHandler(command, ...)
    -- Convert command to lowercase for case-insensitive matching
    command = string.lower(command)
    local args = {...}
    
    -- Command processing with case matching for each command
    if command == "exit" then
        toggleExit()
    elseif command == "bot" then
        setBotOnOff(args[1])
    elseif command == "save" then
        setSave()
    elseif command == "assist" then
        setAssist(args[1], args[2], args[3])

    -- Toggleable Commands
    elseif command == "mainheal" then
        setMainHeal(args[1])
    elseif command == "hot" then
        setUseHoT(args[1])
    elseif command == "fastheal" then
        setFastHeal(args[1])
    elseif command == "ch" then
        setCompleteHeal(args[1])
    elseif command == "groupheal" then
        setGroupHeal(args[1])
    elseif command == "cures" then
        setUseCures(args[1])
    elseif command == "buffgroup" then
        setBuffGroup(args[1])
    elseif command == "buffraid" then
        setBuffRaid(args[1])
    elseif command == "aegis" then
        setAchpBuff(args[1])
    elseif command == "symbol" then
        setHpOnlyBuff(args[1])
    elseif command == "shield" then
        setAcOnlyBuff(args[1])
    elseif command == "buffmagic" then
        setResistMagic(args[1])
    elseif command == "bufffire" then
        setResistFire(args[1])
    elseif command == "buffcold" then
        setResistCold(args[1])
    elseif command == "buffdisease" then
        setResistDisease(args[1])
    elseif command == "buffpoison" then
        setResistPoison(args[1])
    elseif command == "rez" then
        setResOn(args[1])  -- Now takes on/off
    elseif command == "epic" then
        setUseEpic(args[1])
    elseif command == "combatres" then
        setCombatRes(args[1])
    elseif command == "sitmed" then
        setSitMed(args[1])
    elseif command == "karn" then
        setKarn(args[1])

    -- Slider Commands
    elseif command == "mainhealpct" then
        setMainHealPct(args[1])
    elseif command == "hotpct" then
        setHotPct(args[1])
    elseif command == "fasthealpct" then
        setFastHealPct(args[1])
    elseif command == "completehealpct" then
        setCompleteHealPct(args[1])
    elseif command == "grouphealpct" then
        setGroupHealPct(args[1])
    elseif command == "grouphealnumber" then
        setGroupHealNumber(args[1])

    -- Nav Commands
elseif command == "camphere" then
    setCampHere(args[1])
elseif command == "chase" then
    local chaseValue = args[1]
    if args[2] then
        chaseValue = chaseValue .. " " .. args[2]
    end
    setChaseOnOff(chaseValue)

    else
        print("Error: Unknown command.")
    end
end

-- Initialize command bindings
function commands.init()
    -- Bind all commands to the handler
    mq.bind('/convclr', function(command, ...)
        commandHandler(command, ...)
    end)
end

return commands