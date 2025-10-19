--// Auto Skip Auto-Reactivator
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar a que cargue la GUI del juego
local gui
repeat
    gui = player.PlayerGui:FindFirstChild("GameGuiNoInset")
    task.wait(0.5)
until gui

local autoSkipButton
repeat
    autoSkipButton = gui:FindFirstChild("Screen") 
        and gui.Screen.Top:FindFirstChild("WaveControls") 
        and gui.Screen.Top.WaveControls:FindFirstChild("AutoSkip")
    task.wait(0.5)
until autoSkipButton

local ON_IMAGE = "rbxassetid://91983021855852"
local OFF_IMAGE = "rbxassetid://591983921855852"

print("[AutoSkip Monitor] Monitoring Auto Skip every 1s...")

-- Intentar obtener la función interna del juego
local function triggerAutoSkip()
    local success = false
    -- Probar Activated
    if autoSkipButton.Activated then
        pcall(function() autoSkipButton.Activated:Fire() success = true end)
    end
    -- Probar MouseButton1Click
    if not success then
        local conns = getconnections(autoSkipButton.MouseButton1Click)
        if conns and #conns > 0 then
            pcall(function() conns[1]:Fire() success = true end)
        end
    end
    return success
end

-- Loop para monitorear y reactivar
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if autoSkipButton.Image == OFF_IMAGE then
                local activated = triggerAutoSkip()
                if not activated then
                    -- Como último recurso, forzar la imagen a ON
                    autoSkipButton.Image = ON_IMAGE
                    print("[AutoSkip Monitor] Forced Image to ON")
                else
                    print("[AutoSkip Monitor] Auto Skip reactivated via internal function")
                end
            end
        end)
    end
end)