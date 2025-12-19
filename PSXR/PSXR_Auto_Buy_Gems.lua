local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local VirtualUser = game:GetService("VirtualUser")

local Library = require(ReplicatedStorage:WaitForChild("Library"))
local diamondGui = PlayerGui:WaitForChild("Diamonds Animation")

-- Utility function to get RemoteFunction by index
local function getRemote(int)
    local count = 0
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteFunction") then
            count += 1
            if count == int then
                return obj
            end
        end
    end
    return nil
end

local function Autobuy(bundleNumber, remoteIndex)
    local remote = getRemote(remoteIndex)
    if remote then
        remote:InvokeServer(bundleNumber)
    end
end

-- Create GUI
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "Auto Buy Gems"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 120, 0, 125)
frame.Position = UDim2.new(0.5, -160, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Header
local header = Instance.new("Frame", frame)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 20)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Text = "⚡Auto Buy"
title.Font = Enum.Font.GothamBold
title.TextSize = 10
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", header)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Size = UDim2.new(0, 15, 0, 15)
closeBtn.Position = UDim2.new(0, 100, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.Size = UDim2.new(0, 15, 0, 15)
minimizeBtn.Position = UDim2.new(0, 82, 0, 2)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)

-- Content
local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Position = UDim2.new(0, 0, 0, 30)
content.Size = UDim2.new(1, 0, 1, -30)
content.BackgroundTransparency = 1

-- Inputs
local TargetBox = Instance.new("TextBox", content)
TargetBox.Size = UDim2.new(0, 100, 0, 20)
TargetBox.Position = UDim2.new(0, 10, 0, -5)
TargetBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TargetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetBox.PlaceholderText = "Bundle Number"
TargetBox.Text = "2"
TargetBox.BorderSizePixel = 0

local remoteBox = Instance.new("TextBox", content)
remoteBox.Size = UDim2.new(0, 100, 0, 20)
remoteBox.Position = UDim2.new(0, 10, 0, 20)
remoteBox.PlaceholderText = "Remote Index"
remoteBox.Text = "130"
remoteBox.TextColor3 = Color3.new(1, 1, 1)
remoteBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", remoteBox).CornerRadius = UDim.new(0, 6)

-- Auto Buy Button
local BuyBtn = Instance.new("TextButton", content)
BuyBtn.Size = UDim2.new(0, 100, 0, 20)
BuyBtn.Position = UDim2.new(0, 10, 0, 45)
BuyBtn.Text = "Auto Buy: OFF"
BuyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BuyBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
BuyBtn.BorderSizePixel = 0
Instance.new("UICorner", BuyBtn).CornerRadius = UDim.new(0, 6)

-- AFK Timer Labels
local function createLabel(name, text, pos, xSize, ySize, color)
    local lbl = Instance.new("TextLabel", content)
    lbl.Name = name
    lbl.Text = text
    lbl.Size = UDim2.new(0, xSize, 0, ySize)
    lbl.Position = pos
    lbl.BackgroundColor3 = color
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.BorderSizePixel = 0
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0,6)
    return lbl
end

local AntiAfkLbl = createLabel("AntiAfkLbl", "AFK:", UDim2.new(0,10,0,70), 40, 20, Color3.fromRGB(50,50,50))
local AfkTimeLabel = createLabel("AfkTimeLabel", "0:0:0", UDim2.new(0,55,0,70), 55, 20, Color3.fromRGB(50,50,50))

-- Auto Buy and Anti-AFK Logic
local autoBuyEnabled = false
local antiAfkEnabled = false
local interval = 0.03
local seconds, minutes, hours = 0, 0, 0
local timerRunning = false

local function updateBuyButton()
    if autoBuyEnabled then
        BuyBtn.Text = "Auto Buy: ON"
        BuyBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        diamondGui.Enabled = false
        antiAfkEnabled = true
        timerRunning = true
    else
        BuyBtn.Text = "Auto Buy: OFF"
        BuyBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        diamondGui.Enabled = true
        antiAfkEnabled = false
        timerRunning = false
        seconds, minutes, hours = 0,0,0
        AfkTimeLabel.Text = "0:0:0"
    end
end

BuyBtn.MouseButton1Click:Connect(function()
    autoBuyEnabled = not autoBuyEnabled
    updateBuyButton()
end)

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if antiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

task.spawn(function()
    while true do
        if autoBuyEnabled then
            local bundle = tonumber(TargetBox.Text)
            local remoteIndex = tonumber(remoteBox.Text)
            if bundle and remoteIndex then
                Autobuy(bundle, remoteIndex)
            end
        end
        task.wait(interval)
    end
end)

-- AFK Timer
task.spawn(function()
    while true do
        task.wait(1)
        if timerRunning then
            seconds += 1
            if seconds >= 60 then seconds = 0 minutes += 1 end
            if minutes >= 60 then minutes = 0 hours += 1 end
            AfkTimeLabel.Text = string.format("%d:%d:%d", hours, minutes, seconds)
        end
    end
end)

-- Minimize
local isMinimized = false
local originalSize = frame.Size
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        content.Visible = false
        frame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, header.Size.Y.Offset)
        minimizeBtn.Text = "+"
    else
        content.Visible = true
        frame.Size = originalSize
        minimizeBtn.Text = "-"
    end
end)

-- Close
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

