repeat task.wait() until game:IsLoaded()
task.wait(2)

local Players = game:GetService(“Players”)
local plr = Players.LocalPlayer
local HttpService = game:GetService(“HttpService”)

repeat task.wait() until plr and plr.Parent
repeat task.wait() until plr:FindFirstChild(“PlayerGui”)

warn(”[INIT] Starting Webhook Tracker…”)

_G.isTracking = _G.isTracking or false
_G.gameStartTime = _G.gameStartTime or nil
_G.isMinimized = _G.isMinimized or false
_G.webhookURL = _G.webhookURL or “”

local WEBHOOK_FILE = “webhook_tracker_config.txt”

local function loadWebhook()
if readfile and isfile then
local success, result = pcall(function()
if isfile(WEBHOOK_FILE) then
local savedURL = readfile(WEBHOOK_FILE)
if savedURL and savedURL ~= “” then
_G.webhookURL = savedURL
warn(”[WEBHOOK] Loaded from file”)
return true
end
end
return false
end)

```
    if not success then
        warn("[WEBHOOK] Load error: " .. tostring(result))
    end
end
```

end

local function saveWebhook(url)
if writefile then
local success, err = pcall(function()
writefile(WEBHOOK_FILE, url)
end)

```
    if success then
        warn("[WEBHOOK] Saved")
        return true
    else
        warn("[WEBHOOK] Save error: " .. tostring(err))
        return false
    end
end
return false
```

end

pcall(loadWebhook)

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

local function getCandyFromGameGui()
local success, result = pcall(function()
local gameGui = plr.PlayerGui:FindFirstChild(“GameGui”)
if not gameGui then return “N/A” end

```
    for _, descendant in pairs(gameGui:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            local text = descendant.Text
            
            if text:match("🍬") or descendant.Name:lower():find("candy") then
                local number = text:match("%d+")
                if number then
                    warn("[DEBUG] Candy found: " .. number)
                    return number
                end
            end
            
            if text == "🍬" or text:match("🍬") then
                local parent = descendant.Parent
                if parent then
                    for _, sibling in pairs(parent:GetChildren()) do
                        if sibling:IsA("TextLabel") and sibling ~= descendant then
                            local candyNum = sibling.Text:match("%d+")
                            if candyNum then
                                warn("[DEBUG] Candy in sibling: " .. candyNum)
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
    warn("[ERROR] getCandyFromGameGui: " .. tostring(result))
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
    MinimizeButton.Text = "-"
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
    SaveButton.Text = "Save"
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
    ClearButton.Text = "Clear"
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
    StatusLabel.Text = "Waiting for game..."
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 10
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatusLabel.TextWrapped = true
    StatusLabel.Parent = WebhookFrame
    
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
            MinimizeButton.Text = "-"
            WebhookInput.Visible = true
            SaveButton.Visible = true
            ClearButton.Visible = true
            StatusLabel.Visible = true
        end
    end)
    
    SaveButton.MouseButton1Click:Connect(function()
        _G.webhookURL = WebhookInput.Text
        saveWebhook(_G.webhookURL)
        SaveButton.Text = "Saved!"
        SaveButton.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        task.wait(1.5)
        SaveButton.Text = "Save"
        SaveButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    end)
    
    ClearButton.MouseButton1Click:Connect(function()
        _G.webhookURL = ""
        saveWebhook("")
        WebhookInput.Text = ""
        ClearButton.Text = "Cleared!"
        task.wait(1)
        ClearButton.Text = "Clear"
    end)
    
    return StatusLabel
end)

if success then
    return gui
else
    warn("[ERROR] GUI creation failed: " .. tostring(gui))
    return nil
end
```

end

local function sendWebhook(gameEndFrame, statusLabel)
if _G.webhookURL == “” or not _G.webhookURL then
warn(”[WEBHOOK] No URL configured”)
if statusLabel then
statusLabel.Text = “No webhook URL set!”
end
return
end

```
local success, err = pcall(function()
    local currentTime = os.date("%Y-%m-%d %H:%M:%S")
    
    local leaderstats = plr:WaitForChild("leaderstats", 5)
    local totalSeeds = "N/A"
    
    if leaderstats then
        local seedsValue = leaderstats:FindFirstChild("Seeds")
        if seedsValue then
            totalSeeds = getValueSafe(seedsValue)
            warn("[DEBUG] Seeds: " .. totalSeeds)
        end
    end
    
    local totalCandy = getCandyFromGameGui()
    warn("[DEBUG] Candy: " .. totalCandy)
    
    local resultText = "Unknown"
    
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
        warn("[DEBUG] Result: " .. resultText)
    end
    
    if resultText == "Unknown" then
        for _, child in pairs(gameEndFrame:GetDescendants()) do
            if child:IsA("TextLabel") then
                local text = child.Text:lower()
                
                if text:find("victory") or text:find("win") or text:find("won") or 
                   text:find("success") or text:find("complete") then
                    resultText = "Victory"
                    warn("[DEBUG] Victory in: " .. child.Name)
                    break
                end
                
                if text:find("defeat") or text:find("lost") or text:find("lose") or 
                   text:find("fail") or text:find("game over") then
                    resultText = "Defeat"
                    warn("[DEBUG] Defeat in: " .. child.Name)
                    break
                end
            end
        end
    end
    
    local runTime = "00:00"
    
    for _, child in pairs(gameEndFrame:GetDescendants()) do
        if child:IsA("TextLabel") then
            local text = child.Text
            local timeMatch = text:match("(%d+:%d+)")
            if timeMatch then
                runTime = timeMatch
                warn("[DEBUG] Time: " .. runTime)
                break
            end
        end
    end
    
    local embedColor = resultText == "Victory" and 3066993 or 15158332
    
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
                    ["name"] = "Seeds:",
                    ["value"] = totalSeeds,
                    ["inline"] = true
                },
                {
                    ["name"] = "Candy:",
                    ["value"] = totalCandy,
                    ["inline"] = true
                },
                {
                    ["name"] = "Run Time:",
                    ["value"] = runTime,
                    ["inline"] = true
                },
                {
                    ["name"] = "Result:",
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
    
    warn("[WEBHOOK] Sent! " .. resultText)
    if statusLabel then
        statusLabel.Text = "Webhook sent!\n" .. resultText .. " | " .. runTime
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end
end)

if not success then
    warn("[WEBHOOK ERROR] " .. tostring(err))
    if statusLabel then
        statusLabel.Text = "Webhook failed!"
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
                        statusLabel.Text = "Game in progress..."
                        statusLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
                    end
                    
                    repeat
                        task.wait(0.5)
                    until gameEndFrame.Visible == true
                    
                    task.wait(2.5)
                    
                    warn("[TRACKER] Game ended!")
                    
                    if statusLabel then
                        statusLabel.Text = "Sending webhook..."
                        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                    end
                    
                    sendWebhook(gameEndFrame, statusLabel)
                    
                    task.wait(3)
                    _G.isTracking = false
                    
                    if statusLabel then
                        statusLabel.Text = "Waiting for next game..."
                        statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                    end
                end
            end
        end)
    end
end)
```

end

local statusLabel = createWebhookGui()
if statusLabel then
detectGameStart(statusLabel)
warn(”=================================”)
warn(”[TRACKER] Initialized successfully”)
warn(”[INFO] Webhook: “ .. (_G.webhookURL ~= “” and “Loaded” or “Not configured”))
warn(”=================================”)
else
warn(”[ERROR] Failed to initialize”)
end