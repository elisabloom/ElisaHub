local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

local lastState = autoSkipButton.ImageColor3 -- guarda el color actual

print("[AutoSkip Monitor] Started")

autoSkipButton:GetPropertyChangedSignal("ImageColor3"):Connect(function()
    local current = autoSkipButton.ImageColor3
    -- Detectar OFF: color verde (según tu dump)
    if current.R < 0.5 and current.G > 0.8 then
        -- Solo reactivar si el estado cambió desde ON a OFF
        if lastState.R > 0.5 then
            local connections = getconnections(autoSkipButton.MouseButton1Click)
            if connections and #connections > 0 then
                connections[1]:Fire()
                print("[AutoSkip Monitor] Reactivated Auto Skip automatically")
            end
        end
    end
    lastState = current
end)