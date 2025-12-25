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

-- ==================== PERFORMANCE MODE CONFIG ====================
getgenv().PerformanceConfig = getgenv().PerformanceConfig or {
    RenderStopped = false,
    BlackScreenEnabled = false,
    BlackScreenGui = nil
}

-- ==================== BLACK SCREEN FUNCTIONS ====================
local function createBlackScreen()
    if getgenv().PerformanceConfig.BlackScreenGui then
        return -- Ya existe
    end
    
    local success = pcall(function()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "NoahHubBlackScreen"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.DisplayOrder = 999999
        ScreenGui.IgnoreGuiInset = true -- ✅ CUBRE TODO, incluso el topbar
        
        local BlackFrame = Instance.new("Frame")
        BlackFrame.Name = "BlackFrame"
        BlackFrame.Size = UDim2.new(1, 0, 1, 0)
        BlackFrame.Position = UDim2.new(0, 0, 0, 0)
        BlackFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        BlackFrame.BackgroundTransparency = 0 -- ✅ 100% opaco
        BlackFrame.BorderSizePixel = 0
        BlackFrame.ZIndex = 10 -- ✅ Arriba de todo
        BlackFrame.Parent = ScreenGui
        
        ScreenGui.Parent = PlayerGui
        
        getgenv().PerformanceConfig.BlackScreenGui = ScreenGui
        print("[BLACK SCREEN] ✅ Created successfully (Full Screen)")
    end)
    
    if not success then
        warn("[BLACK SCREEN] Failed to create")
    end
end

local function removeBlackScreen()
    if getgenv().PerformanceConfig.BlackScreenGui then
        pcall(function()
            getgenv().PerformanceConfig.BlackScreenGui:Destroy()
            getgenv().PerformanceConfig.BlackScreenGui = nil
            print("[BLACK SCREEN] ✅ Removed successfully")
        end)
    end
end

-- ==================== LOW GRAPHICS MODE CONFIG ====================
getgenv().LowGraphicsConfig = getgenv().LowGraphicsConfig or {
    Enabled = false,
    OriginalSettings = {},
    RemovedObjects = {}
}

-- ==================== FUNCIONES LOW GRAPHICS MODE ====================
local function saveLightingSettings()
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")
    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    
    -- ✅ GUARDAR RENDER DISTANCE ANTES DE CUALQUIER OTRA COSA
    local currentQuality = settings().Rendering.QualityLevel
    print("[LOW GRAPHICS] 📊 Current Quality Level: " .. tostring(currentQuality))
    
    getgenv().LowGraphicsConfig.OriginalSettings = {
        -- Lighting
        Brightness = Lighting.Brightness,
        GlobalShadows = Lighting.GlobalShadows,
        Technology = Lighting.Technology,
        
        -- Terrain Water
        WaterReflectance = terrain and terrain.WaterReflectance or 1,
        WaterTransparency = terrain and terrain.WaterTransparency or 0.3,
        WaterWaveSize = terrain and terrain.WaterWaveSize or 0.15,
        WaterWaveSpeed = terrain and terrain.WaterWaveSpeed or 10,
        
        -- ✅ GUARDAR RENDER DISTANCE ORIGINAL
        RenderDistance = currentQuality,
        
        -- Effects
        PostEffects = {}
    }
    
    print("[LOW GRAPHICS] ✓ Saved Quality Level: " .. tostring(getgenv().LowGraphicsConfig.OriginalSettings.RenderDistance))
    
    -- ✅ GUARDAR EFECTOS CON TODAS SUS PROPIEDADES
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Sky") or effect:IsA("Clouds") then
            local savedEffect = {
                Object = effect,
                Type = effect.ClassName,
                Enabled = effect:IsA("PostEffect") and effect.Enabled or true
            }
            
            -- ✅ GUARDAR PROPIEDADES ESPECÍFICAS DE CADA TIPO
            if effect:IsA("ColorCorrectionEffect") then
                savedEffect.Brightness = effect.Brightness
                savedEffect.Contrast = effect.Contrast
                savedEffect.Saturation = effect.Saturation
                savedEffect.TintColor = effect.TintColor
            elseif effect:IsA("BloomEffect") then
                savedEffect.Intensity = effect.Intensity
                savedEffect.Size = effect.Size
                savedEffect.Threshold = effect.Threshold
            elseif effect:IsA("SunRaysEffect") then
                savedEffect.Intensity = effect.Intensity
                savedEffect.Spread = effect.Spread
            elseif effect:IsA("BlurEffect") then
                savedEffect.Size = effect.Size
            elseif effect:IsA("Atmosphere") then
                savedEffect.Density = effect.Density
                savedEffect.Offset = effect.Offset
                savedEffect.Color = effect.Color
                savedEffect.Decay = effect.Decay
                savedEffect.Glare = effect.Glare
                savedEffect.Haze = effect.Haze
            elseif effect:IsA("Sky") then
                savedEffect.SkyboxBk = effect.SkyboxBk
                savedEffect.SkyboxDn = effect.SkyboxDn
                savedEffect.SkyboxFt = effect.SkyboxFt
                savedEffect.SkyboxLf = effect.SkyboxLf
                savedEffect.SkyboxRt = effect.SkyboxRt
                savedEffect.SkyboxUp = effect.SkyboxUp
            elseif effect:IsA("Clouds") then
                savedEffect.Cover = effect.Cover
                savedEffect.Density = effect.Density
                savedEffect.Color = effect.Color
            end
            
            table.insert(getgenv().LowGraphicsConfig.OriginalSettings.PostEffects, savedEffect)
        end
    end
    
    print("[LOW GRAPHICS] ✓ Saved " .. #getgenv().LowGraphicsConfig.OriginalSettings.PostEffects .. " lighting effects")
end

local function enableLowGraphics()
    pcall(function()
        local Lighting = game:GetService("Lighting")
        local Workspace = game:GetService("Workspace")
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        
        print("[LOW GRAPHICS] 🎨 Applying optimizations...")
        
-- 1. OPTIMIZAR LIGHTING
Lighting.Brightness = 2
Lighting.GlobalShadows = false
Lighting.Technology = Enum.Technology.Legacy

-- ✅ REDUCIR RENDER DISTANCE (Quality Level)
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
print("[LOW GRAPHICS] ✓ Render distance set to minimum (Level 1)")

        
        -- 2. DESACTIVAR POST EFFECTS
        local effectsDisabled = 0
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
                effectsDisabled = effectsDisabled + 1
            elseif effect:IsA("Atmosphere") then
                effect.Density = 0
                effect.Offset = 0
                effectsDisabled = effectsDisabled + 1
            elseif effect:IsA("Sky") then
                effect.Parent = nil
                getgenv().LowGraphicsConfig.RemovedObjects[#getgenv().LowGraphicsConfig.RemovedObjects + 1] = {
                    Object = effect,
                    OriginalParent = Lighting
                }
                effectsDisabled = effectsDisabled + 1
            elseif effect:IsA("Clouds") then
                effect.Parent = nil
                getgenv().LowGraphicsConfig.RemovedObjects[#getgenv().LowGraphicsConfig.RemovedObjects + 1] = {
                    Object = effect,
                    OriginalParent = Lighting
                }
                effectsDisabled = effectsDisabled + 1
            end
        end
        print("[LOW GRAPHICS] ✓ Disabled " .. effectsDisabled .. " post effects")
        
        -- 3. OPTIMIZAR TERRAIN WATER
        if terrain then
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            print("[LOW GRAPHICS] ✓ Water effects disabled")
        end
        
        -- 4. ELIMINAR TEXTURAS DECORATIVAS
        local texturesRemoved = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                -- Solo eliminar si NO está en Entities (unidades del juego)
                if not obj:FindFirstAncestorOfClass("Folder") or obj:FindFirstAncestorOfClass("Folder").Name ~= "Entities" then
                    obj.Parent = nil
                    getgenv().LowGraphicsConfig.RemovedObjects[#getgenv().LowGraphicsConfig.RemovedObjects + 1] = {
                        Object = obj,
                        OriginalParent = obj.Parent
                    }
                    texturesRemoved = texturesRemoved + 1
                end
            end
        end
        print("[LOW GRAPHICS] ✓ Removed " .. texturesRemoved .. " textures")
        
-- 5. OPTIMIZAR MATERIALES PESADOS (con backup)
local materialsOptimized = 0
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") then
        -- Solo optimizar si NO está en Entities
        if not obj:FindFirstAncestorOfClass("Folder") or obj:FindFirstAncestorOfClass("Folder").Name ~= "Entities" then
            -- Convertir materiales pesados a SmoothPlastic
            if obj.Material == Enum.Material.Neon or 
               obj.Material == Enum.Material.Glass or
               obj.Material == Enum.Material.Ice or
               obj.Material == Enum.Material.ForceField then
                
                -- ✅ GUARDAR MATERIAL ORIGINAL
                table.insert(getgenv().LowGraphicsConfig.RemovedObjects, {
                    Object = obj,
                    OriginalMaterial = obj.Material,
                    OriginalReflectance = obj.Reflectance,
                    Type = "Material"
                })
                
                obj.Material = Enum.Material.SmoothPlastic
                materialsOptimized = materialsOptimized + 1
            end
            
            -- Eliminar reflectancia
            if obj.Reflectance > 0 then
                obj.Reflectance = 0
            end
        end
    end
end
print("[LOW GRAPHICS] ✓ Optimized " .. materialsOptimized .. " materials")
        
        -- 6. ELIMINAR DECORACIÓN DEL MAP (solo en partida)
        local mapDecorationRemoved = 0
        local mapFolder = Workspace:FindFirstChild("Map")
        if mapFolder then
            for _, obj in pairs(mapFolder:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
                    local name = obj.Name:lower()
                    -- Eliminar solo decoración, NO gameplay elements
                    if name:find("tree") or name:find("plant") or name:find("grass") or 
                       name:find("bush") or name:find("flower") or name:find("rock") or 
                       name:find("stone") or name:find("cloud") or name:find("decor") or 
                       name:find("prop") then
                        obj.Parent = nil
                        getgenv().LowGraphicsConfig.RemovedObjects[#getgenv().LowGraphicsConfig.RemovedObjects + 1] = {
                            Object = obj,
                            OriginalParent = obj.Parent
                        }
                        mapDecorationRemoved = mapDecorationRemoved + 1
                    end
                end
            end
            if mapDecorationRemoved > 0 then
                print("[LOW GRAPHICS] ✓ Removed " .. mapDecorationRemoved .. " map decorations")
            end
        end
        
        -- 7. DESACTIVAR PARTICLE EFFECTS
        local particlesDisabled = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                -- Solo desactivar si NO está en Entities
                if not obj:FindFirstAncestorOfClass("Folder") or obj:FindFirstAncestorOfClass("Folder").Name ~= "Entities" then
                    obj.Enabled = false
                    particlesDisabled = particlesDisabled + 1
                end
            end
        end
        if particlesDisabled > 0 then
            print("[LOW GRAPHICS] ✓ Disabled " .. particlesDisabled .. " particle effects")
        end
        
        print("[LOW GRAPHICS] ✅ All optimizations applied!")
    end)
end

local function restoreGraphics()
    pcall(function()
        print("[LOW GRAPHICS] 🔄 Restoring original settings...")
        
        local Lighting = game:GetService("Lighting")
        local Workspace = game:GetService("Workspace")
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        local savedSettings = getgenv().LowGraphicsConfig.OriginalSettings
        
        -- ✅ VERIFICAR QUE EXISTAN SETTINGS GUARDADOS
        if not savedSettings or not next(savedSettings) then
            warn("[LOW GRAPHICS] ⚠️ No saved settings found! Cannot restore.")
            WindUI:Notify({
                Title = "Restore Warning",
                Content = "No original settings found. Graphics may not restore properly.",
                Duration = 3
            })
            return
        end
        
        -- ✅ RESTAURAR LIGHTING (usando valores guardados)
        if savedSettings.Brightness then
            Lighting.Brightness = savedSettings.Brightness
        end
        if savedSettings.GlobalShadows ~= nil then
            Lighting.GlobalShadows = savedSettings.GlobalShadows
        end
        if savedSettings.Technology then
            Lighting.Technology = savedSettings.Technology
        end
        
        -- ✅ RESTAURAR RENDER DISTANCE ORIGINAL (CON DEBUG CORREGIDO)
        if savedSettings.RenderDistance then
            local currentQuality = settings().Rendering.QualityLevel
            print("[LOW GRAPHICS] 📊 Restoring Quality Level from: " .. tostring(currentQuality) .. " to: " .. tostring(savedSettings.RenderDistance))
            
            pcall(function()
                settings().Rendering.QualityLevel = savedSettings.RenderDistance
            end)
            
            task.wait(0.1)
            
            local newQuality = settings().Rendering.QualityLevel
            print("[LOW GRAPHICS] 📊 Quality Level after restore: " .. tostring(newQuality))
            
            if newQuality == savedSettings.RenderDistance then
                print("[LOW GRAPHICS] ✓ Render distance restored successfully!")
            else
                warn("[LOW GRAPHICS] ⚠️ Render distance may not have restored properly")
            end
        else
            warn("[LOW GRAPHICS] ⚠️ No RenderDistance saved!")
        end
        
        print("[LOW GRAPHICS] ✓ Lighting settings restored")
        
        -- ✅ RESTAURAR POST EFFECTS CON TODAS SUS PROPIEDADES
        local effectsRestored = 0
        for _, effectData in pairs(savedSettings.PostEffects or {}) do
            if effectData.Object then
                pcall(function()
                    -- Restaurar enabled
                    if effectData.Object:IsA("PostEffect") then
                        effectData.Object.Enabled = effectData.Enabled
                    end
                    
                    -- ✅ RESTAURAR PROPIEDADES ESPECÍFICAS
                    if effectData.Type == "ColorCorrectionEffect" then
                        effectData.Object.Brightness = effectData.Brightness or 0
                        effectData.Object.Contrast = effectData.Contrast or 0
                        effectData.Object.Saturation = effectData.Saturation or 0
                        effectData.Object.TintColor = effectData.TintColor or Color3.fromRGB(255, 255, 255)
                    elseif effectData.Type == "BloomEffect" then
                        effectData.Object.Intensity = effectData.Intensity or 1
                        effectData.Object.Size = effectData.Size or 24
                        effectData.Object.Threshold = effectData.Threshold or 2
                    elseif effectData.Type == "SunRaysEffect" then
                        effectData.Object.Intensity = effectData.Intensity or 0.25
                        effectData.Object.Spread = effectData.Spread or 1
                    elseif effectData.Type == "BlurEffect" then
                        effectData.Object.Size = effectData.Size or 24
                    elseif effectData.Type == "Atmosphere" then
                        effectData.Object.Density = effectData.Density or 0.3
                        effectData.Object.Offset = effectData.Offset or 0.25
                        effectData.Object.Color = effectData.Color or Color3.fromRGB(199, 199, 199)
                        effectData.Object.Decay = effectData.Decay or Color3.fromRGB(92, 60, 13)
                        effectData.Object.Glare = effectData.Glare or 0
                        effectData.Object.Haze = effectData.Haze or 0
                    elseif effectData.Type == "Sky" then
                        if effectData.SkyboxBk then effectData.Object.SkyboxBk = effectData.SkyboxBk end
                        if effectData.SkyboxDn then effectData.Object.SkyboxDn = effectData.SkyboxDn end
                        if effectData.SkyboxFt then effectData.Object.SkyboxFt = effectData.SkyboxFt end
                        if effectData.SkyboxLf then effectData.Object.SkyboxLf = effectData.SkyboxLf end
                        if effectData.SkyboxRt then effectData.Object.SkyboxRt = effectData.SkyboxRt end
                        if effectData.SkyboxUp then effectData.Object.SkyboxUp = effectData.SkyboxUp end
                    elseif effectData.Type == "Clouds" then
                        effectData.Object.Cover = effectData.Cover or 0.5
                        effectData.Object.Density = effectData.Density or 0.5
                        effectData.Object.Color = effectData.Color or Color3.fromRGB(255, 255, 255)
                    end
                    
                    effectsRestored = effectsRestored + 1
                end)
            end
        end
        print("[LOW GRAPHICS] ✓ Restored " .. effectsRestored .. " post effects with original properties")
        
        -- ✅ RESTAURAR TERRAIN WATER (usando valores guardados)
        if terrain and savedSettings.WaterReflectance then
            terrain.WaterReflectance = savedSettings.WaterReflectance
            terrain.WaterTransparency = savedSettings.WaterTransparency or 0.3
            terrain.WaterWaveSize = savedSettings.WaterWaveSize or 0.15
            terrain.WaterWaveSpeed = savedSettings.WaterWaveSpeed or 10
            print("[LOW GRAPHICS] ✓ Water effects restored")
        end
        
        -- ✅ RESTAURAR OBJETOS ELIMINADOS (Sky, Clouds, Texturas, Decoración)
        local objectsRestored = 0
        for _, data in pairs(getgenv().LowGraphicsConfig.RemovedObjects) do
            if data.Object and data.OriginalParent then
                pcall(function()
                    data.Object.Parent = data.OriginalParent
                    objectsRestored = objectsRestored + 1
                end)
            end
        end
        if objectsRestored > 0 then
            print("[LOW GRAPHICS] ✓ Restored " .. objectsRestored .. " removed objects")
        end
        
        -- ✅ RESTAURAR MATERIALES ORIGINALES
        local materialsRestored = 0
        for _, data in pairs(getgenv().LowGraphicsConfig.RemovedObjects) do
            if data.Type == "Material" and data.Object and data.OriginalMaterial then
                pcall(function()
                    data.Object.Material = data.OriginalMaterial
                    if data.OriginalReflectance then
                        data.Object.Reflectance = data.OriginalReflectance
                    end
                    materialsRestored = materialsRestored + 1
                end)
            end
        end
        if materialsRestored > 0 then
            print("[LOW GRAPHICS] ✓ Restored " .. materialsRestored .. " materials")
        end
        
        -- ✅ RESTAURAR PARTICLE EFFECTS (reactivar)
        local particlesRestored = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")) and not obj.Enabled then
                -- Solo reactivar si NO está en Entities
                if not obj:FindFirstAncestorOfClass("Folder") or obj:FindFirstAncestorOfClass("Folder").Name ~= "Entities" then
                    obj.Enabled = true
                    particlesRestored = particlesRestored + 1
                end
            end
        end
        if particlesRestored > 0 then
            print("[LOW GRAPHICS] ✓ Restored " .. particlesRestored .. " particle effects")
        end
        
        -- ✅ LIMPIAR TABLA DE OBJETOS ELIMINADOS
        getgenv().LowGraphicsConfig.RemovedObjects = {}
        
        print("[LOW GRAPHICS] ✅ Graphics restored to original!")
    end)
end

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
            print("[WEBHOOK] Loaded saved config: " .. (data.URL ~= "" and "✅ URL configured" or "⚠️ No URL"))
            -- ✅ SIEMPRE RESETEAR GamesPlayed A 0 AL CARGAR
            return {
                URL = data.URL or "",
                GamesPlayed = 0,  -- ❌ NUNCA CARGAR DESDE ARCHIVO
                IsTracking = false
            }
        end
    end
    
    return {
        URL = "",
        GamesPlayed = 0,
        IsTracking = false
    }
end

local function saveWebhookConfig()
    local configPath = "NoahScriptHub/WebhookConfig.json"
    
    pcall(function()
        local data = {
            URL = getgenv().WebhookConfig.URL
            -- ❌ NO GUARDAR GamesPlayed - siempre empieza de 0
        }
        
        local jsonData = game:GetService("HttpService"):JSONEncode(data)
        writefile(configPath, jsonData)
        print("[WEBHOOK] Config saved")
    end)
end

getgenv().WebhookConfig = getgenv().WebhookConfig or loadWebhookConfig()

-- ✅ FORZAR RESET DE GamesPlayed AL EJECUTAR/RE-EJECUTAR SCRIPT
getgenv().WebhookConfig.GamesPlayed = 0
print("[WEBHOOK] Games counter reset to 0")

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
getgenv().WindUI = WindUI



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
        
        local lobbySetMap = remoteFunctions:FindFirstChild("LobbySetMap_8")
        local lobbySetMaxPlayers = remoteFunctions:FindFirstChild("LobbySetMaxPlayers_8")
        
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

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "wrench",
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

-- ==================== AUTO LOAD CONFIG AL INICIO ====================
task.spawn(function()
    task.wait(2) -- Esperar a que todos los tabs carguen
    
    local autoLoadPath = "NoahScriptHub/AutoLoad.txt"
    
    if isfile(autoLoadPath) then
        local success, configName = pcall(function()
            return readfile(autoLoadPath)
        end)
        
        if success and configName and configName ~= "" then
            local configPath = "NoahScriptHub/Configs/" .. configName .. ".json"
            
            if isfile(configPath) then
                print("[AUTO LOAD] Loading config: " .. configName)
                
                local loadSuccess, configData = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(readfile(configPath))
                end)
                
                if loadSuccess and configData then
                    -- RESTAURAR MAIN TAB - TOGGLES
                    getgenv().MainTabConfig.AutoSkip = configData.MainTab_AutoSkip or false
                    getgenv().MainTabConfig.AutoSpeed2x = configData.MainTab_AutoSpeed2x or false
                    getgenv().MainTabConfig.AutoSpeed3x = configData.MainTab_AutoSpeed3x or false
                    getgenv().MainTabConfig.AutoPlayAgain = configData.MainTab_AutoPlayAgain or false
                    getgenv().MainTabConfig.AutoReturn = configData.MainTab_AutoReturn or false
                    getgenv().MainTabConfig.AutoDifficulty = configData.MainTab_AutoDifficulty or false
                    getgenv().MainTabConfig.AutoJoinMap = configData.MainTab_AutoJoinMap or false
                    
                    -- RESTAURAR MAIN TAB - DROPDOWN VALUES
                    getgenv().MainTabConfig.SelectedDifficulty = configData.MainTab_SelectedDifficulty
                    getgenv().MainTabConfig.SelectedDifficultyName = configData.MainTab_SelectedDifficultyName
                    getgenv().MainTabConfig.SelectedMap = configData.MainTab_SelectedMap
                    getgenv().MainTabConfig.SelectedMapName = configData.MainTab_SelectedMapName
                    
-- RESTAURAR ANTI-BAN TAB
                    getgenv().AntiBanConfig.PlacementOffset = configData.AntiBan_PlacementOffset or 1.5
                    getgenv().AntiBanConfig.MatchesBeforeReturn = configData.AntiBan_MatchesBeforeReturn or 100
                    getgenv().AntiBanConfig.AutoReturnEnabled = configData.AntiBan_AutoReturnEnabled or false
                    getgenv().AntiBanConfig.AntiAFKEnabled = configData.AntiBan_AntiAFKEnabled or false
                    
                    -- ✅ RESTAURAR AUTO FARM TAB (SOLO VALORES)
                    getgenv().AutoFarmConfig.GraveyardV1Active = configData.AutoFarm_GraveyardV1Active or false
                    getgenv().AutoFarmConfig.GraveyardV2Active = configData.AutoFarm_GraveyardV2Active or false
                    getgenv().AutoFarmConfig.DojoActive = configData.AutoFarm_DojoActive or false
                    getgenv().AutoFarmConfig.AutoWinV1Active = configData.AutoFarm_AutoWinV1Active or false
                    getgenv().AutoFarmConfig.AutoWinV2Active = configData.AutoFarm_AutoWinV2Active or false
                    
                    -- RESTAURAR PERFORMANCE TAB
                    getgenv().PerformanceConfig.RenderStopped = configData.Performance_RenderStopped or false
                    getgenv().PerformanceConfig.BlackScreenEnabled = configData.Performance_BlackScreenEnabled or false
                    getgenv().LowGraphicsConfig.Enabled = configData.Performance_LowGraphicsEnabled or false
                    
                    -- RESTAURAR WEBHOOK TAB
                    getgenv().WebhookConfig.URL = configData.Webhook_URL or ""
                    getgenv().WebhookConfig.Enabled = configData.Webhook_Enabled or false
                    
                    task.wait(0.5)
                    
                    -- APLICAR CAMBIOS VISUALES EN LOS TOGGLES
                    if getgenv().MainTabToggles.AutoSkip then
                        getgenv().MainTabToggles.AutoSkip:Set(getgenv().MainTabConfig.AutoSkip)
                    end
                    if getgenv().MainTabToggles.AutoSpeed2x then
                        getgenv().MainTabToggles.AutoSpeed2x:Set(getgenv().MainTabConfig.AutoSpeed2x)
                    end
                    if getgenv().MainTabToggles.AutoSpeed3x then
                        getgenv().MainTabToggles.AutoSpeed3x:Set(getgenv().MainTabConfig.AutoSpeed3x)
                    end
                    if getgenv().MainTabToggles.AutoPlayAgain then
                        getgenv().MainTabToggles.AutoPlayAgain:Set(getgenv().MainTabConfig.AutoPlayAgain)
                    end
                    if getgenv().MainTabToggles.AutoDifficulty then
                        getgenv().MainTabToggles.AutoDifficulty:Set(getgenv().MainTabConfig.AutoDifficulty)
                    end
                    if getgenv().MainTabToggles.AutoJoinMap then
                        getgenv().MainTabToggles.AutoJoinMap:Set(getgenv().MainTabConfig.AutoJoinMap)
                    end
                    if getgenv().AntiBanToggles.AntiAFK then
                        getgenv().AntiBanToggles.AntiAFK:Set(getgenv().AntiBanConfig.AntiAFKEnabled)
                    end
                    if getgenv().PerformanceModeToggle then
                        getgenv().PerformanceModeToggle:Set(getgenv().PerformanceConfig.RenderStopped)
                    end
                    if getgenv().BlackScreenToggle then
                        getgenv().BlackScreenToggle:Set(getgenv().PerformanceConfig.BlackScreenEnabled)
                    end

                    if getgenv().LowGraphicsToggle then
                        getgenv().LowGraphicsToggle:Set(getgenv().LowGraphicsConfig.Enabled)
                    end
                    
                    -- ✅ APLICAR AUTO FARM TOGGLE (SI ALGUNO ESTABA ACTIVO)
                    local autoFarmToActivate = nil

                    if configData.AutoFarm_GraveyardV1Active then
                        autoFarmToActivate = "GraveyardV1"
                    elseif configData.AutoFarm_GraveyardV2Active then
                        autoFarmToActivate = "GraveyardV2"
                    elseif configData.AutoFarm_DojoActive then
                        autoFarmToActivate = "Dojo"
                    elseif configData.AutoFarm_AutoWinV1Active then
                        autoFarmToActivate = "AutoWinV1"
                    elseif configData.AutoFarm_AutoWinV2Active then
                        autoFarmToActivate = "AutoWinV2"
                    end

                    if autoFarmToActivate then
                        print("[AUTO LOAD] Waiting for Auto Farm toggle: " .. autoFarmToActivate)
                        
                        local maxWait = 20
                        local waited = 0
                        local found = false
                        
                        while waited < maxWait and not found do
                            if getgenv().AutoFarmToggles and getgenv().AutoFarmToggles[autoFarmToActivate] then
                                found = true
                                print("[AUTO LOAD] ✓ Toggle found after " .. waited .. " seconds")
                                break
                            end
                            task.wait(0.1)
                            waited = waited + 0.1
                        end
                        
                        if found then
                            print("[AUTO LOAD] ✓ Activating toggle: " .. autoFarmToActivate)
                            task.spawn(function()
                                task.wait(0.1)
                                getgenv().AutoFarmToggles[autoFarmToActivate]:Set(true)
                            end)
                        else
                            warn("[AUTO LOAD] ❌ Toggle '" .. autoFarmToActivate .. "' not found after " .. maxWait .. " seconds!")
                        end
                    end
                    
                    WindUI:Notify({
                        Title = "Auto Load Complete",
                        Content = "Config '" .. configName .. "' loaded automatically!",
                        Duration = 4
                    })
                    
                    print("[AUTO LOAD] ✅ Config '" .. configName .. "' loaded successfully!")
                else
                    warn("[AUTO LOAD] Failed to load config: " .. configName)
                end
            else
                warn("[AUTO LOAD] Config file not found: " .. configName)
                WindUI:Notify({
                    Title = "Auto Load Failed",
                    Content = "Config '" .. configName .. "' not found!",
                    Duration = 3
                })
            end
        end
    else
        print("[AUTO LOAD] No auto-load config set")
    end
end)


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

local function getPresentsFromScreen()
    local success, result = pcall(function()
        local gui = PlayerGui:FindFirstChild("GameGui")
        if not gui then return "N/A" end
        
        -- ✅ BUSCAR ChristmasGiftsDisplay (nombre interno correcto)
        local presentsDisplay = gui:FindFirstChild("ChristmasGiftsDisplay", true)
        
        if presentsDisplay then
            local titleLabel = presentsDisplay:FindFirstChild("Title")
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
    print("[WEBHOOK] Scanning for game result...")
    
    -- Buscar en TODOS los TextLabels visibles
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local txt = obj.Text
            local txtLower = txt:lower()
            
            print("[WEBHOOK] Checking label: " .. txt)
            
            -- Detectar derrota
            if txtLower == "defeat" or 
               txtLower:find("overwhelmed") or 
               txtLower:find("been overwhelmed") then
                print("[WEBHOOK] ✅ DEFEAT DETECTED!")
                return "Defeat"
            end
            
            -- Detectar victoria
            if txtLower == "victory" or 
               txtLower:find("cleared") or 
               txtLower:find("you win") then
                print("[WEBHOOK] ✅ VICTORY DETECTED!")
                return "Victory"
            end
        end
    end
    
    -- Fallback: Buscar por nombre "Title"
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Name == "Title" and obj.Visible then
            if obj.Text == "Defeat" then 
                print("[WEBHOOK] ✅ DEFEAT DETECTED (by Title)!")
                return "Defeat" 
            end
            if obj.Text == "Victory" then 
                print("[WEBHOOK] ✅ VICTORY DETECTED (by Title)!")
                return "Victory" 
            end
        end
    end
    
    print("[WEBHOOK] ⚠️ No result detected (Unknown)")
    return "Unknown"
end

local function getRunTime(endFrame)
    print("[WEBHOOK] Scanning for run time...")
    
    -- Buscar en TODO el endFrame
    for _, obj in pairs(endFrame:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Visible then
            local txt = obj.Text
            local txtLower = txt:lower()
            
            if txtLower:find("run") then
                print("[WEBHOOK] Found label with 'run': " .. txt)
            end
            
            if txtLower:find("run time") then
                print("[WEBHOOK] ✅ Found 'Run time' label: " .. txt)
                
                -- Intentar formato "M:SS"
                local timeMatch = txt:match("(%d+:%d+)")
                if timeMatch then
                    print("[WEBHOOK] ✅ Captured formatted time: " .. timeMatch)
                    return timeMatch
                end
                
                -- Buscar solo números (ej: "Run time: 24")
                local secsMatch = txt:match("[Rr]un%s+[Tt]ime[:%s]*(%d+)")
                if secsMatch then
                    print("[WEBHOOK] Captured seconds: " .. secsMatch)
                    local secs = tonumber(secsMatch)
                    if secs and secs < 3600 then  -- ✅ CRÍTICO: verifica que sea < 1 hora
                        local minutes = math.floor(secs / 60)
                        local seconds = secs % 60
                        local formatted = string.format("%d:%02d", minutes, seconds)
                        print("[WEBHOOK] ✅ Formatted time: " .. formatted)
                        return formatted
                    end
                end
            end
        end
    end
    
    print("[WEBHOOK] ⚠️ No run time found (N/A)")
    return "N/A"
end

local function sendWebhook(endFrame, isTest)
    if getgenv().WebhookConfig.URL == "" or not getgenv().WebhookConfig.URL then
        print("[WEBHOOK] ⚠️ No URL configured")
        WindUI:Notify({
            Title = "Webhook Error",
            Content = "Please enter a Webhook URL first!",
            Duration = 3
        })
        return false
    end
    
    print("[WEBHOOK] 📤 Preparing to send webhook...")
    
    local success, err = pcall(function()
        if not isTest then
            getgenv().WebhookConfig.GamesPlayed = getgenv().WebhookConfig.GamesPlayed + 1
        end
        
        local time = os.date("%Y-%m-%d %H:%M:%S")
        local seeds = getSeedsFromScreen()
        local presents = getPresentsFromScreen()
        
        local result = "Test Webhook"
        local runTime = "N/A"
        
        if not isTest and endFrame then
            result = getGameResult(endFrame)
            runTime = getRunTime(endFrame)
        end
        
        -- ✅ DEBUG: Mostrar datos antes de enviar
        print("\n=== WEBHOOK DATA ===")
        print("Seeds: " .. seeds)
        print("Presents: " .. presents)
        print("Result: " .. result)
        print("Run Time: " .. runTime)
        print("===================\n")
        
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
                "🎁 Presents: %s\n\n" ..
                "**Match Results**\n" ..
                "%s\n" ..
                "⏱️ Run Time: %s",
                userName,
                getgenv().WebhookConfig.GamesPlayed,
                seeds,
                presents,
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
                "🎁 Presents: %s\n\n" ..
                "**Match Results**\n" ..
                "%s\n" ..
                "⏱️ Run Time: %s",
                userName,
                getgenv().WebhookConfig.GamesPlayed,
                seeds,
                presents,
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
            print("[WEBHOOK] Sent! Result: " .. result .. " | Seeds: " .. seeds .. " | Presents: " .. presents)
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
    
    print("[WEBHOOK] ✅ Webhook sent successfully!")
    return true
end


local function startWebhookTracking()
    task.spawn(function()
        local lastEndFrameState = false
        print("[WEBHOOK TRACKER] 🚀 Tracking system started")
        
        while task.wait(0.5) do
            if getgenv().WebhookConfig.URL ~= "" then
                pcall(function()
                    local gui = PlayerGui:FindFirstChild("GameGui")
                    if gui then
                        local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
                        if endFrame then
                            local currentState = endFrame.Visible
                            
                            if currentState == true and lastEndFrameState == false and not getgenv().WebhookConfig.IsTracking then
                                print("[WEBHOOK TRACKER] 🎯 GAME END DETECTED!")
                                
                                getgenv().WebhookConfig.IsTracking = true
                                
                                task.wait(1.5)
                                
                                print("[WEBHOOK TRACKER] 📤 Sending webhook now...")
                                sendWebhook(endFrame, false)
                                
                                task.wait(2)
                                getgenv().WebhookConfig.IsTracking = false
                                print("[WEBHOOK TRACKER] ✅ Ready for next match")
                            end
                            
                            lastEndFrameState = currentState
                        end
                    end
                end)
            else
                lastEndFrameState = false
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

-- ✅ REFERENCIAS GLOBALES PARA AUTO FARM TOGGLES
getgenv().AutoFarmToggles = getgenv().AutoFarmToggles or {
    GraveyardV1 = nil,
    GraveyardV2 = nil,
    Dojo = nil,
    AutoWinV1 = nil,
    AutoWinV2 = nil
}

-- ==================== MAP CONFIG & SETUP FUNCTION (MODIFICADO CON DUAL POSITION) ====================
local MapConfig = {
    ["map_farm"] = {
        positions = {
            primary = {
                teleport = CFrame.new(118.89, 78, 779.65),
                remote = "LobbySetMaxPlayers_8",
                leaveRemote = "LeaveLobby_8",
                setMapRemote = "LobbySetMap_8"
            },
            secondary = {
                teleport = CFrame.new(108, 71, 777),
                remote = "LobbySetMaxPlayers_7",
                leaveRemote = "LeaveLobby_7",
                setMapRemote = "LobbySetMap_7"
            }
        }
    },
    ["map_jungle"] = {
        positions = {
            primary = {
                teleport = CFrame.new(118.89, 78, 779.65),
                remote = "LobbySetMaxPlayers_8",
                leaveRemote = "LeaveLobby_8",
                setMapRemote = "LobbySetMap_8"
            },
            secondary = {
                teleport = CFrame.new(108, 71, 777),
                remote = "LobbySetMaxPlayers_7",
                leaveRemote = "LeaveLobby_7",
                setMapRemote = "LobbySetMap_7"
            }
        }
    },
    ["map_island"] = {
        positions = {
            primary = {
                teleport = CFrame.new(118.89, 78, 779.65),
                remote = "LobbySetMaxPlayers_8",
                leaveRemote = "LeaveLobby_8",
                setMapRemote = "LobbySetMap_8"
            },
            secondary = {
                teleport = CFrame.new(108, 71, 777),
                remote = "LobbySetMaxPlayers_7",
                leaveRemote = "LeaveLobby_7",
                setMapRemote = "LobbySetMap_7"
            }
        }
    },
    ["map_toxic"] = {
        positions = {
            primary = {
                teleport = CFrame.new(118.89, 78, 779.65),
                remote = "LobbySetMaxPlayers_8",
                leaveRemote = "LeaveLobby_8",
                setMapRemote = "LobbySetMap_8"
            },
            secondary = {
                teleport = CFrame.new(108, 71, 777),
                remote = "LobbySetMaxPlayers_7",
                leaveRemote = "LeaveLobby_7",
                setMapRemote = "LobbySetMap_7"
            }
        }
    },
    ["map_back_garden"] = {
        positions = {
            primary = {
                teleport = CFrame.new(118.89, 78, 779.65),
                remote = "LobbySetMaxPlayers_8",
                leaveRemote = "LeaveLobby_8",
                setMapRemote = "LobbySetMap_8"
            },
            secondary = {
                teleport = CFrame.new(108, 71, 777),
                remote = "LobbySetMaxPlayers_7",
                leaveRemote = "LeaveLobby_7",
                setMapRemote = "LobbySetMap_7"
            }
        }
    },
    ["map_dojo"] = {
        positions = {
            primary = {
                teleport = CFrame.new(118.89, 78, 779.65),
                remote = "LobbySetMaxPlayers_8",
                leaveRemote = "LeaveLobby_8",
                setMapRemote = "LobbySetMap_8"
            },
            secondary = {
                teleport = CFrame.new(108, 71, 777),
                remote = "LobbySetMaxPlayers_7",
                leaveRemote = "LeaveLobby_7",
                setMapRemote = "LobbySetMap_7"
            }
        }
    },
    ["map_graveyard"] = {
        positions = {
            primary = {
                teleport = CFrame.new(118.89, 78, 779.65),
                remote = "LobbySetMaxPlayers_8",
                leaveRemote = "LeaveLobby_8",
                setMapRemote = "LobbySetMap_8"
            },
            secondary = {
                teleport = CFrame.new(108, 71, 777),
                remote = "LobbySetMaxPlayers_7",
                leaveRemote = "LeaveLobby_7",
                setMapRemote = "LobbySetMap_7"
            }
        }
    }
}

-- ==================== FUNCIÓN DE SETUP DE LOBBY CON REINTENTOS Y DUAL POSITION ====================
local function setupLobbyWithRetry(mapId, mapName, maxRetries)
    maxRetries = maxRetries or 10
    local mapConfig = MapConfig[mapId]
    
    if not mapConfig or not mapConfig.positions then
        warn("[LOBBY SETUP] ❌ No config found for map: " .. mapId)
        return false
    end
    
    local usePrimary = true -- Empezar con la posición primaria
    
    for attempt = 1, maxRetries do
        -- Alternar entre posiciones primary y secondary
        local currentPosition = usePrimary and mapConfig.positions.primary or mapConfig.positions.secondary
        local positionName = usePrimary and "PRIMARY" or "SECONDARY"
        
        print("[LOBBY SETUP] ========================================")
        print("[LOBBY SETUP] Attempt " .. attempt .. "/" .. maxRetries .. " for " .. mapName)
        print("[LOBBY SETUP] Using " .. positionName .. " position")
        print("[LOBBY SETUP] ========================================")
        
        -- 1. Verificar si ya estamos en el mapa correcto
        local currentMap = getCurrentMap()
        if currentMap == "in_map" then
            print("[LOBBY SETUP] ✅ Already in map - setup successful!")
            return true
        end
        
        -- 2. Si estamos en lobby, hacer el setup
        if currentMap == "map_lobby" then
            print("[LOBBY SETUP] In lobby - executing setup with " .. positionName .. " position...")
            
            -- Teleport
            local Character = LocalPlayer.Character
            if Character then
                local HRP = Character:FindFirstChild("HumanoidRootPart")
                if HRP then
                    print("[LOBBY SETUP] Teleporting to " .. positionName .. " position...")
                    HRP.CFrame = currentPosition.teleport
                    task.wait(1)
                end
            end
            
            -- Set max players usando el remote correspondiente
            print("[LOBBY SETUP] Setting max players to 1 (using " .. currentPosition.remote .. ")...")
            pcall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("RemoteFunctions")
                    :WaitForChild(currentPosition.remote)
                    :InvokeServer(1)
            end)
            task.wait(0.3)
            
            -- Set map usando el remote correspondiente
            print("[LOBBY SETUP] Setting map to: " .. mapId .. " (using " .. currentPosition.setMapRemote .. ")...")
            pcall(function()
                game:GetService("ReplicatedStorage")
                    :WaitForChild("RemoteFunctions")
                    :WaitForChild(currentPosition.setMapRemote)
                    :InvokeServer(mapId)
            end)
            
            -- Esperar 7 segundos para verificar si entramos al mapa
            print("[LOBBY SETUP] Waiting 7 seconds to verify map entry...")
            task.wait(7)
            
            currentMap = getCurrentMap()
            if currentMap == "in_map" then
                print("[LOBBY SETUP] ✅ Successfully entered map on attempt " .. attempt .. " using " .. positionName .. " position!")
                return true
            else
                warn("[LOBBY SETUP] ⚠️ Still in lobby after 7 seconds with " .. positionName .. " position")
                
                if attempt < maxRetries then
                    print("[LOBBY SETUP] Leaving lobby and switching position...")
                    
                    -- Salir del lobby usando el remote correspondiente
                    pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("RemoteFunctions")
                            :WaitForChild(currentPosition.leaveRemote)
                            :InvokeServer()
                    end)
                    
                    -- ✅ ALTERNAR POSICIÓN PARA EL SIGUIENTE INTENTO
                    usePrimary = not usePrimary
                    print("[LOBBY SETUP] Switched to " .. (usePrimary and "PRIMARY" or "SECONDARY") .. " position for next attempt")
                    
                    -- Esperar 5 segundos antes del siguiente intento
                    print("[LOBBY SETUP] Waiting 5 seconds before retry...")
                    task.wait(5)
                end
            end
        else
            warn("[LOBBY SETUP] ⚠️ Not in lobby, waiting...")
            task.wait(3)
        end
    end
    
    warn("[LOBBY SETUP] ❌ Failed to enter map after " .. maxRetries .. " attempts")
    warn("[LOBBY SETUP] Tried both PRIMARY and SECONDARY positions")
    return false
end

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
            -- ✅ VERIFICAR SI ESTÁ EN MAPA
            local currentMap = getCurrentMap()
            
            if state and currentMap == "map_lobby" then
                WindUI:Notify({
                    Title = "Cannot Use in Lobby",
                    Content = "Auto Skip only works inside maps!",
                    Duration = 3
                })
                
                task.spawn(function()
                    task.wait(0.1)
                    AutoSkipToggle:Set(false)
                end)
                return
            end
            
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
    
    local AutoReturnMainToggle
    
    AutoReturnMainToggle = MainTab:Toggle({
        Flag = "AutoReturn",
        Title = "Auto Return",
        Default = getgenv().MainTabConfig.AutoReturn,
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
                    AutoReturnMainToggle:Set(false)
                end)
                return
            end
            
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
                            print("[AUTO JOIN MAP] Teleporting to lobby position...")
                            HumanoidRootPart.CFrame = mapConfig.teleport
                            task.wait(1)
                            print("[AUTO JOIN MAP] ✓ Teleported successfully")
                        end
                    end
                    
                    print("[AUTO JOIN MAP] Setting max players to 1...")
                    local args = { 1 }
                    local success1 = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild(mapConfig.remote):InvokeServer(unpack(args))
                    print("[AUTO JOIN MAP] SetMaxPlayers result: " .. tostring(success1))
                    task.wait(0.3)
                    
                    print("[AUTO JOIN MAP] Setting map to: " .. getgenv().MainTabConfig.SelectedMap)
                    local args = { getgenv().MainTabConfig.SelectedMap }
                    local success2 = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("LobbySetMap_8"):InvokeServer(unpack(args))
                    print("[AUTO JOIN MAP] SetMap result: " .. tostring(success2))
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

-- ==================== PERFORMANCE MODE SECTION ====================
MainTab:Space({ Columns = 2 })

MainTab:Section({
    Title = "Performance Mode",
    TextSize = 16,
    TextTransparency = 0.3,
})

MainTab:Space()

local PerformanceModeToggle = MainTab:Toggle({
    Flag = "PerformanceMode",
    Title = "Disable 3D Render",
    Desc = "",
    Default = getgenv().PerformanceConfig.RenderStopped,
    Callback = function(state)
        getgenv().PerformanceConfig.RenderStopped = state
        
        local RunService = game:GetService("RunService")
        
        pcall(function()
            RunService:Set3dRenderingEnabled(not state)
        end)
        
        if state then
            WindUI:Notify({
                Title = "Performance Mode ON",
                Content = "3D rendering disabled",
                Duration = 1
            })
            print("[PERFORMANCE] ✅ 3D Rendering STOPPED!")
        else
            WindUI:Notify({
                Title = "Performance Mode OFF",
                Content = "3D rendering enabled",
                Duration = 1
            })
            print("[PERFORMANCE] ✅ 3D Rendering RESTORED!")
        end
    end
})

-- ✅ GUARDAR REFERENCIA GLOBAL
getgenv().PerformanceModeToggle = PerformanceModeToggle

MainTab:Space()

-- ==================== LOW GRAPHICS MODE TOGGLE ====================
local LowGraphicsToggle = MainTab:Toggle({
    Flag = "LowGraphicsMode",
    Title = "Low Graphics Mode",
    Desc = "",
    Default = getgenv().LowGraphicsConfig.Enabled,
    Callback = function(state)
        getgenv().LowGraphicsConfig.Enabled = state
        
        if state then
            -- Guardar configuración original antes de aplicar cambios
            saveLightingSettings()
            
            -- Aplicar optimizaciones
            enableLowGraphics()
            
            WindUI:Notify({
                Title = "Low Graphics ON", 
                Content = "Textures, effects, and decorations removed", 
                Duration = 3
            })
        else
            -- Restaurar gráficos originales
            restoreGraphics()
            
            WindUI:Notify({
                Title = "Low Graphics OFF", 
                Content = "Graphics restored to original", 
                Duration = 2
            })
        end
    end
})

-- ✅ GUARDAR REFERENCIA GLOBAL
getgenv().LowGraphicsToggle = LowGraphicsToggle

MainTab:Space()

-- ==================== BLACK SCREEN TOGGLE ====================
local BlackScreenToggle = MainTab:Toggle({
    Flag = "BlackScreenMode",
    Title = "Black Screen",
    Desc = "Does not improve performance",
    Default = getgenv().PerformanceConfig.BlackScreenEnabled,
    Callback = function(state)
        getgenv().PerformanceConfig.BlackScreenEnabled = state
        
        if state then
            createBlackScreen()
            WindUI:Notify({
                Title = "Black Screen ON",
                Content = "Screen covered with black overlay",
                Duration = 1
            })
            print("[BLACK SCREEN] ✅ Enabled!")
        else
            removeBlackScreen()
            WindUI:Notify({
                Title = "Black Screen OFF",
                Content = "Screen restored to normal",
                Duration = 1
            })
            print("[BLACK SCREEN] ✅ Disabled!")
        end
    end
})

getgenv().BlackScreenToggle = BlackScreenToggle

MainTab:Space()
    
    print("[MAIN TAB] Content loaded successfully!")
end)

-- ==================== AUTO FARM FUNCTIONS ====================

-- ==================== AUTO FARM FUNCTIONS ====================
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ❌ SISTEMA DE TESTEO DE FALLOS - DESACTIVADO (ya testeado)
getgenv().TestFailureSystem = getgenv().TestFailureSystem or {
    Enabled = false,  -- ❌ DESACTIVADO
    FailOnMatches = {},
    FailureType = "none"
}

--[[
local function simulateFailure(matchNumber)
    if not getgenv().TestFailureSystem.Enabled then return false end
    
    -- Verificar si este match debe fallar
    local shouldFail = false
    for _, failMatch in ipairs(getgenv().TestFailureSystem.FailOnMatches) do
        if failMatch == matchNumber then
            shouldFail = true
            break
        end
    end
    
    if not shouldFail then return false end
    
    -- Determinar tipo de error
    local failType = getgenv().TestFailureSystem.FailureType
    
    -- ✅ Modo secuencial - prueba cada tipo en orden
    if failType == "sequential" then
        local errorSequence = {
            "nil_error",    -- Match 1
            "invalid_id",   -- Match 2
            "timeout",      -- Match 3
            "random"        -- Match 4+
        }
        
        local index = matchNumber
        if index > #errorSequence then
            index = #errorSequence
        end
        
        failType = errorSequence[index]
        print("[TEST FAILURE] Sequential mode - Using error type: " .. failType .. " for match #" .. matchNumber)
    end
    
    -- ✅ EJECUTAR EL TIPO DE ERROR SELECCIONADO
    if failType == "nil_error" then
        warn("[TEST FAILURE] Simulating NIL ERROR in match #" .. matchNumber)
        local nilValue = nil
        return nilValue.SomeProperty  -- ❌ Causará: attempt to index nil with 'SomeProperty'
        
    elseif failType == "timeout" then
        warn("[TEST FAILURE] Simulating TIMEOUT in match #" .. matchNumber)
        -- ✅ USAR assert() en lugar de error()
        assert(false, "⏱️ TIMEOUT: Waiting for money took too long ($5000 required)")
        
    elseif failType == "invalid_id" then
        warn("[TEST FAILURE] Simulating INVALID UNIT ID in match #" .. matchNumber)
        -- ✅ USAR assert() en lugar de error()
        assert(false, "🚫 INVALID ID: Could not find unit for upgrade (ID: 999)")
        
    else  -- "random"
        local errorTypes = {
            "⚠️ RANDOM: attempt to index nil with 'Parent'",
            "⚠️ RANDOM: Unit model not found in workspace",
            "⚠️ RANDOM: Money requirement not met after 30 seconds",
            "⚠️ RANDOM: Failed to track unit after 10 attempts",
            "⚠️ RANDOM: Game state changed unexpectedly"
        }
        local randomError = errorTypes[math.random(1, #errorTypes)]
        warn("[TEST FAILURE] Simulating RANDOM ERROR in match #" .. matchNumber)
        -- ✅ USAR assert() en lugar de error()
        assert(false, randomError)
    end
end

]]--

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

-- ===== FUNCIÓN DE DETECCIÓN MEJORADA =====
local function isGameEnded()
    local success, result = pcall(function()
        local gui = PlayerGui:FindFirstChild("GameGui")
        if gui then
            local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
            if endFrame and endFrame.Visible then
                return true
            end
        end
        return false
    end)
    return success and result
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

local function isGameEnded()
    local success, result = pcall(function()
        local gui = PlayerGui:FindFirstChild("GameGui")
        if gui then
            local endFrame = gui.Screen.Middle:FindFirstChild("GameEnd")
            if endFrame and endFrame.Visible then
                return true
            end
        end
        return false
    end)
    return success and result
end

local function waitForMoney(amount, timeout)
    local startTime = tick()
    timeout = timeout or 30
    
    while getMoney() < amount do
        if isGameEnded() then
            warn("[WAIT MONEY] Game ended - stopping wait")
            return false
        end
        if tick() - startTime > timeout then
            warn("[WAIT MONEY] Timeout waiting for $" .. amount)
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
        
        task.wait(math.random(11, 25) / 100)
    end
    
    return true
end


-- ==================== GRAVEYARD V2: NUEVO ORDEN OPTIMIZADO ====================
local function runGraveyardV2()
    print("[GRAVEYARD V2] Starting optimized Multi-Unit strategy...")
    
    -- ✅ USAR TRACKING GLOBAL
    local myUnitIDs = getgenv().GlobalTracking.unitIDs
    
    local function plantWithRetry(unitName, position, unitDisplayName)
        for attempt = 1, 50 do
            if isGameEnded() then
                warn("[PLANT] Game ended - stopping plant attempts")
                return false
            end
            
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
            if isGameEnded() then
                warn("[UPGRADE] Game ended - stopping upgrades for " .. unitName)
                return false
            end
            
            local costIndex = level - 1
            local cost = costs[costIndex]
            
            if not cost then
                warn("[GRAVEYARD V2] No cost for level " .. level .. " of " .. unitName)
                return false
            end
            
            print("[GRAVEYARD V2] Upgrading " .. unitName .. " to Level " .. level .. " (cost: $" .. cost .. ")...")
            
            if not waitForMoney(cost, 30) then
                warn("[GRAVEYARD V2] Failed to get money for " .. unitName .. " Level " .. level)
                return false
            end
            
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(unitID)
            end)
            task.wait(0.1 + (math.random() * 0.21))
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
        witch2 = {cframe = CFrame.new(-327.02313232421875, 61.6803092956543, -706.6849365234375, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        witch3 = {cframe = CFrame.new(-331.0621643066406, 61.68030548095703, -703.8416137695312, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        potato1 = {cframe = CFrame.new(-333.68597412109375, 61.6803092956543, -716.2599487304688, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        potato2 = {cframe = CFrame.new(-330.1884765625, 61.680301666259766, -719.8148193359375, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        potato3 = {cframe = CFrame.new(-335.74871826171875, 61.68030548095703, -719.666015625, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        christmasbell1 = {cframe = CFrame.new(-331.47357177734375, 61.6803092956543, -713.38330078125, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        corrupted1 = {cframe = CFrame.new(-336.26654052734375, 61.680301666259766, -712.6754760742188, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        corrupted2 = {cframe = CFrame.new(-340.38153076171875, 61.6803092956543, -718.155029296875, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        frostgolem1 = {cframe = CFrame.new(-329.5, 61.68030548095703, -717.0, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        frostgolem2 = {cframe = CFrame.new(-332.0, 61.68030548095703, -714.5, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        frostgolem3 = {cframe = CFrame.new(-327.0, 61.68030548095703, -715.0, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        prismleaf2 = {cframe = CFrame.new(-345.2245178222656, 61.68030548095703, -709.4812622070312, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        prismleaf3 = {cframe = CFrame.new(-348.204345703125, 61.68030548095703, -712.9251098632812, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        prismleaf4 = {cframe = CFrame.new(-347.61895751953125, 61.6803092956543, -705.2569580078125, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180},
        prismleaf5 = {cframe = CFrame.new(-350.3448791503906, 61.6803092956543, -708.4331665039062, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1), rotation = 180}
    }
    
    local costs = {
        prismleaf = {300, 475, 800, 1100},
        christmasbell = {4000, 8750, 18000, 30500},
        frostgolem = {15000, 25500, 39000, 56000},
        potato = {6000, 9000, 14000, 40000},
        witch = {9000, 17000, 25000, 35000},
        dragon = {8000, 12500, 26000, 35000},
        corrupted = {9000, 15750, 32000, 53500}
    }
    
    -- ===== PASO 1: Prismleaf 1 → Lvl 5 =====
    print("[GRAVEYARD V2] ========== PASO 1: PRISMLEAF 1 ==========")
    while getMoney() < 225 do task.wait(0.2) end
    if not plantWithRetry("unit_glow_ray", positions.prismleaf1, "Prismleaf 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 1 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[1], 5, costs.prismleaf, "Prismleaf 1")
    
    -- ===== PASO 2: 3 Dragons (sin upgrade) =====
    print("[GRAVEYARD V2] ========== PASO 2: 3 DRAGONS (SIN UPGRADE) ==========")
    for i = 1, 3 do
        while getMoney() < 6000 do task.wait(0.2) end
        if not plantWithRetry("unit_golem_dragon", positions["dragon"..i], "Dragon " .. i) then
            return false
        end
        task.wait(0.15)
    end
    while #myUnitIDs < 4 do task.wait(0.2) end
    
    -- ===== PASO 3: Witch 1 → Lvl 3 =====
    print("[GRAVEYARD V2] ========== PASO 3: WITCH 1 → LVL 3 ==========")
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_witch", positions.witch1, "Witch 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 5 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[5], 3, costs.witch, "Witch 1")
    
    -- ===== PASO 4: Potato 1 → Lvl 5 (UNO POR UNO) =====
    print("[GRAVEYARD V2] ========== PASO 4: POTATOES UNO POR UNO ==========")
    
    -- Potato 1
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_punch_potato", positions.potato1, "Potato 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 6 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[6], 5, costs.potato, "Potato 1")
    
    -- Potato 2
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_punch_potato", positions.potato2, "Potato 2") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 7 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[7], 5, costs.potato, "Potato 2")
    
    -- Potato 3
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_punch_potato", positions.potato3, "Potato 3") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 8 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[8], 5, costs.potato, "Potato 3")
    
    -- ===== PASO 5: Witch 1 → Lvl 5 (desde lvl 3) =====
    print("[GRAVEYARD V2] ========== PASO 5: WITCH 1 → LVL 5 ==========")
    upgradeToLevel(myUnitIDs[5], 5, costs.witch, "Witch 1", 3)
    
   -- ===== PASO 6: Christmas Bell 1 → Lvl 5 =====
    print("[GRAVEYARD V2] ========== PASO 6: CHRISTMAS BELL ==========")
    while getMoney() < 1600 do task.wait(0.2) end
    if not plantWithRetry("unit_christmas_bell", positions.christmasbell1, "Christmas Bell 1") then
    return false
    end
    task.wait(0.15)
    while #myUnitIDs < 9 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[9], 5, costs.christmasbell, "Christmas Bell 1")
    
    -- ===== PASO 7: Witch 2 → Lvl 5 =====
    print("[GRAVEYARD V2] ========== PASO 7: WITCH 2 ==========")
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_witch", positions.witch2, "Witch 2") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 10 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[10], 5, costs.witch, "Witch 2")
    
    -- ===== PASO 8: Witch 3 → Lvl 5 =====
    print("[GRAVEYARD V2] ========== PASO 8: WITCH 3 ==========")
    while getMoney() < 4500 do task.wait(0.2) end
    if not plantWithRetry("unit_witch", positions.witch3, "Witch 3") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 11 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[11], 5, costs.witch, "Witch 3")

    -- ===== PASO 9: Upgrade Dragons 1, 2, 3 → Lvl 5 =====
    print("[GRAVEYARD V2] ========== PASO 9: UPGRADING ALL DRAGONS ==========")
    upgradeToLevel(myUnitIDs[2], 5, costs.dragon, "Dragon 1")
    upgradeToLevel(myUnitIDs[3], 5, costs.dragon, "Dragon 2")
    upgradeToLevel(myUnitIDs[4], 5, costs.dragon, "Dragon 3")
    
    -- ===== PASO 10: Corrupted 1 y 2 → Lvl 5 =====
    print("[GRAVEYARD V2] ========== PASO 10: CORRUPTED 1 Y 2 ==========")
    
    -- Corrupted 1
    while getMoney() < 8666 do task.wait(0.2) end
    if not plantWithRetry("unit_eyeball", positions.corrupted1, "Corrupted 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 12 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[12], 5, costs.corrupted, "Corrupted 1")
    
    -- Corrupted 2
    while getMoney() < 8666 do task.wait(0.2) end
    if not plantWithRetry("unit_eyeball", positions.corrupted2, "Corrupted 2") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 13 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[13], 5, costs.corrupted, "Corrupted 2")
    
    -- ===== PASO 11: Frost Golem 1, 2, 3 → Lvl 5 =====
    print("[GRAVEYARD V2] ========== PASO 11: FROST GOLEMS ==========")
    
    -- Frost Golem 1
    while getMoney() < 7000 do task.wait(0.2) end
    if not plantWithRetry("unit_frost_golem", positions.frostgolem1, "Frost Golem 1") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 14 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[14], 5, costs.frostgolem, "Frost Golem 1")
    
    -- Frost Golem 2
    while getMoney() < 7000 do task.wait(0.2) end
    if not plantWithRetry("unit_frost_golem", positions.frostgolem2, "Frost Golem 2") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 15 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[15], 5, costs.frostgolem, "Frost Golem 2")
    
    -- Frost Golem 3
    while getMoney() < 7000 do task.wait(0.2) end
    if not plantWithRetry("unit_frost_golem", positions.frostgolem3, "Frost Golem 3") then
       return false
    end
    task.wait(0.15)
    while #myUnitIDs < 16 do task.wait(0.2) end
    upgradeToLevel(myUnitIDs[16], 5, costs.frostgolem, "Frost Golem 3")
    
    -- ===== PASO 12: Prismleafs 2-5 → Lvl 5 =====
    print("[GRAVEYARD V2] ========== PASO 12: PRISMLEAFS RESTANTES ==========")
    for i = 2, 5 do
        while getMoney() < 225 do task.wait(0.2) end
        if not plantWithRetry("unit_glow_ray", positions["prismleaf"..i], "Prismleaf " .. i) then
            return false
        end
        task.wait(0.15)
        while #myUnitIDs < (16 + i - 1) do task.wait(0.2) end
        upgradeToLevel(myUnitIDs[16 + i - 1], 5, costs.prismleaf, "Prismleaf " .. i)
    end

    print("[GRAVEYARD V2] ========== COMPLETE - 20 UNITS PLANTED ==========")
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
        if isGameEnded() then
            warn("[DOJO] Game ended - stopping plant attempts")
            return false
        end
        
        local placementData = pathFunction()
        
        local success, result = pcall(function()
            return ReplicatedStorage:WaitForChild("RemoteFunctions")
                :WaitForChild("PlaceUnit")
                :InvokeServer("unit_rafflesia", placementData)
        end)
        
        if success and result then
            print("[DOJO] ✓ Placed " .. rafflesiaName .. " on attempt " .. attempt)
            return true
        end
        
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
    while getMoney() < 1250 do 
        if isGameEnded() then return false end
        task.wait(0.2) 
    end
    
    if not plantRafflesiaWithRetry(getRandomPositionPath1, "Rafflesia 1", 10) then
        WindUI:Notify({
            Title = "Dojo Error",
            Content = "Failed to plant Rafflesia 1 after 10 attempts",
            Duration = 5
        })
        return false
    end
    
    local waitTime = 0
    local maxWaitTime = 5
    
    while #myUnitIDs < 1 and waitTime < maxWaitTime do
        if isGameEnded() then
            warn("[DOJO] Game ended before tracking Rafflesia 1")
            return false
        end
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
    while getMoney() < 1250 do 
        if isGameEnded() then return false end
        task.wait(0.2) 
    end
    
    if not plantRafflesiaWithRetry(getRandomPositionPath2, "Rafflesia 2", 10) then
        WindUI:Notify({
            Title = "Dojo Error",
            Content = "Failed to plant Rafflesia 2 after 10 attempts",
            Duration = 5
        })
        return false
    end
    
    waitTime = 0
    
    while #myUnitIDs < 2 and waitTime < maxWaitTime do
        if isGameEnded() then
            warn("[DOJO] Game ended before tracking Rafflesia 2")
            return false
        end
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
    while getMoney() < 8000 do 
        if isGameEnded() then return false end
        task.wait(0.2) 
    end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(raff1ID)
    end)
    task.wait(0.28 + (math.random() * 0.41))
    
    print("[DOJO] Upgrading Rafflesia 2...")
    while getMoney() < 8000 do 
        if isGameEnded() then return false end
        task.wait(0.2) 
    end
    pcall(function()
        ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(raff2ID)
    end)
    task.wait(0.28 + (math.random() * 0.41))
    
    print("[DOJO] ========== ALL UPGRADES COMPLETE - WAITING FOR WAVE 10 ==========")
    
    -- ===== ESPERAR WAVE 10 O FIN DEL JUEGO =====
    local currentWave = 0
    local wave10Detected = false
    
    while not wave10Detected and getgenv().AutoFarmConfig.DojoActive do
        if isGameEnded() then
            warn("[DOJO] ✅ Game ended before Wave 10 - continuing to next match")
            return true
        end
        
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
    
    if not getgenv().AutoFarmConfig.DojoActive then
        print("[DOJO] Farm stopped by user")
        return false
    end
    
    if isGameEnded() then
        warn("[DOJO] ✅ Game ended - continuing to next match")
        return true
    end
    
    if not wave10Detected then
        warn("[DOJO] Wave 10 not detected but continuing")
        return true
    end
    
    print("[DOJO] ========== WAVE 10 REACHED - SELLING UNITS ==========")
    
    task.wait(0.35 + (math.random() * 0.35))
    
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

-- ==================== AUTO WIN V1: TOMATO PLANT STRATEGY (FIXED TRACKING) ====================
local function runAutoWinV1()
    print("[AUTO WIN V1] Starting Tomato Plant strategy...")
    
    local myUnitIDs = getgenv().GlobalTracking.unitIDs
    
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
    
    local tomatoIDs = {} -- ✅ GUARDAR IDS INDIVIDUALES
    
    for i = 1, #tomatoPositions do
        if isGameEnded() then
            warn("[AUTO WIN V1] Game ended during planting")
            return false
        end
        
        print("[AUTO WIN V1] Planting Tomato " .. i .. "/18...")
        while getMoney() < 100 do 
            if isGameEnded() then return false end
            task.wait(0.2) 
        end
        
        for attempt = 1, 10 do
            if placeUnit("unit_tomato_plant", tomatoPositions[i].cframe, tomatoPositions[i].rotation) then 
                print("[AUTO WIN V1] ✓ Placed Tomato " .. i)
                break 
            end
            task.wait(0.05)
        end
        task.wait(0.15)
        
        -- ✅ ESPERAR TRACKING ESPECÍFICO
        local waitTime = 0
        local maxWait = 5
        while #myUnitIDs < i and waitTime < maxWait do
            if isGameEnded() then return false end
            task.wait(0.2)
            waitTime = waitTime + 0.2
        end
        
        if #myUnitIDs < i then
            warn("[AUTO WIN V1] ❌ Failed to track Tomato " .. i)
            return false
        end
        
        -- ✅ GUARDAR ID INDIVIDUAL
        local tomatoID = myUnitIDs[i]
        tomatoIDs[i] = tomatoID
        print("[AUTO WIN V1] ✓ Tracked Tomato " .. i .. " (ID: " .. tostring(tomatoID) .. ")")
        
        -- ✅ UPGRADES USANDO EL ID GUARDADO
        for level = 2, 5 do
            if isGameEnded() then return false end
            
            local cost = upgradeCosts[level - 1]
            print("[AUTO WIN V1] Upgrading Tomato " .. i .. " to Level " .. level .. "...")
            
            while getMoney() < cost do 
                if isGameEnded() then return false end
                task.wait(0.2) 
            end
            
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(tomatoID)
            end)
            task.wait(0.28 + (math.random() * 0.27))
        end
        
        print("[AUTO WIN V1] ✓ Tomato " .. i .. " fully upgraded")
    end
    
    print("[AUTO WIN V1] ========== COMPLETE - 18 TOMATOES PLANTED ==========")
    return true
end

-- ==================== AUTO WIN V2: RAINBOW TOMATO STRATEGY (FIXED TRACKING) ====================
local function runAutoWinV2()
    print("[AUTO WIN V2] Starting Rainbow Tomato strategy...")
    
    local myUnitIDs = getgenv().GlobalTracking.unitIDs
    
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
    
    local rainbowIDs = {} -- ✅ GUARDAR IDS INDIVIDUALES
    
    for i = 1, #rainbowPositions do
        if isGameEnded() then
            warn("[AUTO WIN V2] Game ended during planting")
            return false
        end
        
        print("[AUTO WIN V2] Planting Rainbow Tomato " .. i .. "/10...")
        while getMoney() < 100 do 
            if isGameEnded() then return false end
            task.wait(0.2) 
        end
        
        for attempt = 1, 10 do
            if placeUnit("unit_tomato_rainbow", rainbowPositions[i].cframe, rainbowPositions[i].rotation) then 
                print("[AUTO WIN V2] ✓ Placed Rainbow Tomato " .. i)
                break 
            end
            task.wait(0.05)
        end
        task.wait(0.15)
        
        -- ✅ ESPERAR TRACKING ESPECÍFICO
        local waitTime = 0
        local maxWait = 5
        while #myUnitIDs < i and waitTime < maxWait do
            if isGameEnded() then return false end
            task.wait(0.2)
            waitTime = waitTime + 0.2
        end
        
        if #myUnitIDs < i then
            warn("[AUTO WIN V2] ❌ Failed to track Rainbow Tomato " .. i)
            return false
        end
        
        -- ✅ GUARDAR ID INDIVIDUAL
        local rainbowID = myUnitIDs[i]
        rainbowIDs[i] = rainbowID
        print("[AUTO WIN V2] ✓ Tracked Rainbow Tomato " .. i .. " (ID: " .. tostring(rainbowID) .. ")")
        
        -- ✅ UPGRADES USANDO EL ID GUARDADO
        for level = 2, 5 do
            if isGameEnded() then return false end
            
            local cost = upgradeCosts[level - 1]
            print("[AUTO WIN V2] Upgrading Rainbow Tomato " .. i .. " to Level " .. level .. "...")
            
            while getMoney() < cost do 
                if isGameEnded() then return false end
                task.wait(0.2) 
            end
            
            pcall(function()
                ReplicatedStorage:WaitForChild("RemoteFunctions"):WaitForChild("UpgradeUnit"):InvokeServer(rainbowID)
            end)
            task.wait(0.28 + (math.random() * 0.27))
        end
        
        print("[AUTO WIN V2] ✓ Rainbow Tomato " .. i .. " fully upgraded")
    end
    
    print("[AUTO WIN V2] ========== COMPLETE - 10 RAINBOW TOMATOES PLANTED ==========")
    return true
end

-- ==================== AUTO FARM LOOP MANAGER CON RECUPERACIÓN AUTOMÁTICA ====================
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
        
        -- ✅ EJECUTAR MACRO CON SISTEMA DE RECUPERACIÓN MEJORADO
        local macroSuccess, macroError = pcall(function()
            strategyFunction()
        end)
        
        -- ✅ SIEMPRE INCREMENTAR (victoria o derrota cuenta como partida completada)
        getgenv().AutoFarmConfig.MatchesPlayed = getgenv().AutoFarmConfig.MatchesPlayed + 1
        
        if macroSuccess then
            print("[AUTO FARM LOOP] ✓ First macro complete! Match count: " .. getgenv().AutoFarmConfig.MatchesPlayed)
        else
            warn("[AUTO FARM LOOP] ❌ MACRO HAD ERRORS IN MATCH #" .. getgenv().AutoFarmConfig.MatchesPlayed)
            warn("[AUTO FARM LOOP] 📋 ERROR DETAILS: " .. tostring(macroError))
            warn("[AUTO FARM LOOP] 🔄 Match still counts, continuing to next")
            
            -- ✅ NOTIFICAR AL USUARIO
            WindUI:Notify({
                Title = "⚠️ Macro Had Errors",
                Content = "Match #" .. getgenv().AutoFarmConfig.MatchesPlayed .. " completed with errors",
                Duration = 4
            })
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
        
        -- ==================== LOOP INFINITO CON RECUPERACIÓN AUTOMÁTICA ====================
        while getgenv().AutoFarmConfig.IsRunning and (
            getgenv().AutoFarmConfig.GraveyardV1Active or 
            getgenv().AutoFarmConfig.GraveyardV2Active or 
            getgenv().AutoFarmConfig.DojoActive or 
            getgenv().AutoFarmConfig.AutoWinV1Active or 
            getgenv().AutoFarmConfig.AutoWinV2Active
        ) do
            print("[AUTO FARM LOOP] ========== WAITING FOR GAME END ==========")
            local gameEnded = false
            
            -- ✅ ESPERAR A QUE TERMINE EL JUEGO
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
            
            -- ✅ ESPERAR A QUE EMPIECE NUEVA PARTIDA
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
                warn("[AUTO FARM LOOP] ❌ Failed to detect new game after 15 seconds")
                warn("[AUTO FARM LOOP] 🔄 Continuing to wait...")
                
                -- ✅ ESPERAR MÁS TIEMPO (hasta 60 segundos total)
                while waitTime < 60 and not newGameStarted do
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
                    warn("[AUTO FARM LOOP] ❌ CRITICAL: New game not detected after 60 seconds - STOPPING FARM")
                    stopGlobalTracking()
                    
                    WindUI:Notify({
                        Title = "❌ Auto Farm Error",
                        Content = "Could not detect new game - farm stopped",
                        Duration = 5
                    })
                    break
                end
            end
            
            print("[AUTO FARM LOOP] ✓ New game detected after " .. waitTime .. " seconds")
            task.wait(2)
            
            -- ✅ RESETEAR TRACKING PARA NUEVA PARTIDA (CRÍTICO)
            print("[AUTO FARM LOOP] 🔄 Resetting tracking for Match #" .. (getgenv().AutoFarmConfig.MatchesPlayed + 1))
            resetGlobalTracking()
            
            print("[AUTO FARM LOOP] ========== VOTING DIFFICULTY FOR MATCH #" .. (getgenv().AutoFarmConfig.MatchesPlayed + 1) .. " ==========")
            pcall(function()
                game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions"):WaitForChild("PlaceDifficultyVote"):InvokeServer(difficulty)
            end)
            
            task.wait(1)
            
                        print("[AUTO FARM LOOP] ========== EXECUTING MACRO FOR MATCH #" .. (getgenv().AutoFarmConfig.MatchesPlayed + 1) .. " ==========")
            
            -- ✅ EJECUTAR MACRO CON SISTEMA DE RECUPERACIÓN (CATCH ERRORES)
            local macroSuccess, macroError = pcall(function()
                strategyFunction()
            end)
            
            -- ✅ SIEMPRE INCREMENTAR EL CONTADOR (incluso si falla)
            local matchNumberAttempted = getgenv().AutoFarmConfig.MatchesPlayed + 1
            
            if macroSuccess then
                getgenv().AutoFarmConfig.MatchesPlayed = matchNumberAttempted
                print("[AUTO FARM LOOP] ✅ MACRO COMPLETE! Match count: " .. getgenv().AutoFarmConfig.MatchesPlayed)
            else
                warn("[AUTO FARM LOOP] ❌ MACRO FAILED IN MATCH #" .. matchNumberAttempted)
                warn("[AUTO FARM LOOP] 📋 ERROR DETAILS: " .. tostring(macroError))
                warn("[AUTO FARM LOOP] 🔄 Tracking will reset for next match")
                
                -- ✅ INCREMENTAR CONTADOR AUNQUE HAYA FALLADO (para avanzar al siguiente match)
                getgenv().AutoFarmConfig.MatchesPlayed = matchNumberAttempted
                
                -- ✅ NOTIFICAR AL USUARIO
                WindUI:Notify({
                    Title = "⚠️ Macro Failed",
                    Content = "Error in match #" .. matchNumberAttempted .. " - continuing to next match",
                    Duration = 4
                })
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
    

    local GraveyardV2Toggle = AutoFarmTab:Toggle({
        Flag = "GraveyardV2",
        Title = "Graveyard V2",
        Desc = "Prismleaf, Festive Garden Warbell, Frost Golem, Super Punch Potato, Witchleaf, Earth Dragon and Corrupted Stem",
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
                        local success = setupLobbyWithRetry("map_graveyard", "Graveyard", 10)
                        
                        if success then
                            WindUI:Notify({
                                Title = "Setup Complete", 
                                Content = "Successfully entered Graveyard map!", 
                                Duration = 3
                            })
                        else
                            WindUI:Notify({
                                Title = "Setup Failed", 
                                Content = "Could not enter Graveyard after 10 attempts. Please try manually.", 
                                Duration = 5
                            })
                        end
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

-- ✅ GUARDAR REFERENCIA GLOBAL
    getgenv().AutoFarmToggles.GraveyardV2 = GraveyardV2Toggle

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
                        local success = setupLobbyWithRetry("map_dojo", "Dojo", 10)
                        
                        if success then
                            WindUI:Notify({
                                Title = "Setup Complete", 
                                Content = "Successfully entered Dojo map!", 
                                Duration = 3
                            })
                        else
                            WindUI:Notify({
                                Title = "Setup Failed", 
                                Content = "Could not enter Dojo after 10 attempts. Please try manually.", 
                                Duration = 5
                            })
                        end
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

-- ✅ GUARDAR REFERENCIA GLOBAL
    getgenv().AutoFarmToggles.Dojo = DojoToggle

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
                    local success = setupLobbyWithRetry("map_farm", "Garden", 10)
                    
                    if success then
                        WindUI:Notify({
                            Title = "Setup Complete", 
                            Content = "Successfully entered Garden map!", 
                            Duration = 3
                        })
                    else
                        WindUI:Notify({
                            Title = "Setup Failed", 
                            Content = "Could not enter Garden after 10 attempts. Please try manually.", 
                            Duration = 5
                        })
                    end
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

-- ✅ GUARDAR REFERENCIA GLOBAL
getgenv().AutoFarmToggles.AutoWinV1 = AutoWinV1Toggle

AutoFarmTab:Space()

local AutoWinV2Toggle = AutoFarmTab:Toggle({
    Flag = "AutoWinV2",
    Title = "Auto Win V2",
    Desc = "Rainbow Tomato",
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
                    local success = setupLobbyWithRetry("map_farm", "Garden", 10)
                    
                    if success then
                        WindUI:Notify({
                            Title = "Setup Complete", 
                            Content = "Successfully entered Garden map!", 
                            Duration = 3
                        })
                    else
                        WindUI:Notify({
                            Title = "Setup Failed", 
                            Content = "Could not enter Garden after 10 attempts. Please try manually.", 
                            Duration = 5
                        })
                    end
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

-- ✅ GUARDAR REFERENCIA GLOBAL
getgenv().AutoFarmToggles.AutoWinV2 = AutoWinV2Toggle
    
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
        IsRunning = false,
        AutoDeleteEnabled = false
    }
    
    -- ==================== AUTO DELETE CONFIGURATION ====================
    -- Solo se PROTEGEN las unidades GODLY (🟣 ROSA)
    -- LISTA CORRECTA DE GODLIES: Bloodvine, Venus Flytrap, Pyropetal, Lucky Clover, 
    -- Mudmauler, Robo Flower, Rangeleaf, Fungal Barrage, Electroleaf, Mango Cluster,
    -- Stun Flower, Confusion Plant, Ballistic Banana, Beehive, Passion Shooter, 
    -- Shadestool, Snowblossom, Subzero Stem
    local AutoDeleteConfig = {
        -- Classic Summon: GODLY = Bloodvine
        ["ub_classic_v10"] = {
            "unit_cactus", "unit_tomato_plant", "unit_farmer_npc", "unit_gnome_npc",
            "unit_potato", "unit_pineapple", "unit_mushroom", "unit_chili_pepper",
            "unit_money_tree", "unit_bamboo", "unit_roses", "unit_carrots",
            "unit_palm_tree", "unit_broccoli", "unit_peas", "unit_watermelon", "unit_sunflower"
        },
        
        -- Enchanted Summon: GODLY = Venus Flytrap
        ["ub_jungle"] = {
            "unit_onion", "unit_strawberry", "unit_pumpkin", "unit_ghost_pepper",
            "unit_pak_choi", "unit_laser_plant"
        },
        
        -- Sun Summon: GODLY = Pyropetal, Lucky Clover
        ["ub_sun"] = {
            "unit_razor", "unit_eggplant", "unit_durian", "unit_sound_plant", "unit_sprinkler"
        },
        
        -- Astral Summon: GODLY = Mudmauler, Robo Flower
        ["ub_astral"] = {
            "unit_stun_root", "unit_daisy", "unit_accumulator", "unit_cauliflower", "unit_ufo"
        },
        
        -- Crystal Summon: GODLY = Electroleaf, Mango Cluster
        ["ub_crystal"] = {
            "unit_dragonfruit", "unit_slap_leaf", "unit_hammer", "unit_glow_fruit", "unit_magic_pot"
        },
        
        -- Tropical Summon: GODLY = Stun Flower, Confusion Plant
        ["ub_tropical"] = {
            "unit_radish", "unit_scarecrow", "unit_kiwi_cannon", "unit_grandma", "unit_umbra", "unit_lawnmower"
        },
        
        -- Bee Summon: GODLY = Ballistic Banana, Beehive
        ["ub_bee"] = {
            "unit_pomegranate", "unit_aloe_vera", "unit_venus_floortrap", "unit_fruit_lobber", "unit_worker"
        },
        
        -- Corrupted Summon: GODLY = Passion Shooter, Shadestool
        ["ub_corrupted"] = {
            "unit_lumberjack", "unit_whip_plant", "unit_drill", "unit_fairy", "unit_blackberries"
        },
        
        -- Mushroom Summon: GODLY = Rangeleaf, Fungal Barrage
        ["ub_mushroom"] = {
            "unit_pine", "unit_drill_head", "unit_pea_lobber", "unit_grenade_lobber", "unit_scent_flower"
        },
        
        -- Winter Summon: GODLY = Snowblossom, Subzero Stem
        ["ub_christmas"] = {
            "unit_christmas_tree", "unit_ice_chomp", "unit_wheel_bush", "unit_snowballer", "unit_frost_shroom"
        }
    }
    
    local function applyAutoDelete(crateName)
        if not SummonConfig.AutoDeleteEnabled then return end
        
        local unitsToDelete = AutoDeleteConfig[crateName]
        if not unitsToDelete then 
            warn("[AUTO DELETE] No configuration found for: " .. crateName)
            return 
        end
        
        print("[AUTO DELETE] Applying bans for: " .. crateName)
        local bannedCount = 0
        
        for _, unitName in ipairs(unitsToDelete) do
            local success = pcall(function()
                local args = { crateName, unitName, true }
                game:GetService("ReplicatedStorage")
                    :WaitForChild("RemoteEvents")
                    :WaitForChild("BanFromUnitBox")
                    :FireServer(unpack(args))
            end)
            
            if success then
                bannedCount = bannedCount + 1
            else
                warn("[AUTO DELETE] Failed to ban: " .. unitName)
            end
            
            task.wait(0.05)
        end
        
        print("[AUTO DELETE] ✓ Banned " .. bannedCount .. " units from " .. crateName)
    end
    
    local function removeAutoDelete(crateName)
        local unitsToDelete = AutoDeleteConfig[crateName]
        if not unitsToDelete then return end
        
        print("[AUTO DELETE] Removing bans for: " .. crateName)
        
        for _, unitName in ipairs(unitsToDelete) do
            pcall(function()
                local args = { crateName, unitName, false }
                game:GetService("ReplicatedStorage")
                    :WaitForChild("RemoteEvents")
                    :WaitForChild("BanFromUnitBox")
                    :FireServer(unpack(args))
            end)
            task.wait(0.05)
        end
        
        print("[AUTO DELETE] ✓ Removed all bans from " .. crateName)
    end
    
    local CrateMapping = {
        ["Classic Summon"] = "ub_classic_v10",
        ["Enchanted Summon"] = "ub_jungle",
        ["Sun Summon"] = "ub_sun",
        ["Astral Summon"] = "ub_astral",
        ["Crystal Summon"] = "ub_crystal",
        ["Tropical Summon"] = "ub_tropical",
        ["Bee Summon"] = "ub_bee",
        ["Corrupted Summon"] = "ub_corrupted",
        ["Mushroom Summon"] = "ub_mushroom",
        ["Winter Summon"] = "ub_christmas"
    }
    
    SummonTab:Section({
        Title = "Summon Crate",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    
    SummonTab:Section({
        Title = "Buy crates anywhere even the crates out of stock.",
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
            { Title = "Winter Summon" }
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
    
    -- ==================== AUTO DELETE TOGGLE ====================
    local AutoDeleteToggle = SummonTab:Toggle({
        Flag = "AutoDelete",
        Title = "Auto Delete",
        Desc = "Automatically delete non-Godly units",
        Default = false,
        Callback = function(state)
            SummonConfig.AutoDeleteEnabled = state
            
            if state then
                -- ✅ APLICAR BANS INMEDIATAMENTE SI HAY UN CRATE SELECCIONADO
                if SummonConfig.SelectedCrate then
                    applyAutoDelete(SummonConfig.SelectedCrate)
                end
                
                WindUI:Notify({
                    Title = "Auto Delete Enabled",
                    Content = "Non-Godly units will be deleted automatically",
                    Duration = 3
                })
            else
                -- ✅ REMOVER BANS SI SE DESACTIVA
                if SummonConfig.SelectedCrate then
                    removeAutoDelete(SummonConfig.SelectedCrate)
                end
                
                WindUI:Notify({
                    Title = "Auto Delete Disabled",
                    Content = "All units will be kept",
                    Duration = 2
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
                
                -- ✅ APLICAR AUTO DELETE SI ESTÁ ACTIVADO
                if SummonConfig.AutoDeleteEnabled then
                    task.spawn(function()
                        task.wait(1)
                        applyAutoDelete(SummonConfig.SelectedCrate)
                    end)
                end
                
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
                        
                        if success and result == true then
                            completed = completed + 1
                            print("[AUTO SUMMON] ✓ Purchase " .. i .. "/" .. SummonConfig.BuyAmount .. " completed")
                        else
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

-- ==================== CARGAR CONTENIDO DEL MISC TAB ====================
task.spawn(function()
    wait(0.35)
    print("[MISC TAB] Loading content...")
    
    MiscTab:Section({
        Title = "Server Management",
        TextSize = 16,
        TextTransparency = 0.3,
    })
    
    MiscTab:Space()
    
    -- ==================== FUNCIONES DE SERVER HOP ====================
    local TeleportService = game:GetService("TeleportService")
    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    
    local function serverHop(minPlayers, maxPlayers)
        local success, result = pcall(function()
            print("[SERVER HOP] Starting server hop...")
            print("[SERVER HOP] Looking for servers with " .. minPlayers .. "-" .. maxPlayers .. " players")
            
            local placeId = game.PlaceId
            local currentJobId = game.JobId
            
            local serversUrl = string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100",
                placeId
            )
            
            local serversResponse = game:HttpGet(serversUrl)
            local serversData = HttpService:JSONDecode(serversResponse)
            
            if not serversData or not serversData.data then
                error("Failed to fetch server list")
            end
            
            print("[SERVER HOP] Total servers found: " .. #serversData.data)
            
            local validServers = {}
            for _, server in pairs(serversData.data) do
                if server.id ~= currentJobId and 
                   server.playing >= minPlayers and 
                   server.playing <= maxPlayers and
                   server.playing < server.maxPlayers then
                    table.insert(validServers, server)
                end
            end
            
            print("[SERVER HOP] Valid servers in range: " .. #validServers)
            
            if #validServers == 0 then
                error("No servers found with " .. minPlayers .. "-" .. maxPlayers .. " players")
            end
            
            table.sort(validServers, function(a, b)
                return a.playing < b.playing
            end)
            
            print("[SERVER HOP] Available servers:")
            for i = 1, math.min(5, #validServers) do
                local server = validServers[i]
                print(string.format("  %d. Players: %d/%d", i, server.playing, server.maxPlayers))
            end
            
            local targetServer = validServers[math.random(1, math.min(10, #validServers))]
            
            print("[SERVER HOP] Selected server with " .. targetServer.playing .. " players")
            
            WindUI:Notify({
                Title = "Server Hop",
                Content = "Teleporting to server with " .. targetServer.playing .. " players...",
                Duration = 2
            })
            
            TeleportService:TeleportToPlaceInstance(
                placeId,
                targetServer.id,
                LocalPlayer
            )
            
            print("[SERVER HOP] Teleport initiated")
        end)
        
        if not success then
            warn("[SERVER HOP] ERROR: " .. tostring(result))
            
            WindUI:Notify({
                Title = "Server Hop Failed",
                Content = tostring(result),
                Duration = 5
            })
        end
    end
    
    -- ==================== BOTON SERVER HOP: 7+ JUGADORES ====================
    MiscTab:Button({
        Title = "Hop to Old Server",
        Desc = "10 or more players",
        Callback = function()
            print("[SERVER HOP] Button pressed: 7+ players")
            
            WindUI:Notify({
                Title = "Server Hop",
                Content = "Searching for populated servers...",
                Duration = 1.5
            })
            
            task.spawn(function()
                serverHop(10, 20)
            end)
        end
    })
    
    MiscTab:Space()
    
    -- ==================== BOTON SERVER HOP: 1-5 JUGADORES ====================
    MiscTab:Button({
        Title = "Hop to New Server",
        Desc = "1 to 6 players",
        Callback = function()
            print("[SERVER HOP] Button pressed: 1-6 players")
            
            WindUI:Notify({
                Title = "Server Hop",
                Content = "Searching for low-pop servers...",
                Duration = 1.5
            })
            
            task.spawn(function()
                serverHop(1, 6)
            end)
        end
    })
    
    MiscTab:Space()
    
    
    print("[MISC TAB] Content loaded successfully!")
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
        Title = "Matches Before Returning to Lobby",
        Desc = "",
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
    
local AutoReturnToggle

AutoReturnToggle = AntiBanTab:Toggle({
    Flag = "EnableAutoReturn",
    Title = "Enable Auto Return",
    Desc = "",
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

-- ✅ GUARDAR REFERENCIA GLOBAL
getgenv().AntiBanToggles = getgenv().AntiBanToggles or {}
getgenv().AntiBanToggles.AutoReturn = AutoReturnToggle
    
    AntiBanTab:Space()
    
    local AntiAFKToggle
    
    AntiAFKToggle = AntiBanTab:Toggle({
        Flag = "EnableAntiAFK",
        Title = "Enable Anti-AFK",
        Desc = "",
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

-- ==================== MONITOR DE LOBBY PARA AUTO-DESACTIVAR TOGGLES ====================
task.spawn(function()
    while task.wait(2) do
        local currentMap = getCurrentMap()
        
        if currentMap == "map_lobby" then
            -- ✅ DESACTIVAR AUTO RETURN SI ESTÁ ACTIVO
            if getgenv().AntiBanConfig.AutoReturnEnabled then
                getgenv().AntiBanConfig.AutoReturnEnabled = false
                if getgenv().AntiBanToggles and getgenv().AntiBanToggles.AutoReturn then
                    getgenv().AntiBanToggles.AutoReturn:Set(false)
                end
                print("[AUTO RETURN] ⛔ Disabled - Detected in lobby")
            end
            
            -- ✅ DESACTIVAR ANTI-AFK SI ESTÁ ACTIVO
            if getgenv().AntiBanConfig.AntiAFKEnabled then
                getgenv().AntiBanConfig.AntiAFKEnabled = false
                if getgenv().AntiBanToggles and getgenv().AntiBanToggles.AntiAFK then
                    getgenv().AntiBanToggles.AntiAFK:Set(false)
                end
                print("[ANTI-AFK] ⛔ Disabled - Detected in lobby")
            end
        end
    end
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
        Title = "",
        TextSize = 14,
        TextTransparency = 0.5,
    })
    
    WebhookTab:Space()

    WebhookTab:Input({
        Flag = "WebhookURL",
        Title = "Webhook Link",
        Desc = "",
        Type = "Input",
        Value = getgenv().WebhookConfig.URL,
        Placeholder = "",
        Callback = function(input)
            getgenv().WebhookConfig.URL = input
            saveWebhookConfig()
            
            if input ~= "" and input ~= nil then
                WindUI:Notify({
                    Title = "Webhook Saved",
                    Content = "Stats will be sent automatically after each match",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "Webhook Removed",
                    Content = "Webhook notifications disabled",
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
            if getgenv().WebhookConfig.URL == "" then
                WindUI:Notify({
                    Title = "No URL Configured",
                    Content = "Please enter a Webhook URL first!",
                    Duration = 3
                })
                return
            end
            
            if sendWebhook(nil, true) then
                WindUI:Notify({
                    Title = "Test Sent",
                    Content = "Check your Discord Channel!",
                    Duration = 3
                })
            end
        end
    })

   -- WebhookTab:Space()

  --  WebhookTab:Section({
   --     Title = "Webhook Status: " .. (getgenv().WebhookConfig.URL ~= "" and "Active" or "Not Configured"),
   --     TextSize = 14,
   --     TextTransparency = 0.5,
   -- })
    
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
    
    SettingsTab:Space()
    
-- ==================== FUNCIONES HELPER ====================
    
    local function saveCompleteConfig(configName)
        if not configName or configName == "" then return false end
        
        local configData = {
            MainTab_AutoSkip = getgenv().MainTabConfig.AutoSkip,
            MainTab_AutoSpeed2x = getgenv().MainTabConfig.AutoSpeed2x,
            MainTab_AutoSpeed3x = getgenv().MainTabConfig.AutoSpeed3x,
            MainTab_AutoPlayAgain = getgenv().MainTabConfig.AutoPlayAgain,
            MainTab_AutoReturn = getgenv().MainTabConfig.AutoReturn,
            MainTab_AutoDifficulty = getgenv().MainTabConfig.AutoDifficulty,
            MainTab_AutoJoinMap = getgenv().MainTabConfig.AutoJoinMap,
            MainTab_SelectedDifficulty = getgenv().MainTabConfig.SelectedDifficulty,
            MainTab_SelectedDifficultyName = getgenv().MainTabConfig.SelectedDifficultyName,
            MainTab_SelectedMap = getgenv().MainTabConfig.SelectedMap,
            MainTab_SelectedMapName = getgenv().MainTabConfig.SelectedMapName,
            AutoFarm_GraveyardV1Active = getgenv().AutoFarmConfig.GraveyardV1Active,
            AutoFarm_GraveyardV2Active = getgenv().AutoFarmConfig.GraveyardV2Active,
            AutoFarm_DojoActive = getgenv().AutoFarmConfig.DojoActive,
            AutoFarm_AutoWinV1Active = getgenv().AutoFarmConfig.AutoWinV1Active,
            AutoFarm_AutoWinV2Active = getgenv().AutoFarmConfig.AutoWinV2Active,
            AntiBan_PlacementOffset = getgenv().AntiBanConfig.PlacementOffset,
            AntiBan_MatchesBeforeReturn = getgenv().AntiBanConfig.MatchesBeforeReturn,
            AntiBan_AutoReturnEnabled = getgenv().AntiBanConfig.AutoReturnEnabled,
            AntiBan_AntiAFKEnabled = getgenv().AntiBanConfig.AntiAFKEnabled,
            Performance_RenderStopped = getgenv().PerformanceConfig.RenderStopped,
            Performance_BlackScreenEnabled = getgenv().PerformanceConfig.BlackScreenEnabled,
            Performance_LowGraphicsEnabled = getgenv().LowGraphicsConfig.Enabled,
            Webhook_URL = getgenv().WebhookConfig.URL
        }
        
        if not isfolder("NoahScriptHub") then makefolder("NoahScriptHub") end
        if not isfolder("NoahScriptHub/Configs") then makefolder("NoahScriptHub/Configs") end
        
        local success = pcall(function()
            local jsonData = game:GetService("HttpService"):JSONEncode(configData)
            writefile("NoahScriptHub/Configs/" .. configName .. ".json", jsonData)
        end)
        
        return success
    end
    
    local function loadCompleteConfig(configName)
        if not configName or configName == "" then return false end
        
        local configPath = "NoahScriptHub/Configs/" .. configName .. ".json"
        if not isfile(configPath) then return false end
        
        local success, configData = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(configPath))
        end)
        
        if not success or not configData then return false end
        
        getgenv().MainTabConfig.AutoSkip = configData.MainTab_AutoSkip or false
        getgenv().MainTabConfig.AutoSpeed2x = configData.MainTab_AutoSpeed2x or false
        getgenv().MainTabConfig.AutoSpeed3x = configData.MainTab_AutoSpeed3x or false
        getgenv().MainTabConfig.AutoPlayAgain = configData.MainTab_AutoPlayAgain or false
        getgenv().MainTabConfig.AutoReturn = configData.MainTab_AutoReturn or false
        getgenv().MainTabConfig.AutoDifficulty = configData.MainTab_AutoDifficulty or false
        getgenv().MainTabConfig.AutoJoinMap = configData.MainTab_AutoJoinMap or false
        getgenv().MainTabConfig.SelectedDifficulty = configData.MainTab_SelectedDifficulty
        getgenv().MainTabConfig.SelectedDifficultyName = configData.MainTab_SelectedDifficultyName
        getgenv().MainTabConfig.SelectedMap = configData.MainTab_SelectedMap
        getgenv().MainTabConfig.SelectedMapName = configData.MainTab_SelectedMapName
        
        getgenv().AutoFarmConfig.GraveyardV1Active = configData.AutoFarm_GraveyardV1Active or false
        getgenv().AutoFarmConfig.GraveyardV2Active = configData.AutoFarm_GraveyardV2Active or false
        getgenv().AutoFarmConfig.DojoActive = configData.AutoFarm_DojoActive or false
        getgenv().AutoFarmConfig.AutoWinV1Active = configData.AutoFarm_AutoWinV1Active or false
        getgenv().AutoFarmConfig.AutoWinV2Active = configData.AutoFarm_AutoWinV2Active or false
        
        getgenv().AntiBanConfig.PlacementOffset = configData.AntiBan_PlacementOffset or 1.5
        getgenv().AntiBanConfig.MatchesBeforeReturn = configData.AntiBan_MatchesBeforeReturn or 100
        getgenv().AntiBanConfig.AutoReturnEnabled = configData.AntiBan_AutoReturnEnabled or false
        getgenv().AntiBanConfig.AntiAFKEnabled = configData.AntiBan_AntiAFKEnabled or false
        
        getgenv().PerformanceConfig.RenderStopped = configData.Performance_RenderStopped or false
        getgenv().PerformanceConfig.BlackScreenEnabled = configData.Performance_BlackScreenEnabled or false
        getgenv().LowGraphicsConfig.Enabled = configData.Performance_LowGraphicsEnabled or false
        
        getgenv().WebhookConfig.URL = configData.Webhook_URL or ""

        
        if getgenv().MainTabToggles.AutoSkip then getgenv().MainTabToggles.AutoSkip:Set(getgenv().MainTabConfig.AutoSkip) end
        if getgenv().MainTabToggles.AutoSpeed2x then getgenv().MainTabToggles.AutoSpeed2x:Set(getgenv().MainTabConfig.AutoSpeed2x) end
        if getgenv().MainTabToggles.AutoSpeed3x then getgenv().MainTabToggles.AutoSpeed3x:Set(getgenv().MainTabConfig.AutoSpeed3x) end
        if getgenv().MainTabToggles.AutoPlayAgain then getgenv().MainTabToggles.AutoPlayAgain:Set(getgenv().MainTabConfig.AutoPlayAgain) end
        if getgenv().MainTabToggles.AutoDifficulty then getgenv().MainTabToggles.AutoDifficulty:Set(getgenv().MainTabConfig.AutoDifficulty) end
        if getgenv().MainTabToggles.AutoJoinMap then getgenv().MainTabToggles.AutoJoinMap:Set(getgenv().MainTabConfig.AutoJoinMap) end
        if getgenv().AntiBanToggles.AntiAFK then getgenv().AntiBanToggles.AntiAFK:Set(getgenv().AntiBanConfig.AntiAFKEnabled) end
        if getgenv().PerformanceModeToggle then getgenv().PerformanceModeToggle:Set(getgenv().PerformanceConfig.RenderStopped) end
        if getgenv().BlackScreenToggle then getgenv().BlackScreenToggle:Set(getgenv().PerformanceConfig.BlackScreenEnabled) end
        if getgenv().LowGraphicsToggle then getgenv().LowGraphicsToggle:Set(getgenv().LowGraphicsConfig.Enabled) end
        
        local autoFarmToActivate = nil
        if configData.AutoFarm_GraveyardV1Active then autoFarmToActivate = "GraveyardV1"
        elseif configData.AutoFarm_GraveyardV2Active then autoFarmToActivate = "GraveyardV2"
        elseif configData.AutoFarm_DojoActive then autoFarmToActivate = "Dojo"
        elseif configData.AutoFarm_AutoWinV1Active then autoFarmToActivate = "AutoWinV1"
        elseif configData.AutoFarm_AutoWinV2Active then autoFarmToActivate = "AutoWinV2"
        end
        
        if autoFarmToActivate and getgenv().AutoFarmToggles and getgenv().AutoFarmToggles[autoFarmToActivate] then
            task.spawn(function()
                task.wait(0.1)
                getgenv().AutoFarmToggles[autoFarmToActivate]:Set(true)
            end)
        end
        
        return true
    end
    
    local function deleteConfig(configName)
        if not configName or configName == "" then return false end
        
        local configPath = "NoahScriptHub/Configs/" .. configName .. ".json"
        
        if not isfile(configPath) then 
            warn("[SETTINGS] Config file not found: " .. configPath)
            return false 
        end
        
        local success = pcall(function()
            delfile(configPath)
            print("[SETTINGS] ✓ Deleted config file: " .. configPath)
        end)
        
        if not success then
            warn("[SETTINGS] ✗ Failed to delete config: " .. configName)
        end
        
        return success
    end
    
    local function getAllConfigs()
        if not isfolder("NoahScriptHub/Configs") then return {} end
        
        local configs = {}
        pcall(function()
            for _, file in pairs(listfiles("NoahScriptHub/Configs")) do
                local fileName = file:match("([^/\\]+)%.json$")
                if fileName then table.insert(configs, fileName) end
            end
        end)
        
        return configs
    end
    
    local function setAutoLoadConfig(configName)
        if not isfolder("NoahScriptHub") then makefolder("NoahScriptHub") end
        
        local success = pcall(function()
            writefile("NoahScriptHub/AutoLoad.txt", configName)
        end)
        
        return success
    end
    
    local function getAutoLoadConfig()
        if not isfile("NoahScriptHub/AutoLoad.txt") then return nil end
        
        local success, configName = pcall(function()
            return readfile("NoahScriptHub/AutoLoad.txt")
        end)
        
        return (success and configName and configName ~= "") and configName or nil
    end
    
    local function removeAutoLoadConfig()
        if not isfile("NoahScriptHub/AutoLoad.txt") then return false end
        
        local success = pcall(function()
            delfile("NoahScriptHub/AutoLoad.txt")
        end)
        
        return success
    end

    -- ==================== UI ELEMENTS ====================
    
    local ConfigListDropdown
    local NewConfigInput
    local SetAutoloadButton
    
    NewConfigInput = SettingsTab:Input({
        Flag = "NewConfigName",
        Title = "Config Name",
        Desc = "",
        Type = "Input",
        Placeholder = "",
        Callback = function(input)
            if input ~= "" then
                NewConfigInput:Highlight()
            end
        end
    })
    
    SettingsTab:Space()
    
    local function refreshDropdown()
        local configs = getAllConfigs()
        local dropdownValues = {}
        
        for _, name in ipairs(configs) do
            table.insert(dropdownValues, { Title = name })
        end
        
        if #dropdownValues == 0 then
            dropdownValues = {{ Title = "No configs saved" }}
        end
        
        if ConfigListDropdown then
            ConfigListDropdown:Refresh(dropdownValues)
        end
    end
    
    ConfigListDropdown = SettingsTab:Dropdown({
        Flag = "ConfigList",
        Title = "Config List",
        Values = {},
        Callback = function(option)
            if option.Title ~= "No configs saved" then
                ConfigListDropdown:Highlight()
                print("[SETTINGS] Selected config: " .. option.Title)
            end
        end
    })
    
    refreshDropdown()
    
    SettingsTab:Space()
    
    SettingsTab:Button({
        Title = "Create Config",
        Desc = "",
        Callback = function()
            local configName = NewConfigInput.Value
            
            if not configName or configName == "" then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Please enter a config name!",
                    Duration = 3
                })
                return
            end
            
            local success = saveCompleteConfig(configName)
            
            if success then
                refreshDropdown()
                ConfigListDropdown:Select(configName)
                
                WindUI:Notify({
                    Title = "Config Created",
                    Content = "'" .. configName .. "' saved successfully!",
                    Duration = 3
                })
                print("[SETTINGS] Config '" .. configName .. "' created")
            else
                WindUI:Notify({
                    Title = "Save Failed",
                    Content = "Failed to save configuration",
                    Duration = 3
                })
            end
        end
    })

        SettingsTab:Space()

    SettingsTab:Button({
        Title = "Delete Config",
        Desc = "",
        Callback = function()
            -- ✅ EXTRAER EL VALOR CORRECTO DEL DROPDOWN
            local selectedValue = ConfigListDropdown.Value
            local selected = nil
            
            -- Si es una tabla (comportamiento de WindUI)
            if type(selectedValue) == "table" then
                selected = selectedValue.Title or selectedValue[1]
            else
                selected = selectedValue
            end
            
            print("[SETTINGS] Delete button pressed. Selected: " .. tostring(selected))
            
            if not selected or selected == "" or selected == "No configs saved" then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Please select a config to delete!",
                    Duration = 3
                })
                return
            end
            
            print("[SETTINGS] Attempting to delete: " .. selected)
            
            local success = deleteConfig(selected)
            
            if success then
                print("[SETTINGS] ✓ Delete successful, refreshing dropdown...")
                
                task.wait(0.1)
                refreshDropdown()
                
                local currentAutoload = getAutoLoadConfig()
                if currentAutoload == selected then
                    removeAutoLoadConfig()
                    if SetAutoloadButton then
                        SetAutoloadButton:SetDesc("Load selected config on startup")
                    end
                    print("[SETTINGS] Autoload removed because config was deleted")
                end
                
                WindUI:Notify({
                    Title = "Config Deleted",
                    Content = "'" .. selected .. "' has been deleted!",
                    Duration = 3
                })
                print("[SETTINGS] ✓ Config deleted: " .. selected)
            else
                WindUI:Notify({
                    Title = "Delete Failed",
                    Content = "Config '" .. selected .. "' not found!",
                    Duration = 3
                })
                warn("[SETTINGS] ✗ Failed to delete: " .. selected)
            end
        end
    })
    
    
    SettingsTab:Space()
    
    SettingsTab:Button({
        Title = "Load Config",
        Desc = "",
        Callback = function()
            -- ✅ EXTRAER VALOR CORRECTO
            local selectedValue = ConfigListDropdown.Value
            local selected = type(selectedValue) == "table" and (selectedValue.Title or selectedValue[1]) or selectedValue
            
            if not selected or selected == "No configs saved" then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Please select a config from the list!",
                    Duration = 3
                })
                return
            end
            
            local success = loadCompleteConfig(selected)
            
            if success then
                WindUI:Notify({
                    Title = "Config Loaded",
                    Content = "'" .. selected .. "' loaded successfully!",
                    Duration = 3
                })
                print("[SETTINGS] Config '" .. selected .. "' loaded")
            else
                WindUI:Notify({
                    Title = "Load Failed",
                    Content = "Failed to load '" .. selected .. "'",
                    Duration = 3
                })
            end
        end
    })
    
    SettingsTab:Space()
    
SettingsTab:Button({
        Title = "Overwrite Config",
        Desc = "",
        Callback = function()
            -- ✅ EXTRAER VALOR CORRECTO
            local selectedValue = ConfigListDropdown.Value
            local selected = type(selectedValue) == "table" and (selectedValue.Title or selectedValue[1]) or selectedValue
            
            if not selected or selected == "No configs saved" then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Please select a config to overwrite!",
                    Duration = 3
                })
                return
            end
            
            local success = saveCompleteConfig(selected)
            
            if success then
                WindUI:Notify({
                    Title = "Config Overwritten",
                    Content = "'" .. selected .. "' updated successfully!",
                    Duration = 3
                })
                print("[SETTINGS] Config '" .. selected .. "' overwritten")
            else
                WindUI:Notify({
                    Title = "Overwrite Failed",
                    Content = "Failed to overwrite configuration",
                    Duration = 3
                })
            end
        end
    })
    
    SettingsTab:Space()
    
    
    SettingsTab:Button({
        Title = "Refresh List",
        Desc = "",
        Callback = function()
            refreshDropdown()
            WindUI:Notify({
                Title = "List Refreshed",
                Content = "Config list updated",
                Duration = 2
            })
        end
    })
    
    SettingsTab:Space()
    
    local currentAutoload = getAutoLoadConfig()
    
        SetAutoloadButton = SettingsTab:Button({
        Title = "Set as Autoload",
        Desc = currentAutoload and ("Current: '" .. currentAutoload .. "'") or "",
        Callback = function()
            -- ✅ EXTRAER VALOR CORRECTO
            local selectedValue = ConfigListDropdown.Value
            local selected = type(selectedValue) == "table" and (selectedValue.Title or selectedValue[1]) or selectedValue
            
            if not selected or selected == "No configs saved" then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Please select a config!",
                    Duration = 3
                })
                return
            end
            
            local success = setAutoLoadConfig(selected)
            
            if success then
                SetAutoloadButton:SetDesc("Current: '" .. selected .. "'")
                
                WindUI:Notify({
                    Title = "Autoload Set",
                    Content = "'" .. selected .. "' will load on startup",
                    Duration = 3
                })
                print("[SETTINGS] Autoload set to: " .. selected)
            else
                WindUI:Notify({
                    Title = "Failed",
                    Content = "Failed to set autoload",
                    Duration = 3
                })
            end
        end
    })
    
    SettingsTab:Space()
    
    SettingsTab:Button({
        Title = "Remove Autoload",
        Desc = "",
        Callback = function()
            local currentAutoLoad = getAutoLoadConfig()
            
            if not currentAutoLoad then
                WindUI:Notify({
                    Title = "No Autoload",
                    Content = "Autoload is not currently set",
                    Duration = 3
                })
                return
            end
            
            local success = removeAutoLoadConfig()
            
            if success then
                SetAutoloadButton:SetDesc("Load selected config on startup")
                
                WindUI:Notify({
                    Title = "Autoload Removed",
                    Content = "Autoload disabled",
                    Duration = 3
                })
                print("[SETTINGS] Autoload removed")
            else
                WindUI:Notify({
                    Title = "Failed",
                    Content = "Failed to remove autoload",
                    Duration = 3
                })
            end
        end
    })
    
    print("[SETTINGS TAB] Content loaded successfully!")
end)
