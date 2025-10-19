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
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KeyGui"
ScreenGui.Parent = plr:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Enter Key"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.Parent = Frame

local TextBox = Instance.new("TextBox")
TextBox.Size = UDim2.new(1, -20, 0, 40)
TextBox.Position = UDim2.new(0, 10, 0, 50)
TextBox.PlaceholderText = "Enter Key Here"
TextBox.Text = ""
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 16
TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
TextBox.Parent = Frame

local CheckBtn = Instance.new("TextButton")
CheckBtn.Size = UDim2.new(1, -20, 0, 40)
CheckBtn.Position = UDim2.new(0, 10, 0, 100)
CheckBtn.Text = "Check Key"
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 18
CheckBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
CheckBtn.Parent = Frame

local Label = Instance.new("TextLabel")
Label.Size = UDim2.new(1, -20, 0, 40)
Label.Position = UDim2.new(0, 10, 0, 150)
Label.BackgroundTransparency = 1
Label.Text = ""
Label.Font = Enum.Font.GothamBold
Label.TextSize = 16
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.Parent = Frame

--// Remotes
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")

--=== GAME SCRIPTS ===--
function load2xScript()
    warn("[System] Loaded 2x Speed Script")
    remotes.ChangeTickSpeed:InvokeServer(2)

    local difficulty = "dif_impossible"
    local placements = {
        -- agregar tus unidades y tiempos aquí
    }

    local function placeUnit(unitName, slot, data)
        remotes.PlaceUnit:InvokeServer(unitName, data)
        warn("[Placing] "..unitName.." at "..os.clock())
    end

    local function startGame()
        remotes.PlaceDifficultyVote:InvokeServer(difficulty)

        -- Espera 6 segundos y activa Auto Skip seguro
        task.delay(6, function()
            local gui = plr.PlayerGui:WaitForChild("GameGuiNoInset")
            local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")
            -- Activar Auto Skip
            local connections = getconnections(autoSkipButton.MouseButton1Click)
            if connections and #connections > 0 then
                connections[1]:Fire()
            end
            -- Seguro: mantener en ON
            spawn(function()
                while task.wait(1) do
                    local c = autoSkipButton.ImageColor3
                    -- Off = naranja (R=0.45 G=0.90), On = verde (R=1 G=0.666)
                    if c.R < 0.5 and c.G > 0.8 then
                        connections[1]:Fire()
                        print("[AutoSkip Monitor] Auto Skip reactivated")
                    end
                end
            end)
        end)

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
        -- agregar tus unidades y tiempos aquí
    }

    local function placeUnit(unitName, slot, data)
        remotes.PlaceUnit:InvokeServer(unitName, data)
        warn("[Placing] "..unitName.." at "..os.clock())
    end

    local function startGame()
        remotes.PlaceDifficultyVote:InvokeServer(difficulty)

        task.delay(6, function()
            local gui = plr.PlayerGui:WaitForChild("GameGuiNoInset")
            local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")
            local connections = getconnections(autoSkipButton.MouseButton1Click)
            if connections and #connections > 0 then
                connections[1]:Fire()
            end
            spawn(function()
                while task.wait(1) do
                    local c = autoSkipButton.ImageColor3
                    if c.R < 0.5 and c.G > 0.8 then
                        connections[1]:Fire()
                        print("[AutoSkip Monitor] Auto Skip reactivated")
                    end
                end
            end)
        end)

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

--=== KEY CHECK & SPEED MENU ===--
CheckBtn.MouseButton1Click:Connect(function()
    print("[Debug] CheckBtn clicked, TextBox.Text = "..TextBox.Text)
    if TextBox.Text:lower() == "test" then
        Label.Text = "Key Accepted!"
        Label.TextColor3 = Color3.fromRGB(0,255,0)
        task.delay(1, function()
            Title.Text = "Select Speed"
            TextBox.Visible = false
            CheckBtn.Visible = false

            local btn2x = Instance.new("TextButton")
            btn2x.Size = UDim2.new(0.45, 0, 0, 50)
            btn2x.Position = UDim2.new(0.05, 0, 0.5, -25)
            btn2x.Text = "2x Speed"
            btn2x.BackgroundColor3 = Color3.fromRGB(80,160,250)
            btn2x.Parent = Frame

            local btn3x = Instance.new("TextButton")
            btn3x.Size = UDim2.new(0.45, 0, 0, 50)
            btn3x.Position = UDim2.new(0.5, 0, 0.5, -25)
            btn3x.Text = "3x Speed"
            btn3x.BackgroundColor3 = Color3.fromRGB(250,120,120)
            btn3x.Parent = Frame

            btn2x.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
                load2xScript()
            end)

            btn3x.MouseButton1Click:Connect(function()
                ScreenGui:Destroy()
                load3xScript()
            end)
        end)
    else
        TextBox.Text = ""
        Label.Text = "Invalid Key!"
        Label.TextColor3 = Color3.fromRGB(255,0,0)
        print("[Debug] Invalid key entered")
    end
end)

--=== Anti AFK (opcional) ===--
loadstring(game:HttpGet("https://pastebin.com/raw/HkAmPckQ"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();