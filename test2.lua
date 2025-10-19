local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

-- Función para mostrar el pop-up en pantalla
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

-- Estado previo
local prevState = nil

-- Loop que revisa cambios cada 0.5 segundos
task.spawn(function()
    while true do
        local stateText = autoSkipButton.Text -- Usa el texto para detectar ON/OFF
        local stateColor

        if stateText:lower():find("on") then
            stateColor = Color3.fromRGB(95, 189, 0) -- verde
        elseif stateText:lower():find("off") then
            stateColor = Color3.fromRGB(219, 145, 0) -- naranja
        else
            stateColor = Color3.fromRGB(255,255,255) -- fallback
        end

        if stateText ~= prevState then
            showPopup("Auto Skip: "..stateText, stateColor)
            prevState = stateText
        end

        task.wait(0.5)
    end
end)