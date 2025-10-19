local player = game.Players.LocalPlayer

-- Función que espera que exista un objeto en la jerarquía
local function WaitForChildOfClass(parent, name, className)
    local obj = parent:FindFirstChild(name)
    while not obj or obj.ClassName ~= className do
        obj = parent:FindFirstChild(name)
        task.wait(0.1)
    end
    return obj
end

-- Esperar a GameGuiNoInset
local gameGui = player.PlayerGui:WaitForChild("GameGuiNoInset")

-- Esperar a WaveControls y AutoSkip
local waveControls = WaitForChildOfClass(gameGui.Screen.Top, "WaveControls", "Frame")
local autoSkipButton = WaitForChildOfClass(waveControls, "AutoSkip", "TextButton") -- Cambiar clase si es ImageButton

-- Función para mostrar pop-up
local function showPopup(text, color)
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 250, 0, 50)
    frame.Position = UDim2.new(0.5, -125, 0.1, 0)
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 0

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18

    task.delay(15, function()
        gui:Destroy()
    end)
end

-- Detectar cambios en BackgroundColor3
autoSkipButton:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
    local col = autoSkipButton.BackgroundColor3
    local text
    if col == Color3.fromRGB(95, 189, 0) then
        text = "ON"
    elseif col == Color3.fromRGB(219, 145, 0) then
        text = "OFF"
    else
        text = "UNKNOWN"
    end
    showPopup("Auto Skip: "..text, col)
end)

-- Activar Auto Skip una sola vez al inicio
task.delay(6, function()
    local connections = getconnections(autoSkipButton.MouseButton1Click)
    if connections and #connections > 0 then
        connections[1]:Fire()
    end
end)