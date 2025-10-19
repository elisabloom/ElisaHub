local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local btn = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

local ok, vim = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok or not vim then
    print("VirtualInputManager no disponible en este entorno.")
    return
end

local ok2, pos, size = pcall(function() return btn.AbsolutePosition, btn.AbsoluteSize end)
if not ok2 or not pos or not size then
    -- try waiting a bit then re-read
    task.wait(0.2)
    pos = btn.AbsolutePosition
    size = btn.AbsoluteSize
end

local cx = pos.X + size.X/2
local cy = pos.Y + size.Y/2
print("Simulating mouse click at", cx, cy)
pcall(function()
    vim:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
    task.wait(0.05)
    vim:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
end)
print("Done simulated click")