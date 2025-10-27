--// Garden Tower Defense - GRAVEYARD MAP AUTO FARM (WHITELIST + KEY SYSTEM)

--// Whitelist system
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local whitelist = {
    ["holasoy_kier"] = true,
    ["Sugaplum753"] = true,
    ["Nstub1234"] = true,
    ["Girthentersmyvergona"] = true,
    ["Derick12401"] = true,
    ["Threldor"] = true,
    ["Derick12401"] = true,
    ["keraieu"] = true,
    ["PurpPom"] = true,
    ["67cheesy"] = true

}

if not whitelist[plr.Name] then
    plr:Kick("You are not whitelisted.")
    return
end

print(plr.Name .. " is whitelisted. Waiting for key...")

--// Key GUI
local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Enter Key"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(1, -20, 0, 40)
TextBox.Position = UDim2.new(0, 10, 0, 50)
TextBox.PlaceholderText = "Enter Key Here"
TextBox.Text = ""
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 16
TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(200, 200, 200)

local CheckBtn = Instance.new("TextButton", Frame)
CheckBtn.Size = UDim2.new(1, -20, 0, 40)
CheckBtn.Position = UDim2.new(0, 10, 0, 100)
CheckBtn.Text = "Check Key"
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 18
CheckBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)

local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(1, -20, 0, 40)
Label.Position = UDim2.new(0, 10, 0, 150)
Label.BackgroundTransparency = 1
Label.Text = ""
Label.Font = Enum.Font.GothamBold
Label.TextSize = 16
Label.TextColor3 = Color3.fromRGB(255, 255, 255)

--// Services
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")
local Workspace = game:GetService("Workspace")
local entities = Workspace:WaitForChild("Map"):WaitForChild("Entities")

-- Track our placed units
_G.myUnitIDs = _G.myUnitIDs or {}
_G.trackingEnabled = false

--=== AUTO SKIP SETUP ===--
local function setupAutoSkip()
    task.delay(6, function()
        pcall(function()
            local gui = plr.PlayerGui:WaitForChild("GameGuiNoInset")
            local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")
            warn("[AutoSkip] Activated 6s after difficulty selection")
            
            spawn(function()
                while _G.trackingEnabled do
                    task.wait(0.8)
                    pcall(function()
                        local c = autoSkipButton.ImageColor3
                        if c.R > 0.8 and c.G > 0.5 then
                            local conns = getconnections(autoSkipButton.MouseButton1Click)
                            if conns and #conns > 0 then
                                conns[1]:Fire()
                                warn("[AutoSkip] Reactivated ON automatically")
                            end
                        end
                    end)
                end
            end)
        end)
    end)
end

-- Get current money
local function getMoney()
    return plr:GetAttribute("Cash") or 0
end

-- Get unit ID from the entity (with retry)
local function getUnitID(unit)
    for attempt = 1, 10 do
        for _, v in ipairs(unit:GetDescendants()) do
            if (v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue")) and string.find(string.lower(v.Name), "id") then
                return v.Value
            end
        end
        for attrName, attrValue in pairs(unit:GetAttributes()) do
            if string.find(string.lower(attrName), "id") then
                return attrValue
            end
        end
        task.wait(0.2)
    end
    return nil
end

-- Monitor for new units and track their IDs
entities.ChildAdded:Connect(function(child)
    if _G.trackingEnabled then
        task.spawn(function()
            task.wait(1)
            if child and child.Parent and string.find(child.Name, "unit_") then
                warn("[DETECTING] Checking unit: " .. child.Name)
                local unitID = getUnitID(child)
                if unitID then
                    table.insert(_G.myUnitIDs, unitID)
                    warn("[✓ TRACKED] Unit ID: " .. unitID .. " | Total: " .. #_G.myUnitIDs)
                else
                    warn("[✗ FAILED] Could not find ID for: " .. child.Name)
                end
            end
        end)
    end
end)

-- Unit placement and upgrade data with conditions
local placements = {} -- Will be generated each game

local completedActions = {}
local unitLevels = {} -- Track current level of each unit
local upgradeDelays = {} -- Random delays for each game
local waitingForLevel = {} -- Track if we're waiting for a specific level

local function generateRandomDelays()
    upgradeDelays = {}
    for i = 1, #placements do
        if placements[i].type == "upgrade" then
            -- Random delay between 0.4 and 0.99 seconds for each upgrade
            upgradeDelays[i] = 0.4 + (math.random() * 0.59)
        end
    end
    warn("[DELAYS] Generated random upgrade delays for this game")
end

-- Check if a unit has reached target level
local function hasReachedLevel(unitIndex, targetLevel)
    return (unitLevels[unitIndex] or 1) >= targetLevel
end

-- Generate random position with slight variation
local function randomizePosition(basePosition, variation)
    variation = variation or 2 -- Default 2 studs variation
    local randomX = basePosition.X + (math.random() * variation * 2 - variation)
    local randomZ = basePosition.Z + (math.random() * variation * 2 - variation)
    return Vector3.new(randomX, basePosition.Y, randomZ)
end

-- Try to place unit with position retry
local function tryPlaceUnit(unit, basePosition, unitIndex, maxAttempts)
    maxAttempts = maxAttempts or 5
    
    for attempt = 1, maxAttempts do
        local randomPos = randomizePosition(basePosition, 2.5)
        local data = {
            CF = CFrame.new(randomPos.X, randomPos.Y, randomPos.Z, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1),
            Rotation = 180,
            Valid = true,
            Position = randomPos
        }
        
        local success, result = pcall(function()
            return remotes.PlaceUnit:InvokeServer(unit, data)
        end)
        
        -- Check if placement was successful (result should not be false or nil)
        if success and result then
            warn("[✓ PLACED] " .. unit .. " #" .. unitIndex .. " at: " .. tostring(randomPos) .. " (Attempt " .. attempt .. ")")
            return true, unitIndex
        else
            -- Check if error message indicates placement issue
            local errorMsg = tostring(result)
            if errorMsg:find("can't place") or errorMsg:find("Cannot place") or not result then
                warn("[✗ RETRY] Attempt " .. attempt .. " failed for Unit #" .. unitIndex .. " - trying new position...")
                task.wait(0.3)
            else
                -- Unknown error, might be successful
                warn("[✓ PLACED] " .. unit .. " #" .. unitIndex .. " (Attempt " .. attempt .. ", assuming success)")
                return true, unitIndex
            end
        end
    end
    
    warn("[✗ FAILED] Could not place Unit #" .. unitIndex .. " after " .. maxAttempts .. " attempts")
    return false, nil
end

-- Generate randomized placement data for this game
local function generateRandomPlacements()
    local randomPlacements = {
        -- Rainbow Tomato #1 - Randomized position
        {
            type = "place",
            requiredMoney = 100,
            unit = "unit_tomato_rainbow",
            basePosition = Vector3.new(-344.7191162109375, 61.680301666259766, -702.30859375),
            unitIndex = 1
        },
        {type = "upgrade", requiredMoney = 125, unitIndex = 1, targetLevel = 2},
        {type = "upgrade", requiredMoney = 175, unitIndex = 1, targetLevel = 3},
        
        -- Rainbow Tomato #2 - Randomized position
        {
            type = "place",
            requiredMoney = 100,
            unit = "unit_tomato_rainbow",
            basePosition = Vector3.new(-351.1462097167969, 61.68030548095703, -711.151123046875),
            unitIndex = 2,
            waitForUnit = 1,
            waitForLevel = 3
        },
        {type = "upgrade", requiredMoney = 125, unitIndex = 2, targetLevel = 2},
        {type = "upgrade", requiredMoney = 175, unitIndex = 2, targetLevel = 3},
        {type = "upgrade", requiredMoney = 350, unitIndex = 2, targetLevel = 4},
        {type = "upgrade", requiredMoney = 500, unitIndex = 2, targetLevel = 5},
        
        {type = "upgrade", requiredMoney = 350, unitIndex = 1, targetLevel = 4, waitForUnit = 2, waitForLevel = 5},
        {type = "upgrade", requiredMoney = 500, unitIndex = 1, targetLevel = 5},
        
        -- Rainbow Tomato #3 - Randomized position
        {
            type = "place",
            requiredMoney = 100,
            unit = "unit_tomato_rainbow",
            basePosition = Vector3.new(-334.91607666015625, 61.6803092956543, -721.29736328125),
            unitIndex = 3,
            waitForUnit = 1,
            waitForLevel = 5
        },
        {type = "upgrade", requiredMoney = 125, unitIndex = 3, targetLevel = 2},
        {type = "upgrade", requiredMoney = 175, unitIndex = 3, targetLevel = 3},
        {type = "upgrade", requiredMoney = 350, unitIndex = 3, targetLevel = 4},
        {type = "upgrade", requiredMoney = 500, unitIndex = 3, targetLevel = 5},
        
        -- Dragon Golem #1 - Randomized position
        {
            type = "place",
            requiredMoney = 6000,
            unit = "unit_golem_dragon",
            basePosition = Vector3.new(-319.2539978027344, 61.68030548095703, -720.3961181640625),
            unitIndex = 4
        },
        
        -- Dragon Golem #2 - Randomized position
        {
            type = "place",
            requiredMoney = 6000,
            unit = "unit_golem_dragon",
            basePosition = Vector3.new(-331.4523620605469, 61.680301666259766, -735.6544799804688),
            unitIndex = 5
        },
        
        -- Dragon Golem #3 - Randomized position
        {
            type = "place",
            requiredMoney = 6000,
            unit = "unit_golem_dragon",
            basePosition = Vector3.new(-319.48638916015625, 61.68030548095703, -734.1026000976562),
            unitIndex = 6
        }
    }
    
    -- Generate random positions for each placement
    for i, action in ipairs(randomPlacements) do
        if action.type == "place" and action.basePosition then
            -- Store base position for retry logic, don't generate data yet
            action.needsPlacement = true
        end
    end
    
    return randomPlacements
end

local function moneyBasedActions(sellTime)
    local gameStartTime = tick()
    
    task.spawn(function()
        while _G.trackingEnabled do
            task.wait(0.5)
            
            local currentMoney = getMoney()
            local elapsedTime = tick() - gameStartTime
            
            -- Debug every 5 seconds
            if math.floor(tick()) % 5 == 0 then
                warn("[DEBUG] Time: " .. string.format("%.1f", elapsedTime) .. "s | Units: " .. #_G.myUnitIDs .. " | Money: $" .. currentMoney)
            end
            
            -- Process all actions in order
            for i, action in ipairs(placements) do
                if not completedActions[i] then
                    -- Check if we need to wait for another unit to reach a level
                    if action.waitForUnit and action.waitForLevel then
                        if not hasReachedLevel(action.waitForUnit, action.waitForLevel) then
                            -- Skip this action for now, wait for condition
                            continue
                        end
                    end
                    
                    currentMoney = getMoney()
                    
                    if currentMoney >= action.requiredMoney then
                        if action.type == "place" then
                            -- Place unit with retry logic
                            local success, placedUnitIndex = tryPlaceUnit(action.unit, action.basePosition, action.unitIndex, 5)
                            
                            if success and placedUnitIndex then
                                completedActions[i] = true
                                unitLevels[action.unitIndex] = 1
                                warn("[STATUS] Unit #" .. action.unitIndex .. " placed successfully, moving to next action")
                            else
                                warn("[CRITICAL] Failed to place " .. action.unit .. " #" .. action.unitIndex .. " after all attempts")
                                completedActions[i] = true -- Mark as complete to avoid infinite loop
                            end
                            
                            task.wait(1)
                            
                        elseif action.type == "upgrade" then
                            -- Upgrade unit
                            if #_G.myUnitIDs >= action.unitIndex then
                                local unitID = _G.myUnitIDs[action.unitIndex]
                                local currentLevel = unitLevels[action.unitIndex] or 1
                                
                                -- Only upgrade if we're at the level before target
                                if currentLevel < action.targetLevel then
                                    local success = pcall(function()
                                        remotes.UpgradeUnit:InvokeServer(unitID)
                                    end)
                                    
                                    if success then
                                        completedActions[i] = true
                                        unitLevels[action.unitIndex] = action.targetLevel
                                        warn("[UPGRADED] Unit #" .. action.unitIndex .. " → Level " .. action.targetLevel .. " (ID: " .. unitID .. ", Money: $" .. currentMoney .. ")")
                                    end
                                    
                                    -- Use random delay for this specific upgrade
                                    local delay = upgradeDelays[i] or 0.5
                                    task.wait(delay)
                                else
                                    completedActions[i] = true
                                end
                            end
                        end
                    end
                end
            end
            
            -- TIME-BASED SELLING: Sell all units at 2:20 (140 seconds)
            if elapsedTime >= sellTime and not _G.unitsSold then
                _G.unitsSold = true
                
                local randomDelay = 0.5 + (math.random() * 0.5)
                warn("[SELL TIME: 2:20] Waiting " .. string.format("%.2f", randomDelay) .. " seconds before selling...")
                task.wait(randomDelay)
                
                warn("[SELLING] Attempting to sell all units...")
                
                local soldCount = 0
                local targetCount = 6 -- 3 Rainbows + 3 Golems
                
                if #_G.myUnitIDs > 0 then
                    warn("[METHOD 1] Selling " .. #_G.myUnitIDs .. " tracked units...")
                    for i, unitID in ipairs(_G.myUnitIDs) do
                        local success = pcall(function()
                            remotes.SellUnit:InvokeServer(unitID)
                        end)
                        if success then
                            soldCount = soldCount + 1
                            warn("[✓ SOLD] Unit ID: " .. unitID .. " (" .. soldCount .. "/" .. targetCount .. ")")
                            if soldCount >= targetCount then
                                warn("[COMPLETE] All units sold!")
                                break
                            end
                        end
                        task.wait(0.05)
                    end
                else
                    warn("[METHOD 2] No tracked units, trying IDs 1-30...")
                    for unitID = 1, 30 do
                        local success = pcall(function()
                            remotes.SellUnit:InvokeServer(unitID)
                        end)
                        if success then
                            soldCount = soldCount + 1
                            warn("[✓ SOLD] Unit ID: " .. unitID .. " (" .. soldCount .. "/" .. targetCount .. ")")
                            if soldCount >= targetCount then
                                warn("[COMPLETE] All units sold!")
                                break
                            end
                        end
                        local randomWait = 0.3 + (math.random() * 0.2)
                        task.wait(randomWait)
                    end
                end
                
                _G.myUnitIDs = {}
                warn("[CLEANUP] Selling complete - Sold " .. soldCount .. " units")
                break
            end
        end
    end)
end

local function setupGame(tickSpeed)
    pcall(function()
        remotes.LobbySetMap_6:InvokeServer("map_graveyard")
        warn("[MAP] Set to Graveyard")
    end)
    
    task.wait(0.25)
    
    remotes.PlaceDifficultyVote:InvokeServer("dif_impossible")
    warn("[DIFFICULTY] Set to Impossible")
    
    task.wait(0.25)
    
    remotes.ChangeTickSpeed:InvokeServer(tickSpeed)
    warn("[SPEED] Set to " .. tickSpeed .. "x")
    
    setupAutoSkip()
end

--=== 3X SPEED SCRIPT ===--
function load3xScript()
    warn("========================================")
    warn("[SYSTEM] Starting 3x Speed Script - Graveyard")
    warn("========================================")
    
    while true do
        _G.myUnitIDs = {}
        _G.unitsSold = false
        completedActions = {}
        unitLevels = {}
        _G.trackingEnabled = true
        
        -- Generate random delays for this game
        generateRandomDelays()
        
        setupGame(3)
        
        task.wait(1.5)
        
        -- Generate random placements for this game
        placements = generateRandomPlacements()
        
        -- Sell at 2:17.5 (137.5 seconds) - 1 second earlier than before
        moneyBasedActions(137.5)
        
        -- Restart at 2:40 (160 seconds)
        warn("[WAITING] Game running... will restart at 2:40")
        task.wait(160)
        
        warn("[GAME ENDED] Waiting 4 seconds before restarting...")
        task.wait(4)
        
        warn("[RESTART] Clicking Play Again...")
        _G.trackingEnabled = false
        
        pcall(function()
            remotes.RestartGame:InvokeServer()
        end)
        
        task.wait(4)
    end
end

--=== 2X SPEED SCRIPT ===--
function load2xScript()
    warn("========================================")
    warn("[SYSTEM] Starting 2x Speed Script - Graveyard")
    warn("========================================")
    
    while true do
        _G.myUnitIDs = {}
        _G.unitsSold = false
        completedActions = {}
        unitLevels = {}
        _G.trackingEnabled = true
        
        -- Generate random delays for this game
        generateRandomDelays()
        
        setupGame(2)
        
        task.wait(1.5)
        
        -- Generate random placements for this game
        placements = generateRandomPlacements()
        
        -- Sell at 3:25.5 (205.5 seconds)
        moneyBasedActions(205.5)
        
        -- Restart at 3:50 (230 seconds)
        warn("[WAITING] Game running... will restart at 3:50")
        task.wait(230)
        
        warn("[GAME ENDED] Waiting 6 seconds before restarting...")
        task.wait(6)
        
        warn("[RESTART] Clicking Play Again...")
        _G.trackingEnabled = false
        
        pcall(function()
            remotes.RestartGame:InvokeServer()
        end)
        
        task.wait(4)
    end
end

--=== SPEED MENU ===--
local function showSpeedMenu()
    Title.Text = "Select Speed - Graveyard"
    TextBox.Visible = false
    CheckBtn.Visible = false
    Label.Visible = false

    local btn2x = Instance.new("TextButton", Frame)
    btn2x.Size = UDim2.new(0.45, 0, 0, 50)
    btn2x.Position = UDim2.new(0.05, 0, 0.5, -25)
    btn2x.Text = "2x Speed"
    btn2x.Font = Enum.Font.GothamBold
    btn2x.TextSize = 18
    btn2x.BackgroundColor3 = Color3.fromRGB(80, 160, 250)

    local btn3x = Instance.new("TextButton", Frame)
    btn3x.Size = UDim2.new(0.45, 0, 0, 50)
    btn3x.Position = UDim2.new(0.5, 0, 0.5, -25)
    btn3x.Text = "3x Speed"
    btn3x.Font = Enum.Font.GothamBold
    btn3x.TextSize = 18
    btn3x.BackgroundColor3 = Color3.fromRGB(250, 120, 120)

    btn2x.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        load2xScript()
    end)

    btn3x.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        load3xScript()
    end)
end

--=== KEY CHECK ===--
CheckBtn.MouseButton1Click:Connect(function()
    if TextBox.Text == "candy" then
        Label.Text = "Key Accepted!"
        Label.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.delay(1, showSpeedMenu)
    else
        TextBox.Text = ""
        Label.Text = "Invalid Key!"
        Label.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

--=== LOADSTRINGS (Outside loops - loaded once) ===--
task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/HkAmPckQ"))()
        warn("[LoadString] FPS Unlocker loaded")
    end)
end)

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
        warn("[LoadString] Anti-AFK loaded")
    end)
end)
