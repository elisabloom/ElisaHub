local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

local function showPopup(text, color)
    local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 250, 0, 50)
    Frame.Position = UDim2.new(0.5, -125, 0.1, 0)
    Frame.BackgroundColor3 = color
    Frame.BorderSizePixel = 0

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1,0,1,0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255,255,255)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 18

    task.delay(15, function()
        ScreenGui:Destroy()
    end)
end

-- Detecta cambios en el color real
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