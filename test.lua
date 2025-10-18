task.wait(5)
warn("🛰 Escaneando interfaces...")

for _,gui in ipairs(game:GetDescendants()) do
    if gui:IsA("TextButton") and string.find(string.lower(gui.Name), "skip") then
        warn("🎯 Botón posible encontrado:", gui:GetFullName())
    end
end

warn("✅ Escaneo completado.")