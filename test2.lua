--// Auto Reactivate Auto Skip
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar a que cargue la GUI del juego
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

print("[AutoSkip Monitor] Script started. Monitoring every 0.5s...")

local function isOff(color)
    -- Detecta naranja (OFF)
    return color.R > 0.44 and color.R < 0.46
       and color.G > 0.88 and color.G < 0.91
       and color.B < 0.01
end

local function checkAutoSkip()
    local c = autoSkipButton.ImageColor3
    if isOff(c) then
        local connections = getconnections(autoSkipButton.MouseButton1Click)
        if connections and #connections > 0 then
            connections[1]:Fire()
            print("[AutoSkip Monitor] Auto Skip reactivated automatically")
        end
    end
end

-- Revisar cada 0.5 segundos
while task.wait(0.5) do
    pcall(checkAutoSkip)
end