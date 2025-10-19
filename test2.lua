local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

-- Función para mostrar un pop-up
local function showPopup(message)
    local screenGui = Instance.new("ScreenGui", player.PlayerGui)
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 250, 0, 50)
    frame.Position = UDim2.new(0.5, -125, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = message

    -- Destruir pop-up después de 2.5 segundos
    task.delay(2.5, function()
        screenGui:Destroy()
    end)
end

-- Guardar color inicial
local lastColor = autoSkipButton.BackgroundColor3

-- Detectar cambios de color
autoSkipButton:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
    local currentColor = autoSkipButton.BackgroundColor3
    if currentColor ~= lastColor then
        lastColor = currentColor
        -- Convertir a RGB 0-255
        local r = math.floor(currentColor.R * 255)
        local g = math.floor(currentColor.G * 255)
        local b = math.floor(currentColor.B * 255)
        showPopup("Auto Skip Color Changed!\nRGB: ("..r..","..g..","..b..")")
    end
end)