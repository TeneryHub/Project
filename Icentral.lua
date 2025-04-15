-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Variables
local dragging
local dragStart
local startPos
local dragInput

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

-- Save/Load Functions
local function saveConfig()
    local data = HttpService:JSONEncode(config)
    writefile("TeneryHub_config.txt", data)
end

local function loadConfig()
    if isfile("TeneryHub_config.txt") then
        local data = readfile("TeneryHub_config.txt")
        local success, result = pcall(function()
            return HttpService:JSONDecode(data)
        end)
        if success then
            config = result
            return true
        end
    end
    return false
end

-- Auto Farm Configuration
local autoFarmConfig = {
    path1 = false,
    path2 = false,
    path3 = false,
    antiAFK = false,
    autoReconnect = false
}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeneryHubGUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Try to protect the GUI
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

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Add corner rounding
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Add stroke
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 0, 60)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleBarCorner = Instance.new("UICorner")
TitleBarCorner.CornerRadius = UDim.new(0, 8)
TitleBarCorner.Parent = TitleBar

local TitleBarCover = Instance.new("Frame")
TitleBarCover.Size = UDim2.new(1, 0, 0.5, 0)
TitleBarCover.Position = UDim2.new(0, 0, 0.5, 0)
TitleBarCover.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
TitleBarCover.BorderSizePixel = 0
TitleBarCover.Parent = TitleBar

-- Title
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

-- Content Container with Scrolling
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

-- Add auto-size canvas
local ContentLayout = Instance.new("UIListLayout")
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 5)
ContentLayout.Parent = ContentContainer

-- Add padding
local ContentPadding = Instance.new("UIPadding")
ContentPadding.PaddingTop = UDim.new(0, 5)
ContentPadding.PaddingBottom = UDim.new(0, 5)
ContentPadding.PaddingLeft = UDim.new(0, 5)
ContentPadding.PaddingRight = UDim.new(0, 5)
ContentPadding.Parent = ContentContainer

-- Function to update canvas size
local function updateCanvasSize()
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
end

-- Connect the update function
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

-- Info Container
local InfoContainer = Instance.new("Frame")
InfoContainer.Name = "InfoContainer"
InfoContainer.Size = UDim2.new(1, 0, 0, 70)
InfoContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
InfoContainer.BorderSizePixel = 0
InfoContainer.LayoutOrder = 1
InfoContainer.Parent = ContentContainer

local InfoCorner = Instance.new("UICorner")
InfoCorner.CornerRadius = UDim.new(0, 6)
InfoCorner.Parent = InfoContainer

-- Time Display
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

local TimeValue = Instance.new("TextLabel")
TimeValue.Name = "TimeValue"
TimeValue.Size = UDim2.new(1, -20, 0, 20)
TimeValue.Position = UDim2.new(0, 10, 0, 25)
TimeValue.BackgroundTransparency = 1
TimeValue.Text = os.date("%Y-%m-%d %H:%M:%S")
TimeValue.TextColor3 = Color3.fromRGB(85, 255, 127)
TimeValue.TextSize = 13
TimeValue.Font = Enum.Font.GothamBold
TimeValue.TextXAlignment = Enum.TextXAlignment.Left
TimeValue.Parent = InfoContainer

-- User Display
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

-- Tabs Container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(1, 0, 0, 35)
TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabContainer.BorderSizePixel = 0
TabContainer.LayoutOrder = 2
TabContainer.Parent = ContentContainer

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 6)
TabCorner.Parent = TabContainer

-- Save Button
local SaveButton = Instance.new("TextButton")
SaveButton.Name = "SaveButton"
SaveButton.Size = UDim2.new(0.5, -5, 1, -10)
SaveButton.Position = UDim2.new(0, 5, 0, 5)
SaveButton.BackgroundColor3 = Color3.fromRGB(255, 0, 60)
SaveButton.Text = "Save [Broken Il Fix soon]"
SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveButton.TextSize = 14
SaveButton.Font = Enum.Font.GothamBold
SaveButton.Parent = TabContainer

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 6)
SaveCorner.Parent = SaveButton

-- Discord Button
local DiscordButton = Instance.new("TextButton")
DiscordButton.Name = "DiscordButton"
DiscordButton.Size = UDim2.new(0.5, -5, 1, -10)
DiscordButton.Position = UDim2.new(0.5, 5, 0, 5)
DiscordButton.BackgroundColor3 = Color3.fromRGB(255, 0, 60)
DiscordButton.Text = "Join Discord"
DiscordButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DiscordButton.TextSize = 14
DiscordButton.Font = Enum.Font.GothamBold
DiscordButton.Parent = TabContainer

local DiscordCorner = Instance.new("UICorner")
DiscordCorner.CornerRadius = UDim.new(0, 6)
DiscordCorner.Parent = DiscordButton

-- Toggle Container
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Name = "ToggleContainer"
ToggleContainer.Size = UDim2.new(1, 0, 0, 290)
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.LayoutOrder = 3
ToggleContainer.Parent = ContentContainer

-- Create Toggle Function
local function createToggle(text, gemValue, position)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = text.."Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.Position = position
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ToggleContainer

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleFrame

    local toggleText
    if text == "autoReconnect" then
        toggleText = "Auto Reconnect"
    elseif text == "antiAFK" then
        toggleText = "Anti AFK"
    else
        toggleText = "Gems +" .. gemValue
    end

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

    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
    ToggleButtonCorner.Parent = ToggleButton

    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "Circle"
    ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleButton

    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCircleCorner.Parent = ToggleCircle

    local ClickArea = Instance.new("TextButton")
    ClickArea.Name = "ClickArea"
    ClickArea.Size = UDim2.new(1, 0, 1, 0)
    ClickArea.BackgroundTransparency = 1
    ClickArea.Text = ""
    ClickArea.Parent = ToggleFrame

    local Count = nil
    if text ~= "antiAFK" and text ~= "autoReconnect" then
        Count = Instance.new("TextLabel")
        Count.Name = "Count"
        Count.Size = UDim2.new(0, 40, 0, 20)
        Count.Position = UDim2.new(1, -110, 0.5, -10)
        Count.BackgroundTransparency = 1
        Count.Text = "0"
        Count.TextColor3 = Color3.fromRGB(85, 255, 127)
        Count.TextSize = 14
        Count.Font = Enum.Font.GothamBold
        Count.TextXAlignment = Enum.TextXAlignment.Right
        Count.Parent = ToggleFrame
    end

    local enabled = false
    if config.autoFarm[text] ~= nil then
        enabled = config.autoFarm[text]
        if enabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 0, 60)
            ToggleCircle.Position = UDim2.new(1, -18, 0.5, -8)
        end
    end

    ClickArea.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetColor = enabled and Color3.fromRGB(255, 0, 60) or Color3.fromRGB(15, 15, 15)
        local targetPosition = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = targetPosition}):Play()
        
        config.autoFarm[text] = enabled
        autoFarmConfig[text] = enabled
        
        pcall(saveConfig)
    end)

    return Count
end

-- Create Toggles
local path1Counter = createToggle("path1", "1", UDim2.new(0, 0, 0, 0))
local path2Counter = createToggle("path2", "5", UDim2.new(0, 0, 0, 60))
local path3Counter = createToggle("path3", "10", UDim2.new(0, 0, 0, 120))
local antiAFKCounter = createToggle("antiAFK", "", UDim2.new(0, 0, 0, 180))
local autoReconnectCounter = createToggle("autoReconnect", "", UDim2.new(0, 0, 0, 240))

-- Button Functions
local function createButtonEffect(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(200, 0, 45)
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 0, 60)
        }):Play()
    end)
end

createButtonEffect(SaveButton)
createButtonEffect(DiscordButton)

-- Button Click Events
SaveButton.MouseButton1Click:Connect(function()
    pcall(function()
        saveConfig()
        local originalColor = SaveButton.BackgroundColor3
        SaveButton.BackgroundColor3 = Color3.fromRGB(85, 255, 127)
        task.wait() 
        SaveButton.BackgroundColor3 = originalColor
    end)
end)

DiscordButton.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/avcKTA2w") 
end)

-- Auto Farm Function
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

-- Anti AFK Function
local function startAntiAFK()
    local antiAFKConnection = nil
    
    local function setupAntiAFK()
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
    end
    
    while true do
        setupAntiAFK()
        task.wait(1)
    end
end

-- Auto Reconnect Function
local function startAutoReconnect()
    local connections = {}

    local function setupAutoReconnect()
        if config.autoFarm.autoReconnect then
            if #connections == 0 then
                -- Error Message Handler
                connections.errorConnection = game:GetService("GuiService").ErrorMessageChanged:Connect(function()
                    print("Error detected, attempting to rejoin...")
                    task.wait(5)
                    game:GetService("TeleportService"):Teleport(game.PlaceId)
                end)

                -- Teleport Failure Handler
                connections.teleportConnection = player.OnTeleport:Connect(function(State)
                    if State == Enum.TeleportState.Failed then
                        print("Teleport failed, retrying...")
                        task.wait(5)
                        game:GetService("TeleportService"):Teleport(game.PlaceId)
                    end
                end)

                -- Connectivity Monitor
                connections.connectivityTask = task.spawn(function()
                    while config.autoFarm.autoReconnect do
                        if not player then
                            print("Lost connection, attempting to rejoin...")
                            game:GetService("TeleportService"):Teleport(game.PlaceId)
                        end
                        task.wait(5) 
                    end
                end)
            end
        else
            -- Cleanup connections
            for _, connection in pairs(connections) do
                if typeof(connection) == "RBXScriptConnection" then
                    connection:Disconnect()
                elseif typeof(connection) == "thread" then
                    task.cancel(connection)
                end
            end
            connections = {}
        end
    end

    while true do
        setupAutoReconnect()
        task.wait(1)
    end
end

-- Update Counter Function
local function updateCounters()
    while true do
        pcall(function()
            local activePoints = workspace:FindFirstChild("ActivePoints")
            if activePoints then
                local counts = {path1 = 0, path2 = 0, path3 = 0}
                
                for _, point in pairs(activePoints:GetChildren()) do
                    if point:IsA("BasePart") then
                        local pathType = "path"..point.Name
                        counts[pathType] = (counts[pathType] or 0) + 1
                    end
                end
                
                path1Counter.Text = tostring(counts.path1)
                path2Counter.Text = tostring(counts.path2)
                path3Counter.Text = tostring(counts.path3)

                for i, counter in pairs({path1Counter, path2Counter, path3Counter}) do
                    counter.TextColor3 = counts["path"..i] > 0 
                        and Color3.fromRGB(85, 255, 127) 
                        or Color3.fromRGB(255, 85, 85)
                end
            end
        end)
        task.wait() 
    end
end

-- Update Time Function
local function updateTime()
    while true do
        TimeValue.Text = os.date("%Y-%m-%d %H:%M:%S")
        task.wait() 
    end
end

-- Make GUI Draggable
local function updateDrag(input)
    local delta = input.Position - dragStart
    local position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
    TweenService:Create(MainFrame, TweenInfo.new(0.1), {Position = position}):Play()
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
       input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or
       input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)

-- Load saved configuration
pcall(function()
    if loadConfig() then
        print("Configuration loaded successfully")
    else
        print("No saved configuration found or error loading configuration")
    end
end)

-- Auto-save on teleport
player.OnTeleport:Connect(function()
    pcall(saveConfig)
end)

-- Auto-save on game exit
Players.PlayerRemoving:Connect(function(plr)
    if plr == player then
        pcall(saveConfig)
    end
end)

-- Start all functions
task.spawn(updateTime)
task.spawn(updateCounters)
task.spawn(startAutoFarm)
task.spawn(startAntiAFK)
task.spawn(startAutoReconnect)
