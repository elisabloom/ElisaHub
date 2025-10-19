-- Auto Skip (enable once at start y mostrar color)
task.delay(6, function() -- espera 6 segundos antes de activar
    pcall(function()
        local player = game.Players.LocalPlayer
        local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
        local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

        -- Activar Auto Skip una sola vez
        local connections = getconnections(autoSkipButton.MouseButton1Click)
        if connections and #connections > 0 then
            connections[1]:Fire()
        end

        -- Crear pop-up mostrando el color actual del botón Auto Skip
        local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
        local Label = Instance.new("TextLabel", ScreenGui)
        Label.Size = UDim2.new(0, 300, 0, 50)
        Label.Position = UDim2.new(0.5, -150, 0.1, 0)
        Label.BackgroundColor3 = Color3.fromRGB(0,0,0)
        Label.BackgroundTransparency = 0.5
        Label.TextColor3 = Color3.fromRGB(255,255,255)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 18

        local c = autoSkipButton.BackgroundColor3
        Label.Text = string.format("Auto Skip ON Color RGB: %d, %d, %d", math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))

        -- Destruir pop-up después de 15 segundos
        task.delay(15, function()
            ScreenGui:Destroy()
        end)
    end)
end)