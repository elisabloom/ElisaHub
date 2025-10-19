local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("GameGuiNoInset")
local autoSkipButton = gui:WaitForChild("Screen"):WaitForChild("Top"):WaitForChild("WaveControls"):WaitForChild("AutoSkip")

-- Función para obtener color visible
local function getButtonColor(btn)
    if btn:IsA("TextButton") or btn:IsA("ImageButton") then
        return btn.BackgroundColor3
    end
    for _, child in ipairs(btn:GetChildren()) do
        if child:IsA("Frame") then
            return child.BackgroundColor3
        end
    end
    return Color3.new(1,1,1)
end

local color = getButtonColor(autoSkipButton)

-- Crear pop-up en pantalla
local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
ScreenGui.ResetOnSpawn = false
local Label = Instance.new("TextLabel", ScreenGui)
Label.Size = UDim2.new(0, 300, 0, 50)
Label.Position = UDim2.new(0.5, -150, 0.1, 0)
Label.BackgroundColor3 = Color3.fromRGB(0,0,0)
Label.BackgroundTransparency = 0.3
Label.TextColor3 = Color3.fromRGB(255,255,255)
Label.TextStrokeTransparency = 0
Label.Font = Enum.Font.GothamBold
Label.TextSize = 18
Label.Text = string.format("Auto Skip Color RGB: %d, %d, %d",
    math.floor(color.R*255),
    math.floor(color.G*255),
    math.floor(color.B*255)
)

-- Duración 15 segundos
task.delay(15, function()
    ScreenGui:Destroy()
end)