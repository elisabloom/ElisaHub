--// Whitelist system
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local whitelist = {
    ["FleonelF100mil"]= true,
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

-- Auto Skip monitor (activa al inicio y revisa cada 1 segundo)
task.spawn(function()
    local player = game.Players.LocalPlayer
    local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
    local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

    local function enableAutoSkip()
        local connections = getconnections(autoSkipButton.MouseButton1Click)
        if connections and #connections > 0 then
            connections[1]:Fire()
        end
    end

    -- Primera activación después de 6 segundos
    task.delay(6, enableAutoSkip)

    -- Loop de monitoreo cada 1 segundo
    while true do
        task.wait(1)
        pcall(enableAutoSkip)
    end
end)

--=== GAME SCRIPTS ===--

function load2xScript()
    warn("[System] Loaded 2x Speed Script")
    remotes.ChangeTickSpeed:InvokeServer(2)

    local difficulty = "dif_impossible"
    local placements = {
        {
            time = 29, unit = "unit_lawnmower", slot = "1",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803055,-123.052032),
                DistanceAlongPath=248.0065,
                CF=CFrame.new(-843.87384,62.1803055,-123.052032,-0,0,1,0,1,-0,-1,0,-0),
                Rotation=180}
        },
        {
            time = 47, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-162.012131),
                DistanceAlongPath=180.53,
                CF=CFrame.new(-842.381287,62.1803055,-162.012131,1,0,0,0,1,0,0,0,1),
                Rotation=180}
        },
        {
            time = 85, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-164.507538),
                DistanceAlongPath=178.04,
                CF=CFrame.new(-842.381287,62.1803055,-164.507538,1,0,0,0,1,0,0,0,1),
                Rotation=180}
        },
        {
            time = 110, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=2,Position=Vector3.new(-864.724426,62.1803055,-199.052032),
                DistanceAlongPath=100.65,
                CF=CFrame.new(-864.724426,62.1803055,-199.052032,-0,0,1,0,1,0,-1,0,0),
                Rotation=180}
        }
    }

    local function placeUnit(unitName, slot, data)
        remotes.PlaceUnit:InvokeServer(unitName, data)
        warn("[Placing] "..unitName.." at "..os.clock())
    end

    local function startGame()
        remotes.PlaceDifficultyVote:InvokeServer(difficulty)
        for _, p in ipairs(placements) do
            task.delay(p.time, function()
                placeUnit(p.unit, p.slot, p.data)
            end)
        end
    end

    while true do
        startGame()
        task.wait(174.5)
        remotes.RestartGame:InvokeServer()
    end
end

function load3xScript()
    warn("[System] Loaded 3x Speed Script")
    remotes.ChangeTickSpeed:InvokeServer(3)

    local difficulty = "dif_impossible"
    local placements = {
        {
            time = 23, unit = "unit_lawnmower", slot = "1",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803055,-123.052032),
                DistanceAlongPath=248.0065,
                CF=CFrame.new(-843.87384,62.1803055,-123.052032,-0,0,1,0,1,-0,-1,0,-0),
                Rotation=180}
        },
        {
            time = 32, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-162.012131),
                DistanceAlongPath=180.53,
                CF=CFrame.new(-842.381287,62.1803055,-162.012131,1,0,0,0,1,0,0,0,1),
                Rotation=180}
        },
        {
            time = 57, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-164.507538),
                DistanceAlongPath=178.04,
                CF=CFrame.new(-842.381287,62.1803055,-164.507538,1,0,0,0,1,0,0,0,1),
                Rotation=180}
        },
        {
            time = 77, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=2,Position=Vector3.new(-864.724426,62.1803055,-199.052032),
                DistanceAlongPath=100.65,
                CF=CFrame.new(-864.724426,62.1803055,-199.052032,-0,0,1,0,1,0,-1,0,0),
                Rotation=180}
        }
    }

    local function placeUnit(unitName, slot, data)
        remotes.PlaceUnit:InvokeServer(unitName, data)
        warn("[Placing] "..unitName.." at "..os.clock())
    end

    local function startGame()
        remotes.PlaceDifficultyVote:InvokeServer(difficulty)
        for _, p in ipairs(placements) do
            task.delay(p.time, function()
                placeUnit(p.unit, p.slot, p.data)
            end)
        end
    end

    while true do
        startGame()
        task.wait(128)
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
    btn2x.BackgroundColor3 = Color3.fromRGB(80,160,250)

    local btn3x = Instance.new("TextButton", Frame)
    btn3x.Size = UDim2.new(0.45, 0, 0, 50)
    btn3x.Position = UDim2.new(0.5, 0, 0.5, -25)
    btn3x.Text = "3x Speed"
    btn3x.BackgroundColor3 = Color3.fromRGB(250,120,120)

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
    if TextBox.Text == "test" then
        Label.Text = "Key Accepted!"
        Label.TextColor3 = Color3.fromRGB(0,255,0)
        task.delay(1, showSpeedMenu)
    else
        TextBox.Text = ""
        Label.Text = "Invalid Key!"
        Label.TextColor3 = Color3.fromRGB(255,0,0)
    end
end)

loadstring(game:HttpGet("https://pastebin.com/raw/HkAmPckQ"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();