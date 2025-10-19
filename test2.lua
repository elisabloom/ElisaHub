-- Espera a que el jugador y GUI estén listos
local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

-- Colores
local ON_COLOR = Color3.fromRGB(95,189,0)
local OFF_COLOR = Color3.fromRGB(219,145,0)

-- Función para comparar colores con tolerancia
local function colorsAreClose(c1, c2, tolerance)
    tolerance = tolerance or 0.02
    return math.abs(c1.R - c2.R) < tolerance
       and math.abs(c1.G - c2.G) < tolerance
       and math.abs(c1.B - c2.B) < tolerance
end

-- Función para mostrar pop-up
local function showColorPopup(color)
    local popup = Instance.new("TextLabel")
    popup.Size = UDim2.new(0, 250, 0, 50)
    popup.Position = UDim2.new(0.5, -125, 0.1, 0)
    popup.BackgroundColor3 = Color3.fromRGB(30,30,30)
    popup.TextColor3 = Color3.new(1,1,1)
    popup.Font = Enum.Font.GothamBold
    popup.TextSize = 16
    popup.Text = string.format("Auto Skip Color: R=%d, G=%d, B=%d", 
        math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
    popup.Parent = player.PlayerGui

    task.delay(15, function()
        popup:Destroy()
    end)
end

-- Función para activar Auto Skip
local function enableAutoSkip()
    local connections = getconnections(autoSkipButton.MouseButton1Click)
    if connections and #connections > 0 then
        connections[1]:Fire()
    end
end

-- Estado inicial
local lastState = autoSkipButton.BackgroundColor3
enableAutoSkip()
showColorPopup(autoSkipButton.BackgroundColor3)

-- Loop para verificar cambios manuales
task.spawn(function()
    while true do
        local currentColor = autoSkipButton.BackgroundColor3
        if not colorsAreClose(currentColor, ON_COLOR) then
            enableAutoSkip()
            showColorPopup(autoSkipButton.BackgroundColor3)
        elseif not colorsAreClose(currentColor, lastState) then
            -- Solo mostrar pop-up si cambió manualmente
            showColorPopup(currentColor)
        end
        lastState = currentColor
        task.wait(1)
    end
end)