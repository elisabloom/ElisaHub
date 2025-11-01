–// Discord Webhook Tracker v3 - Error-Safe Version
–// Wait for game to load completely
repeat task.wait() until game:IsLoaded()
task.wait(2) – Extra safety delay

local Players = game:GetService(“Players”)
local plr = Players.LocalPlayer
local HttpService = game:GetService(“HttpService”)

– Wait for player to be fully loaded
repeat task.wait() until plr and plr.Parent
repeat task.wait() until plr:FindFirstChild(“PlayerGui”)

warn(”[INIT] Player and services loaded successfully”)

– Variables globales
_G.isTracking = _G.isTracking or false
_G.gameStartTime = _G.gameStartTime or nil
_G.isMinimized = _G.isMinimized or false
_G.webhookURL = _G.webhookURL or “”

– Nombre del archivo donde se guardará el webhook
local WEBHOOK_FILE = “webhook_tracker_config.txt”

– Cargar el webhook guardado del archivo
local function loadWebhook()
if readfile and isfile then
local success, result = pcall(function()
if isfile(WEBHOOK_FILE) then
local savedURL = readfile(WEBHOOK_FILE)
if savedURL and savedURL ~= “” then
_G.webhookURL = savedURL
warn(”[WEBHOOK] ✓ Webhook cargado desde archivo”)
return true
end
end
return false
end)

```
    if not success then
        warn("[WEBHOOK] ⚠️ Error al cargar webhook: " .. tostring(result))
    end
else
    warn("[WEBHOOK] ⚠️ writefile/readfile no disponible en este ejecutor")
end
```

end

– Guardar el webhook en archivo permanente
local function saveWebhook(url)
if writefile then
local success, err = pcall(function()
writefile(WEBHOOK_FILE, url)
end)

```
    if success then
        warn("[WEBHOOK] ✓ Webhook guardado permanentemente")
        return true
    else
        warn("[WEBHOOK] ❌ Error al guardar webhook: " .. tostring(err))
        return false
    end
else
    warn("[WEBHOOK] ⚠️ writefile no disponible")
    return false
end
```

end

– Cargar el webhook al iniciar
pcall(loadWebhook)

– Función para obtener valores del GUI del juego
local function getValueSafe(valueObject)
if not valueObject then
return “N/A”
end

```
local success, val = pcall(function()
    return valueObject.Value
end)

if not success then
    return "N/A"
end

if type(val) == "number" then
    return tostring(val)
end

if type(val) == "string" then
    return val
end

return tostring(val)
```

end

– NUEVA FUNCIÓN: Buscar Candy en el GUI del juego
local function getCandyFromGameGui()
local success, result = pcall(function()
local gameGui = plr.PlayerGui:FindFirstChild(“GameGui”)
if not gameGui then return “N/A” end

```
    -- Buscar en todos los descendientes
    for _, descendant in pairs(gameGui:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            local text = descendant.Text
            
            -- Buscar el icono de candy (🍬) o el patrón numérico cerca de él
            if text:match("🍬") or descendant.Name:lower():find("candy") then
                local number = text:match("%d+")
                if number then
                    warn("[DEBUG] Candy encontrado en GUI: " .. number)
                    return number
                end
            end
            
            -- También buscar en elementos hermanos si este es el icono
            if text == "🍬" or text:match("🍬") then
                local parent = descendant.Parent
                if parent then
                    for _, sibling in pairs(parent:GetChildren()) do
                        if sibling:IsA("TextLabel") and sibling ~= descendant then
                            local candyNum = sibling.Text:match("%d+")
                            if candyNum then
                                warn("[DEBUG] Candy encontrado en sibling: " .. candyNum)
                                return candyNum
                            end
                        end
                    end
                end
            end
        end
    end
    
    return "N/A"
end)

if success then
    return result
else
    warn("[ERROR] getCandyFromGameGui failed: " .. tostring(result))
    return "N/A"
end
```

end

local function createWebhookGui()
local success, gui = pcall(function()
local existingGui = plr.PlayerGui:FindFirstChild(“WebhookTest”)
if existingGui then existingGui:Destroy() end

```
    local WebhookGui = Instance.new("ScreenGui")
    WebhookGui.Name = "WebhookTest"
    WebhookGui.ResetOnSpawn = false
    WebhookGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WebhookGui.Parent = plr:WaitForChild("PlayerGui")
    
    local WebhookFrame = Instance.new("Frame")
    WebhookFrame.Name = "MainFrame"
    WebhookFrame.Size = UDim2.new(0, 210, 0, 132)
    WebhookFrame.Position = UDim2.new(1, -220, 1, -142)
    WebhookFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    WebhookFrame.BackgroundTransparency = 0.1
    WebhookFrame.BorderSizePixel = 0
    WebhookFrame.Active = true
    WebhookFrame.Draggable = true
    WebhookFrame.Parent = WebhookGui
    
    local UICorner = Instance.new("UICorner", WebhookFrame)
    UICorner.CornerRadius = UDim.new(0, 10)
    
    local WebhookTitle = Instance.new("TextLabel")
    WebhookTitle.Size = UDim2.new(1, -30, 0, 25)
    WebhookTitle.BackgroundTransparency = 1
    WebhookTitle.Text = "Webhook Tracker"
    WebhookTitle.Font = Enum.Font.GothamBold
    WebhookTitle.TextSize = 12
    WebhookTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WebhookTitle.Parent = WebhookFrame
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -25, 0, 0)
    MinimizeButton.Text = "−"
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 18
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = WebhookFrame
    
    local MinimizeCorner = Instance.new("UICorner", MinimizeButton)
    MinimizeCorner.CornerRadius = UDim.new(0, 6)
    
    local WebhookInput = Instance.new("TextBox")
    WebhookInput.Name = "WebhookInput"
    WebhookInput.Size = UDim2.new(1, -20, 0, 28)
    WebhookInput.Position = UDim2.new(0, 10, 0, 30)
    WebhookInput.PlaceholderText = "Paste Discord Webhook URL..."
    WebhookInput.Text = _G.webhookURL
    WebhookInput.Font = Enum.Font.Gotham
    WebhookInput.TextSize = 9
    WebhookInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    WebhookInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    WebhookInput.BorderSizePixel = 0
    WebhookInput.TextXAlignment = Enum.TextXAlignment.Left
    WebhookInput.ClearTextOnFocus = false
    WebhookInput.TextWrapped = false
    WebhookInput.ClipsDescendants = true
    WebhookInput.Parent = WebhookFrame
    
    local InputCorner = Instance.new("UICorner", WebhookInput)
    InputCorner.CornerRadius = UDim.new(0, 6)
    
    local SaveButton = Instance.new("TextButton")
    SaveButton.Size = UDim2.new(0, 60, 0, 25)
    SaveButton.Position = UDim2.new(0, 10, 0, 65)
    SaveButton.Text = "💾 Save"
    SaveButton.Font = Enum.Font.GothamBold
    SaveButton.TextSize = 10
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    SaveButton.BorderSizePixel = 0
    SaveButton.Parent = WebhookFrame
    
    local SaveCorner = Instance.new("UICorner", SaveButton)
    SaveCorner.CornerRadius = UDim.new(0, 6)
    
    local ClearButton = Instance.new("TextButton")
    ClearButton.Size = UDim2.new(0, 60, 0, 25)
    ClearButton.Position = UDim2.new(0, 75, 0, 65)
    ClearButton.Text = "🗑️ Clear"
    ClearButton.Font = Enum.Font.GothamBold
    ClearButton.TextSize = 10
    ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ClearButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    ClearButton.BorderSizePixel = 0
    ClearButton.Parent = WebhookFrame
    
    local ClearCorner = Instance.new("UICorner", ClearButton)
    ClearCorner.CornerRadius = UDim.new(0, 6)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -20, 0, 35)
    StatusLabel.Position = UDim2.new(0, 10, 0, 95)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "⏸️ Waiting for game..."
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 10
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = WebhookFrame
    
    -- Funcionalidad de minimizar
    MinimizeButton.MouseButton1Click:Connect(function()
        _G.isMinimized = not _G.isMinimized
        
        if _G.isMinimized then
            WebhookFrame:TweenSize(UDim2.new(0, 210, 0, 25), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            MinimizeButton.Text = "+"
            WebhookInput.Visible = false
            SaveButton.Visible = false
            ClearButton.Visible = false
            StatusLabel.Visible = false
        else
            WebhookFrame:TweenSize(UDim2.new(0, 210, 0, 132), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            MinimizeButton.Text = "−"
            WebhookInput.Visible = true
            SaveButton.Visible = true
            ClearButton.Visible = true
            StatusLabel.Visible = true
        end
    end)
    
    SaveButton.MouseButton1Click:Connect(function()
        _G.webhookURL = WebhookInput.Text
        saveWebhook(_G.webhookURL)
        SaveButton.Text = "✓ Saved!"
        SaveButton.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        task.wait(1.5)
        SaveButton.Text = "💾 Save"
        SaveButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end)
    
    ClearButton.MouseButton1Click:Connect(function()
        _G.webhookURL = ""
        saveWebhook("")
        WebhookInput.Text = ""
        ClearButton.Text = "✓ Cleared!"
        task.wait(1)
        ClearButton.Text = "🗑️ Clear"
    end)
    
    return StatusLabel
end)

if success then
    return gui
else
    warn("[ERROR] Failed to create GUI: " .. tostring(gui))
    return nil
end
```

end

local function sendWebhook(gameEndFrame, statusLabel)
if _G.webhookURL == “” or not _G.webhookURL then
warn(”[WEBHOOK] No webhook URL configured!”)
if statusLabel then
statusLabel.Text = “⚠️ No webhook URL set!”
end
return
end

```
local success, err = pcall(function()
    local currentTime = os.date("%Y-%m-%d %H:%M:%S")
    
    -- Obtener Seeds de leaderstats
    local leaderstats = plr:WaitForChild("leaderstats", 5)
    local totalSeeds = "N/A"
    
    if leaderstats then
        local seedsValue = leaderstats:FindFirstChild("Seeds")
        if seedsValue then
            totalSeeds = getValueSafe(seedsValue)
            warn("[DEBUG] Seeds Value: " .. totalSeeds)
        end
    end
    
    -- Obtener Candy del GUI del juego
    local totalCandy = getCandyFromGameGui()
    warn("[DEBUG] Candy Value (from GUI): " .. totalCandy)
    
    -- Buscar el resultado del juego
    local resultText = "Unknown"
    
    -- Método 1: Buscar en el label "Result"
    local resultLabel = gameEndFrame:FindFirstChild("Result", true)
    if resultLabel and resultLabel:IsA("TextLabel") then
        local text = resultLabel.Text:lower()
        if text:find("defeat") or text:find("lost") or text:find("lose") then
            resultText = "Defeat"
        elseif text:find("victory") or text:find("win") or text:find("won") then
            resultText = "Victory"
        else
            resultText = resultLabel.Text
        end
        warn("[DEBUG] Result from Result label: " .. resultText)
    end
    
    -- Método 2: Buscar en TODOS los TextLabels
    if resultText == "Unknown" then
        for _, child in pairs(gameEndFrame:GetDescendants()) do
            if child:IsA("TextLabel") then
                local text = child.Text:lower()
                
                if text:find("victory") or text:find("win") or text:find("won") or 
                   text:find("success") or text:find("complete") then
                    resultText = "Victory"
                    warn("[DEBUG] Victory detected in: " .. child.Name .. " - " .. child.Text)
                    break
                end
                
                if text:find("defeat") or text:find("lost") or text:find("lose") or 
                   text:find("fail") or text:find("game over") then
                    resultText = "Defeat"
                    warn("[DEBUG] Defeat detected in: " .. child.Name .. " - " .. child.Text)
                    break
                end
            end
        end
    end
    
    -- Buscar el Run Time
    local runTime = "00:00"
    
    for _, child in pairs(gameEndFrame:GetDescendants()) do
        if child:IsA("TextLabel") then
            local text = child.Text
            local timeMatch = text:match("(%d+:%d+)")
            if timeMatch then
                runTime = timeMatch
                warn("[DEBUG] Run Time found: " .. runTime)
                break
            end
        end
    end
    
    local embedColor = resultText == "Victory" and 3066993 or 15158332
    
    local data = {
        ["embeds"] = {{
            ["title"] = "🎮 Seed Tracker",
            ["color"] = embedColor,
            ["fields"] = {
                {
                    ["name"] = "User:",
                    ["value"] = "||" .. plr.Name .. "||",
                    ["inline"] = false
                },
                {
                    ["name"] = "💎 Seeds:",
                    ["value"] = totalSeeds,
                    ["inline"] = true
                },
                {
                    ["name"] = "🍬 Candy:",
                    ["value"] = totalCandy,
                    ["inline"] = true
                },
                {
                    ["name"] = "⏱️ Run Time:",
                    ["value"] = runTime,
                    ["inline"] = true
                },
                {
                    ["name"] = "📊 Result:",
                    ["value"] = resultText,
                    ["inline"] = true
                }
            },
            ["footer"] = {
                ["text"] = "Noah Hub | " .. currentTime
            }
        }}
    }
    
    local jsonData = HttpService:JSONEncode(data)
    local headers = {["Content-Type"] = "application/json"}
    
    request({
        Url = _G.webhookURL,
        Method = "POST",
        Headers = headers,
        Body = jsonData
    })
    
    warn("[WEBHOOK] ✅ Message sent! (" .. resultText .. " | Candy: " .. totalCandy .. ")")
    if statusLabel then
        statusLabel.Text = "✅ Webhook sent!\n" .. resultText .. " | " .. runTime .. "\nCandy: " .. totalCandy
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

if not success then
    warn("[WEBHOOK ERROR] " .. tostring(err))
    if statusLabel then
        statusLabel.Text = "❌ Webhook failed!\n" .. tostring(err):sub(1, 40)
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end
```

end

local function detectGameStart(statusLabel)
task.spawn(function()
while true do
task.wait(2)

```
        pcall(function()
            local gameGui = plr.PlayerGui:FindFirstChild("GameGui")
            
            if gameGui and not _G.isTracking then
                local gameEndFrame = gameGui.Screen.Middle:FindFirstChild("GameEnd")
                
                if gameEndFrame and not gameEndFrame.Visible then
                    _G.isTracking = true
                    _G.gameStartTime = tick()
                    warn("[TRACKER] Game started!")
                    if statusLabel then
                        statusLabel.Text = "🎮 Game in progress..."
                        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                    end
                    
                    -- Esperar hasta que el juego termine
                    repeat
                        task.wait(0.5)
                    until gameEndFrame.Visible == true
                    
                    -- Esperar para que se carguen todos los datos
                    task.wait(2.5)
                    
                    warn("[TRACKER] Game ended! Collecting data...")
                    
                    if statusLabel then
                        statusLabel.Text = "📤 Sending webhook..."
                        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                    end
                    
                    sendWebhook(gameEndFrame, statusLabel)
                    
                    task.wait(3)
                    _G.isTracking = false
                    
                    if statusLabel then
                        statusLabel.Text = "⏸️ Waiting for next game..."
                        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                    end
                end
            end
        end)
    end
end)
```

end

– Inicializar el tracker
local statusLabel = createWebhookGui()
if statusLabel then
detectGameStart(statusLabel)

```
warn("========================================")
warn("[WEBHOOK TRACKER] Initialized v3 (Error-Safe)")
warn("[INFO] Ejecutor: " .. (writefile and "✓ Compatible" or "✗ No compatible"))
warn("[INFO] Webhook: " .. (_G.webhookURL ~= "" and "✓ Cargado" or "⚠️ No configurado"))
warn("[INFO] GUI loaded successfully!")
warn("========================================")
```

else
warn(”[ERROR] Failed to initialize tracker - GUI creation failed”)
end