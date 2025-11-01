local plr = game.Players.LocalPlayer

print("=== BUSCANDO WINS EN DATOS DEL JUGADOR ===")

-- Método 1: Buscar en el jugador directamente
for _, child in pairs(plr:GetChildren()) do
    print("Player child:", child.Name, child.ClassName)
    if child:IsA("Folder") or child:IsA("Configuration") or child:IsA("IntValue") or child:IsA("NumberValue") then
        for _, subChild in pairs(child:GetChildren()) do
            local name = subChild.Name:lower()
            if name:find("win") or name:find("victor") then
                print("  ENCONTRADO:", subChild.Name, "=", subChild.Value)
            end
        end
    end
end

-- Método 2: Buscar en ReplicatedStorage
local repStorage = game:GetService("ReplicatedStorage")
print("\n=== REPLICATEDSTORAGE ===")
for _, obj in pairs(repStorage:GetDescendants()) do
    local name = obj.Name:lower()
    if name:find("win") or name:find("victor") or name:find("stat") then
        if obj:IsA("IntValue") or obj:IsA("NumberValue") then
            print("Found:", obj:GetFullName(), "=", obj.Value)
        end
    end
end

print("=== FIN ===")
