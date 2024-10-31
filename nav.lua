local mq = require('mq')
local gui = require('gui')

local nav = {}

local campLocation = nil

-- Function to set the camp location with zone information
function nav.setCamp()
    campLocation = {
        x = mq.TLO.Me.X(),
        y = mq.TLO.Me.Y(),
        z = mq.TLO.Me.Z(),
        zone = mq.TLO.Zone.ShortName()
    }
    print(string.format("Camp location set at your current position in zone %s.", campLocation.zone))
end

-- Function to check distance from camp and return if out of range
function nav.checkCampDistance()
    if gui.returnToCamp and campLocation then
        -- Check if the character is in the same zone as the camp location
        if mq.TLO.Zone.ShortName() ~= campLocation.zone then
            print("Current zone does not match camp zone. Aborting return to camp.")
            return
        end

        -- Retrieve current position
        local currentX = mq.TLO.Me.X()
        local currentY = mq.TLO.Me.Y()

        -- Calculate distance to camp using the distance formula
        local distance = math.sqrt((campLocation.x - currentX)^2 + (campLocation.y - currentY)^2)
        
        -- Check if distance exceeds the camp radius (campDistance)
        if distance > gui.campDistance and not mq.TLO.Me.Casting() then
            mq.cmdf('/nav locyx %f %f distance=5', campLocation.y, campLocation.x)
        
            local startTime = os.time()  -- Record the start time for timeout
            while mq.TLO.Me.Moving() do
                mq.delay(100)
                
                -- Check if 10 seconds have passed
                if os.time() - startTime >= 10 then
                    print("Timeout reached: Stopping navigation to camp.")
                    mq.cmd('/nav stop')
                    break
                end
            end
        
            print("Returning to camp location.")
        end        
    end
end

-- Function to follow a designated member within a specified distance
function nav.chase()
    if gui.chaseTarget ~= "" and gui.chaseDistance then
        local target = mq.TLO.Spawn(gui.chaseTarget)
        if target() and not mq.TLO.Me.Casting() then
            local distance = target.Distance3D()
            if distance > gui.chaseDistance then
                mq.cmdf('/nav id %d distance=5', target.ID())
                while mq.TLO.Me.Moving() do
                    mq.delay(100)
                end
            end
        end
    end
end


-- Define setChaseTargetAndDistance within nav
function nav.setChaseTargetAndDistance(targetName, distance)

    if targetName and targetName ~= "" then
        -- Remove spaces, numbers, and symbols
        targetName = targetName:gsub("[^%a]", "")
        
        -- Capitalize the first letter and make the rest lowercase
        targetName = targetName:sub(1, 1):upper() .. targetName:sub(2):lower()
    end
    
    if targetName == 'off' then
        gui.chaseTarget = ""
        gui.chaseOn = false  -- Uncheck Chase in the GUI
        print("Chase mode disabled.")
    elseif targetName ~= "" then
        local targetSpawn = mq.TLO.Spawn(targetName)
        
        -- Validate target and path existence
        if targetSpawn() and targetSpawn.Type() == 'PC' and mq.TLO.Navigation.PathExists("id " .. targetSpawn.ID())() then
            local distanceNum = tonumber(distance)
            if distanceNum then
                gui.chaseTarget = targetName
                gui.chaseDistance = distanceNum
                gui.returnToCamp = false  -- Disable Return to Camp
                gui.chaseOn = true  -- Check Chase in the GUI
                print(string.format("Chasing %s within %d units.", gui.chaseTarget, gui.chaseDistance))
            else
                print("Invalid distance provided. Usage: /ccChase <targetName> <distance> or /ccChase off")
            end
        else
            print("Error: Invalid target or no navigable path exists to the target.")
        end
    end
end


return nav
