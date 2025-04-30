if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId == 15898586428 then

local cloneref = cloneref or function(...) return ... end
local DeltaLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/AsLikeJustScriptLuaForRoblox/Privatev1/refs/heads/main/Gui%20Libary/Source%20GUI.lua"))()
local Player = game.Players.LocalPlayer
local MarketplaceService = cloneref(game:GetService("MarketplaceService"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local SoundService = cloneref(game:GetService("SoundService"))

local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
local gameName = gameInfo.Name
local executorName = identifyexecutor()
local HWID = game:GetService("RbxAnalyticsService"):GetClientId()

local function playNotificationSound()
    local notificationSound = Instance.new("Sound")
    notificationSound.SoundId = "rbxassetid://8745692251"
    notificationSound.Volume = 0.5
    notificationSound.Parent = SoundService
    notificationSound:Play()
end

local function sendNotification(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 3,
        })
    end)
end

-- Create DeltaLib Window
local Window = DeltaLib:CreateWindow("The might obby gay.lua", UDim2.new(0, 550, 0, 400))
local UserProfile = Window:AddUserProfile()

local HomeTab = Window:CreateTab("Home")
local FarmTab = Window:CreateTab("Auto Farm")
local MiscTab = Window:CreateTab("Misc")  
local Whygay = Window:CreateTab("Egg")

-- HOME TAB
local Info = HomeTab:CreateSection("Account Info")
Info:AddLabel("Executor and Player Info")
Info:AddLabel("Game Name: " .. gameName)
Info:AddLabel("Place ID: " .. game.PlaceId)
Info:AddLabel("Username: " .. Player.Name)
Info:AddLabel("Display Name: " .. Player.DisplayName)
Info:AddLabel("User ID: " .. Player.UserId)
Info:AddLabel("Account Age: " .. Player.AccountAge .. " days")
Info:AddLabel("Executor: " .. executorName)
Info:AddLabel("HWID: " .. HWID)

local Discord = HomeTab:CreateSection("Discord")
Discord:AddLabel("Join our support server")
Discord:AddButton("Copy Discord Link", function()
    setclipboard("https://discord.gg/n8Mxqmze")
    playNotificationSound()
end)
Discord:AddButton("Set Username to Anonymous", function()
    UserProfile.SetDisplayName("Unknown")
    StatusLabel:SetText("Status: Username set to Unknown")
end)

-- AUTO FARM TAB
local Main = FarmTab:CreateSection("Main Features")
Main:AddButton("Anti AFK", function()
    sendNotification("AntiAfk", "Turned On", 10)
    Player.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    playNotificationSound()
end)

-- Infinite Spins toggle
Main:AddToggle("Auto Spin", false, function(state)
    getgenv().Hi = state
    task.spawn(function()
        while getgenv().Hi and task.wait() do
            local args = {}
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9):WaitForChild("NewSpin", 9e9):InvokeServer(unpack(args))
        end
    end)
    playNotificationSound()
end)

-- Infinite Spins Button
Main:AddButton("Inf Spins (Purchase Product)", function()
    local function SafePurchase(productId)
        pcall(function()
            game:GetService("MarketplaceService"):SignalPromptProductPurchaseFinished(game:GetService("Players").LocalPlayer.UserId, productId, true)
            for _, name in ipairs({"PurchaseProduct", "BuyItem", "AttemptPurchase"}) do
                if game:GetService("ReplicatedStorage"):FindFirstChild(name) then
                    if game:GetService("ReplicatedStorage")[name]:IsA("RemoteEvent") then
                        game:GetService("ReplicatedStorage")[name]:FireServer(productId)
                    elseif game:GetService("ReplicatedStorage")[name]:IsA("RemoteFunction") then
                        game:GetService("ReplicatedStorage")[name]:InvokeServer(productId)
                    end
                end
            end
        end)
    end

    SafePurchase(1821818097)
    playNotificationSound()
end)

end 
