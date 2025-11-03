--// Garden Tower Defense - Simple Wave Detector

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

_G.currentWave = 0
_G.detecting = true

-- GUI simple
local function createSimpleGui()
    local gui = plr.PlayerGui:FindFirstChild("WaveDetector")
    if gui then gui:Destroy() end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "WaveDetector"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = plr.PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 180, 0, 80)
    Frame.Position = UDim2.new(0, 10, 0.5, -40)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = ScreenGui
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.BackgroundTransparency = 1
    Title.Text = "Wave Detector"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = Frame
    
    local WaveLabel = Instance.new("TextLabel")
    WaveLabel.Size = UDim2.new(1, -16, 0, 30)
    WaveLabel.Position = UDim2.new(0, 8, 0, 30)
    WaveLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    WaveLabel.Text = "Wave: --"
    WaveLabel.Font = Enum.Font.GothamBold
    WaveLabel.TextSize = 16
    WaveLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    WaveLabel.Parent = Frame
    Instance.new("UICorner", WaveLabel).CornerRadius = UDim.new(0, 6)
    
    local MethodLabel = Instance.new("TextLabel")
    MethodLabel.Size = UDim2.new(1, 0, 0, 15)
    MethodLabel.Position = UDim2.new(0, 0, 1, -15)
    MethodLabel.BackgroundTransparency = 1
    MethodLabel.Text = "Detecting..."
    MethodLabel.Font = Enum.Font.Gotham
    MethodLabel.TextSize = 9
    MethodLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    MethodLabel.Parent = Frame
    
    return WaveLabel, MethodLabel
end

local waveLabel, methodLabel = createSimpleGui()

-- Métodos de detección
local function method1_GameGui()
    local success, result = pcall(function()
        local gameGui = plr.PlayerGui:FindFirstChild("GameGui")
        if not gameGui then return nil end
        
        for _, obj in pairs(gameGui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local text = string.lower(obj.Text)
                if string.find(text, "wave") then
                    local num = tonumber(string.match(obj.Text, "%d+"))
                    if num and num > 0 then
                        return num
                    end
                end
            end
        end
    end)
    return success and result or nil
end

local function method2_PlayerAttribute()
    local success, result = pcall(function()
        return plr:GetAttribute("CurrentWave") or plr:GetAttribute("Wave")
    end)
    return success and result or nil
end

local function method3_Workspace()
    local success, result = pcall(function()
        local map = workspace:FindFirstChild("Map")
        if not map then return nil end
        
        for _, obj in pairs(map:GetDescendants()) do
            if obj.Name == "CurrentWave" or obj.Name == "Wave" then
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    return obj.Value
                end
            end
        end
    end)
    return success and result or nil
end

local function method4_ReplicatedStorage()
    local success, result = pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        
        for _, obj in pairs(rs:GetDescendants()) do
            if obj.Name == "CurrentWave" or obj.Name == "Wave" then
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    return obj.Value
                end
            end
        end
    end)
    return success and result or nil
end

local function method5_GameGuiNoInset()
    local success, result = pcall(function()
        local gameGui = plr.PlayerGui:FindFirstChild("GameGuiNoInset")
        if not gameGui then return nil end
        
        for _, obj in pairs(gameGui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local text = string.lower(obj.Text)
                if string.find(text, "wave") or string.find(text, "round") then
                    local num = tonumber(string.match(obj.Text, "%d+"))
                    if num and num > 0 then
                        return num
                    end
                end
            end
        end
    end)
    return success and result or nil
end

-- Detectar wave con todos los métodos
local function detectWave()
    local methods = {
        {name = "GameGui", func = method1_GameGui},
        {name = "Attribute", func = method2_PlayerAttribute},
        {name = "Workspace", func = method3_Workspace},
        {name = "RepStorage", func = method4_ReplicatedStorage},
        {name = "GameGuiNoInset", func = method5_GameGuiNoInset}
    }
    
    for i, method in ipairs(methods) do
        local wave = method.func()
        if wave and wave > 0 then
            return wave, method.name
        end
    end
    
    return nil, "None"
end

-- Loop de detección
task.spawn(function()
    local lastWave = 0
    
    while _G.detecting do
        task.wait(0.5)
        
        local wave, method = detectWave()
        
        if wave then
            _G.currentWave = wave
            waveLabel.Text = "Wave: " .. wave
            methodLabel.Text = "Method: " .. method
            
            if wave ~= lastWave then
                lastWave = wave
                warn("[WAVE] Changed to: " .. wave .. " (Method: " .. method .. ")")
            end
        else
            waveLabel.Text = "Wave: --"
            methodLabel.Text = "Searching..."
        end
    end
end)

warn("========================================")
warn("[WAVE DETECTOR] Initialized")
warn("[STATUS] Detection active")
warn("========================================")
```

---

## ✅ **Detector Simple de Waves**

### **📋 Lo que hace:**

1. **Detecta el wave actual** usando 5 métodos diferentes
2. **Muestra en GUI** el wave y qué método funcionó
3. **Imprime en consola** cuando cambia de wave

### **🎮 Output en consola:**
```
========================================
[WAVE DETECTOR] Initialized
[STATUS] Detection active
========================================
[WAVE] Changed to: 1 (Method: GameGuiNoInset)
[WAVE] Changed to: 2 (Method: GameGuiNoInset)
[WAVE] Changed to: 3 (Method: GameGuiNoInset)
[WAVE] Changed to: 4 (Method: GameGuiNoInset)
[WAVE] Changed to: 5 (Method: GameGuiNoInset)
...
[WAVE] Changed to: 15 (Method: GameGuiNoInset)
```

### **📊 GUI muestra:**
```
┌─────────────────┐
│ Wave Detector   │
├─────────────────┤
│   Wave: 15      │
│ Method: GameGui │
└─────────────────┘
