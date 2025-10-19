-- Esperar a que la GUI cargue completamente
local gui = plr.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

-- Activar Auto Skip al inicio solo una vez
pcall(function()
    local c = autoSkipButton.ImageColor3
    -- OFF es naranja: R>0.4, G>0.6, B<0.1
    if c.R > 0.4 and c.G > 0.6 and c.B < 0.1 then
        local connections = getconnections(autoSkipButton.MouseButton1Click)
        if connections and #connections > 0 then
            connections[1]:Fire()
            print("[AutoSkip] Activated at start")
        end
    end
end)

-- Monitor de Auto Skip solo para reactivar si alguien lo apaga
task.defer(function()
    while task.wait(1) do
        pcall(function()
            local c = autoSkipButton.ImageColor3
            if c.R > 0.4 and c.G > 0.6 and c.B < 0.1 then
                local connections = getconnections(autoSkipButton.MouseButton1Click)
                if connections and #connections > 0 then
                    connections[1]:Fire()
                    print("[AutoSkip Monitor] Reactivated automatically")
                end
            end
        end)
    end
end)