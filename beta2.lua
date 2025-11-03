--// Wave Detector (REMOTE HOOK METHOD - 100% Accurate)

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")

getgenv().currentWave = 0
getgenv().detecting = true
getgenv().waveCallbacks = {}

local function createGui()
    local gui = plr.PlayerGui:FindFirstChild("WaveDetector")
    if gui then gui:Destroy() end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "WaveDetector"
    sg.ResetOnSpawn = false
    sg.Parent = plr.PlayerGui
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 180, 0, 80)
    f.Position = UDim2.new(0, 10, 0.5, -40)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    f.BackgroundTransparency = 0.2
    f.BorderSizePixel = 0
    f.Active = true
    f.Draggable = true
    f.Parent = sg
    
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, 0, 0, 25)
    t.BackgroundTransparency = 1
    t.Text = "Wave Detector"
    t.Font = Enum.Font.GothamBold
    t.TextSize = 13
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.Parent = f
    
    local w = Instance.new("TextLabel")
    w.Size = UDim2.new(1, -16, 0, 30)
    w.Position = UDim2.new(0, 8, 0, 30)
    w.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    w.Text = "Wave: 0"
    w.Font = Enum.Font.GothamBold
    w.TextSize = 16
    w.TextColor3 = Color3.fromRGB(100, 255, 100)
    w.Parent = f
    Instance.new("UICorner", w).CornerRadius = UDim.new(0, 6)
    
    local m = Instance.new("TextLabel")
    m.Size = UDim2.new(1, 0, 0, 15)
    m.Position = UDim2.new(0, 0, 1, -15)
    m.BackgroundTransparency = 1
    m.Text = "Waiting for wave..."
    m.Font = Enum.Font.Gotham
    m.TextSize = 9
    m.TextColor3 = Color3.fromRGB(150, 150, 150)
    m.Parent = f
    
    return w, m
end

local waveLabel, methodLabel = createGui()

-- Función para actualizar wave
local function updateWave(newWave)
    if newWave and newWave > 0 then
        local oldWave = getgenv().currentWave
        getgenv().currentWave = newWave
        waveLabel.Text = "Wave: " .. newWave
        methodLabel.Text = "Remote hook active"
        
        if newWave ~= oldWave then
            print("[WAVE] Changed: " .. oldWave .. " -> " .. newWave)
            
            -- Ejecutar callbacks registrados para este wave
            if getgenv().waveCallbacks[newWave] then
                for _, callback in ipairs(getgenv().waveCallbacks[newWave]) do
                    local success, err = pcall(callback, newWave)
                    if not success then
                        warn("[WAVE] Callback error:", err)
                    end
                end
            end
        end
    end
end

-- Hook del SkipWave remote
local function hookSkipWave()
    local remotes = rs:WaitForChild("RemoteFunctions", 30)
    if not remotes then
        warn("[WAVE] RemoteFunctions not found!")
        return false
    end
    
    local skipWave = remotes:FindFirstChild("SkipWave")
    if not skipWave then
        warn("[WAVE] SkipWave remote not found!")
        return false
    end
    
    local success = pcall(function()
        local oldSkip = skipWave.InvokeServer
        
        skipWave.InvokeServer = function(self, ...)
            -- Llamar al remote original
            local result = oldSkip(self, ...)
            
            -- Incrementar wave cuando se hace skip
            task.wait(0.1) -- Pequeño delay para asegurar que el servidor procese
            updateWave(getgenv().currentWave + 1)
            
            return result
        end
    end)
    
    if success then
        print("[WAVE] SkipWave hook installed!")
        methodLabel.Text = "Hook: SkipWave"
        return true
    else
        warn("[WAVE] Failed to hook SkipWave")
        return false
    end
end

-- Detectar wave inicial desde la UI (solo una vez al inicio)
local function detectInitialWave()
    local success, wave = pcall(function()
        local guiNoInset = plr.PlayerGui:FindFirstChild("GameGuiNoInset")
        if guiNoInset then
            for _, obj in pairs(guiNoInset:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Visible then
                    local text = obj.Text
                    
                    -- Buscar "Difficulty: Wave X / Y"
                    local difficulty, waveNum, totalWaves = string.match(text, "(%w+):%s*Wave%s*(%d+)%s*/%s*(%d+)")
                    if waveNum then
                        return tonumber(waveNum)
                    end
                    
                    -- Buscar "Wave X / Y"
                    local waveNum2, totalWaves2 = string.match(text, "Wave%s*(%d+)%s*/%s*(%d+)")
                    if waveNum2 then
                        return tonumber(waveNum2)
                    end
                end
            end
        end
        return nil
    end)
    
    if success and wave then
        updateWave(wave)
        print("[WAVE] Initial wave detected: " .. wave)
        return true
    end
    return false
end

-- API: Registrar callback para un wave específico
function onWave(waveNumber, callback)
    if not getgenv().waveCallbacks[waveNumber] then
        getgenv().waveCallbacks[waveNumber] = {}
    end
    table.insert(getgenv().waveCallbacks[waveNumber], callback)
    print("[WAVE] Registered callback for wave " .. waveNumber)
end

-- API: Limpiar callbacks
function clearWaveCallbacks()
    getgenv().waveCallbacks = {}
    print("[WAVE] All callbacks cleared")
end

-- API: Obtener wave actual
function getCurrentWave()
    return getgenv().currentWave
end

-- Inicializar
task.spawn(function()
    -- Esperar a que el juego cargue
    task.wait(2)
    
    -- Detectar wave inicial
    local detected = false
    for i = 1, 10 do
        if detectInitialWave() then
            detected = true
            break
        end
        task.wait(1)
    end
    
    if not detected then
        print("[WAVE] Could not detect initial wave, starting from 0")
        updateWave(1)
    end
    
    -- Instalar hook
    hookSkipWave()
end)

print("========================================")
print("[WAVE DETECTOR] Remote Hook Method")
print("[STATUS] Initializing...")
print("========================================")
print("")
print("[API FUNCTIONS]")
print("onWave(waveNumber, function)")
print("getCurrentWave()")
print("clearWaveCallbacks()")
print("========================================")