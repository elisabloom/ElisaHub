local ReplicatedStorage = game:GetService("ReplicatedStorage")

for _,v in ipairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        v.OnClientEvent:Connect(function(...)
            game.StarterGui:SetCore("SendNotification", {
                Title = "🎯 RemoteEvent Detectado";
                Text = v:GetFullName();
                Duration = 6;
            })
        end)
        if v:IsA("RemoteFunction") then
            local old; old = hookfunction(v.InvokeServer, function(self, ...)
                game.StarterGui:SetCore("SendNotification", {
                    Title = "⚙️ RemoteFunction Detectado";
                    Text = self:GetFullName();
                    Duration = 6;
                })
                return old(self, ...)
            end)
        end
    end
end

game.StarterGui:SetCore("SendNotification", {
    Title = "🛰 Detector listo";
    Text = "Presiona Auto Skip ON ahora.";
    Duration = 6;
})