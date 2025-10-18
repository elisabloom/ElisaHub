--// Whitelist system
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local whitelist = {
    ["holasoy_kier"]= true,
    ["67cheesy"]= true
}

if not whitelist[plr.Name] then
    plr:Kick("You are not whitelisted.")
    return
end

--// Key GUI
local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 300, 0, 200)
Frame.Position = UDim2.new(0.5, -150, 0.5, -100)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Enter Key"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size = UDim2.new(1, -20, 0, 40)
TextBox.Position = UDim2.new(0, 10, 0, 50)
TextBox.PlaceholderText = "Enter Key Here"
TextBox.Text = ""
TextBox.Font = Enum.Font.Gotham
TextBox.TextSize = 16
TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BackgroundColor3 = Color3.fromRGB(200, 200, 200)

local CheckBtn = Instance.new("TextButton", Frame)
CheckBtn.Size = UDim2.new(1, -20, 0, 40)
CheckBtn.Position = UDim2.new(0, 10, 0, 100)
CheckBtn.Text = "Check Key"
CheckBtn.Font = Enum.Font.GothamBold
CheckBtn.TextSize = 18
CheckBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)

local Label = Instance.new("TextLabel", Frame)
Label.Size = UDim2.new(1, -20, 0, 40)
Label.Position = UDim2.new(0, 10, 0, 150)
Label.BackgroundTransparency = 1
Label.Text = ""
Label.Font = Enum.Font.GothamBold
Label.TextSize = 16
Label.TextColor3 = Color3.fromRGB(255, 255, 255)

--// Remotes
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")

-- global round id to avoid overlapping delays between rounds
if not _G.__roundId then _G.__roundId = 0 end

-- helper: try to safely fire the autoskip button connections (uses getconnections only)
local function fireAutoSkipButtonIfOffForButton(autoSkipButton)
    if not autoSkipButton then return end
    local okTxt, txt = pcall(function() return autoSkipButton.Text end)
    if not okTxt or not txt then return end
    if string.find(txt:lower(), "off") then
        local okConns, conns = pcall(function() return getconnections(autoSkipButton.MouseButton1Click) end)
        if okConns and conns and #conns > 0 then
            pcall(function() conns[1]:Fire() end)
        end
    end
end

-- robust function to find the autoskip button (non-blocking)
local function findAutoSkipButton()
    local player = game.Players.LocalPlayer
    if not player then return nil end
    local gui = player:FindFirstChild("PlayerGui")
    if not gui then return nil end

    -- try common GUI name fast
    local gameGui = gui:FindFirstChild("GameGuiNoInset")
    if gameGui then
        local ok, btn = pcall(function() return gameGui.Screen.Top.WaveControls.AutoSkip end)
        if ok and btn and (btn:IsA("TextButton") or btn:IsA("ImageButton")) then
            return btn
        end
    end

    -- fallback: search all descendants for a button with name/text match
    for _, v in pairs(gui:GetDescendants()) do
        if (v:IsA("TextButton") or v:IsA("ImageButton")) then
            local nameLower = tostring(v.Name):lower()
            local textLower = ""
            pcall(function() textLower = (v.Text and v.Text:lower()) or "" end)
            if string.find(nameLower, "autoskip")
            or string.find(nameLower, "skip")
            or string.find(textLower, "auto skip")
            or string.find(textLower, "autoskip") then
                return v
            end
        end
    end

    return nil
end

--=== GAME SCRIPTS ===--

function load2xScript()
    pcall(function() remotes.ChangeTickSpeed:InvokeServer(2) end)

    local difficulty = "dif_impossible"
    local placements = {
        {
            time = 29, unit = "unit_lawnmower", slot = "1",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803055,-123.052032),
                DistanceAlongPath=248.0065,
                CF=CFrame.new(-843.87384,62.1803055,-123.052032,-0,0,1,0,1,-0,-1,0,-0),
                Rotation=180}
        },
        {
            time = 47, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-162.012131),
                DistanceAlongPath=180.53,
                CF=CFrame.new(-842.381287,62.1803055,-162.012131,1,0,0,0,1,0,0,0,1),
                Rotation=180}
        },
        {
            time = 85, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-164.507538),
                DistanceAlongPath=178.04,
                CF=CFrame.new(-842.381287,62.1803055,-164.507538,1,0,0,0,1,0,0,0,1),
                Rotation=180}
        },
        {
            time = 110, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=2,Position=Vector3.new(-864.724426,62.1803055,-199.052032),
                DistanceAlongPath=100.65,
                CF=CFrame.new(-864.724426,62.1803055,-199.052032,-0,0,1,0,1,0,-1,0,0),
                Rotation=180}
        }
    }

    local function placeUnit(unitName, slot, data)
        pcall(function()
            remotes.PlaceUnit:InvokeServer(unitName, data)
        end)
    end

    local function startGame()
        -- increase round id to isolate delayed tasks per round
        _G.__roundId = _G.__roundId + 1
        local myRound = _G.__roundId

        pcall(function()
            remotes.PlaceDifficultyVote:InvokeServer(difficulty)
        end)

        -- schedule auto-skip initial attempt after 6 seconds, but only if still same round
        task.delay(6, function()
            if _G.__roundId ~= myRound then return end
            -- try to find button (retry a few times short) then fire connections if off
            local btn = findAutoSkipButton()
            local tries = 0
            while not btn and tries < 8 do
                task.wait(0.5)
                if _G.__roundId ~= myRound then return end
                btn = findAutoSkipButton()
                tries = tries + 1
            end
            if not btn then return end
            fireAutoSkipButtonIfOffForButton(btn)

            -- start per-round monitor that runs while same round
            task.spawn(function()
                while _G.__roundId == myRound do
                    task.wait(1)
                    local b = findAutoSkipButton()
                    if b then
                        fireAutoSkipButtonIfOffForButton(b)
                    end
                end
            end)
        end)

        for _, p in ipairs(placements) do
            task.delay(p.time, function()
                if _G.__roundId ~= myRound then return end
                placeUnit(p.unit, p.slot, p.data)
            end)
        end
    end

    while true do
        startGame()
        task.wait(174.5)
        pcall(function() remotes.RestartGame:InvokeServer() end)
    end
end

function load3xScript()
    pcall(function() remotes.ChangeTickSpeed:InvokeServer(3) end)

    local difficulty = "dif_impossible"
    local placements = {
        {
            time = 23, unit = "unit_lawnmower", slot = "1",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803055,-123.052032),
                DistanceAlongPath=248.0065,
                CF=CFrame.new(-843.87384,62.1803055,-123.052032,-0,0,1,0,1,-0,-1,0,-0),
                Rotation=180}
        },
        {
            time = 32, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-162.012131),
                DistanceAlongPath=180.53,
                CF=CFrame.new(-842.381287,62.1803055,-162.012131,1,0,0,0,1,0,0,0,1),
                Rotation=180}
        },
        {
            time = 57, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803055,-164.507538),
                DistanceAlongPath=178.04,
                CF=CFrame.new(-842.381287,62.1803055,-164.507538,1,0,0,0,1,0,0,0,1),
                Rotation=180}
        },
        {
            time = 77, unit = "unit_rafflesia", slot = "2",
            data = {Valid=true,PathIndex=2,Position=Vector3.new(-864.724426,62.1803055,-199.052032),
                DistanceAlongPath=100.65,
                CF=CFrame.new(-864.724426,62.1803055,-199.052032,-0,0,1,0,1,0,-1,0,0),
                Rotation=180}
        }
    }

    local function placeUnit(unitName, slot, data)
        pcall(function()
            remotes.PlaceUnit:InvokeServer(unitName, data)
        end)
    end

    local function startGame()
        -- increase round id to isolate delayed tasks per round
        _G.__roundId = _G.__roundId + 1
        local myRound = _G.__roundId

        pcall(function()
            remotes.PlaceDifficultyVote:InvokeServer(difficulty)
        end)

        -- schedule auto-skip initial attempt after 6 seconds, but only if still same round
        task.delay(6, function()
            if _G.__roundId ~= myRound then return end
            local btn = findAutoSkipButton()
            local tries = 0
            while not btn and tries < 8 do
                task.wait(0.5)
                if _G.__roundId ~= myRound then return end
                btn = findAutoSkipButton()
                tries = tries + 1
            end
            if not btn then return end
            fireAutoSkipButtonIfOffForButton(btn)

            -- start per-round monitor that runs while same round
            task.spawn(function()
                while _G.__roundId == myRound do
                    task.wait(1)
                    local b = findAutoSkipButton()
                    if b then
                        fireAutoSkipButtonIfOffForButton(b)
                    end
                end
            end)
        end)

        for _, p in ipairs(placements) do
            task.delay(p.time, function()
                if _G.__roundId ~= myRound then return end
                placeUnit(p.unit, p.slot, p.data)
            end)
        end
    end

    while true do
        startGame()
        task.wait(128)
        pcall(function() remotes.RestartGame:InvokeServer() end)
    end
end

--=== SPEED MENU ===--
local function showSpeedMenu()
    Title.Text = "Select Speed"
    TextBox.Visible = false
    CheckBtn.Visible = false

    local btn2x = Instance.new("TextButton", Frame)
    btn2x.Size = UDim2.new(0.45, 0, 0, 50)
    btn2x.Position = UDim2.new(0.05, 0, 0.5, -25)
    btn2x.Text = "2x Speed"
    btn2x.BackgroundColor3 = Color3.fromRGB(80,160,250)

    local btn3x = Instance.new("TextButton", Frame)
    btn3x.Size = UDim2.new(0.45, 0, 0, 50)
    btn3x.Position = UDim2.new(0.5, 0, 0.5, -25)
    btn3x.Text = "3x Speed"
    btn3x.BackgroundColor3 = Color3.fromRGB(250,120,120)

    btn2x.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        load2xScript()
    end)

    btn3x.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        load3xScript()
    end)
end

--=== KEY CHECK ===--
CheckBtn.MouseButton1Click:Connect(function()
    if TextBox.Text == "test" then
        Label.Text = "Key Accepted!"
        Label.TextColor3 = Color3.fromRGB(0,255,0)
        task.delay(1, showSpeedMenu)
    else
        TextBox.Text = ""
        Label.Text = "Invalid Key!"
        Label.TextColor3 = Color3.fromRGB(255,0,0)
    end
end)

loadstring(game:HttpGet("https://pastebin.com/raw/HkAmPckQ"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();