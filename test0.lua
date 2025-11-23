local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- ✅ CARGAR WHITELIST DESDE PASTEBIN UNLISTED
local whitelist
local whitelistUrl = "https://pastebin.com/raw/TYqMyvcA"

local success, error = pcall(function()
    whitelist = loadstring(game:HttpGet(whitelistUrl))()
end)

if not success then
    warn("[WHITELIST ERROR] Failed to load: " .. tostring(error))
    plr:Kick("Failed to connect to server.")
    return
end

if not whitelist or type(whitelist) ~= "table" then
    warn("[WHITELIST ERROR] Invalid whitelist format")
    plr:Kick("Invalid server response.")
    return
end

if not whitelist[plr.Name] then
    plr:Kick("You are not whitelisted.")
    return
end

print("[WHITELIST] ✓ " .. plr.Name .. " authenticated successfully")
-- ==================== INICIO LIMPIO (SIN BLOQUEOS) ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

print("[NOAH HUB] 🚀 Starting Noah Hub...")

-- ==================== CONFIGURACIONES GLOBALES ====================
getgenv().MainTabConfig = getgenv().MainTabConfig or {
    AutoSkip = false,
    AutoSpeed2x = false,
    AutoSpeed3x = false,
    AutoPlayAgain = false,
    AutoReturn = false,
    AutoDifficulty = false,
    AutoJoinMap = false,
    SelectedDifficulty = nil,
    SelectedDifficultyName = nil,
    SelectedMap = nil,
    SelectedMapName = nil
}

getgenv().AntiBanConfig = getgenv().AntiBanConfig or {
    PlacementOffset = 1.5,
    MatchesBeforeReturn = 100,
    AutoReturnEnabled = false,
    AntiAFKEnabled = false,
    AntiAFKLoaded = false
}

getgenv().AutoFarmConfig = getgenv().AutoFarmConfig or {
    GraveyardV1Active = false,
    GraveyardV2Active = false,
    DojoActive = false,
    AutoWinV1Active = false,
    AutoWinV2Active = false, 
    CurrentStrategy = nil,
    IsRunning = false,
    MatchesPlayed = 0,
    MyUnitIDs = {},
    TrackingEnabled = false,
    CurrentWave = 0,
    UpgradeLoopRunning = false,
    FirstRunComplete = false
}

-- ==================== CARGAR WEBHOOK CONFIG GUARDADA ====================
local function loadWebhookConfig()
    local configPath = "NoahScriptHub/WebhookConfig.json"
    
    if not isfolder("NoahScriptHub") then
        makefolder("NoahScriptHub")
    end
    
    if isfile(configPath) then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(configPath))
        end)
        
        if success and data then
            print("[WEBHOOK] Loaded saved config: " .. (data.URL ~= "" and "URL configured" or "No URL"))
            -- ✅ Si hay URL guardada, activar automáticamente
            if data.URL ~= "" then
                data.Enabled = true
                print("[WEBHOOK] Auto-enabled because URL is configured")
            end
            return data
        end
    end
    
    return {
        URL = "",
        Enabled = false,
        GamesPlayed = 0,
        IsTracking = false
    }
end

local function saveWebhookConfig()
    local configPath = "NoahScriptHub/WebhookConfig.json"
    
    pcall(function()
        local data = {
            URL = getgenv().WebhookConfig.URL,
            Enabled = getgenv().WebhookConfig.Enabled,
            GamesPlayed = getgenv().WebhookConfig.GamesPlayed
        }
        
        local jsonData = game:GetService("HttpService"):JSONEncode(data)
        writefile(configPath, jsonData)
        print("[WEBHOOK] Config saved")
    end)
end

getgenv().WebhookConfig = getgenv().WebhookConfig or loadWebhookConfig()

-- ==================== CARGAR WINDUI ====================
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Noah Hub",
    Icon = "rbxassetid://107309769795150",
    Author = "by Threldor",
    Folder = "NoahScriptHub",
    
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    
    User = {
        Enabled = true,
        Anonymous = true,
    },
    
    KeySystem = { 
        Key = { "1234", "5678" },
        SaveKey = true,
    },

    OpenButton = {
        Title = "",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        
        Color = ColorSequence.new(
            Color3.fromHex("#6A4EC1"), 
            Color3.fromHex("#150F26")
        )
    }
})

getgenv().NoahHubWindow = Window
getgenv().NoahHubLoaded = true

Window:SetToggleKey(Enum.KeyCode.LeftShift)

print("[NOAH HUB] Press Left Shift to toggle UI visibility")
print("[NOAH HUB] Script ready! Close UI with X button to unlock for re-execution")

-- ==================== FUNCIÓN PARA DETECTAR MAPA ====================
local function getCurrentMap()
    local success, result = pcall(function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local remoteFunctions = replicatedStorage:FindFirstChild("RemoteFunctions")
        
        if not remoteFunctions then
            return "map_lobby"
        end
        
        local lobbySetMap = remoteFunctions:FindFirstChild("LobbySetMap_9")
        local lobbySetMaxPlayers = remoteFunctions:FindFirstChild("LobbySetMaxPlayers_9")
        
        if lobbySetMap or lobbySetMaxPlayers then
            return "map_lobby"
        end
        
        return "in_map"
    end)
    
    return success and result or "map_lobby"
end

-- ==================== CREAR TODOS LOS TABS ====================
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "target",
})

local AutoFarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "swords",
})

local SummonTab = Window:Tab({
    Title = "Summon",
    Icon = "sprout",
})

local AntiBanTab = Window:Tab({
    Title = "Anti Ban",
    Icon = "shield-check",
})

local WebhookTab = Window:Tab({
    Title = "Webhook",
    Icon = "bell-dot",
})

local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

print("[NOAH HUB] All tabs created")

-- ==================== CARGAR ANTI-AFK SOLO EN MAPAS ====================
-- El Anti-AFK se cargará automáticamente cuando se active un farm en un mapa

-- ==================== FUNCIONES DE WEBHOOK (COMPLETAS) ====================
local HttpService = game:GetService("HttpService")

local function getSeedsFromScreen()
    local success, result = pcall(function()
        local gui = PlayerGui:FindFirstChild("GameGui")
        if not gui then return "N/A" end
        
        local seedsDisplay = gui:FindFirstChild("SeedsDisplay", true)
        
        if seedsDisplay then
            local titleLabel = seedsDisplay:FindFirstChild("Title")
            if titleLabel and titleLabel:IsA("TextLabel") then
                local num = titleLabel.Text:match("(%d+)")
                if num then return num end
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
    
    return success and result or "N/A"
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
                if num then return num end
            end
        end
        
        return "N/A"
    end)
    
    return success and result or "N/A"
end

local function getGameResult(endFrame)
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local txt = obj.Text
            local txtLower = txt:lower()
            
            if txtLower:find("overwhelmed") or txtLower:find("defeated") or txtLower:find("game over") then
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
                    transparency = obj.TextTransparency,
                    size = obj.TextSize,
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

local function getRunTime(endFrame)
    local runTime = "N/A"
    
    local items = endFrame:FindFirstChild("Items", true)
    if items then
        local txtLabel = items:FindFirstChild("txt")
        if txtLabel and txtLabel:IsA("TextLabel") then
            local fullText = txtLabel.Text
            
            local timeMatch = fullText:match("Run time[:%s]*(%d+:%d+)")
            if timeMatch then
                return timeMatch
            end
            
            local secsMatch = fullText:match("Run time[:%s]*(%d+)%s*$")
            if secsMatch then
                local secs = tonumber(secsMatch)
                if secs then
                    return "0:" .. string.format("%02d", secs)
                end
            end
        end
    end
    
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local txt = obj.Text
            local txtLower = txt:lower()
            
            if txtLower:find("run time") then
                local timeMatch = txt:match("(%d+:%d+)")
                if timeMatch then
                    return timeMatch
                end
                
                local secsMatch = txt:match("run time[:%s]*(%d+)%s*$")
                if secsMatch then
                    local secs = tonumber(secsMatch)
                    if secs and secs < 3600 then
                        return "0:" .. string.format("%02d", secs)
                    end
                end
            end
        end
    end
    
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local txt = obj.Text
            
            local numOnly = txt:match("^%s*(%d+)%s*$")
            if numOnly then
                local secs = tonumber(numOnly)
                if secs and secs > 0 and secs < 600 then
                    if obj.Name:lower():find("time") or obj.Name:lower():find("txt") then
                        return "0:" .. string.format("%02d", secs)
                    end
                end
            end
            
            local timeMatch = txt:match("(%d+:%d+)")
            if timeMatch then
                return timeMatch
            end
        end
    end
    
    return runTime
end

local function sendWebhook(endFrame, isTest)
    if getgenv().WebhookConfig.URL == "" or not getgenv().WebhookConfig.URL then
        WindUI:Notify({
            Title = "Webhook Error",
            Content = "Please enter a Webhook URL first!",
            Duration = 3
        })
        return false
    end
    
    local success, err = pcall(function()
        if not isTest then
            getgenv().WebhookConfig.GamesPlayed = getgenv().WebhookConfig.GamesPlayed + 1
        end
        
        local time = os.date("%Y-%m-%d %H:%M:%S")
        local seeds = getSeedsFromScreen()
        local candy = getCandyCornFromScreen()
        
        local result = "Test Webhook"
        local runTime = "N/A"
        
        if not isTest and endFrame then
            result = getGameResult(endFrame)
            runTime = getRunTime(endFrame)
        end
        
        local color = result == "Victory" and 3066993 or (result == "Test Webhook" and 16776960 or 15158332)
        
        local userName = "||" .. LocalPlayer.Name .. "||"
        
        local description
        if isTest then
            description = string.format(
                "**Test Webhook**\n\n" ..
                "**User:** %s\n\n" ..
                "**Matches Played:** %d\n\n" ..
                "**Stats**\n" ..
                "🌱 Seeds: %s\n" ..
                "🍬 Candy: %s\n\n" ..
                "**Match Results**\n" ..
                "%s\n" ..
                "⏱️ Run Time: %s",
                userName,
                getgenv().WebhookConfig.GamesPlayed,
                seeds,
                candy,
                result,
                runTime
            )
        else
            description = string.format(
                "**Garden Tower Defense**\n\n" ..
                "**User:** %s\n\n" ..
                "**Matches Played:** %d\n\n" ..
                "**Stats**\n" ..
                "🌱 Seeds: %s\n" ..
                "🍬 Candy: %s\n\n" ..
                "**Match Results**\n" ..
                "%s\n" ..
                "⏱️ Run Time: %s",
                userName,
                getgenv().WebhookConfig.GamesPlayed,
                seeds,
                candy,
                result,
                runTime
            )
        end
        
        local data = {
            embeds = {{
                color = color,
                description = description,
                footer = {text = "Noah Hub | " .. time}
            }}
        }
        
        local jsonData = HttpService:JSONEncode(data)
        
        local response = request({
            Url = getgenv().WebhookConfig.URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
        
        if isTest then
            print("[WEBHOOK TEST] Sent successfully!")
        else
            print("[WEBHOOK] Sent! Result: " .. result .. " | Seeds: " .. seeds .. " | Candy: " .. candy)
        end
    end)
    
    if not success then
        warn("[WEBHOOK ERROR] " .. tostring(err))
        WindUI:Notify({
            Title = "Webhook Error",
            Content = "Failed to send webhook. Check console for details.",
            Duration = 3
        })
        return false
    end
    
    return true
end

local function startWebhookTracking()
    task.spawn(function()
        while task.wait(1) do
            if getgenv().WebhookConfig.Enabled then
                pcall(function()
                    local gui = PlayerGui:FindFirstChild("GameGui")
                    if gui and not getgenv().WebhookConfig.IsTracking then
                        local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                        if endFrame and not endFrame.Visible then
                            getgenv().WebhookConfig.IsTracking = true
                            
                            repeat task.wait(0.3) until endFrame.Visible
                            task.wait(1)
                            
                            sendWebhook(endFrame, false)
                            
                            task.wait(2)
                            getgenv().WebhookConfig.IsTracking = false
                        end
                    end
                end)
            end
        end
    end)
end

startWebhookTracking()
print("[WEBHOOK] System initialized. Games Played: " .. getgenv().WebhookConfig.GamesPlayed)

-- ==================== VARIABLES GLOBALES PARA TOGGLES ====================
getgenv().MainTabToggles = getgenv().MainTabToggles or {
    AutoSkip = nil,
    AutoSpeed2x = nil,
    AutoSpeed3x = nil,
    AutoPlayAgain = nil,
    AutoDifficulty = nil,
    AutoJoinMap = nil
}

getgenv().AntiBanToggles = getgenv().AntiBanToggles or {
    AntiAFK = nil
}

-- ==================== CARGAR CONTENIDO DEL MAIN TAB ====================
task.spawn(function()
    print("[MAIN TAB] Loading content...")
    
    local AutoSpeed2xToggle
    local AutoSpeed3xToggle
    local AutoSkipToggle
    local AutoPlayAgainToggle
    local AutoDifficultyToggle
    local AutoJoinMapToggle
    
    MainTab:Section({
        Title = "Auto Play",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    
    MainTab:Space()
    
    AutoSkipToggle = MainTab:Toggle({
        Flag = "AutoSkip",
        Title = "Auto Skip",
        Default = getgenv().MainTabConfig.AutoSkip,
        Callback = function(state)
            getgenv().MainTabConfig.AutoSkip = state
        
            
            if state then
                task.spawn(function()
                    while getgenv().MainTabConfig.AutoSkip do
                        pcall(function()
                            local gui = PlayerGui:FindFirstChild("GameGuiNoInset")
                            if gui then
                                local autoSkipButton = gui.Screen.Top.WaveControls:FindFirstChild("AutoSkip")
                                if autoSkipButton then
                                    local c = autoSkipButton.ImageColor3
                                    if c.R > 0.8 and c.G > 0.5 then
                                        local conns = getconnections(autoSkipButton.MouseButton1Click)
                                        if conns and #conns > 0 then 
                                            conns[1]:Fire()
                                        end
                                    end
                                end
                            end
                        end)
                        task.wait(0.5)
                    end
                end)
            end
        end
    })
    
    getgenv().MainTabToggles.AutoSkip = AutoSkipToggle
    
    MainTab:Space()
    
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                local gui = PlayerGui:FindFirstChild("GameGuiNoInset")
                if gui then
                    local speedButton = gui.Screen.Top.WaveControls:FindFirstChild("TickSpeed")
                    if speedButton then
                        local speedText = speedButton:FindFirstChild("Speed")
                        if speedText and speedText:IsA("TextLabel") then
                            local currentSpeed = tonumber(string.match(speedText.Text, "%d+"))
                            
                            if currentSpeed then
                                if currentSpeed == 2 then
                                    if not getgenv().MainTabConfig.AutoSpeed2x then
                                        getgenv().MainTabConfig.AutoSpeed2x = true
                                        if AutoSpeed2xToggle then
                                            AutoSpeed2xToggle:Set(true)
                                        end
                                    end
                                    if getgenv().MainTabConfig.AutoSpeed3x then
                                        getgenv().MainTabConfig.AutoSpeed3x = false
                                        if AutoSpeed3xToggle then
                                            AutoSpeed3xToggle:Set(false)
                                        end
                                    end
                                elseif currentSpeed == 3 then
                                    if not getgenv().MainTabConfig.AutoSpeed3x then
                                        getgenv().MainTabConfig.AutoSpeed3x = true
                                        if AutoSpeed3xToggle then
                                            AutoSpeed3xToggle:Set(true)
                                        end
                                    end
                                    if getgenv().MainTabConfig.AutoSpeed2x then
                                        getgenv().MainTabConfig.AutoSpeed2x = false
                                        if AutoSpeed2xToggle then
                                            AutoSpeed2xToggle:Set(false)
                                        end
                                    end
                                elseif currentSpeed == 1 then
                                    if getgenv().MainTabConfig.AutoSpeed2x then
                                        getgenv().MainTabConfig.AutoSpeed2x = false
                                        if AutoSpeed2xToggle then
                                            AutoSpeed2xToggle:Set(false)
                                        end
                                    end
                                    if getgenv().MainTabConfig.AutoSpeed3x then
                                        getgenv().MainTabConfig.AutoSpeed3x = false
                                        if AutoSpeed3xToggle then
                                            AutoSpeed3xToggle:Set(false)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    AutoSpeed2xToggle = MainTab:Toggle({
    Flag = "AutoSpeed2x",
    Title = "Auto x2 Speed",
    Default = getgenv().MainTabConfig.AutoSpeed2x,
    Callback = function(state)
        -- ✅ VERIFICAR SI ESTÁ EN MAPA
        local currentMap = getCurrentMap()
        
        if state and currentMap == "map_lobby" then
            WindUI:Notify({
                Title = "Cannot Use in Lobby",
                Content = "Auto Speed only works inside maps!",
                Duration = 3
            })
            
            task.spawn(function()
                task.wait(0.1)
                AutoSpeed2xToggle:Set(false)
            end)
            return
        end
        
        getgenv().MainTabConfig.AutoSpeed2x = state
        
        if state then
            if getgenv().MainTabConfig.AutoSpeed3x then
                getgenv().MainTabConfig.AutoSpeed3x = false
                if AutoSpeed3xToggle then
                    AutoSpeed3xToggle:Set(false)
                end
            end
            
            pcall(function()
                local args = { 2 }
                game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("ChangeTickSpeed"):InvokeServer(unpack(args))
            end)
        end
    end
})
    
    getgenv().MainTabToggles.AutoSpeed2x = AutoSpeed2xToggle
    
    MainTab:Space()
    
    AutoSpeed3xToggle = MainTab:Toggle({
    Flag = "AutoSpeed3x",
    Title = "Auto x3 Speed",
    Default = getgenv().MainTabConfig.AutoSpeed3x,
    Callback = function(state)
        -- ✅ VERIFICAR SI ESTÁ EN MAPA
        local currentMap = getCurrentMap()
        
        if state and currentMap == "map_lobby" then
            WindUI:Notify({
                Title = "Cannot Use in Lobby",
                Content = "Auto Speed only works inside maps!",
                Duration = 3
            })
            
            task.spawn(function()
                task.wait(0.1)
                AutoSpeed3xToggle:Set(false)
            end)
            return
        end
        
        getgenv().MainTabConfig.AutoSpeed3x = state
        
        if state then
            if getgenv().MainTabConfig.AutoSpeed2x then
                getgenv().MainTabConfig.AutoSpeed2x = false
                if AutoSpeed2xToggle then
                    AutoSpeed2xToggle:Set(false)
                end
            end
            
            pcall(function()
                local args = { 3 }
                game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("ChangeTickSpeed"):InvokeServer(unpack(args))
            end)
        end
    end
})
    
    getgenv().MainTabToggles.AutoSpeed3x = AutoSpeed3xToggle
    
    MainTab:Space()
    
    AutoPlayAgainToggle = MainTab:Toggle({
        Flag = "AutoPlayAgain",
        Title = "Auto Play Again",
        Default = getgenv().MainTabConfig.AutoPlayAgain,
        Callback = function(state)
            -- ✅ VERIFICAR SI ESTÁ EN MAPA
            local currentMap = getCurrentMap()
            
            if state and currentMap == "map_lobby" then
                WindUI:Notify({
                    Title = "Cannot Use in Lobby",
                    Content = "Auto Play Again only works inside maps!",
                    Duration = 3
                })
                
                task.spawn(function()
                    task.wait(0.1)
                    AutoPlayAgainToggle:Set(false)
                end)
                return
            end
            
            getgenv().MainTabConfig.AutoPlayAgain = state
            
            if state then
                task.spawn(function()
                    while getgenv().MainTabConfig.AutoPlayAgain do
                        pcall(function()
                            local gui = PlayerGui:FindFirstChild("GameGui")
                            if gui then
                                local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                                if endFrame and endFrame.Visible then
                                    task.wait(2)
                                    
                                    local clicked = false
                                    for attempt = 1, 10 do
                                        pcall(function()
                                            for _, button in ipairs(gui:GetDescendants()) do
                                                if button:IsA("TextButton") and button.Visible then
                                                    local text = string.lower(button.Text)
                                                    if string.find(text, "again") or string.find(text, "play") then
                                                        local conns = getconnections(button.MouseButton1Click)
                                                        if conns and #conns > 0 then
                                                            conns[1]:Fire()
                                                            clicked = true
                                                            return
                                                        end
                                                    end
                                                end
                                            end
                                        end)
                                        if clicked then break end
                                        task.wait(0.15)
                                    end
                                    
                                    if not clicked then
                                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("RestartGame"):InvokeServer()
                                    end
                                    
                                    task.wait(5)
                                end
                            end
                        end)
                        task.wait(1)
                    end
                end)
            end
        end
    })
    
    getgenv().MainTabToggles.AutoPlayAgain = AutoPlayAgainToggle
    
    MainTab:Space()
    
    MainTab:Toggle({
        Flag = "AutoReturn",
        Title = "Auto Return",
        Default = getgenv().MainTabConfig.AutoReturn,
        Callback = function(state)
            getgenv().MainTabConfig.AutoReturn = state
        end
    })
    
    MainTab:Space({ Columns = 2 })
    
    MainTab:Section({
        Title = "Auto Select Difficulty",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    
    MainTab:Space()
    
    local DifficultyMapping = {
        ["Easy"] = "dif_easy",
        ["Normal"] = "dif_normal",
        ["Hard"] = "dif_hard",
        ["Insane"] = "dif_insane",
        ["Impossible"] = "dif_impossible",
        ["Apocalypse"] = "dif_apocalypse"
    }
    
    local DifficultyDropdown = MainTab:Dropdown({
        Flag = "SelectedDifficulty",
        Title = "Difficulty",
        Values = {
            { Title = "Easy" },
            { Title = "Normal" },
            { Title = "Hard" },
            { Title = "Insane" },
            { Title = "Impossible" },
            { Title = "Apocalypse" }
        },
        Callback = function(option)
            getgenv().MainTabConfig.SelectedDifficultyName = option.Title
            getgenv().MainTabConfig.SelectedDifficulty = DifficultyMapping[option.Title]
            DifficultyDropdown:Highlight()
        end
    })
    
    MainTab:Space()
    
    local hasVotedThisLoop = false
    
    task.spawn(function()
        local lastGameEndState = false
        
        while task.wait(0.5) do
            pcall(function()
                local gui = PlayerGui:FindFirstChild("GameGui")
                if gui then
                    local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                    
                    if endFrame then
                        local currentState = endFrame.Visible
                        
                        if lastGameEndState == true and currentState == false then
                            hasVotedThisLoop = false
                        end
                        
                        lastGameEndState = currentState
                    end
                end
            end)
        end
    end)
    
    AutoDifficultyToggle = MainTab:Toggle({
        Flag = "AutoDifficulty",
        Title = "Auto Difficulty",
        Default = getgenv().MainTabConfig.AutoDifficulty,
        Callback = function(state)
            -- ✅ VERIFICAR SI ESTÁ EN MAPA
            local currentMap = getCurrentMap()
            
            if state and currentMap == "map_lobby" then
                WindUI:Notify({
                    Title = "Cannot Use in Lobby",
                    Content = "Auto Difficulty only works inside maps!",
                    Duration = 3
                })
                
                task.spawn(function()
                    task.wait(0.1)
                    AutoDifficultyToggle:Set(false)
                end)
                return
            end
            
            getgenv().MainTabConfig.AutoDifficulty = state
            
            if state then
                if not getgenv().MainTabConfig.SelectedDifficulty then
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Please select a difficulty first!",
                        Duration = 3
                    })
                    AutoDifficultyToggle:Set(false)
                    return
                end
                
                hasVotedThisLoop = false
                
                task.spawn(function()
                    while getgenv().MainTabConfig.AutoDifficulty do
                        pcall(function()
                            if not hasVotedThisLoop and getgenv().MainTabConfig.SelectedDifficulty then
                                local success = pcall(function()
                                    local args = { getgenv().MainTabConfig.SelectedDifficulty }
                                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(unpack(args))
                                end)
                                
                                if success then
                                    hasVotedThisLoop = true
                                end
                            end
                        end)
                        task.wait(1)
                    end
                end)
            else
                hasVotedThisLoop = false
            end
        end
    })
    
    getgenv().MainTabToggles.AutoDifficulty = AutoDifficultyToggle
    
    MainTab:Space({ Columns = 2 })
    
    MainTab:Section({
        Title = "Auto Select Map",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    
    MainTab:Space()
    
    local MapMapping = {
        ["Garden"] = "map_farm",
        ["Jungle"] = "map_jungle",
        ["Tropical Island"] = "map_island",
        ["Toxic Facility"] = "map_toxic",
        ["Back Garden"] = "map_back_garden",
        ["Dojo"] = "map_dojo",
        ["Graveyard"] = "map_graveyard"
    }
    
    local MapConfig = {
        ["map_farm"] = {
            teleport = CFrame.new(121.05, 67.74, 779.65),
            remote = "LobbySetMaxPlayers_9"
        },
        ["map_jungle"] = {
            teleport = CFrame.new(121.05, 67.74, 779.65),
            remote = "LobbySetMaxPlayers_9"
        },
        ["map_island"] = {
            teleport = CFrame.new(121.05, 67.74, 779.65),
            remote = "LobbySetMaxPlayers_9"
        },
        ["map_toxic"] = {
            teleport = CFrame.new(121.05, 67.74, 779.65),
            remote = "LobbySetMaxPlayers_9"
        },
        ["map_back_garden"] = {
            teleport = CFrame.new(121.05, 67.74, 779.65),
            remote = "LobbySetMaxPlayers_9"
        },
        ["map_dojo"] = {
            teleport = CFrame.new(121.05, 67.74, 779.65),
            remote = "LobbySetMaxPlayers_9"
        },
        ["map_graveyard"] = {
            teleport = CFrame.new(121.05, 67.74, 779.65),
            remote = "LobbySetMaxPlayers_9"
        }
    }
    
    local MapDropdown = MainTab:Dropdown({
        Flag = "SelectedMap",
        Title = "Map",
        Values = {
            { Title = "Garden" },
            { Title = "Jungle" },
            { Title = "Tropical Island" },
            { Title = "Toxic Facility" },
            { Title = "Back Garden" },
            { Title = "Dojo" },
            { Title = "Graveyard" }
        },
        Callback = function(option)
            getgenv().MainTabConfig.SelectedMapName = option.Title
            getgenv().MainTabConfig.SelectedMap = MapMapping[option.Title]
            MapDropdown:Highlight()
        end
    })
    
    MainTab:Space()
    
    AutoJoinMapToggle = MainTab:Toggle({
        Flag = "AutoJoinMap",
        Title = "Auto Join Map",
        Default = getgenv().MainTabConfig.AutoJoinMap,
        Callback = function(state)
            if state then
                if not getgenv().MainTabConfig.SelectedMap then
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Please select a map first!",
                        Duration = 3
                    })
                    
                    task.spawn(function()
                        task.wait(0.1)
                        getgenv().MainTabConfig.AutoJoinMap = false
                        if AutoJoinMapToggle then
                            AutoJoinMapToggle:Set(false)
                        end
                    end)
                    return
                end
                
                local currentMap = getCurrentMap()
                
                if currentMap == "in_map" then
                    WindUI:Notify({
                        Title = "Cannot Use in Map",
                        Content = "Auto Join Map only works in the Lobby!\nPlease return to lobby first.",
                        Duration = 5
                    })
                    
                    task.spawn(function()
                        task.wait(0.1)
                        getgenv().MainTabConfig.AutoJoinMap = false
                        if AutoJoinMapToggle then
                            AutoJoinMapToggle:Set(false)
                        end
                    end)
                    
                    return
                end
                
                local mapConfig = MapConfig[getgenv().MainTabConfig.SelectedMap]
                
                if not mapConfig then
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Map configuration not found!",
                        Duration = 3
                    })
                    
                    task.spawn(function()
                        task.wait(0.1)
                        getgenv().MainTabConfig.AutoJoinMap = false
                        if AutoJoinMapToggle then
                            AutoJoinMapToggle:Set(false)
                        end
                    end)
                    return
                end
                
                local success, err = pcall(function()
                    local Character = LocalPlayer.Character
                    if Character then
                        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                        if HumanoidRootPart then
                            HumanoidRootPart.CFrame = mapConfig.teleport
                            task.wait(0.5)
                        end
                    end
                    
                    local args = { 1 }
                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild(mapConfig.remote):InvokeServer(unpack(args))
                    task.wait(0.15)
                    
                    local args = { getgenv().MainTabConfig.SelectedMap }
                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMap_9"):InvokeServer(unpack(args))
                end)
                
                if success then
                    WindUI:Notify({
                        Title = "Auto Join Map",
                        Content = "Successfully joined: " .. getgenv().MainTabConfig.SelectedMapName,
                        Duration = 3
                    })
                else
                    warn("[AUTO JOIN MAP ERROR] " .. tostring(err))
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Failed to join map. Check console for details.",
                        Duration = 3
                    })
                end
                
                task.spawn(function()
                    task.wait(1)
                    getgenv().MainTabConfig.AutoJoinMap = false
                    if AutoJoinMapToggle then
                        AutoJoinMapToggle:Set(false)
                    end
                end)
            else
                getgenv().MainTabConfig.AutoJoinMap = false
            end
        end
    })
    
    print("[MAIN TAB] Content loaded successfully!")
end)

-- ==================== AUTO FARM FUNCTIONS ====================
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== SISTEMA DE TRACKING GLOBAL MEJORADO =====
getgenv().GlobalTracking = getgenv().GlobalTracking or {
    enabled = false,
    connection = nil,
    unitIDs = {}
}

local function getUnitID(unit)
    for attempt = 1, 10 do
        for _, v in ipairs(unit:GetDescendants()) do
            if (v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue")) and string.find(string.lower(v.Name), "id") then
                return v.Value
            end
        end
        for attrName, attrValue in pairs(unit:GetAttributes()) do
            if string.find(string.lower(attrName), "id") then
                return attrValue
            end
        end
        task.wait(0.2)
    end
    return nil
end

local function startGlobalTracking()
    if getgenv().GlobalTracking.connection then
        -- Ya existe un tracker activo
        return
    end
    
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then
        warn("[GLOBAL TRACKING] Map not found!")
        return
    end
    
    local entities = mapFolder:FindFirstChild("Entities")
    if not entities then
        warn("[GLOBAL TRACKING] Entities not found!")
        return
    end
    
    getgenv().GlobalTracking.enabled = true
    getgenv().GlobalTracking.unitIDs = {}
    
    getgenv().GlobalTracking.connection = entities.ChildAdded:Connect(function(child)
        if getgenv().GlobalTracking.enabled then
            task.spawn(function()
                task.wait(1)
                if child and child.Parent and string.find(child.Name, "unit_") then
                    local unitID = getUnitID(child)
                    if unitID then
                        table.insert(getgenv().GlobalTracking.unitIDs, unitID)
                        print("[GLOBAL TRACKING] Tracked unit ID: " .. tostring(unitID))
                    end
                end
            end)
        end
    end)
    
    print("[GLOBAL TRACKING] ✅ Started successfully")
end

local function resetGlobalTracking()
    getgenv().GlobalTracking.unitIDs = {}
    print("[GLOBAL TRACKING] 🔄 IDs reset for new game")
end

local function stopGlobalTracking()
    getgenv().GlobalTracking.enabled = false
    if getgenv().GlobalTracking.connection then
        getgenv().GlobalTracking.connection:Disconnect()
        getgenv().GlobalTracking.connection = nil
    end
    getgenv().GlobalTracking.unitIDs = {}
    print("[GLOBAL TRACKING] ⛔ Stopped and cleaned")
end

local function getMoney()
    return LocalPlayer:GetAttribute("Cash") or 0
end

local function placeUnit(unitName, cframe, rotation)
    local offset = getgenv().AntiBanConfig.PlacementOffset or 1.5
    
    local randomX = (math.random() - 0.5) * 2 * offset
    local randomZ = (math.random() - 0.5) * 2 * offset
    
    local adjustedCFrame = cframe * CFrame.new(randomX, 0, randomZ)
    
    local args = {
        unitName,
        {
            CF = adjustedCFrame,
            Rotation = rotation,
            Valid = true,
            Position = adjustedCFrame.Position
        }
    }
    
    local success, result = pcall(function()
        return ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("PlaceUnit"):InvokeServer(unpack(args))
    end)
    
    return success and result
end

local function upgradeUnit(unitModel)
    if not unitModel then return false end
    
    local success = pcall(function()
        local args = { unitModel }
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(unpack(args))
    end)
    
    return success
end

local function sellUnit(unitModel)
    if not unitModel then return false end
    
    local success = pcall(function()
        local args = { unitModel }
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("SellUnit"):InvokeServer(unpack(args))
    end)
    
    return success
end

local function waitForMoney(amount, timeout)
    local startTime = tick()
    timeout = timeout or 30
    
    while getMoney() < amount do
        if tick() - startTime > timeout then
            return false
        end
        task.wait(0.2)
    end
    
    return true
end

local function getPlacedUnits()
    local units = {}
    local success = pcall(function()
        local mapEntities = Workspace:FindFirstChild("Map")
        if mapEntities then
            local entities = mapEntities:FindFirstChild("Entities")
            if entities then
                for _, entity in pairs(entities:GetChildren()) do
                    if entity:IsA("Model") then
                        local owner = entity:GetAttribute("Owner")
                        if owner == LocalPlayer.UserId then
                            table.insert(units, entity)
                        end
                    end
                end
            end
        end
    end)
    return units
end

local function getUnitByIndex(index)
    local units = getPlacedUnits()
    return units[index]
end

local function upgradeUnitToLevel(unitModel, targetLevel, unitCosts)
    if not unitModel then 
        warn("[UPGRADE] Unit model is nil")
        return false
    end
    
    local currentLevel = unitModel:GetAttribute("Level") or 1
    
    while currentLevel < targetLevel do
        local upgradeCost = unitCosts[currentLevel + 1]
        
        if not upgradeCost then
            warn("[UPGRADE] No cost defined for level " .. (currentLevel + 1))
            return false
        end
        
        if not waitForMoney(upgradeCost, 30) then
            warn("[UPGRADE] Timeout waiting for $" .. upgradeCost)
            return false
        end
        
        if upgradeUnit(unitModel) then
            task.wait(0.2)
            currentLevel = unitModel:GetAttribute("Level") or currentLevel
        else
            warn("[UPGRADE] Failed to upgrade to level " .. (currentLevel + 1))
            return false
        end
        
        task.wait(math.random(15, 35) / 100)
    end
    
    return true
end

-- ==================== GRAVEYARD V1: RAINBOW TOMATO & EARTH DRAGON (CORREGIDO) ====================
local function runGraveyardV1()
    print("[GRAVEYARD V1] Starting Rainbow Tomato & Earth Dragon strategy...")
    
    -- ✅ USAR TRACKING GLOBAL
    local myUnitIDs = getgenv().GlobalTracking.unitIDs
    
    -- ===== COORDENADAS EXACTAS =====
    local rainbowPositions = {
        {cframe = CFrame.new(-344.7191162109375, 61.680301666259766, -702.30859375, -1, 0, -8.74e-08, 0, 1, 0, 8.74e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-351.1462097167969, 61.68030548095703, -711.151123046875, -1, 0, -8.74e-08, 0, 1, 0, 8.74e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-334.91607666015625, 61.6803092956543, -721.29736328125, -1, 0, -8.74e-08, 0, 1, 0, 8.74e-08, 0, -1), rotation = 180}
    }
    
    local dragonPositions = {
        {cframe = CFrame.new(-319.2539978027344, 61.68030548095703, -720.3961181640625, -1, 0, -8.74e-08, 0, 1, 0, 8.74e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-331.4523620605469, 61.680301666259766, -735.6544799804688, -1, 0, -8.74e-08, 0, 1, 0, 8.74e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-319.48638916015625, 61.68030548095703, -734.1026000976562, -1, 0, -8.74e-08, 0, 1, 0, 8.74e-08, 0, -1), rotation = 180}
    }
    
    -- ===== PASO 1: PLANTAR RAINBOW TOMATO 1 =====
    print("[GRAVEYARD V1] Planting Rainbow Tomato 1...")
    while getMoney() < 100 do task.wait(0.2) end
    
    for attempt = 1, 5 do
        local placed = placeUnit("unit_tomato_rainbow", rainbowPositions[1].cframe, rainbowPositions[1].rotation)
        if placed then 
            print("[GRAVEYARD V1] ✓ Placed Rainbow Tomato 1")
            break 
        end
        task.wait(0.15)
    end
    task.wait(0.15)
    
    local waitTime = 0
    while #myUnitIDs < 1 and waitTime < 10 do
        task.wait(0.2)
        waitTime = waitTime + 0.2
    end
    
    if #myUnitIDs < 1 then
        warn("[GRAVEYARD V1] Failed to track Rainbow Tomato 1!")
        return false
    end
    
    local rb1ID = myUnitIDs[1]
    
    -- ===== UPGRADES RB1 → LVL 2 y 3 =====
    while getMoney() < 125 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb1ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    while getMoney() < 175 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb1ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 4: PLANTAR RAINBOW TOMATO 2 =====
    print("[GRAVEYARD V1] Planting Rainbow Tomato 2...")
    while getMoney() < 100 do task.wait(0.2) end
    
    for attempt = 1, 5 do
        local placed = placeUnit("unit_tomato_rainbow", rainbowPositions[2].cframe, rainbowPositions[2].rotation)
        if placed then 
            print("[GRAVEYARD V1] ✓ Placed Rainbow Tomato 2")
            break 
        end
        task.wait(0.15)
    end
    task.wait(0.15)
    
    waitTime = 0
    while #myUnitIDs < 2 and waitTime < 10 do
        task.wait(0.2)
        waitTime = waitTime + 0.2
    end
    
    if #myUnitIDs < 2 then
        warn("[GRAVEYARD V1] Failed to track Rainbow Tomato 2!")
        return false
    end
    
    local rb2ID = myUnitIDs[2]
    
    -- ===== UPGRADES RB2 → LVL 2, 3, 4, 5 =====
    while getMoney() < 125 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb2ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    while getMoney() < 175 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb2ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    while getMoney() < 350 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb2ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    while getMoney() < 500 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb2ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== UPGRADES RB1 → LVL 4, 5 =====
    while getMoney() < 350 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb1ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    while getMoney() < 500 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb1ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 11: PLANTAR RAINBOW TOMATO 3 =====
    print("[GRAVEYARD V1] Planting Rainbow Tomato 3...")
    while getMoney() < 100 do task.wait(0.2) end
    
    for attempt = 1, 5 do
        local placed = placeUnit("unit_tomato_rainbow", rainbowPositions[3].cframe, rainbowPositions[3].rotation)
        if placed then 
            print("[GRAVEYARD V1] ✓ Placed Rainbow Tomato 3")
            break 
        end
        task.wait(0.15)
    end
    task.wait(0.15)
    
    waitTime = 0
    while #myUnitIDs < 3 and waitTime < 10 do
        task.wait(0.2)
        waitTime = waitTime + 0.2
    end
    
    if #myUnitIDs < 3 then
        warn("[GRAVEYARD V1] Failed to track Rainbow Tomato 3!")
        return false
    end
    
    local rb3ID = myUnitIDs[3]
    
    -- ===== UPGRADES RB3 → LVL 2, 3, 4, 5 =====
    while getMoney() < 125 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb3ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    while getMoney() < 175 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb3ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    while getMoney() < 350 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb3ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    while getMoney() < 500 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb3ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    print("[GRAVEYARD V1] ========== ALL RAINBOW TOMATO UPGRADES COMPLETE - PLACING DRAGONS ==========")
    
    -- ===== PLANTAR 3 EARTH DRAGONS =====
    print("[GRAVEYARD V1] Placing Earth Dragon 1...")
    while getMoney() < 6000 do task.wait(0.2) end
    
    for attempt = 1, 5 do
        local placed = placeUnit("unit_golem_dragon", dragonPositions[1].cframe, dragonPositions[1].rotation)
        if placed then 
            print("[GRAVEYARD V1] ✓ Placed Earth Dragon 1")
            break 
        end
        task.wait(0.15)
    end
    task.wait(0.15)
    
    print("[GRAVEYARD V1] Placing Earth Dragon 2...")
    while getMoney() < 6000 do task.wait(0.2) end
    
    for attempt = 1, 5 do
        local placed = placeUnit("unit_golem_dragon", dragonPositions[2].cframe, dragonPositions[2].rotation)
        if placed then 
            print("[GRAVEYARD V1] ✓ Placed Earth Dragon 2")
            break 
        end
        task.wait(0.15)
    end
    task.wait(0.15)
    
    print("[GRAVEYARD V1] Placing Earth Dragon 3...")
    while getMoney() < 6000 do task.wait(0.2) end
    
    for attempt = 1, 5 do
        local placed = placeUnit("unit_golem_dragon", dragonPositions[3].cframe, dragonPositions[3].rotation)
        if placed then 
            print("[GRAVEYARD V1] ✓ Placed Earth Dragon 3")
            break 
        end
        task.wait(0.15)
    end
    task.wait(0.15)
    
    print("[GRAVEYARD V1] ========== ALL DRAGONS PLACED - WAITING FOR WAVE 20 ==========")
    
    -- ===== ESPERAR WAVE 20 =====
    local currentWave = 0
    local wave20Detected = false
    
    while not wave20Detected and getgenv().AutoFarmConfig.GraveyardV1Active do
        pcall(function()
            local gui = PlayerGui:FindFirstChild("GameGuiNoInset") or PlayerGui:FindFirstChild("GameGui")
            if gui then
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Visible and obj.Name == "Title" then
                        local waveNum = tonumber(string.match(obj.Text, "^Wave%s*(%d+)") or string.match(obj.Text, "Wave%s*(%d+)%s*/"))
                        
                        if waveNum and waveNum ~= currentWave then
                            currentWave = waveNum
                            if currentWave >= 20 then
                                print("[GRAVEYARD V1] ✓✓✓ WAVE 20 DETECTED! ✓✓✓")
                                wave20Detected = true
                                return
                            elseif currentWave % 5 == 0 and currentWave > 0 then
                                print("[GRAVEYARD V1] Current wave: " .. currentWave)
                            end
                        end
                    end
                end
            end
        end)
        
        if wave20Detected then break end
        task.wait(0.5)
    end
    
    if not getgenv().AutoFarmConfig.GraveyardV1Active then
        print("[GRAVEYARD V1] Farm stopped before Wave 20")
        return false
    end
    
    print("[GRAVEYARD V1] ========== WAVE 20 REACHED - SELLING ALL UNITS ==========")
    
    local randomDelay = 0.5 + (math.random() * 0.5)
    task.wait(randomDelay)
    
    -- Vender usando IDs trackeados
    if #myUnitIDs >= 6 then
        print("[GRAVEYARD V1] Selling all 6 units using tracked IDs...")
        for i = 1, 6 do
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("SellUnit"):InvokeServer(myUnitIDs[i])
                print("[GRAVEYARD V1] ✓ Sold unit " .. i)
            end)
            task.wait(0.05)
        end
    else
        -- Fallback
        print("[GRAVEYARD V1] Selling using numeric IDs (fallback)...")
        for unitID = 1, 6 do
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("SellUnit"):InvokeServer(unitID)
            end)
            task.wait(0.3)
        end
    end
    
    print("[GRAVEYARD V1] ========== ALL UNITS SOLD ==========")
    return true
end

-- ==================== GRAVEYARD V2: MULTIPLE UNITS STRATEGY ====================
local function runGraveyardV2()
    print("[GRAVEYARD V2] Starting Multi-Unit strategy...")
    
-- ✅ USAR TRACKING GLOBAL
    local myUnitIDs = getgenv().GlobalTracking.unitIDs
    
    local function plantWithRetry(unitName, position, unitDisplayName)
    for attempt = 1, 50 do
        -- ✅ USA SIEMPRE EL VALOR DEL ANTI-BAN TAB (sin sobreescribirlo)
        local placed = placeUnit(unitName, position.cframe, position.rotation)
        
        if placed then
            print("[GRAVEYARD V2] ✓ Planted " .. unitDisplayName .. " on attempt " .. attempt .. " (offset: " .. getgenv().AntiBanConfig.PlacementOffset .. " studs)")
            return true
        end
        
        task.wait(0.05)
    end
    
    warn("[GRAVEYARD V2] ❌ FAILED to plant " .. unitDisplayName .. " after 50 attempts!")
    return false
end
    
   local function upgradeToLevel(unitID, targetLevel, costs, unitName, startLevel)
    startLevel = startLevel or 1
    
    for level = (startLevel + 1), targetLevel do
        local costIndex = level - 1
        local cost = costs[costIndex]
        
        if not cost then
            warn("[GRAVEYARD V2] No cost for level " .. level .. " of " .. unitName)
            return false
        end
        
        print("[GRAVEYARD V2] Upgrading " .. unitName .. " to Level " .. level .. " (cost: $" .. cost .. ")...")
        while getMoney() < cost do task.wait(0.2) end
        pcall(function()
            ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(unitID)
        end)
        task.wait(0.1 + (math.random() * 0.21))  -- ✅ 30% más rápido (antes: 0.4-0.78, ahora: 0.1-0.31)
    end
    print("[GRAVEYARD V2] ✓ " .. unitName .. " upgraded to Level " .. targetLevel)
    return true
end
    
    local positions = {
        prismleaf1 = {cframe = CFrame.new(-343.09326171875, 61.68030548095703, -706.1312866210938, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        dragon1 = {cframe = CFrame.new(-325.69024658203125, 61.68030548095703, -719.0919799804688, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        dragon2 = {cframe = CFrame.new(-321.40118408203125, 61.6803092956543, -718.98583984375, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        dragon3 = {cframe = CFrame.new(-324.6614990234375, 61.68030548095703, -712.499755859375, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        witch1 = {cframe = CFrame.new(-330.850341796875, 61.680301666259766, -708.5601806640625, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        potato1 = {cframe = CFrame.new(-333.68597412109375, 61.6803092956543, -716.2599487304688, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        blackclover1 = {cframe = CFrame.new(-331.47357177734375, 61.6803092956543, -713.38330078125, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        rose1 = {cframe = CFrame.new(-340.619873046875, 61.68030548095703, -695.4280395507812, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        rose2 = {cframe = CFrame.new(-328.5089416503906, 61.68030548095703, -697.7555541992188, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        witch2 = {cframe = CFrame.new(-327.02313232421875, 61.6803092956543, -706.6849365234375, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        witch3 = {cframe = CFrame.new(-331.0621643066406, 61.68030548095703, -703.8416137695312, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        potato2 = {cframe = CFrame.new(-330.1884765625, 61.680301666259766, -719.8148193359375, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        potato3 = {cframe = CFrame.new(-335.74871826171875, 61.68030548095703, -719.666015625, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        corrupted1 = {cframe = CFrame.new(-336.26654052734375, 61.680301666259766, -712.6754760742188, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        corrupted2 = {cframe = CFrame.new(-340.38153076171875, 61.6803092956543, -718.155029296875, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        prismleaf2 = {cframe = CFrame.new(-345.2245178222656, 61.68030548095703, -709.4812622070312, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        prismleaf3 = {cframe = CFrame.new(-348.204345703125, 61.68030548095703, -712.9251098632812, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        prismleaf4 = {cframe = CFrame.new(-347.61895751953125, 61.6803092956543, -705.2569580078125, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        prismleaf5 = {cframe = CFrame.new(-350.3448791503906, 61.6803092956543, -708.4331665039062, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180}
    }
    
    local costs = {
        prismleaf = {300, 475, 800, 1100},
        blackclover = {3000, 4000, 7500, 15000},
        rose = {4000, 7000, 10000, 14000},
        potato = {6000, 9000, 14000, 40000},
        witch = {9000, 17000, 25000, 35000},
        dragon = {8000, 12500, 26000, 35000},
        corrupted = {9000, 15750, 32000, 53500}
    }
    
    -- Prismleaf 1 → Lvl 5
    while getMoney() < 225 do task.wait(0.2) end
    if not plantWithRetry("unit_glow_ray", positions.prismleaf1, "Prismleaf 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 1 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[1], 5, costs.prismleaf, "Prismleaf 1")
    
    -- 3 Dragons (sin upgrade)
    for i = 1, 3 do
        while getMoney() < 6000 do task.wait(0.2) end
        if not plantWithRetry("unit_golem_dragon", positions["dragon"..i], "Dragon " .. i) then
            return false
        end
        task.wait(0.15)
    end
    while #myUnitIDs < 4 do task.wait(0.2) end
    
    -- Witch 1 → Lvl 3
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_witch", positions.witch1, "Witch 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 5 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[5], 3, costs.witch, "Witch 1")
    
    -- Potato 1 → Lvl 5
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_punch_potato", positions.potato1, "Potato 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 6 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[6], 5, costs.potato, "Potato 1")
    
    -- Black Clover 1 → Lvl 5
    while getMoney() < 1500 do task.wait(0.2) end
    if not plantWithRetry("unit_black_clover", positions.blackclover1, "Black Clover 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 7 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[7], 5, costs.blackclover, "Black Clover 1")
    
    -- ✅ CORRECCIÓN: Witch 1 → Lvl 5 (ya está en level 3)
    upgradeToLevel(myUnitIDs[5], 5, costs.witch, "Witch 1", 3)
    
    -- Rose 1 → Lvl 5
    while getMoney() < 2000 do task.wait(0.2) end
    if not plantWithRetry("unit_pink_rose", positions.rose1, "Rose 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 8 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[8], 5, costs.rose, "Rose 1")
    
    -- Rose 2 → Lvl 5
    while getMoney() < 2000 do task.wait(0.2) end
    if not plantWithRetry("unit_pink_rose", positions.rose2, "Rose 2") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 9 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[9], 5, costs.rose, "Rose 2")
    
    -- Witch 2 → Lvl 5
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_witch", positions.witch2, "Witch 2") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 10 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[10], 5, costs.witch, "Witch 2")
    
    -- Witch 3 → Lvl 5
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_witch", positions.witch3, "Witch 3") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 11 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[11], 5, costs.witch, "Witch 3")
    
    -- Potato 2 → Lvl 5
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_punch_potato", positions.potato2, "Potato 2") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 12 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[12], 5, costs.potato, "Potato 2")
    
    -- Potato 3 → Lvl 5
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_punch_potato", positions.potato3, "Potato 3") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 13 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[13], 5, costs.potato, "Potato 3")
    
    -- Corrupted 1 → Lvl 5
    while getMoney() < 8666 do task.wait(0.2) end
    if not plantWithRetry("unit_eyeball", positions.corrupted1, "Corrupted 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 14 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[14], 5, costs.corrupted, "Corrupted 1")
    
    -- Corrupted 2 → Lvl 5
    while getMoney() < 8666 do task.wait(0.2) end
    if not plantWithRetry("unit_eyeball", positions.corrupted2, "Corrupted 2") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 15 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[15], 5, costs.corrupted, "Corrupted 2")
    
    -- Upgrade Dragons
    upgradeToLevel(myUnitIDs[2], 5, costs.dragon, "Dragon 1")
    upgradeToLevel(myUnitIDs[3], 5, costs.dragon, "Dragon 2")
    upgradeToLevel(myUnitIDs[4], 5, costs.dragon, "Dragon 3")
    
    -- Prismleafs 2-5
    for i = 2, 5 do
        while getMoney() < 225 do task.wait(0.2) end
        if not plantWithRetry("unit_glow_ray", positions["prismleaf"..i], "Prismleaf " .. i) then
            return false
        end
        task.wait(0.15)
        while #myUnitIDs < (15 + i - 1) do task.wait(0.2) end
        upgradeToLevel(myUnitIDs[15 + i - 1], 5, costs.prismleaf, "Prismleaf " .. i)
    end

  print("[GRAVEYARD V2] ========== COMPLETE ==========")
    return true
end

-- ==================== DOJO: VERSIÓN OPTIMIZADA ====================

local function getRandomPositionPath1()
    local minPos = Vector3.new(46.63258361816406, -21.75, -49.71086502075195)
    local maxPos = Vector3.new(52.49168014526367, -21.75, -55.56996154785156)
    local randomX = minPos.X + math.random() * (maxPos.X - minPos.X)
    local randomZ = minPos.Z + math.random() * (maxPos.Z - minPos.Z)
    local position = Vector3.new(randomX, -21.75, randomZ)
    return {
        Valid = true,
        PathIndex = 1,
        Position = position,
        CF = CFrame.new(position.X, position.Y, position.Z, 0.7071068286895752, 0, -0.7071067690849304, -0, 1, -0, 0.7071068286895752, 0, 0.7071067690849304),
        Rotation = 180
    }
end

local function getRandomPositionPath2()
    local minPos = Vector3.new(-54.49039077758789, -21.75, -53.30671691894531)
    local maxPos = Vector3.new(-42.14012908935547, -21.74989891052246, -40.86867141723633)
    local randomX = minPos.X + math.random() * (maxPos.X - minPos.X)
    local randomZ = minPos.Z + math.random() * (maxPos.Z - minPos.Z)
    local position = Vector3.new(randomX, -21.75, randomZ)
    return {
        Valid = true,
        PathIndex = 2,
        Position = position,
        CF = CFrame.new(position.X, position.Y, position.Z, 0.7071068286895752, 0, 0.7071067690849304, -0, 1, -0, -0.7071068286895752, 0, 0.7071067690849304),
        Rotation = 180
    }
end

local function plantRafflesiaWithRetry(pathFunction, rafflesiaName, maxAttempts)
    maxAttempts = maxAttempts or 10
    
    for attempt = 1, maxAttempts do
        -- ✅ GENERAR NUEVA POSICIÓN RANDOM EN CADA INTENTO
        local placementData = pathFunction()
        
        local success, result = pcall(function()
            return ReplicatedStorage:WaitForChild("RemoteFunctions")
                :WaitForChild("PlaceUnit")
                :InvokeServer("unit_rafflesia", placementData)
        end)
        
        -- ✅ VERIFICAR QUE PLANTÓ EXITOSAMENTE (success Y result)
        if success and result then
            print("[DOJO] ✓ Placed " .. rafflesiaName .. " on attempt " .. attempt)
            return true
        end
        
        -- ✅ SI FALLÓ, ESPERA Y REINTENTA CON NUEVA POSICIÓN
        task.wait(0.05)
    end
    
    warn("[DOJO] ❌ FAILED to plant " .. rafflesiaName .. " after " .. maxAttempts .. " attempts!")
    return false
end

local function runDojo()
    print("[DOJO] Starting Rafflesia strategy...")
    
    local myUnitIDs = getgenv().GlobalTracking.unitIDs
    
    -- ===== PLANTAR RAFFLESIA 1 (PATH 1) =====
    print("[DOJO] Planting Rafflesia 1 (Path 1)...")
    while getMoney() < 1250 do task.wait(0.2) end
    
    if not plantRafflesiaWithRetry(getRandomPositionPath1, "Rafflesia 1", 10) then
        WindUI:Notify({
            Title = "Dojo Error",
            Content = "Failed to plant Rafflesia 1 after 10 attempts",
            Duration = 5
        })
        return false
    end
    
    -- ✅ ESPERA ACTIVA EN LUGAR DE task.wait(1)
    local waitTime = 0
    local maxWaitTime = 5
    
    while #myUnitIDs < 1 and waitTime < maxWaitTime do
        task.wait(0.2)
        waitTime = waitTime + 0.2
    end
    
    if #myUnitIDs < 1 then
        warn("[DOJO] Failed to track Rafflesia 1 after " .. waitTime .. " seconds!")
        return false
    end
    
    local raff1ID = myUnitIDs[1]
    print("[DOJO] ✓ Rafflesia 1 tracked successfully (ID: " .. raff1ID .. ")")
    
    -- ===== PLANTAR RAFFLESIA 2 (PATH 2) =====
    print("[DOJO] Planting Rafflesia 2 (Path 2)...")
    while getMoney() < 1250 do task.wait(0.2) end
    
    if not plantRafflesiaWithRetry(getRandomPositionPath2, "Rafflesia 2", 10) then
        WindUI:Notify({
            Title = "Dojo Error",
            Content = "Failed to plant Rafflesia 2 after 10 attempts",
            Duration = 5
        })
        return false
    end
    
    -- ✅ ESPERA ACTIVA EN LUGAR DE task.wait(1)
    waitTime = 0
    
    while #myUnitIDs < 2 and waitTime < maxWaitTime do
        task.wait(0.2)
        waitTime = waitTime + 0.2
    end
    
    if #myUnitIDs < 2 then
        warn("[DOJO] Failed to track Rafflesia 2 after " .. waitTime .. " seconds!")
        return false
    end
    
    local raff2ID = myUnitIDs[2]
    print("[DOJO] ✓ Rafflesia 2 tracked successfully (ID: " .. raff2ID .. ")")
    
    -- ===== UPGRADES =====
    print("[DOJO] Upgrading Rafflesia 1...")
    while getMoney() < 8000 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(raff1ID)
    end)
    task.wait(0.4 + (math.random() * 0.59))
    
    print("[DOJO] Upgrading Rafflesia 2...")
    while getMoney() < 8000 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(raff2ID)
    end)
    task.wait(0.4 + (math.random() * 0.59))
    
    print("[DOJO] ========== ALL UPGRADES COMPLETE - WAITING FOR WAVE 10 ==========")
    
    -- ===== ESPERAR WAVE 10 =====
    local currentWave = 0
    local wave10Detected = false
    
    while not wave10Detected and getgenv().AutoFarmConfig.DojoActive do
        pcall(function()
            local gui = PlayerGui:FindFirstChild("GameGuiNoInset") or PlayerGui:FindFirstChild("GameGui")
            if gui then
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Visible and obj.Name == "Title" then
                        local waveNum = tonumber(string.match(obj.Text, "^Wave%s*(%d+)") or string.match(obj.Text, "Wave%s*(%d+)%s*/"))
                        
                        if waveNum and waveNum ~= currentWave then
                            currentWave = waveNum
                            
                            if currentWave >= 10 then
                                print("[DOJO] ✓✓✓ WAVE 10 REACHED! ✓✓✓")
                                wave10Detected = true
                                return
                            end
                        end
                    end
                end
            end
        end)
        
        if wave10Detected then break end
        task.wait(0.5)
    end
    
    if not wave10Detected then
        warn("[DOJO] Wave 10 detection failed")
        return false
    end
    
    print("[DOJO] ========== WAVE 10 REACHED - SELLING UNITS ==========")
    
    task.wait(0.5 + (math.random() * 0.5))
    
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("SellUnit"):InvokeServer(raff1ID)
    end)
    task.wait(0.05)
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("SellUnit"):InvokeServer(raff2ID)
    end)
    
    print("[DOJO] ========== SELL COMPLETE ==========")
    return true
end

-- ==================== AUTO WIN V1: TOMATO PLANT STRATEGY ====================
local function runAutoWinV1()
    print("[AUTO WIN V1] Starting Tomato Plant strategy...")
    
    -- ✅ USAR TRACKING GLOBAL
    local myUnitIDs = getgenv().GlobalTracking.unitIDs
    
    -- ===== COORDENADAS EXACTAS =====
    local tomatoPositions = {
        {cframe = CFrame.new(-326.81658935546875, 61.68030548095703, -105.2947998046875, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-326.57305908203125, 61.68030548095703, -110.16496276855469, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-340.4522705078125, 61.68030548095703, -102.63774108886719, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-341.37030029296875, 61.68030548095703, -108.40327453613281, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-330.5658264160156, 61.68030548095703, -107.22344970703125, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-331.0650634765625, 61.68030548095703, -112.37507629394531, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-325.50054931640625, 61.68030548095703, -114.86784362792969, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-340.1313781738281, 61.68030548095703, -112.30937194824219, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-330.9828186035156, 61.68030548095703, -115.9708480834961, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-345.5301513671875, 61.68030548095703, -105.17726135253906, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-341.2877197265625, 61.68030548095703, -116.77902221679688, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-345.55413818359375, 61.68030548095703, -111.3570327758789, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-327.5501708984375, 61.68030548095703, -118.89196014404297, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-339.9394836425781, 61.68030548095703, -120.87809753417969, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-345.091064453125, 61.68030548095703, -118.65930938720703, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-331.5858154296875, 61.680301666259766, -121.98548889160156, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-340.29302978515625, 61.68030548095703, -124.85790252685547, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-329.318115234375, 61.68030548095703, -125.80452728271484, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180}
    }
    
    local upgradeCosts = {125, 175, 350, 500}
    
    for i = 1, #tomatoPositions do
        print("[AUTO WIN V1] Planting Tomato " .. i .. "/18...")
        
        while getMoney() < 100 do task.wait(0.2) end
        
        for attempt = 1, 5 do
            local placed = placeUnit("unit_tomato_plant", tomatoPositions[i].cframe, tomatoPositions[i].rotation)
            if placed then 
                print("[AUTO WIN V1] ✓ Placed Tomato " .. i)
                break 
            end
            task.wait(0.15)
        end
        task.wait(0.15)
        
        local waitTime = 0
        while #myUnitIDs < i and waitTime < 10 do
            task.wait(0.2)
            waitTime = waitTime + 0.2
        end
        
        if #myUnitIDs < i then
            warn("[AUTO WIN V1] Failed to track Tomato " .. i)
            return false
        end
        
        local tomatoID = myUnitIDs[i]
        
        for level = 2, 5 do
            local cost = upgradeCosts[level - 1]
            print("[AUTO WIN V1] Upgrading Tomato " .. i .. " to Level " .. level .. "...")
            
            while getMoney() < cost do task.wait(0.2) end
            
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(tomatoID)
            end)
            
            task.wait(0.4 + (math.random() * 0.38))
        end
        
        print("[AUTO WIN V1] ✓ Tomato " .. i .. " fully upgraded (Level 5)")
    end
    
    print("[AUTO WIN V1] ========== ALL 18 TOMATO PLANTS PLACED AND UPGRADED ==========")
    return true
end

-- ==================== AUTO WIN V2: RAINBOW TOMATO STRATEGY ====================
local function runAutoWinV2()
    print("[AUTO WIN V2] Starting Rainbow Tomato strategy...")
    
    -- ✅ USAR TRACKING GLOBAL
    local myUnitIDs = getgenv().GlobalTracking.unitIDs
    
    -- ===== COORDENADAS EXACTAS =====
    local rainbowPositions = {
        {cframe = CFrame.new(-345.869873046875, 61.68030548095703, -116.59803771972656, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-341.4617004394531, 61.68030548095703, -105.65262603759766, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-325.448486328125, 61.68030548095703, -113.05741119384766, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-347.0238037109375, 61.68030548095703, -101.94581604003906, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-321.42462158203125, 61.68030548095703, -100.28288269042969, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-340.7768859863281, 61.68030548095703, -116.85527801513672, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-326.3725891113281, 61.6803092956543, -111.12118530273438, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-343.39996337890625, 61.68030548095703, -109.55160522460938, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-326.04852294921875, 61.68030548095703, -118.88896179199219, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        {cframe = CFrame.new(-341.5750732421875, 61.68030548095703, -115.53831481933594, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180}
    }
    
    local upgradeCosts = {125, 175, 350, 500}
    
    for i = 1, #rainbowPositions do
        print("[AUTO WIN V2] Planting Rainbow Tomato " .. i .. "/10...")
        
        while getMoney() < 100 do task.wait(0.2) end
        
        for attempt = 1, 5 do
            local placed = placeUnit("unit_tomato_rainbow", rainbowPositions[i].cframe, rainbowPositions[i].rotation)
            if placed then 
                print("[AUTO WIN V2] ✓ Placed Rainbow Tomato " .. i)
                break 
            end
            task.wait(0.15)
        end
        task.wait(0.15)
        
        local waitTime = 0
        while #myUnitIDs < i and waitTime < 10 do
            task.wait(0.2)
            waitTime = waitTime + 0.2
        end
        
        if #myUnitIDs < i then
            warn("[AUTO WIN V2] Failed to track Rainbow Tomato " .. i)
            return false
        end
        
        local rainbowID = myUnitIDs[i]
        
        for level = 2, 5 do
            local cost = upgradeCosts[level - 1]
            print("[AUTO WIN V2] Upgrading Rainbow Tomato " .. i .. " to Level " .. level .. "...")
            
            while getMoney() < cost do task.wait(0.2) end
            
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rainbowID)
            end)
            
            task.wait(0.4 + (math.random() * 0.38))
        end
        
        print("[AUTO WIN V2] ✓ Rainbow Tomato " .. i .. " fully upgraded (Level 5)")
    end
    
    print("[AUTO WIN V2] ========== ALL 10 RAINBOW TOMATOES PLACED AND UPGRADED ==========")
    return true
end

-- ==================== AUTO FARM LOOP MANAGER ====================
local function startAutoFarmLoop(strategyFunction, strategyName)
    task.spawn(function()
        print("[AUTO FARM LOOP] ========== STARTING " .. strategyName .. " LOOP ==========")
        
        -- ✅ INICIAR TRACKING GLOBAL UNA SOLA VEZ
        startGlobalTracking()
        
        local difficulty = "dif_impossible"
        local difficultyName = "Impossible"

        if strategyName == "Dojo" then
            difficulty = "dif_apocalypse"
            difficultyName = "Apocalypse"
        elseif strategyName == "Graveyard V2" then
            difficulty = "dif_impossible"
            difficultyName = "Impossible"
        elseif strategyName == "Auto Win V1" or strategyName == "Auto Win V2" then
            difficulty = "dif_easy"
            difficultyName = "Easy"
        end
        
        print("[AUTO FARM LOOP] First run - Activating toggles...")
        task.wait(1)
        
        if not getgenv().MainTabConfig.AutoSkip and getgenv().MainTabToggles.AutoSkip then
            getgenv().MainTabToggles.AutoSkip:Set(true)
        end
        
        if not getgenv().MainTabConfig.AutoPlayAgain and getgenv().MainTabToggles.AutoPlayAgain then
            getgenv().MainTabToggles.AutoPlayAgain:Set(true)
        end
        
        if not getgenv().AntiBanConfig.AntiAFKEnabled then
            if not getgenv().AntiBanConfig.AntiAFKLoaded then
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
                    getgenv().AntiBanConfig.AntiAFKLoaded = true
                end)
            end
            getgenv().AntiBanConfig.AntiAFKEnabled = true
            if getgenv().AntiBanToggles.AntiAFK then
                getgenv().AntiBanToggles.AntiAFK:Set(true)
            end
        end
        
        getgenv().MainTabConfig.SelectedDifficultyName = difficultyName
        getgenv().MainTabConfig.SelectedDifficulty = difficulty
        
        if not getgenv().MainTabConfig.AutoDifficulty and getgenv().MainTabToggles.AutoDifficulty then
            getgenv().MainTabToggles.AutoDifficulty:Set(true)
        end
        
        task.wait(1)
        
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(difficulty)
        end)
        
        print("[AUTO FARM LOOP] ========== EXECUTING FIRST MACRO ==========")
        
        -- ✅ RESETEAR IDS ANTES DEL PRIMER MACRO
        resetGlobalTracking()
        
        -- ✅ EJECUTAR MACRO CON PROTECCIÓN DE ERRORES
        local macroSuccess = pcall(function()
            strategyFunction()
        end)
        
        if macroSuccess then
            getgenv().AutoFarmConfig.MatchesPlayed = getgenv().AutoFarmConfig.MatchesPlayed + 1
            print("[AUTO FARM LOOP] ✓ First macro complete! Match count: " .. getgenv().AutoFarmConfig.MatchesPlayed)
        else
            warn("[AUTO FARM LOOP] ⚠️ First macro failed - will retry next match")
        end
        
        if getgenv().AntiBanConfig.AutoReturnEnabled and 
           getgenv().AntiBanConfig.MatchesBeforeReturn > 0 and 
           getgenv().AutoFarmConfig.MatchesPlayed >= getgenv().AntiBanConfig.MatchesBeforeReturn then
            
            print("[AUTO FARM LOOP] 🚨 MATCH LIMIT REACHED - DISABLING AUTO PLAY AGAIN 🚨")
            getgenv().MainTabConfig.AutoPlayAgain = false
            if getgenv().MainTabToggles.AutoPlayAgain then
                getgenv().MainTabToggles.AutoPlayAgain:Set(false)
            end
        end
        
        -- LOOP INFINITO
        while getgenv().AutoFarmConfig.IsRunning and (
            getgenv().AutoFarmConfig.GraveyardV1Active or 
            getgenv().AutoFarmConfig.GraveyardV2Active or 
            getgenv().AutoFarmConfig.DojoActive or 
            getgenv().AutoFarmConfig.AutoWinV1Active or 
            getgenv().AutoFarmConfig.AutoWinV2Active
        ) do
            print("[AUTO FARM LOOP] ========== WAITING FOR GAME END ==========")
            local gameEnded = false
            
            while not gameEnded and getgenv().AutoFarmConfig.IsRunning do
                pcall(function()
                    local gui = PlayerGui:FindFirstChild("GameGui")
                    if gui then
                        local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                        if endFrame and endFrame.Visible then
                            gameEnded = true
                        end
                    end
                end)
                task.wait(0.5)
            end
            
            if not getgenv().AutoFarmConfig.IsRunning then break end
            
            print("[AUTO FARM LOOP] Game ended - Match #" .. getgenv().AutoFarmConfig.MatchesPlayed .. " complete")
            
            -- ✅ VERIFICAR SI LLEGÓ AL LÍMITE
            if getgenv().AntiBanConfig.AutoReturnEnabled and 
               getgenv().AntiBanConfig.MatchesBeforeReturn > 0 and 
               getgenv().AutoFarmConfig.MatchesPlayed >= getgenv().AntiBanConfig.MatchesBeforeReturn then
                
                print("[AUTO FARM LOOP] ========== MATCH LIMIT REACHED - RETURNING TO LOBBY ==========")
                task.wait(3)
                
                print("[AUTO FARM LOOP] Using BackToMainLobby RemoteFunction...")
                local returnSuccess = pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BackToMainLobby"):InvokeServer()
                end)
                
                if returnSuccess then
                    print("[AUTO FARM LOOP] ✅ RETURN TO LOBBY SUCCESSFUL!")
                    task.wait(10)
                else
                    warn("[AUTO FARM LOOP] ✗ Return failed - Please return manually")
                end
                
                if getgenv().MainTabToggles then
                    if getgenv().MainTabToggles.AutoSkip then
                        getgenv().MainTabToggles.AutoSkip:Set(false)
                    end
                    if getgenv().MainTabToggles.AutoPlayAgain then
                        getgenv().MainTabToggles.AutoPlayAgain:Set(false)
                    end
                    if getgenv().MainTabToggles.AutoDifficulty then
                        getgenv().MainTabToggles.AutoDifficulty:Set(false)
                    end
                end
                
                stopGlobalTracking()
                
                getgenv().AutoFarmConfig.IsRunning = false
                getgenv().AutoFarmConfig.GraveyardV1Active = false
                getgenv().AutoFarmConfig.GraveyardV2Active = false
                getgenv().AutoFarmConfig.DojoActive = false
                getgenv().AutoFarmConfig.AutoWinV1Active = false
                getgenv().AutoFarmConfig.AutoWinV2Active = false
                getgenv().AutoFarmConfig.FirstRunComplete = false
                getgenv().AutoFarmConfig.MatchesPlayed = 0
                
                getgenv().NoahHubLocked = false
                
                WindUI:Notify({
                    Title = "✅ Auto Farm Completed",
                    Content = returnSuccess and "Returned to lobby after " .. getgenv().AntiBanConfig.MatchesBeforeReturn .. " matches" or "Farm stopped - Return manually",
                    Duration = 5
                })
                
                print("[AUTO FARM LOOP] ========== FARM STOPPED SUCCESSFULLY ==========")
                return
            end
            
            -- Continuar con siguiente partida
            print("[AUTO FARM LOOP] ========== WAITING FOR NEW GAME ==========")
            task.wait(2)
            
            local newGameStarted = false
            local waitTime = 0
            while not newGameStarted and waitTime < 15 do
                pcall(function()
                    local gui = PlayerGui:FindFirstChild("GameGui")
                    if gui then
                        local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                        if endFrame and not endFrame.Visible then
                            newGameStarted = true
                        end
                    end
                end)
                task.wait(0.5)
                waitTime = waitTime + 0.5
            end
            
            if not newGameStarted then
                warn("[AUTO FARM LOOP] Failed to detect new game - stopping")
                stopGlobalTracking()
                break
            end
            
            task.wait(2)
            
            -- ✅ RESETEAR IDS PARA NUEVA PARTIDA
            resetGlobalTracking()
            
            print("[AUTO FARM LOOP] ========== VOTING DIFFICULTY FOR MATCH #" .. (getgenv().AutoFarmConfig.MatchesPlayed + 1) .. " ==========")
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(difficulty)
            end)
            
            task.wait(1)
            
            print("[AUTO FARM LOOP] ========== EXECUTING MACRO FOR MATCH #" .. (getgenv().AutoFarmConfig.MatchesPlayed + 1) .. " ==========")
            
            -- ✅ EJECUTAR MACRO CON PROTECCIÓN DE ERRORES
            local macroSuccess = pcall(function()
                strategyFunction()
            end)
            
            if macroSuccess then
                getgenv().AutoFarmConfig.MatchesPlayed = getgenv().AutoFarmConfig.MatchesPlayed + 1
                print("[AUTO FARM LOOP] ✓ Macro complete! Match count: " .. getgenv().AutoFarmConfig.MatchesPlayed)
            else
                warn("[AUTO FARM LOOP] ⚠️ Macro failed - will retry next match")
            end
            
            if getgenv().AntiBanConfig.AutoReturnEnabled and 
               getgenv().AntiBanConfig.MatchesBeforeReturn > 0 and 
               getgenv().AutoFarmConfig.MatchesPlayed >= getgenv().AntiBanConfig.MatchesBeforeReturn then
                
                print("[AUTO FARM LOOP] 🚨 MATCH LIMIT REACHED - DISABLING AUTO PLAY AGAIN 🚨")
                getgenv().MainTabConfig.AutoPlayAgain = false
                if getgenv().MainTabToggles.AutoPlayAgain then
                    getgenv().MainTabToggles.AutoPlayAgain:Set(false)
                end
            end
        end
        
        stopGlobalTracking()
        print("[AUTO FARM LOOP] ========== LOOP STOPPED ==========")
    end)
end

-- ==================== CARGAR CONTENIDO DEL AUTO FARM TAB ====================
task.spawn(function()
    wait(0.2)
    print("[AUTO FARM TAB] Loading content...")
    
    AutoFarmTab:Section({
        Title = "Auto Farm",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    
    AutoFarmTab:Space()
    
    local GraveyardV1Toggle = AutoFarmTab:Toggle({
        Flag = "GraveyardV1",
        Title = "Graveyard V1",
        Desc = "Rainbow Tomato & Earth Dragon",
        Default = getgenv().AutoFarmConfig.GraveyardV1Active,
        Callback = function(state)
            if state then
                if getgenv().AutoFarmConfig.DojoActive then
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Another farm strategy is already running!",
                        Duration = 3
                    })
                    task.wait(0.1)
                    GraveyardV1Toggle:Set(false)
                    return
                end
                
                local currentMap = getCurrentMap()
                
                if currentMap == "map_lobby" then
                    print("[GRAVEYARD V1] Detected in lobby - Starting TP and setup...")
                    
                    WindUI:Notify({
                        Title = "Lobby Setup",
                        Content = "Teleporting to Graveyard lobby...",
                        Duration = 3
                    })
                    
                    task.spawn(function()
                        local Character = LocalPlayer.Character
                        if Character then
                            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                            if HumanoidRootPart then
                                HumanoidRootPart.CFrame = CFrame.new(121.05, 67.74, 779.65)
                                task.wait(0.5)
                            end
                        end
                        
                        pcall(function()
                            local args = { 1 }
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMaxPlayers_9"):InvokeServer(unpack(args))
                        end)
                        task.wait(0.15)
                        
                        pcall(function()
                            local args = { "map_graveyard" }
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMap_9"):InvokeServer(unpack(args))
                        end)
                        
                        WindUI:Notify({
                            Title = "Setup Complete",
                            Content = "Re-execute script when you enter Graveyard map!",
                            Duration = 5
                        })
                    end)
                    
                    task.wait(0.1)
                    getgenv().AutoFarmConfig.GraveyardV1Active = false
                    GraveyardV1Toggle:Set(false)
                    return
                end
                
                print("[GRAVEYARD V1] Detected in map - Starting auto farm...")
                
                getgenv().AutoFarmConfig.GraveyardV1Active = true
                getgenv().AutoFarmConfig.IsRunning = true
                getgenv().AutoFarmConfig.CurrentStrategy = "V1"
                getgenv().AutoFarmConfig.MatchesPlayed = 0
                getgenv().AutoFarmConfig.FirstRunComplete = false
                
                WindUI:Notify({
                    Title = "Graveyard V1 Started",
                    Content = "Rainbow Tomato & Earth Dragon strategy running...",
                    Duration = 3
                })
                
                print("[AUTO FARM] Graveyard V1 activated")
                
                startAutoFarmLoop(runGraveyardV1, "Graveyard V1")
                
            else
                getgenv().AutoFarmConfig.GraveyardV1Active = false
                getgenv().AutoFarmConfig.IsRunning = false
                getgenv().AutoFarmConfig.CurrentStrategy = nil
                getgenv().AutoFarmConfig.FirstRunComplete = false
                
                -- Si todas las farms están inactivas, desbloquear
                if not getgenv().AutoFarmConfig.DojoActive then
                    getgenv().NoahHubLocked = false
                    print("[NOAH HUB] All farms stopped - script unlocked")
                end
                
                WindUI:Notify({
                    Title = "Graveyard V1 Stopped",
                    Content = "Auto farm has been disabled",
                    Duration = 2
                })
                
                print("[AUTO FARM] Graveyard V1 deactivated")
            end
        end
    })
    
    AutoFarmTab:Space()

    local GraveyardV2Toggle = AutoFarmTab:Toggle({
        Flag = "GraveyardV2",
        Title = "Graveyard V2",
        Desc = "Prismleaf, Black Clover, Enchanting Rose, Potato, Witchleaf, Earth Dragon and Corrupted Stem",
        Default = getgenv().AutoFarmConfig.GraveyardV2Active,
        Callback = function(state)
            if state then
                if getgenv().AutoFarmConfig.GraveyardV1Active or getgenv().AutoFarmConfig.DojoActive or getgenv().AutoFarmConfig.AutoWinV1Active or getgenv().AutoFarmConfig.AutoWinV2Active then
                    WindUI:Notify({Title = "Error", Content = "Another farm strategy is already running!", Duration = 3})
                    task.wait(0.1)
                    GraveyardV2Toggle:Set(false)
                    return
                end
                
                local currentMap = getCurrentMap()
                
                if currentMap == "map_lobby" then
                    WindUI:Notify({Title = "Lobby Setup", Content = "Teleporting to Graveyard lobby...", Duration = 3})
                    task.spawn(function()
                        local Character = LocalPlayer.Character
                        if Character then
                            local HRP = Character:FindFirstChild("HumanoidRootPart")
                            if HRP then HRP.CFrame = CFrame.new(121.05, 67.74, 779.65) task.wait(0.5) end
                        end
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMaxPlayers_9"):InvokeServer(1)
                        end)
                        task.wait(0.15)
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMap_9"):InvokeServer("map_graveyard")
                        end)
                        WindUI:Notify({Title = "Setup Complete", Content = "Re-execute script when you enter Graveyard map!", Duration = 5})
                    end)
                    task.wait(0.1)
                    getgenv().AutoFarmConfig.GraveyardV2Active = false
                    GraveyardV2Toggle:Set(false)
                    return
                end
                
                getgenv().AutoFarmConfig.GraveyardV2Active = true
                getgenv().AutoFarmConfig.IsRunning = true
                getgenv().AutoFarmConfig.CurrentStrategy = "GraveyardV2"
                getgenv().AutoFarmConfig.MatchesPlayed = 0
                WindUI:Notify({Title = "Graveyard V2 Started", Content = "Multi-Unit strategy running...", Duration = 3})
                startAutoFarmLoop(runGraveyardV2, "Graveyard V2")
            else
                getgenv().AutoFarmConfig.GraveyardV2Active = false
                getgenv().AutoFarmConfig.IsRunning = false
                if not getgenv().AutoFarmConfig.GraveyardV1Active and not getgenv().AutoFarmConfig.DojoActive and not getgenv().AutoFarmConfig.AutoWinV1Active and not getgenv().AutoFarmConfig.AutoWinV2Active then
                    getgenv().NoahHubLocked = false
                end
                WindUI:Notify({Title = "Graveyard V2 Stopped", Content = "Auto farm disabled", Duration = 2})
            end
        end
    })

    AutoFarmTab:Space()
    
    local DojoToggle = AutoFarmTab:Toggle({
        Flag = "Dojo",
        Title = "Dojo",
        Desc = "Rafflesia",
        Default = getgenv().AutoFarmConfig.DojoActive,
        Callback = function(state)
            if state then
                if getgenv().AutoFarmConfig.GraveyardV1Active then
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Another farm strategy is already running!",
                        Duration = 3
                    })
                    task.wait(0.1)
                    DojoToggle:Set(false)
                    return
                end
                
                local currentMap = getCurrentMap()
                
                if currentMap == "map_lobby" then
                    print("[DOJO] Detected in lobby - Starting TP and setup...")
                    
                    WindUI:Notify({
                        Title = "Lobby Setup",
                        Content = "Teleporting to Dojo lobby...",
                        Duration = 3
                    })
                    
                    task.spawn(function()
                        local Character = LocalPlayer.Character
                        if Character then
                            local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                            if HumanoidRootPart then
                                HumanoidRootPart.CFrame = CFrame.new(121.05, 67.74, 779.65)
                                task.wait(0.5)
                            end
                        end
                        
                        pcall(function()
                            local args = { 1 }
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMaxPlayers_9"):InvokeServer(unpack(args))
                        end)
                        task.wait(0.15)
                        
                        pcall(function()
                            local args = { "map_dojo" }
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMap_9"):InvokeServer(unpack(args))
                        end)
                        
                        WindUI:Notify({
                            Title = "Setup Complete",
                            Content = "Re-execute script when you enter Dojo map!",
                            Duration = 5
                        })
                    end)
                    
                    task.wait(0.1)
                    getgenv().AutoFarmConfig.DojoActive = false
                    DojoToggle:Set(false)
                    return
                end
                
                print("[DOJO] Detected in map - Starting auto farm...")
                
                getgenv().AutoFarmConfig.DojoActive = true
                getgenv().AutoFarmConfig.IsRunning = true
                getgenv().AutoFarmConfig.CurrentStrategy = "Dojo"
                getgenv().AutoFarmConfig.MatchesPlayed = 0
                getgenv().AutoFarmConfig.FirstRunComplete = false
                
                WindUI:Notify({
                    Title = "Dojo Started",
                    Content = "Rafflesia strategy running...",
                    Duration = 3
                })
                
                print("[AUTO FARM] Dojo activated")
                
                startAutoFarmLoop(runDojo, "Dojo")
                
            else
                getgenv().AutoFarmConfig.DojoActive = false
                getgenv().AutoFarmConfig.IsRunning = false
                getgenv().AutoFarmConfig.CurrentStrategy = nil
                getgenv().AutoFarmConfig.FirstRunComplete = false
                
                -- Si todas las farms están inactivas, desbloquear
                if not getgenv().AutoFarmConfig.GraveyardV1Active then
                    getgenv().NoahHubLocked = false
                    print("[NOAH HUB] All farms stopped - script unlocked")
                end
                
                WindUI:Notify({
                    Title = "Dojo Stopped",
                    Content = "Auto farm has been disabled",
                    Duration = 2
                })
                
                print("[AUTO FARM] Dojo deactivated")
            end
        end
    })

    AutoFarmTab:Space()

local AutoWinV1Toggle = AutoFarmTab:Toggle({
    Flag = "AutoWinV1",
    Title = "Auto Win V1",
    Desc = "Tomato",
    Default = getgenv().AutoFarmConfig.AutoWinV1Active,
    Callback = function(state)
        if state then
            if getgenv().AutoFarmConfig.GraveyardV1Active or getgenv().AutoFarmConfig.DojoActive or getgenv().AutoFarmConfig.AutoWinV2Active then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Another farm strategy is already running!",
                    Duration = 3
                })
                task.wait(0.1)
                AutoWinV1Toggle:Set(false)
                return
            end
            
            local currentMap = getCurrentMap()
            
            if currentMap == "map_lobby" then
                print("[AUTO WIN V1] Detected in lobby - Starting TP and setup...")
                
                WindUI:Notify({
                    Title = "Lobby Setup",
                    Content = "Teleporting to Garden lobby...",
                    Duration = 3
                })
                
                task.spawn(function()
                    local Character = LocalPlayer.Character
                    if Character then
                        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                        if HumanoidRootPart then
                            HumanoidRootPart.CFrame = CFrame.new(121.05, 67.74, 779.65)
                            task.wait(0.5)
                        end
                    end
                    
                    pcall(function()
                        local args = { 1 }
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMaxPlayers_9"):InvokeServer(unpack(args))
                    end)
                    task.wait(0.15)
                    
                    pcall(function()
                        local args = { "map_farm" }
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMap_9"):InvokeServer(unpack(args))
                    end)
                    
                    WindUI:Notify({
                        Title = "Setup Complete",
                        Content = "Re-execute script when you enter Garden map!",
                        Duration = 5
                    })
                end)
                
                task.wait(0.1)
                getgenv().AutoFarmConfig.AutoWinV1Active = false
                AutoWinV1Toggle:Set(false)
                return
            end
            
            print("[AUTO WIN V1] Detected in map - Starting auto farm...")
            
            getgenv().AutoFarmConfig.AutoWinV1Active = true
            getgenv().AutoFarmConfig.IsRunning = true
            getgenv().AutoFarmConfig.CurrentStrategy = "AutoWinV1"
            getgenv().AutoFarmConfig.MatchesPlayed = 0
            getgenv().AutoFarmConfig.FirstRunComplete = false
            
            WindUI:Notify({
                Title = "Auto Win V1 Started",
                Content = "Tomato Plant strategy running...",
                Duration = 3
            })
            
            print("[AUTO FARM] Auto Win V1 activated")
            
            startAutoFarmLoop(runAutoWinV1, "Auto Win V1")
            
        else
            getgenv().AutoFarmConfig.AutoWinV1Active = false
            getgenv().AutoFarmConfig.IsRunning = false
            getgenv().AutoFarmConfig.CurrentStrategy = nil
            getgenv().AutoFarmConfig.FirstRunComplete = false
            
            if not getgenv().AutoFarmConfig.GraveyardV1Active and not getgenv().AutoFarmConfig.DojoActive and not getgenv().AutoFarmConfig.AutoWinV2Active then
                getgenv().NoahHubLocked = false
                print("[NOAH HUB] All farms stopped - script unlocked")
            end
            
            WindUI:Notify({
                Title = "Auto Win V1 Stopped",
                Content = "Auto farm has been disabled",
                Duration = 2
            })
            
            print("[AUTO FARM] Auto Win V1 deactivated")
        end
    end
})

AutoFarmTab:Space()

local AutoWinV2Toggle = AutoFarmTab:Toggle({
    Flag = "AutoWinV2",
    Title = "Auto Win V2",
    Desc = "Rainbow Tomatoes",
    Default = getgenv().AutoFarmConfig.AutoWinV2Active,
    Callback = function(state)
        if state then
            if getgenv().AutoFarmConfig.GraveyardV1Active or getgenv().AutoFarmConfig.DojoActive or getgenv().AutoFarmConfig.AutoWinV1Active then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Another farm strategy is already running!",
                    Duration = 3
                })
                task.wait(0.1)
                AutoWinV2Toggle:Set(false)
                return
            end
            
            local currentMap = getCurrentMap()
            
            if currentMap == "map_lobby" then
                print("[AUTO WIN V2] Detected in lobby - Starting TP and setup...")
                
                WindUI:Notify({
                    Title = "Lobby Setup",
                    Content = "Teleporting to Garden lobby...",
                    Duration = 3
                })
                
                task.spawn(function()
                    local Character = LocalPlayer.Character
                    if Character then
                        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                        if HumanoidRootPart then
                            HumanoidRootPart.CFrame = CFrame.new(121.05, 67.74, 779.65)
                            task.wait(0.5)
                        end
                    end
                    
                    pcall(function()
                        local args = { 1 }
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMaxPlayers_9"):InvokeServer(unpack(args))
                    end)
                    task.wait(0.15)
                    
                    pcall(function()
                        local args = { "map_farm" }
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMap_9"):InvokeServer(unpack(args))
                    end)
                    
                    WindUI:Notify({
                        Title = "Setup Complete",
                        Content = "Re-execute script when you enter Garden map!",
                        Duration = 5
                    })
                end)
                
                task.wait(0.1)
                getgenv().AutoFarmConfig.AutoWinV2Active = false
                AutoWinV2Toggle:Set(false)
                return
            end
            
            print("[AUTO WIN V2] Detected in map - Starting auto farm...")
            
            getgenv().AutoFarmConfig.AutoWinV2Active = true
            getgenv().AutoFarmConfig.IsRunning = true
            getgenv().AutoFarmConfig.CurrentStrategy = "AutoWinV2"
            getgenv().AutoFarmConfig.MatchesPlayed = 0
            getgenv().AutoFarmConfig.FirstRunComplete = false
            
            WindUI:Notify({
                Title = "Auto Win V2 Started",
                Content = "Rainbow Tomato strategy running...",
                Duration = 3
            })
            
            print("[AUTO FARM] Auto Win V2 activated")
            
            startAutoFarmLoop(runAutoWinV2, "Auto Win V2")
            
        else
            getgenv().AutoFarmConfig.AutoWinV2Active = false
            getgenv().AutoFarmConfig.IsRunning = false
            getgenv().AutoFarmConfig.CurrentStrategy = nil
            getgenv().AutoFarmConfig.FirstRunComplete = false
            
            if not getgenv().AutoFarmConfig.GraveyardV1Active and not getgenv().AutoFarmConfig.DojoActive and not getgenv().AutoFarmConfig.AutoWinV1Active then
                getgenv().NoahHubLocked = false
                print("[NOAH HUB] All farms stopped - script unlocked")
            end
            
            WindUI:Notify({
                Title = "Auto Win V2 Stopped",
                Content = "Auto farm has been disabled",
                Duration = 2
            })
            
            print("[AUTO FARM] Auto Win V2 deactivated")
        end
    end
})
    
    print("[AUTO FARM TAB] Content loaded!")
end)

-- ==================== CARGAR CONTENIDO DEL SUMMON TAB ====================
task.spawn(function()
    wait(0.3)
    print("[SUMMON TAB] Loading content...")
    
    local AutoSummonToggle
    
    local SummonConfig = {
        SelectedCrate = nil,
        SelectedCrateName = nil,
        BuyType = nil,
        BuyAmount = nil,
        IsRunning = false
    }
    
    local CrateMapping = {
        ["Classic Summon"] = "ub_classic_v8",
        ["Enchanted Summon"] = "ub_jungle",
        ["Sun Summon"] = "ub_sun",
        ["Astral Summon"] = "ub_astral",
        ["Crystal Summon"] = "ub_crystal",
        ["Tropical Summon"] = "ub_tropical",
        ["Bee Summon"] = "ub_bee",
        ["Corrupted Summon"] = "ub_corrupted",
        ["Mushroom Summon"] = "ub_mushroom",
        ["Halloween Summon"] = "ub_halloween"
    }
    
    SummonTab:Section({
        Title = "Summon Crate",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    
    SummonTab:Section({
        Title = "You can buy crates anywhere even the crates out of stock.",
        TextSize = 14,
        TextTransparency = 0.5,
    })
    
    local SelectCrateDropdown = SummonTab:Dropdown({
        Flag = "SelectedCrate",
        Title = "Select Crate",
        Values = {
            { Title = "Classic Summon" },
            { Title = "Enchanted Summon" },
            { Title = "Sun Summon" },
            { Title = "Astral Summon" },
            { Title = "Crystal Summon" },
            { Title = "Tropical Summon" },
            { Title = "Bee Summon" },
            { Title = "Corrupted Summon" },
            { Title = "Mushroom Summon" },
            { Title = "Halloween Summon" }
        },
        Callback = function(option)
            SummonConfig.SelectedCrateName = option.Title
            SummonConfig.SelectedCrate = CrateMapping[option.Title]
            SelectCrateDropdown:Highlight()
        end
    })
    
    SummonTab:Space()
    
    local BuyTypeDropdown = SummonTab:Dropdown({
        Flag = "BuyType",
        Title = "Quantity",
        Values = {
            { Title = "Buy 1" },
            { Title = "Buy 10" }
        },
        Callback = function(option)
            if option.Title == "Buy 1" then
                SummonConfig.BuyType = 1
            else
                SummonConfig.BuyType = 10
            end
            BuyTypeDropdown:Highlight()
        end
    })
    
    SummonTab:Space()
    
    local BuyAmountInput = SummonTab:Input({
        Flag = "BuyAmount",
        Title = "Amount",
        Desc = "X times you want to buy.",
        Type = "Input",
        Placeholder = "Enter amount...",
        Callback = function(input)
            if input == "" or input == nil then
                SummonConfig.BuyAmount = nil
                return
            end
            
            local amount = tonumber(input)
            if amount and amount > 0 then
                SummonConfig.BuyAmount = math.floor(amount)
                BuyAmountInput:Highlight()
            else
                SummonConfig.BuyAmount = nil
                WindUI:Notify({
                    Title = "Invalid Amount",
                    Content = "Please enter a valid number greater than 0",
                    Duration = 3
                })
            end
        end
    })
    
    SummonTab:Space()
    
    AutoSummonToggle = SummonTab:Toggle({
        Flag = "AutoSummon",
        Title = "Summon",
        Default = false,
        Callback = function(state)
            SummonConfig.IsRunning = state
            
            if state then
                if not SummonConfig.SelectedCrate then
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Please select a crate first!",
                        Duration = 3
                    })
                    AutoSummonToggle:Set(false)
                    return
                end
                
                if not SummonConfig.BuyType then
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Please select buy type (1 or 10)!",
                        Duration = 3
                    })
                    AutoSummonToggle:Set(false)
                    return
                end
                
                if not SummonConfig.BuyAmount or SummonConfig.BuyAmount <= 0 then
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Please enter a valid buy amount!",
                        Duration = 3
                    })
                    AutoSummonToggle:Set(false)
                    return
                end
                
                WindUI:Notify({
                    Title = "Auto Summon Started",
                    Content = "Buying " .. SummonConfig.BuyAmount .. "x " .. SummonConfig.BuyType .. " of " .. SummonConfig.SelectedCrateName,
                    Duration = 3
                })
                
                AutoSummonToggle:Highlight()
                
                task.spawn(function()
                    local completed = 0
                    
                    for i = 1, SummonConfig.BuyAmount do
                        if not SummonConfig.IsRunning then
                            WindUI:Notify({
                                Title = "Auto Summon Stopped",
                                Content = "Completed " .. completed .. " out of " .. SummonConfig.BuyAmount,
                                Duration = 3
                            })
                            break
                        end
                        
                      local success, result = pcall(function()
                            local args = {
                                SummonConfig.SelectedCrate,
                                SummonConfig.BuyType
                            }
                            return game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BuyUnitBox"):InvokeServer(unpack(args))
                        end)
                        
                        -- ✅ VERIFICAR EL RESULTADO EXACTO
                        if success and result == true then
                            -- Compra exitosa
                            completed = completed + 1
                            print("[AUTO SUMMON] ✓ Purchase " .. i .. "/" .. SummonConfig.BuyAmount .. " completed")
                            
                        else
                            -- Compra rechazada (sin dinero, inventario lleno, u otro error)
                            warn("[AUTO SUMMON] ✗ Purchase failed: " .. tostring(result))
                            
                            SummonConfig.IsRunning = false
                            AutoSummonToggle:Set(false)
                            
                            WindUI:Notify({
                                Title = "Auto Summon Stopped",
                                Content = "You broke or your inventory is full!",
                                Duration = 5
                            })
                            break
                        end
                        
                        task.wait(0.5)
                    end
                    
                    if SummonConfig.IsRunning then
                        SummonConfig.IsRunning = false
                        AutoSummonToggle:Set(false)
                        
                        WindUI:Notify({
                            Title = "Auto Summon Completed",
                            Content = "Successfully bought " .. completed .. "x " .. SummonConfig.BuyType .. " of " .. SummonConfig.SelectedCrateName,
                            Duration = 2
                        })
                    end
                end)
            else
                WindUI:Notify({
                    Title = "Auto Summon Stopped",
                    Content = "Summoning has been stopped",
                    Duration = 2
                })
            end
        end
    })
    
    print("[SUMMON TAB] Content loaded!")
end)

-- ==================== CARGAR CONTENIDO DEL ANTI BAN TAB ====================
task.spawn(function()
    wait(0.4)
    print("[ANTI BAN TAB] Loading content...")
    
    AntiBanTab:Section({
        Title = "Anti Ban",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    
    AntiBanTab:Section({
        Title = "This is not 100% Bulletproof",
        TextSize = 14,
        TextTransparency = 0.5,
    })
    
    AntiBanTab:Section({
        Title = "⚠️ These settings only work inside maps",
        TextSize = 13,
        TextTransparency = 0.4,
    })
    
    AntiBanTab:Space()
    
    local PlacementOffsetInput = AntiBanTab:Input({
        Flag = "PlacementOffset",
        Title = "Placement Offset",
        Desc = "Adds randomness to macro placements.",
        Type = "Input",
        Value = tostring(getgenv().AntiBanConfig.PlacementOffset),
        Placeholder = "1.5",
        Callback = function(input)
            -- ✅ VERIFICAR SI ESTÁ EN MAPA
            local currentMap = getCurrentMap()
            
            if currentMap == "map_lobby" then
                WindUI:Notify({
                    Title = "Cannot Use in Lobby",
                    Content = "Placement Offset only works inside maps!",
                    Duration = 3
                })
                
                -- Restaurar valor anterior
                PlacementOffsetInput:Set(tostring(getgenv().AntiBanConfig.PlacementOffset))
                return
            end
            
            if input == "" or input == nil then
                getgenv().AntiBanConfig.PlacementOffset = 1.5
                return
            end
            
            local number = tonumber(input)
            if number and number >= 0 and number <= 10 then
                getgenv().AntiBanConfig.PlacementOffset = number
                
                -- ✅ Solo notificar si es diferente al valor por defecto
                if number ~= 1.5 then
                    WindUI:Notify({
                        Title = "Placement Offset Updated",
                        Content = "Random offset: " .. number .. " studs",
                        Duration = 2
                    })
                end
            else
                WindUI:Notify({
                    Title = "Invalid Value",
                    Content = "Please enter a number between 0 and 10",
                    Duration = 3
                })
            end
        end
    })
    
    AntiBanTab:Space()
    
    local MatchesBeforeReturnInput = AntiBanTab:Input({
        Flag = "MatchesBeforeReturn",
        Title = "Matches Before Lobby Return",
        Desc = "Return to lobby after X matches",
        Type = "Input",
        Value = tostring(getgenv().AntiBanConfig.MatchesBeforeReturn),
        Placeholder = "100",
        Callback = function(input)
            -- ✅ VERIFICAR SI ESTÁ EN MAPA
            local currentMap = getCurrentMap()
            
            if currentMap == "map_lobby" then
                WindUI:Notify({
                    Title = "Cannot Use in Lobby",
                    Content = "This setting only works inside maps!",
                    Duration = 3
                })
                
                -- Restaurar valor anterior
                MatchesBeforeReturnInput:Set(tostring(getgenv().AntiBanConfig.MatchesBeforeReturn))
                return
            end
            
            if input == "" or input == nil then
                getgenv().AntiBanConfig.MatchesBeforeReturn = 100
                return
            end
            
            local number = tonumber(input)
            if number and number >= 0 then
                local oldValue = getgenv().AntiBanConfig.MatchesBeforeReturn
                getgenv().AntiBanConfig.MatchesBeforeReturn = math.floor(number)
                
                -- ✅ Solo notificar si cambió el valor
                if oldValue ~= number then
                    WindUI:Notify({
                        Title = "Matches Updated",
                        Content = "Will return after " .. number .. " matches",
                        Duration = 2
                    })
                end
            else
                WindUI:Notify({
                    Title = "Invalid Value",
                    Content = "Please enter a valid number",
                    Duration = 3
                })
            end
        end
    })
    
    AntiBanTab:Space()
    
    local AutoReturnToggle = AntiBanTab:Toggle({
        Flag = "EnableAutoReturn",
        Title = "Enable Auto Return",
        Desc = "Toggle to activate matches limit",
        Default = getgenv().AntiBanConfig.AutoReturnEnabled,
        Callback = function(state)
            -- ✅ VERIFICAR SI ESTÁ EN MAPA
            local currentMap = getCurrentMap()
            
            if state and currentMap == "map_lobby" then
                WindUI:Notify({
                    Title = "Cannot Use in Lobby",
                    Content = "Auto Return only works inside maps!",
                    Duration = 3
                })
                
                task.spawn(function()
                    task.wait(0.1)
                    AutoReturnToggle:Set(false)
                end)
                return
            end
            
            getgenv().AntiBanConfig.AutoReturnEnabled = state
            
            if state then
                WindUI:Notify({
                    Title = "Auto Return Enabled",
                    Content = "Will return to lobby after " .. getgenv().AntiBanConfig.MatchesBeforeReturn .. " matches",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "Auto Return Disabled",
                    Content = "Farm will run indefinitely",
                    Duration = 2
                })
            end
        end
    })
    
    AntiBanTab:Space()
    
    local AntiAFKToggle = AntiBanTab:Toggle({
        Flag = "EnableAntiAFK",
        Title = "Enable Anti-AFK",
        Desc = "Prevents AFK kick (auto-activates with farm)",
        Default = false,
        Callback = function(state)
            -- ✅ VERIFICAR SI ESTÁ EN MAPA
            local currentMap = getCurrentMap()
            
            if state and currentMap == "map_lobby" then
                WindUI:Notify({
                    Title = "Cannot Use in Lobby",
                    Content = "Anti-AFK only works inside maps!",
                    Duration = 3
                })
                
                task.spawn(function()
                    task.wait(0.1)
                    AntiAFKToggle:Set(false)
                end)
                return
            end
            
            getgenv().AntiBanConfig.AntiAFKEnabled = state
            
            if state then
                -- Cargar Anti-AFK inmediatamente si se activa manualmente
                if not getgenv().AntiBanConfig.AntiAFKLoaded then
                    task.spawn(function()
                        pcall(function()
                            print("[ANTI-AFK] Loading anti-AFK script...")
                            loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
                            getgenv().AntiBanConfig.AntiAFKLoaded = true
                            print("[ANTI-AFK] Anti-AFK loaded successfully")
                        end)
                    end)
                end
                
                WindUI:Notify({
                    Title = "Anti-AFK Enabled",
                    Content = "You won't be kicked for being AFK",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "Anti-AFK Disabled",
                    Content = "Anti-AFK protection disabled (requires rejoin to fully disable)",
                    Duration = 3
                })
            end
        end
    })
    
    -- Guardar referencia global
    getgenv().AntiBanToggles.AntiAFK = AntiAFKToggle
    
    print("[ANTI BAN TAB] Content loaded!")
end)

-- ==================== CARGAR CONTENIDO DEL WEBHOOK TAB ====================
task.spawn(function()
    wait(0.5)
    print("[WEBHOOK TAB] Loading content...")
    
    WebhookTab:Section({
        Title = "Discord Webhook Configuration",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    
    WebhookTab:Section({
        Title = "Send game statistics to your Discord Server",
        TextSize = 14,
        TextTransparency = 0.5,
    })
    
    WebhookTab:Space()
    
    -- ✅ DECLARAR VARIABLES PRIMERO
    local WebhookToggle
    local WebhookInput
    
    -- ✅ CREAR INPUT PRIMERO
    WebhookInput = WebhookTab:Input({
        Flag = "WebhookURL",
        Title = "Webhook Link",
        Desc = "Discord Webhook URL",
        Type = "Input",
        Value = getgenv().WebhookConfig.URL,
        Placeholder = "https://discord.com/api/webhooks/...",
        Callback = function(input)
            getgenv().WebhookConfig.URL = input
            
            -- ✅ Si el input NO está vacío, activar el toggle automáticamente
            if input ~= "" and input ~= nil then
                getgenv().WebhookConfig.Enabled = true
                saveWebhookConfig()
                
                -- Activar el toggle visualmente
                if WebhookToggle then
                    WebhookToggle:Set(true)
                end
                
                WebhookInput:Highlight()
                WindUI:Notify({
                    Title = "Webhook Saved & Enabled",
                    Content = "Webhook URL saved and activated!",
                    Duration = 2
                })
            else
                -- ✅ Si borra el URL, desactivar el toggle
                getgenv().WebhookConfig.Enabled = false
                saveWebhookConfig()
                
                if WebhookToggle then
                    WebhookToggle:Set(false)
                end
            end
        end
    })
    
    WebhookTab:Space()
    
    WebhookTab:Button({
        Title = "Test Webhook",
        Desc = "Send a test message to verify the Webhook",
        Callback = function()
            if sendWebhook(nil, true) then
                WindUI:Notify({
                    Title = "Test Sent",
                    Content = "Check your Discord Channel!",
                    Duration = 3
                })
            end
        end
    })
    
    WebhookTab:Space()
    
    -- ✅ CREAR TOGGLE DESPUÉS
    WebhookToggle = WebhookTab:Toggle({
        Flag = "EnableWebhook",
        Title = "Enable Webhook",
        Default = getgenv().WebhookConfig.Enabled,
        Callback = function(state)
            getgenv().WebhookConfig.Enabled = state
            saveWebhookConfig()
            
            if state then
                if getgenv().WebhookConfig.URL == "" then
                    WindUI:Notify({
                        Title = "Webhook Error",
                        Content = "Please configure the Webhook URL first!",
                        Duration = 3
                    })
                    WebhookToggle:Set(false)
                    return
                end
                
                WindUI:Notify({
                    Title = "Webhook Enabled",
                    Content = "Stats will be sent automatically after each match",
                    Duration = 3
                })
                
                WebhookToggle:Highlight()
            else
                WindUI:Notify({
                    Title = "Webhook Disabled",
                    Content = "Automatic Webhook sending has been disabled",
                    Duration = 2
                })
            end
        end
    })
    
    -- ✅ FORZAR ACTUALIZACIÓN VISUAL SI HAY URL GUARDADA
    task.spawn(function()
        task.wait(0.1)
        if getgenv().WebhookConfig.Enabled and getgenv().WebhookConfig.URL ~= "" then
            WebhookToggle:Set(true)
            print("[WEBHOOK] Toggle visually updated to ON")
        end
    end)
    
    print("[WEBHOOK TAB] Content loaded!")
end)

-- ==================== CARGAR CONTENIDO DEL SETTINGS TAB ====================
task.spawn(function()
    wait(0.6)
    print("[SETTINGS TAB] Loading content...")
    
    SettingsTab:Section({
        Title = "Configuration System",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    
    SettingsTab:Section({
        Title = "⚠️ Configuration system temporarily disabled",
        TextSize = 14,
        TextTransparency = 0.5,
    })
    
    print("[SETTINGS TAB] Content loaded (disabled)!")
end)
