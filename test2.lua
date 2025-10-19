--== WHITELIST ==
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local whitelist = {["PurpPum"]= true, ["kierbot2"]= true, ["67cheesy"] = true}
if not whitelist[plr.Name] then plr:Kick("You are not whitelisted.") return end

--== KEY GUI ==
local ScreenGui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0,300,0,200); Frame.Position = UDim2.new(0.5,-150,0.5,-100)
Frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1,0,0,40); Title.BackgroundTransparency=1
Title.Text="Enter Key"; Title.TextColor3=Color3.fromRGB(255,255,255)
Title.Font=Enum.Font.GothamBold; Title.TextSize=20

local TextBox = Instance.new("TextBox", Frame)
TextBox.Size=UDim2.new(1,-20,0,40); TextBox.Position=UDim2.new(0,10,0,50)
TextBox.PlaceholderText="Enter Key Here"; TextBox.Text=""; TextBox.Font=Enum.Font.Gotham
TextBox.TextSize=16; TextBox.TextColor3=Color3.fromRGB(0,0,0); TextBox.BackgroundColor3=Color3.fromRGB(200,200,200)

local CheckBtn = Instance.new("TextButton", Frame)
CheckBtn.Size=UDim2.new(1,-20,0,40); CheckBtn.Position=UDim2.new(0,10,0,100)
CheckBtn.Text="Check Key"; CheckBtn.Font=Enum.Font.GothamBold; CheckBtn.TextSize=18
CheckBtn.BackgroundColor3=Color3.fromRGB(100,200,100)

local Label = Instance.new("TextLabel", Frame)
Label.Size=UDim2.new(1,-20,0,40); Label.Position=UDim2.new(0,10,0,150)
Label.BackgroundTransparency=1; Label.Text=""; Label.Font=Enum.Font.GothamBold
Label.TextSize=16; Label.TextColor3=Color3.fromRGB(255,255,255)

local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")

--== AUTO SKIP MONITOR ==
local function startAutoSkipMonitor()
    local gui = plr.PlayerGui:WaitForChild("GameGuiNoInset")
    local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")

    task.delay(6,function() -- activa 6s después
        pcall(function()
            local connections = getconnections(autoSkipButton.MouseButton1Click)
            if connections and #connections>0 then connections[1]:Fire() end
        end)
    end)

    task.spawn(function() -- seguro que mantiene en ON
        while true do
            task.wait(0.5)
            pcall(function()
                local c = autoSkipButton.ImageColor3
                -- OFF = naranja (aprox R=1,G=0.667,B=0), ON = verde (aprox R=0.451,G=0.902,B=0)
                if math.abs(c.R-1)<0.05 and math.abs(c.G-0.667)<0.05 and math.abs(c.B-0)<0.05 then
                    local connections = getconnections(autoSkipButton.MouseButton1Click)
                    if connections and #connections>0 then
                        connections[1]:Fire()
                        print("[AutoSkip Monitor] Reactivated ON")
                    end
                end
            end)
        end
    end)
end

--== GAME SCRIPT ==
local function loadGame(speed)
    remotes.ChangeTickSpeed:InvokeServer(speed)
    local difficulty="dif_impossible"

    -- Tabla de unidades según velocidad
    local placements2x = {
        {time=29, unit="unit_lawnmower", slot="1", data={Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803,-123.052032),DistanceAlongPath=248.0065,CF=CFrame.new(-843.87384,62.1803,-123.052032),Rotation=180}},
        {time=47, unit="unit_rafflesia", slot="2", data={Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803,-162.012131),DistanceAlongPath=180.53,CF=CFrame.new(-842.381287,62.1803,-162.012131),Rotation=180}},
        {time=85, unit="unit_rafflesia", slot="2", data={Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803,-164.507538),DistanceAlongPath=178.04,CF=CFrame.new(-842.381287,62.1803,-164.507538),Rotation=180}},
        {time=110, unit="unit_rafflesia", slot="2", data={Valid=true,PathIndex=2,Position=Vector3.new(-864.724426,62.1803,-199.052032),DistanceAlongPath=100.65,CF=CFrame.new(-864.724426,62.1803,-199.052032),Rotation=180}}
    }

    local placements3x = {
        {time=23, unit="unit_lawnmower", slot="1", data={Valid=true,PathIndex=3,Position=Vector3.new(-843.87384,62.1803,-123.052032),DistanceAlongPath=248.0065,CF=CFrame.new(-843.87384,62.1803,-123.052032),Rotation=180}},
        {time=32, unit="unit_rafflesia", slot="2", data={Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803,-162.012131),DistanceAlongPath=180.53,CF=CFrame.new(-842.381287,62.1803,-162.012131),Rotation=180}},
        {time=57, unit="unit_rafflesia", slot="2", data={Valid=true,PathIndex=3,Position=Vector3.new(-842.381287,62.1803,-164.507538),DistanceAlongPath=178.04,CF=CFrame.new(-842.381287,62.1803,-164.507538),Rotation=180}},
        {time=77, unit="unit_rafflesia", slot="2", data={Valid=true,PathIndex=2,Position=Vector3.new(-864.724426,62.1803,-199.052032),DistanceAlongPath=100.65,CF=CFrame.new(-864.724426,62.1803,-199.052032),Rotation=180}}
    }

    local placements = speed==2 and placements2x or placements3x

    local function placeUnit(unit)
        remotes.PlaceUnit:InvokeServer(unit.unit,unit.data)
        warn("[Placing] "..unit.unit.." at "..os.clock())
    end

    local function startGame()
        remotes.PlaceDifficultyVote:InvokeServer(difficulty)
        startAutoSkipMonitor()
        for _,p in ipairs(placements) do
            task.delay(p.time,function() placeUnit(p) end)
        end
    end

    while true do
        startGame()
        task.wait(speed==2 and 174.5 or 128)
        remotes.RestartGame:InvokeServer()
    end
end

--== SPEED MENU ==
local function showSpeedMenu()
    Title.Text="Select Speed"; TextBox.Visible=false; CheckBtn.Visible=false
    local btn2x = Instance.new("TextButton",Frame)
    btn2x.Size=UDim2.new(0.45,0,0,50); btn2x.Position=UDim2.new(0.05,0,0.5,-25)
    btn2x.Text="2x Speed"; btn2x.BackgroundColor3=Color3.fromRGB(80,160,250)
    local btn3x = Instance.new("TextButton",Frame)
    btn3x.Size=UDim2.new(0.45,0,0,50); btn3x.Position=UDim2.new(0.5,0,0.5,-25)
    btn3x.Text="3x Speed"; btn3x.BackgroundColor3=Color3.fromRGB(250,120,120)

    btn2x.MouseButton1Click:Connect(function() ScreenGui:Destroy(); loadGame(2) end)
    btn3x.MouseButton1Click:Connect(function() ScreenGui:Destroy(); loadGame(3) end)
end

--== KEY CHECK ==
CheckBtn.MouseButton1Click:Connect(function()
    if TextBox.Text=="test" then
        Label.Text="Key Accepted!"; Label.TextColor3=Color3.fromRGB(0,255,0)
        task.delay(1, showSpeedMenu)
    else
        TextBox.Text=""; Label.Text="Invalid Key!"; Label.TextColor3=Color3.fromRGB(255,0,0)
    end
end)