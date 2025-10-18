local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local gui = plr:WaitForChild("PlayerGui")

-- Función para buscar botones con nombre parecido a "AutoSkip"
local function findAutoSkipButton(parent)
    for _, child in pairs(parent:GetDescendants()) do
        if child:IsA("TextButton") or child:IsA("ImageButton") then
            local nameLower = child.Name:lower()
            if string.find(nameLower, "autoskip") then
                return child
            end
        end
    end
    return nil
end

-- Intentar encontrar el botón
local button = findAutoSkipButton(gui)

if button then
    button:Activate() -- Simula clic
    print("[Sistema] Auto Skip activado automáticamente")
else
    warn("[Sistema] No se encontró ningún botón de Auto Skip")
end