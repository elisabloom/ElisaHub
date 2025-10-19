local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local btn = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

local conns = {}
local ok, tmp = pcall(function() return getconnections(btn.MouseButton1Click) end)
if not ok or not tmp then
    print("No se pudieron obtener conexiones o no existen.")
    return
end

print("Connections found:", #tmp)
for i, c in ipairs(tmp) do
    print(("---- conn %d ----"):format(i))
    pcall(function()
        print("  Connected:", tostring(c.Connected))
    end)
    pcall(function()
        print("  Function tostring:", tostring(c.Function))
    end)
    pcall(function()
        -- some environments allow printing closure env/source
        if c.Function then
            print("  Function source dump:", debug and debug.getinfo and debug.getinfo(c.Function) or "no debug.getinfo")
        end
    end)
end
_G._AutoSkipConnections = tmp