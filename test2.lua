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

--// Función para mantener Auto Skip en ON
local function monitorAutoSkip()
    local player = game.Players.LocalPlayer
    local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
    local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

    -- Activación inicial 6s después de seleccionar dificultad
    task.delay(6, function()
        pcall(function()
            local connections = getconnections(autoSkipButton.MouseButton1Click)
            if connections and #connections > 0 then
                connections[1]:Fire()
                print("[AutoSkip] Activated 6s after difficulty selection")
            end
        end)
    end)

    -- Monitor para mantener Auto Skip ON
    task.spawn(function()
        while true do
            task.wait(1)
            pcall(function()
                local c = autoSkipButton.ImageColor3
                -- Si está OFF (naranja), volver a ON (verde)
                if c.R < 0.6 and c.G < 0.7 and c.B < 0.1 then
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
        -- Activar Auto Skip 6s después
        monitorAutoSkip()
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
        -- Activar Auto Skip 6s después
        monitorAutoSkip()
        for _, p in ipairs(placements) do
            task.delay(p.time, function()
                place