-- ==================== WEBHOOK TESTER INDEPENDIENTE ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")

print("=== WEBHOOK TESTER LOADED ===")
print("Press F1 to test webhook detection")
print("Press F2 to send test webhook")
print("================================")

-- ==================== CONFIGURACIÓN ====================
local WEBHOOK_URL = "https://discord.com/api/webhooks/1427401416691154946/oCV4MaZpJcQHmcuID8GObO8Rr5rG775zxShpy30RyA6-69LkmlJQYWwC2Ax0T7LwZE5P"  -- ⚠️ PEGA TU WEBHOOK AQUÍ

-- ==================== FUNCIONES DE DETECCIÓN ====================
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

local function getPresentsFromScreen()
    local success, result = pcall(function()
        local gui = PlayerGui:FindFirstChild("GameGui")
        if not gui then return "N/A" end
        
        -- ✅ Buscar ChristmasGiftsDisplay (nombre actual)
        local presentsDisplay = gui:FindFirstChild("ChristmasGiftsDisplay", true)
        
        if presentsDisplay then
            local titleLabel = presentsDisplay:FindFirstChild("Title")
            if titleLabel and titleLabel:IsA("TextLabel") then
                local num = titleLabel.Text:match("(%d+)")
                if num then return num end
            end
        end
        
        -- Fallback: CandyCornsDisplay (evento pasado)
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
    print("[TEST] Scanning for game result...")
    
    -- Buscar en TODOS los TextLabels visibles
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local txt = obj.Text
            local txtLower = txt:lower()
            
            print("[TEST] Checking label: " .. txt)
            
            -- Detectar derrota
            if txtLower == "defeat" or 
               txtLower:find("overwhelmed") or 
               txtLower:find("been overwhelmed") then
                print("[TEST] ✅ DEFEAT DETECTED!")
                return "Defeat"
            end
            
            -- Detectar victoria
            if txtLower == "victory" or 
               txtLower:find("cleared") or 
               txtLower:find("you win") then
                print("[TEST] ✅ VICTORY DETECTED!")
                return "Victory"
            end
        end
    end
    
    -- Fallback: Buscar por nombre "Title"
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Name == "Title" and obj.Visible then
            if obj.Text == "Defeat" then 
                print("[TEST] ✅ DEFEAT DETECTED (by Title)!")
                return "Defeat" 
            end
            if obj.Text == "Victory" then 
                print("[TEST] ✅ VICTORY DETECTED (by Title)!")
                return "Victory" 
            end
        end
    end
    
    print("[TEST] ⚠️ No result detected (Unknown)")
    return "Unknown"
end

local function getRunTime(endFrame)
    print("[TEST] Scanning for run time...")
    
    -- Buscar en TODO el endFrame
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local txt = obj.Text
            local txtLower = txt:lower()
            
            if txtLower:find("run") then
                print("[TEST] Found label with 'run': " .. txt)
            end
            
            if txtLower:find("run time") then
                print("[TEST] ✅ Found 'Run time' label: " .. txt)
                
                -- Intentar formato "M:SS"
                local timeMatch = txt:match("(%d+:%d+)")
                if timeMatch then
                    print("[TEST] ✅ Captured formatted time: " .. timeMatch)
                    return timeMatch
                end
                
                -- Buscar solo números (ej: "Run time: 24")
                local secsMatch = txt:match("[Rr]un%s+[Tt]ime[:%s]*(%d+)")
                if secsMatch then
                    print("[TEST] Captured seconds: " .. secsMatch)
                    local secs = tonumber(secsMatch)
                    if secs and secs < 3600 then
                        local minutes = math.floor(secs / 60)
                        local seconds = secs % 60
                        local formatted = string.format("%d:%02d", minutes, seconds)
                        print("[TEST] ✅ Formatted time: " .. formatted)
                        return formatted
                    end
                end
            end
        end
    end
    
    print("[TEST] ⚠️ No run time found (N/A)")
    return "N/A"
end

local function sendTestWebhook(endFrame)
    if WEBHOOK_URL == "" then
        warn("[TEST] ⚠️ NO WEBHOOK URL CONFIGURED!")
        print("Please set WEBHOOK_URL at the top of the script")
        return false
    end
    
    local success, err = pcall(function()
        local time = os.date("%Y-%m-%d %H:%M:%S")
        local seeds = getSeedsFromScreen()
        local presents = getPresentsFromScreen()
        
        local result = "Unknown"
        local runTime = "N/A"
        
        if endFrame then
            result = getGameResult(endFrame)
            runTime = getRunTime(endFrame)
        end
        
        print("\n=== WEBHOOK DATA ===")
        print("Seeds: " .. seeds)
        print("Presents: " .. presents)
        print("Result: " .. result)
        print("Run Time: " .. runTime)
        print("===================\n")
        
        local color = result == "Victory" and 3066993 or (result == "Unknown" and 16776960 or 15158332)
        
        local userName = "||" .. LocalPlayer.Name .. "||"
        
        local description = string.format(
            "**TEST WEBHOOK - Garden Tower Defense**\n\n" ..
            "**User:** %s\n\n" ..
            "**Stats**\n" ..
            "🌱 Seeds: %s\n" ..
            "🎁 Presents: %s\n\n" ..
            "**Match Results**\n" ..
            "%s\n" ..
            "⏱️ Run Time: %s\n\n" ..
            "*This is a test webhook*",
            userName,
            seeds,
            presents,
            result,
            runTime
        )
        
        local data = {
            embeds = {{
                color = color,
                description = description,
                footer = {text = "Webhook Tester | " .. time}
            }}
        }
        
        local jsonData = HttpService:JSONEncode(data)
        
        local response = request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
        
        print("[TEST] ✅ Webhook sent successfully!")
        print("[TEST] Response code: " .. tostring(response.StatusCode))
    end)
    
    if not success then
        warn("[TEST] ❌ Webhook failed: " .. tostring(err))
        return false
    end
    
    return true
end

-- ==================== DETECCIÓN AUTOMÁTICA ====================
local function startAutoDetection()
    print("[TEST] Auto-detection started (monitoring GameEnd frame)")
    
    task.spawn(function()
        local lastState = false
        
        while task.wait(0.3) do
            pcall(function()
                local gui = PlayerGui:FindFirstChild("GameGui")
                if not gui then return end
                
                local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                if not endFrame then return end
                
                local currentState = endFrame.Visible
                
                -- Detectar cambio: invisible → visible
                if not lastState and currentState then
                    print("\n[TEST] 🚨 GAME END FRAME DETECTED! 🚨")
                    task.wait(1.5)  -- Esperar que cargue el contenido
                    
                    if endFrame.Visible then
                        print("[TEST] Analyzing end screen...")
                        sendTestWebhook(endFrame)
                    end
                end
                
                lastState = currentState
            end)
        end
    end)
end

-- ==================== COMANDOS DE TECLADO ====================
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        print("\n[TEST] === MANUAL TEST (F1) ===")
        
        local gui = PlayerGui:FindFirstChild("GameGui")
        if not gui then
            warn("[TEST] GameGui not found!")
            return
        end
        
        local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
        if not endFrame then
            warn("[TEST] GameEnd frame not found!")
            return
        end
        
        if not endFrame.Visible then
            warn("[TEST] GameEnd frame is not visible!")
            print("[TEST] Waiting for game to end...")
            return
        end
        
        print("[TEST] GameEnd frame found and visible!")
        sendTestWebhook(endFrame)
        
    elseif input.KeyCode == Enum.KeyCode.F2 then
        print("\n[TEST] === SENDING TEST WEBHOOK (F2) ===")
        sendTestWebhook(nil)
    end
end)

-- ==================== INICIAR ====================
startAutoDetection()

print("\n=== CONTROLS ===")
print("F1 = Test detection on current GameEnd screen")
print("F2 = Send test webhook (no game data)")
print("================\n")
