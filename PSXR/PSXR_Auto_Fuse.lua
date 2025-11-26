local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Library = require(ReplicatedStorage:WaitForChild("Library"))

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

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "PetFuse"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 120, 0, 130)
frame.Position = UDim2.new(0.5, -160, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local header = Instance.new("Frame", frame)
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 20)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Text = "ðŸ’€Pet Fuse"
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

local content = Instance.new("Frame", frame)
content.Name = "Content"
content.Position = UDim2.new(0, 0, 0, 30)
content.Size = UDim2.new(1, 0, 1, -30)
content.BackgroundTransparency = 1

local PetNameBox = Instance.new("TextBox", content)
PetNameBox.Size = UDim2.new(0, 100, 0, 20)
PetNameBox.Position = UDim2.new(0, 10, 0, -5)
PetNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PetNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PetNameBox.PlaceholderText = "Pet Name"
PetNameBox.Text = "Dog"
PetNameBox.TextSize = 11
PetNameBox.BorderSizePixel = 0

local GoldBox = Instance.new("TextBox", content)
GoldBox.Size = UDim2.new(0, 100, 0, 20)
GoldBox.Position = UDim2.new(0, 10, 0, 20)
GoldBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
GoldBox.TextColor3 = Color3.fromRGB(255, 255, 255)
GoldBox.PlaceholderText = "Gold Machine Remote"
GoldBox.Text = ""
GoldBox.TextSize = 11
GoldBox.BorderSizePixel = 0

local RainbowBox = Instance.new("TextBox", content)
RainbowBox.Size = UDim2.new(0, 100, 0, 20)
RainbowBox.Position = UDim2.new(0, 10, 0, 45)
RainbowBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
RainbowBox.TextColor3 = Color3.fromRGB(255, 255, 255)
RainbowBox.PlaceholderText = "Rainbow Machine Remote"
RainbowBox.Text = ""
RainbowBox.TextSize = 11
RainbowBox.BorderSizePixel = 0

local SwitchFuseBtn = Instance.new("TextButton", content)
SwitchFuseBtn.Size = UDim2.new(0, 100, 0, 20)
SwitchFuseBtn.Position = UDim2.new(0, 10, 0, 70)
SwitchFuseBtn.TextSize = 11
SwitchFuseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SwitchFuseBtn.BorderSizePixel = 0
Instance.new("UICorner", SwitchFuseBtn).CornerRadius = UDim.new(0, 6)

local autoRunning = false

local function updateButtonUI()
    if autoRunning then
        SwitchFuseBtn.Text = "Off Fuse"
        SwitchFuseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    else
        SwitchFuseBtn.Text = "On Fuse"
        SwitchFuseBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    end
end
updateButtonUI()

local function GetPetNameById(id)
    local petData = Library.Directory.Pets[id]
    return petData and petData.name or tostring(id)
end

local function CollectPetsByType(name)
    local save = Library.Save.Get()
    if not save or not save.Pets then return {}, {}, {} end
    local normal, gold, rainbow = {}, {}, {}

    for _, pet in ipairs(save.Pets) do
        if GetPetNameById(pet.id) == name then
            if pet.r then table.insert(rainbow, pet.uid)
            elseif pet.g then table.insert(gold, pet.uid)
            else table.insert(normal, pet.uid) end
        end
    end

    return normal, gold, rainbow
end

local function station1(name)
    local _, gold, _ = CollectPetsByType(name)

    local remoteIndex = tonumber(RainbowBox.Text)
    if not remoteIndex then return end

    local FuseToRainbow = getRemote(remoteIndex)
    if not FuseToRainbow then return end

    if #gold >= 6 then
        local batch = {unpack(gold, 1, 6)}
        pcall(function()
            FuseToRainbow:InvokeServer({unpack(batch)})
        end)
    end
end

local function station2(name)
    local normal, _, _ = CollectPetsByType(name)

    local remoteIndex = tonumber(GoldBox.Text)
    if not remoteIndex then return end

    local FuseToGold = getRemote(remoteIndex)
    if not FuseToGold then return end

    if #normal >= 6 then
        local batch = {unpack(normal, 1, 6)}
        pcall(function()
            FuseToGold:InvokeServer({unpack(batch)})
        end)
    end
end

local function runLoop(name)
    while autoRunning do
        station1(name)
        station2(name)
        task.wait(0.1)
    end
end

local fuseThread = nil
SwitchFuseBtn.MouseButton1Click:Connect(function()
    local petName = PetNameBox.Text
    if petName == "" then return warn("Enter a pet name.") end
    autoRunning = not autoRunning
    updateButtonUI()

    if autoRunning then
        if not fuseThread or coroutine.status(fuseThread) == "dead" then
            fuseThread = coroutine.create(function()
                runLoop(petName)
            end)
            coroutine.resume(fuseThread)
        end
    end
end)

local originalSize = frame.Size
minimizeBtn.MouseButton1Click:Connect(function()
    content.Visible = not content.Visible
    frame.Size = content.Visible and originalSize or UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, header.Size.Y.Offset)
    minimizeBtn.Text = content.Visible and "-" or "+"
end)

closeBtn.MouseButton1Click:Connect(function()
    autoRunning = false
    gui:Destroy()
end)
