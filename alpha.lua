local plr = game.Players.LocalPlayer
local gui = plr.PlayerGui

print("=== BUSCANDO VICTORIAS EN MENU DE STATS ===")

for _, screenGui in pairs(gui:GetChildren()) do
    if screenGui:IsA("ScreenGui") then
        print("\n--- ScreenGui:", screenGui.Name, "---")
        for _, obj in pairs(screenGui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = obj.Text
                local name = obj.Name
                
                -- Buscar números (posibles victorias)
                if txt:match("%d+") or name:lower():find("win") or name:lower():find("victor") or name:lower():find("stat") then
                    print("Nombre:", name, "| Texto:", txt, "| Parent:", obj.Parent.Name)
                end
            end
        end
    end
end

print("=== FIN ===")
