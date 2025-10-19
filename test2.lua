local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

-- Función para disparar Auto Skip
local function enableAutoSkip()
    local connections = getconnections(autoSkipButton.MouseButton1Click)
    if connections and #connections > 0 then
        connections[1]:Fire()
        showStatus("Auto Skip: ON", Color3.fromRGB(95, 189, 0))
    end
end

-- Pop-up temporal
function showStatus(text, color)
    local popup = Instance.new("TextLabel", player.PlayerGui)
    popup.Size = UDim2.new(0, 300, 0, 50)
    popup.Position = UDim2.new(0.5, -150, 0.1, 0)
    popup.BackgroundColor3 = Color3.fromRGB(50,50,50)
    popup.TextColor3 = color
    popup.Font = Enum.Font.GothamBold
    popup.TextSize = 18
    popup.Text = text
    popup.BackgroundTransparency = 0.3
    task.delay(3, function() popup:Destroy() end)
end

-- Activar Auto Skip al inicio
task.delay(3, enableAutoSkip)

-- Revisar cada segundo si Auto Skip se desactivó (solo reactivar si es necesario)
task.spawn(function()
    local autoSkipActive = true
    while true do
        task.wait(1)
        local currentColor = autoSkipButton.BackgroundColor3
        if autoSkipActive and currentColor ~= Color3.fromRGB(95, 189, 0) then
            autoSkipActive = false
            enableAutoSkip() -- reactiva solo si se apagó
            autoSkipActive = true
        end
    end
end)

