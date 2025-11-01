wait(1)
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local plr = Players.LocalPlayer
wait(1)

getgenv().isTracking = getgenv().isTracking or false
getgenv().webhookURL = getgenv().webhookURL or ""
getgenv().isMinimized = getgenv().isMinimized or false
getgenv().startSeeds = getgenv().startSeeds or 0

local WEBHOOK_FILE = "webhook_config.txt"

local function loadWebhook()
    if isfile and readfile then
        pcall(function()
            if isfile(WEBHOOK_FILE) then
                local url = readfile(WEBHOOK_FILE)
                if url and url ~= "" then
                    getgenv().webhookURL = url
                end
            end
        end)
    end
end

local function saveWebhook(url)
    if writefile then
        pcall(function()
            writefile(WEBHOOK_FILE, url)
        end)
    end
end

loadWebhook()

local function getValueSafe(obj)
    if not obj then return "N/A" end
    local v = obj.Value
    if type(v) == "number" then return tostring(v) end
    if type(v) == "string" then return v end
    return tostring(v)
end

local function getRealSeedsValue()
    local stats = plr:FindFirstChild("leaderstats")
    if stats then
        local seedsObj = stats:FindFirstChild("Seeds")
        if seedsObj then
            local val = seedsObj.Value
            if type(val) == "number" then
                return val
            end
        end
    end
    return 0
end

local function getCandyFromScreen()
    local success, result = pcall(function()
        local gui = plr.PlayerGui:FindFirstChild("GameGui")
        if not gui then return "N/A" end
        
        for _, obj in pairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local txt = obj.Text
                
                local bigNumber = txt:match("(%d%d%d%d%d+)")
                if bigNumber then
                    local numVal = tonumber(bigNumber)
                    if numVal and numVal > 10000 then
                        return bigNumber
                    end
                end
            end
        end
        return "N/A"
    end)
    
    if success then return result else return "N/A" end
end

local function makeGUI()
    local old = plr.PlayerGui:FindFirstChild("WebhookGUI")
    if old then old:Destroy() end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "WebhookGUI"
    sg.ResetOnSpawn = false
    sg.Parent = plr.PlayerGui
    
    local fr = Instance.new("Frame")
    fr.Size
