-- Ver todos los textos que detecta
local function showAllWaveTexts()
    for _, gui in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, obj in pairs(gui:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Visible then
                    local text = obj.Text
                    if string.find(string.lower(text), "wave") or string.find(text, "%d+%s*/%s*%d+") then
                        print("GUI:", gui.Name, "| Text:", text)
                    end
                end
            end
        end
    end
end
showAllWaveTexts()