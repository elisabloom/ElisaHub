--// Wave Detector (FIXED - Detects correct wave number)

local Players = game:GetService("Players")
local plr = Players.LocalPlayer

getgenv().currentWave = 0
getgenv().detecting = true

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
    
    local c1 = Instance.new("UICorner", f)
    c1.CornerRadius = UDim.new(0, 8)
    
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
    w.Text = "Wave: --"
    w.Font = Enum.Font.GothamBold
    w.TextSize = 16
    w.TextColor3 = Color3.fromRGB(100, 255, 100)
    w.Parent = f
    
    local c2 = Instance.new("UICorner", w)
    c2.CornerRadius = UDim.new(0, 6)
    
    local m = Instance.new("TextLabel")
    m.Size = UDim2.new(1, 0, 0, 15)
    m.Position = UDim2.new(0, 0, 1, -15)
    m.BackgroundTransparency = 1
    m.Text = "Detecting..."
    m.Font = Enum.Font.Gotham
    m.TextSize = 9
    m.TextColor3 = Color3.fromRGB(150, 150, 150)
    m.Parent = f
    
    return w, m
end

local waveLabel, methodLabel = createGui()

-- MÉTODO MEJORADO: Busca específicamente "Wave X / Y" o "Wave X"
local function m1_improved()
    local s, r = pcall(function()
        local g = plr.PlayerGui:FindFirstChild("GameGui")
        if not g then return nil end
        
        for _, o in pairs(g:GetDescendants()) do
            if o:IsA("TextLabel") then
                local text = o.Text
                
                -- Patrón 1: "Wave 2 / 40" o "Impossible: Wave 2 / 40"
                local wave1, total1 = string.match(text, "[Ww]ave%s*(%d+)%s*/%s*(%d+)")
                if wave1 then
                    return tonumber(wave1)
                end
                
                -- Patrón 2: "2 / 40" (solo números con slash)
                local wave2, total2 = string.match(text, "^(%d+)%s*/%s*(%d+)$")
                if wave2 then
                    local num = tonumber(wave2)
                    if num and num <= 100 then -- Evita números grandes falsos
                        return num
                    end
                end
                
                -- Patrón 3: "Wave: 2"
                local wave3 = string.match(text, "[Ww]ave:%s*(%d+)")
                if wave3 then
                    return tonumber(wave3)
                end
            end
        end
    end)
    return s and r or nil
end

local function m2()
    local s, r = pcall(function()
        return plr:GetAttribute("CurrentWave") or plr:GetAttribute("Wave")
    end)
    return s and r or nil
end

local function m3()
    local s, r = pcall(function()
        local m = workspace:FindFirstChild("Map")
        if not m then return nil end
        for _, o in pairs(m:GetDescendants()) do
            if o.Name == "CurrentWave" or o.Name == "Wave" then
                if o:IsA("IntValue") or o:IsA("NumberValue") then
                    return o.Value
                end
            end
        end
    end)
    return s and r or nil
end

local function m4()
    local s, r = pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        for _, o in pairs(rs:GetDescendants()) do
            if o.Name == "CurrentWave" or o.Name == "Wave" then
                if o:IsA("IntValue") or o:IsA("NumberValue") then
                    return o.Value
                end
            end
        end
    end)
    return s and r or nil
end

-- MÉTODO MEJORADO para GameGuiNoInset
local function m5_improved()
    local s, r = pcall(function()
        local g = plr.PlayerGui:FindFirstChild("GameGuiNoInset")
        if not g then return nil end
        
        for _, o in pairs(g:GetDescendants()) do
            if o:IsA("TextLabel") then
                local text = o.Text
                
                -- Patrón 1: "Wave 2 / 40" o "Impossible: Wave 2 / 40"
                local wave1, total1 = string.match(text, "[Ww]ave%s*(%d+)%s*/%s*(%d+)")
                if wave1 then
                    return tonumber(wave1)
                end
                
                -- Patrón 2: "2 / 40" (solo números con slash)
                local wave2, total2 = string.match(text, "^(%d+)%s*/%s*(%d+)$")
                if wave2 then
                    local num = tonumber(wave2)
                    if num and num <= 100 then
                        return num
                    end
                end
                
                -- Patrón 3: "Wave: 2"
                local wave3 = string.match(text, "[Ww]ave:%s*(%d+)")
                if wave3 then
                    return tonumber(wave3)
                end
            end
        end
    end)
    return s and r or nil
end

local function detect()
    local methods = {
        {n = "GameGui", f = m1_improved},
        {n = "GameGuiNoInset", f = m5_improved},
        {n = "Attribute", f = m2},
        {n = "Workspace", f = m3},
        {n = "RepStorage", f = m4}
    }
    
    for i, mt in ipairs(methods) do
        local w = mt.f()
        if w and w > 0 and w <= 100 then -- Validar rango razonable
            return w, mt.n
        end
    end
    
    return nil, "None"
end

task.spawn(function()
    local last = 0
    while getgenv().detecting do
        task.wait(0.5)
        local w, mt = detect()
        if w then
            getgenv().currentWave = w
            waveLabel.Text = "Wave: " .. w
            methodLabel.Text = "Method: " .. mt
            if w ~= last then
                last = w
                print("[WAVE] Changed to: " .. w .. " (Method: " .. mt .. ")")
            end
        else
            waveLabel.Text = "Wave: --"
            methodLabel.Text = "Searching..."
        end
    end
end)

print("[WAVE DETECTOR] Loaded - Fixed pattern matching")