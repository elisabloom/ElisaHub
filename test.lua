local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls.AutoSkip

local connections = getconnections(autoSkipButton.MouseButton1Click)
if connections and #connections > 0 then
    connections[1]:Fire()
end