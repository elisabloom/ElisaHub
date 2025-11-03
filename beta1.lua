--// Garden Tower Defense - Macro Recorder v4 (ULTRA COMPACT)

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

repeat task.wait() until plr.Character

local remotes = rs:WaitForChild("RemoteFunctions", 30)
if not remotes then return end

_G.macroRecording = false
_G.macroPlaying = false
_G.recordedMacro = {}
_G.savedMacros = _G.savedMacros or {}
_G.recordStartTime = nil
_G.placedUnits = {}
_G.selectedMacro = nil
_G.guiMinimized = false
_G.listExpanded = false

local function createMacroGui()
    local existingGui = plr.PlayerGui:FindFirstChild("MacroRecorder")
    if existingGui then existingGui:Destroy() end
    
    local MacroGui = Instance.new("ScreenGui")
    MacroGui.Name = "MacroRecorder"
    MacroGui.ResetOnSpawn = false
    MacroGui.Parent = plr.PlayerGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 280, 0, 200)
    MainFrame.Position = UDim2.new(1, -290, 0, 10)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = MacroGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -30, 0, 25)
    Title.BackgroundTransparency = 1
    Title.Text = "Macro Recorder"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = MainFrame
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -28, 0, 0)
    MinimizeButton.Text = "➖"
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 14
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = MainFrame
    Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -25)
    ContentFrame.Position = UDim2.new(0, 0, 0, 25)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -16, 0, 20)
    StatusLabel.Position = UDim2.new(0, 8, 0, 5)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    StatusLabel.Text = Ready"
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 11
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.Parent = ContentFrame
    Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 5)
    
    local NameInput = Instance.new("TextBox")
    NameInput.Size = UDim2.new(1, -16, 0, 25)
    NameInput.Position = UDim2.new(0, 8, 0, 30)
    NameInput.PlaceholderText = "Macro name..."
    NameInput.Text = ""
    NameInput.Font = Enum.Font.Gotham
    NameInput.TextSize = 11
    NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    NameInput.BorderSizePixel = 0
    NameInput.ClearTextOnFocus = false
    NameInput.Parent = ContentFrame
    Instance.new("UICorner", NameInput).CornerRadius = UDim.new(0, 5)
    
    local RecordButton = Instance.new("TextButton")
    RecordButton.Size = UDim2.new(0.48, 0, 0, 32)
    RecordButton.Position = UDim2.new(0, 8, 0, 60)
    RecordButton.Text = "Record"
    RecordButton.Font = Enum.Font.GothamBold
    RecordButton.TextSize = 12
    RecordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RecordButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    RecordButton.BorderSizePixel = 0
    RecordButton.Parent = ContentFrame
    Instance.new("UICorner", RecordButton).CornerRadius = UDim.new(0, 6)
    
    local StopButton = Instance.new("TextButton")
    StopButton.Size = UDim2.new(0.48, 0, 0, 32)
    StopButton.Position = UDim2.new(0.52, 0, 0, 60)
    StopButton.Text = "Save"
    StopButton.Font = Enum.Font.GothamBold
    StopButton.TextSize = 12
    StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    StopButton.BorderSizePixel = 0
    StopButton.Parent = ContentFrame
    Instance.new("UICorner", StopButton).CornerRadius = UDim.new(0, 6)
    
    local MacroListButton = Instance.new("TextButton")
    MacroListButton.Size = UDim2.new(1, -16, 0, 28)
    MacroListButton.Position = UDim2.new(0, 8, 0, 97)
    MacroListButton.Text = "Saved Macros (0) ▼"
    MacroListButton.Font = Enum.Font.GothamBold
    MacroListButton.TextSize = 11
    MacroListButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MacroListButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MacroListButton.BorderSizePixel = 0
    MacroListButton.Parent = ContentFrame
    Instance.new("UICorner", MacroListButton).CornerRadius = UDim.new(0, 5)
    
    local MacroListFrame = Instance.new("ScrollingFrame")
    MacroListFrame.Size = UDim2.new(1, -16, 0, 0)
    MacroListFrame.Position = UDim2.new(0, 8, 0, 130)
    MacroListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MacroListFrame.BorderSizePixel = 0
    MacroListFrame.ScrollBarThickness = 3
    MacroListFrame.Visible = false
    MacroListFrame.Parent = ContentFrame
    Instance.new("UICorner", MacroListFrame).CornerRadius = UDim.new(0, 5)
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 2)
    UIListLayout.Parent = MacroListFrame
    
    local ExportButton = Instance.new("TextButton")
    ExportButton.Size = UDim2.new(0.48, 0, 0, 28)
    ExportButton.Position = UDim2.new(0, 8, 0, 132)
    ExportButton.Text = "Export"
    ExportButton.Font = Enum.Font.GothamBold
    ExportButton.TextSize = 11
    ExportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExportButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    ExportButton.BorderSizePixel = 0
    ExportButton.Parent = ContentFrame
    Instance.new("UICorner", ExportButton).CornerRadius = UDim.new(0, 5)
    
    local ImportButton = Instance.new("TextButton")
    ImportButton.Size = UDim2.new(0.48, 0, 0, 28)
    ImportButton.Position = UDim2.new(0.52, 0, 0, 132)
    ImportButton.Text = "Import"
    ImportButton.Font = Enum.Font.GothamBold
    ImportButton.TextSize = 11
    ImportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ImportButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    ImportButton.BorderSizePixel = 0
    ImportButton.Parent = ContentFrame
    Instance.new("UICorner", ImportButton).CornerRadius = UDim.new(0, 5)
    
    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Size = UDim2.new(1, -16, 0, 20)
    SelectedLabel.Position = UDim2.new(0, 8, 0, 165)
    SelectedLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SelectedLabel.Text = "Selected: None"
    SelectedLabel.Font = Enum.Font.Gotham
    SelectedLabel.TextSize = 10
    SelectedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    SelectedLabel.Parent = ContentFrame
    Instance.new("UICorner", SelectedLabel).CornerRadius = UDim.new(0, 5)
    
    return {
        MainFrame = MainFrame,
        ContentFrame = ContentFrame,
        MinimizeButton = MinimizeButton,
        StatusLabel = StatusLabel,
        NameInput = NameInput,
        RecordButton = RecordButton,
        StopButton = StopButton,
        MacroListButton = MacroListButton,
        MacroListFrame = MacroListFrame,
        ExportButton = ExportButton,
        ImportButton = ImportButton,
        SelectedLabel = SelectedLabel
    }
end

local function toggleMinimize(gui)
    _G.guiMinimized = not _G.guiMinimized
    if _G.guiMinimized then
        gui.MainFrame:TweenSize(UDim2.new(0, 280, 0, 25), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        gui.ContentFrame.Visible = false
        gui.MinimizeButton.Text = "➕"
    else
        gui.MainFrame:TweenSize(UDim2.new(0, 280, 0, 200), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        gui.ContentFrame.Visible = true
        gui.MinimizeButton.Text = "➖"
    end
end

local function toggleMacroList(gui)
    _G.listExpanded = not _G.listExpanded
    if _G.listExpanded then
        gui.MacroListFrame.Visible = true
        gui.MacroListFrame:TweenSize(UDim2.new(1, -16, 0, 120), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        gui.MainFrame:TweenSize(UDim2.new(0, 280, 0, 380), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        gui.MacroListButton.Text = "Saved Macros (" .. #_G.savedMacros .. ") ▲"
        gui.ExportButton.Position = UDim2.new(0, 8, 0, 257)
        gui.ImportButton.Position = UDim2.new(0.52, 0, 0, 257)
        gui.SelectedLabel.Position = UDim2.new(0, 8, 0, 290)
    else
        gui.MacroListFrame:TweenSize(UDim2.new(1, -16, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true, function()
            gui.MacroListFrame.Visible = false
        end)
        gui.MainFrame:TweenSize(UDim2.new(0, 280, 0, 200), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
        gui.MacroListButton.Text = "Saved Macros (" .. #_G.savedMacros .. ") ▼"
        gui.ExportButton.Position = UDim2.new(0, 8, 0, 132)
        gui.ImportButton.Position = UDim2.new(0.52, 0, 0, 132)
        gui.SelectedLabel.Position = UDim2.new(0, 8, 0, 165)
    end
end

local function updateMacroList(gui)
    for _, child in ipairs(gui.MacroListFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    gui.MacroListButton.Text = "Saved Macros (" .. #_G.savedMacros .. ") " .. (_G.listExpanded and "▲" or "▼")
    
    if #_G.savedMacros == 0 then
        local EmptyLabel = Instance.new("TextLabel")
        EmptyLabel.Size = UDim2.new(1, -8, 0, 25)
        EmptyLabel.BackgroundTransparency = 1
        EmptyLabel.Text = "No saved macros"
        EmptyLabel.Font = Enum.Font.Gotham
        EmptyLabel.TextSize = 10
        EmptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        EmptyLabel.Parent = gui.MacroListFrame
        return
    end
    
    for i, macro in ipairs(_G.savedMacros) do
        local MacroItem = Instance.new("Frame")
        MacroItem.Size = UDim2.new(1, -8, 0, 32)
        MacroItem.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        MacroItem.BorderSizePixel = 0
        MacroItem.Parent = gui.MacroListFrame
        Instance.new("UICorner", MacroItem).CornerRadius = UDim.new(0, 5)
        
        local MacroNameLabel = Instance.new("TextLabel")
        MacroNameLabel.Size = UDim2.new(0, 100, 1, 0)
        MacroNameLabel.Position = UDim2.new(0, 6, 0, 0)
        MacroNameLabel.BackgroundTransparency = 1
        MacroNameLabel.Text = "Name " .. macro.name
        MacroNameLabel.Font = Enum.Font.GothamBold
        MacroNameLabel.TextSize = 10
        MacroNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        MacroNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        MacroNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        MacroNameLabel.Parent = MacroItem
        
        local ActionCountLabel = Instance.new("TextLabel")
        ActionCountLabel.Size = UDim2.new(0, 45, 1, 0)
        ActionCountLabel.Position = UDim2.new(0, 108, 0, 0)
        ActionCountLabel.BackgroundTransparency = 1
        ActionCountLabel.Text = #macro.actions .. " acts"
        ActionCountLabel.Font = Enum.Font.Gotham
        ActionCountLabel.TextSize = 9
        ActionCountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        ActionCountLabel.TextXAlignment = Enum.TextXAlignment.Left
        ActionCountLabel.Parent = MacroItem
        
        local PlayBtn = Instance.new("TextButton")
        PlayBtn.Size = UDim2.new(0, 25, 0, 25)
        PlayBtn.Position = UDim2.new(1, -83, 0.5, -12.5)
        PlayBtn.Text = "Play"
        PlayBtn.Font = Enum.Font.GothamBold
        PlayBtn.TextSize = 12
        PlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        PlayBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        PlayBtn.BorderSizePixel = 0
        PlayBtn.Parent = MacroItem
        Instance.new("UICorner", PlayBtn).CornerRadius = UDim.new(0, 5)
        
        local SelectBtn = Instance.new("TextButton")
        SelectBtn.Size = UDim2.new(0, 25, 0, 25)
        SelectBtn.Position = UDim2.new(1, -54, 0.5, -12.5)
        SelectBtn.Text = "✓"
        SelectBtn.Font = Enum.Font.GothamBold
        SelectBtn.TextSize = 12
        SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SelectBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        SelectBtn.BorderSizePixel = 0
        SelectBtn.Parent = MacroItem
        Instance.new("UICorner", SelectBtn).CornerRadius = UDim.new(0, 5)
        
        local DeleteBtn = Instance.new("TextButton")
        DeleteBtn.Size = UDim2.new(0, 25, 0, 25)
        DeleteBtn.Position = UDim2.new(1, -25, 0.5, -12.5)
        DeleteBtn.Text = "Delete"
        DeleteBtn.Font = Enum.Font.GothamBold
        DeleteBtn.TextSize = 10
        DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DeleteBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        DeleteBtn.BorderSizePixel = 0
        DeleteBtn.Parent = MacroItem
        Instance.new("UICorner", DeleteBtn).CornerRadius = UDim.new(0, 5)
        
        PlayBtn.MouseButton1Click:Connect(function()
            _G.selectedMacro = macro
            gui.SelectedLabel.Text = "Selected: " .. macro.name
            toggleMacroList(gui)
            playMacro(macro.actions, gui)
        end)
        
        SelectBtn.MouseButton1Click:Connect(function()
            _G.selectedMacro = macro
            gui.SelectedLabel.Text = "Selected: " .. macro.name
            toggleMacroList(gui)
        end)
        
        DeleteBtn.MouseButton1Click:Connect(function()
            table.remove(_G.savedMacros, i)
            if _G.selectedMacro == macro then
                _G.selectedMacro = nil
                gui.SelectedLabel.Text = "Selected: None"
            end
            updateMacroList(gui)
        end)
    end
    
    gui.MacroListFrame.CanvasSize = UDim2.new(0, 0, 0, #_G.savedMacros * 34)
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
    gui.StatusLabel.Text = "Recording..."
    gui.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    gui.RecordButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    gui.StopButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    warn("[MACRO] Started recording")
end

local function stopRecording(gui)
    if not _G.macroRecording then return end
    _G.macroRecording = false
    local macroName = gui.NameInput.Text
    if macroName == "" then macroName = "Macro_" .. os.date("%H%M%S") end
    
    warn("[MACRO] Stopping - Total actions: " .. #_G.recordedMacro)
    
    table.insert(_G.savedMacros, {name = macroName, actions = _G.recordedMacro, timestamp = os.time()})
    gui.StatusLabel.Text = "Saved: " .. macroName
    gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    gui.RecordButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    gui.StopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    gui.NameInput.Text = ""
    updateMacroList(gui)
    warn("[MACRO] Saved '" .. macroName .. "' with " .. #_G.recordedMacro .. " actions")
    task.wait(2)
    gui.StatusLabel.Text = "Ready"
    gui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
end

local function recordAction(actionType, actionData)
    if not _G.macroRecording then return end
    local timestamp = tick() - _G.recordStartTime
    local action = {type = actionType, timestamp = timestamp}
    for k, v in pairs(actionData) do action[k] = v end
    table.insert(_G.recordedMacro, action)
    warn("[MACRO] Recorded " .. actionType .. " at " .. string.format("%.2f", timestamp) .. "s (Total: " .. #_G.recordedMacro .. ")")
end

local function hookPlacement()
    if not remotes:FindFirstChild("PlaceUnit") then 
        warn("[MACRO] PlaceUnit not found!")
        return 
    end
    
    local success = pcall(function()
        local oldPlaceUnit = remotes.PlaceUnit.InvokeServer
        remotes.PlaceUnit.InvokeServer = function(self, unitName, data)
            local moneyBefore = getMoney()
            local result = oldPlaceUnit(self, unitName, data)
            
            if result and _G.macroRecording then
                task.wait(0.1)
                local moneyAfter = getMoney()
                table.insert(_G.placedUnits, {unit = unitName, position = data.Position, id = result})
                recordAction("place", {
                    unit = unitName, 
                    position = data.Position, 
                    rotation = data.Rotation, 
                    cost = moneyBefore - moneyAfter, 
                    unitIndex = #_G.placedUnits
                })
            end
            return result
        end
    end)
    
    if success then
        warn("[MACRO] PlaceUnit hooked!")
    else
        warn("[MACRO] Failed to hook PlaceUnit")
    end
end

local function hookUpgrade()
    if not remotes:FindFirstChild("UpgradeUnit") then 
        warn("[MACRO] UpgradeUnit not found!")
        return 
    end
    
    local success = pcall(function()
        local oldUpgradeUnit = remotes.UpgradeUnit.InvokeServer
        remotes.UpgradeUnit.InvokeServer = function(self, unitID)
            local moneyBefore = getMoney()
            local result = oldUpgradeUnit(self, unitID)
            
            if _G.macroRecording then
                task.wait(0.1)
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
                    targetLevel = (unitIndex and _G.placedUnits[unitIndex].level) or 2, 
                    cost = moneyBefore - getMoney()
                })
            end
            return result
        end
    end)
    
    if success then
        warn("[MACRO] UpgradeUnit hooked!")
    else
        warn("[MACRO] Failed to hook UpgradeUnit")
    end
end

local function hookSell()
    if not remotes:FindFirstChild("SellUnit") then 
        warn("[MACRO] SellUnit not found!")
        return 
    end
    
    local success = pcall(function()
        local oldSellUnit = remotes.SellUnit.InvokeServer
        remotes.SellUnit.InvokeServer = function(self, unitID)
            local moneyBefore = getMoney()
            local result = oldSellUnit(self, unitID)
            
            if _G.macroRecording then
                task.wait(0.1)
                local unitIndex = nil
                for i, unit in ipairs(_G.placedUnits) do
                    if i == unitID or unit.id == unitID then unitIndex = i break end
                end
                recordAction("sell", {unitIndex = unitIndex or unitID, refund = getMoney() - moneyBefore})
            end
            return result
        end
    end)
    
    if success then
        warn("[MACRO] SellUnit hooked!")
    else
        warn("[MACRO] Failed to hook SellUnit")
    end
end

function playMacro(actions, gui)
    if _G.macroPlaying or not actions or #actions == 0 then return end
    _G.macroPlaying = true
    _G.placedUnits = {}
    gui.StatusLabel.Text = "Playing..."
    gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    warn("[MACRO] Playing " .. #actions .. " actions")
    
    task.spawn(function()
        local playStartTime = tick()
        for i, action in ipairs(actions) do
            local waitTime = action.timestamp - (tick() - playStartTime)
            if waitTime > 0 then task.wait(waitTime) end
            
            if action.type == "place" then
                local success, result = pcall(function()
                    return remotes.PlaceUnit:InvokeServer(action.unit, {
                        CF = CFrame.new(action.position.X, action.position.Y, action.position.Z, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1),
                        Rotation = action.rotation or 180,
                        Valid = true,
                        Position = action.position
                    })
                end)
                if success and result then 
                    table.insert(_G.placedUnits, {unit = action.unit, id = result})
                    warn("[MACRO] Placed " .. action.unit)
                end
            elseif action.type == "upgrade" and #_G.placedUnits >= action.unitIndex then
                pcall(function() 
                    remotes.UpgradeUnit:InvokeServer(_G.placedUnits[action.unitIndex].id or action.unitIndex) 
                    warn("[MACRO] Upgraded unit " .. action.unitIndex)
                end)
            elseif action.type == "sell" and #_G.placedUnits >= action.unitIndex then
                pcall(function() 
                    remotes.SellUnit:InvokeServer(_G.placedUnits[action.unitIndex].id or action.unitIndex) 
                    warn("[MACRO] Sold unit " .. action.unitIndex)
                end)
            end
        end
        
        _G.macroPlaying = false
        gui.StatusLabel.Text = "Complete!"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        warn("[MACRO] Playback complete")
        task.wait(2)
        gui.StatusLabel.Text = "Ready"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
end

local function exportMacro(gui)
    if not _G.selectedMacro then
        gui.StatusLabel.Text = "Select macro"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        task.wait(2)
        gui.StatusLabel.Text = "Ready"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        return
    end
    pcall(function()
        setclipboard(HttpService:JSONEncode(_G.selectedMacro))
        gui.ExportButton.Text = "export"
        gui.ExportButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    end)
    task.wait(1.5)
    gui.ExportButton.Text = "Export"
    gui.ExportButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
end

local function importMacro(gui)
    local success, result = pcall(function() return HttpService:JSONDecode(getclipboard() or "") end)
    if success and result and result.name and result.actions then
        for i, macro in ipairs(_G.savedMacros) do
            if macro.name == result.name then result.name = result.name .. "_" .. os.date("%H%M%S") break end
        end
        table.insert(_G.savedMacros, result)
        updateMacroList(gui)
        gui.ImportButton.Text = "import"
        gui.ImportButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    else
        gui.ImportButton.Text = "x"
        gui.ImportButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    task.wait(1.5)
    gui.ImportButton.Text = "Import"
    gui.ImportButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
end

local gui = createMacroGui()

hookPlacement()
hookUpgrade()
hookSell()

gui.MinimizeButton.MouseButton1Click:Connect(function() toggleMinimize(gui) end)
gui.RecordButton.MouseButton1Click:Connect(function() startRecording(gui) end)
gui.StopButton.MouseButton1Click:Connect(function() stopRecording(gui) end)
gui.MacroListButton.MouseButton1Click:Connect(function() toggleMacroList(gui) end)
gui.ExportButton.MouseButton1Click:Connect(function() exportMacro(gui) end)
gui.ImportButton.MouseButton1Click:Connect(function() importMacro(gui) end)

updateMacroList(gui)

warn("========================================")
warn("[MACRO RECORDER v4] Loaded!")
warn("[GUI] 280x200px (50% smaller)")
warn("[HOOKS] Placement, Upgrade, Sell active")
warn("========================================")
