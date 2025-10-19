task.delay(6, function() -- espera 6 segundos antes de activar
    pcall(function()
        local player = game.Players.LocalPlayer
        local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
        local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip
        local connections = getconnections(autoSkipButton.MouseButton1Click)

        if connections and #connections > 0 then
            connections[1]:Fire() -- activamos al inicio
            warn("[AutoSkip] Activated at start")
        end

        -- Guardamos que queremos que siempre esté On
        local desiredState = true

        -- Loop que mantiene Auto Skip activado
        task.spawn(function()
            while true do
                task.wait(1.5)
                -- Forzamos click si el estado se cambió a Off
                -- Este método dispara el click siempre que no está activado
                -- No depende de color ni texto
                local currentText = autoSkipButton.Text
                if currentText:find("Off") and connections and #connections > 0 then
                    connections[1]:Fire()
                    warn("[AutoSkip] Re-activated automatically")
                end
            end
        end)
    end)
end)