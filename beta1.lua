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
        gui.StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        task.wait(2)
        gui.StatusLabel.Text = "⏸️ Idle"
        gui.StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        return
    end
    
    local success, err = pcall(function()
        local encoded = HttpService:JSONEncode(_G.selectedMacro)
        setclipboard(encoded)
        
        gui.ExportButton.Text = "✅ Copied!"
        gui.ExportButton.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
        
        warn("[MACRO] Exported: " .. _G.selectedMacro.name)
    end)
    
    if not success then
        warn("[MACRO ERROR] Export failed: " .. tostring(err))
        gui.ExportButton.Text = "❌ Failed!"
        gui.ExportButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
    
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

-- Initialize GUI
local gui = createMacroGui()

-- Hook functions with error handling
hookPlacement(gui)
hookUpgrade(gui)
hookSell(gui)

-- Connect buttons
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
warn("[MACRO RECORDER v3 - FIXED] Initialized")
warn("[STATUS] RemoteFunctions found: " .. tostring(remotes ~= nil))
if remotes then
    warn("[REMOTES] Available:")
    for _, v in pairs(remotes:GetChildren()) do
        warn("  - " .. v.Name)
    end
end
warn("[FEATURES]")
warn("  • Compact GUI (320x280)")
warn("  • Minimizable")
warn("  • Collapsible macro list")
warn("  • Error handling enabled")
warn("[USAGE]")
warn("  1. Name your macro")
warn("  2. Click 'Record' → play game")
warn("  3. Click 'Save' when done")
warn("  4. Click 'Saved Macros' to expand list")
warn("  5. ▶️ Play | ✓ Select | 🗑️ Delete")
warn("========================================")
