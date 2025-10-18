--// Garden Tower Defense - Auto Skip Test
-- This only tests the SkipWave RemoteFunction

local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")

task.wait(2)

pcall(function()
    remotes.SkipWave:InvokeServer("y")
    warn("[✅ TEST] Auto Skip triggered successfully via SkipWave remote")
end)