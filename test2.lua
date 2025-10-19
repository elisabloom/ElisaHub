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

--=== SPEED MENU ===--
local function startAutoSkipMonitor()
    local player = game.Players.LocalPlayer
    local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
    local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

    task.spawn(function()
        while true do
            task.wait(0.8) -- revisar cada 0.8 segundos
            pcall(function()
                local c = autoSkipButton.ImageColor3
                -- OFF es naranja: R > 0.4 y G > 0.6
                if c.R > 0.4 and c.G > 0.6 then
                    local connections = getconnections(autoSkipButton.MouseButton1Click)
                    if connections and #connections > 0 then
                        connections[1]:Fire()
                        print("[AutoSkip Monitor] Auto Skip reactivated automatically")
                    end
                end
            end)
        end
    end)
end

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

    local function start2x()
        ScreenGui:Destroy()
        task.delay(6, function()
            startAutoSkipMonitor() -- iniciar monitor después de 6s
        end)
        load2xScript()
    end

    local function start3x()
        ScreenGui:Destroy()
        task.delay(6, function()
            startAutoSkipMonitor() -- iniciar monitor después de 6s
        end)
        load3xScript()
    end

    btn2x.MouseButton1Click:Connect(start2x)
    btn3x.MouseButton1Click:Connect(start3x)
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

--=== GAME SCRIPTS ===--
function load2xScript()
    warn("[System] Loaded 2x Speed Script")
    remotes.ChangeTickSpeed:InvokeServer(2)

    local difficulty = "dif_impossible"
    remotes.PlaceDifficultyVote:InvokeServer(difficulty)

    local placements = {
        -- Tus unidades y tiempos aquí
    }

    local function placeUnit(unitName, slot, data)
        remotes.PlaceUnit:InvokeServer(unitName, data)
    end

    local function startGame()
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
    remotes.PlaceDifficultyVote:InvokeServer(difficulty)

    local placements = {
        -- Tus unidades y tiempos aquí
    }

    local function placeUnit(unitName, slot, data)
        remotes.PlaceUnit:InvokeServer(unitName, data)
    end

    local function startGame()
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

--=== Anti-AFK ===--
loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()