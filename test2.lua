-- Auto Skip (enable once at start)
task.delay(6, function() -- espera 6 segundos antes de activar
    pcall(function()
        local player = game.Players.LocalPlayer
        local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
        local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

        local connections = getconnections(autoSkipButton.MouseButton1Click)
        if connections and #connections > 0 then
            connections[1]:Fire()
        end

        --=== Auto-reactivar si alguien lo apaga manualmente ===--
        local rs = game:GetService("ReplicatedStorage")
        local remotes = rs:WaitForChild("RemoteFunctions")

        local function enableAutoSkip()
            pcall(function()
                remotes.ToggleAutoSkip:InvokeServer(true)
                warn("[AutoSkip] Activated")
            end)
        end

        -- Detecta cambios manuales en el texto
        autoSkipButton:GetPropertyChangedSignal("Text"):Connect(function()
            local state = autoSkipButton.Text
            if state == "Auto Skip: Off" then
                enableAutoSkip()
                -- Opcional: pop-up en pantalla
                local popup = Instance.new("TextLabel")
                popup.Size = UDim2.new(0, 200, 0, 50)
                popup.Position = UDim2.new(0.5, -100, 0.1, 0)
                popup.BackgroundColor3 = Color3.fromRGB(0,0,0)
                popup.BackgroundTransparency = 0.5
                popup.TextColor3 = Color3.fromRGB(255,255,255)
                popup.Font = Enum.Font.GothamBold
                popup.TextSize = 18
                popup.Text = "Auto Skip re-activated"
                popup.Parent = player.PlayerGui
                task.delay(5, function() popup:Destroy() end)
            end
        end)
    end)
end)