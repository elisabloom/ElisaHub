-- Mantener Auto Skip siempre activado
task.spawn(function()
    local player = game.Players.LocalPlayer
    local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
    local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

    local connections = getconnections(autoSkipButton.MouseButton1Click)
    if not connections or #connections == 0 then
        warn("[AutoSkip] No se encontró la función del botón")
        return
    end

    local clickFunc = connections[1]

    -- Activar Auto Skip una vez al inicio
    clickFunc:Fire()

    while true do
        task.wait(1) -- revisar cada 1 segundo
        -- Si el texto del botón es "Auto Skip: Off", volver a activarlo
        if autoSkipButton.Text == "Auto Skip: Off" then
            clickFunc:Fire()
            warn("[AutoSkip] Se reactivó Auto Skip automáticamente")
        end
    end
end)