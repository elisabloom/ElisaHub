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

local function getBigNumberFromScreen()
    local success, result = pcall(function()
        local gui = plr.PlayerGui:FindFirstChild("GameGui")
        if not gui then return nil, nil end
        
        local numbers = {}
        
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = obj.Text
                local bigNumber = txt:match("(%d%d%d%d%d%d+)")
                if bigNumber then
                    local numVal = tonumber(bigNumber)
                    if numVal and numVal > 100000 then
                        table.insert(numbers, numVal)
                    end
                end
            end
        end
        
        table.sort(numbers, function(a, b) return a > b end)
        
        if #numbers >= 2 then
            return tostring(numbers[1]), tostring(numbers[2])
        elseif #numbers == 1 then
            return tostring(numbers[1]), "N/A"
        end
        
        return "N/A", "N/A"
    end)
    
    if success then 
        return result 
    else 
        return "N/A", "N/A" 
    end
end

local function makeGUI()
    local old = plr.PlayerGui:FindFirstChild("WebhookGUI")
    if old then old:Destroy() end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "WebhookGUI"
    sg.ResetOnSpawn = false
    sg.Parent = plr.PlayerGui
    
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 210, 0, 25)
    fr.Position = UDim2.new(1, -220, 1, -35)
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
    
    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(0, 25, 0, 25)
    expandBtn.Position = UDim2.new(1, -25, 0, 0)
    expandBtn.Text = "+"
    expandBtn.Font = Enum.Font.GothamBold
    expandBtn.TextSize = 18
    expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    expandBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    expandBtn.BorderSizePixel = 0
    expandBtn.Parent = fr
    
    Instance.new("UICorner", expandBtn).CornerRadius = UDim.new(0, 6)
    
    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(1, -20, 0, 28)
    input.Position = UDim2.new(0, 10, 0, 30)
    input.PlaceholderText = "Webhook URL..."
    input.Text = getgenv().webhookURL
    input.Font = Enum.Font.Gotham
    input.TextSize = 8
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.BorderSizePixel = 0
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.TextWrapped = true
    input.Visible = false
    input.Parent = fr
    
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 90, 0, 25)
    saveBtn.Position = UDim2.new(0, 10, 0, 65)
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
    clearBtn.Size = UDim2.new(0, 90, 0, 25)
    clearBtn.Position = UDim2.new(0, 110, 0, 65)
    clearBtn.Text = "Clear"
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 10
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    clearBtn.BorderSizePixel = 0
    clearBtn.Visible = false
    clearBtn.Parent = fr
    
    Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)
    
    expandBtn.MouseButton1Click:Connect(function()
        local isExpanded = expandBtn.Text == "-"
        
        if isExpanded then
            fr:TweenSize(UDim2.new(0, 210, 0, 25), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            expandBtn.Text = "+"
            input.Visible = false
            saveBtn.Visible = false
            clearBtn.Visible = false
        else
            fr:TweenSize(UDim2.new(0, 210, 0, 97), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
            expandBtn.Text = "-"
            wait(0.3)
            input.Visible = true
            saveBtn.Visible = true
            clearBtn.Visible = true
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
end

local function sendHook(endFrame)
    pcall(function()
        if getgenv().webhookURL == "" then
            return
        end
        
        local time = os.date("%Y-%m-%d %H:%M:%S")
        
        local seeds, candy = getBigNumberFromScreen()
        
        local result = "Unknown"
        local runTime = "N/A"
        
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
                description = "User: " .. plr.Name .. "\nSeed: " .. seeds .. "\nCandy: " .. candy .. "\nRun Time: " .. runTime .. "\nResult: " .. result,
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
    end)
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
                        wait(2.5)
                        
                        sendHook(endFrame)
                        
                        wait(3)
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
