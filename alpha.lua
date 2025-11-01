local plr = game.Players.LocalPlayer

print("=== ANALIZANDO LEADERSTATS ===")

local leaderstats = plr:FindFirstChild("leaderstats")
if leaderstats then
    print("Leaderstats encontrado! Tipo:", leaderstats.ClassName)
    print("Valor:", leaderstats.Value)
    
    print("\nHijos de leaderstats:")
    for _, child in pairs(leaderstats:GetChildren()) do
        print("  ", child.Name, child.ClassName)
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            print("    Valor:", child.Value)
        end
    end
else
    print("Leaderstats NO encontrado")
end

print("\n=== BUSCANDO OTROS DATOS ===")
for _, child in pairs(plr:GetChildren()) do
    if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
        print(child.Name, "=", child.Value)
    end
end

print("=== FIN ===")local plr = game.Players.LocalPlayer

print("=== ANALIZANDO LEADERSTATS ===")

local leaderstats = plr:FindFirstChild("leaderstats")
if leaderstats then
    print("Leaderstats encontrado! Tipo:", leaderstats.ClassName)
    print("Valor:", leaderstats.Value)
    
    print("\nHijos de leaderstats:")
    for _, child in pairs(leaderstats:GetChildren()) do
        print("  ", child.Name, child.ClassName)
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            print("    Valor:", child.Value)
        end
    end
else
    print("Leaderstats NO encontrado")
end

print("\n=== BUSCANDO OTROS DATOS ===")
for _, child in pairs(plr:GetChildren()) do
    if child:IsA("IntValue") or child:IsA("NumberValue") or child:IsA("StringValue") then
        print(child.Name, "=", child.Value)
    end
end

print("=== FIN ===")
