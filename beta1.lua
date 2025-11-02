--// Garden Tower Defense - Macro Recorder & Player v3
--// Compact version with collapsible macro list

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
_G.selectedMacro = nil
_G.guiMinimized = false
_G.listExpanded = false

local function createMacroGui()
    local existingGui = plr.PlayerGui:FindFirstChild("MacroRecorder")
    if existingGui then existingGui:Destroy() end
    
    local MacroGui = Instance.new("ScreenGui")
    MacroGui.Name = "MacroRecorder"
    MacroGui.ResetOnSpawn = false
    MacroGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MacroGui.Parent = plr:WaitForChild("PlayerGui")
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 280)
    MainFrame.Position = UDim2.new(1, -330, 0, 10)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = MacroGui
    
    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 10)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "🎬 Macro Recorder"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = MainFrame
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -35, 0, 0)
    MinimizeButton.Text = "➖"
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 16
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = MainFrame
    
    local MinimizeCorner = Instance.new("UICorner", MinimizeButton)
    MinimizeCorner.CornerRadius = UDim.new(0, 6)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -30)
    ContentFrame.Position = UDim2.new(0, 0, 0, 30)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 25)
    StatusLabel.Position = UDim2.new(0, 10, 0, 5)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    StatusLabel.Text = "⏸️ Idle"
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 12
    StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    StatusLabel.Parent = ContentFrame
    
    local StatusCorner = Instance.new("UICorner", StatusLabel)
    StatusCorner.CornerRadius = UDim.new(0, 6)
    
    local NameInput = Instance.new("TextBox")
    NameInput.Size = UDim2.new(1, -20, 0, 30)
    NameInput.Position = UDim2.new(0, 10, 0, 40)
    NameInput.PlaceholderText = "Macro name..."
    NameInput.Text = ""
    NameInput.Font = Enum.Font.Gotham
    NameInput.TextSize = 12
    NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    NameInput.BorderSizePixel = 0
    NameInput.ClearTextOnFocus = false
    NameInput.Parent = ContentFrame
    
    local NameInputCorner = Instance.new("UICorner", NameInput)
    NameInputCorner.CornerRadius = UDim.new(0, 6)
    
    local RecordButton = Instance.new("TextButton")
    RecordButton.Size = UDim2.new(0.48, 0, 0, 40)
    RecordButton.Position = UDim2.new(0, 10, 0, 80)
    RecordButton.Text = "🔴 Record"
    RecordButton.Font = Enum.Font.GothamBold
    RecordButton.TextSize = 13
    RecordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RecordButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    RecordButton.BorderSizePixel = 0
    RecordButton.Parent = ContentFrame
    
    local RecordCorner = Instance.new("UICorner", RecordButton)
    RecordCorner.CornerRadius = UDim.new(0, 8)
    
    local StopButton = Instance.new("TextButton")
    StopButton.Size = UDim2.new(0.48, 0, 0, 40)
    StopButton.Position = UDim2.new(0.52, 0, 0, 80)
    StopButton.Text = "⏹️ Save"
    StopButton.Font = Enum.Font.GothamBold
    StopButton.TextSize = 13
    StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    StopButton.BorderSizePixel = 0
    StopButton.Parent = ContentFrame
    
    local StopCorner = Instance.new("UICorner", StopButton)
    StopCorner.CornerRadius = UDim.new(0, 8)
    
    local MacroListButton = Instance.new("TextButton")
    MacroListButton.Size = UDim2.new(1, -20, 0, 35)
    MacroListButton.Position = UDim2.new(0, 10, 0, 130)
    MacroListButton.Text = "📁 Saved Macros (" .. #_G.savedMacros .. ") ▼"
    MacroListButton.Font = Enum.Font.GothamBold
    MacroListButton.TextSize = 13
    MacroListButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MacroListButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MacroListButton.BorderSizePixel = 0
    MacroListButton.Parent = ContentFrame
    
    local ListBtnCorner = Instance.new("UICorner", MacroListButton)
    ListBtnCorner.CornerRadius = UDim.new(0, 6)
    
    local MacroListFrame = Instance.new("ScrollingFrame")
    MacroListFrame.Size = UDim2.new(1, -20, 0, 0)
    MacroListFrame.Position = UDim2.new(0, 10, 0, 170)
    MacroListFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MacroListFrame.BorderSizePixel = 0
    MacroListFrame.ScrollBarThickness = 4
    MacroListFrame.Visible = false
    MacroListFrame.Parent = ContentFrame
    
    local MacroListCorner = Instance.new("UICorner", MacroListFrame)
    MacroListCorner.CornerRadius = UDim.new(0, 6)
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 3)
    UIListLayout.Parent = MacroListFrame
    
    local ExportButton = Instance.new("TextButton")
    ExportButton.Size = UDim2.new(0.48, 0, 0, 35)
    ExportButton.Position = UDim2.new(0, 10, 0, 175)
    ExportButton.Text = "📋 Export"
    ExportButton.Font = Enum.Font.GothamBold
    ExportButton.TextSize = 12
    ExportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExportButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    ExportButton.BorderSizePixel = 0
    ExportButton.Parent = ContentFrame
    
    local ExportCorner = Instance.new("UICorner", ExportButton)
    ExportCorner.CornerRadius = UDim.new(0, 6)
    
    local ImportButton = Instance.new("TextButton")
    ImportButton.Size = UDim2.new(0.48, 0, 0, 35)
    ImportButton.Position = UDim2.new(0.52, 0, 0, 175)
    ImportButton.Text = "📥 Import"
    ImportButton.Font = Enum.Font.GothamBold
    ImportButton.TextSize = 12
    ImportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ImportButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    ImportButton.BorderSizePixel = 0
    ImportButton.Parent = ContentFrame
    
    local ImportCorner = Instance.new("UICorner", ImportButton)
    ImportCorner.CornerRadius = UDim.new(0, 6)
    
    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Size = UDim2.new(1, -20, 0, 25)
    SelectedLabel.Position = UDim2.new(0, 10, 0, 220)
    SelectedLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SelectedLabel.Text = "Selected: None"
    SelectedLabel.Font = Enum.Font.Gotham
    SelectedLabel.TextSize = 11
    SelectedLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    SelectedLabel.Parent = ContentFrame
    
    local SelectedCorner = Instance.new("UICorner", SelectedLabel)
    SelectedCorner.CornerRadius = UDim.new(0, 6)
    
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
        gui.MainFrame:TweenSize(
            UDim2.new(0, 320, 0, 30),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
        gui.ContentFrame.Visible = false
        gui.MinimizeButton.Text = "➕"
    else
        gui.MainFrame:TweenSize(
            UDim2.new(0, 320, 0, 280),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
        gui.ContentFrame.Visible = true
        gui.MinimizeButton.Text = "➖"
    end
end

local function toggleMacroList(gui)
    _G.listExpanded = not _G.listExpanded
    
    if _G.listExpanded then
        gui.MacroListFrame.Visible = true
        gui.MacroListFrame:TweenSize(
            UDim2.new(1, -20, 0, 150),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
        gui.MainFrame:TweenSize(
            UDim2.new(0, 320, 0, 470),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
        gui.MacroListButton.Text = "📁 Saved Macros (" .. #_G.savedMacros .. ") ▲"
        gui.ExportButton.Position = UDim2.new(0, 10, 0, 330)
        gui.ImportButton.Position = UDim2.new(0.52, 0, 0, 330)
        gui.SelectedLabel.Position = UDim2.new(0, 10, 0, 375)
    else
        gui.MacroListFrame:TweenSize(
            UDim2.new(1, -20, 0, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true,
            function()
                gui.MacroListFrame.Visible = false
            end
        )
        gui.MainFrame:TweenSize(
            UDim2.new(0, 320, 0, 280),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.3,
            true
        )
        gui.MacroListButton.Text = "📁 Saved Macros (" .. #_G.savedMacros .. ") ▼"
        gui.ExportButton.Position = UDim2.new(0, 10, 0, 175)
        gui.ImportButton.Position = UDim2.new(0.52, 0, 0, 175)
        gui.SelectedLabel.Position = UDim2.new(0, 10, 0, 220)
    end
end

local function updateMacroList(gui)
    for _, child in ipairs(gui.MacroListFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    gui.MacroListButton.Text = "📁 Saved Macros (" .. #_G.savedMacros .. ") " .. (_G.listExpanded and "▲" or "▼")
    
    if #_G.savedMacros == 0 then
        local EmptyLabel = Instance.new("TextLabel")
        EmptyLabel.Size = UDim2.new(1, -10, 0, 30)
        EmptyLabel.BackgroundTransparency = 1
        EmptyLabel.Text = "No saved macros"
        EmptyLabel.Font = Enum.Font.Gotham
        EmptyLabel.TextSize = 11
        EmptyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        EmptyLabel.Parent = gui.MacroListFrame
        return
    end
    
    for i, macro in ipairs(_G.savedMacros) do
        local MacroItem = Instance.new("Frame")
        MacroItem.Size = UDim2.new(1, -10, 0, 40)
        MacroItem.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        MacroItem.BorderSizePixel = 0
        MacroItem.Parent = gui.MacroListFrame
        
        local ItemCorner = Instance.new("UICorner", MacroItem)
        ItemCorner.CornerRadius = UDim.new(0, 6)
        
        local MacroNameLabel = Instance.new("TextLabel")
        MacroNameLabel.Size = UDim2.new(0, 130, 1, 0)
        MacroNameLabel.Position = UDim2.new(0, 8, 0, 0)
        MacroNameLabel.BackgroundTransparency = 1
        MacroNameLabel.Text = "📄 " .. macro.name
        MacroNameLabel.Font = Enum.Font.GothamBold
        MacroNameLabel.TextSize = 11
        MacroNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        MacroNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        MacroNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        MacroNameLabel.Parent = MacroItem
        
        local ActionCountLabel = Instance.new("TextLabel")
        ActionCountLabel.Size = UDim2.new(0, 60, 1, 0)
        ActionCountLabel.Position = UDim2.new(0, 140, 0, 0)
        ActionCountLabel.BackgroundTransparency = 1
        ActionCountLabel.Text = #macro.actions .. " acts"
        ActionCountLabel.Font = Enum.Font.Gotham
        ActionCountLabel.TextSize = 10
        ActionCountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        ActionCountLabel.TextXAlignment = Enum.TextXAlignment.Left
        ActionCountLabel.Parent = MacroItem
        
        local PlayBtn = Instance.new("TextButton")
        PlayBtn.Size = UDim2.new(0, 30, 0, 30)
        PlayBtn.Position = UDim2.new(1, -75, 0.5, -15)
        PlayBtn.Text = "▶️"
        PlayBtn.Font = Enum.Font.GothamBold
        PlayBtn.TextSize = 14
        PlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        PlayBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        PlayBtn.BorderSizePixel = 0
        PlayBtn.Parent = MacroItem
        
        local PlayBtnCorner = Instance.new("UICorner", PlayBtn)
        PlayBtnCorner.CornerRadius = UDim.new(0, 6)
        
        local SelectBtn = Instance.new("TextButton")
        SelectBtn.Size = UDim2.new(0, 30, 0, 30)
        SelectBtn.Position = UDim2.new(1, -40, 0.5, -15)
        SelectBtn.Text = "✓"
        SelectBtn.Font = Enum.Font.GothamBold
        SelectBtn.TextSize = 14
        SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SelectBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
        SelectBtn.BorderSizePixel = 0
        SelectBtn.Parent = MacroItem
        
        local SelectBtnCorner = Instance.new("UICorner", SelectBtn)
        SelectBtnCorner.CornerRadius = UDim.new(0, 6)
        
        local DeleteBtn = Instance.new("TextButton")
        DeleteBtn.Size = UDim2.new(0, 30, 0, 30)
        DeleteBtn.Position = UDim2.new(1, -5, 0.5, -15)
        DeleteBtn.Text = "🗑️"
        DeleteBtn.Font = Enum.Font.GothamBold
        DeleteBtn.TextSize = 12
        DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        DeleteBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        DeleteBtn.BorderSizePixel = 0
        DeleteBtn.Parent = MacroItem
        
        local DeleteBtnCorner = Instance.new("UICorner", DeleteBtn)
        DeleteBtnCorner.CornerRadius = UDim.new(0, 6)
        
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
            warn("[MACRO] Deleted: " .. macro.name)
        end)
    end
    
    gui.MacroListFrame.CanvasSize = UDim2.new(0, 0, 0, #_G.savedMacros * 43)
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
    
    gui.StatusLabel.Text = "🔴 Recording..."
    gui.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    gui.RecordButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    gui.StopButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    
    warn("[MACRO] Recording started!")
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
    
    gui.StatusLabel.Text = "💾 Saved: " .. macroName
    gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    gui.RecordButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    gui.StopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    gui.NameInput.Text = ""
    
    updateMacroList(gui)
    
    warn("[MACRO] Saved: " .. macroName .. " (" .. #_G.recordedMacro .. " actions)")
    
    task.wait(3)
    gui.StatusLabel.Text = "⏸️ Idle"
    gui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
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
    
    gui.StatusLabel.Text = "▶️ Playing..."
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
                end
                
            elseif action.type == "upgrade" then
                if #_G.placedUnits >= action.unitIndex then
                    local unitID = _G.placedUnits[action.unitIndex].id or action.unitIndex
                    
                    pcall(function()
                        remotes.UpgradeUnit:InvokeServer(unitID)
                    end)
                end
                
            elseif action.type == "sell" then
                if #_G.placedUnits >= action.unitIndex then
                    local unitID = _G.placedUnits[action.unitIndex].id or action.unitIndex
                    
                    pcall(function()
                        remotes.SellUnit:InvokeServer(unitID)
                    end)
                end
            end
        end
        
        _G.macroPlaying = false
        gui.StatusLabel.Text = "✅ Complete!"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        warn("[MACRO] Playback finished!")
        
        task.wait(3)
        gui.StatusLabel.Text = "⏸️ Idle"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end)
end

local function exportMacro(gui)
    if not _G.selectedMacro then
        warn("[MACRO] No macro selected!")
        gui.StatusLabel.Text = "⚠️ Select a macro first"
        task.wait(2)
        gui.StatusLabel.Text = "⏸️ Idle"
        return
    end
    
    local encoded = HttpService:JSONEncode(_G.selectedMacro)
    setclipboard(encoded)
    
    gui.ExportButton.Text = "✅ Copied!"
gui.ExportButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
    
    warn("[MACRO] Exported: " .. _G.selectedMacro.name)
    
    task.wait(2)
    gui.ExportButton.Text = "📋 Export"
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
        
        gui.ImportButton.Text = "✅ Done!"
        gui.ImportButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
        gui.StatusLabel.Text = "✅ Imported: " .. result.name
        gui.StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        
        warn("[MACRO] Imported: " .. result.name)
        
        task.wait(2)
        gui.ImportButton.Text = "📥 Import"
        gui.ImportButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
        gui.StatusLabel.Text = "⏸️ Idle"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    else
        gui.ImportButton.Text = "❌ Failed!"
        gui.ImportButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        warn("[MACRO] Failed to import macro!")
        
        task.wait(2)
        gui.ImportButton.Text = "📥 Import"
        gui.ImportButton.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
    end
end

local gui = createMacroGui()

hookPlacement(gui)
hookUpgrade(gui)
hookSell(gui)

gui.MinimizeButton.MouseButton1Click:Connect(function()
    toggleMinimize(gui)
end)

gui.RecordButton.MouseButton1Click:Connect(function()
    startRecording(gui)
end)

gui.StopButton.MouseButton1Click:Connect(function()
    stopRecording(gui)
end)

gui.MacroListButton.MouseButton1Click:Connect(function()
    toggleMacroList(gui)
end)

gui.ExportButton.MouseButton1Click:Connect(function()
    exportMacro(gui)
end)

gui.ImportButton.MouseButton1Click:Connect(function()
    importMacro(gui)
end)

updateMacroList(gui)

warn("========================================")
warn("[MACRO RECORDER v3] Initialized")
warn("[FEATURES]")
warn("  • Compact GUI (320x280)")
warn("  • Minimizable")
warn("  • Collapsible macro list")
warn("  • Quick play/select/delete")
warn("[USAGE]")
warn("  1. Name your macro")
warn("  2. Click 'Record' → play game")
warn("  3. Click 'Save' when done")
warn("  4. Click 'Saved Macros' to expand list")
warn("  5. ▶️ Play | ✓ Select | 🗑️ Delete")
warn("========================================")
```

---

## ✅ **Macro Recorder v3 - Compact Edition**

### **🎨 Mejoras implementadas:**

1. **GUI compacta:**
   - Tamaño reducido: **320x280px**
   - Sin preview innecesario
   - Controles esenciales únicamente

2. **Minimizable:**
   - Botón **➖** en la esquina superior derecha
   - Se reduce a solo el título (30px)
   - Botón cambia a **➕** para expandir

3. **Lista colapsable:**
   - **"📁 Saved Macros (X) ▼"** - Click para expandir
   - La lista solo aparece cuando la necesitas
   - Se expande con animación suave
   - **▲** cuando está expandida, **▼** cuando está cerrada
   - Al seleccionar un macro, la lista se colapsa automáticamente

4. **Tamaños optimizados:**
   - Normal: **320x280px**
   - Expandida: **320x470px** (con lista)
   - Minimizada: **320x30px**

5. **Botones compactos por macro:**
   - **▶️** = Play inmediato
   - **✓** = Seleccionar (para export/import)
   - **🗑️** = Eliminar

6. **Indicador de selección:**
   - "Selected: None" / "Selected: MacroName"
   - Muestra qué macro se exportará

---

## **🎮 Flujo de uso simplificado:**

### **Grabar:**
```
1. Escribe nombre
2. 🔴 Record
3. Juega
4. ⏹️ Save
```

### **Reproducir:**
```
1. Click "📁 Saved Macros ▼"
2. Click ▶️ junto al macro
3. ¡Lista se cierra y reproduce!
```

### **Exportar:**
```
1. Click "📁 Saved Macros ▼"
2. Click ✓ junto al macro
3. Click "📋 Export"
```

### **Minimizar:**
```
Click ➖ en esquina superior derecha
