-- ==================== TARGETING MODE DETECTOR (DELTA COMPATIBLE) ====================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

print("==========================================")
print("[TARGET DETECTOR] Delta-compatible version")
print("[TARGET DETECTOR] Scanning RemoteEvents...")
print("==========================================")

-- ===== LISTAR TODOS LOS REMOTEEVENTS =====
local function listAllRemotes(parent, path, depth)
    depth = depth or 0
    if depth > 6 then return end
    
    for _, obj in pairs(parent:GetChildren()) do
        local currentPath = path .. "." .. obj.Name
        
        if obj:IsA("RemoteEvent") then
            print("📡 REMOTE: " .. currentPath)
        end
        
        local ok = pcall(function()
            if #obj:GetChildren() > 0 then
                listAllRemotes(obj, currentPath, depth + 1)
            end
        end)
    end
end

print("\n--- ALL REMOTEEVENTS IN REPLICATEDSTORAGE ---")
listAllRemotes(ReplicatedStorage, "ReplicatedStorage")
print("--- END OF LIST ---\n")

-- ===== HOOKEAR REMOTEEVENTS POR NOMBRE SOSPECHOSO =====
local monitored = {}

local function hookRemote(remote, path)
    if monitored[remote] then return end
    monitored[remote] = true
    
    -- Usar hookfunction si está disponible en Delta
    local hookOk = pcall(function()
        local original = remote.FireServer
        hookfunction(original, function(self, ...)
            local args = {...}
            print("\n🎯 [FIRED] " .. path)
            for i, arg in ipairs(args) do
                print("   Arg[" .. i .. "] = " .. tostring(arg) .. " | type: " .. type(arg))
                if type(arg) == "number" then
                    print("   Arg[" .. i .. "] hex = 0x" .. string.format("%X", math.abs(arg)))
                end
            end
            return original(self, ...)
        end)
    end)
    
    if not hookOk then
        -- Fallback: reemplazar directamente
        pcall(function()
            local original = remote.FireServer
            remote.FireServer = function(self, ...)
                local args = {...}
                print("\n🎯 [FIRED] " .. path)
                for i, arg in ipairs(args) do
                    print("   Arg[" .. i .. "] = " .. tostring(arg) .. " | type: " .. type(arg))
                end
                return original(self, ...)
            end
        end)
    end
end

-- ===== HOOKEAR TODOS LOS REMOTEEVENTS =====
local hookedCount = 0

local function hookAll(parent, path, depth)
    depth = depth or 0
    if depth > 6 then return end
    
    for _, obj in pairs(parent:GetChildren()) do
        local currentPath = path .. "." .. obj.Name
        
        if obj:IsA("RemoteEvent") then
            hookRemote(obj, currentPath)
            hookedCount = hookedCount + 1
        end
        
        pcall(function()
            if #obj:GetChildren() > 0 then
                hookAll(obj, currentPath, depth + 1)
            end
        end)
    end
end

hookAll(ReplicatedStorage, "ReplicatedStorage")

print("[TARGET DETECTOR] Hooked " .. hookedCount .. " remotes")
print("[TARGET DETECTOR] ✅ Ready!")
print("[TARGET DETECTOR] Now click the TARGET button on any unit")
print("==========================================\n")
