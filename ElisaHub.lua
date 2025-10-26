--// Garden Tower Defense - DOJO MAP AUTO FARM (WHITELIST + KEY SYSTEM)

--// Whitelist system
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local whitelist = {
    ["holasoy_kier"] = true,
    ["Sugaplum753"] = true,
    ["Nstub1234"] = true,
    ["Girthentersmyvergona"] = true,
    ["Derick12401"] = true,
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
    task.delay(4, function()
        pcall(function()
            local gui = plr.PlayerGui:WaitForChild("GameGuiNoInset")
            local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")
            warn("[AutoSkip] Activated 6s after difficulty selection")
            
            -- Monitor to keep it ON
            spawn(function()
                while _G.trackingEnabled do
                    task.wait(0.8)
                    pcall(function()
                        local c = autoSkipButton.ImageColor3
                        -- If OFF (orange): R>0.8, G>0.5
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

-- Random position generator for Path 1 (between min and max coordinates)
local function getRandomPositionPath1()
    local minPos = Vector3.new(46.63258361816406, -21.75, -49.71086502075195)
    local maxPos = Vector3.new(52.49168014526367, -21.75, -55.56996154785156)
    
    local randomX = minPos.X + math.random() * (maxPos.X - minPos.X)
    local randomZ = minPos.Z + math.random() * (maxPos.Z - minPos.Z)
    local position = Vector3.new(randomX, -21.75, randomZ)
    
    return {
        Valid = true,
        PathIndex = 1,
        Position = position,
        CF = CFrame.new(position.X, position.Y, position.Z, 0.7071068286895752, 0, -0.7071067690849304, -0, 1, -0, 0.7071068286895752, 0, 0.7071067690849304),
        Rotation = 180
    }
end

-- Random position generator for Path 2 (between min and max coordinates)
local function getRandomPositionPath2()
    local minPos = Vector3.new(-54.49039077758789, -21.75, -53.30671691894531)
    local maxPos = Vector3.new(-42.14012908935547, -21.74989891052246, -40.86867141723633)
    
    local randomX = minPos.X + math.random() * (maxPos.X - minPos.X)
    local randomZ = minPos.Z + math.random() * (maxPos.Z - minPos.Z)
    local position = Vector3.new(randomX, -21.75, randomZ)
    
    return {
        Valid = true,
        PathIndex = 2,
        Position = position,
        CF = CFrame.new(position.X, position.Y, position.Z, 0.7071068286895752, 0, 0.7071067690849304, -0, 1, -0, -0.7071068286895752, 0, 0.7071067690849304),
        Rotation = 180
    }
end

-- Unit placement data (money-based) - ONLY 2 UNITS
local unitPlacements = {
    {
        requiredMoney = 1250,
        unit = "unit_rafflesia",
        data = "RANDOM_PATH1",
        id = 1
    },
    {
        requiredMoney = 1250,
        unit = "unit_rafflesia",
        data = "RANDOM_PATH2",
        id = 2
    }
}

-- Upgrade queue (money-based) - Upgrade Path 1 first, then Path 2
local upgradeQueue = {
    {unitIndex = 1, requiredMoney = 8000},
    {unitIndex = 2, requiredMoney = 8000}
}

local placedUnits = {}
local upgradedUnits = {}

local function moneyBasedActions(sellTime)
    local gameStartTime = tick()
    
    task.spawn(function()
        while _G.trackingEnabled do
            task.wait(0.5)
            
            local currentMoney = getMoney()
            local elapsedTime = tick() - gameStartTime
            
            -- Debug: Show time and unit count every 5 seconds
            if math.floor(tick()) % 5 == 0 then
                warn("[DEBUG] Time: " .. string.format("%.1f", elapsedTime) .. "s | Units tracked: " .. #_G.myUnitIDs .. " | Money: $" .. currentMoney)
            end
            
            -- Check for unit placements
            for i, placement in ipairs(unitPlacements) do
                if not placedUnits[i] then
                    currentMoney = getMoney()
                    
                    if currentMoney >= placement.requiredMoney then
                        local placementData = placement.data
                        if placementData == "RANDOM_PATH1" then
                            placementData = getRandomPositionPath1()
                            warn("[RANDOM] Path 1 - Generated random position: " .. tostring(placementData.Position))
                        elseif placementData == "RANDOM_PATH2" then
                            placementData = getRandomPositionPath2()
                            warn("[RANDOM] Path 2 - Generated random position: " .. tostring(placementData.Position))
                        end
                        
                        local success, result = pcall(function()
                            return remotes.PlaceUnit:InvokeServer(placement.unit, placementData)
                        end)
                        
                        if success then
                            placedUnits[i] = true
                            warn("[PLACED] " .. placement.unit .. " #" .. i .. " (Money: $" .. currentMoney .. ")")
                        else
                            warn("[FAILED] " .. placement.unit .. " #" .. i .. " - " .. tostring(result))
                        end
                        
                        task.wait(1)
                    end
                end
            end
            
            -- Check for upgrades
            for i, upgrade in ipairs(upgradeQueue) do
                if not upgradedUnits[i] then
                    currentMoney = getMoney()
                    
                    if currentMoney >= upgrade.requiredMoney then
                        if #_G.myUnitIDs >= upgrade.unitIndex then
                            local unitID = _G.myUnitIDs[upgrade.unitIndex]
                            local success = pcall(function()
                                remotes.UpgradeUnit:InvokeServer(unitID)
                            end)
                            
                            if success then
                                upgradedUnits[i] = true
                                warn("[UPGRADED] Unit #" .. upgrade.unitIndex .. " (ID: " .. unitID .. ") (Money: $" .. currentMoney .. ")")
                            end
                            
                            task.wait(1)
                        end
                    end
                end
            end
            
            -- TIME-BASED SELLING: Sell all units at specified time
            if elapsedTime >= sellTime and not _G.unitsSold then
                _G.unitsSold = true
                
                local randomDelay = 0.5 + (math.random() * 0.5)
                warn("[SELL TIME] Waiting " .. string.format("%.2f", randomDelay) .. " seconds before selling...")
                task.wait(randomDelay)
                
                warn("[SELLING] Attempting to sell all units...")
                
                local soldCount = 0
                local targetCount = 2
                
                if #_G.myUnitIDs > 0 then
                    warn("[METHOD 1] Selling " .. #_G.myUnitIDs .. " tracked units...")
                    for i, unitID in ipairs(_G.myUnitIDs) do
                        local success, err = pcall(function()
                            remotes.SellUnit:InvokeServer(unitID)
                        end)
                        if success then
                            soldCount = soldCount + 1
                            warn("[✓ SOLD] Unit ID: " .. unitID .. " (" .. soldCount .. "/" .. targetCount .. ")")
                            if soldCount >= targetCount then
                                warn("[COMPLETE] All units sold!")
                                break
                            end
                        else
                            warn("[✗ FAILED] Unit ID: " .. unitID)
                        end
                        task.wait(0.05)
                    end
                else
                    warn("[METHOD 2] No tracked units, trying IDs 1-20...")
                    for unitID = 1, 20 do
                        local success = pcall(function()
                            remotes.SellUnit:InvokeServer(unitID)
                        end)
                        if success then
                            soldCount = soldCount + 1
                            warn("[✓ SOLD] Unit ID: " .. unitID .. " (" .. soldCount .. "/" .. targetCount .. ")")
                            if soldCount >= targetCount then
                                warn("[COMPLETE] All units sold, stopping brute force!")
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
        remotes.LobbySetMap_6:InvokeServer("map_dojo")
        warn("[MAP] Set to Dojo")
    end)
    
    task.wait(0.25) -- Reduced from 0.5 to 0.25
    
    remotes.PlaceDifficultyVote:InvokeServer("dif_apocalypse")
    warn("[DIFFICULTY] Set to Apocalypse")
    
    task.wait(0.25) -- Reduced from 0.5 to 0.25
    
    remotes.ChangeTickSpeed:InvokeServer(tickSpeed)
    warn("[SPEED] Set to " .. tickSpeed .. "x")
    
    setupAutoSkip()
end

--=== 3X SPEED SCRIPT ===--
function load3xScript()
    warn("========================================")
    warn("[SYSTEM] Starting 3x Speed Script")
    warn("========================================")
    
    while true do
        _G.myUnitIDs = {}
        _G.unitsSold = false
        placedUnits = {}
        upgradedUnits = {}
        _G.trackingEnabled = true
        
        setupGame(3)
        
        task.wait(1.5) -- Reduced from 3 to 1.5
        
        -- Sell at 1:06 (66 seconds)
        moneyBasedActions(69)
        
        -- Restart at 1:24 (84 seconds)
        warn("[WAITING] Game running... will restart at 1:24")
        task.wait(84)
        
        warn("[RESTART] Game complete, restarting...")
        _G.trackingEnabled = false
        
        pcall(function()
            remotes.RestartGame:InvokeServer()
        end)
        
        task.wait(3) -- Reduced from 8 to 4 seconds
    end
end

--=== 2X SPEED SCRIPT ===--
function load2xScript()
    warn("========================================")
    warn("[SYSTEM] Starting 2x Speed Script")
    warn("========================================")
    
    while true do
        _G.myUnitIDs = {}
        _G.unitsSold = false
        placedUnits = {}
        upgradedUnits = {}
        _G.trackingEnabled = true
        
        setupGame(2)
        
        task.wait(1.5) -- Reduced from 3 to 1.5
        
        -- Sell at 1:31 (91 seconds) - 2 seconds later than before
        moneyBasedActions(96)
        
        -- Restart at 1:52.5 (112.5 seconds) - 1.5 seconds later
        warn("[WAITING] Game running... will restart at 1:52.5")
        task.wait(115)
        
        warn("[RESTART] Game complete, restarting...")
        _G.trackingEnabled = false
        
        pcall(function()
            remotes.RestartGame:InvokeServer()
        end)
        
        task.wait(3)
    end
end

--=== SPEED MENU ===--
local function showSpeedMenu()
    Title.Text = "Select Speed - Dojo"
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
    if TextBox.Text == "dojo" then
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
