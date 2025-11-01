--// Discord Webhook Test - Real Game Data Tracker

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Variables globales
_G.isTracking = false
_G.gameStartTime = nil
_G.isMinimized = false
_G.webhookURL = ""

-- Nombre del archivo donde se guardará el webhook
local WEBHOOK_FILE = "webhook_tracker_config.txt"

-- Cargar el webhook guardado del archivo
local function loadWebhook()
    if readfile and isfile then
        local success, result = pcall(function()
            if isfile(WEBHOOK_FILE) then
                local savedURL = readfile(WEBHOOK_FILE)
                if savedURL and savedURL ~= "" then
                    _G.webhookURL = savedURL
                    warn("[WEBHOOK] ✓ Webhook cargado desde archivo")
                    return true
                end
            end
            return false
        end)
        
        if not success then
            warn("[WEBHOOK] ⚠️ Error al cargar webhook")
        end
    else
        warn("[WEBHOOK] ⚠️ writefile/readfile no disponible en este ejecutor")
    end
end

-- Guardar el webhook en archivo permanente
local function saveWebhook(url)
    if writefile then
        local success = pcall(function()
            writefile(WEBHOOK_FILE, url)
        end)
        
        if success then
            warn("[WEBHOOK] ✓ Webhook guardado permanentemente")
            return true
        else
            warn("[WEBHOOK] ❌ Error al guardar webhook")
            return false
        end
    else
        warn("[WEBHOOK] ⚠️ writefile no disponible")
        return false
    end
end

-- Cargar el webhook al iniciar
loadWebhook()

local function formatNumber(num)
    if type(num) ~= "number" then
        return tostring(num)
    end
    return tostring(math.floor(num))
end

local function parseFormattedNumber(str)
    -- Si ya es un número, devolverlo
    if type(str) == "number" then
        return tostring(math.floor(str))
    end
    
    -- Convertir a string
    str = tostring(str)
    
    -- Si no tiene sufijos, devolver tal cual
    if not str:match("[KMBkmb]") then
        local num = tonumber(str)
        if num then
            return tostring(math.floor(num))
        end
        return str
    end
    
    -- Parsear números con sufijos (3.5M, 1.2K, etc)
    local number = str:match("([%d%.]+)")
    local suffix = str:match("[KMBkmb]")
    
    if not number or not suffix then
        return str
    end
    
    number = tonumber(number)
    suffix = suffix:upper()
    
    local multipliers = {
        K = 1000,
        M = 1000000,
        B = 1000000000
    }
    
    local result = number * (multipliers[suffix] or 1)
    return tostring(math.floor(result))
end

local function createWebhookGui()
    local existingGui = plr.PlayerGui:FindFirstChild("WebhookTest")
    if existingGui then existingGui:Destroy() end
    
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
end

local function sendWebhook(gameEndFrame, statusLabel)
    if _G.webhookURL == "" or not _G.webhookURL then
        warn("[WEBHOOK] No webhook URL configured!")
        if statusLabel then
            statusLabel.Text = "⚠️ No webhook URL set!"
        end
        return
    end
    
    local success, err = pcall(function()
        local currentTime = os.date("%Y-%m-%d %H:%M:%S")
        
        -- Obtener Seeds y Candy de leaderstats
        local leaderstats = plr:WaitForChild("leaderstats", 5)
        local totalSeeds = "N/A"
        local totalCandy = "N/A"
        
        if leaderstats then
            local seedsValue = leaderstats:FindFirstChild("Seeds")
            local candyValue = leaderstats:FindFirstChild("Candy")
            
            if seedsValue then
                totalSeeds = tostring(math.floor(seedsValue.Value))
            end
            
            if candyValue then
                totalCandy = tostring(math.floor(candyValue.Value))
            end
        end
        
        -- Obtener el resultado del juego
        local resultText = "Unknown"
        local resultLabel = gameEndFrame:FindFirstChild("Result")
        if resultLabel and resultLabel:IsA("TextLabel") then
            local text = resultLabel.Text:lower()
            if text:find("defeat") then
                resultText = "Defeat"
            elseif text:find("victory") then
                resultText = "Victory"
            else
                resultText = resultLabel.Text
            end
        end
        
        -- Buscar el Run Time en el GameEnd frame
        local runTime = "00:00"
        
        -- Buscar en todos los descendientes del GameEnd frame
        for _, child in pairs(gameEndFrame:GetDescendants()) do
            if child:IsA("TextLabel") then
                local text = child.Text
                -- Buscar formato de tiempo XX:XX
                if text:match("%d+:%d+") and child.Name:lower():find("time") then
                    runTime = text:match("%d+:%d+")
                    break
                elseif text:match("Run time: (%d+:%d+)") then
                    runTime = text:match("Run time: (%d+:%d+)")
                    break
                end
            end
        end
        
        -- Si no se encontró, buscar específicamente "Run time" label
        if runTime == "00:00" then
            local runTimeLabel = gameEndFrame:FindFirstChild("Run time", true)
            if runTimeLabel and runTimeLabel:IsA("TextLabel") then
                local timeMatch = runTimeLabel.Text:match("%d+:%d+")
                if timeMatch then
                    runTime = timeMatch
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
        
        warn("[WEBHOOK] Message sent! (" .. resultText .. ")")
        if statusLabel then
            statusLabel.Text = "✅ Webhook sent!\n" .. resultText .. " | " .. runTime
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end)
    
    if not success then
        warn("[WEBHOOK ERROR] " .. tostring(err))
        if statusLabel then
            statusLabel.Text = "❌ Webhook failed!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end
end

local function detectGameStart(statusLabel)
    task.spawn(function()
        while true do
            task.wait(2)
            
            local success = pcall(function()
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
                        
                        -- Esperar un momento para que todos los datos se carguen
                        task.wait(1)
                        
                        warn("[TRACKER] Game ended! Searching for data...")
                        warn("[DEBUG] ========== GameEnd Structure ==========")
                        
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
            
            if not success then
                task.wait(1)
            end
        end
    end)
end

local statusLabel = createWebhookGui()
detectGameStart(statusLabel)

warn("========================================")
warn("[WEBHOOK TRACKER] Initialized")
warn("[INFO] Ejecutor: " .. (writefile and "✓ Compatible (Delta)" or "✗ No compatible"))
warn("[INFO] Webhook: " .. (_G.webhookURL ~= "" and "✓ Cargado" or "⚠️ No configurado"))
warn("[INFO] Start a game - tracker will auto-detect!")
warn("========================================")
