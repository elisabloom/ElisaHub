--// Whitelist system
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local whitelist = {
    ["PurpPum"]= true,
    ["kierbot2"]= true,
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

--// Remotes
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")

-- Función de monitor Auto Skip
local function monitorAutoSkip()
    local player = game.Players.LocalPlayer
    local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
    local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

    -- Activación inicial 6s después
    task.delay(6, function()
        pcall(function()
            local connections = getconnections(autoSkipButton.MouseButton1Click)
            if connections and #connections > 0 then
                connections[1]:Fire()
                print("[AutoSkip] Activated 6s after difficulty selection")
            end
        end)
    end)

    -- Monitor persistente
    task.spawn(function()
        while true do
            task.wait(0.5)
            pcall(function()
                local c = autoSkipButton.ImageColor3
                -- OFF detectado por naranja
                if math.abs(c.R - 0.451) < 0.05 and math.abs(c.G - 0.902) < 0.05 then
                    local connections = getconnections(autoSkipButton.MouseButton1Click)
                    if connections and #connections > 0 then
                        connections[1]:Fire()
                        print("[AutoSkip Monitor] Auto Skip restored to ON")
                    end
                end
            end)
        end
    end)
end

--=== GAME SCRIPTS ===--
local function loadScript(speed)
    remotes.ChangeTickSpeed:InvokeServer(speed)
    warn("[System] Loaded "..speed.."x Speed Script")

    local difficulty = "dif_impossible"
    local placements
    if speed == 2 then
        placements = {
            {time = 29, unit = "unit_lawnmower", slot = "1", data = {Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803055,-123.052032),DistanceAlongPath=248.0065,CF=CFrame.new(-843.87384,62.1803055,-123.052032),Rotation=180}},
            {time = 47, unit = "unit_rafflesia", slot = "2", data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-162.012131),DistanceAlongPath=180.53,CF=CFrame.new(-842.381287,62.1803055,-162.012131),Rotation=180}},
            {time = 85, unit = "unit_rafflesia", slot = "2", data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-164.507538),DistanceAlongPath=178.04,CF=CFrame.new(-842.381287,62.1803055,-164.507538),Rotation=180}},
            {time = 110, unit = "unit_rafflesia", slot = "2", data = {Valid=true,PathIndex=2,Position=Vector3.new(-864.724426,62.1803055,-199.052032),DistanceAlongPath=100.65,CF=CFrame.new(-864.724426,62.1803055,-199.052032),Rotation=180}}
        }
    else
        placements = {
            {time = 23, unit = "unit_lawnmower", slot = "1", data = {Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803055,-123.052032),DistanceAlongPath=248.0065,CF=CFrame.new(-843.87384,62.1803055,-123.052032),Rotation=180}},
            {time = 32, unit = "unit_rafflesia", slot = "2", data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-162.012131),DistanceAlongPath=180.53,CF=CFrame.new(-842.381287,62.1803055,-162.012131),Rotation=180}},
            {time = 57, unit = "unit_rafflesia", slot = "2", data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-164.507538),DistanceAlongPath=178.04,CF=CFrame.new(-842.381287,62.1803055,-164.507538),Rotation=180}},
            {time = 77, unit = "unit_rafflesia", slot = "2", data = {Valid=true,PathIndex=2,Position=Vector3.new(-864.724426,62.1803055,-199.052032),DistanceAlongPath=100.65,CF=CFrame.new(-864.724426,62.1803055,-199.052032),Rotation=180}}
        }
    end

    local function placeUnit(unit)
        remotes.PlaceUnit:InvokeServer(unit.unit, unit.data)
        warn("[Placing] "..unit.unit.." at "..os.clock())
    end

    local function startGame()
        remotes.PlaceDifficultyVote:InvokeServer(difficulty)
        for _, p in ipairs(placements) do
            task.delay(p.time, function()
                placeUnit(p)
            end)
        end
        monitorAutoSkip() -- activa Auto Skip 6s después + monitor
    end

    while true do
        startGame()
        if speed == 2 then
            task.wait(174.5)
        else
            task.wait(128)
        end
        remotes.RestartGame:InvokeServer()
    end
end

--=== SPEED MENU ===--
local function showSpeedMenu()
    Title.Text = "Select Speed"
    TextBox.Visible = false
    CheckBtn.Visible = false

    local btn2x = Instance.new("TextButton", Frame)
    btn2x.Size = UDim2.new(0.45, 0, 0, 50)
    btn2x.Position = UDim2.new(0.05, 0, 0.5, -25)
    btn2x.Text = "2x Speed"
    btn2x.BackgroundColor3 = Color3.fromRGB(80,160,250