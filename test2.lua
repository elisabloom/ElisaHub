local player = game.Players.LocalPlayer
local gui = player.PlayerGui:WaitForChild("GameGuiNoInset")
local btn = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

-- función que decide si color es naranja (OFF)
local function looksLikeOff(c)
    return c.R > 0.40 and c.R < 0.50 and c.G > 0.85 and c.G < 0.93 and c.B < 0.05
end

local lastAttempt = 0
local cooldown = 6 -- segundos entre intentos del script para evitar loops

-- property change listener: actúa sólo cuando detecta transición
local lastColor = btn.ImageColor3
btn:GetPropertyChangedSignal("ImageColor3"):Connect(function()
    local now = tick()
    local newColor = btn.ImageColor3
    -- detect ON -> OFF transition (we heuristically say last wasn't orange and new is orange)
    if not looksLikeOff(lastColor) and looksLikeOff(newColor) then
        if now - lastAttempt >= cooldown then
            task.delay(0.12, function() -- small delay to let animations settle
                if looksLikeOff(btn.ImageColor3) then
                    -- attempt activation via getconnections.Function() first
                    local ok, conns = pcall(function() return getconnections(btn.MouseButton1Click) end)
                    local activated = false
                    if ok and conns and #conns>0 then
                        -- try calling function directly if available
                        if conns[1].Function then
                            local s, e = pcall(function() conns[1].Function() end)
                            activated = s
                        end
                        if not activated then
                            local s2, e2 = pcall(function() conns[1]:Fire() end)
                            activated = s2
                        end
                    end
                    lastAttempt = tick()
                    print("AutoSkip monitor: attempted reactivation, success?", activated)
                end
            end)
        else
            print("AutoSkip monitor: skipping reactivation due cooldown")
        end
    end
    lastColor = newColor
end)