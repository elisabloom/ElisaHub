--// Garden Tower Defense - FULL MACRO WITH FIXED RECORDER
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Rain-Design/Libraries/main/Shaman/Library.lua'))()
local Flags = Library.Flags

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")
local Workspace = game:GetService("Workspace")
local entities = Workspace:WaitForChild("Map"):WaitForChild("Entities")
local RunService = game:GetService("RunService")

-- Settings
local Settings = {
    MacroEnabled = false,
    PositionOffset = 2,
    AutoWalk = false,
}

-- Recorder Settings
local Recorder = {
    IsRecording = false,
    StartTime = 0,
    Actions = {},
    MacroName = "MyMacro",
    LastPlacedUnit = nil
}

-- Track units
_G.myUnitIDs = _G.myUnitIDs or {}
_G.trackingEnabled = false
_G.upgradeLoopRunning = false
_G.autoWalkConnection = nil
_G.recordedUnits = {}

--// UI CREATION
local Window = Library:Window({
    Text = "🌻 GTD Macro"
})

local FarmTab = Window:Tab({
    Text = "Farm"
})

local AntiBanTab = Window:Tab({
    Text = "Anti-Ban"
})

local RecorderTab = Window:Tab({
    Text = "Recorder"
})

-- Farm Section
local FarmSection = FarmTab:Section({
    Text = "Auto Farm"
})

-- Anti-Ban Section
local AntiBanSection = AntiBanTab:Section({
    Text = "Humanization"
})

local MovementSection = AntiBanTab:Section({
    Text = "Movement",
    Side = "Right"
})

-- Recorder Section
local RecorderSection = RecorderTab:Section({
    Text = "Recording"
})

local SavedMacrosSection = RecorderTab:Section({
    Text = "Saved Macros",
    Side = "Right"
})

-- Status Labels
local StatusLabel
local RecorderStatusLabel

--// FARM TAB
FarmSection:Toggle({
    Text = "Auto Normal",
    Tooltip = "Automatically farms Normal difficulty with Voltshade + Rainbow Tomato strategy",
    Callback = function(enabled)
        Settings.MacroEnabled = enabled
        if enabled then
            warn("🚀 MACRO STARTED!")
            if StatusLabel then
                StatusLabel:Set({Text = "Status: Running", Color = Color3.fromRGB(0, 255, 100)})
            end
            task.spawn(runMacro)
        else
            warn("⏹️ MACRO STOPPED!")
            if StatusLabel then
                StatusLabel:Set({Text = "Status: Stopped", Color = Color3.fromRGB(255, 100, 100)})
            end
            _G.trackingEnabled = false
            _G.upgradeLoopRunning = false
            stopAutoWalk()
        end
    end
})

StatusLabel = FarmSection:Label({
    Text = "Status: Idle",
    Color = Color3.fromRGB(150, 150, 150)
})

--// ANTI-BAN TAB
AntiBanSection:Slider({
    Text = "Position Offset (studs)",
    Default = 2,
    Minimum = 0,
    Maximum = 5,
    Callback = function(value)
        Settings.PositionOffset = value
        warn("[SETTINGS] Position offset: " .. value)
    end
})

MovementSection:Toggle({
    Text = "Auto Walk",
    Tooltip = "Randomly walks around during the game (AI movement pattern)",
    Callback = function(enabled)
        Settings.AutoWalk = enabled
        if enabled then
            warn("[AUTO WALK] Enabled")
            if _G.trackingEnabled then
                startAutoWalk()
            end
        else
            warn("[AUTO WALK] Disabled")
            stopAutoWalk()
        end
    end
})

--// RECORDER TAB
RecorderSection:Input({
    Placeholder = "Macro Name",
    Flag = "MacroName",
    Callback = function(text)
        Recorder.MacroName = text
        warn("[RECORDER] Macro name set to: " .. text)
    end
})

RecorderSection:Toggle({
    Text = "Start Recording",
    Tooltip = "Start recording your manual gameplay",
    Callback = function(enabled)
        if enabled then
            startRecording()
        else
            stopRecording()
        end
    end
})

RecorderSection:Button({
    Text = "Save Recording",
    Tooltip = "Save the current recording to file",
    Callback = function()
        saveRecording()
    end
})

RecorderStatusLabel = RecorderSection:Label({
    Text = "Status: Not Recording",
    Color = Color3.fromRGB(150, 150, 150)
})

--// MACRO FUNCTIONS

-- Random position offset
local function getRandomOffset()
    local offset = Settings.PositionOffset
    return Vector3.new(
        math.random(-offset * 10, offset * 10) / 10,
        0,
        math.random(-offset * 10, offset * 10) / 10
    )
end

-- AI Auto Walk function (50 stud radius)
function startAutoWalk()
    if _G.autoWalkConnection then
        stopAutoWalk()
    end
    
    local walkCooldown = 0
    local isWalking = false
    
    _G.autoWalkConnection = RunService.Heartbeat:Connect(function(deltaTime)
        if not Settings.AutoWalk or not _G.trackingEnabled then
            return
        end
        
        walkCooldown = walkCooldown - deltaTime
        
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
            local humanoid = char.Humanoid
            local hrp = char.HumanoidRootPart
            
            if walkCooldown <= 0 then
                if not isWalking then
                    isWalking = true
                    local walkDuration = math.random(30, 80) / 10
                    
                    local randomX = math.random(-50, 50)
                    local randomZ = math.random(-50, 50)
                    local targetPos = hrp.Position + Vector3.new(randomX, 0, randomZ)
                    
                    humanoid:MoveTo(targetPos)
                    walkCooldown = walkDuration
                else
                    isWalking = false
                    local idleDuration = math.random(20, 50) / 10
                    humanoid:MoveTo(hrp.Position)
                    walkCooldown = idleDuration
                end
            end
        end
    end)
end

function stopAutoWalk()
    if _G.autoWalkConnection then
        _G.autoWalkConnection:Disconnect()
        _G.autoWalkConnection = nil
    end
    
    local char = plr.Character
    if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        char.Humanoid:MoveTo(char.HumanoidRootPart.Position)
    end
end

local function getMoney()
    return plr:GetAttribute("Cash") or 0
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

-- Track placed units (for macro playback)
entities.ChildAdded:Connect(function(child)
    if _G.trackingEnabled then
        task.spawn(function()
            task.wait(1)
            if child and child.Parent and string.find(child.Name, "unit_") then
                local unitID = getUnitID(child)
                if unitID then
                    table.insert(_G.myUnitIDs, unitID)
                    warn("[✓ TRACKED] Unit ID: " .. unitID)
                end
            end
        end)
    end
    
    -- RECORDING: Detect unit placement
    if Recorder.IsRecording and Recorder.LastPlacedUnit then
        task.spawn(function()
            task.wait(0.5)
            if child and child.Parent and string.find(child.Name, "unit_") then
                local unitID = getUnitID(child)
                if unitID then
                    table.insert(_G.recordedUnits, unitID)
                    warn("[✓ RECORDER] Tracked unit ID: " .. unitID .. " for recording")
                end
            end
        end)
    end
end)

local function setupAutoSkip()
    task.spawn(function()
        task.wait(6)
        
        pcall(function()
            local gui = plr.PlayerGui:WaitForChild("GameGuiNoInset")
            local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")
            
            pcall(function()
                remotes.ToggleAutoSkip:InvokeServer(true)
            end)
            warn("[AUTO SKIP] Enabled")
            
            while _G.trackingEnabled do
                task.wait(0.8)
                pcall(function()
                    local c = autoSkipButton.ImageColor3
                    if c.R > 0.8 and c.G > 0.5 then
                        local conns = getconnections(autoSkipButton.MouseButton1Click)
                        if conns and #conns > 0 then
                            conns[1]:Fire()
                        end
                    end
                end)
            end
        end)
    end)
end

local function setupGame()
    remotes.PlaceDifficultyVote:InvokeServer("dif_normal")
    remotes.ChangeTickSpeed:InvokeServer(3)
    setupAutoSkip()
    warn("[GAME SETUP] Complete")
end

-- Base placements for Auto Normal
local basePlacements = {
    {
        time = 5,
        unit = "unit_tomato_rainbow",
        cost = 100,
        position = Vector3.new(-850.7767333984375, 61.93030548095703, -155.0453338623047),
        rotation = 180
    },
    {
        time = 53,
        unit = "unit_tomato_rainbow",
        cost = 100,
        position = Vector3.new(-852.2405395507812, 61.93030548095703, -150.1680450439453),
        rotation = 180
    },
    {
        time = 100,
        unit = "unit_metal_flower",
        cost = 2250,
        position = Vector3.new(-850.2332153320312, 61.93030548095703, -151.0040740966797),
        rotation = 180
    },
    {
        time = 130,
        unit = "unit_metal_flower",
        cost = 2250,
        position = Vector3.new(-853.2742919921875, 61.93030548095703, -146.7690887451172),
        rotation = 180
    }
}

local function generateRandomizedPlacements()
    local randomized = {}
    
    for _, base in ipairs(basePlacements) do
        local posOffset = getRandomOffset()
        local newPos = base.position + posOffset
        
        table.insert(randomized, {
            time = base.time,
            unit = base.unit,
            cost = base.cost,
            data = {
                Valid = true,
                Rotation = base.rotation,
                CF = CFrame.new(newPos.X, newPos.Y, newPos.Z, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1),
                Position = newPos
            }
        })
    end
    
    return randomized
end

local function placeUnits(placements)
    for _, placement in ipairs(placements) do
        task.delay(placement.time, function()
            local waitTime = 0
            while getMoney() < placement.cost and waitTime < 60 do
                task.wait(1)
                waitTime = waitTime + 1
            end
            
            if getMoney() >= placement.cost then
                local success = pcall(function()
                    return remotes.PlaceUnit:InvokeServer(placement.unit, placement.data)
                end)
                
                if success then
                    warn("[PLACED] " .. placement.unit)
                end
            end
        end)
    end
end

local function startUpgrades()
    _G.upgradeLoopRunning = true
    
    task.spawn(function()
        task.wait(15)
        
        while _G.upgradeLoopRunning and _G.trackingEnabled do
            if #_G.myUnitIDs > 0 then
                for _, unitID in ipairs(_G.myUnitIDs) do
                    if not _G.upgradeLoopRunning then break end
                    
                    if getMoney() >= 125 then
                        pcall(function()
                            remotes.UpgradeUnit:InvokeServer(unitID)
                        end)
                        task.wait(0.5)
                    end
                end
            end
            task.wait(2)
        end
    end)
end

function runMacro()
    while Settings.MacroEnabled do
        warn("========================================")
        warn("[GAME START] Starting new game...")
        warn("========================================")
        
        _G.myUnitIDs = {}
        _G.trackingEnabled = true
        _G.upgradeLoopRunning = false
        
        local randomizedPlacements = generateRandomizedPlacements()
        
        setupGame()
        placeUnits(randomizedPlacements)
        startUpgrades()
        
        if Settings.AutoWalk then
            startAutoWalk()
        end
        
        task.wait(267)
        
        _G.trackingEnabled = false
        _G.upgradeLoopRunning = false
        stopAutoWalk()
        
        task.wait(2)
        
        warn("[RESTART] Restarting game...")
        pcall(function()
            remotes.RestartGame:InvokeServer()
        end)
        
        task.wait(8)
    end
end

--// RECORDER FUNCTIONS

function getUnitCost(unitType)
    local costs = {
        unit_tomato_rainbow = 100,
        unit_metal_flower = 2250,
        unit_golem_dragon = 5000,
        unit_eyeball = 4500,
        unit_punch_potato = 2500,
        unit_lucky_plant = 1500,
        unit_eye_petal = 5500,
        unit_confusion_plant = 1000
    }
    return costs[unitType] or 0
end

function startRecording()
    Recorder.IsRecording = true
    Recorder.StartTime = tick()
    Recorder.Actions = {}
    _G.recordedUnits = {}
    warn("[RECORDER] 🔴 Started recording!")
    RecorderStatusLabel:Set({Text = "🔴 Recording... (0 actions)", Color = Color3.fromRGB(255, 100, 100)})
end

function stopRecording()
    Recorder.IsRecording = false
    warn("[RECORDER] ⏹️ Stopped recording! Total actions: " .. #Recorder.Actions)
    RecorderStatusLabel:Set({Text = "⏹️ Stopped (" .. #Recorder.Actions .. " actions)", Color = Color3.fromRGB(255, 200, 0)})
end

function updateRecorderStatus()
    if Recorder.IsRecording and RecorderStatusLabel then
        RecorderStatusLabel:Set({Text = "🔴 Recording... (" .. #Recorder.Actions .. " actions)", Color = Color3.fromRGB(255, 100, 100)})
    end
end

-- FIXED HOOK: Record without thread issues
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Record PlaceUnit calls (capture data BEFORE calling original)
    if method == "InvokeServer" and self.Name == "PlaceUnit" and Recorder.IsRecording then
        local unitType = args[1]
        local data = args[2]
        local elapsedTime = tick() - Recorder.StartTime
        
        -- Extract data immediately (before thread switch)
        local recordData = {
            time = math.floor(elapsedTime * 10) / 10,
            type = "place",
            unit = unitType,
            cframe = data.CF,
            position = Vector3.new(data.Position.X, data.Position.Y, data.Position.Z),
            rotation = data.Rotation,
            cost = getUnitCost(unitType)
        }
        
        -- Now safely add to table in a deferred thread
        task.defer(function()
            table.insert(Recorder.Actions, recordData)
            warn(string.format("[RECORDED] 📍 Placed %s at %.1fs", unitType, elapsedTime))
            
            -- Update status safely
            pcall(function()
                if Recorder.IsRecording and RecorderStatusLabel then
                    RecorderStatusLabel:Set({
                        Text = "🔴 Recording... (" .. #Recorder.Actions .. " actions)", 
                        Color = Color3.fromRGB(255, 100, 100)
                    })
                end
            end)
        end)
    end
    
    -- Record SellUnit calls
    if method == "InvokeServer" and self.Name == "SellUnit" and Recorder.IsRecording then
        local unitID = args[1]
        local unitIndex = table.find(_G.recordedUnits, unitID)
        local elapsedTime = tick() - Recorder.StartTime
        
        if unitIndex then
            local recordData = {
                time = math.floor(elapsedTime * 10) / 10,
                type = "sell",
                unitIndex = unitIndex
            }
            
            task.defer(function()
                table.insert(Recorder.Actions, recordData)
                warn(string.format("[RECORDED] 💰 Sold unit #%d at %.1fs", unitIndex, elapsedTime))
                
                pcall(function()
                    if Recorder.IsRecording and RecorderStatusLabel then
                        RecorderStatusLabel:Set({
                            Text = "🔴 Recording... (" .. #Recorder.Actions .. " actions)", 
                            Color = Color3.fromRGB(255, 100, 100)
                        })
                    end
                end)
            end)
        end
    end
    
    return oldNamecall(self, ...)
end)

function saveRecording()
    if #Recorder.Actions == 0 then
        warn("[RECORDER] ❌ No actions to save!")
        RecorderStatusLabel:Set({Text = "❌ No actions recorded!", Color = Color3.fromRGB(255, 0, 0)})
        return
    end
    
    local macroName = Recorder.MacroName
    if macroName == "" or macroName == "MyMacro" then
        macroName = "Macro_" .. os.time()
    end
    
    -- Remove invalid filename characters
    macroName = macroName:gsub("[^%w_%-]", "_")
    
    local macroData = {
        name = macroName,
        actions = Recorder.Actions,
        createdAt = os.date("%Y-%m-%d %H:%M:%S")
    }
    
    local macroScript = "return " .. tableToString(macroData)
    
    pcall(function()
        if not isfolder("SimpleSpy") then
            makefolder("SimpleSpy")
        end
        if not isfolder("SimpleSpy/Macros") then
            makefolder("SimpleSpy/Macros")
        end
    end)
    
    local success, err = pcall(function()
        writefile("SimpleSpy/Macros/" .. macroName .. ".lua", macroScript)
    end)
    
    if success then
        warn("[RECORDER] ✅ Saved macro: " .. macroName)
        warn("[RECORDER] 📊 Actions recorded: " .. #Recorder.Actions)
        RecorderStatusLabel:Set({Text = "✅ Saved: " .. macroName, Color = Color3.fromRGB(0, 255, 100)})
        
        task.wait(1)
        loadSavedMacros()
    else
        warn("[RECORDER] ❌ Failed to save: " .. tostring(err))
        RecorderStatusLabel:Set({Text = "❌ Save failed!", Color = Color3.fromRGB(255, 0, 0)})
    end
end

function tableToString(tbl, indent)
    indent = indent or ""
    local result = "{\n"
    for k, v in pairs(tbl) do
        result = result .. indent .. "    "
        if type(k) == "string" then
            result = result .. '["' .. k .. '"] = '
        else
            result = result .. "[" .. k .. "] = "
        end
        
        if type(v) == "table" then
            result = result .. tableToString(v, indent .. "    ")
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '"'
        elseif typeof(v) == "Vector3" then
            result = result .. string.format("Vector3.new(%.10f, %.10f, %.10f)", v.X, v.Y, v.Z)
        elseif typeof(v) == "CFrame" then
            local components = {v:GetComponents()}
            result = result .. string.format("CFrame.new(%.10f, %.10f, %.10f, %.10f, %.10f, %.10f, %.10f, %.10f, %.10f, %.10f, %.10f, %.10f)", 
                unpack(components))
        else
            result = result .. tostring(v)
        end
        result = result .. ",\n"
    end
    return result .. indent .. "}"
end

function loadSavedMacros()
    -- Clear existing buttons first
    pcall(function()
        for _, child in pairs(SavedMacrosSection:GetDescendants()) do
            if child:IsA("TextButton") or child.ClassName == "Button" then
                pcall(function() child:Destroy() end)
            end
        end
    end)
    
    warn("[RECORDER] 📂 Loading saved macros...")
    
    -- Create folders if they don't exist
    pcall(function()
        if not isfolder("SimpleSpy") then
            makefolder("SimpleSpy")
            warn("[RECORDER] Created SimpleSpy folder")
        end
        if not isfolder("SimpleSpy/Macros") then
            makefolder("SimpleSpy/Macros")
            warn("[RECORDER] Created Macros folder")
        end
    end)
    
    local success, macros = pcall(function()
        return listfiles("SimpleSpy/Macros")
    end)
    
    if not success or not macros then
        warn("[RECORDER] ⚠️ No macros found or can't access folder")
        SavedMacrosSection:Label({
            Text = "No macros saved yet",
            Color = Color3.fromRGB(150, 150, 150)
        })
        return
    end
    
    local macroCount = 0
    for _, file in ipairs(macros) do
        if file:match("%.lua$") then
            macroCount = macroCount + 1
            local macroName = file:match("([^/\\]+)%.lua$")
            
            -- Play button
            SavedMacrosSection:Button({
                Text = "▶️ " .. macroName,
                Tooltip = "Click to play this macro",
                Callback = function()
                    warn("[RECORDER] Playing macro: " .. macroName)
                    playMacro(file)
                end
            })
            
            -- Delete button
            SavedMacrosSection:Button({
                Text = "🗑️ Delete",
                Tooltip = "Delete " .. macroName,
                Callback = function()
                    pcall(function()
                        delfile(file)
                        warn("[RECORDER] 🗑️ Deleted: " .. macroName)
                    end)
                    task.wait(0.2)
                    loadSavedMacros()
                end
            })
        end
    end
    
    warn("[RECORDER] ✅ Loaded " .. macroCount .. " macro(s)")
    
    if macroCount == 0 then
        SavedMacrosSection:Label({
            Text = "No macros saved yet",
            Color = Color3.fromRGB(150, 150, 150)
        })
    end
end

function playMacro(file)
    local success, macroScript = pcall(function()
        return readfile(file)
    end)
    
    if not success then
        warn("[MACRO] ❌ Failed to read file!")
        return
    end
    
    local macroData = loadstring(macroScript)()
    
    warn("========================================")
    warn("[MACRO] ▶️ Playing: " .. macroData.name)
    warn("[MACRO] Actions: " .. #macroData.actions)
    warn("========================================")
    
    _G.myUnitIDs = {}
    _G.trackingEnabled = true
    _G.upgradeLoopRunning = false
    _G.recordedUnits = {}
    
    setupGame()
    
    for _, action in ipairs(macroData.actions) do
        task.delay(action.time, function()
            if action.type == "place" then
                -- Apply position offset
                local posOffset = getRandomOffset()
                local originalCF = action.cframe
                local newCF = originalCF + posOffset
                
                local data = {
                    Valid = true,
                    Rotation = action.rotation,
                    CF = newCF,
                    Position = Vector3.new(newCF.X, newCF.Y, newCF.Z)
                }
                
                -- Wait for money
                local waitTime = 0
                while getMoney() < action.cost and waitTime < 60 do
                    task.wait(1)
                    waitTime = waitTime + 1
                end
                
                if getMoney() >= action.cost then
                    local success, result = pcall(function()
                        return remotes.PlaceUnit:InvokeServer(action.unit, data)
                    end)
                    if success then
                        table.insert(_G.recordedUnits, result)
                        warn("[MACRO] 📍 Placed " .. action.unit)
                    end
                end
            elseif action.type == "sell" then
                if _G.recordedUnits[action.unitIndex] then
                    pcall(function()
                        remotes.SellUnit:InvokeServer(_G.recordedUnits[action.unitIndex])
                    end)
                    warn("[MACRO] 💰 Sold unit #" .. action.unitIndex)
                end
            end
        end)
    end
    
    startUpgrades()
    
    if Settings.AutoWalk then
        startAutoWalk()
    end
end

task.wait(1)
loadSavedMacros()

FarmTab:Select()
warn("✅ GTD Macro UI Loaded with Fixed Recorder!")