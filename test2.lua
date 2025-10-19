-- Detector de color Auto Skip ON/OFF
local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

local lastColor = autoSkipButton.BackgroundColor3

-- Función para mostrar pop-up temporal
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
        local currentColor = autoSkipButton.BackgroundColor3
        if currentColor ~= lastColor then
            lastColor = currentColor
            showColorPopup(currentColor)
        end
        task.wait(0.5) -- revisa cada medio segundo
    end
end)