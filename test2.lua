local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("GameGuiNoInset")
local autoSkipButton = gui:WaitForChild("Screen"):WaitForChild("Top"):WaitForChild("WaveControls"):WaitForChild("AutoSkip")

local function getVisualColor(btn)
    for _, child in ipairs(btn:GetDescendants()) do
        if child:IsA("Frame") or child:IsA("ImageLabel") then
            return child.BackgroundColor3 or child.ImageColor3
        end
    end
    return btn.BackgroundColor3
end

local previousColor = getVisualColor(autoSkipButton)

while true do
    task.wait(0.5) -- revisa cada medio segundo
    local color = getVisualColor(autoSkipButton)
    if color ~= previousColor then
        previousColor = color
        local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
        ScreenGui.ResetOnSpawn = false
        local Label = Instance.new("TextLabel", ScreenGui)
        Label.Size = UDim2.new(0, 300, 0, 50)
        Label.Position = UDim2.new(0.5, -150, 0.1, 0)
        Label.BackgroundColor3 = Color3.fromRGB(0,0,0)
        Label.BackgroundTransparency = 0.3
        Label.TextColor3 = Color3.fromRGB(255,255,255)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 18
        Label.Text = string.format("Auto Skip Color RGB: %d, %d, %d",
            math.floor(color.R*255),
            math.floor(color.G*255),
            math.floor(color.B*255)
        )
        task.delay(15, function() ScreenGui:Destroy() end)
    end
end