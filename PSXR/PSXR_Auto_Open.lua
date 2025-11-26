local Players = game:GetService("Players")
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

local function AutoOpenEgg(name, openEggRemote)
	name = name:lower()
	local save = Library.Save.Get()
	if not save or not save.Pets then 
		return 
	end

	local uids = {}
	for _, pet in ipairs(save.Pets) do
		local petData = Library.Directory.Pets[pet.id]
		local pname = petData and petData.name:lower() or pet.id:lower()
		if pname == name then
			table.insert(uids, pet.uid)
		end
	end

	if #uids == 0 then
		return
	end

	local selected = {}
	for i = 1, math.min(8, #uids) do
		table.insert(selected, uids[i])
	end

	if openEggRemote then
		openEggRemote:InvokeServer(selected[1], #selected)
	end
end

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "Auto Open"
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
header.Size = UDim2.new(1, 0, 0, 20)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Text = "💀Auto Open"
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
content.Position = UDim2.new(0, 0, 0, 30)
content.Size = UDim2.new(1, 0, 1, -30)
content.BackgroundTransparency = 1

local eggNameBox = Instance.new("TextBox", content)
eggNameBox.Size = UDim2.new(0, 100, 0, 20)
eggNameBox.Position = UDim2.new(0, 10, 0, -5)
eggNameBox.PlaceholderText = "Enter Egg Name"
eggNameBox.Text = "Exclusive Axolotl Egg"
eggNameBox.TextColor3 = Color3.new(1, 1, 1)
eggNameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", eggNameBox).CornerRadius = UDim.new(0, 6)

local remoteBox = Instance.new("TextBox", content)
remoteBox.Size = UDim2.new(0, 100, 0, 20)
remoteBox.Position = UDim2.new(0, 10, 0, 20)
remoteBox.PlaceholderText = "Remote Index"
remoteBox.TextColor3 = Color3.new(1, 1, 1)
remoteBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", remoteBox).CornerRadius = UDim.new(0, 6)

local statusLabel = Instance.new("TextLabel", content)
statusLabel.Size = UDim2.new(0, 100, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 45)
statusLabel.Text = "STATUS : OFF"
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local SwitchBtn = Instance.new("TextButton", content)
SwitchBtn.Size = UDim2.new(0, 100, 0, 20)
SwitchBtn.Position = UDim2.new(0, 10, 0, 70)
SwitchBtn.Font = Enum.Font.GothamBold
SwitchBtn.TextSize = 14
SwitchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", SwitchBtn).CornerRadius = UDim.new(0, 6)

local autoRunning = false

local function updateButtonUI()
	if autoRunning then
		SwitchBtn.Text = "Stop"
		statusLabel.Text = "STATUS : ON"
		SwitchBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	else
		SwitchBtn.Text = "Start"
		statusLabel.Text = "STATUS : OFF"
		SwitchBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
	end
end
updateButtonUI()

SwitchBtn.MouseButton1Click:Connect(function()
	autoRunning = not autoRunning
	updateButtonUI()

	if autoRunning then
		local remoteIndex = tonumber(remoteBox.Text)
		local openEggRemote = getRemote(remoteIndex)

		task.spawn(function()
			while autoRunning do
				local eggName = eggNameBox.Text
				AutoOpenEgg(eggName, openEggRemote)
				task.wait(0.1)
			end
		end)
	end
end)

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

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
