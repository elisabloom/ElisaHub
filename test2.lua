local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

-- Crear pop-up para mostrar estado
local function showPopup(text)
    local popup = Instance.new("TextLabel")
    popup.Size = UDim2.new(0, 200, 0, 50)
    popup.Position = UDim2.new(0.5, -100, 0.1, 0)
    popup.BackgroundColor3 = Color3.fromRGB(0,0,0)
    popup.TextColor3 = Color3.fromRGB(255,255,255)
    popup.Text = text
    popup.Font = Enum.Font.GothamBold
    popup.TextSize = 18
    popup.BackgroundTransparency = 0.5
    popup.Parent = player.PlayerGui
    task.delay(3, function()
        popup:Destroy()
    end)
end

-- Función para revisar estado y activar si está OFF
local function checkAutoSkip()
    if autoSkipButton.Text:find("OFF") then
        -- Activar Auto Skip
        local connections = getconnections(autoSkipButton.MouseButton1Click)
        if connections and #connections > 0 then
            connections[1]:Fire()
        end
        showPopup("Auto Skip was OFF → Activated")
    else
        showPopup("Auto Skip is ON")
    end
end

-- Ejecutar la primera vez
checkAutoSkip()

-- Conectar para detectar cambios manuales
autoSkipButton:GetPropertyChangedSignal("Text"):Connect(function()
    checkAutoSkip()
end)