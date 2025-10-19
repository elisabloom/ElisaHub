task.delay(6, function() -- espera inicial antes de activar
    pcall(function()
        local player = game.Players.LocalPlayer
        local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
        local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

        -- Activar Auto Skip al inicio
        local connections = getconnections(autoSkipButton.MouseButton1Click)
        if connections and #connections > 0 then
            connections[1]:Fire()
            warn("[AutoSkip] Activado al inicio")
        end

        -- Listener para reactivar si se pone Off manualmente
        autoSkipButton:GetPropertyChangedSignal("Text"):Connect(function()
            if autoSkipButton.Text == "Auto Skip: Off" then
                -- Reactivar Auto Skip
                local connections = getconnections(autoSkipButton.MouseButton1Click)
                if connections and #connections > 0 then
                    connections[1]:Fire()
                    warn("[AutoSkip] Reactivado automáticamente")
                end
            end
        end)
    end)
end)