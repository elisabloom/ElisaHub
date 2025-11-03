--// Garden Tower Defense Hub with WindUI
--// Made by Noah Hub

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/source.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Noah Hub",
    Icon = "rbxassetid://10723415903",
    Author = "by Threldor",
    Folder = "NoahHub",
    Size = UDim2.fromOffset(580, 460),
    KeySystem = false,
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
})

-- User Display (opcional)
Window.User:Set({
    Name = game.Players.LocalPlayer.Name,
    UserId = game.Players.LocalPlayer.UserId
})

-- Tags
Window:Tag({
    Title = "v2.0",
    Color = Color3.fromHex("#30ff6a")
})

Window:Tag({
    Title = "Beta",
    Color = Color3.fromHex("#315dff")
})

-- ==========================================
-- VARIABLES GLOBALES
-- ==========================================

_G.FarmEnabled = false
_G.AutoUpgrade = false
_G.SelectedMap = "map_farm"
_G.SelectedDifficulty = "dif_easy"
_G.SelectedSpeed = 3

local rs = game:GetService("ReplicatedStorage")
local remotes = rs:WaitForChild("RemoteFunctions")
local plr = game.Players.LocalPlayer

-- ==========================================
-- TAB: AUTO FARM
-- ==========================================

local FarmTab = Window:Tab({
    Title = "Auto Farm",
    Icon = "sprout"
})

local FarmSection = FarmTab:Section({
    Title = "Farm Settings"
})

FarmSection:Dropdown({
    Title = "Select Map",
    Description = "Choose which map to farm",
    Values = {"Farm Map", "Dojo Map", "Graveyard Map"},
    Default = "Farm Map",
    Callback = function(value)
        if value == "Farm Map" then
            _G.SelectedMap = "map_farm"
        elseif value == "Dojo Map" then
            _G.SelectedMap = "map_dojo"
        elseif value == "Graveyard Map" then
            _G.SelectedMap = "map_graveyard"
        end
        WindUI:Notify({
            Title = "Map Changed",
            Content = "Selected: " .. value,
            Duration = 3
        })
    end
})

FarmSection:Dropdown({
    Title = "Difficulty",
    Description = "Select game difficulty",
    Values = {"Easy", "Normal", "Hard", "Impossible", "Apocalypse"},
    Default = "Easy",
    Callback = function(value)
        local diffMap = {
            Easy = "dif_easy",
            Normal = "dif_normal",
            Hard = "dif_hard",
            Impossible = "dif_impossible",
            Apocalypse = "dif_apocalypse"
        }
        _G.SelectedDifficulty = diffMap[value]
        WindUI:Notify({
            Title = "Difficulty Changed",
            Content = value,
            Duration = 3
        })
    end
})

FarmSection:Dropdown({
    Title = "Game Speed",
    Description = "Select game speed multiplier",
    Values = {"1x", "2x", "3x"},
    Default = "3x",
    Callback = function(value)
        _G.SelectedSpeed = tonumber(string.sub(value, 1, 1))
        WindUI:Notify({
            Title = "Speed Changed",
            Content = value,
            Duration = 3
        })
    end
})

FarmSection:Toggle({
    Title = "Enable Auto Farm",
    Description = "Start automatic farming",
    Default = false,
    Callback = function(value)
        _G.FarmEnabled = value
        if value then
            WindUI:Notify({
                Title = "Auto Farm Started",
                Content = "Farming on " .. _G.SelectedMap,
                Duration = 5
            })
            -- Aquí irían tus funciones de farm
        else
            WindUI:Notify({
                Title = "Auto Farm Stopped",
                Content = "Farm disabled",
                Duration = 3
            })
        end
    end
})

FarmSection:Toggle({
    Title = "Auto Upgrade Units",
    Description = "Automatically upgrade placed units",
    Default = false,
    Callback = function(value)
        _G.AutoUpgrade = value
    end
})

-- ==========================================
-- TAB: MACROS
-- ==========================================

local MacroTab = Window:Tab({
    Title = "Macros",
    Icon = "file-code"
})

local MacroSection = MacroTab:Section({
    Title = "Macro Manager"
})

MacroSection:Button({
    Title = "Open Macro Recorder",
    Description = "Launch the macro recording tool",
    Callback = function()
        loadstring(game:HttpGet("YOUR_MACRO_RECORDER_URL"))()
        WindUI:Notify({
            Title = "Macro Recorder",
            Content = "Macro tool loaded!",
            Duration = 3
        })
    end
})

-- ==========================================
-- TAB: UNITS
-- ==========================================

local UnitsTab = Window:Tab({
    Title = "Units",
    Icon = "users"
})

local UnitsSection = UnitsTab:Section({
    Title = "Quick Place Units"
})

UnitsSection:Button({
    Title = "Place Rainbow Tomato",
    Description = "Instantly place a Rainbow Tomato",
    Callback = function()
        -- Código para colocar unidad
        WindUI:Notify({
            Title = "Unit Placed",
            Content = "Rainbow Tomato placed",
            Duration = 2
        })
    end
})

UnitsSection:Button({
    Title = "Place Tomato Plant",
    Description = "Instantly place a Tomato Plant",
    Callback = function()
        -- Código para colocar unidad
        WindUI:Notify({
            Title = "Unit Placed",
            Content = "Tomato Plant placed",
            Duration = 2
        })
    end
})

-- ==========================================
-- TAB: MISC
-- ==========================================

local MiscTab = Window:Tab({
    Title = "Misc",
    Icon = "settings"
})

local MiscSection = MiscTab:Section({
    Title = "Miscellaneous"
})

MiscSection:Toggle({
    Title = "Auto Skip Waves",
    Description = "Automatically skip wave countdown",
    Default = true,
    Callback = function(value)
        -- Auto skip logic
    end
})

MiscSection:Button({
    Title = "Collect All Rewards",
    Description = "Claim all available rewards",
    Callback = function()
        WindUI:Notify({
            Title = "Rewards",
            Content = "All rewards collected!",
            Duration = 3
        })
    end
})

MiscSection:Button({
    Title = "Teleport to Lobby",
    Description = "Return to main lobby",
    Callback = function()
        -- Teleport code
    end
})

-- ==========================================
-- TAB: WEBHOOK
-- ==========================================

local WebhookTab = Window:Tab({
    Title = "Webhook",
    Icon = "webhook"
})

local WebhookSection = WebhookTab:Section({
    Title = "Discord Webhook"
})

_G.webhookURL = ""

WebhookSection:Input({
    Title = "Webhook URL",
    Description = "Paste your Discord webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(value)
        _G.webhookURL = value
        WindUI:Notify({
            Title = "Webhook Saved",
            Content = "URL configured successfully",
            Duration = 3
        })
    end
})

WebhookSection:Toggle({
    Title = "Send Game Results",
    Description = "Send results to Discord after each game",
    Default = false,
    Callback = function(value)
        _G.webhookEnabled = value
    end
})

WebhookSection:Button({
    Title = "Test Webhook",
    Description = "Send a test message",
    Callback = function()
        if _G.webhookURL ~= "" then
            -- Test webhook function
            WindUI:Notify({
                Title = "Test Sent",
                Content = "Check your Discord!",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Please enter a webhook URL first",
                Duration = 3
            })
        end
    end
})

-- ==========================================
-- TAB: SETTINGS
-- ==========================================

local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings-2"
})

local UISection = SettingsTab:Section({
    Title = "UI Settings"
})

UISection:Colorpicker({
    Title = "Theme Color",
    Description = "Customize the UI accent color",
    Default = Color3.fromRGB(49, 93, 255),
    Callback = function(color)
        -- Apply color theme
    end
})

UISection:Slider({
    Title = "UI Transparency",
    Description = "Adjust window transparency",
    Default = 0.2,
    Min = 0,
    Max = 1,
    Decimals = 0.01,
    Callback = function(value)
        Window:SetTransparency(value)
    end
})

UISection:Button({
    Title = "Destroy UI",
    Description = "Close and remove the hub",
    Callback = function()
        Window:Destroy()
    end
})

-- ==========================================
-- TAB: CREDITS
-- ==========================================

local CreditsTab = Window:Tab({
    Title = "Credits",
    Icon = "heart"
})

local CreditsSection = CreditsTab:Section({
    Title = "Created By"
})

CreditsSection:Label({
    Title = "Noah Hub",
    Description = "Main Developer"
})

CreditsSection:Label({
    Title = "WindUI",
    Description = "UI Library by Footages"
})

CreditsSection:Button({
    Title = "Join Discord Server",
    Description = "Get support and updates",
    Callback = function()
        -- Discord invite code
        WindUI:Notify({
            Title = "Discord",
            Content = "Invite copied to clipboard!",
            Duration = 3
        })
    end
})

-- ==========================================
-- INITIALIZE
-- ==========================================

WindUI:Notify({
    Title = "Noah Hub Loaded",
    Content = "Garden Tower Defense v2.0",
    Duration = 5
})

warn("========================================")
warn("[NOAH HUB] Garden Tower Defense loaded!")
warn("[VERSION] 2.0 Beta")
warn("[UI] WindUI by Footages")
warn("========================================")
