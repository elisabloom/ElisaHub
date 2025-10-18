mlocal player = game.Players.LocalPlayer
local found = false

for _,v in ipairs(player.PlayerGui:GetDescendants()) do
    if v:IsA("TextButton") and string.find(string.lower(v.Name), "skip") then
        warn("🔍 Posible botón encontrado:", v:GetFullName())
        found = true
    end
end

if not found then
    warn("⚠️ No se encontró ningún botón con 'skip' en el nombre. Prueba cuando estés dentro de la partida.")
end