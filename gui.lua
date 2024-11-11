local mq = require('mq')
local ImGui = require('ImGui')


local charName = mq.TLO.Me.Name()
local configPath = mq.configDir .. '/' .. 'ConvCLR_'.. charName .. '_config.lua'
local config = {}

local gui = {}

gui.isOpen = true
-- Initialize GUI default values
local function setDefaultConfig()
    gui.botOn = false
    gui.mainAssist = ""
    gui.assistRange = 40
    gui.assistPercent = 95
    gui.mainHeal = false
    gui.mainHealPct = 70
    gui.fastHeal = false
    gui.fastHealPct = 90
    gui.useHoT = false
    gui.hotPct = 95
    gui.completeHeal = false
    gui.completeHealPct = 40
    gui.groupHeal = false
    gui.groupHealPct = 80
    gui.groupHealNumber = 3
    gui.useCures = false
    gui.buffGroup = false
    gui.buffRaid = false
    gui.achpBuff = false
    gui.hpOnlyBuff = false
    gui.acOnlyBuff = false
    gui.resistMagic = false
    gui.resistFire = false
    gui.resistCold = false
    gui.resistDisease = false
    gui.resistPoison = false
    gui.useRes = false
    gui.useEpic = false
    gui.combatRes = false
    gui.sitMed = false
    gui.stopCast = false
    gui.stopCastPct = 95
    gui.returnToCamp = false
    gui.campDistance = 30
    gui.chaseOn = false
    gui.chaseTarget = ""
    gui.chaseDistance = 20
    gui.useKarn = false
    
    -- Extended Target Defaults for Healing
    for i = 1, 5 do
        gui["ExtTargetMainHeal" .. i] = false
        gui["ExtTargetMainHeal" .. i .. "Pct"] = 70
        gui["ExtTargetFastHeal" .. i] = false
        gui["ExtTargetFastHeal" .. i .. "Pct"] = 90
        gui["ExtTargetHoT" .. i] = false
        gui["ExtTargetHoT" .. i .. "Pct"] = 95
        gui["ExtTargetCompleteHeal" .. i] = false
        gui["ExtTargetCompleteHeal" .. i .. "Pct"] = 40
        gui["ExtTargetCures" .. i] = false
    end
end

-- Save configuration to file
function gui.saveConfig()
    for key, value in pairs(gui) do
        config[key] = value
    end
    mq.pickle(configPath, config)  -- Serialize `config` to the config file
    print("Configuration saved to " .. configPath)
end

-- Load configuration from file or initialize defaults
local function loadConfig()
    local configData, err = loadfile(configPath)
    if configData then
        config = configData() or {}
        for key, value in pairs(config) do
            gui[key] = value
        end
    else
        print("Config file not found. Initializing with defaults.")
        setDefaultConfig()
        gui.saveConfig()  -- Save defaults if the config file doesn't exist
    end
end

-- Initialize GUI state from config
loadConfig()

function ColoredText(text, color)
    ImGui.TextColored(color[1], color[2], color[3], color[4], text)
end


-- Main GUI rendering function
local function clericControlGUI()
    gui.isOpen, _ = ImGui.Begin("Convergence Cleric", gui.isOpen, 2)

    if not gui.isOpen then
        mq.exit()
    end

    ImGui.SetWindowSize(440, 600)

    gui.botOn = ImGui.Checkbox("Bot On", gui.botOn or false)

    ImGui.SameLine()

    if ImGui.Button("Save Config") then
        gui.saveConfig()
    end

    ImGui.Spacing()
    if ImGui.CollapsingHeader("Assist Settings") then
    ImGui.Spacing()
        ImGui.SetNextItemWidth(100)
        gui.mainAssist = ImGui.InputText("Main Assist", gui.mainAssist)
        if gui.mainAssist ~= "" then
            gui.assistMelee = ImGui.Checkbox("Melee", gui.assistMelee or false)
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            gui.assistRange = ImGui.SliderInt("Assist Range", gui.assistRange, 5, 100)
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            gui.assistPercent= ImGui.SliderInt("Assist %", gui.assistPercent, 5, 100)
        end
    end

    ImGui.Spacing()
    if ImGui.CollapsingHeader("Heal Settings") then
    ImGui.Spacing()

        -- Main Heal Settings with Extended Targets
        gui.mainHeal = ImGui.Checkbox("Main Heal", gui.mainHeal or false)
        if gui.mainHeal then
            ImGui.SetNextItemWidth(100)
            ImGui.SameLine()
            gui.mainHealPct = ImGui.SliderInt("MH %", gui.mainHealPct, 1, 100)
            ImGui.Spacing()
            if ImGui.CollapsingHeader("Main Heal - Extended Target Settings") then
                for i = 1, 5 do
                    gui["ExtTargetMainHeal" .. i] = ImGui.Checkbox("MH Ext Target " .. i, gui["ExtTargetMainHeal" .. i] or false)
                    if gui["ExtTargetMainHeal" .. i] then
                        ImGui.SameLine()
                        ImGui.SetNextItemWidth(100)
                        gui["ExtTargetMainHeal" .. i .. "Pct"] = ImGui.SliderInt("MH Ext Target " .. i .. " %", gui["ExtTargetMainHeal" .. i .. "Pct"] or 70, 1, 100)
                    end
                end
            end
        end

        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Spacing()

        -- Fast Heal Settings with Extended Targets
        gui.fastHeal = ImGui.Checkbox("Fast Heal", gui.fastHeal or false)
        if gui.fastHeal then
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            gui.fastHealPct = ImGui.SliderInt("FH %", gui.fastHealPct, 1, 100)
            ImGui.Spacing()
            if ImGui.CollapsingHeader("Fast Heal - Extended Target Settings") then
                for i = 1, 5 do
                    gui["ExtTargetFastHeal" .. i] = ImGui.Checkbox("FH Ext Target " .. i, gui["ExtTargetFastHeal" .. i] or false)
                    if gui["ExtTargetFastHeal" .. i] then
                        ImGui.SameLine()
                        ImGui.SetNextItemWidth(100)
                        gui["ExtTargetFastHeal" .. i .. "Pct"] = ImGui.SliderInt("FH Ext Target " .. i .. " %", gui["ExtTargetFastHeal" .. i .. "Pct"] or 90, 1, 100)
                    end
                end
            end
        end

        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Spacing()

        -- HoT Settings with Extended Targets
        gui.useHoT = ImGui.Checkbox("HoT", gui.useHoT or false)
        if gui.useHoT then
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            gui.hotPct = ImGui.SliderInt("HoT %", gui.hotPct, 1, 100)
            ImGui.Spacing()
            if ImGui.CollapsingHeader("HoT - Extended Target Settings") then
                for i = 1, 5 do
                    gui["ExtTargetHoT" .. i] = ImGui.Checkbox("HoT Ext Target " .. i, gui["ExtTargetHoT" .. i] or false)
                    if gui["ExtTargetHoT" .. i] then
                        ImGui.SameLine()
                        ImGui.SetNextItemWidth(100)
                        gui["ExtTargetHoT" .. i .. "Pct"] = ImGui.SliderInt("HoT Ext Target " .. i .. " %", gui["ExtTargetHoT" .. i .. "Pct"] or 95, 1, 100)
                    end
                end
            end
        end

        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Spacing()

        -- Complete Heal Settings with Extended Targets
        gui.completeHeal = ImGui.Checkbox("Complete Heal", gui.completeHeal or false)
        if gui.completeHeal then
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            gui.completeHealPct = ImGui.SliderInt("CH %", gui.completeHealPct, 1, 100)
            ImGui.Spacing()
            if ImGui.CollapsingHeader("Complete Heal - Extended Target Settings") then
                for i = 1, 5 do
                    gui["ExtTargetCompleteHeal" .. i] = ImGui.Checkbox("CH Ext Target " .. i, gui["ExtTargetCompleteHeal" .. i] or false)
                    if gui["ExtTargetCompleteHeal" .. i] then
                        ImGui.SameLine()
                        ImGui.SetNextItemWidth(100)
                        gui["ExtTargetCompleteHeal" .. i .. "Pct"] = ImGui.SliderInt("CH Ext Target " .. i .. " %", gui["ExtTargetCompleteHeal" .. i .. "Pct"] or 40, 1, 100)
                    end
                end
            end
        end

        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Spacing()

        gui.groupHeal = ImGui.Checkbox("Group Heal", gui.groupHeal or false)
            if gui.groupHeal then
                ImGui.SameLine()
                ImGui.SetNextItemWidth(100)
                gui.groupHealPct = ImGui.SliderInt("GH %", gui.groupHealPct, 1, 100)
                
                ImGui.SameLine()
                ImGui.SetNextItemWidth(100)
                gui.groupHealNumber = ImGui.SliderInt("#Hurt", gui.groupHealNumber, 1, 5)
            end

        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Spacing()

        gui.useCures = ImGui.Checkbox("Cures", gui.useCures or false)
        if gui.useCures then
            ImGui.Spacing()
            if ImGui.CollapsingHeader("Cure - Extended Target Settings") then
                for i = 1, 5 do
                    gui["ExtTargetCures" .. i] = ImGui.Checkbox("Cure Ext Target " .. i, gui["ExtTargetCures" .. i] or false)
                end
            end
        end
    end

    ImGui.Spacing()
    if ImGui.CollapsingHeader("Buff Settings") then
    ImGui.Spacing()

        -- Checkbox for Buff Group
        gui.buffGroup = ImGui.Checkbox("Buff Group", gui.buffGroup or false)
        if gui.buffGroup then
            gui.buffRaid = false
        end

        ImGui.SameLine()

        -- Checkbox for Buff Raid
        gui.buffRaid = ImGui.Checkbox("Buff Raid", gui.buffRaid or false)
        if gui.buffRaid then
            gui.buffGroup = false
        end

        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Spacing()

        ColoredText("AC/HP Buffs", {1.0, 1.0, 0.0, 1.0})
        ImGui.Separator()

        gui.achpBuff = ImGui.Checkbox("Aegis", gui.achpBuff or false)
        ImGui.SameLine()
        gui.hpOnlyBuff = ImGui.Checkbox("Symbol", gui.hpOnlyBuff or false)
        ImGui.SameLine()
        gui.acOnlyBuff = ImGui.Checkbox("Shield", gui.acOnlyBuff or false)
        ImGui.Separator()

        ColoredText("Resist Buffs", {1.0, 1.0, 0.0, 1.0})
        ImGui.Separator()

        gui.resistMagic = ImGui.Checkbox("Magic", gui.resistMagic or false)
        ImGui.SameLine()
        gui.resistFire = ImGui.Checkbox("Fire", gui.resistFire or false)
        ImGui.SameLine()
        gui.resistCold = ImGui.Checkbox("Cold", gui.resistCold or false)
        ImGui.SameLine()
        gui.resistDisease = ImGui.Checkbox("Disease", gui.resistDisease or false)
        ImGui.SameLine()
        gui.resistPoison = ImGui.Checkbox("Poison", gui.resistPoison or false)
        ImGui.Separator()
    end

    ImGui.Spacing()
    if ImGui.CollapsingHeader("Res Settings") then
    ImGui.Spacing()

        gui.useRes = ImGui.Checkbox("Res", gui.useRes or false)
            if gui.useRes then
                ImGui.SameLine()
                gui.useEpic = ImGui.Checkbox("Epic", gui.useEpic or false)
                ImGui.SameLine()
                gui.combatRes = ImGui.Checkbox("Combat Res", gui.combatRes or false)
                    if gui.combatRes and not gui.useEpic then
                        gui.useKarn = false
                    end
            end
    end

    ImGui.Spacing()
    if ImGui.CollapsingHeader("Nav Settings") then
    ImGui.Spacing()
    
        -- Track the previous states of returnToCamp and chaseOn to detect changes
        local previousReturnToCamp = gui.returnToCamp or false
        local previousChaseOn = gui.chaseOn or false

        -- Checkbox for Return to Camp with mutual exclusivity and clearing camp location if unchecked
        local currentReturnToCamp = ImGui.Checkbox("Return To Camp", gui.returnToCamp or false)
        if currentReturnToCamp ~= previousReturnToCamp then
            gui.returnToCamp = currentReturnToCamp
                if gui.returnToCamp then
                    gui.chaseOn = false  -- Disable Chase if Return to Camp is enabled
                else
                    local nav = require('nav')
                    nav.campLocation = nil  -- Clear camp location when Return to Camp is disabled
                    print("Camp location cleared.")
                end
            previousReturnToCamp = currentReturnToCamp  -- Update previous state
        end

        if gui.returnToCamp then
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            gui.campDistance = ImGui.SliderInt("Camp Distance", gui.campDistance, 5, 200)
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            if ImGui.Button("Camp Here") then
                local nav = require('nav')
                nav.setCamp()
            end
        end

        -- Checkbox for Chase with mutual exclusivity
        local currentChaseOn = ImGui.Checkbox("Chase", gui.chaseOn or false)
        if currentChaseOn ~= previousChaseOn then
            -- Update the GUI state and handle mutual exclusivity
            gui.chaseOn = currentChaseOn
                if gui.chaseOn then
                    local nav = require('nav')
                    gui.returnToCamp = false  -- Disable Return to Camp if Chase is enabled
                    nav.campLocation = nil  -- Clear camp location when Return to Camp is disabled
                    print("Camp location cleared.")
                end
            previousChaseOn = currentChaseOn  -- Update previous state
        end

        if gui.chaseOn then
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            gui.chaseTarget = ImGui.InputText("Name", gui.chaseTarget)
            ImGui.SameLine()
            ImGui.SetNextItemWidth(100)
            gui.chaseDistance = ImGui.SliderInt("Chase Distance", gui.chaseDistance, 5, 200)
        end
    end

    ImGui.Spacing()
    if ImGui.CollapsingHeader("Misc Settings") then
    ImGui.Spacing()
        gui.sitMed = ImGui.Checkbox("Sit Med", gui.sitMed or false)
        ImGui.Spacing()
        gui.stopCast = ImGui.Checkbox("Stop Cast", gui.stopCast or false)
            if gui.stopCast then
                ImGui.SameLine()
                ImGui.SetNextItemWidth(100)
                gui.stopCastPct = ImGui.SliderInt("Stop Cast %", gui.stopCastPct, 1, 100)
            end
        gui.useKarn = ImGui.Checkbox("Mark of Karn", gui.useKarn or false)
            if gui.useKarn and not gui.useEpic then
                gui.combatRes = false
            end
    end

    ImGui.End()
end

gui.clericControlGUI = clericControlGUI

return gui