local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local gui = plr:WaitForChild("PlayerGui")

-- Función para buscar cualquier botón de Auto Skip
local function findAutoSkipButton(parent)
    for _, child in pairs(parent:GetDescendants()) do
        if child:IsA("TextButton") or child:IsA("ImageButton") then
            if string.find(child.Name:lower(), "autoskip") then
                return child
            end
        end
    end
    return nil
end

-- Buscar el botón
local button = findAutoSkipButton(gui)

if button then
    button:Activate() -- Simula el clic
    print("[Sistema] Auto Skip activado automáticamente")
else
    warn("[Sistema] No se encontró ningún botón de Auto Skip")
end