--// Discord Webhook Test - Real Game Data Tracker

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

_G.webhookURL = _G.webhookURL or ""
_G.isTracking = false
_G.gameStartTime = nil

local function createWebhookGui()
    local existingGui = plr.PlayerGui:FindFirstChild("WebhookTest")
    if existingGui then existingGui:Destroy() end
    
    local WebhookGui = Instance.new("ScreenGui")
    WebhookGui.Name = "WebhookTest"
    WebhookGui.ResetOnSpawn = false
    WebhookGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WebhookGui.Parent = plr:WaitForChild("PlayerGui")
    
    local WebhookFrame = Instance.new("Frame")
    WebhookFrame.Size = UDim2.new(0, 350, 0, 220)
    WebhookFrame.Position = UDim2.new(1, -360, 1, -230)
    WebhookFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    WebhookFrame.BackgroundTransparency = 0.1
    WebhookFrame.BorderSizePixel = 0
    WebhookFrame.Active = true
    WebhookFrame.Draggable = true
    WebhookFrame.Parent = WebhookGui
    
    local UICorner = Instance.new("UICorner", WebhookFrame)
    UICorner.CornerRadius = UDim.new(0, 10)
    
    local WebhookTitle = Instance.new("TextLabel")
    WebhookTitle.Size = UDim2.new(1, 0, 0, 30)
    WebhookTitle.BackgroundTransparency = 1
    WebhookTitle.Text = "Discord Webhook - Real Game Tracker"
    WebhookTitle.Font = Enum.Font.GothamBold
    WebhookTitle.TextSize = 15
    WebhookTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    WebhookTitle.Parent = WebhookFrame
    
    local WebhookInput = Instance.new("TextBox")
    WebhookInput.Size = UDim2.new(1, -20, 0, 40)
    WebhookInput.Position = UDim2.new(0, 10, 0, 40)
    WebhookInput.PlaceholderText = "Paste Discord Webhook URL here..."
    WebhookInput.Text = _G.webhookURL
    WebhookInput.Font = Enum.Font.Gotham
    WebhookInput.TextSize = 11
    WebhookInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    WebhookInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    WebhookInput.BorderSizePixel = 0
    WebhookInput.TextXAlignment = Enum.TextXAlignment.Left
    WebhookInput.ClearTextOnFocus = false
    WebhookInput.Parent = WebhookFrame
    
    local InputCorner = Instance.new("UICorner", WebhookInput)
    InputCorner.CornerRadius = UDim.new(0, 6)
    
    local SaveButton = Instance.new("TextButton")
    SaveButton.Size = UDim2.new(0.48, 0, 0, 35)
    SaveButton.Position = UDim2.new(0, 10, 0, 90)
    SaveButton.Text = "💾 Save"
    SaveButton.Font = Enum.Font.GothamBold
    SaveButton.TextSize = 14
    SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SaveButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    SaveButton.BorderSizePixel = 0
    SaveButton.Parent = WebhookFrame
    
    local SaveCorner = Instance.new("UICorner", SaveButton)
    SaveCorner.CornerRadius = UDim.new(0, 6)
    
    local ClearButton = Instance.new("TextButton")
    ClearButton.Size = UDim2.new(0.48, 0, 0, 35)
    ClearButton.Position = UDim2.new(0.52, 0, 0, 90)
    ClearButton.Text = "🗑️ Clear"
    ClearButton.Font = Enum.Font.GothamBold
    ClearButton.TextSize = 14
    ClearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ClearButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    ClearButton.BorderSizePixel = 0
    ClearButton.Parent = WebhookFrame
    
    local ClearCorner = Instance.new("UICorner", ClearButton)
    ClearCorner.CornerRadius = UDim.new(0, 6)
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 0, 135)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "⏸️ Status: Waiting for game..."
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 13
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = WebhookFrame
    
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Size = UDim2.new(1, -20, 0, 50)
    InfoLabel.Position = UDim2.new(0, 10, 0, 160)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.Text = "📌 Instructions:\n1. Save your webhook URL\n2. Start a game - tracker will auto-detect!"
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextSize = 11
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    InfoLabel.Parent = WebhookFrame
    
    SaveButton.MouseButton1Click:Connect(function()
        _G.webhookURL = WebhookInput.Text
        SaveButton.Text = "✓ Saved!"
        SaveButton.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        task.wait(1.5)
        SaveButton.Text = "💾 Save"
        SaveButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end)
    
    ClearButton.MouseButton1Click:Connect(function()
        _G.webhookURL = ""
        WebhookInput.Text = ""
        ClearButton.Text = "✓ Cleared!"
        task.wait(1)
        ClearButton.Text = "🗑️ Clear"
    end)
    
    return StatusLabel
end

local function sendWebhook(runTime, result, statusLabel)
    if _G.webhookURL == "" or not _G.webhookURL then
        warn("[WEBHOOK] No webhook URL configured!")
        if statusLabel then
            statusLabel.Text = "⚠️ Status: No webhook URL set!"
        end
        return
    end
    
    local success, err = pcall(function()
        local currentTime = os.date("%Y-%m-%d %H:%M:%S")
        local leaderstats = plr:WaitForChild("leaderstats", 5)
        local totalSeeds = leaderstats and leaderstats:FindFirstChild("Seeds") and leaderstats.Seeds.Value or "N/A"
        local totalCandy = leaderstats and leaderstats:FindFirstChild("Candy") and leaderstats.Candy.Value or "N/A"
        
        local embedColor = result == "Victory" and 3066993 or 15158332
        
        local data = {
            ["embeds"] = {{
                ["title"] = "Seed Tracker",
                ["color"] = embedColor,
                ["fields"] = {
                    {
                        ["name"] = "User:",
                        ["value"] = "||" .. plr.Name .. "||",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "Seed:",
                        ["value"] = tostring(totalSeeds),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Candy:",
                        ["value"] = tostring(totalCandy),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Run Time:",
                        ["value"] = runTime,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Result:",
                        ["value"] = result,
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
        
        warn("[WEBHOOK] Message sent successfully! (" .. result .. ")")
        if statusLabel then
            statusLabel.Text = "✅ Status: Webhook sent! (" .. result .. ")"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end)
    
    if not success then
        warn("[WEBHOOK ERROR] " .. tostring(err))
        if statusLabel then
            statusLabel.Text = "❌ Status: Webhook failed!"
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
                        warn("[TRACKER] Game started! Tracking...")
                        if statusLabel then
                            statusLabel.Text = "🎮 Status: Game in progress..."
                            statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                        end
                        
                        repeat
                            task.wait(0.5)
                        until gameEndFrame.Visible == true
                        
                        local gameDuration = tick() - _G.gameStartTime
                        local mins = math.floor(gameDuration / 60)
                        local secs = math.floor(gameDuration % 60)
                        local runTime = string.format("%02d:%02d", mins, secs)
                        
                        task.wait(0.5)
                        
                        local resultText = "Unknown"
                        pcall(function()
                            local resultLabel = gameEndFrame:FindFirstChild("Result")
                            if resultLabel and resultLabel:IsA("TextLabel") then
                                resultText = resultLabel.Text
                            end
                        end)
                        
                        warn("[TRACKER] Game ended! Result: " .. resultText .. " | Time: " .. runTime)
                        
                        if statusLabel then
                            statusLabel.Text = "📤 Status: Sending webhook..."
                            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                        end
                        
                        sendWebhook(runTime, resultText, statusLabel)
                        
                        task.wait(3)
                        _G.isTracking = false
                        
                        if statusLabel then
                            statusLabel.Text = "⏸️ Status: Waiting for next game..."
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
warn("[INFO] Paste your Discord Webhook URL and Save")
warn("[INFO] Start a game - tracker will auto-detect!")
warn("[INFO] Works with ANY game mode/map")
warn("========================================")
