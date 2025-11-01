-- Debug para encontrar victorias totales
local plr = game.Players.LocalPlayer

print("=== BUSCANDO VICTORIAS TOTALES ===")

-- Método 1: Buscar en leaderstats
if plr:FindFirstChild("leaderstats") then
    print("leaderstats encontrado:")
    for _, stat in pairs(plr.leaderstats:GetChildren()) do
        print("  ", stat.Name, "=", stat.Value)
    end
end

-- Método 2: Buscar en PlayerGui (estadísticas en pantalla)
local gui = plr.PlayerGui:FindFirstChild("GameGui")
if gui then
    print("\nBuscando en GameGui:")
    for _, obj in pairs(gui:GetDescendants()) do
        if obj:IsA("TextLabel") then
            local txt = obj.Text:lower()
            local name = obj.Name:lower()
            
            -- Buscar palabras clave relacionadas a victorias/stats
            if txt:find("win") or txt:find("victor") or txt:find("total") or 
               name:find("win") or name:find("victor") or name:find("stat") then
                print("  ", obj.Name, "Parent:", obj.Parent.Name, "Text:", obj.Text)
            end
        end
    end
end

-- Método 3: Buscar en Data (donde normalmente se guardan stats)
if plr:FindFirstChild("Data") then
    print("\nData encontrado:")
    for _, data in pairs(plr.Data:GetChildren()) do
        print("  ", data.Name, "=", data.Value)
    end
end

-- Método 4: Buscar en PlayerData o similar
for _, child in pairs(plr:GetChildren()) do
    local name = child.Name:lower()
    if name:find("data") or name:find("stat") or name:find("profile") then
        print("\nEncontrado:", child.Name)
        if child:IsA("Folder") or child:IsA("Configuration") then
            for _, subChild in pairs(child:GetChildren()) do
                print("  ", subChild.Name, "=", subChild.Value)
            end
        end
    end
end

-- Método 5: Revisar ReplicatedStorage (a veces guarda stats del jugador)
local repStorage = game:GetService("ReplicatedStorage")
print("\nBuscando en ReplicatedStorage:")
for _, obj in pairs(repStorage:GetDescendants()) do
    local name = obj.Name:lower()
    if name:find("win") or name:find("victor") or name:find(plr.Name:lower()) then
        print("  ", obj.Name, "Path:", obj:GetFullName())
    end
end

print("=== FIN BÚSQUEDA ===")
```

## Una vez que encuentres dónde están las victorias

Cuando ejecutes el código de arriba, probablemente verás algo como:
```
Data encontrado:
   Wins = 42
   Losses = 15
   TotalGames = 57
```

O quizás:
```
leaderstats encontrado:
   Victories = 42
```

## Entonces actualizamos el script

Una vez que sepas la ubicación exacta, me dices el resultado y actualizaré el script para incluir las victorias totales en el webhook.

**Ejemplo de cómo se vería:**
```
User: ||67cheesy||
Seed: 2903842
Candy: 958
Run Time: 0:55
Result: Defeat
Total Wins: 127
