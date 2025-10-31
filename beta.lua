--// Garden Tower Defense - FARM MAP UNIFIED - AUTO DETECTION + COUNTER

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")
local Workspace = game:GetService("Workspace")
local entities = Workspace:WaitForChild("Map"):WaitForChild("Entities")

_G.myUnitIDs = _G.myUnitIDs or {}
_G.trackingEnabled = false
_G.gamesCompleted = _G.gamesCompleted or 0

local function createAFKGui()
    local existingGui = plr.PlayerGui:FindFirstChild("AFK_Info")
    if existingGui then existingGui:Destroy() end
    
    local leaderstats = plr:WaitForChild("leaderstats", 10)
    local seeds = leaderstats and leaderstats:FindFirstChild("Seeds")
    
    local AFKGui = Instance.new("ScreenGui")
    AFKGui.Name = "AFK_Info"
    AFKGui.ResetOnSpawn = false
    AFKGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    AFKGui.DisplayOrder = 999999
    AFKGui.Parent = plr:WaitForChild("PlayerGui")
    
    local InfoFrame = Instance.new("Frame")
    InfoFrame.Size = UDim2.new(0, 180, 0, 105)
    InfoFrame.Position = UDim2.new(1, -190, 0, 10)
    InfoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    InfoFrame.BackgroundTransparency = 0.2
    InfoFrame.BorderSizePixel = 0
    InfoFrame.Active = true
    InfoFrame.Draggable = true
    InfoFrame.ZIndex = 999999
    InfoFrame.Parent = AFKGui
    
    local UICorner = Instance.new("UICorner", InfoFrame)
    UICorner.CornerRadius = UDim.new(0, 8)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 20)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "AFK Info"
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.ZIndex = 1000000
    TitleLabel.Parent = InfoFrame
    
    local SeedLabel = Instance.new("TextLabel")
    SeedLabel.Size = UDim2.new(1, -10, 0, 25)
    SeedLabel.Position = UDim2.new(0, 5, 0, 25)
    SeedLabel.BackgroundTransparency = 1
    SeedLabel.Font = Enum.Font.Gotham
    SeedLabel.TextSize = 14
    SeedLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
    SeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SeedLabel.ZIndex = 1000000
    SeedLabel.Parent = InfoFrame
    
    local GamesLabel = Instance.new("TextLabel")
    GamesLabel.Size = UDim2.new(1, -10, 0, 25)
    GamesLabel.Position = UDim2.new(0, 5, 0, 50)
    GamesLabel.BackgroundTransparency = 1
    GamesLabel.Font = Enum.Font.Gotham
    GamesLabel.TextSize = 14
    GamesLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    GamesLabel.TextXAlignment = Enum.TextXAlignment.Left
    GamesLabel.ZIndex = 1000000
    GamesLabel.Parent = InfoFrame
    
    local TimerLabel = Instance.new("TextLabel")
    TimerLabel.Size = UDim2.new(1, -10, 0, 25)
    TimerLabel.Position = UDim2.new(0, 5, 0, 75)
    TimerLabel.BackgroundTransparency = 1
    TimerLabel.Font = Enum.Font.Gotham
    TimerLabel.TextSize = 14
    TimerLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    TimerLabel.TextXAlignment = Enum.TextXAlignment.Left
    TimerLabel.ZIndex = 1000000
    TimerLabel.Parent = InfoFrame
    
    if seeds then
        local function updateSeeds()
            SeedLabel.Text = "Seeds: " .. tostring(seeds.Value)
        end
        updateSeeds()
        seeds:GetPropertyChangedSignal("Value"):Connect(updateSeeds)
    else
        SeedLabel.Text = "Seeds: N/A"
    end
    
    _G.updateGamesCounter = function(count)
        GamesLabel.Text = "Games: " .. tostring(count)
    end
    _G.updateGamesCounter(_G.gamesCompleted or 0)
    
    local startTime = os.clock()
    task.spawn(function()
        while task.wait(1) do
            local elapsed = math.floor(os.clock() - startTime)
            local mins = math.floor(elapsed / 60)
            local secs = elapsed % 60
            TimerLabel.Text = string.format("AFK Time: %02d:%02d", mins, secs)
        end
    end)
end

task.spawn(function()
    task.wait(2)
    pcall(createAFKGui)
end)

local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 350, 0, 200)
Frame.Position = UDim2.new(0.5, -175, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local UICorner = Instance.new("UICorner", Frame)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "Select Unit Type"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

local btnRainbow = Instance.new("TextButton", Frame)
btnRainbow.Size = UDim2.new(0.9, 0, 0, 60)
btnRainbow.Position = UDim2.new(0.05, 0, 0.35, 0)
btnRainbow.Text = "Rainbow Tomato"
btnRainbow.Font = Enum.Font.GothamBold
btnRainbow.TextSize = 18
btnRainbow.BackgroundColor3 = Color3.fromRGB(255, 100, 180)

local UICorner2 = Instance.new("UICorner", btnRainbow)
UICorner2.CornerRadius = UDim.new(0, 8)

local btnTomatoPlant = Instance.new("TextButton", Frame)
btnTomatoPlant.Size = UDim2.new(0.9, 0, 0, 60)
btnTomatoPlant.Position = UDim2.new(0.05, 0, 0.65, 0)
btnTomatoPlant.Text = "Tomato Plant"
btnTomatoPlant.Font = Enum.Font.GothamBold
btnTomatoPlant.TextSize = 18
btnTomatoPlant.BackgroundColor3 = Color3.fromRGB(100, 200, 100)

local UICorner3 = Instance.new("UICorner", btnTomatoPlant)
UICorner3.CornerRadius = UDim.new(0, 8)

local function showSpeedMenu(unitType)
    Frame:ClearAllChildren()
    local UICorner = Instance.new("UICorner", Frame)
    UICorner.CornerRadius = UDim.new(0, 10)
    local Title2 = Instance.new("TextLabel", Frame)
    Title2.Size = UDim2.new(1, 0, 0, 40)
    Title2.BackgroundTransparency = 1
    Title2.Text = "Select Speed - " .. unitType
    Title2.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title2.Font = Enum.Font.GothamBold
    Title2.TextSize = 20
    local btn2x = Instance.new("TextButton", Frame)
    btn2x.Size = UDim2.new(0.45, 0, 0, 60)
    btn2x.Position = UDim2.new(0.05, 0, 0.45, 0)
    btn2x.Text = "2x Speed"
    btn2x.Font = Enum.Font.GothamBold
    btn2x.TextSize = 18
    btn2x.BackgroundColor3 = Color3.fromRGB(80, 160, 250)
    local UICorner4 = Instance.new("UICorner", btn2x)
    UICorner4.CornerRadius = UDim.new(0, 8)
    local btn3x = Instance.new("TextButton", Frame)
    btn3x.Size = UDim2.new(0.45, 0, 0, 60)
    btn3x.Position = UDim2.new(0.5, 0, 0.45, 0)
    btn3x.Text = "3x Speed"
    btn3x.Font = Enum.Font.GothamBold
    btn3x.TextSize = 18
    btn3x.BackgroundColor3 = Color3.fromRGB(250, 120, 120)
    local UICorner5 = Instance.new("UICorner", btn3x)
    UICorner5.CornerRadius = UDim.new(0, 8)
    return btn2x, btn3x
end

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

local unitLevels = {}
local upgradeDelays = {}

local function generateRandomDelays(unitType)
    upgradeDelays = {}
    local delayCount = unitType == "Rainbow" and 50 or 100
    for i = 1, delayCount do
        upgradeDelays[i] = 0.15 + (math.random() * 0.2)
    end
end

local function randomizePosition(basePosition, variation)
    variation = variation or 1.5
    local randomX = basePosition.X + (math.random() * variation * 2 - variation)
    local randomZ = basePosition.Z + (math.random() * variation * 2 - variation)
    return Vector3.new(randomX, basePosition.Y, randomZ)
end

local function tryPlaceUnit(unit, basePosition, unitIndex, maxAttempts, isFast)
    maxAttempts = maxAttempts or 10
    for attempt = 1, maxAttempts do
        local variationMultiplier = 1 + (attempt - 1) * 0.2
        local randomPos = randomizePosition(basePosition, 1.5 * variationMultiplier)
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
            task.wait(isFast and 0.15 or 0.3)
        end
    end
    return false
end

local rainbowPositions = {
    Vector3.new(-345.869873046875, 61.68030548095703, -116.59803771972656),
    Vector3.new(-341.4617004394531, 61.68030548095703, -105.65262603759766),
    Vector3.new(-325.448486328125, 61.68030548095703, -113.05741119384766),
    Vector3.new(-347.0238037109375, 61.68030548095703, -101.94581604003906),
    Vector3.new(-321.42462158203125, 61.68030548095703, -100.28288269042969),
    Vector3.new(-340.7768859863281, 61.68030548095703, -116.85527801513672),
    Vector3.new(-326.3725891113281, 61.6803092956543, -111.12118530273438),
    Vector3.new(-343.39996337890625, 61.68030548095703, -109.55160522460938),
    Vector3.new(-326.04852294921875, 61.68030548095703, -118.88896179199219),
    Vector3.new(-341.5750732421875, 61.68030548095703, -115.53831481933594)
}

local tomatoPlantPositions = {
    Vector3.new(-326.81658935546875, 61.68030548095703, -105.2947998046875),
    Vector3.new(-326.57305908203125, 61.68030548095703, -110.16496276855469),
    Vector3.new(-340.4522705078125, 61.68030548095703, -102.63774108886719),
    Vector3.new(-341.37030029296875, 61.68030548095703, -108.40327453613281),
    Vector3.new(-330.5658264160156, 61.68030548095703, -107.22344970703125),
    Vector3.new(-331.0650634765625, 61.68030548095703, -112.37507629394531),
    Vector3.new(-325.50054931640625, 61.68030548095703, -114.86784362792969),
    Vector3.new(-340.1313781738281, 61.68030548095703, -112.30937194824219),
    Vector3.new(-330.9828186035156, 61.68030548095703, -115.9708480834961),
    Vector3.new(-345.5301513671875, 61.68030548095703, -105.17726135253906),
    Vector3.new(-341.2877197265625, 61.68030548095703, -116.77902221679688),
    Vector3.new(-345.55413818359375, 61.68030548095703, -111.3570327758789),
    Vector3.new(-327.5501708984375, 61.68030548095703, -118.89196014404297),
    Vector3.new(-339.9394836425781, 61.68030548095703, -120.87809753417969),
    Vector3.new(-345.091064453125, 61.68030548095703, -118.65930938720703),
    Vector3.new(-331.5858154296875, 61.680301666259766, -121.98548889160156),
    Vector3.new(-340.29302978515625, 61.68030548095703, -124.85790252685547),
    Vector3.new(-329.318115234375, 61.68030548095703, -125.80452728271484)
}

local placementCost = 100
local upgradeCosts = {125, 175, 350, 500}

local function placeAndUpgradeSequentially(unitType, unitName, positions, isFast)
    task.spawn(function()
        local totalUnits = #positions
        local waitCheckTime = isFast and 0.2 or 0.3
        local retryTime = isFast and 0.3 or 1
        local trackTimeout = isFast and 8 or 15
        for unitIndex = 1, totalUnits do
            local placed = false
            while not placed do
                while getMoney() < placementCost do
                    task.wait(waitCheckTime)
                end
                placed = tryPlaceUnit(unitName, positions[unitIndex], unitIndex, 10, isFast)
                if not placed then
                    task.wait(retryTime)
                end
            end
            unitLevels[unitIndex] = 1
            local waitTime = 0
            while #_G.myUnitIDs < unitIndex and waitTime < trackTimeout do
                task.wait(waitCheckTime)
                waitTime = waitTime + waitCheckTime
            end
            if #_G.myUnitIDs >= unitIndex then
                local unitID = _G.myUnitIDs[unitIndex]
                for targetLevel = 2, 5 do
                    local cost = upgradeCosts[targetLevel - 1]
                    while getMoney() < cost do
                        task.wait(waitCheckTime)
                    end
                    local upgraded = false
                    while not upgraded do
                        local upgradeSuccess = pcall(function()
                            remotes.UpgradeUnit:InvokeServer(unitID)
                        end)
                        if upgradeSuccess then
                            unitLevels[unitIndex] = targetLevel
                            upgraded = true
                            local delay = upgradeDelays[unitIndex * 10 + targetLevel] or (isFast and 0.25 or 0.6)
                            task.wait(delay)
                        else
                            task.wait(waitCheckTime)
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
        task.wait(0.3)
    end
    if not clicked then
        pcall(function()
            remotes.RestartGame:InvokeServer()
            clicked = true
        end)
    end
    return clicked
end

local function setupGame(tickSpeed)
    pcall(function()
        remotes.LobbySetMap_6:InvokeServer("map_farm")
    end)
    task.wait(0.25)
    remotes.PlaceDifficultyVote:InvokeServer("dif_easy")
    task.wait(0.25)
    remotes.ChangeTickSpeed:InvokeServer(tickSpeed)
    setupAutoSkip()
end

function loadRainbow3x()
    while true do
        _G.myUnitIDs = {}
        unitLevels = {}
        _G.trackingEnabled = true
        generateRandomDelays("Rainbow")
        setupGame(3)
        task.wait(1.5)
        placeAndUpgradeSequentially("Rainbow Tomatoes", "unit_tomato_rainbow", rainbowPositions, true)
        waitForGameEnd()
        task.wait(1)
        _G.trackingEnabled = false
        task.spawn(function()
            _G.gamesCompleted = _G.gamesCompleted + 1
            if _G.updateGamesCounter then
                _G.updateGamesCounter(_G.gamesCompleted)
            end
        end)
        clickPlayAgain()
        task.wait(2)
    end
end

function loadRainbow2x()
    while true do
        _G.myUnitIDs = {}
        unitLevels = {}
        _G.trackingEnabled = true
        generateRandomDelays("Rainbow")
        setupGame(2)
        task.wait(1.5)
        placeAndUpgradeSequentially("Rainbow Tomatoes", "unit_tomato_rainbow", rainbowPositions, true)
        waitForGameEnd()
        task.wait(1)
        _G.trackingEnabled = false
        task.spawn(function()
            _G.gamesCompleted = _G.gamesCompleted + 1
            if _G.updateGamesCounter then
                _G.updateGamesCounter(_G.gamesCompleted)
            end
        end)
        clickPlayAgain()
        task.wait(2)
    end
end

function loadTomatoPlant3x()
    while true do
        _G.myUnitIDs = {}
        unitLevels = {}
        _G.trackingEnabled = true
        generateRandomDelays("TomatoPlant")
        setupGame(3)
        task.wait(1.5)
        placeAndUpgradeSequentially("Tomato Plants", "unit_tomato_plant", tomatoPlantPositions, true)
        waitForGameEnd()
        task.wait(1)
        _G.trackingEnabled = false
        task.spawn(function()
            _G.gamesCompleted = _G.gamesCompleted + 1
            if _G.updateGamesCounter then
                _G.updateGamesCounter(_G.gamesCompleted)
            end
        end)
        clickPlayAgain()
        task.wait(2)
    end
end

function loadTomatoPlant2x()
    while true do
        _G.myUnitIDs = {}
        unitLevels = {}
        _G.trackingEnabled = true
        generateRandomDelays("TomatoPlant")
        setupGame(2)
        task.wait(1.5)
        placeAndUpgradeSequentially("Tomato Plants", "unit_tomato_plant", tomatoPlantPositions, true)
        waitForGameEnd()
        task.wait(1)
        _G.trackingEnabled = false
        task.spawn(function()
            _G.gamesCompleted = _G.gamesCompleted + 1
            if _G.updateGamesCounter then
                _G.updateGamesCounter(_G.gamesCompleted)
            end
        end)
        clickPlayAgain()
        task.wait(2)
    end
end

btnRainbow.MouseButton1Click:Connect(function()
    local btn2x, btn3x = showSpeedMenu("Rainbow Tomato")
    btn2x.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        loadRainbow2x()
    end)
    btn3x.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        loadRainbow3x()
    end)
end)

btnTomatoPlant.MouseButton1Click:Connect(function()
    local btn2x, btn3x = showSpeedMenu("Tomato Plant")
    btn2x.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        loadTomatoPlant2x()
    end)
    btn3x.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        loadTomatoPlant3x()
    end)
end)

task.spawn(function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
    end)
end)