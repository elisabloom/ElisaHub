--// Auto Reactivate Auto Skip
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar a que cargue la GUI del juego
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

print("[AutoSkip Monitor] Script started. Monitoring every 0.5s...")

local function checkAutoSkip()
    -- OFF detectado por ImageColor3 verde
    local c = autoSkipButton.ImageColor3
    if c.R < 0.5 and c.G > 0.8 then
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