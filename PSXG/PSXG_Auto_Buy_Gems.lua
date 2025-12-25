local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Library = require(ReplicatedStorage:WaitForChild("Library"))
local diamondGui = PlayerGui:WaitForChild("Diamonds Animation")

----------------------------------------------------
-- REMOTE FINDER
----------------------------------------------------
local function getRemote(index)
    local count = 0
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteFunction") then
            count += 1
            if count == index then
                return obj
            end
        end
    end
end

local function Autobuy(bundleValue, remoteIndex)
    local remote = getRemote(remoteIndex)
    if remote then
        remote:InvokeServer(bundleValue)
    end
end

----------------------------------------------------
-- GUI
----------------------------------------------------
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "AutoBuyGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 120, 0, 125)
frame.Position = UDim2.new(0.5, -160, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

----------------------------------------------------
-- HEADER
----------------------------------------------------
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 20)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Text = "⚡ Auto Buy"
title.Font = Enum.Font.GothamBold
title.TextSize = 10
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", header)
closeBtn.Text = "X"
closeBtn.Size = UDim2.new(0, 15, 0, 15)
closeBtn.Position = UDim2.new(0, 100, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", closeBtn)

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Text = "-"
minimizeBtn.Size = UDim2.new(0, 15, 0, 15)
minimizeBtn.Position = UDim2.new(0, 82, 0, 2)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(70,70,70)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", minimizeBtn)

----------------------------------------------------
-- CONTENT
----------------------------------------------------
local content = Instance.new("Frame", frame)
content.Position = UDim2.new(0, 0, 0, 30)
content.Size = UDim2.new(1, 0, 1, -30)
content.BackgroundTransparency = 1

----------------------------------------------------
-- DROPDOWN DATA (TEXT VALUES)
----------------------------------------------------
local bundleOptions = {
    { name = "100K",  value = "Tiny Diamonds"  },
    { name ="300K", value = "Medium Diamonds" },
    { name = "2.5M",  value = "Large Diamonds"  },
    { name = "25M",  value = "Massive Diamonds"  },
}

local selectedBundleValue = bundleOptions[1].value
local dropdownOpen = false

----------------------------------------------------
-- DROPDOWN BUTTON
----------------------------------------------------
local bundleDropdown = Instance.new("TextButton", content)
bundleDropdown.Size = UDim2.new(0, 100, 0, 20)
bundleDropdown.Position = UDim2.new(0, 10, 0, -5)
bundleDropdown.Text = bundleOptions[1].name .. " ▼"
bundleDropdown.TextColor3 = Color3.new(1,1,1)
bundleDropdown.BackgroundColor3 = Color3.fromRGB(40,40,40)
bundleDropdown.BorderSizePixel = 0
Instance.new("UICorner", bundleDropdown)

local dropdownFrame = Instance.new("Frame", content)
dropdownFrame.Position = UDim2.new(0, 115, 0, -5)
dropdownFrame.Size = UDim2.new(0, 100, 0, 0)
dropdownFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
dropdownFrame.Visible = false
dropdownFrame.ClipsDescendants = true
Instance.new("UICorner", dropdownFrame)

bundleDropdown.MouseButton1Click:Connect(function()
    dropdownOpen = not dropdownOpen
    dropdownFrame.Visible = dropdownOpen
    dropdownFrame.Size = dropdownOpen and UDim2.new(0,100,0,#bundleOptions * 22)
        or UDim2.new(0,100,0,0)
end)

for i, option in ipairs(bundleOptions) do
    local btn = Instance.new("TextButton", dropdownFrame)
    btn.Size = UDim2.new(1, 0, 0, 22)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 22)
    btn.Text = option.name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.BorderSizePixel = 0

    btn.MouseButton1Click:Connect(function()
        selectedBundleValue = option.value
        bundleDropdown.Text = option.name .. " ▼"
        dropdownOpen = false
        dropdownFrame.Visible = false
    end)
end

----------------------------------------------------
-- REMOTE INDEX INPUT
----------------------------------------------------
local remoteBox = Instance.new("TextBox", content)
remoteBox.Size = UDim2.new(0, 100, 0, 20)
remoteBox.Position = UDim2.new(0, 10, 0, 20)
remoteBox.PlaceholderText = "Remote Index"
remoteBox.Text = "130"
remoteBox.TextColor3 = Color3.new(1,1,1)
remoteBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
remoteBox.BorderSizePixel = 0
Instance.new("UICorner", remoteBox)

----------------------------------------------------
-- AUTO BUY BUTTON
----------------------------------------------------
local BuyBtn = Instance.new("TextButton", content)
BuyBtn.Size = UDim2.new(0, 100, 0, 20)
BuyBtn.Position = UDim2.new(0, 10, 0, 45)
BuyBtn.Text = "Auto Buy: OFF"
BuyBtn.TextColor3 = Color3.new(1,1,1)
BuyBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
BuyBtn.BorderSizePixel = 0
Instance.new("UICorner", BuyBtn)

----------------------------------------------------
-- AFK LABELS
----------------------------------------------------
local function label(name, text, pos)
    local l = Instance.new("TextLabel", content)
    l.Name = name
    l.Text = text
    l.Size = UDim2.new(0, 55, 0, 20)
    l.Position = pos
    l.BackgroundColor3 = Color3.fromRGB(50,50,50)
    l.TextColor3 = Color3.new(1,1,1)
    l.BorderSizePixel = 0
    Instance.new("UICorner", l)
    return l
end

local AntiAfkLbl = label("AFK", "AFK:", UDim2.new(0,10,0,70))
local AfkTimeLabel = label("Time", "0:0:0", UDim2.new(0,55,0,70))

----------------------------------------------------
-- LOGIC
----------------------------------------------------
local autoBuyEnabled = false
local antiAfkEnabled = false
local seconds, minutes, hours = 0, 0, 0

local function updateButton()
    if autoBuyEnabled then
        BuyBtn.Text = "Auto Buy: ON"
        BuyBtn.BackgroundColor3 = Color3.fromRGB(50,180,50)
        diamondGui.Enabled = false
        antiAfkEnabled = true
    else
        BuyBtn.Text = "Auto Buy: OFF"
        BuyBtn.BackgroundColor3 = Color3.fromRGB(180,50,50)
        diamondGui.Enabled = true
        antiAfkEnabled = false
        seconds, minutes, hours = 0, 0, 0
        AfkTimeLabel.Text = "0:0:0"
    end
end

BuyBtn.MouseButton1Click:Connect(function()
    autoBuyEnabled = not autoBuyEnabled
    updateButton()
end)

----------------------------------------------------
-- ANTI AFK
----------------------------------------------------
LocalPlayer.Idled:Connect(function()
    if antiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

----------------------------------------------------
-- AUTO BUY LOOP
----------------------------------------------------
task.spawn(function()
    while true do
        if autoBuyEnabled then
            local remoteIndex = tonumber(remoteBox.Text)
            if remoteIndex then
                Autobuy(selectedBundleValue, remoteIndex)
            end
        end
        task.wait(0.03)
    end
end)

----------------------------------------------------
-- TIMER
----------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1)
        if autoBuyEnabled then
            seconds += 1
            if seconds >= 60 then seconds = 0 minutes += 1 end
            if minutes >= 60 then minutes = 0 hours += 1 end
            AfkTimeLabel.Text = string.format("%d:%d:%d", hours, minutes, seconds)
        end
    end
end)

----------------------------------------------------
-- MINIMIZE / CLOSE
----------------------------------------------------
local minimized = false
local originalSize = frame.Size

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    frame.Size = minimized and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 20) or originalSize
    minimizeBtn.Text = minimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
