-- 🔍 Remote Detector (iPhone compatible)
-- Ejecuta este script y luego presiona "Auto Skip ON" en el juego

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function listenRemote(remote)
    if remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(...)
            local args = {...}
            local data = ""
            for i, v in ipairs(args) do
                data = data .. tostring(v) .. " "
            end
            local msg = "[EVENT] " .. remote:GetFullName() .. " | Args: " .. data
            print(msg)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Remote Detectado 🎯";
                Text = remote:GetFullName();
                Duration = 8;
            })
        end)
    elseif remote:IsA("RemoteFunction") then
        local old; old = hookfunction(remote.InvokeServer, function(self, ...)
            local args = {...}
            local data = ""
            for i, v in ipairs(args) do
                data = data .. tostring(v) .. " "
            end
            local msg = "[FUNCTION] " .. self:GetFullName() .. " | Args: " .. data
            print(msg)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Remote Detectado 🎯";
                Text = self:GetFullName();
                Duration = 8;
            })
            return old(self, ...)
        end)
    end
end

for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        listenRemote(v)
    end
end

print("🛰 Escuchando todos los remotes... Presiona 'Auto Skip ON'.")
game.StarterGui:SetCore("SendNotification", {
    Title = "🛰 Detector activado";
    Text = "Presiona Auto Skip ON ahora.";
    Duration = 6;
})