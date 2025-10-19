local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

local ON_COLOR = Color3.fromRGB(95,189,0)
local OFF_COLOR = Color3.fromRGB(219,145,0)

local function colorsAreClose(c1, c2, tolerance)
    tolerance = tolerance or 0.05
    return math.abs(c1.R - c2.R) < tolerance
       and math.abs(c1.G - c2.G) < tolerance
       and math.abs(c1.B - c2.B) < tolerance
end

local lastState = "unknown"

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
    task.delay(15, function() popup:Destroy() end)
end

local function enableAutoSkip()
    local connections = getconnections(autoSkipButton.MouseButton1Click)
    if connections and #connections > 0 then
        connections[1]:Fire()
    end
end

-- Inicializar
if not colorsAreClose(autoSkipButton.BackgroundColor3, ON_COLOR) then
    enableAutoSkip()
end
lastState = "on"
showColorPopup(autoSkipButton.BackgroundColor3)

-- Loop de verificación
task.spawn(function()
    while true do
        local currentColor = autoSkipButton.BackgroundColor3
        if colorsAreClose(currentColor, OFF_COLOR) and lastState == "on" then
            enableAutoSkip()
            lastState = "on"
            showColorPopup(autoSkipButton.BackgroundColor3)
        elseif colorsAreClose(currentColor, ON_COLOR) and lastState ~= "on" then
            lastState = "on"
            showColorPopup(currentColor)
        end
        task.wait(1)
    end
end)