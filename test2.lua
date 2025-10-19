local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

local ON_IMAGE = "rbxassetid://91983021855852"
local OFF_IMAGE = "rbxassetid://591983921855852"

print("GUI loaded")
print("AutoSkip button found")
print("Monitoring AutoSkip every 1s…")

local function simulateClick(button)
    -- Simular InputBegan + InputEnded
    local pos = button.AbsolutePosition + button.AbsoluteSize / 2
    local input = Instance.new("InputObject")
    input.Position = pos
    pcall(function()
        firetouchinterest(button, input, 0)
        firetouchinterest(button, input, 1)
    end)
end

RunService.Heartbeat:Connect(function()
    pcall(function()
        if autoSkipButton.Image == OFF_IMAGE then
            simulateClick(autoSkipButton)
            print("[AutoSkip Monitor] Simulated click to reactivate Auto Skip")
        end
    end)
end)