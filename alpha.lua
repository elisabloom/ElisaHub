local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local plr = Players.LocalPlayer
repeat wait() until plr
repeat wait() until plr:FindFirstChild("PlayerGui")

local PlayerGui = plr:WaitForChild("PlayerGui")

getgenv().isTracking = getgenv().isTracking or false
getgenv().webhookURL = getgenv().webhookURL or ""
getgenv().gamesPlayed = getgenv().gamesPlayed or 0

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
        local gui = PlayerGui:FindFirstChild("GameGui")
        if not gui then return "N/A" end
        
        local seedsDisplay = gui:FindFirstChild("SeedsDisplay", true)
        
        if seedsDisplay then
            local titleLabel = seedsDisplay:FindFirstChild("Title")
            if titleLabel and titleLabel:IsA("TextLabel") then
                local num = titleLabel.Text:match("(%d+)")
                if num then
                    return num
                end
            end
        end
        
        local currencyDisplay = gui:FindFirstChild("CurrencyDisplay", true)
        if currencyDisplay then
            local seedsDisplay = currencyDisplay:FindFirstChild("SeedsDisplay")
            if seedsDisplay then
                local titleLabel = seedsDisplay:FindFirstChild("Title")
                if titleLabel and titleLabel:IsA("TextLabel") then
                    local num = titleLabel.Text:match("(%d+)")
                    if num then return num end
                end
            end
        end
        
        return "N/A"
    end)
    
    if success then return result else return "N/A" end
end

local function getCandyCornFromScreen()
    local success, result = pcall(function()
        local gui = PlayerGui:FindFirstChild("GameGui")
        if not gui then return "N/A" end
        
        local candyDisplay = gui:FindFirstChild("CandyCornsDisplay", true)
        
        if candyDisplay then
            local titleLabel = candyDisplay:FindFirstChild("Title")
            if titleLabel and titleLabel:IsA("TextLabel") then
                local num = titleLabel.Text:match("(%d+)")
                if num then
                    return num
                end
            end
        end
        
        return "N/A"
    end)
    
    if success then return result else return "N/A" end
end

local function getGameResult(endFrame)
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local txt = obj.Text
            local txtLower = txt:lower()
            
            if txtLower:find("overwhelmed") then
                return "Defeat"
            elseif txtLower:find("defeated") or txtLower:find("game over") then
                return "Defeat"
            elseif txtLower:find("cleared all waves") or (txtLower:find("cleared") and txtLower:find("%d+")) then
                return "Victory"
            elseif txtLower:find("you win") or txtLower:find("congratulations") then
                return "Victory"
            end
        end
    end
    
    local titles = {}
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Name == "Title" then
            if obj.Text == "Victory" or obj.Text == "Defeat" then
                table.insert(titles, {
                    text = obj.Text,
                    obj = obj,
                    size = obj.TextSize,
                    transparency = obj.TextTransparency,
                    visible = obj.Visible
                })
            end
        end
    end
    
    table.sort(titles, function(a, b)
        if a.transparency ~= b.transparency then
            return a.transparency < b.transparency
        end
        return a.size > b.size
    end)
    
    if #titles > 0 and titles[1].visible then
        return titles[1].text
    end
    
    return "Unknown"
end

local function makeGUI()
    local old = PlayerGui:FindFirstChild("WebhookGUI")
    if old then old:Destroy() end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "WebhookGUI"
    sg.ResetOnSpawn = false
    sg.Parent = PlayerGui
    
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
    input.Text = getgenv().webhookURL
    input.Font = Enum.Font.Gotham
    input.TextSize = 7
    input.TextColor3 = Color3.fromRGB(200, 200, 200)
    input.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    input.BorderSizePixel = 0
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false
    input.TextWrapped = false
    input.ClipsDescendants = true
    input.TextTruncate = Enum.TextTruncate.AtEnd
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
    
    saveBtn.MouseButton1Click:Connect(function()
        if input.Text ~= "" then
            getgenv().webhookURL = input.Text
            saveWebhook(input.Text)
            saveBtn.Text = "Saved!"
            wait(1)
            saveBtn.Text = "Save"
        end
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
    local success, err = pcall(function()
        if getgenv().webhookURL == "" or not getgenv().webhookURL then
            warn("[WEBHOOK] No URL configured")
            return
        end
        
        getgenv().gamesPlayed = getgenv().gamesPlayed + 1
        
        local time = os.date("%Y-%m-%d %H:%M:%S")
        
        local seeds = getSeedsFromScreen()
        local candy = getCandyCornFromScreen()
        local result = getGameResult(endFrame)
        
        local runTime = "N/A"
        
        local items = endFrame:FindFirstChild("Items", true)
        if items then
            local txtLabel = items:FindFirstChild("txt")
            if txtLabel and txtLabel:IsA("TextLabel") then
                local fullText = txtLabel.Text
                
                local timeMatch = fullText:match("Run time[:%s]*(%d+:%d+)")
                if timeMatch then
                    runTime = timeMatch
                elseif fullText:lower():find("run time") then
                    local secsMatch = fullText:match("Run time[:%s]*(%d+)%s*$")
                    if secsMatch then
                        local secs = tonumber(secsMatch)
                        if secs and secs < 3600 then
                            local mins = math.floor(secs / 60)
                            local remainingSecs = secs % 60
                            runTime = string.format("%d:%02d", mins, remainingSecs)
                        end
                    end
                end
            end
        end
        
        if runTime == "N/A" then
            for _, obj in pairs(endFrame:GetDescendants()) do
                if obj:IsA("TextLabel") then
                    local txt = obj.Text
                    local txtLower = txt:lower()
                    
                    if txtLower:find("run time") then
                        local timeMatch = txt:match("(%d+:%d+)")
                        if timeMatch then
                            runTime = timeMatch
                            break
                        end
                        
                        local secsMatch = txt:match("run time[:%s]*(%d+)%s*$")
                        if secsMatch then
                            local secs = tonumber(secsMatch)
                            if secs and secs < 3600 then
                                local mins = math.floor(secs / 60)
                                local remainingSecs = secs % 60
                                runTime = string.format("%d:%02d", mins, remainingSecs)
                                break
                            end
                        end
                    end
                end
            end
        end
        
        if runTime == "N/A" then
            for _, obj in pairs(endFrame:GetDescendants()) do
                if obj:IsA("TextLabel") then
                    local objName = obj.Name:lower()
                    if objName:find("time") or objName == "txt" then
                        local txt = obj.Text
                        
                        local timeMatch = txt:match("(%d+:%d+)")
                        if timeMatch then
                            runTime = timeMatch
                            break
                        end
                        
                        if txt:lower():find("run") or txt:lower():find("time") then
                            local num = txt:match("(%d+)%s*$")
                            if num then
                                local secs = tonumber(num)
                                if secs and secs > 0 and secs < 600 then
                                    local mins = math.floor(secs / 60)
                                    local remainingSecs = secs % 60
                                    runTime = string.format("%d:%02d", mins, remainingSecs)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        
        local color = result == "Victory" and 3066993 or 15158332
        
        local userName = "||" .. plr.Name .. "||"
        
        local description = string.format(
            "**Garden Tower Defense**\n\n" ..
            "**User:** %s\n\n" ..
            "**Matches Played:** %d\n\n" ..
            "**Stats**\n" ..
            "🌱 Seeds: %s\n" ..
            "🍬 Candy: %s\n\n" ..
            "**Match Results**\n" ..
            "%s\n" ..
            "Run Time: %s",
            userName,
            getgenv().gamesPlayed,
            seeds,
            candy,
            result,
            runTime
        )
        
        local data = {
            embeds = {{
                title = nil,
                color = color,
                description = description,
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
        
        warn("[WEBHOOK] Sent! Result: " .. result .. " | Seeds: " .. seeds .. " | Candy: " .. candy .. " | Time: " .. runTime .. " | Games: " .. getgenv().gamesPlayed)
    end)
    
    if not success then
        warn("[WEBHOOK ERROR] " .. tostring(err))
    end
end

local function startTracking()
    spawn(function()
        while wait(1) do
            pcall(function()
                local gui = PlayerGui:FindFirstChild("GameGui")
                if gui and not getgenv().isTracking then
                    local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                    if endFrame and not endFrame.Visible then
                        getgenv().isTracking = true
                        
                        repeat wait(0.3) until endFrame.Visible
                        wait(1)
                        
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
print("Webhook Tracker loaded! Games Played: " .. getgenv().gamesPlayed)
