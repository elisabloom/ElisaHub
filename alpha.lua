local plr = game.Players.LocalPlayer

print("=== BUSCANDO VICTORIAS TOTALES (SEGURO) ===")

local success1 = pcall(function()
    if plr:FindFirstChild("leaderstats") then
        print("leaderstats encontrado:")
        for _, stat in pairs(plr.leaderstats:GetChildren()) do
            print("  ", stat.Name, "=", stat.Value)
        end
    else
        print("leaderstats NO encontrado")
    end
end)

local success2 = pcall(function()
    if plr:FindFirstChild("Data") then
        print("\nData encontrado:")
        for _, data in pairs(plr.Data:GetChildren()) do
            print("  ", data.Name, "=", data.Value)
        end
    else
        print("Data NO encontrado")
    end
end)

local success3 = pcall(function()
    print("\nTodos los hijos del jugador:")
    for _, child in pairs(plr:GetChildren()) do
        print("  ", child.Name, "Type:", child.ClassName)
        if child:IsA("Folder") or child:IsA("Configuration") then
            for _, subChild in pairs(child:GetChildren()) do
                pcall(function()
                    print("    ", subChild.Name, "=", subChild.Value)
                end)
            end
        end
    end
end)

local success4 = pcall(function()
    local gui = plr.PlayerGui:FindFirstChild("GameGui")
    if gui then
        print("\nBuscando 'Wins' o 'Victories' en GameGui:")
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("IntValue") or obj:IsA("NumberValue") then
                local name = obj.Name:lower()
                if name:find("win") or name:find("victor") or name:find("total") then
                    pcall(function()
                        if obj:IsA("TextLabel") then
                            print("  TextLabel:", obj.Name, "Text:", obj.Text, "Parent:", obj.Parent.Name)
                        else
                            print("  Value:", obj.Name, "=", obj.Value, "Parent:", obj.Parent.Name)
                        end
                    end)
                end
            end
        end
    end
end)

print("=== FIN BÚSQUEDA ===")