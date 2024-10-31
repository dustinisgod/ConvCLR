local mq = require 'mq'
local gui = require 'gui'
local nav = require 'nav'
local res = require 'res'
local utils = require 'utils'

local commands = {}

local function toggleExit()
    print("Closing..")
    gui.isOpen = false
end

local function setBotOn()
    gui.botOn = true
    print("Bot is now enabled")
end

local function setBotOff()
    gui.botOn = false
    print("Bot is now disabled.")
end

local function setSave()
    gui.saveConfig()
end

local function setAssistRange(value)
    gui.assistRange = tonumber(value) or gui.assistRange
    print("Assist Range set to ", gui.assistRange)
end


local function togglemainheal() 
    gui.mainheal = not gui.mainheal 
    print("Normal Heal is now", gui.mainheal and "enabled" or "disabled")
end

local function toggleUseHoT() 
    gui.useHoT = not gui.useHoT 
    print("HoT is now", gui.useHoT and "enabled" or "disabled")
end

local function toggleFastHeal() 
    gui.fastHeal = not gui.fastHeal 
    print("Fast Heal is now", gui.fastHeal and "enabled" or "disabled")
end

local function toggleCompleteHeal() 
    gui.completeHeal = not gui.completeHeal 
    print("Complete Heal is now", gui.completeHeal and "enabled" or "disabled")
end

local function toggleGroupHeal() 
    gui.groupHeal = not gui.groupHeal 
    print("Group Heal is now", gui.groupHeal and "enabled" or "disabled")
end

local function toggleUseCures() 
    gui.useCures = not gui.useCures 
    print("Use Cures is now", gui.useCures and "enabled" or "disabled")
end

local function toggleAchpBuff() 
    gui.achpBuff = not gui.achpBuff 
    print("Aegis is now", gui.achpBuff and "enabled" or "disabled")
end

local function toggleHpOnlyBuff() 
    gui.hpOnlyBuff = not gui.hpOnlyBuff 
    print("Symbol is now", gui.hpOnlyBuff and "enabled" or "disabled")
end

local function toggleAcOnlyBuff() 
    gui.acOnlyBuff = not gui.acOnlyBuff 
    print("Shield is now", gui.acOnlyBuff and "enabled" or "disabled")
end

local function toggleResistMagic() 
    gui.resistMagic = not gui.resistMagic 
    print("Resist Magic is now", gui.resistMagic and "enabled" or "disabled")
end

local function toggleResistFire() 
    gui.resistFire = not gui.resistFire 
    print("Resist Fire is now", gui.resistFire and "enabled" or "disabled")
end

local function toggleResistCold() 
    gui.resistCold = not gui.resistCold 
    print("Resist Cold is now", gui.resistCold and "enabled" or "disabled")
end

local function toggleResistDisease() 
    gui.resistDisease = not gui.resistDisease 
    print("Resist Disease is now", gui.resistDisease and "enabled" or "disabled")
end

local function toggleResistPoison() 
    gui.resistPoison = not gui.resistPoison 
    print("Resist Poison is now", gui.resistPoison and "enabled" or "disabled")
end

local function setResOn()
    gui.useRes = true
    print("Res's are now enabled.")
end

local function setResOff()
    gui.useRes = false
    print("Res's are now disabled.")
    
end

local function toggleUseEpic() 
    gui.useEpic = not gui.useEpic 
    print("Use Epic is now", gui.useEpic and "enabled" or "disabled")
end

local function toggleCombatRes() 
    gui.combatRes = not gui.combatRes 
    print("Combat Res is now", gui.combatRes and "enabled" or "disabled")
end

local function toggleSitMed() 
    gui.sitMed = not gui.sitMed 
    print("Sit Med is now", gui.sitMed and "enabled" or "disabled")
end

local function toggleKarn()
    gui.useKarn = not gui.useKarn
    print("Using Mark of Karn is now", gui.useKarn and "enabled" or "disabled")
end

-- Set functions for sliders
local function setmainhealPct(value)
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

local function setCamp()
    gui.campLocation = nav.setCamp()
end

local function setReturnToCampOn()
    gui.returnToCamp = true
    gui.chaseOn = false
    print("Return to camp is now enabled.")
end

local function setReturnToCampOff()
    gui.returnToCamp = false
    print("Return to camp is now disabled.")
end

local function setCampDistance(value)
    gui.campDistance = tonumber(value) or gui.campDistance
    print("Camp distance set to", gui.campDistance)
end


function commands.init()

mq.bind('/ccExit', toggleExit)
mq.bind('/ccOn', setBotOn)
mq.bind('/ccOff', setBotOff)
mq.bind('/ccSave', setSave)
mq.bind('/ccMainAssist', utils.setMainAssist)
mq.bind('/ccAssistRange', setAssistRange)
mq.bind('/ccMainHeal', togglemainheal)
mq.bind('/ccHoT', toggleUseHoT)
mq.bind('/ccFastHeal', toggleFastHeal)
mq.bind('/ccCompleteHeal', toggleCompleteHeal)
mq.bind('/ccGroupHeal', toggleGroupHeal)
mq.bind('/ccCures', toggleUseCures)
mq.bind('/ccAegis', toggleAchpBuff)
mq.bind('/ccSymbol', toggleHpOnlyBuff)
mq.bind('/ccShield', toggleAcOnlyBuff)
mq.bind('/ccResistMagic', toggleResistMagic)
mq.bind('/ccResistFire', toggleResistFire)
mq.bind('/ccResistCold', toggleResistCold)
mq.bind('/ccResistDisease', toggleResistDisease)
mq.bind('/ccResistPoison', toggleResistPoison)
mq.bind('/ccResOn', setResOn)
mq.bind('/ccResOff', setResOff)
mq.bind('/ccEpic', toggleUseEpic)
mq.bind('/ccCombatRes', toggleCombatRes)
mq.bind('/ccResCorpse', res.manualResurrection)
mq.bind('/ccSitMed', toggleSitMed)
mq.bind('/ccKarn', toggleKarn)

-- Register binds for sliders (requires a value parameter)
mq.bind('/ccMainHealPct', setmainhealPct)
mq.bind('/ccHotPct', setHotPct)
mq.bind('/ccFastHealPct', setFastHealPct)
mq.bind('/ccCompleteHealPct', setCompleteHealPct)
mq.bind('/ccGroupHealPct', setGroupHealPct)
mq.bind('/ccGroupHealNumber', setGroupHealNumber)

-- Nav binds
mq.bind('/ccCampHere', setCamp)
mq.bind('/ccReturnOn', setReturnToCampOn)
mq.bind('/ccReturnOff', setReturnToCampOff)
mq.bind('/ccCampDistance', setCampDistance)
mq.bind('/ccChase', nav.setChaseTargetAndDistance)

end

return commands