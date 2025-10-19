local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

-- Verifica si es ImageButton y usa ImageColor3
local lastColor = autoSkipButton:IsA("ImageButton") and autoSkipButton.ImageColor3 or autoSkipButton.BackgroundColor3

local function showPopup(text, color)
    local guiPop = Instance.new("ScreenGui", player.PlayerGui)
    local frame = Instance.new("Frame", guiPop)
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

    task.delay(15, function() guiPop:Destroy() end)
end

task.spawn(function()
    while true do
        local currentColor = autoSkipButton:IsA("ImageButton") and autoSkipButton.ImageColor3 or autoSkipButton.BackgroundColor3
        if currentColor ~= lastColor then
            lastColor = currentColor
            local text
            if currentColor == Color3.fromRGB(95,189,0) then text="ON"
            elseif currentColor == Color3.fromRGB(219,145,0) then text="OFF"
            else text="UNKNOWN" end
            showPopup("Auto Skip: "..text, currentColor)
        end
        task.wait(0.2)
    end
end)