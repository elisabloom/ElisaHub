-- Espera a la GUI de AutoSkip
local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

-- Variable para controlar si Auto Skip debe estar activo
_G.AutoSkipEnabled = true

-- Función para activar Auto Skip
local function activateAutoSkip()
    local connections = getconnections(autoSkipButton.MouseButton1Click)
    if connections and #connections > 0 then
        connections[1]:Fire()
    end
end

-- Activar Auto Skip al inicio
task.delay(6, function()
    activateAutoSkip()
end)

-- Detectar si alguien hace click manual en Auto Skip
autoSkipButton.MouseButton1Click:Connect(function()
    if _G.AutoSkipEnabled then
        -- Pequeño delay para esperar que cambie el estado
        task.wait(0.1)
        -- Vuelve a activar si alguien lo apagó
        activateAutoSkip()
    end
end)
