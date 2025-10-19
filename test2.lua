-- Script automático (NO toca Auto Skip)
-- Basado en tu script funcional, automatiza partidas completas sin intentar forzar el Auto Skip

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

--// Key GUI (idéntico al tuyo)
local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false
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

--// Remotes (usa la carpeta RemoteFunctions si existe)
local rs = game:GetService("ReplicatedStorage")
local remotes = nil
pcall(function() remotes = rs:WaitForChild("RemoteFunctions", 2) end)
if not remotes then
    -- si no existe la carpeta, intentamos usar directamente lo que haya
    remotes = rs
end

-- Helper seguro para invoocar remotes (no rompe si no existe)
local function safeInvoke(remoteName, ...)
    if not remotes then return nil end
    local ok, remote = pcall(function() return remotes:FindFirstChild(remoteName) end)
    if not ok or not remote then return nil end
    if remote.ClassName == "RemoteFunction" then
        return pcall(function() return remote:InvokeServer(...) end)
    elseif remote.ClassName == "RemoteEvent" then
        return pcall(function() remote:FireServer(...) end)
    end
    return nil
end

--=== GAME SCRIPTS ===--
-- Estos son los placements que tenías — ajusta tiempos si quieres.
local difficulty = "dif_impossible"
local placements_2x = {
    { time = 29, unit = "unit_lawnmower", slot = "1",
      data = {Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803055,-123.052032),
          DistanceAlongPath=248.0065,
          CF=CFrame.new(-843.87384,62.1803055,-123.052032,-0,0,1,0,1,-0,-1,0,-0),
          Rotation=180}
    },
    { time = 47, unit = "unit_rafflesia", slot = "2",
      data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-162.012131),
          DistanceAlongPath=180.53,
          CF=CFrame.new(-842.381287,62.1803055,-162.012131,1,0,0,0,1,0,0,0,1),
          Rotation=180}
    },
    { time = 85, unit = "unit_rafflesia", slot = "2",
      data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-164.507538),
          DistanceAlongPath=178.04,
          CF=CFrame.new(-842.381287,62.1803055,-164.507538,1,0,0,0,1,0,0,0,1),
          Rotation=180}
    },
    { time = 110, unit = "unit_rafflesia", slot = "2",
      data = {Valid=true,PathIndex=2,Position=Vector3.new(-864.724426,62.1803055,-199.052032),
          DistanceAlongPath=100.65,
          CF=CFrame.new(-864.724426,62.1803055,-199.052032,-0,0,1,0,1,0,-1,0,0),
          Rotation=180}
    }
}

local placements_3x = {
    { time = 23, unit = "unit_lawnmower", slot = "1",
      data = placements_2x[1].data
    },
    { time = 32, unit = "unit_rafflesia", slot = "2",
      data = placements_2x[2].data
    },
    { time = 57, unit = "unit_rafflesia", slot = "2",
      data = placements_2x[3].data
    },
    { time = 77, unit = "unit_rafflesia", slot = "2",
      data = placements_2x[4].data
    }
}

-- función genérica para colocar unidades según lista de placements
local function runPlacements(placements)
    -- votar dificultad
    pcall(function() 
        if remotes and remotes:FindFirstChild("PlaceDifficultyVote") then
            remotes.PlaceDifficultyVote:InvokeServer(difficulty)
        else
            -- fallback: intentar por nombre común
            safeInvoke("PlaceDifficultyVote", difficulty)
        end
    end)

    for _, p in ipairs(placements) do
        task.delay(p.time, function()
            pcall(function()
                if remotes and remotes:FindFirstChild("PlaceUnit") then
                    remotes.PlaceUnit:InvokeServer(p.unit, p.data)
                else
                    safeInvoke("PlaceUnit", p.unit, p.data)
                end
            end)
        end)
    end
end

-- versión que corre el ciclo completo en loop (sin tocar auto skip)
local function startAutoLoop(tickSpeed, placements, cycleWait)
    -- Ejecutar en un hilo
    task.spawn(function()
        -- intentar setear tick speed (si existe)
        pcall(function()
            if remotes and remotes:FindFirstChild("ChangeTickSpeed") then
                remotes.ChangeTickSpeed:InvokeServer(tickSpeed)
            else
                safeInvoke("ChangeTickSpeed", tickSpeed)
            end
        end)

        while true do
            -- iniciar la partida: votar y colocar unidades programadas
            runPlacements(placements)

            -- esperar al final del ciclo (tiempo estimado)
            task.wait(cycleWait or 170) -- ajusta según 2x/3x (ej. 174.5 / 128)
            -- reiniciar la partida mediante remote
            pcall(function()
                if remotes and remotes:FindFirstChild("RestartGame") then
                    remotes.RestartGame:InvokeServer()
                else
                    safeInvoke("RestartGame")
                end
            end)

            -- pequeña espera para asegurar reinicio
            task.wait(2)
        end
    end)
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
        -- start loop for 2x: tickSpeed 2 and cycle wait ~174.5
        startAutoLoop(2, placements_2x, 174.5)
    end)

    btn3x.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        -- start loop for 3x: tickSpeed 3 and cycle wait ~128
        startAutoLoop(3, placements_3x, 128)
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

-- Anti-AFK u otros scripts externos (igual que tenías)
pcall(function()
    loadstring(game:HttpGet("https://pastebin.com/raw/HkAmPckQ"))()
end)
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
end)

-- Fin del script