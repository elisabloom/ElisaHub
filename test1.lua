-- ==================== SERVER HOP STANDALONE - TEST VERSION ====================
print("[SERVER HOP TEST] Starting standalone test...")

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function serverHop()
    local success, result = pcall(function()
        print("[SERVER HOP] ========================================")
        print("[SERVER HOP] Starting server hop process...")
        print("[SERVER HOP] ========================================")
        
        local placeId = game.PlaceId
        local currentJobId = game.JobId
        
        print("[SERVER HOP] Current Place ID: " .. placeId)
        print("[SERVER HOP] Current Job ID: " .. currentJobId)
        
        -- ✅ Obtener lista de servidores
        local serversUrl = string.format(
            "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100",
            placeId
        )
        
        print("[SERVER HOP] Fetching server list from Roblox API...")
        local serversResponse = game:HttpGet(serversUrl)
        local serversData = HttpService:JSONDecode(serversResponse)
        
        if not serversData or not serversData.data then
            error("❌ Failed to fetch server list")
        end
        
        print("[SERVER HOP] ✓ Server list fetched successfully")
        print("[SERVER HOP] Total servers found: " .. #serversData.data)
        
        -- ✅ Filtrar servidores válidos (que no sean el actual)
        local validServers = {}
        for _, server in pairs(serversData.data) do
            if server.id ~= currentJobId and server.playing < server.maxPlayers then
                table.insert(validServers, server)
            end
        end
        
        print("[SERVER HOP] Valid servers (not current, not full): " .. #validServers)
        
        if #validServers == 0 then
            error("❌ No available servers found")
        end
        
        -- ✅ Ordenar por cantidad de jugadores (buscar servidores menos llenos)
        table.sort(validServers, function(a, b)
            return a.playing < b.playing
        end)
        
        print("[SERVER HOP] Servers sorted by player count (ascending)")
        
        -- ✅ Mostrar los primeros 5 servidores candidatos
        print("[SERVER HOP] ========================================")
        print("[SERVER HOP] TOP 5 CANDIDATE SERVERS:")
        for i = 1, math.min(5, #validServers) do
            local server = validServers[i]
            print(string.format(
                "  %d. Players: %d/%d | Job ID: %s",
                i,
                server.playing,
                server.maxPlayers,
                server.id:sub(1, 8) .. "..."
            ))
        end
        print("[SERVER HOP] ========================================")
        
        -- ✅ Seleccionar servidor aleatorio de los 10 menos llenos
        local targetServer = validServers[math.random(1, math.min(10, #validServers))]
        
        print("[SERVER HOP] ========================================")
        print("[SERVER HOP] SELECTED TARGET SERVER:")
        print("  - Job ID: " .. targetServer.id)
        print("  - Players: " .. targetServer.playing .. "/" .. targetServer.maxPlayers)
        print("  - Ping: " .. (targetServer.ping or "N/A") .. "ms")
        print("[SERVER HOP] ========================================")
        
        -- ✅ Notificar al jugador
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🔄 SERVER HOP",
            Text = "Teleporting to new server...\n" .. targetServer.playing .. "/" .. targetServer.maxPlayers .. " players",
            Duration = 3
        })
        
        print("[SERVER HOP] Waiting 2 seconds before teleport...")
        task.wait(2)
        
        print("[SERVER HOP] 🚀 INITIATING TELEPORT...")
        
        -- ✅ Teleportar al nuevo servidor
        TeleportService:TeleportToPlaceInstance(
            placeId,
            targetServer.id,
            LocalPlayer
        )
        
        print("[SERVER HOP] Teleport command sent successfully")
    end)
    
    if not success then
        warn("[SERVER HOP] ❌ ERROR OCCURRED:")
        warn(tostring(result))
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "❌ SERVER HOP FAILED",
            Text = "Could not find another server.\nError: " .. tostring(result),
            Duration = 5
        })
    end
end

-- ==================== EJECUTAR SERVER HOP INMEDIATAMENTE ====================
print("[SERVER HOP TEST] Executing server hop in 3 seconds...")

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🧪 SERVER HOP TEST",
    Text = "Starting in 3 seconds...",
    Duration = 3
})

task.wait(3)

serverHop()

print("[SERVER HOP TEST] Script execution complete")
