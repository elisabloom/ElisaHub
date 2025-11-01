wait(1)
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer
wait(1)

getgenv().isTracking = getgenv().isTracking or false
getgenv().webhookURL = getgenv().webhookURL or ""
getgenv().isMinimized = getgenv().isMinimized or false

local WEBHOOK_FILE = "webhook_config.txt"

local function loadWebhook()
    if isfile and readfile then
        pcall(function()
            if isfile(WEBHOOK_FILE) then
                local url = readfile(WEBHOOK_FILE)
                if url and url ~= "" then
                    getgenv().webhookURL = url
                end
            end
        end)
    end
end

local function saveWebhook(url)
    if writefile then
        pcall(function()
            writefile(WEBHOOK_FILE, url)
        end)
    end
end

loadWebhook()

local function getValueSafe(obj)
    if not obj then return "N/A" end
    local v = obj.Value
    if type(v) == "number" then return tostring(v) end
    if type(v) == "string" then return v end
    return tostring(v)
end

local function makeGUI()
    local old = plr.PlayerGui:FindFirstChild("WebhookGUI")
    if old then old:Destroy() end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "WebhookGUI"
    sg.ResetOnSpawn = false
    sg.Parent = plr.PlayerGui
    
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 210, 0, 132)
    fr.Position = UDim2.new(1, -220, 1, -142)
    fr.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    fr.BackgroundTransparency = 0.1
    fr.BorderSizePixel = 0
    fr.Active = true
    fr.Draggable = true
    fr.Parent = sg
    
    local corner = Instance.new("UICorner", fr)
    corner.CornerRadius = UDim.new(0, 10)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -30, 0, 25)
    title.BackgroundTransparency = 1
    title.Text = "Webhook Tracker"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = fr
    
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 25, 0, 25)
    minBtn.Position = UDim2.new(1, -25, 0, 0)
    minBtn.Text = "-"
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 18
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    minBtn.BorderSizePixel = 0
    minBtn.Parent = fr
    
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)
    
    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(1, -20, 0, 28)
    input.Position = UDim2.new(0, 10, 0, 30)
    input.PlaceholderText = "Webhook URL..."
    input.Text = getgenv().webhookURL
    input.Font = Enum.Font.Gotham
    input.TextSize = 9
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.BorderSizePixel = 0
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.Parent = fr
    
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 60, 0, 25)
    saveBtn.Position = UDim2.new(0, 10, 0, 65)
    saveBtn.Text = "Save"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 10
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    saveBtn.BorderSizePixel = 0
    saveBtn.Parent = fr
    
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 60, 0, 25)
    clearBtn.Position = UDim2.new(0, 75, 0, 65)
    clearBtn.Text = "Clear"
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 10
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    clearBtn.BorderSizePixel = 0
    clearBtn.Parent = fr
    
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
    
    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(1, -20, 0, 35)
    status.Position = UDim2.new(0, 10, 0, 95)
    status.BackgroundTransparency = 1
    status.Text = "Waiting..."
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.TextColor3 = Color3.fromRGB(255, 200, 100)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextYAlignment = Enum.TextYAlignment.Top
    status.TextWrapped = true
    status.Parent = fr
    
    minBtn.MouseButton1Click:Connect(function()
        getgenv().isMinimized = not getgenv().isMinimized
        if getgenv().isMinimized then
            fr:TweenSize(UDim2.new(0, 210, 0, 25), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            minBtn.Text = "+"
            input.Visible = false
            saveBtn.Visible = false
            clearBtn.Visible = false
            status.Visible = false
        else
            fr:TweenSize(UDim2.new(0, 210, 0, 132), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            minBtn.Text = "-"
            input.Visible = true
            saveBtn.Visible = true
            clearBtn.Visible = true
            status.Visible = true
        end
    end)
    
    saveBtn.MouseButton1Click:Connect(function()
        getgenv().webhookURL = input.Text
        saveWebhook(input.Text)
        saveBtn.Text = "Saved!"
        wait(1)
        saveBtn.Text = "Save"
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        getgenv().webhookURL = ""
        saveWebhook("")
        input.Text = ""
        clearBtn.Text = "Cleared!"
        wait(1)
        clearBtn.Text = "Clear"
    end)
    
    return status
end

local function sendHook(endFrame, statusLbl)
    pcall(function()
        if getgenv().webhookURL == "" then
            if statusLbl then statusLbl.Text = "No URL!" end
            return
        end
        
        local time = os.date("%Y-%m-%d %H:%M:%S")
        local seeds = "N/A"
        local candy = "N/A"
        local result = "Unknown"
        local runTime = "N/A"
        
        local stats = plr:FindFirstChild("leaderstats")
        if stats then
            local seedsObj = stats:FindFirstChild("Seeds")
            if seedsObj then 
                seeds = getValueSafe(seedsObj)
            end
            
            local candyObj = stats:FindFirstChild("Candy")
            if candyObj then 
                candy = getValueSafe(candyObj)
            end
        end
        
        local foundResult = false
        local foundTime = false
        
        for _, obj in pairs(endFrame:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = obj.Text
                local txtLower = txt:lower()
                
                if not foundResult then
                    if txt == "Victory" or txt == "Defeat" then
                        result = txt
                        foundResult = true
                    elseif txtLower == "victory" or txtLower == "defeat" then
                        result = txt:sub(1,1):upper() .. txt:sub(2):lower()
                        foundResult = true
                    elseif txtLower:find("victory") or txtLower:find("win") then
                        result = "Victory"
                        foundResult = true
                    elseif txtLower:find("defeat") or txtLower:find("overwhelmed") then
                        result = "Defeat"
                        foundResult = true
                    end
                end
                
                if not foundTime then
                    if txtLower:find("run time") then
                        local t = txt:match("(%d+:%d+)")
                        if t then
                            runTime = t
                            foundTime = true
                        end
                    else
                        local t = txt:match("(%d+:%d+)")
                        if t and obj.Name:lower():find("time") then
                            runTime = t
                            foundTime = true
                        end
                    end
                end
            end
        end
        
        local color = result == "Victory" and 3066993 or 15158332
        
        local data = {
            embeds = {{
                title = "Seed Tracker",
                color = color,
                fields = {
                    {name = "User:", value = plr.Name, inline = false},
                    {name = "Seed:", value = seeds, inline = false},
                    {name = "Candy:", value = candy, inline = false},
                    {name = "Run Time:", value = runTime, inline = false},
                    {name = "Result:", value = result, inline = false}
                },
                footer = {text = "Noah Hub | " .. time}
            }}
        }
        
        local json = HttpService:JSONEncode(data)
        
        request({
            Url = getgenv().webhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
        
        if statusLbl then
            statusLbl.Text = "Sent! " .. result
            statusLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
        end
    end)
end

local function startTracking(statusLbl)
    spawn(function()
        while wait(2) do
            pcall(function()
                local gui = plr.PlayerGui:FindFirstChild("GameGui")
                if gui and not getgenv().isTracking then
                    local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                    if endFrame and not endFrame.Visible then
                        getgenv().isTracking = true
                        if statusLbl then
                            statusLbl.Text = "Game started..."
                            statusLbl.TextColor3 = Color3.fromRGB(100, 200, 255)
                        end
                        
                        repeat wait(0.5) until endFrame.Visible
                        wait(2.5)
                        
                        if statusLbl then statusLbl.Text = "Sending..." end
                        sendHook(endFrame, statusLbl)
                        
                        wait(3)
                        getgenv().isTracking = false
                        if statusLbl then
                            statusLbl.Text = "Waiting..."
                            statusLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
                        end
                    end
                end
            end)
        end
    end)
end

local statusLabel = makeGUI()
startTracking(statusLabel)
print("Webhook Tracker loaded successfully!")
