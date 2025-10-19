local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

-- Función para obtener el color visible del botón
local function getButtonColor(btn)
    -- Si es un TextButton usa su BackgroundColor3
    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
        return btn.BackgroundColor3
    end
    -- Si tiene Frames internos con color
    for _, child in ipairs(btn:GetChildren()) do
        if child:IsA("Frame") then
            return child.BackgroundColor3
        end
    end
    return Color3.new(1,1,1) -- blanco por defecto si no encuentra
end

local lastColor = getButtonColor(autoSkipButton)

-- Función para mostrar pop-up
local function showColorPopup(color)
    local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
    local Label = Instance.new("TextLabel", ScreenGui)
    Label.Size = UDim2.new(0, 300, 0, 50)
    Label.Position = UDim2.new(0.5, -150, 0.1, 0)
    Label.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Label.BackgroundTransparency = 0.5
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 18

    Label.Text = string.format("Auto Skip Color RGB: %d, %d, %d",
        math.floor(color.R*255),
        math.floor(color.G*255),
        math.floor(color.B*255)
    )

    task.delay(15, function()
        ScreenGui:Destroy()
    end)
end

-- Loop para detectar cambios de color
task.spawn(function()
    while true do
        local currentColor = getButtonColor(autoSkipButton)
        if currentColor ~= lastColor then
            lastColor = currentColor
            showColorPopup(currentColor)
        end
        task.wait(0.5)
    end
end)