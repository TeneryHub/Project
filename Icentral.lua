-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Variables for dragging
local dragging
local dragStart
local startPos
local dragInput

-- Exact time format function
local function formatTime()
    return os.date("!%Y-%m-%d %H:%M:%S")
end

-- Configuration
local config = {
    autoFarm = {
        path1 = false,
        path2 = false,
        path3 = false,
        antiAFK = false,
        autoReconnect = false
    }
}

local autoFarmConfig = {
    path1 = false,
    path2 = false,
    path3 = false,
    antiAFK = false,
    autoReconnect = false
}

-- Save configuration
local function saveConfig()
    local configToSave = {
        autoFarm = {
            path1 = config.autoFarm.path1,
            path2 = config.autoFarm.path2,
            path3 = config.autoFarm.path3,
            antiAFK = config.autoFarm.antiAFK,
            autoReconnect = config.autoFarm.autoReconnect
        }
    }
    
    local success, data = pcall(function()
        return HttpService:JSONEncode(configToSave)
    end)
    
    if success then
        pcall(function()
            writefile("TeneryHub_config.txt", data)
        end)
        return true
    end
    return false
end

-- Load configuration
local function loadConfig()
    if isfile("TeneryHub_config.txt") then
        local success, data = pcall(function()
            return readfile("TeneryHub_config.txt")
        end)
        
        if success then
            local decodeSuccess, decoded = pcall(function()
                return HttpService:JSONDecode(data)
            end)
            
            if decodeSuccess and type(decoded) == "table" and decoded.autoFarm then
                config = decoded
                for key, value in pairs(config.autoFarm) do
                    autoFarmConfig[key] = value
                end
                return true
            end
        end
    end
    return false
end

-- Auto farm function
local function startAutoFarm()
    while true do
        pcall(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                for _, point in pairs(workspace.ActivePoints:GetChildren()) do
                    if point:IsA("BasePart") then
                        local pathType = "path"..point.Name
                        if autoFarmConfig[pathType] then
                            firetouchinterest(root, point, 0)
                            task.wait()
                            firetouchinterest(root, point, 1)
                        end
                    end
                end
            end
        end)
        task.wait() 
    end
end

-- Anti AFK function
local function startAntiAFK()
    local antiAFKConnection = nil
    
    while true do
        if config.autoFarm.antiAFK then
            if not antiAFKConnection then
                antiAFKConnection = player.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        else
            if antiAFKConnection then
                antiAFKConnection:Disconnect()
                antiAFKConnection = nil
            end
        end
        task.wait(1)
    end
end

-- Auto reconnect function
local function startAutoReconnect()
    while true do
        if config.autoFarm.autoReconnect then
            game:GetService("GuiService").ErrorMessageChanged:Connect(function()
                task.wait(5)
                game:GetService("TeleportService"):Teleport(game.PlaceId)
            end)
        end
        task.wait(1)
    end
end

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeneryHubGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Handle ScreenGui protection
pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game:GetService("CoreGui")
    end
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
end

-- Create main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Create UI elements
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Create title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Tenery Hub |⭐[NEW UGC] Collect for UGC💎"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

-- Create content container
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -20, 1, -40)
ContentContainer.Position = UDim2.new(0, 10, 0, 35)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.ScrollBarThickness = 2
ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 60)
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentContainer.Parent = MainFrame

-- Create info container
local InfoContainer = Instance.new("Frame")
InfoContainer.Name = "InfoContainer"
InfoContainer.Size = UDim2.new(1, 0, 0, 70)
InfoContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
InfoContainer.BorderSizePixel = 0
InfoContainer.Parent = ContentContainer

-- Create time label
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Name = "TimeLabel"
TimeLabel.Size = UDim2.new(1, -20, 0, 30)
TimeLabel.Position = UDim2.new(0, 10, 0, 5)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted):"
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.TextSize = 13
TimeLabel.Font = Enum.Font.GothamBold
TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
TimeLabel.Parent = InfoContainer

-- Create time value
local TimeValue = Instance.new("TextLabel")
TimeValue.Name = "TimeValue"
TimeValue.Size = UDim2.new(1, -20, 0, 20)
TimeValue.Position = UDim2.new(0, 10, 0, 25)
TimeValue.BackgroundTransparency = 1
TimeValue.Text = formatTime()
TimeValue.TextColor3 = Color3.fromRGB(85, 255, 127)
TimeValue.TextSize = 13
TimeValue.Font = Enum.Font.GothamBold
TimeValue.TextXAlignment = Enum.TextXAlignment.Left
TimeValue.Parent = InfoContainer

-- Create user display
local UserDisplay = Instance.new("TextLabel")
UserDisplay.Name = "UserDisplay"
UserDisplay.Size = UDim2.new(1, -20, 0, 20)
UserDisplay.Position = UDim2.new(0, 10, 0, 45)
UserDisplay.BackgroundTransparency = 1
UserDisplay.Text = "Current User's Login: " .. player.Name
UserDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
UserDisplay.TextSize = 13
UserDisplay.Font = Enum.Font.GothamBold
UserDisplay.TextXAlignment = Enum.TextXAlignment.Left
UserDisplay.Parent = InfoContainer

-- Create toggle container
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Name = "ToggleContainer"
ToggleContainer.Size = UDim2.new(1, 0, 0, 290)
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Parent = ContentContainer

-- Create toggle function
local function createToggle(text, gemValue, position)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = text.."Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.Position = position
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ToggleContainer

    local toggleText = text == "autoReconnect" and "Auto Reconnect" or
                      text == "antiAFK" and "Anti AFK" or
                      "Gems +" .. gemValue

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(1, -80, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 15, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = toggleText
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local ToggleButton = Instance.new("Frame")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -55, 0.5, -10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = ToggleFrame

    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "Circle"
    ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleButton

    local enabled = config.autoFarm[text] or false
    if enabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 60)
        ToggleCircle.Position = UDim2.new(1, -18, 0.5, -8)
    end

    local ClickArea = Instance.new("TextButton")
    ClickArea.Name = "ClickArea"
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = ToggleFrame

    ClickArea.MouseButton1Click:Connect(function()
        enabled = not enabled
        config.autoFarm[text] = enabled
        autoFarmConfig[text] = enabled
        
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = enabled and Color3.fromRGB(255, 0, 60) or Color3.fromRGB(15, 15, 15)
        }):Play()
        
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
            Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        
        saveConfig()
    end)

    return ClickArea
end

-- Create toggles
createToggle("path1", "1", UDim2.new(0, 0, 0, 0))
createToggle("path2", "5", UDim2.new(0, 0, 0, 60))
createToggle("path3", "10", UDim2.new(0, 0, 0, 120))
createToggle("antiAFK", "", UDim2.new(0, 0, 0, 180))
createToggle("autoReconnect", "", UDim2.new(0, 0, 0, 240))

-- Update time
task.spawn(function()
    while true do
        TimeValue.Text = formatTime()
        task.wait(1)
    end
end)

-- Start auto farm
task.spawn(startAutoFarm)
task.spawn(startAntiAFK)
task.spawn(startAutoReconnect)

-- Load configuration
if loadConfig() then
    print("Configuration loaded successfully")
else
    print("No saved configuration found")
end

-- Save configuration on exit
game:GetService("Players").PlayerRemoving:Connect(function(plr)
    if plr == player then
        saveConfig()
    end
end)

-- Save before teleport
player.OnTeleport:Connect(saveConfig)

-- Auto save every 30 seconds
task.spawn(function()
    while true do
        task.wait(30)
        saveConfig()
    end
end)
