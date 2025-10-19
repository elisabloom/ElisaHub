--// Auto Skip Watchdog
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar a que cargue la GUI del juego
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

-- Identificadores de imagen
local ON_IMAGE = "rbxassetid://91983021855852"
local OFF_IMAGE = "rbxassetid://591983921855852"

print("[AutoSkip Watchdog] Activated. Checking every 1s...")

task.spawn(function()
    while true do
        task.wait(1) -- revisar cada segundo
        pcall(function()
            if autoSkipButton.Image == OFF_IMAGE then
                local connections = getconnections(autoSkipButton.MouseButton1Click)
                if connections and #connections > 0 then
                    -- intenta llamar a la función directamente
                    if connections[1].Function then
                        pcall(function() connections[1].Function() end)
                    else
                        -- fallback al Fire()
                        pcall(function() connections[1]:Fire() end)
                    end
                    print("[AutoSkip Watchdog] Auto Skip reactivated automatically")
                end
            end
        end)
    end
end)