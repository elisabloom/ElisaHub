local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

print("=== DUMP DEL AUTO SKIP ===")
print("Text:", autoSkipButton.Text)
print("BackgroundColor3:", autoSkipButton.BackgroundColor3)
print("ImageColor3:", autoSkipButton.ImageColor3)
print("TextScaled:", autoSkipButton.TextScaled)
print("TextSize:", autoSkipButton.TextSize)
print("Font:", autoSkipButton.Font)
print("ClassName:", autoSkipButton.ClassName)

-- Opcional: Observador para cambios en tiempo real
autoSkipButton:GetPropertyChangedSignal("Text"):Connect(function()
    print("[Change Detected] Text:", autoSkipButton.Text)
end)
autoSkipButton:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
    print("[Change Detected] BackgroundColor3:", autoSkipButton.BackgroundColor3)
end)
autoSkipButton:GetPropertyChangedSignal("ImageColor3"):Connect(function()
    print("[Change Detected] ImageColor3:", autoSkipButton.ImageColor3)
end)