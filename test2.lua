local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

-- Función para disparar el Auto Skip
local function enableAutoSkip()
    local connections = getconnections(autoSkipButton.MouseButton1Click)
    if connections and #connections > 0 then
        connections[1]:Fire()
    end
end

-- Pop-up para mostrar estado
local function showStatus(text, color)
    local popup = Instance.new("TextLabel", player.PlayerGui)
    popup.Size = UDim2.new(0, 300, 0, 50)
    popup.Position = UDim2.new(0.5, -150, 0.1, 0)
    popup.BackgroundColor3 = Color3.fromRGB(50,50,50)
    popup.TextColor3 = color
    popup.Font = Enum.Font.GothamBold
    popup.TextSize = 18
    popup.Text = text
    popup.BackgroundTransparency = 0.3

    task.delay(3, function()
        popup:Destroy()
    end)
end

-- Activar Auto Skip al inicio
task.delay(3, function()
    pcall(function()
        enableAutoSkip()
        showStatus("Auto Skip: ON", Color3.fromRGB(95, 189, 0))
    end)
end)

-- Detectar cambios manuales
local lastState = true -- asumimos que al inicio está ON
task.spawn(function()
    while true do
        task.wait(1)
        local currentState = autoSkipButton.BackgroundColor3 == Color3.fromRGB(95, 189, 0) -- solo decorativo
        if currentState ~= lastState then
            lastState = currentState
            if not currentState then
                enableAutoSkip()
                showStatus("Auto Skip reactivado", Color3.fromRGB(95, 189, 0))
            else
                showStatus("Auto Skip: ON", Color3.fromRGB(95, 189, 0))
            end
        end
    end
end)