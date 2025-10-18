--// Whitelist system
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local whitelist = {
    ["wasaorchiquito"] = true,
    ["PurpPom"] = true,
    ["Girthentersmyvergona"] = true,
    ["Sugaplum753"] = true,
    ["Nstub1234"] = true,
    ["VladimirMercer"]= true,
    ["ilyprame"]= true,
    ["lyrachanx"]=true,
    ["menorbom928373"]= true,
    ["holasoy_kier"]= true,
    ["LOSTRALALA771"]= true,
    ["kaique91919"]= true,
    ["67cheesy"]= true,
    ["FleonelF100mil"]= true,
    ["keraieu"] = true
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

--=== AUTO SKIP HANDLER ===--
-- Reemplaza la función ensureAutoSkip existente por esta versión mejorada
local function ensureAutoSkip()
    local player = game.Players.LocalPlayer
    if not player then return false end

    -- intenta obtener la GUI principal (no bloquea demasiado)
    local gui = player.PlayerGui:FindFirstChild("GameGuiNoInset") or player.PlayerGui:FindFirstChildWhichIsA and player.PlayerGui:FindFirstChildWhichIsA("ScreenGui")
    -- si no encontramos la GUI aún, buscar en todos los descendants
    if not gui then
        for _, g in pairs(player.PlayerGui:GetChildren()) do
            if g:IsA("ScreenGui") then
                gui = g
                break
            end
        end
    end

    -- helper: intentar detectar si ya está ON
    local function isOn(btn)
        if not btn or not btn.Text then return false end
        local ok, t = pcall(function() return btn.Text end)
        if not ok or not t then return false end
        return string.find(t:lower(), "on")
    end

    -- helper: buscar botón por rutas conocidas o por nombre/texto
    local function findButton()
        if gui then
            -- ruta común según tu script original
            local ok, screen = pcall(function() return player.PlayerGui:WaitForChild("GameGuiNoInset", 0.1) end)
            if ok and screen then
                local suc, btn = pcall(function() return screen.Screen.Top.WaveControls.AutoSkip end)
                if suc and btn and (btn:IsA("TextButton") or btn:IsA("ImageButton")) then
                    return btn
                end
            end

            -- fallback: buscar en todo PlayerGui por nombre o texto
            for _, v in pairs(player.PlayerGui:GetDescendants()) do
                if (v:IsA("TextButton") or v:IsA("ImageButton")) then
                    local nameLower = tostring(v.Name):lower()
                    local textLower = ""
                    pcall(function() textLower = (v.Text and v.Text:lower()) or "" end)
                    if string.find(nameLower, "autoskip") or string.find(nameLower, "skip") or string.find(textLower, "auto skip") or string.find(textLower, "autoskip") then
                        return v
                    end
                end
            end
        end
        return nil
    end

    -- intento de activar por conexiones (getconnections)
    local function tryFireConnections(button)
        if not button then return false end
        local ok, conns = pcall(function() return getconnections(button.MouseButton1Click) end)
        if ok and conns and #conns > 0 then
            for i = 1, #conns do
                pcall(function() conns[i]:Fire() end)
            end
            return true
        end
        return false
    end

    -- intento de activar por VirtualInputManager (simula clic real)
    local function tryVirtualClick(button)
        if not button or not button.Parent then return false end
        local ok, vim = pcall(function() return game:GetService("VirtualInputManager") end)
        if not ok or not vim then return false end
        local absPos, absSize = nil, nil
        pcall(function()
            absPos = button.AbsolutePosition
            absSize = button.AbsoluteSize
        end)
        if not absPos or not absSize then return false end
        local cx = absPos.X + absSize.X/2
        local cy = absPos.Y + absSize.Y/2
        pcall(function()
            vim:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
            task.wait(0.05)
            vim:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
        end)
        return true
    end

    -- fallback: buscar remotos parecidos en ReplicatedStorage y llamar
    local function tryRemotes()
        local rs = game:GetService("ReplicatedStorage")
        for _, r in ipairs(rs:GetDescendants()) do
            if (r.ClassName == "RemoteFunction" or r.ClassName == "RemoteEvent") then
                local name = tostring(r.Name):lower()
                if string.find(name, "skip") or string.find(name, "autoskip") or string.find(name, "skipwave") then
                    pcall(function()
                        if r.ClassName == "RemoteFunction" then
                            r:InvokeServer(true)
                        else
                            r:FireServer(true)
                        end
                    end)
                end
            end
        end
    end

    -- 3 intentos combinando métodos con pequeñas pausas
    local btn = findButton()
    for attempt = 1, 3 do
        -- refrescar botón si no hay
        if not btn then btn = findButton() end

        if btn and isOn(btn) then
            return true -- ya está ON
        end

        local fired = false
        if btn then
            fired = tryFireConnections(btn) -- preferente
            if not fired then
                fired = tryVirtualClick(btn)  -- fallback más seguro
            end
        end

        if not fired then
            -- si no tuvimos botón o no funcionó, intentamos remotos
            tryRemotes()
        end

        -- esperar un poco y comprobar resultado
        task.wait(0.25)
        if btn and isOn(btn) then
            return true
        end

        -- intentar encontrar botón otra vez antes del siguiente intento
        btn = findButton()
        task.wait(0.15)
    end

    -- verificación final: si encontramos botón y está on, devuelve true
    if btn and isOn(btn) then return true end
    return false
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

        -- Auto Skip: inicia 6 segundos después y se mantiene activo
        task.delay(6, function()
            ensureAutoSkip()
            task.spawn(function()
                while task.wait(2) do
                    ensureAutoSkip()
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

        -- Auto Skip: inicia 6 segundos después y se mantiene activo
        task.delay(6, function()
            ensureAutoSkip()
            task.spawn(function()
                while task.wait(2) do
                    ensureAutoSkip()
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

--=== SPEED MENU ===--
local function showSpeedMenu()
    Title.Text = "Select Speed"
    TextBox.Visible = false
    CheckBtn.Visible = false

    local AutoSkipMsg = Instance.new("TextLabel", Frame)
    AutoSkipMsg.Size = UDim2.new(1, -20, 0, 30)
    AutoSkipMsg.Position = UDim2.new(0, 10, 0, 40)
    AutoSkipMsg.BackgroundTransparency = 1
    AutoSkipMsg.Text = "Please enable auto skip manually or you will get banned."
    AutoSkipMsg.Font = Enum.Font.GothamBold
    AutoSkipMsg.TextSize = 14
    AutoSkipMsg.TextColor3 = Color3.fromRGB(255, 200, 0)
    AutoSkipMsg.TextWrapped = true

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