-- Auto Skip Watcher
task.spawn(function()
    local player = game.Players.LocalPlayer
    local gui = player:WaitForChild("PlayerGui"):WaitForChild("GameGuiNoInset")
    local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")
    
    -- Obtenemos la función interna del botón
    local connections = getconnections(autoSkipButton.MouseButton1Click)
    if not connections or #connections == 0 then return end
    local clickFunc = connections[1]

    -- Loop que fuerza auto skip cada 1.5 segundos
    while true do
        pcall(function()
            clickFunc:Fire()  -- dispara la función interna
        end)
        task.wait(1.5)
    end
end)