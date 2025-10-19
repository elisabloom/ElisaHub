--// Auto Skip Manager
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Espera la GUI del juego
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

--// Remotes
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunctions")

--=== 1️⃣ Activar Auto Skip automáticamente una vez ===--
task.delay(5, function() -- espera 5 segundos para que todo cargue
    pcall(function()
        remotes.ToggleAutoSkip:InvokeServer(true)
        warn("[System] Auto Skip Activated via Remote")
    end)
end)

--=== 2️⃣ Detectar cambios manuales y mostrar pop-up ===--
autoSkipButton:GetPropertyChangedSignal("Text"):Connect(function()
    local state = autoSkipButton.Text -- "Auto Skip: On" o "Auto Skip: Off"

    local popup = Instance.new("TextLabel")
    popup.Size = UDim2.new(0, 250, 0, 50)
    popup.Position = UDim2.new(0.5, -125, 0.1, 0)
    popup.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    popup.BackgroundTransparency = 0.5
    popup.TextColor3 = Color3.fromRGB(255, 255, 255)
    popup.Text = state
    popup.Font = Enum.Font.GothamBold
    popup.TextSize = 18
    popup.Parent = player.PlayerGui

    -- Destruye el pop-up después de 15 segundos
    task.delay(15, function()
        if popup then popup:Destroy() end
    end)
end)