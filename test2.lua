local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("GameGuiNoInset")
local autoSkipButton = gui:WaitForChild("Screen"):WaitForChild("Top"):WaitForChild("WaveControls"):WaitForChild("AutoSkip")

-- Función para obtener el color visual real
local function getVisualColor()
    -- Revisa todos los hijos y toma el primero que tenga BackgroundColor3
    for _, obj in ipairs(autoSkipButton:GetDescendants()) do
        if obj:IsA("Frame") or obj:IsA("ImageLabel") or obj:IsA("TextLabel") then
            return obj.BackgroundColor3
        end
    end
    -- Si no encuentra, devuelve el botón mismo
    return autoSkipButton.BackgroundColor3
end

local previousColor = getVisualColor()

task.spawn(function()
    while true do
        task.wait(0.3)
        local color = getVisualColor()
        if color ~= previousColor then
            previousColor = color

            -- Crear pop-up
            local pop = Instance.new("ScreenGui")
            pop.ResetOnSpawn = false
            pop.Parent = player.PlayerGui

            local label = Instance.new("TextLabel", pop)
            label.Size = UDim2.new(0, 300, 0, 50)
            label.Position = UDim2.new(0.5, -150, 0.1, 0)
            label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            label.BackgroundTransparency = 0.3
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.GothamBold
            label.TextSize = 18
            label.Text = string.format("Auto Skip Color RGB: %d, %d, %d",
                math.floor(color.R * 255),
                math.floor(color.G * 255),
                math.floor(color.B * 255)
            )

            task.delay(15, function()
                pop:Destroy()
            end)
        end
    end
end)