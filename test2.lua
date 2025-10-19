--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local plr = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("RemoteFunctions")

--// Whitelist
local whitelist = {
    ["PurpPum"]= true,
    ["kierbot2"]= true,
    ["67cheesy"]= true
}

if not whitelist[plr.Name] then
    plr:Kick("You are not whitelisted.")
    return
end
print(plr.Name .. " is whitelisted. Waiting for key...")

--// GUI Setup
local playerGui = plr:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeyGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0,300,0,200)
Frame.Position = UDim2.new(0.5,-150,0.5,-100)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,40)
Title.BackgroundTransparency = 1
Title.Text = "Enter Key"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Frame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1,-20,0,40)
TextBox.Position = UDim2.new(0,10,0,50)
TextBox.PlaceholderText = "Enter Key Here"
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 16
TextBox.TextColor3 = Color3.fromRGB(0,0,0)
TextBox.BackgroundColor3 = Color3.fromRGB(200,200,200)
TextBox.Parent = Frame

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(1,-20,0,40)
CheckBtn.Position = UDim2.new(0,10,0,100)
CheckBtn.Text = "Check Key"
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 18
CheckBtn.BackgroundColor3 = Color3.fromRGB(100,200,100)
CheckBtn.Parent = Frame

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1,-20,0,40)
Label.Position = UDim2.new(0,10,0,150)
Label.BackgroundTransparency = 1
Label.Text = ""
Label.Font = Enum.Font.GothamBold
Label.TextSize = 16
Label.TextColor3 = Color3.fromRGB(255,255,255)
Label.Parent = Frame

--=== KEY CHECK ===--
local function showSpeedMenu()
    Title.Text = "Select Speed"
    TextBox.Visible = false
    CheckBtn.Visible = false

    local btn2x = Instance.new("TextButton", Frame)
    btn2x.Size = UDim2.new(0.45,0,0,50)
    btn2x.Position = UDim2.new(0.05,0,0.5,-25)
    btn2x.Text = "2x Speed"
    btn2x.BackgroundColor3 = Color3.fromRGB(80,160,250)

    local btn3x = Instance.new("TextButton", Frame)
    btn3x.Size = UDim2.new(0.45,0,0,50)
    btn3x.Position = UDim2.new(0.5,0,0.5,-25)
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

--=== GAME SCRIPTS ===--
local function startGameLoop(waitTime, placements)
    local difficulty = "dif_impossible"

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

        -- Activar Auto Skip después de 6s y mantenerlo en ON
        task.delay(6, function()
            local gui = plr.PlayerGui:WaitForChild("GameGuiNoInset")
            local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

            local function forceAutoSkip()
                local c = autoSkipButton.ImageColor3
                if c.R > 0.4 and c.G < 0.8 then -- OFF naranja
                    local connections = getconnections(autoSkipButton.MouseButton1Click)
                    if connections and #connections > 0 then
                        connections[1]:Fire()
                        print("[AutoSkip] Re-activated automatically")
                    end
                end
            end

            while task.wait(1) do
                pcall(forceAutoSkip)
            end
        end)
    end

    while true do
        startGame()
        task.wait(waitTime)
        remotes.RestartGame:InvokeServer()
    end
end

function load2xScript()
    local placements = {
        {
            time = 29, unit = "unit_lawnmower", slot = "1",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803055,-123.052032),
                DistanceAlongPath=248.0065,
                CF=CFrame.new(-843.87384,62.1803055,-123.052032,0,0,1,0,1,0,-1,0,0),
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
                CF=CFrame.new(-864.724426,62.1803055,-199.052032,0,0,1,0,1,0,-1,0,0),
                Rotation=180}
        }
    }
    remotes.ChangeTickSpeed:InvokeServer(2)
    startGameLoop(174.5, placements)
end

function load3xScript()
    local placements = {
        {
            time = 23, unit = "unit_lawnmower", slot = "1",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803055,-123.052032),
                DistanceAlongPath=248.0065,
                CF=CFrame.new(-843.87384,62.1803055,-123.052032,0,0,1,0,1,0,-1,0,0),
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
                CF=CFrame.new(-864.724426,62.1803055,-199.052032,0,0,1,0,1,0,-1,0,0),
                Rotation=180}
        }
    }
    remotes.ChangeTickSpeed:InvokeServer(3)
    startGameLoop(128, placements)
end

--=== Anti-AFK y Extras ===--
loadstring(game:HttpGet("https://pastebin.com/raw/HkAmPckQ"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();