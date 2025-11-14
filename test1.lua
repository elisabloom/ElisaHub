-- ==================== PREVENIR MÚLTIPLES INSTANCIAS (MEJORADO) ====================
-- Sistema de bloqueo para evitar ejecuciones múltiples
if getgenv().NoahHubLocked then
    warn("[NOAH HUB] Script already running! Please wait or reset to run again.")
    return
end

getgenv().NoahHubLocked = true

if getgenv().NoahHubWindow then
    local success = pcall(function()
        getgenv().NoahHubWindow:Destroy()
    end)
    if not success then
        warn("[NOAH HUB] Failed to destroy previous window")
    end
    getgenv().NoahHubWindow = nil
    
    -- Limpiar estados de farm
    if getgenv().AutoFarmConfig then
        getgenv().AutoFarmConfig.GraveyardV1Active = false
        getgenv().AutoFarmConfig.GraveyardV2Active = false
        getgenv().AutoFarmConfig.DojoActive = false
        getgenv().AutoFarmConfig.IsRunning = false
    end
    
    wait(0.5)  -- Esperar más tiempo para que se limpie todo
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")


-- Limpiar TODAS las GUIs previas
for _, gui in pairs(PlayerGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        if gui.Name:find("WindUI") or gui.Name:find("NoahHub") or gui.Name:find("OpenButton") then
            pcall(function()
                gui:Destroy()
            end)
        end
    end
end

wait(0.5)

print("[NOAH HUB] Starting fresh instance...")

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
            autoSaveToAutoLoad()  -- ⬅️ AGREGAR AL FINAL
        end
    })
    
    getgenv().MainTabToggles.AutoSpeed2x = AutoSpeed2xToggle
    
    MainTab:Space()
    
    AutoSpeed3xToggle = MainTab:Toggle({
        Flag = "AutoSpeed3x",
        Title = "Auto x3 Speed",
        Default = getgenv().MainTabConfig.AutoSpeed3x,
        Callback = function(state)
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
                    task.wait(0.3)
                    
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

local function getMoney()
    return LocalPlayer:GetAttribute("Cash") or 0
end

-- ✅ FUNCIÓN CORREGIDA: SOLO USA EL OFFSET DEL ANTI-BAN TAB (1.5)
local function placeUnit(unitName, cframe, rotation)
    local offset = getgenv().AntiBanConfig.PlacementOffset or 1.5
    
    -- Solo aplicar UNA VEZ el offset
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
    
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then
        warn("[GRAVEYARD V1] Map not found!")
        return false
    end
    
    local entities = mapFolder:FindFirstChild("Entities")
    if not entities then
        warn("[GRAVEYARD V1] Entities not found!")
        return false
    end
    
    -- ===== SISTEMA DE TRACKING DE IDs =====
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
    
    local myUnitIDs = {}
    local trackingEnabled = true
    
    local childAddedConnection = entities.ChildAdded:Connect(function(child)
        if trackingEnabled then
            task.spawn(function()
                task.wait(1)
                if child and child.Parent and string.find(child.Name, "unit_") then
                    local unitID = getUnitID(child)
                    if unitID then
                        table.insert(myUnitIDs, unitID)
                        print("[GRAVEYARD V1] Tracked unit ID: " .. tostring(unitID))
                    end
                end
            end)
        end
    end)
    
    -- ===== COORDENADAS EXACTAS DEL DOCUMENTO 2 =====
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
    task.wait(0.3)
    
    local waitTime = 0
    while #myUnitIDs < 1 and waitTime < 10 do
        task.wait(0.2)
        waitTime = waitTime + 0.2
    end
    
    if #myUnitIDs < 1 then
        trackingEnabled = false
        childAddedConnection:Disconnect()
        warn("[GRAVEYARD V1] Failed to track Rainbow Tomato 1!")
        return false
    end
    
    local rb1ID = myUnitIDs[1]
    print("[GRAVEYARD V1] rb1ID: " .. tostring(rb1ID))
    
    -- ===== PASO 2: UPGRADE RB1 → LEVEL 2 (125) =====
    print("[GRAVEYARD V1] Upgrading RB1 to Level 2...")
    while getMoney() < 125 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb1ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 3: UPGRADE RB1 → LEVEL 3 (175) =====
    print("[GRAVEYARD V1] Upgrading RB1 to Level 3...")
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
    task.wait(0.3)
    
    waitTime = 0
    while #myUnitIDs < 2 and waitTime < 10 do
        task.wait(0.2)
        waitTime = waitTime + 0.2
    end
    
    if #myUnitIDs < 2 then
        trackingEnabled = false
        childAddedConnection:Disconnect()
        warn("[GRAVEYARD V1] Failed to track Rainbow Tomato 2!")
        return false
    end
    
    local rb2ID = myUnitIDs[2]
    print("[GRAVEYARD V1] rb2ID: " .. tostring(rb2ID))
    
    -- ===== PASO 5: UPGRADE RB2 → LEVEL 2 (125) =====
    print("[GRAVEYARD V1] Upgrading RB2 to Level 2...")
    while getMoney() < 125 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb2ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 6: UPGRADE RB2 → LEVEL 3 (175) =====
    print("[GRAVEYARD V1] Upgrading RB2 to Level 3...")
    while getMoney() < 175 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb2ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 7: UPGRADE RB2 → LEVEL 4 (350) =====
    print("[GRAVEYARD V1] Upgrading RB2 to Level 4...")
    while getMoney() < 350 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb2ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 8: UPGRADE RB2 → LEVEL 5 (500) =====
    print("[GRAVEYARD V1] Upgrading RB2 to Level 5...")
    while getMoney() < 500 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb2ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 9: UPGRADE RB1 → LEVEL 4 (350) =====
    print("[GRAVEYARD V1] Upgrading RB1 to Level 4...")
    while getMoney() < 350 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb1ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 10: UPGRADE RB1 → LEVEL 5 (500) =====
    print("[GRAVEYARD V1] Upgrading RB1 to Level 5...")
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
    task.wait(0.3)
    
    waitTime = 0
    while #myUnitIDs < 3 and waitTime < 10 do
        task.wait(0.2)
        waitTime = waitTime + 0.2
    end
    
    if #myUnitIDs < 3 then
        trackingEnabled = false
        childAddedConnection:Disconnect()
        warn("[GRAVEYARD V1] Failed to track Rainbow Tomato 3!")
        return false
    end
    
    local rb3ID = myUnitIDs[3]
    print("[GRAVEYARD V1] rb3ID: " .. tostring(rb3ID))
    
    -- ===== PASO 12: UPGRADE RB3 → LEVEL 2 (125) =====
    print("[GRAVEYARD V1] Upgrading RB3 to Level 2...")
    while getMoney() < 125 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb3ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 13: UPGRADE RB3 → LEVEL 3 (175) =====
    print("[GRAVEYARD V1] Upgrading RB3 to Level 3...")
    while getMoney() < 175 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb3ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 14: UPGRADE RB3 → LEVEL 4 (350) =====
    print("[GRAVEYARD V1] Upgrading RB3 to Level 4...")
    while getMoney() < 350 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb3ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    -- ===== PASO 15: UPGRADE RB3 → LEVEL 5 (500) =====
    print("[GRAVEYARD V1] Upgrading RB3 to Level 5...")
    while getMoney() < 500 do task.wait(0.2) end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rb3ID)
    end)
    task.wait(0.4 + (math.random() * 0.38))
    
    print("[GRAVEYARD V1] ========== ALL RAINBOW TOMATO UPGRADES COMPLETE - PLACING DRAGONS ==========")
    
    -- ===== PASO 16: PLANTAR 3 EARTH DRAGONS (6000 cada uno, sin upgrades) =====
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
    task.wait(0.3)
    
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
    task.wait(0.3)
    
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
    task.wait(0.3)
    
    print("[GRAVEYARD V1] ========== ALL DRAGONS PLACED - WAITING FOR WAVE 20 ==========")
    
    -- ===== PASO 17: ESPERAR WAVE 20 =====
    local currentWave = 0
    local wave20Detected = false
    
    while not wave20Detected and getgenv().AutoFarmConfig.GraveyardV1Active do
        pcall(function()
            local gui = PlayerGui:FindFirstChild("GameGuiNoInset")
            if gui then
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Visible and obj.Name == "Title" then
                        local text = obj.Text
                        local waveNum = string.match(text, "^Wave%s*(%d+)")
                        if not waveNum then
                            waveNum = string.match(text, "Wave%s*(%d+)%s*/")
                        end
                        
                        if waveNum then
                            currentWave = tonumber(waveNum)
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
            
            if not wave20Detected then
                gui = PlayerGui:FindFirstChild("GameGui")
                if gui then
                    for _, obj in pairs(gui:GetDescendants()) do
                        if obj:IsA("TextLabel") and obj.Visible and obj.Name == "Title" then
                            local text = obj.Text
                            local waveNum = string.match(text, "^Wave%s*(%d+)")
                            if not waveNum then
                                waveNum = string.match(text, "Wave%s*(%d+)%s*/")
                            end
                            
                            if waveNum then
                                currentWave = tonumber(waveNum)
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
            end
        end)
        
        if wave20Detected then break end
        task.wait(0.5)
    end
    
    if not getgenv().AutoFarmConfig.GraveyardV1Active then
        print("[GRAVEYARD V1] Farm stopped before Wave 20")
        trackingEnabled = false
        childAddedConnection:Disconnect()
        return false
    end
    
    print("[GRAVEYARD V1] ========== WAVE 20 REACHED - SELLING ALL UNITS ==========")
    
    -- ===== PASO 18: VENDER TODAS LAS UNIDADES (3 RB + 3 Dragons = 6 unidades) =====
    local randomDelay = 0.5 + (math.random() * 0.5)
    print("[GRAVEYARD V1] Waiting " .. string.format("%.2f", randomDelay) .. " seconds before selling...")
    task.wait(randomDelay)
    
    -- Vender usando IDs trackeados si están disponibles
    if #myUnitIDs >= 6 then
        print("[GRAVEYARD V1] Selling all 6 units using tracked IDs...")
        for i = 1, 6 do
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("SellUnit"):InvokeServer(myUnitIDs[i])
                print("[GRAVEYARD V1] ✓ Sold unit " .. i .. " (ID: " .. tostring(myUnitIDs[i]) .. ")")
            end)
            task.wait(0.05)
        end
    else
        -- Fallback: vender por índice numérico
        print("[GRAVEYARD V1] Selling all 6 units using numeric IDs (fallback)...")
        for unitID = 1, 6 do
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("SellUnit"):InvokeServer(unitID)
                print("[GRAVEYARD V1] ✓ Sold unit " .. unitID)
            end)
            task.wait(0.3 + (math.random() * 0.2))
        end
    end
    
    print("[GRAVEYARD V1] ========== ALL UNITS SOLD ==========")
    
    -- Limpiar tracking
    trackingEnabled = false
    if childAddedConnection then
        childAddedConnection:Disconnect()
    end
    myUnitIDs = {}
    
    print("[GRAVEYARD V1] Strategy complete! All actions finished.")
    
    return true
end

-- ==================== DOJO: RAFFLESIA STRATEGY ====================
local function runDojo()
    print("[DOJO] Starting Rafflesia strategy...")
    
    -- Funciones para posiciones random (con offset del Anti-Ban)
    local function getRandomPositionPath1()
        local offset = getgenv().AntiBanConfig.PlacementOffset or 1.5
        
        local minPos = Vector3.new(46.63258361816406, -21.75, -49.71086502075195)
        local maxPos = Vector3.new(52.49168014526367, -21.75, -55.56996154785156)
        
        local randomX = minPos.X + math.random() * (maxPos.X - minPos.X)
        local randomZ = minPos.Z + math.random() * (maxPos.Z - minPos.Z)
        
        -- Aplicar offset adicional del Anti-Ban
        randomX = randomX + (math.random() - 0.5) * 2 * offset
        randomZ = randomZ + (math.random() - 0.5) * 2 * offset
        
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
        local offset = getgenv().AntiBanConfig.PlacementOffset or 1.5
        
        local minPos = Vector3.new(-54.49039077758789, -21.75, -53.30671691894531)
        local maxPos = Vector3.new(-42.14012908935547, -21.74989891052246, -40.86867141723633)
        
        local randomX = minPos.X + math.random() * (maxPos.X - minPos.X)
        local randomZ = minPos.Z + math.random() * (maxPos.Z - minPos.Z)
        
        -- Aplicar offset adicional del Anti-Ban
        randomX = randomX + (math.random() - 0.5) * 2 * offset
        randomZ = randomZ + (math.random() - 0.5) * 2 * offset
        
        local position = Vector3.new(randomX, -21.75, randomZ)
        
        return {
            Valid = true,
            PathIndex = 2,
            Position = position,
            CF = CFrame.new(position.X, position.Y, position.Z, 0.7071068286895752, 0, 0.7071067690849304, -0, 1, -0, -0.7071068286895752, 0, 0.7071067690849304),
            Rotation = 180
        }
    end
    
    -- Sistema de tracking de IDs (igual que Graveyard V2)
    local mapFolder = Workspace:FindFirstChild("Map")
    if not mapFolder then
        warn("[DOJO] Map not found!")
        return false
    end
    
    local entities = mapFolder:FindFirstChild("Entities")
    if not entities then
        warn("[DOJO] Entities not found!")
        return false
    end
    
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
    
    local myUnitIDs = {}
    local trackingEnabled = true
    
    local childAddedConnection = entities.ChildAdded:Connect(function(child)
        if trackingEnabled then
            task.spawn(function()
                task.wait(1)
                if child and child.Parent and string.find(child.Name, "unit_") then
                    local unitID = getUnitID(child)
                    if unitID then
                        table.insert(myUnitIDs, unitID)
                        print("[DOJO] Tracked unit ID: " .. tostring(unitID))
                    end
                end
            end)
        end
    end)
    
    -- ===== COLOCAR PRIMER RAFFLESIA (PATH 1) =====
    print("[DOJO] Placing Rafflesia 1 (Path 1)...")
    while getMoney() < 1250 do task.wait(0.2) end
    
    for attempt = 1, 5 do
        local placementData = getRandomPositionPath1()
        
        local success = pcall(function()
            ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("PlaceUnit"):InvokeServer("unit_rafflesia", placementData)
        end)
        
        if success then 
            print("[DOJO] ✓ Placed Rafflesia 1")
            break 
        end
        task.wait(0.15)
    end
    task.wait(0.3)
    
    local waitTime = 0
    while #myUnitIDs < 1 and waitTime < 10 do
        task.wait(0.2)
        waitTime = waitTime + 0.2
    end
    
    -- ===== COLOCAR SEGUNDO RAFFLESIA (PATH 2) =====
    print("[DOJO] Placing Rafflesia 2 (Path 2)...")
    while getMoney() < 1250 do task.wait(0.2) end
    
    for attempt = 1, 5 do
        local placementData = getRandomPositionPath2()
        
        local success = pcall(function()
            ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("PlaceUnit"):InvokeServer("unit_rafflesia", placementData)
        end)
        
        if success then 
            print("[DOJO] ✓ Placed Rafflesia 2")
            break 
        end
        task.wait(0.15)
    end
    task.wait(0.3)
    
    waitTime = 0
    while #myUnitIDs < 2 and waitTime < 10 do
        task.wait(0.2)
        waitTime = waitTime + 0.2
    end
    
    if #myUnitIDs < 2 then
        trackingEnabled = false
        childAddedConnection:Disconnect()
        warn("[DOJO] Failed to track both units!")
        return false
    end
    
    local raff1ID = myUnitIDs[1]
    local raff2ID = myUnitIDs[2]
    
    print("[DOJO] raff1ID: " .. tostring(raff1ID))
    print("[DOJO] raff2ID: " .. tostring(raff2ID))
    
    -- ===== UPGRADES: Ambas Rafflesias a máximo (8000 cada una) =====
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
    local checkCount = 0
    
    while not wave10Detected and getgenv().AutoFarmConfig.DojoActive do
        checkCount = checkCount + 1
        
        pcall(function()
            -- Intentar GameGuiNoInset primero
            local gui = PlayerGui:FindFirstChild("GameGuiNoInset")
            if gui then
                for _, obj in pairs(gui:GetDescendants()) do
                    if obj:IsA("TextLabel") and obj.Visible and obj.Name == "Title" then
                        local text = obj.Text
                        -- Patrón más estricto: "Wave X" o "Wave X/Y"
                        local waveNum = string.match(text, "^Wave%s*(%d+)")
                        if not waveNum then
                            waveNum = string.match(text, "Wave%s*(%d+)%s*/")
                        end
                        
                        if waveNum then
                            local newWave = tonumber(waveNum)
                            
                            -- Solo actualizar si cambió
                            if newWave and newWave ~= currentWave then
                                currentWave = newWave
                                print("[DOJO] Wave detected: " .. currentWave .. " (from: '" .. text .. "')")
                                
                                if currentWave >= 10 then
                                    print("[DOJO] ✓✓✓ WAVE 10 REACHED! PREPARING TO SELL ✓✓✓")
                                    wave10Detected = true
                                    return
                                end
                            end
                        end
                    end
                end
            end
            
            -- Si no encontró, intentar GameGui
            if not wave10Detected then
                gui = PlayerGui:FindFirstChild("GameGui")
                if gui then
                    for _, obj in pairs(gui:GetDescendants()) do
                        if obj:IsA("TextLabel") and obj.Visible and obj.Name == "Title" then
                            local text = obj.Text
                            -- Patrón más estricto: "Wave X" o "Wave X/Y"
                            local waveNum = string.match(text, "^Wave%s*(%d+)")
                            if not waveNum then
                                waveNum = string.match(text, "Wave%s*(%d+)%s*/")
                            end
                            
                            if waveNum then
                                local newWave = tonumber(waveNum)
                                
                                if newWave and newWave ~= currentWave then
                                    currentWave = newWave
                                    print("[DOJO] Wave detected: " .. currentWave .. " (from: '" .. text .. "')")
                                    
                                    if currentWave >= 10 then
                                        print("[DOJO] ✓✓✓ WAVE 10 REACHED! PREPARING TO SELL ✓✓✓")
                                        wave10Detected = true
                                        return
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
        
        -- Debug cada 10 checks
        if checkCount % 10 == 0 then
            print("[DOJO] Still waiting for Wave 10... Current: " .. currentWave .. " (check #" .. checkCount .. ")")
        end
        
        if wave10Detected then 
            print("[DOJO] Breaking wave detection loop...")
            break 
        end
        
        task.wait(0.5)
    end
    
    if not getgenv().AutoFarmConfig.DojoActive then
        print("[DOJO] Farm stopped before reaching Wave 10")
        trackingEnabled = false
        if childAddedConnection then
            childAddedConnection:Disconnect()
        end
        return false
    end
    
    if not wave10Detected then
        warn("[DOJO] Wave 10 detection failed after " .. checkCount .. " checks")
        trackingEnabled = false
        if childAddedConnection then
            childAddedConnection:Disconnect()
        end
        return false
    end
    
    print("[DOJO] ========== WAVE 10 REACHED - STARTING SELL PROCESS ==========")
    print("[DOJO] raff1ID value: " .. tostring(raff1ID) .. " (type: " .. type(raff1ID) .. ")")
    print("[DOJO] raff2ID value: " .. tostring(raff2ID) .. " (type: " .. type(raff2ID) .. ")")
    
    -- ===== VENDER CON DELAY CORTO =====
    local randomDelay = 0.3 + (math.random() * 0.3)
    print("[DOJO] Waiting " .. string.format("%.2f", randomDelay) .. " seconds before selling...")
    task.wait(randomDelay)
    
    print("[DOJO] Attempting to sell raff1 (ID: " .. tostring(raff1ID) .. ")...")
    local success1, err1 = pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("SellUnit"):InvokeServer(raff1ID)
    end)
    print("[DOJO] Sell raff1 result: " .. tostring(success1))
    if not success1 then
        warn("[DOJO] Sell raff1 ERROR: " .. tostring(err1))
    end
    
    task.wait(0.05)
    
    print("[DOJO] Attempting to sell raff2 (ID: " .. tostring(raff2ID) .. ")...")
    local success2, err2 = pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("SellUnit"):InvokeServer(raff2ID)
    end)
    print("[DOJO] Sell raff2 result: " .. tostring(success2))
    if not success2 then
        warn("[DOJO] Sell raff2 ERROR: " .. tostring(err2))
    end
    
    print("[DOJO] ========== SELL PROCESS COMPLETE ==========")
    
    -- Limpiar tracking
    trackingEnabled = false
    if childAddedConnection then
        childAddedConnection:Disconnect()
    end
    
    print("[DOJO] Strategy complete! All actions finished.")
    
    return true
end

-- ==================== AUTO FARM LOOP MANAGER ====================
local function startAutoFarmLoop(strategyFunction, strategyName)
    task.spawn(function()
        print("[AUTO FARM LOOP] ========== STARTING " .. strategyName .. " LOOP ==========")
        
        -- Determinar dificultad según estrategia
        local difficulty = "dif_impossible"
        local difficultyName = "Impossible"
        
        if strategyName == "Dojo" then
            difficulty = "dif_apocalypse"
            difficultyName = "Apocalypse"
        end
        
        -- Primera run: Activar todos los toggles SOLO SI NO ESTÁN ACTIVOS
        print("[AUTO FARM LOOP] First run - Checking toggles...")
        
        task.wait(1)
        
        -- ✅ AUTO SKIP: Solo activar si NO está activo
        if not getgenv().MainTabConfig.AutoSkip then
            if getgenv().MainTabToggles.AutoSkip then
                print("[AUTO FARM LOOP] ✓ Activating Auto Skip...")
                getgenv().MainTabToggles.AutoSkip:Set(true)
            end
        else
            print("[AUTO FARM LOOP] ℹ️ Auto Skip already active - skipping")
        end
        
        -- ✅ AUTO PLAY AGAIN: Solo activar si NO está activo
        if not getgenv().MainTabConfig.AutoPlayAgain then
            if getgenv().MainTabToggles.AutoPlayAgain then
                print("[AUTO FARM LOOP] ✓ Activating Auto Play Again...")
                getgenv().MainTabToggles.AutoPlayAgain:Set(true)
            end
        else
            print("[AUTO FARM LOOP] ℹ️ Auto Play Again already active - skipping")
        end
        
        -- ✅ ANTI-AFK: Solo cargar y activar si NO está activo
        if not getgenv().AntiBanConfig.AntiAFKEnabled then
            if not getgenv().AntiBanConfig.AntiAFKLoaded then
                print("[AUTO FARM LOOP] ⚙️ Loading Anti-AFK...")
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))()
                    getgenv().AntiBanConfig.AntiAFKLoaded = true
                    print("[AUTO FARM LOOP] ✅ Anti-AFK loaded!")
                end)
            end
            
            getgenv().AntiBanConfig.AntiAFKEnabled = true
            if getgenv().AntiBanToggles.AntiAFK then
                getgenv().AntiBanToggles.AntiAFK:Set(true)
            end
            print("[AUTO FARM LOOP] ✓ Anti-AFK enabled")
        else
            print("[AUTO FARM LOOP] ℹ️ Anti-AFK already enabled - skipping")
        end
        
        -- ✅ AUTO DIFFICULTY: Solo configurar y activar si NO está activo
        -- Determinar dificultad según estrategia
        local difficulty = "dif_impossible"
        local difficultyName = "Impossible"
        
        if strategyName == "Dojo" then
            difficulty = "dif_apocalypse"
            difficultyName = "Apocalypse"
        end
        
        print("[AUTO FARM LOOP] ✓ Setting " .. difficultyName .. " difficulty...")
        getgenv().MainTabConfig.SelectedDifficultyName = difficultyName
        getgenv().MainTabConfig.SelectedDifficulty = difficulty
        
        if not getgenv().MainTabConfig.AutoDifficulty then
            if getgenv().MainTabToggles.AutoDifficulty then
                print("[AUTO FARM LOOP] ✓ Activating Auto Difficulty...")
                getgenv().MainTabToggles.AutoDifficulty:Set(true)
            end
        else
            print("[AUTO FARM LOOP] ℹ️ Auto Difficulty already active - skipping")
        end
        
        task.wait(1)
        
        pcall(function()
            local args = { difficulty }
            game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(unpack(args))
            print("[AUTO FARM LOOP] ✓ Voted for " .. difficultyName .. " difficulty")
        end)
        
        print("[AUTO FARM LOOP] ========== EXECUTING FIRST MACRO ==========")
        
        -- EJECUTAR PRIMERA VEZ
        strategyFunction()
        getgenv().AutoFarmConfig.MatchesPlayed = getgenv().AutoFarmConfig.MatchesPlayed + 1
        print("[AUTO FARM LOOP] ✓ First macro complete! Match count: " .. getgenv().AutoFarmConfig.MatchesPlayed)
        
        -- ✅ VERIFICAR SI ESTE FUE EL ÚLTIMO MATCH
        if getgenv().AntiBanConfig.AutoReturnEnabled and 
           getgenv().AntiBanConfig.MatchesBeforeReturn > 0 and 
           getgenv().AutoFarmConfig.MatchesPlayed >= getgenv().AntiBanConfig.MatchesBeforeReturn then
            
            print("[AUTO FARM LOOP] 🚨 MATCH LIMIT REACHED - DISABLING AUTO PLAY AGAIN NOW 🚨")
            getgenv().MainTabConfig.AutoPlayAgain = false
            if getgenv().MainTabToggles and getgenv().MainTabToggles.AutoPlayAgain then
                getgenv().MainTabToggles.AutoPlayAgain:Set(false)
            end
        end
        
        -- LOOP INFINITO
        while getgenv().AutoFarmConfig.IsRunning do
            print("[AUTO FARM LOOP] ========== WAITING FOR GAME END ==========")
            local gameEnded = false
            
            -- Esperar a que termine el juego
            while not gameEnded and getgenv().AutoFarmConfig.IsRunning do
                pcall(function()
                    local gui = PlayerGui:FindFirstChild("GameGui")
                    if gui then
                        local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                        if endFrame and endFrame.Visible then
                            gameEnded = true
                            print("[AUTO FARM LOOP] ✓ Game End screen detected!")
                        end
                    end
                end)
                task.wait(0.5)
            end
            
            if not getgenv().AutoFarmConfig.IsRunning then 
                print("[AUTO FARM LOOP] Farm stopped by user")
                break 
            end
            
            print("[AUTO FARM LOOP] Game ended - Match #" .. getgenv().AutoFarmConfig.MatchesPlayed .. " complete")
            
            -- ✅ VERIFICAR SI LLEGÓ AL LÍMITE DE MATCHES
            if getgenv().AntiBanConfig.AutoReturnEnabled and 
               getgenv().AntiBanConfig.MatchesBeforeReturn > 0 and 
               getgenv().AutoFarmConfig.MatchesPlayed >= getgenv().AntiBanConfig.MatchesBeforeReturn then
                
                print("[AUTO FARM LOOP] ========== MATCH LIMIT REACHED ==========")
                print("[AUTO FARM LOOP] Matches played: " .. getgenv().AutoFarmConfig.MatchesPlayed .. "/" .. getgenv().AntiBanConfig.MatchesBeforeReturn)
                print("[AUTO FARM LOOP] ========== PROCEEDING WITH RETURN TO LOBBY ==========")
                
                -- ✅ ESPERAR 3 SEGUNDOS PARA QUE LA PANTALLA SE ESTABILICE
                print("[AUTO FARM LOOP] Waiting 3 seconds for Game End screen to stabilize...")
                task.wait(3)
                
                -- ✅ BUSCAR Y HACER CLIC EN "RETURN TO LOBBY" (MÉTODO MEJORADO)
                print("[AUTO FARM LOOP] Starting Return to Lobby button search...")
                local returnClicked = false
                
                -- Método 1: Buscar por texto exacto "Return to lobby"
                print("[AUTO FARM LOOP] Method 1: Searching by exact text...")
                for attempt = 1, 10 do
                    if returnClicked then break end
                    
                    pcall(function()
                        local gui = PlayerGui:FindFirstChild("GameGui")
                        if gui then
                            for _, button in pairs(gui:GetDescendants()) do
                                if button:IsA("TextButton") and button.Visible then
                                    local text = string.lower(button.Text)
                                    
                                    if text == "return to lobby" then
                                        print("[AUTO FARM LOOP] ✓ Found exact match: '" .. button.Text .. "'")
                                        
                                        local conns = getconnections(button.MouseButton1Click)
                                        if conns and #conns > 0 then
                                            conns[1]:Fire()
                                            returnClicked = true
                                            print("[AUTO FARM LOOP] ✅ Method 1 SUCCESS!")
                                            return
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    
                    if not returnClicked then task.wait(0.5) end
                end
                
                -- Método 2: Buscar por posición (botón derecho)
                if not returnClicked then
                    print("[AUTO FARM LOOP] Method 2: Searching by position (rightmost button)...")
                    
                    pcall(function()
                        local gui = PlayerGui:FindFirstChild("GameGui")
                        if gui then
                            local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                            if endFrame then
                                local buttons = {}
                                
                                for _, btn in pairs(endFrame:GetDescendants()) do
                                    if btn:IsA("TextButton") and btn.Visible and btn.Text ~= "" then
                                        table.insert(buttons, {
                                            btn = btn,
                                            text = btn.Text,
                                            posX = btn.AbsolutePosition.X
                                        })
                                        print("[METHOD 2] Found: '" .. btn.Text .. "' at X=" .. btn.AbsolutePosition.X)
                                    end
                                end
                                
                                table.sort(buttons, function(a, b)
                                    return a.posX > b.posX
                                end)
                                
                                if #buttons >= 1 then
                                    local rightButton = buttons[1].btn
                                    print("[AUTO FARM LOOP] Clicking rightmost button: '" .. rightButton.Text .. "'")
                                    
                                    local conns = getconnections(rightButton.MouseButton1Click)
                                    if conns and #conns > 0 then
                                        conns[1]:Fire()
                                        returnClicked = true
                                        print("[AUTO FARM LOOP] ✅ Method 2 SUCCESS!")
                                    end
                                end
                            end
                        end
                    end)
                end
                
                -- Método 3: RemoteFunction directa
                if not returnClicked then
                    print("[AUTO FARM LOOP] Method 3: Using BackToMainLobby RemoteFunction...")
                    
                    local remoteSuccess = pcall(function()
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("BackToMainLobby"):InvokeServer()
                    end)
                    
                    if remoteSuccess then
                        returnClicked = true
                        print("[AUTO FARM LOOP] ✅ Method 3 SUCCESS!")
                    else
                        warn("[AUTO FARM LOOP] ✗ Method 3 FAILED")
                    end
                end
                
                -- ✅ RESULTADO FINAL
                if returnClicked then
                    print("[AUTO FARM LOOP] ✅✅✅ RETURN TO LOBBY SUCCESSFUL! ✅✅✅")
                    print("[AUTO FARM LOOP] Waiting 10 seconds for lobby transition...")
                    task.wait(10)
                else
                    warn("[AUTO FARM LOOP] ✗✗✗ ALL METHODS FAILED ✗✗✗")
                    task.wait(1)
                end
                
                -- ✅ DETENER FARM Y LIMPIAR TODO
                print("[AUTO FARM LOOP] Stopping farm and cleaning up...")
                
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
                
                getgenv().AutoFarmConfig.IsRunning = false
                getgenv().AutoFarmConfig.GraveyardV1Active = false
                getgenv().AutoFarmConfig.GraveyardV2Active = false
                getgenv().AutoFarmConfig.DojoActive = false
                getgenv().AutoFarmConfig.FirstRunComplete = false
                getgenv().AutoFarmConfig.MatchesPlayed = 0
                
                getgenv().NoahHubLocked = false
                
                WindUI:Notify({
                    Title = "✅ Auto Farm Completed",
                    Content = returnClicked and "Returned to lobby after " .. getgenv().AntiBanConfig.MatchesBeforeReturn .. " matches" or "Farm stopped - Please return to lobby manually",
                    Duration = 5
                })
                
                print("[AUTO FARM LOOP] ========== FARM STOPPED SUCCESSFULLY ==========")
                print("[NOAH HUB] Script unlocked - ready for re-execution")
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
                            print("[AUTO FARM LOOP] ✓ New game started!")
                        end
                    end
                end)
                task.wait(0.5)
                waitTime = waitTime + 0.5
            end
            
            if not newGameStarted then
                warn("[AUTO FARM LOOP] Failed to detect new game start - stopping")
                break
            end
            
            task.wait(2)
            
            -- Votar dificultad de nuevo
            print("[AUTO FARM LOOP] ========== VOTING DIFFICULTY FOR MATCH #" .. (getgenv().AutoFarmConfig.MatchesPlayed + 1) .. " ==========")
            pcall(function()
                local args = { difficulty }
                game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(unpack(args))
                print("[AUTO FARM LOOP] ✓ Voted for " .. difficultyName .. " difficulty")
            end)
            
            task.wait(1)
            
            -- EJECUTAR EL MACRO DE NUEVO
            print("[AUTO FARM LOOP] ========== EXECUTING MACRO FOR MATCH #" .. (getgenv().AutoFarmConfig.MatchesPlayed + 1) .. " ==========")
            strategyFunction()
            
            getgenv().AutoFarmConfig.MatchesPlayed = getgenv().AutoFarmConfig.MatchesPlayed + 1
            print("[AUTO FARM LOOP] ✓ Macro complete! Match count: " .. getgenv().AutoFarmConfig.MatchesPlayed)
            
            -- ✅ VERIFICAR SI ESTE FUE EL ÚLTIMO MATCH (DESACTIVAR AUTO PLAY AGAIN AHORA)
            if getgenv().AntiBanConfig.AutoReturnEnabled and 
               getgenv().AntiBanConfig.MatchesBeforeReturn > 0 and 
               getgenv().AutoFarmConfig.MatchesPlayed >= getgenv().AntiBanConfig.MatchesBeforeReturn then
                
                print("[AUTO FARM LOOP] 🚨 MATCH LIMIT REACHED - DISABLING AUTO PLAY AGAIN NOW 🚨")
                getgenv().MainTabConfig.AutoPlayAgain = false
                if getgenv().MainTabToggles and getgenv().MainTabToggles.AutoPlayAgain then
                    getgenv().MainTabToggles.AutoPlayAgain:Set(false)
                end
            end
        end
        
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
        Desc = "Rainbow Tomato & Earth Dragon strategy",
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
                        task.wait(0.3)
                        
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
    
    local DojoToggle = AutoFarmTab:Toggle({
        Flag = "Dojo",
        Title = "Dojo",
        Desc = "Rafflesia strategy (Apocalypse difficulty)",
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
                        task.wait(0.3)
                        
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
    
    local WebhookInput = WebhookTab:Input({
        Flag = "WebhookURL",
        Title = "Webhook Link",
        Desc = "Discord Webhook URL",
        Type = "Input",
        Value = getgenv().WebhookConfig.URL,
        Placeholder = "https://discord.com/api/webhooks/...",
        Callback = function(input)
            getgenv().WebhookConfig.URL = input
            saveWebhookConfig()  -- ✅ GUARDAR AUTOMÁTICAMENTE
            
            if input ~= "" then
                WebhookInput:Highlight()
                WindUI:Notify({
                    Title = "Webhook Saved",
                    Content = "Webhook URL saved permanently!",
                    Duration = 2
                })
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
    
    local WebhookToggle = WebhookTab:Toggle({
        Flag = "EnableWebhook",
        Title = "Enable Webhook",
        Default = getgenv().WebhookConfig.Enabled,
        Callback = function(state)
            getgenv().WebhookConfig.Enabled = state
            saveWebhookConfig()  -- ✅ GUARDAR AUTOMÁTICAMENTE
            
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
