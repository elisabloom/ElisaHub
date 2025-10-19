--// Test Auto Skip Watchdog
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar a que cargue la GUI del juego
local gui
repeat
    gui = player.PlayerGui:FindFirstChild("GameGuiNoInset")
    task.wait(0.5)
until gui
print("[Watchdog Test] GUI loaded")

local autoSkipButton
repeat
    autoSkipButton = gui:FindFirstChild("Screen") and gui.Screen.Top:FindFirstChild("WaveControls") and gui.Screen.Top.WaveControls:FindFirstChild("AutoSkip")
    task.wait(0.5)
until autoSkipButton
print("[Watchdog Test] AutoSkip button found")

local ON_IMAGE = "rbxassetid://91983021855852"
local OFF_IMAGE = "rbxassetid://591983921855852"

print("[Watchdog Test] Monitoring AutoSkip every 1s...")

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if autoSkipButton.Image == OFF_IMAGE then
                local connections = getconnections(autoSkipButton.MouseButton1Click)
                if connections and #connections > 0 then
                    connections[1]:Fire()
                    print("[Watchdog Test] Auto Skip reactivated automatically")
                end
            end
        end)
    end
end)