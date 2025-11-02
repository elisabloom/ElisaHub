--// Garden Tower Defense - Macro Recorder & Player v2
--// Features: Named macros, Save/Load multiple macros

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

_G.macroRecording = false
_G.macroPlaying = false
_G.recordedMacro = _G.recordedMacro or {}
_G.savedMacros = _G.savedMacros or {}
_G.recordStartTime = nil
_G.placedUnits = {}
_G.currentMacroName = ""

local function createMacroGui()
    local existingGui = plr.PlayerGui:FindFirstChild("MacroRecorder")
    if existingGui then existingGui:Destroy() end
    
    local MacroGui = Instance.new("ScreenGui")
    MacroGui.Name = "MacroRecorder"
    MacroGui.ResetOnSpawn = false
    MacroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MacroGui.Parent = plr:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 450, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = MacroGui
    
    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "🎬 Macro Recorder & Player"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = MainFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 30)
    StatusLabel.Position = UDim2.new(0, 10, 0, 45)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    StatusLabel.Text = "⏸️ Status: Idle"
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 14
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.Parent = MainFrame
    
    local StatusCorner = Instance.new("UICorner", StatusLabel)
    StatusCorner.CornerRadius = UDim.new(0, 6)
    
    -- Macro Name Input
    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0, 100, 0, 35)
    NameLabel.Position = UDim2.new(0, 10, 0, 85)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = "Macro Name:"
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextSize = 13
    NameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = MainFrame
    
    local NameInput = Instance.new("TextBox")
    NameInput.Size = UDim2.new(1, -120, 0, 35)
    NameInput.Position = UDim2.new(0, 110, 0, 85)
    NameInput.PlaceholderText = "Enter macro name..."
    NameInput.Text = ""
    NameInput.Font = Enum.Font.Gotham
    NameInput.TextSize = 13
    NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    NameInput.BorderSizePixel = 0
    NameInput.ClearTextOnFocus = false
    NameInput.Parent = MainFrame
    
    local NameInputCorner = Instance.new("UICorner", NameInput)
    NameInputCorner.CornerRadius = UDim.new(0, 6)
    
    local RecordButton = Instance.new("TextButton")
    RecordButton.Size = UDim2.new(0.48, 0, 0, 45)
    RecordButton.Position = UDim2.new(0, 10, 0, 130)
    RecordButton.Text = "🔴 Start Recording"
    RecordButton.Font = Enum.Font.GothamBold
    RecordButton.TextSize = 15
    RecordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RecordButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    RecordButton.BorderSizePixel = 0
    RecordButton.Parent = MainFrame
    
    local RecordCorner = Instance.new("UICorner", RecordButton)
    RecordCorner.CornerRadius = UDim.new(0, 8)
    
    local StopButton = Instance.new("TextButton")
    StopButton.Size = UDim2.new(0.48, 0, 0, 45)
    StopButton.Position = UDim2.new(0.52, 0, 0, 130)
    StopButton.Text = "⏹️ Stop & Save"
    StopButton.Font = Enum.Font.GothamBold
    StopButton.TextSize = 15
    StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    StopButton.BorderSizePixel = 0
    StopButton.Parent = MainFrame
    
    local StopCorner = Instance.new("UICorner", StopButton)
    StopCorner.CornerRadius = UDim.new(0, 8)
    
    -- Saved Macros Section
    local SavedLabel = Instance.new("TextLabel")
    SavedLabel.Size = UDim2.new(1, -20, 0, 25)
    SavedLabel.Position = UDim2.new(0, 10, 0, 185)
    SavedLabel.BackgroundTransparency = 1
    SavedLabel.Text = "📁 Saved Macros:"
    SavedLabel.Font = Enum.Font.GothamBold
    SavedLabel.TextSize = 14
    SavedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SavedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SavedLabel.Parent = MainFrame
    
    local MacroListFrame = Instance.new("ScrollingFrame")
    MacroListFrame.Size = UDim2.new(1, -20, 0, 150)
    MacroListFrame.Position = UDim2.new(0, 10, 0, 215)
    MacroListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MacroListFrame.BorderSizePixel = 0
    MacroListFrame.ScrollBarThickness = 6
    MacroListFrame.Parent = MainFrame
    
    local MacroListCorner = Instance.new("UICorner", MacroListFrame)
    MacroListCorner.CornerRadius = UDim.new(0, 8)
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = MacroListFrame
    
    -- Action Preview Section
    local PreviewLabel = Instance.new("TextLabel")
    PreviewLabel.Size = UDim2.new(1, -20, 0, 25)
    PreviewLabel.Position = UDim2.new(0, 10, 0, 375)
    PreviewLabel.BackgroundTransparency = 1
    PreviewLabel.Text = "👁️ Action Preview:"
    PreviewLabel.Font = Enum.Font.GothamBold
    PreviewLabel.TextSize = 14
    PreviewLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PreviewLabel.TextXAlignment = Enum.TextXAlignment.Left
    PreviewLabel.Parent = MainFrame
    
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -20, 0, 130)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 405)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 6
    ScrollFrame.Parent = MainFrame
    
    local ScrollCorner = Instance.new("UICorner", ScrollFrame)
    ScrollCorner.CornerRadius = UDim.new(0, 8)
    
    local MacroPreview = Instance.new("TextLabel")
    MacroPreview.Size = UDim2.new(1, -10, 1, 0)
    MacroPreview.Position = UDim2.new(0, 5, 0, 0)
    MacroPreview.BackgroundTransparency = 1
    MacroPreview.Text = "Select a macro to preview"
    MacroPreview.Font = Enum.Font.Code
    MacroPreview.TextSize = 11
    MacroPreview.TextColor3 = Color3.fromRGB(200, 200, 200)
    MacroPreview.TextXAlignment = Enum.TextXAlignment.Left
    MacroPreview.TextYAlignment = Enum.TextYAlignment.Top
    MacroPreview.Parent = ScrollFrame
    
    local ExportButton = Instance.new("TextButton")
    ExportButton.Size = UDim2.new(0.48, 0, 0, 40)
    ExportButton.Position = UDim2.new(0, 10, 0, 545)
    ExportButton.Text = "📋 Export Selected"
    ExportButton.Font = Enum.Font.GothamBold
    ExportButton.TextSize = 14
    ExportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExportButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    ExportButton.BorderSizePixel = 0
    ExportButton.Parent = MainFrame
    
    local ExportCorner = Instance.new("UICorner", ExportButton)
    ExportCorner.CornerRadius = UDim.new(0, 8)
    
    local ImportButton = Instance.new("TextButton")
    ImportButton.Size = UDim2.new(0.48, 0, 0, 40)
    ImportButton.Position = UDim2.new(0.52, 0, 0, 545)
    ImportButton.Text = "📥 Import Macro"
    ImportButton.Font = Enum.Font.GothamBold
    ImportButton.TextSize = 14
    ImportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ImportButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    ImportButton.BorderSizePixel = 0
    ImportButton.Parent = MainFrame
    
    local ImportCorner = Instance.new("UICorner", ImportButton)
    ImportCorner.CornerRadius = UDim.new(0, 8)
    
    return {
        StatusLabel = StatusLabel,
        NameInput = NameInput,
        RecordButton = RecordButton,
        StopButton = StopButton,
        MacroListFrame = MacroListFrame,
        MacroPreview = MacroPreview,
        ExportButton = ExportButton,
        ImportButton = ImportButton,
        ScrollFrame = ScrollFrame
    }
end

local function updateMacroPreview(gui, actions)
    if not actions or #actions == 0 then
        gui.MacroPreview.Text = "No actions in this macro"
        return
    end
    
    local displayText = "📊 Actions (" .. #actions .. "):\n\n"
    
    for i, action in ipairs(actions) do
        local timestamp = string.format("[%05.2fs]", action.timestamp)
        
        if action.type == "place" then
            displayText = displayText .. timestamp .. " 🌱 PLACE: " .. action.unit .. 
                         "\n         Pos: " .. string.format("(%.1f, %.1f, %.1f)", 
                         action.position.X, action.position.Y, action.position.Z) .. 
                         "\n         Cost: $" .. action.cost .. "\n\n"
                         
        elseif action.type == "upgrade" then
            displayText = displayText .. timestamp .. " ⬆️ UPGRADE: Unit #" .. action.unitIndex .. 
                         " → Level " .. action.targetLevel .. 
                         "\n         Cost: $" .. action.cost .. "\n\n"
                         
        elseif action.type == "sell" then
            displayText = displayText .. timestamp .. " 💰 SELL: Unit #" .. action.unitIndex .. 
                         "\n         Refund: $" .. (action.refund or "???") .. "\n\n"
        end
    end
    
    gui.MacroPreview.Text = displayText
    gui.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, gui.MacroPreview.TextBounds.Y + 10)
end

local function updateMacroList(gui)
    for _, child in ipairs(gui.MacroListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    if #_G.savedMacros == 0 then
        local EmptyLabel = Instance.new("TextLabel")
        EmptyLabel.Size = UDim2.new(1, -10, 0, 30)
        EmptyLabel.BackgroundTransparency = 1
        EmptyLabel.Text = "No saved macros yet"
        EmptyLabel.Font = Enum.Font.Gotham
        EmptyLabel.TextSize = 12
        EmptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        EmptyLabel.Parent = gui.MacroListFrame
        return
    end
    
    for i, macro in ipairs(_G.savedMacros) do
        local MacroItem = Instance.new("Frame")
        MacroItem.Size = UDim2.new(1, -10, 0, 50)
        MacroItem.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        MacroItem.BorderSizePixel = 0
        MacroItem.Parent = gui.MacroListFrame
        
        local ItemCorner = Instance.new("UICorner", MacroItem)
        ItemCorner.CornerRadius = UDim.new(0, 6)
        
        local MacroNameLabel = Instance.new("TextLabel")
        MacroNameLabel.Size = UDim2.new(0, 200, 1, 0)
        MacroNameLabel.Position = UDim2.new(0, 10, 0, 0)
        MacroNameLabel.BackgroundTransparency = 1
        MacroNameLabel.Text = "📄 " .. macro.name
        MacroNameLabel.Font = Enum.Font.GothamBold
        MacroNameLabel.TextSize = 13
        MacroNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        MacroNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        MacroNameLabel.Parent = MacroItem
        
        local ActionCountLabel = Instance.new("TextLabel")
        ActionCountLabel.Size = UDim2.new(0, 100, 1, 0)
        ActionCountLabel.Position = UDim2.new(0, 210, 0, 0)
        ActionCountLabel.BackgroundTransparency = 1
        ActionCountLabel.Text = #macro.actions .. " actions"
        ActionCountLabel.Font = Enum.Font.Gotham
        ActionCountLabel.TextSize = 11
        ActionCountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        ActionCountLabel.TextXAlignment = Enum.TextXAlignment.Left
        ActionCountLabel.Parent = MacroItem
        
        local PlayBtn = Instance.new("TextButton")
        PlayBtn.Size = UDim2.new(0, 35, 0, 35)
        PlayBtn.Position = UDim2.new(1, -115, 0.5, -17.5)
        PlayBtn.Text = "▶️"
        PlayBtn.Font = Enum.Font.GothamBold
        PlayBtn.TextSize = 16
        PlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        PlayBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        PlayBtn.BorderSizePixel = 0
        PlayBtn.Parent = MacroItem
        
        local PlayBtnCorner = Instance.new("UICorner", PlayBtn)
        PlayBtnCorner.CornerRadius = UDim.new(0, 6)
        
        local PreviewBtn = Instance.new("TextButton")
        PreviewBtn.Size = UDim2.new(0, 35, 0, 35)
        PreviewBtn.Position = UDim2.new(1, -75, 0.5, -17.5)
        PreviewBtn.Text = "👁️"
        PreviewBtn.Font = Enum.Font.GothamBold
        PreviewBtn.TextSize = 16
        PreviewBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        PreviewBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        PreviewBtn.BorderSizePixel = 0
        PreviewBtn.Parent = MacroItem
        
        local PreviewBtnCorner = Instance.new("UICorner", PreviewBtn)
        PreviewBtnCorner.CornerRadius = UDim.new(0, 6)
        
        local DeleteBtn = Instance.new("TextButton")
        DeleteBtn.Size = UDim2.new(0, 35, 0, 35)
        DeleteBtn.Position = UDim2.new(1, -35, 0.5, -17.5)
        DeleteBtn.Text = "🗑️"
        DeleteBtn.Font = Enum.Font.GothamBold
        DeleteBtn.TextSize = 16
        DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DeleteBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        DeleteBtn.BorderSizePixel = 0
        DeleteBtn.Parent = MacroItem
        
        local DeleteBtnCorner = Instance.new("UICorner", DeleteBtn)
        DeleteBtnCorner.CornerRadius = UDim.new(0, 6)
        
        PlayBtn.MouseButton1Click:Connect(function()
            playMacro(macro.actions, gui)
        end)
        
        PreviewBtn.MouseButton1Click:Connect(function()
            _G.currentMacroName = macro.name
            updateMacroPreview(gui, macro.actions)
        end)
        
        DeleteBtn.MouseButton1Click:Connect(function()
            table.remove(_G.savedMacros, i)
            updateMacroList(gui)
            warn("[MACRO] Deleted: " .. macro.name)
        end)
    end
    
    gui.MacroListFrame.CanvasSize = UDim2.new(0, 0, 0, #_G.savedMacros * 55)
end

local function getMoney()
    return plr:GetAttribute("Cash") or 0
end

local function startRecording(gui)
    if _G.macroRecording then return end
    
    _G.macroRecording = true
    _G.recordedMacro = {}
    _G.placedUnits = {}
    _G.recordStartTime = tick()
    
    gui.StatusLabel.Text = "🔴 Status: RECORDING..."
    gui.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    gui.RecordButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    gui.StopButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    
    warn("[MACRO] Recording started!")
    updateMacroPreview(gui, _G.recordedMacro)
end

local function stopRecording(gui)
    if not _G.macroRecording then return end
    
    _G.macroRecording = false
    
    local macroName = gui.NameInput.Text
    if macroName == "" then
        macroName = "Macro_" .. os.date("%H%M%S")
    end
    
    table.insert(_G.savedMacros, {
        name = macroName,
        actions = _G.recordedMacro,
        timestamp = os.time()
    })
    
    gui.StatusLabel.Text = "💾 Status: Saved as '" .. macroName .. "'"
    gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    gui.RecordButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    gui.StopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    gui.NameInput.Text = ""
    
    updateMacroList(gui)
    updateMacroPreview(gui, _G.recordedMacro)
    
    warn("[MACRO] Saved: " .. macroName .. " (" .. #_G.recordedMacro .. " actions)")
end

local function recordAction(actionType, actionData, gui)
    if not _G.macroRecording then return end
    
    local timestamp = tick() - _G.recordStartTime
    
    local action = {
        type = actionType,
        timestamp = timestamp
    }
    
    for k, v in pairs(actionData) do
        action[k] = v
    end
    
    table.insert(_G.recordedMacro, action)
    
    updateMacroPreview(gui, _G.recordedMacro)
end

local function hookPlacement(gui)
    local oldPlaceUnit = remotes.PlaceUnit.InvokeServer
    remotes.PlaceUnit.InvokeServer = function(self, unitName, data)
        local moneyBefore = getMoney()
        local result = oldPlaceUnit(self, unitName, data)
        
        if result and _G.macroRecording then
            local moneyAfter = getMoney()
            local cost = moneyBefore - moneyAfter
            
            table.insert(_G.placedUnits, {
                unit = unitName,
                position = data.Position,
                timestamp = tick()
            })
            
            recordAction("place", {
                unit = unitName,
                position = data.Position,
                rotation = data.Rotation,
                cost = cost,
                unitIndex = #_G.placedUnits
            }, gui)
        end
        
        return result
    end
end

local function hookUpgrade(gui)
    local oldUpgradeUnit = remotes.UpgradeUnit.InvokeServer
    remotes.UpgradeUnit.InvokeServer = function(self, unitID)
        local moneyBefore = getMoney()
        local result = oldUpgradeUnit(self, unitID)
        
        if _G.macroRecording then
            local moneyAfter = getMoney()
            local cost = moneyBefore - moneyAfter
            
            local unitIndex = nil
            for i, unit in ipairs(_G.placedUnits) do
                if i == unitID or unit.id == unitID then
                    unitIndex = i
                    unit.level = (unit.level or 1) + 1
                    break
                end
            end
            
            recordAction("upgrade", {
                unitIndex = unitIndex or unitID,
                targetLevel = (unitIndex and _G.placedUnits[unitIndex].level) or "?",
                cost = cost
            }, gui)
        end
        
        return result
    end
end

local function hookSell(gui)
    local oldSellUnit = remotes.SellUnit.InvokeServer
    remotes.SellUnit.InvokeServer = function(self, unitID)
        local moneyBefore = getMoney()
        local result = oldSellUnit(self, unitID)
        local moneyAfter = getMoney()
        
        if _G.macroRecording then
            local refund = moneyAfter - moneyBefore
            
            local unitIndex = nil
            for i, unit in ipairs(_G.placedUnits) do
                if i == unitID or unit.id == unitID then
                    unitIndex = i
                    break
                end
            end
            
            recordAction("sell", {
                unitIndex = unitIndex or unitID,
                refund = refund
            }, gui)
        end
        
        return result
    end
end

function playMacro(actions, gui)
    if _G.macroPlaying then
        warn("[MACRO] Already playing!")
        return
    end
    
    if not actions or #actions == 0 then
        warn("[MACRO] No actions to play!")
        return
    end
    
    _G.macroPlaying = true
    _G.placedUnits = {}
    
    gui.StatusLabel.Text = "▶️ Status: PLAYING..."
    gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    
    warn("[MACRO] Starting playback...")
    
    task.spawn(function()
        local playStartTime = tick()
        
        for i, action in ipairs(actions) do
            local currentTime = tick() - playStartTime
            local waitTime = action.timestamp - currentTime
            
            if waitTime > 0 then
                task.wait(waitTime)
            end
            
            if action.type == "place" then
                local data = {
                    CF = CFrame.new(action.position.X, action.position.Y, action.position.Z, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1),
                    Rotation = action.rotation or 180,
                    Valid = true,
                    Position = action.position
                }
                
                local success, result = pcall(function()
                    return remotes.PlaceUnit:InvokeServer(action.unit, data)
                end)
                
                if success and result then
                    table.insert(_G.placedUnits, {unit = action.unit, id = result})
                    warn(string.format("[MACRO PLAY] Placed: %s", action.unit))
                end
                
            elseif action.type == "upgrade" then
                if #_G.placedUnits >= action.unitIndex then
                    local unitID = _G.placedUnits[action.unitIndex].id or action.unitIndex
                    
                    pcall(function()
                        remotes.UpgradeUnit:InvokeServer(unitID)
                        warn(string.format("[MACRO PLAY] Upgraded: Unit #%d", action.unitIndex))
                    end)
                end
                
            elseif action.type == "sell" then
                if #_G.placedUnits >= action.unitIndex then
                    local unitID = _G.placedUnits[action.unitIndex].id or action.unitIndex
                    
                    pcall(function()
                        remotes.SellUnit:InvokeServer(unitID)
                        warn(string.format("[MACRO PLAY] Sold: Unit #%d", action.unitIndex))
                    end)
                end
            end
        end
        
        _G.macroPlaying = false
        gui.StatusLabel.Text = "✅ Status: Playback Complete!"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        warn("[MACRO] Playback finished!")
        
        task.wait(3)
        gui.StatusLabel.Text = "⏸️ Status: Idle"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
end

local function exportMacro(gui)
    if _G.currentMacroName == "" then
        warn("[MACRO] No macro selected!")
        return
    end
    
    local selectedMacro = nil
    for _, macro in ipairs(_G.savedMacros) do
        if macro.name == _G.currentMacroName then
            selectedMacro = macro
            break
        end
    end
    
    if not selectedMacro then
        warn("[MACRO] Selected macro not found!")
        return
    end
    
    local encoded = HttpService:JSONEncode(selectedMacro)
    setclipboard(encoded)
    
    gui.ExportButton.Text = "✅ Copied!"
    gui.ExportButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    
    warn("[MACRO] Exported: " .. selectedMacro.name)
    
    task.wait(2)
    gui.ExportButton.Text = "📋 Export Selected"
    gui.ExportButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
end

local function importMacro(gui)
    local success, result = pcall(function()
        local clipboard = getclipboard() or ""
        return HttpService:JSONDecode(clipboard)
    end)
    
    if success and result and result.name and result.actions then
        local existingIndex = nil
        for i, macro in ipairs(_G.savedMacros) do
            if macro.name == result.name then
                existingIndex = i
                break
            end
        end
        
        if existingIndex then
            result.name = result.name .. "_" .. os.date("%H%M%S")
        end
        
        table.insert(_G.savedMacros, result)
        updateMacroList(gui)
        
        gui.ImportButton.Text = "✅ Imported!"
        gui.ImportButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    gui.StatusLabel.Text = "✅ Status: Imported '" .. result.name .. "'"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        warn("[MACRO] Imported: " .. result.name)
        
        task.wait(2)
        gui.ImportButton.Text = "📥 Import Macro"
        gui.ImportButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    else
        gui.ImportButton.Text = "❌ Failed!"
        gui.ImportButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        warn("[MACRO] Failed to import macro!")
        
        task.wait(2)
        gui.ImportButton.Text = "📥 Import Macro"
        gui.ImportButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    end
end

local gui = createMacroGui()

hookPlacement(gui)
hookUpgrade(gui)
hookSell(gui)

gui.RecordButton.MouseButton1Click:Connect(function()
    startRecording(gui)
end)

gui.StopButton.MouseButton1Click:Connect(function()
    stopRecording(gui)
end)

gui.ExportButton.MouseButton1Click:Connect(function()
    exportMacro(gui)
end)

gui.ImportButton.MouseButton1Click:Connect(function()
    importMacro(gui)
end)

updateMacroList(gui)

warn("========================================")
warn("[MACRO RECORDER v2] Initialized")
warn("[FEATURES]")
warn("  • Named macros with custom names")
warn("  • Save multiple macros")
warn("  • Preview actions before playing")
warn("  • Play/Delete individual macros")
warn("  • Export/Import macros")
warn("[CONTROLS]")
warn("  1. Enter macro name")
warn("  2. Click 'Start Recording'")
warn("  3. Play normally (place, upgrade, sell)")
warn("  4. Click 'Stop & Save'")
warn("  5. Use ▶️ to play, 👁️ to preview, 🗑️ to delete")
warn("========================================")
