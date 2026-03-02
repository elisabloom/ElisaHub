-- ==================== TARGETING MODE DETECTOR ====================
-- Ejecutar ANTES de cambiar el target de cualquier unidad manualmente
-- Luego cambiar el target de una unidad en el juego y ver el output

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

print("==========================================")
print("[TARGET DETECTOR] Starting...")
print("[TARGET DETECTOR] Change the targeting mode of ANY unit NOW")
print("==========================================")

-- ===== PARTE 1: HOOKEAR TODOS LOS REMOTEEVENTS =====
local hookCount = 0

local function scanRemoteEvents(parent, path)
    for _, obj in pairs(parent:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            local fullPath = path .. "." .. obj.Name
            
            -- Hookear el FireServer de este RemoteEvent
            local success = pcall(function()
                local oldFireServer = obj.FireServer
                obj.FireServer = function(self, ...)
                    local args = {...}
                    
                    -- Filtrar por nombre sospechoso
                    local nameLower = obj.Name:lower()
                    if nameLower:find("target") or nameLower:find("mode") or 
                       nameLower:find("entity") or nameLower:find("unit") or
                       nameLower:find("change") or nameLower:find("aim") then
                        
                        print("\n🎯 [SUSPICIOUS REMOTE FIRED]")
                        print("   Path: " .. fullPath)
                        print("   Args count: " .. #args)
                        for i, arg in ipairs(args) do
                            print("   Arg[" .. i .. "] = " .. tostring(arg) .. " (type: " .. type(arg) .. ")")
                        end
                        print("")
                    end
                    
                    return oldFireServer(self, ...)
                end
            end)
            
            if success then
                hookCount = hookCount + 1
            end
        end
    end
end

-- Escanear ReplicatedStorage
scanRemoteEvents(game:GetService("ReplicatedStorage"), "ReplicatedStorage")

print("[TARGET DETECTOR] Hooked " .. hookCount .. " RemoteEvents")
print("[TARGET DETECTOR] Now change a unit's targeting mode manually...")
print("==========================================")

-- ===== PARTE 2: LISTENER GENERAL CON firehook (si el executor lo soporta) =====
-- Este método captura CUALQUIER FireServer, sin importar el remote

task.spawn(function()
    task.wait(0.5)
    
    -- Intentar con hookfunction (Synapse X / KRNL)
    local hookSuccess = pcall(function()
        local mt = getrawmetatable(game)
        local oldIndex = mt.__index
        local oldNamecall = mt.__namecall
        
        setreadonly(mt, false)
        
        mt.__namecall = function(self, ...)
            local method = getnamecallmethod()
            
            if method == "FireServer" and self:IsA("RemoteEvent") then
                local args = {...}
                local nameLower = self.Name:lower()
                
                -- Mostrar TODOS los FireServer durante detección
                print("\n📡 [REMOTE FIRED] " .. self.Name)
                print("   Full path: " .. self:GetFullName())
                for i, arg in ipairs(args) do
                    print("   Arg[" .. i .. "] = " .. tostring(arg) .. " (type: " .. type(arg) .. ")")
                    
                    -- Si el arg es un número, mostrar en hex también
                    if type(arg) == "number" then
                        print("   Arg[" .. i .. "] hex = 0x" .. string.format("%X", arg))
                    end
                end
            end
            
            return oldNamecall(self, ...)
        end
        
        setreadonly(mt, true)
        print("[TARGET DETECTOR] ✅ Global hook active (Synapse/KRNL method)")
    end)
    
    if not hookSuccess then
        print("[TARGET DETECTOR] ⚠️ Global hook failed - using scan method only")
        print("[TARGET DETECTOR] Make sure to change target AFTER running this script")
    end
end)

-- ===== PARTE 3: MOSTRAR TODOS LOS REMOTEEVENTS DISPONIBLES (para referencia) =====
task.spawn(function()
    task.wait(1)
    
    print("\n==========================================")
    print("[TARGET DETECTOR] All RemoteEvents found:")
    
    local function listRemotes(parent, path, depth)
        depth = depth or 0
        if depth > 5 then return end
        
        for _, obj in pairs(parent:GetChildren()) do
            local currentPath = path .. "." .. obj.Name
            
            if obj:IsA("RemoteEvent") then
                print("  📡 " .. currentPath)
            end
            
            -- Recurse into folders/models
            if obj:IsA("Folder") or obj:IsA("Model") or obj:GetChildren then
                listRemotes(obj, currentPath, depth + 1)
            end
        end
    end
    
    listRemotes(game:GetService("ReplicatedStorage"), "ReplicatedStorage")
    
    print("==========================================")
    print("[TARGET DETECTOR] Ready! Change a unit's target mode now.")
    print("==========================================\n")
end)
