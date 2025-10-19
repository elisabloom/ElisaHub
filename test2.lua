--// Auto Reactivate Auto Skip
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar a que cargue la GUI del juego
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

print("[AutoSkip Monitor] Script started. Monitoring every 0.5s...")

local function checkAutoSkip()
    local c = autoSkipButton.ImageColor3
    -- Detectar OFF (naranja)
    if c.R > 0.9 and c.G > 0.6 and c.G < 0.7 and c.B < 0.1 then
        local connections = getconnections(autoSkipButton.MouseButton1Click)
        if connections and #connections > 0 then
            connections[1]:Fire()
            print("[AutoSkip Monitor] Auto Skip reactivated automatically")
        end
    end
end

-- Revisar cada 1 segundos
while task.wait(1) do
    pcall(checkAutoSkip)
end