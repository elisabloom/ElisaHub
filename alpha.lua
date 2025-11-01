local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local plr = Players.LocalPlayer
repeat wait() until plr
repeat wait() until plr:FindFirstChild("PlayerGui")

local PlayerGui = plr:WaitForChild("PlayerGui")

getgenv().isTracking = getgenv().isTracking or false
getgenv().webhookURL = getgenv().webhookURL or ""
getgenv().gamesPlayed = getgenv().gamesPlayed or 0
getgenv().lastSeeds = getgenv().lastSeeds or 0
getgenv().lastCandy = getgenv().lastCandy or 0

local WEBHOOK_FILE = "webhook_config.txt"

local MAP_NAMES = {
    ["map_dojo"] = "Dojo",
    ["map_back_garden"] = "Back Garden",
    ["map_toxic"] = "Toxic",
    ["map_island"] = "Island",
    ["map_jungle"] = "Jungle",
    ["map_farm"] = "Farm",
    ["map_graveyard"] = "Graveyard"
}

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

local function getCurrentMapAndDifficulty()
    local success, results = pcall(function()
        local gui = PlayerGui:FindFirstChild("GameGui")
        if not gui then return "Unknown", "Unknown", "XX" end
        
        local map = "Unknown"
        local difficulty = "Unknown"
        local wave = "XX"
        
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = obj.Text
                
                if txt:match("(%a+):%s*Wave%s*(%d+)%s*/%s*(%d+)") then
                    local dif, currentWave, totalWaves = txt:match("(%a+):%s*Wave%s*(%d+)%s*/%s*(%d+)")
                    if dif then
                        difficulty = dif
                        wave = currentWave or "XX"
                    end
                end
            end
        end
        
        local workspace = game:GetService("Workspace")
        for mapId, mapName in pairs(MAP_NAMES) do
            if workspace:FindFirstChild(mapId) then
                map = mapName
                break
            end
        end
        
        if map == "Unknown" then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("TextLabel") then
                    local txt = obj.Text
                    if txt:find("Graveyard") then map = "Graveyard" break end
                    if txt:find("Dojo") then map = "Dojo" break end
                    if txt:find("Back Garden") then map = "Back Garden" break end
                    if txt:find("Toxic") then map = "Toxic" break end
                    if txt:find("Island") then map = "Island" break end
                    if txt:find("Jungle") then map = "Jungle" break end
                    if txt:find("Farm") then map = "Farm" break end
                end
            end
        end
        
        return map, difficulty, wave
    end)
    
    if success then 
        return results 
    else 
        return "Unknown", "Unknown", "XX" 
    end
end

local function getTotalSeedsFromLeaderstats()
    local success, result = pcall(function()
        local leaderstats = plr:FindFirstChild("leaderstats")
        if leaderstats then
            local seeds = leaderstats:FindFirstChild("Seeds")
            if seeds and seeds:IsA("StringValue") then
                local num = seeds.Value:match("(%d+)")
                if num then return tonumber(num) end
            end
        end
        return 0
    end)
    
    if success then return result else return 0 end
end

local function getTotalCandyFromLeaderstats()
    local success, result = pcall(function()
        local leaderstats = plr:FindFirstChild("leaderstats")
        if leaderstats then
            local cash = leaderstats:FindFirstChild("Cash")
            if cash and cash:IsA("StringValue") then
                local num = cash.Value:match("(%d+)")
                if num then return tonumber(num) end
            end
        end
        return 0
    end)
    
    if success then return result else return 0 end
end

local function getRewardsFromNotification()
    local success, results = pcall(function()
        local gui = PlayerGui:FindFirstChild("GameGui")
        if not gui then return 0, 0 end
        
        local seedsReward = 0
        local candyReward = 0
        
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = obj.Text
                
                if txt:match("You got (%d+) Seeds") then
                    seedsReward = tonumber(txt:match("You got (%d+) Seeds"))
                end
                
                if txt:match("You got (%d+) Candy") or txt:match("You got (%d+) candy") then
                    candyReward = tonumber(txt:match("You got (%d+) [Cc]andy"))
                end
            end
        end
        
        return seedsReward, candyReward
    end)
    
    if success then return results else return 0, 0 end
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
        
        local currentTotalSeeds = getTotalSeedsFromLeaderstats()
        local currentTotalCandy = getTotalCandyFromLeaderstats()
        
        local seedsReward, candyReward = getRewardsFromNotification()
        
        if seedsReward == 0 and getgenv().lastSeeds > 0 then
            seedsReward = currentTotalSeeds - getgenv().lastSeeds
        end
        
        if candyReward == 0 and getgenv().lastCandy > 0 then
            candyReward = currentTotalCandy - getgenv().lastCandy
        end
        
        getgenv().lastSeeds = currentTotalSeeds
        getgenv().lastCandy = currentTotalCandy
        
        local result = getGameResult(endFrame)
        local map, difficulty, wave = getCurrentMapAndDifficulty()
        
        local runTime = "N/A"
        
        for _, obj in pairs(endFrame:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = obj.Text
                
                if txt:match("Run time:%s*(%d+:%d+)") then
                    runTime = txt:match("Run time:%s*(%d+:%d+)")
                    break
                elseif txt:match("Run time:%s*(%d+)") then
                    local secs = tonumber(txt:match("Run time:%s*(%d+)"))
                    if secs then
                        local mins = math.floor(secs / 60)
                        local remainingSecs = secs % 60
                        runTime = string.format("%d:%02d", mins, remainingSecs)
                        break
                    end
                end
            end
        end
        
        local color = result == "Victory" and 3066993 or 15158332
        
        local userName = plr.Name
        
        local description = string.format(
            "**Garden Tower Defense**\n\n" ..
            "**User:** ||%s||\n\n" ..
            "**Total Replays:** %d\n\n" ..
            "**Player Stats          Rewards**\n" ..
            "🌱 %s                    🌱 +%s\n" ..
            "🍬 %s                    🍬 +%s\n\n" ..
            "**Match Results**\n" ..
            "**%s**\n" ..
            "**%s - Wave %s**\n" ..
            "**%s - %s**",
            userName,
            getgenv().gamesPlayed,
            tostring(currentTotalSeeds), tostring(seedsReward),
            tostring(currentTotalCandy), tostring(candyReward),
            result,
            runTime, wave,
            map, difficulty
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
        
        warn("[WEBHOOK] Sent! Result: " .. result .. " | Seeds Reward: +" .. seedsReward .. " | Candy Reward: +" .. candyReward .. " | Time: " .. runTime .. " | Map: " .. map .. " | Difficulty: " .. difficulty .. " | Wave: " .. wave .. " | Games: " .. getgenv().gamesPlayed)
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
