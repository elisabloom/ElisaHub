local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")

-- 1️⃣ Buscar el Remote correcto
local function findAutoSkipRemote()
    for _, child in pairs(rs:GetDescendants()) do
        if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
            local nameLower = child.Name:lower()
            if string.find(nameLower, "autoskip") or string.find(nameLower, "skip") then
                return child
            end
        end
    end
    return nil
end

local remote = findAutoSkipRemote()

if remote then
    -- 2️⃣ Activar Auto Skip según tipo de Remote
    if remote:IsA("RemoteFunction") then
        pcall(function()
            remote:InvokeServer(true)
        end)
    elseif remote:IsA("RemoteEvent") then
        pcall(function()
            remote:FireServer(true)
        end)
    end
    print("[Sistema] Auto Skip activado automáticamente")

    -- 3️⃣ Actualizar el texto en pantalla
    local function updateAutoSkipText(parent)
        for _, child in pairs(parent:GetDescendants()) do
            if child:IsA("TextLabel") then
                local textLower = child.Text:lower()
                if string.find(textLower, "auto skip") then
                    child.Text = "Auto Skip: On"
                    child.TextColor3 = Color3.fromRGB(0,255,0)
                    print("[Sistema] Texto de Auto Skip actualizado")
                end
            end
        end
    end

    updateAutoSkipText(plr.PlayerGui)
else
    warn("[Sistema] No se encontró ningún Remote de Auto Skip")
end

