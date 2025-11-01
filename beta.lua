-- Webhook Tracker
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer

getgenv().isTracking = getgenv().isTracking or false
getgenv().webhookURL = getgenv().webhookURL or ""

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

local function getSeedsFromScreen()
    local success, result = pcall(function()
        local gui = plr.PlayerGui:FindFirstChild("GameGui")
        if not gui then return "N/A" end
        
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = obj.Text
                local bigNumber = txt:match("(%d%d%d%d%d%d+)")
                if bigNumber then
                    local numVal = tonumber(bigNumber)
                    if numVal and numVal > 100000 then
                        return bigNumber
                    end
                end
            end
        end
        
        return "N/A"
    end)
    
    if success then return result else return "N/A" end
end

local function getCandyFromScreen()
    local success, result = pcall(function()
        local gui = plr.PlayerGui:FindFirstChild("GameGui")
        if not gui then return "N/A" end
        
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("ImageLabel") then
                local imgName = obj.Name:lower()
                local imgSrc = tostring(obj.Image):lower()
                
                if imgName:find("candy") or imgSrc:find("candy") then
                    local parent = obj.Parent
                    if parent then
                        for _, sibling in pairs(parent:GetChildren()) do
                            if sibling:IsA("TextLabel") then
                                local num = sibling.Text:match("(%d+)")
                                if num then
                                    return num
                                end
                            end
                        end
                    end
                end
            end
        end
        
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = obj.Text
                if txt:match("🍬") then
                    local parent = obj.Parent
                    if parent then
                        for _, sibling in pairs(parent:GetChildren()) do
                            if sibling:IsA("TextLabel") and sibling ~= obj then
                                local num = sibling.Text:match("(%d+)")
                                if num then
                                    return num
                                end
                            end
                        end
                    end
                end
            end
        end
        
        return "N/A"
    end)
    
    if success then return result else return "N/A" end
end

local function makeGUI()
    local old = plr.PlayerGui:FindFirstChild("WebhookGUI")
    if old then old:Destroy() end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "WebhookGUI"
    sg.ResetOnSpawn = false
    sg.Parent = plr.PlayerGui
    
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 180, 0, 25)
    fr.Position = UDim2.new(1, -190, 1, -35)
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
    title.TextSize = 11
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Parent = fr
    
    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(0, 25, 0, 25)
    expandBtn.Position = UDim2.new(1, -25, 0, 0)
    expandBtn.Text = "+"
    expandBtn.Font = Enum.Font.GothamBold
    expandBtn.TextSize = 16
    expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    expandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    expandBtn.BorderSizePixel = 0
    expandBtn.Parent = fr
    
    Instance.new("UICorner", expandBtn).CornerRadius = UDim.new(0, 6)
    
    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(1, -20, 0, 25)
    input.Position = UDim2.new(0, 10, 0, 30)
    input.PlaceholderText = "Webhook URL"
    input.Text = ""
    input.Font = Enum.Font.Gotham
    input.TextSize = 7
    input.TextColor3 = Color3.fromRGB(200, 200, 200)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    input.BorderSizePixel = 0
    input.TextXAlignment = Enum.TextXAlignment.Center
    input.ClearTextOnFocus = false
    input.TextWrapped = false
    input.ClipsDescendants = true
    input.Visible = false
    input.Parent = fr
    
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 75, 0, 22)
    saveBtn.Position = UDim2.new(0, 10, 0, 60)
    saveBtn.Text = "Save"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 10
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    saveBtn.BorderSizePixel = 0
    saveBtn.Visible = false
    saveBtn.Parent = fr
    
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
    
    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 75, 0, 22)
    clearBtn.Position = UDim2.new(0, 95, 0, 60)
    clearBtn.Text = "Clear"
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 10
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    clearBtn.BorderSizePixel = 0
    clearBtn.Visible = false
    clearBtn.Parent = fr
    
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
    
    if getgenv().webhookURL ~= "" then
        input.PlaceholderText = "Webhook saved"
    end
    
    expandBtn.MouseButton1Click:Connect(function()
        local isExpanded = expandBtn.Text == "-"
        
        if isExpanded then
            fr:TweenSize(UDim2.new(0, 180, 0, 25), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            expandBtn.Text = "+"
            input.Visible = false
            saveBtn.Visible = false
            clearBtn.Visible = false
        else
            fr:TweenSize(UDim2.new(0, 180, 0, 87), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            expandBtn.Text = "-"
            wait(0.3)
            input.Visible = true
            saveBtn.Visible = true
            clearBtn.Visible = true
        end
    end)
    
    input.Focused:Connect(function()
        input.Text = getgenv().webhookURL
    end)
    
    input.FocusLost:Connect(function()
        if input.Text == "" or input.Text == getgenv().webhookURL then
            input.Text = ""
        end
    end)
    
    saveBtn.MouseButton1Click:Connect(function()
        if input.Text ~= "" then
            getgenv().webhookURL = input.Text
            saveWebhook(input.Text)
            input.Text = ""
            input.PlaceholderText = "Webhook saved"
            saveBtn.Text = "Saved!"
            wait(1)
            saveBtn.Text = "Save"
        end
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        getgenv().webhookURL = ""
        saveWebhook("")
        input.Text = ""
        input.PlaceholderText = "Webhook URL"
        clearBtn.Text = "Cleared!"
        wait(1)
        clearBtn.Text = "Clear"
    end)
end

local function sendHook(endFrame)
    local success, err = pcall(function()
        if getgenv().webhookURL == "" or not getgenv().webhookURL then
            warn("[WEBHOOK] No URL configured")
            return
        end
        
        local time = os.date("%Y-%m-%d %H:%M:%S")
        
        local seeds = getSeedsFromScreen()
        local candy = getCandyFromScreen()
        
        local result = "Unknown"
        local runTime = "N/A"
        
        for _, obj in pairs(endFrame:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = obj.Text
                local txtLower = txt:lower()
                
                if txt == "Victory" or txt == "Defeat" then
                    result = txt
                elseif txtLower:find("victory") or txtLower:find("win") then
                    result = "Victory"
                elseif txtLower:find("defeat") or txtLower:find("overwhelmed") then
                    result = "Defeat"
                end
                
                if txtLower:find("run time") or obj.Name:lower():find("time") then
                    local t = txt:match("(%d+:%d+)")
                    if t then runTime = t end
                end
            end
        end
        
        local color = result == "Victory" and 3066993 or 15158332
        
        local data = {
            embeds = {{
                title = "Seed Tracker",
                color = color,
                description = "User: " .. plr.Name .. "\nSeed: " .. seeds .. "\nCandy: " .. candy .. "\nRun Time: " .. runTime .. "\nResult: " .. result,
                footer = {text = "Noah Hub | " .. time}
            }}
        }
        
        local jsonData = HttpService:JSONEncode(data)
        
        local response = request({
            Url = getgenv().webhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
        
        warn("[WEBHOOK] Sent successfully! Result: " .. result)
    end)
    
    if not success then
        warn("[WEBHOOK ERROR] " .. tostring(err))
    end
end

local function startTracking()
    spawn(function()
        while wait(2) do
            pcall(function()
                local gui = plr.PlayerGui:FindFirstChild("GameGui")
                if gui and not getgenv().isTracking then
                    local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                    if endFrame and not endFrame.Visible then
                        getgenv().isTracking = true
                        
                        repeat wait(0.5) until endFrame.Visible
                        wait(3)
                        
                        sendHook(endFrame)
                        
                        wait(2)
                        getgenv().isTracking = false
                    end
                end
            end)
        end
    end)
end

makeGUI()
startTracking()
print("Webhook Tracker loaded!")
