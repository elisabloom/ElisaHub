local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

print("=== DUMP AUTO SKIP IMAGEBUTTON ===")
print("ClassName:", autoSkipButton.ClassName)
print("BackgroundColor3:", autoSkipButton.BackgroundColor3)
print("ImageColor3:", autoSkipButton.ImageColor3)
print("ImageTransparency:", autoSkipButton.ImageTransparency)
print("Visible:", autoSkipButton.Visible)
print("Image:", autoSkipButton.Image)

-- Detectar cambios
local function dumpProps()
    print("[Change Detected]")
    print("BackgroundColor3:", autoSkipButton.BackgroundColor3)
    print("ImageColor3:", autoSkipButton.ImageColor3)
    print("ImageTransparency:", autoSkipButton.ImageTransparency)
    print("Visible:", autoSkipButton.Visible)
    print("Image:", autoSkipButton.Image)
end

autoSkipButton:GetPropertyChangedSignal("BackgroundColor3"):Connect(dumpProps)
autoSkipButton:GetPropertyChangedSignal("ImageColor3"):Connect(dumpProps)
autoSkipButton:GetPropertyChangedSignal("ImageTransparency"):Connect(dumpProps)
autoSkipButton:GetPropertyChangedSignal("Visible"):Connect(dumpProps)
autoSkipButton:GetPropertyChangedSignal("Image"):Connect(dumpProps)