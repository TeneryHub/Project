-- Fixed Roblox Utility Script
if game.PlaceId == 8305160617 or game.Placeid == 8305337434 then

-- === SETTINGS ===
 --[[
  getgenv().config = {
    rotationSpeed = 10000,
    radius = 1000,
    height = 100,
    attractionStrength = 1000
}
getgenv().ringPartsEnabled = true
--]]
-- === UTILITY FUNCTIONS ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti-sit
local function antisit()
    local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        humanoid.Sit = true
    end
end

-- Anti-killbrick (fixed with Heartbeat loop)
local myzaza = false
UIS.InputBegan:Connect(function(input, GPE)
    if not GPE and input.KeyCode == Enum.KeyCode.K then -- Use 'K' to toggle
        myzaza = not myzaza
    end
end)
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    local parts = workspace:GetPartBoundsInRadius(LocalPlayer.Character.HumanoidRootPart.Position, 10)
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            part.CanTouch = myzaza
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not LocalPlayer.Character then return end
    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end)

-- Config Save Button
local function configsavebutton()
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    gui.Name = "SafePlaceCircleGui"
    gui.ResetOnSpawn = false

    local function makeBtn(text, pos, cb)
        local b = Instance.new("TextButton", gui)
        b.Size = UDim2.new(0, 100, 0, 100)
        b.Position = pos
        b.Text = text
        b.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextScaled = true
        b.Font = Enum.Font.SourceSansBold
        b.BorderSizePixel = 0

        local uicorner = Instance.new("UICorner", b)
        uicorner.CornerRadius = UDim.new(1, 0)

        b.MouseButton1Click:Connect(cb)
    end

    makeBtn("Safe Place", UDim2.new(0.5, -50, 0.5, -50), function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and Workspace:FindFirstChild("Circle") then
            hrp.CFrame = Workspace.Circle.CFrame
        end
    end)

    makeBtn("Create Safe Place", UDim2.new(0.5, -150, 0.5, -50), function()
        LocalPlayer.Character:PivotTo(CFrame.new(-0.711, 662.58, -3.298))
        local newBrick = Instance.new("Part")
        newBrick.Size = Vector3.new(100, 0, 100)
        newBrick.Anchored = true
        newBrick.Transparency = 0.4
        newBrick.CFrame = CFrame.new(-0.727, 655.813, -3.282)
        newBrick.Name = "Circle"
        newBrick.Parent = Workspace
    end)
end

-- Fling Logic
local function fling()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local Folder = Instance.new("Folder", Workspace)
    Folder.Name = "FlingParts"

    local parts = {}
    for _, p in pairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(LocalPlayer.Character) then
            table.insert(parts, p)
        end
    end

    RunService.Heartbeat:Connect(function()
        if not getgenv().ringPartsEnabled then return end
        local center = humanoidRootPart.Position
        for _, part in pairs(parts) do
            if part and part.Parent and not part.Anchored then
                local pos = part.Position
                local distance = (Vector3.new(pos.X, center.Y, pos.Z) - center).Magnitude
                local angle = math.atan2(pos.Z - center.Z, pos.X - center.X)
                local newAngle = angle + math.rad(getgenv().config.rotationSpeed)
                local targetPos = Vector3.new(
                    center.X + math.cos(newAngle) * math.min(getgenv().config.radius, distance),
                    center.Y + (getgenv().config.height * math.abs(math.sin((pos.Y - center.Y) / getgenv().config.height))),
                    center.Z + math.sin(newAngle) * math.min(getgenv().config.radius, distance)
                )
                local direction = (targetPos - part.Position).Unit
                part.Velocity = direction * getgenv().config.attractionStrength
            end
        end
    end)
end

-- Run all
fling()
antisit()
configsavebutton()
end
