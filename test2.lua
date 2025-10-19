--// Auto Reactivate Auto Skip (OFF = naranja)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar a que cargue la GUI del juego
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

print("[AutoSkip Monitor] Script started. Monitoring changes...")

-- Función para detectar OFF (naranja)
local function isOff(color)
    -- Ajusta los valores según tu dump
    return color.R > 0.4 and color.R < 0.5 and color.G > 0.88 and color.G < 0.91 and color.B < 0.01
end

-- Reactivar Auto Skip
local function reactivate()
    local connections = getconnections(autoSkipButton.MouseButton1Click)
    if connections and #connections > 0 then
        connections[1]:Fire()
        print("[AutoSkip Monitor] Auto Skip reactivated automatically")
    end
end

-- Detectar cambios en ImageColor3
autoSkipButton:GetPropertyChangedSignal("ImageColor3"):Connect(function()
    if isOff(autoSkipButton.ImageColor3) then
        reactivate()
    end
end)
