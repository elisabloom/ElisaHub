-- Espera a que la GUI de AutoSkip esté lista
local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

-- Variable global para controlar Auto Skip
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

-- Loop que revisa cada 0.5 segundos si Auto Skip está apagado
task.spawn(function()
    while true do
        task.wait(0.5)
        -- Solo actúa si la variable global dice que debe estar activo
        if _G.AutoSkipEnabled then
            local isOn = autoSkipButton:GetAttribute("Active") -- intentamos usar atributo
            -- Si no hay atributo, podemos usar booleano propio
            -- Consideraremos que se presionó si no coincide con nuestro estado
            if not isOn then
                activateAutoSkip()
            end
        else
            break
        end
    end
end)