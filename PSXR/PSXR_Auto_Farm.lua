local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local VirtualUser = game:GetService("VirtualUser")

local Library = require(ReplicatedStorage:WaitForChild("Framework"):WaitForChild("Library"))

local function getRemoteFunction(int)
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

local function getRemoteEvent(int)
    local count = 0
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") then
            count += 1
            if count == int then
                return obj
            end
        end
    end
    return nil
end

local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "AutoFarmUI"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 120, 0, 180)
frame.Position = UDim2.new(0.5, -60, 0.5, -90)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

-- Header
local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 20)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Text = "⚡Auto Farm + AFK"
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
content.Position = UDim2.new(0, 0, 0, 30)
content.Size = UDim2.new(1, 0, 1, -30)
content.BackgroundTransparency = 1

local function createLabel(name, text, pos, w, h, bgColor, textColor)
	local lbl = Instance.new("TextLabel", content)
	lbl.Name = name
	lbl.Size = UDim2.new(0, w or 52.5, 0, h or 20)
	lbl.Position = pos
	lbl.BackgroundColor3 = bgColor or Color3.fromRGB(40, 40, 40)
	lbl.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
	lbl.Text = text or ""
	lbl.TextSize = 12
	lbl.Font = Enum.Font.SourceSansBold
	return lbl
end

local function createTextBox(name, placeholder, text, pos, w, h)
	local box = Instance.new("TextBox", content)
	box.Name = name
	box.Size = UDim2.new(0, w or 52.5, 0, h or 20)
	box.Position = pos
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.PlaceholderText = placeholder or ""
	box.Text = text or ""
	box.TextSize = 12
	box.Font = Enum.Font.SourceSansBold
	box.BorderSizePixel = 0
	return box
end

local function createButton(name, text, pos, w, h, bgColor)
	local btn = Instance.new("TextButton", content)
	btn.Name = name
	btn.Size = UDim2.new(0, w or 110, 0, h or 20)
	btn.Position = pos
	btn.BackgroundColor3 = bgColor or Color3.fromRGB(40, 120, 40)
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 12
	btn.Text = text
	return btn
end

local AreaBox = createTextBox("AreaBox", "Farm Area", "Hacker Portal", UDim2.new(0,10,0,-5), 100, 20)
local remoteBox = createTextBox("RemoteBox", "R - Function", "7", UDim2.new(0,10,0,20), 100, 20)
local event1Box = createTextBox("Event1Box", "R - Event1", "26", UDim2.new(0,10,0,45), 100, 20)
local event2Box = createTextBox("Event2Box", "R - Event2", "7", UDim2.new(0,10,0,70), 100, 20)
local AutoBtn = createButton("AutoBtn", "Farm: Turn On", UDim2.new(0,10,0,95), 100, 20, Color3.fromRGB(180,50,50))

local AntiAfkLbl   = createLabel("AntiAfkLbl", "AFK:Time", UDim2.new(0,5,0,120), 52.5, 20, Color3.fromRGB(50,50,50))
local AfkTimeLabel = createLabel("AfkTimeLabel", "0:0:0", UDim2.new(0,62,0,120), 52.5, 20, Color3.fromRGB(50,50,50))

local autoFarmEnabled = false
local antiAfkEnabled = false
local seconds, minutes, hours = 0, 0, 0
local timerRunning = false

local function getCoins(area)
    local coinsFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Coins")
    local coins = {}
    for _, coin in ipairs(coinsFolder:GetChildren()) do
        if coin:GetAttribute("Area") == area then
            table.insert(coins, coin)
        end
    end
    return coins
end

local function getPets()
    local petsFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Pets")
    local pets = {}
    for _, pet in ipairs(petsFolder:GetChildren()) do
        table.insert(pets, pet.Name)
    end
    return pets
end

local function assignPetsToCoins(area)
    local coins = getCoins(area)
    local pets = getPets()
    local map = {}
    for i = 1, math.min(#coins, #pets) do
        map[coins[i]] = pets[i]
    end
    return map
end

task.spawn(function()
    while task.wait(0.10) do
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local pos = hrp.CFrame

        for _, lootbag in ipairs(Workspace["__THINGS"].Lootbags:GetChildren()) do
            if lootbag:IsA("BasePart") then
                lootbag.CFrame = pos
            end
        end
        for _, orb in ipairs(Workspace["__THINGS"].Orbs:GetChildren()) do
            if orb:IsA("BasePart") then
                orb.CFrame = pos
            end
        end
    end
end)

AutoBtn.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled

    AutoBtn.Text = autoFarmEnabled and "Farm: Turn Off" or "Farm: Turn On"
    AutoBtn.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(50,180,50) or Color3.fromRGB(180,50,50)

    antiAfkEnabled = autoFarmEnabled
    timerRunning = autoFarmEnabled
    if not autoFarmEnabled then
        seconds, minutes, hours = 0, 0, 0
        AfkTimeLabel.Text = "0:0:0"
    end

    if autoFarmEnabled then
        spawn(function()
            local rfIndex = tonumber(remoteBox.Text)
            local re1Index = tonumber(event1Box.Text)
            local re2Index = tonumber(event2Box.Text)

            local remoteF = getRemoteFunction(rfIndex)
            local event1 = getRemoteEvent(re1Index)
            local event2 = getRemoteEvent(re2Index)

            if not remoteF or not event1 or not event2 then
                warn("Invalid remote index")
                return
            end

            while autoFarmEnabled do
                local assignments = assignPetsToCoins(AreaBox.Text)

                for coin, petUID in pairs(assignments) do
                    local coinID = coin.Name
                    pcall(function() remoteF:InvokeServer(coinID, {petUID}) end)
                    pcall(function() event1:FireServer(petUID, "Coin", coinID) end)
                    pcall(function() event2:FireServer(coinID, petUID) end)
                end

                task.wait(0.25)
            end
        end)
    end
end)

LocalPlayer.Idled:Connect(function()
    if antiAfkEnabled then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

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

local isMinimized = false
local originalSize = frame.Size

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    content.Visible = not isMinimized
    frame.Size = isMinimized and UDim2.new(0,120,0,20) or originalSize
    minimizeBtn.Text = isMinimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
