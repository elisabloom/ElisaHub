-- Hook para detectar qué RemoteFunction/RemoteEvent se invoca al presionar Auto Skip
-- Ejecuta esto en Delta ANTES de pulsar el botón Auto Skip en el juego.

local rs = game:GetService("ReplicatedStorage")
local printed = {}

local function safePrint(...)
    local t = {}
    for i=1, select("#", ...) do
        local v = select(i, ...)
        table.insert(t, tostring(v))
    end
    print("[REMOTE-SPY]", table.concat(t, "\t"))
end

-- Intenta usar hookfunction (la mayoría de executors lo tienen)
local canHook = (type(hookfunction) == "function")

if canHook then
    safePrint("hookfunction disponible -> usando wrapper para InvokeServer/FireServer")
else
    safePrint("hookfunction NO disponible -> intentaré imprimir nombres de remotes por GetDescendants()")
end

-- Wrapper para RemoteFunction: hookea InvokeServer
for _, v in ipairs(rs:GetDescendants()) do
    if v:IsA("RemoteFunction") then
        local ok, info = pcall(function()
            if canHook and v.InvokeServer then
                local orig = v.InvokeServer
                -- no repetir hooks
                if not printed[v] then
                    printed[v] = true
                    hookfunction(orig, function(self, ...)
                        safePrint("RemoteFunction.InvokeServer ->", self:GetFullName() or self.Name, "args:", ...)
                        return orig(self, ...)
                    end)
                end
            end
        end)
        if not ok then
            -- ignore
        end
    elseif v:IsA("RemoteEvent") then
        local ok2, info2 = pcall(function()
            if canHook and v.FireServer then
                local origE = v.FireServer
                if not printed[v] then
                    printed[v] = true
                    hookfunction(origE, function(self, ...)
                        safePrint("RemoteEvent.FireServer ->", self:GetFullName() or self.Name, "args:", ...)
                        return origE(self, ...)
                    end)
                end
            end
        end)
    end
end

-- Si hookfunction no está disponible: imprime lista y pide que copies la consola
if not canHook then
    safePrint("Listado de remotes en ReplicatedStorage (busca nombres con 'skip' o similares):")
    for _, v in ipairs(rs:GetDescendants()) do
        if v:IsA("RemoteFunction") or v:IsA("RemoteEvent") then
            safePrint(v.ClassName .. " : " .. v:GetFullName())
        end
    end
    safePrint("Luego, pulsa Auto Skip manualmente y mira la consola para ver si algo aparece.")
else
    safePrint("Hooking completado. Ahora pulsa el botón Auto Skip en el juego. Observa la consola para ver qué remote fue llamado.")
end

-- Nota: algunos remotes sólo aceptan llamadas desde scripts "de confianza" (p. ej. ClientLoader).
-- Si al presionar ves en consola el nombre del remote -> úsalo en tu script.
-- Si no aparece nada, copia la salida de la consola aquí y la reviso.