--// Garden Tower Defense - HUMANIZED AUTO FARM WITH AUTO UPGRADE + ANTI-AFK MOVEMENT
local Players = game:GetService("Players")
local plr = Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")
local Workspace = game:GetService("Workspace")
local entities = Workspace:WaitForChild("Map"):WaitForChild("Entities")

-- Track our placed units
_G.myUnitIDs = _G.myUnitIDs or {}
_G.trackingEnabled = false
_G.upgradeLoopRunning = false

-- HUMANIZATION: Random offset generator
local function getRandomOffset()
    return Vector3.new(
        math.random(-25, 25) / 10,
        0,
        math.random(-25, 25) / 10
    )
end

-- Get current money
local function getMoney()
    return plr:GetAttribute("Cash") or 0
end

-- Get unit ID from the entity (with retry)
local function getUnitID(unit)
    for attempt = 1, 10 do
        for _, v in ipairs(unit:GetDescendants()) do
            if (v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue")) and string.find(string.lower(v.Name), "id") then
                return v.Value
            end
        end
        for attrName, attrValue in pairs(unit:GetAttributes()) do
            if string.find(string.lower(attrName), "id") then
                return attrValue
            end
        end
        task.wait(0.2)
    end
    return nil
end

-- Monitor for new units and track their IDs
entities.ChildAdded:Connect(function(child)
    if _G.trackingEnabled then
        task.spawn(function()
            task.wait(1)
            if child and child.Parent and string.find(child.Name, "unit_") then
                warn("[DETECTING] Checking unit: " .. child.Name)
                local unitID = getUnitID(child)
                if unitID then
                    table.insert(_G.myUnitIDs, unitID)
                    warn("[✓ TRACKED] Unit ID: " .. unitID .. " | Total: " .. #_G.myUnitIDs)
                else
                    warn("[✗ FAILED] Could not find ID for: " .. child.Name)
                end
            end
        end)
    end
end)

-- AUTO SKIP with continuous monitoring
local function setupAutoSkip()
    task.spawn(function()
        task.wait(6)
        pcall(function()
            local gui = plr.PlayerGui:WaitForChild("GameGuiNoInset")
            local autoSkipButton = gui.Screen.Top.WaveControls:WaitForChild("AutoSkip")
            pcall(function()
                remotes.ToggleAutoSkip:InvokeServer(true)
            end)
            warn("[AUTO SKIP] Initial activation")

            while _G.trackingEnabled do
                task.wait(0.8)
                pcall(function()
                    local c = autoSkipButton.ImageColor3
                    if c.R > 0.8 and c.G > 0.5 then
                        local conns = getconnections(autoSkipButton.MouseButton1Click)
                        if conns and #conns > 0 then
                            conns[1]:Fire()
                            warn("[AUTO SKIP] Reactivated (was OFF)")
                        end
                    end
                end)
            end
        end)
    end)
end

local function setupGame()
    warn("[SETUP] Selecting difficulty...")
    local success1 = pcall(function()
        remotes.PlaceDifficultyVote:InvokeServer("dif_normal")
    end)
    warn("[SETUP] Difficulty result: " .. tostring(success1))
    task.wait(0.5)
    warn("[SETUP] Setting speed...")
    local success2 = pcall(function()
        remotes.ChangeTickSpeed:InvokeServer(3)
    end)
    warn("[SETUP] Speed result: " .. tostring(success2))
    setupAutoSkip()
    warn("[GAME SETUP] Complete")
end

-- BASE placements
local basePlacements = {
    {
        time = 5,
        unit = "unit_tomato_rainbow",
        cost = 100,
        position = Vector3.new(-850.7767333984375, 61.93030548095703, -155.0453338623047),
        rotation = 180
    },
    {
        time = 53,
        unit = "unit_tomato_rainbow",
        cost = 100,
        position = Vector3.new(-852.2405395507812, 61.93030548095703, -150.1680450439453),
        rotation = 180
    },
    {
        time = 100,
        unit = "unit_metal_flower",
        cost = 2250,
        position = Vector3.new(-850.2332153320312, 61.93030548095703, -151.0040740966797),
        rotation = 180
    },
    {
        time = 130,
        unit = "unit_metal_flower",
        cost = 2250,
        position = Vector3.new(-853.2742919921875, 61.93030548095703, -146.7690887451172),
        rotation = 180
    }
}

-- HUMANIZATION: Randomized placements
local function generateRandomizedPlacements()
    local randomized = {}
    for _, base in ipairs(basePlacements) do
        local offset = getRandomOffset()
        local newPos = base.position + offset
        table.insert(randomized, {
            time = base.time,
            unit = base.unit,
            cost = base.cost,
            data = {
                Valid = true,
                Rotation = base.rotation,
                CF = CFrame.new(newPos.X, newPos.Y, newPos.Z, -1, 0, -8.742277657347586e-08, 0, 1, 0, 8.742277657347586e-08, 0, -1),
                Position = newPos
            }
        })
        warn(string.format("[HUMANIZED] %s: Position offset (%.1f, %.1f)",
            base.unit, offset.X, offset.Z))
    end
    return randomized
end

-- Place units
local function placeUnits(placements)
    for _, placement in ipairs(placements) do
        task.delay(placement.time, function()
            local waitTime = 0
            while getMoney() < placement.cost and waitTime < 60 do
                task.wait(1)
                waitTime = waitTime + 1
            end
            local currentMoney = getMoney()
            if currentMoney >= placement.cost then
                local success, result = pcall(function()
                    return remotes.PlaceUnit:InvokeServer(placement.unit, placement.data)
                end)
                if success then
                    warn("[PLACED] " .. placement.unit .. " at " .. placement.time .. "s (Had: $" .. currentMoney .. ")")
                else
                    warn("[FAILED] " .. placement.unit .. " - " .. tostring(result))
                end
            else
                warn("[SKIPPED] " .. placement.unit .. " - Not enough money (Need: $" .. placement.cost .. ", Have: $" .. currentMoney .. ")")
            end
        end)
    end
end

-- Upgrade loop
local function startUpgrades()
    _G.upgradeLoopRunning = true
    task.spawn(function()
        task.wait(15)
        while _G.upgradeLoopRunning and _G.trackingEnabled do
            if #_G.myUnitIDs > 0 then
                for _, unitID in ipairs(_G.myUnitIDs) do
                    if not _G.upgradeLoopRunning then break end
                    if getMoney() >= 125 then
                        local success = pcall(function()
                            remotes.UpgradeUnit:InvokeServer(unitID)
                        end)
                        if success then
                            warn("[UPGRADED] Unit ID: " .. unitID)
                        end
                        task.wait(math.random(30, 80) / 100)
                    end
                end
            end
            task.wait(math.random(15, 25) / 10)
        end
        warn("[UPGRADE LOOP] Stopped")
    end)
end

-- MAIN LOOP
while true do
    warn("========================================")
    warn("[GAME START] Setting up new game...")
    warn("========================================")
    _G.myUnitIDs = {}
    _G.trackingEnabled = true
    _G.upgradeLoopRunning = false
    warn("[TRACKING] Enabled - waiting for units...")
    local randomizedPlacements = generateRandomizedPlacements()
    setupGame()
    placeUnits(randomizedPlacements)
    startUpgrades()
    task.wait(260)
    warn("[STOPPING] Disabling tracking and upgrades...")
    _G.trackingEnabled = false
    _G.upgradeLoopRunning = false
    task.wait(2)
    warn("[RESTART] Restarting game...")
    pcall(function()
        remotes.RestartGame:InvokeServer()
    end)
    task.wait(8)
end

--=== LOADSTRINGS ===--
loadstring(game:HttpGet("https://pastebin.com/raw/HkAmPckQ"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();