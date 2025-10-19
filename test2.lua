-- Re-activador usando RemoteFunctions.ToggleAutoSkip
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")

local function enableAutoSkipViaRemote()
    pcall(function()
        remotes.ToggleAutoSkip:InvokeServer(true)
        warn("[AutoSkip] Activated via RemoteFunctions.ToggleAutoSkip")
    end)
end

-- Activar una vez al inicio tras 5s
task.delay(5, function()
    enableAutoSkipViaRemote()
end)

-- Loop de vigilancia: solo re-activa si detectamos que el jugador manualmente lo apagó.
-- Para detectar el apagado uamos varias estrategias: 1) si el texto contiene "Off", 2) fallback: intentar reactivar cada N segundos si quieres.
task.spawn(function()
    local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
    local autoSkipButton = gui:WaitForChild("Screen"):WaitForChild("Top"):WaitForChild("WaveControls"):WaitForChild("AutoSkip")

    -- si el juego no actualiza texto, puedes comentar la verificación por texto y usar reactivación por intervalo
    while true do
        task.wait(2)
        local ok, txt = pcall(function() return autoSkipButton.Text end)
        if ok and type(txt) == "string" and string.find(txt:lower(), "off") then
            enableAutoSkipViaRemote()
        end
        -- OPCIONAL: forzar reactivación cada X segundos (descomenta si quieres)
        -- task.wait(60); enableAutoSkipViaRemote()
    end
end)