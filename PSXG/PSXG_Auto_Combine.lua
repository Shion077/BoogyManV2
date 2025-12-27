--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

--// PLAYER
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// LIBRARY
local Library = require(ReplicatedStorage:WaitForChild("Library"))
local diamondGui = PlayerGui:WaitForChild("Diamonds Animation")

----------------------------------------------------
-- CONFIG
----------------------------------------------------
local GUI_NAME = "AutoGUI"
local DEFAULT_GEM_REMOTE = "32"
local DEFAULT_HUGE_REMOTE = "24"
local DEFAULT_TITANIC_REMOTE = "41"
local DEFAULT_OPENEGG_REMOTE = "100"

local COLORS = {
	bg = Color3.fromRGB(30,30,30),
	header = Color3.fromRGB(20,20,20),
	dark = Color3.fromRGB(40,40,40),
	darker = Color3.fromRGB(35,35,35),
	red = Color3.fromRGB(180,50,50),
	green = Color3.fromRGB(50,180,50),
	text = Color3.new(1,1,1)
}

-- POINT SYSTEM (UPDATED)
local function calculatePetPoints(pet)
	-- base
	local points = 1

	local g = pet.g == true
	local r = pet.r == true
	local sh = pet.sh == true

	if g and sh then return 5 end
	if r and sh then return 6 end
	if sh then return 4 end
	if r then return 3 end
	if g then return 2 end

	return points
end

-- IDS
local HUGE_IDS = { "515" }
local TITANIC_IDS = { "2078", "2097", "2098", "2096", "2108" }

local HUGE_EGG_ID = "1027"
local TITANIC_EGG_ID = "1078"

local MIN_POINTS = 50

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

----------------------------------------------------
-- SAVE ACCESS
----------------------------------------------------
local function getInventoryPets()
	local ok, Save = pcall(function()
		return require(ReplicatedStorage.Library.Client:WaitForChild("Save"))
	end)
	if not ok then return {} end

	local data = Save.Get(LocalPlayer)
	return data and data.Pets or {}
end

----------------------------------------------------
-- OPEN EGG
----------------------------------------------------
local function openEggs(eggId, remoteIndex)
	local pets = getInventoryPets()
	local remote = getRemote(remoteIndex)
	if not remote then return end

	for _, pet in pairs(pets) do
		if tostring(pet.id) == tostring(eggId) then
			remote:InvokeServer(pet.uid, 1, 0)
		end
	end
end

----------------------------------------------------
-- COMBINE LOGIC (RUNS EVERY LOOP)
----------------------------------------------------
local function combinePets(targetIds, remoteIndex)
	local pets = getInventoryPets()
	local remote = getRemote(remoteIndex)
	if not remote then return end

	local arg = {}
	local totalPoints = 0

	table.sort(pets, function(a, b)
		return calculatePetPoints(a) > calculatePetPoints(b)
	end)

	for _, pet in ipairs(pets) do
		if table.find(targetIds, tostring(pet.id)) then
			local pts = calculatePetPoints(pet)
			if totalPoints < MIN_POINTS then
				table.insert(arg, pet.uid)
				totalPoints += pts
			end
		end
	end

	if totalPoints >= MIN_POINTS and #arg > 0 then
		remote:InvokeServer(arg)
	end
end

----------------------------------------------------
-- GUI CREATION (unchanged)
----------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.Parent = PlayerGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,150,0,240)
frame.Position = UDim2.new(0.5,-160,0.5,-140)
frame.BackgroundColor3 = COLORS.bg
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1,0,0,20)
header.BackgroundColor3 = COLORS.header
Instance.new("UICorner", header)

local title = Instance.new("TextLabel", header)
title.Text = "⚡ Auto AFK + Combine"
title.Size = UDim2.new(1,-60,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.TextColor3 = COLORS.text
title.Font = Enum.Font.GothamBold
title.TextSize = 10
title.TextXAlignment = Enum.TextXAlignment.Left

local function headerButton(text, pos, color)
	local b = Instance.new("TextButton", header)
	b.Text = text
	b.Size = UDim2.new(0,15,0,15)
	b.Position = pos
	b.BackgroundColor3 = color
	b.TextColor3 = COLORS.text
	Instance.new("UICorner", b)
	return b
end

local minimizeBtn = headerButton("-", UDim2.new(0,105,0,2), Color3.fromRGB(70,70,70))
local closeBtn = headerButton("X", UDim2.new(0,125,0,2), COLORS.red)

local content = Instance.new("Frame", frame)
content.Position = UDim2.new(0,0,0,30)
content.Size = UDim2.new(1,0,1,-30)
content.BackgroundTransparency = 1

----------------------------------------------------
-- DROPDOWN (DIAMOND BUNDLES)
----------------------------------------------------
local bundleOptions = {
	{ name = "100K", value = "Tiny Diamonds" },
	{ name = "300K", value = "Medium Diamonds" },
	{ name = "2.5M", value = "Large Diamonds" },
	{ name = "25M", value = "Massive Diamonds" },
}

local selectedBundleValue = bundleOptions[1].value
local dropdownOpen = false

local bundleDropdown = Instance.new("TextButton", content)
bundleDropdown.Size = UDim2.new(0, 120, 0, 20)
bundleDropdown.Position = UDim2.new(0, 10, 0, 0)
bundleDropdown.Text = bundleOptions[1].name .. " ▼"
bundleDropdown.TextColor3 = COLORS.text
bundleDropdown.BackgroundColor3 = COLORS.dark
bundleDropdown.BorderSizePixel = 0
Instance.new("UICorner", bundleDropdown)

local dropdownFrame = Instance.new("Frame", content)
dropdownFrame.Position = UDim2.new(0, 10, 0, 20)
dropdownFrame.Size = UDim2.new(0, 120, 0, 0)
dropdownFrame.BackgroundColor3 = COLORS.darker
dropdownFrame.Visible = false
dropdownFrame.ClipsDescendants = true
Instance.new("UICorner", dropdownFrame)

bundleDropdown.MouseButton1Click:Connect(function()
	dropdownOpen = not dropdownOpen
	dropdownFrame.Visible = dropdownOpen
	dropdownFrame.Size = dropdownOpen
		and UDim2.new(0, 120, 0, #bundleOptions * 22)
		or UDim2.new(0, 120, 0, 0)
end)

for i, option in ipairs(bundleOptions) do
	local btn = Instance.new("TextButton")
	btn.Parent = dropdownFrame
	btn.Size = UDim2.new(1, 0, 0, 22)
	btn.Position = UDim2.new(0, 0, 0, (i - 1) * 22)
	btn.Text = option.name
	btn.TextColor3 = COLORS.text
	btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
	btn.BorderSizePixel = 0

	btn.MouseButton1Click:Connect(function()
		selectedBundleValue = option.value
		bundleDropdown.Text = option.name .. " ▼"
		dropdownOpen = false
		dropdownFrame.Visible = false
	end)
end


local function createField(parent, text, y, w)
	local label = Instance.new("TextLabel", parent)
	label.Text = text
	label.Position = UDim2.new(0,10,0,y)
	label.Size = UDim2.new(0,55,0,20)
	label.BackgroundTransparency = 1
	label.TextColor3 = COLORS.text
	label.TextXAlignment = Enum.TextXAlignment.Left

	local box = Instance.new("TextBox", parent)
	box.Position = UDim2.new(0,65,0,y)
	box.Size = UDim2.new(0,w,0,20)
	box.BackgroundColor3 = Color3.fromRGB(50,50,50)
	box.TextColor3 = COLORS.text
	box.BorderSizePixel = 0
	Instance.new("UICorner", box)

	return label, box
end

-- Inputs
local gemLabel, gemRemoteBox = createField(content,"Diamonds:",25,70)
gemRemoteBox.Text = DEFAULT_GEM_REMOTE

----------------------------------------------------
-- COMBINE SECTION LABEL
----------------------------------------------------
local combineLabel = Instance.new("TextLabel", content)
combineLabel.Text = "Combine Section"
combineLabel.Position = UDim2.new(0, 10, 0, 50)
combineLabel.Size = UDim2.new(1, -20, 0, 18)
combineLabel.TextColor3 = COLORS.text
combineLabel.BackgroundTransparency = 1
combineLabel.Font = Enum.Font.GothamBold
combineLabel.TextXAlignment = Enum.TextXAlignment.Left

local hugeLabel, hugeRemoteBox = createField(content,"Huge:",70,70)
hugeRemoteBox.Text = DEFAULT_HUGE_REMOTE
local ctLabel, ctRemoteBox = createField(content,"Titanic:",95,70)
ctRemoteBox.Text = DEFAULT_TITANIC_REMOTE
local openLabel, openRemoteBox= createField(content,"Open Egg:",120,70)
openRemoteBox.Text = DEFAULT_OPENEGG_REMOTE

-- AFK timer
local afkLabel, afkTimeLabel = createField(content,"AFK:",145,70)
afkTimeLabel.Text = "0:0:0"
afkTimeLabel.TextEditable = false

-- Start Button
local startButton = Instance.new("TextButton", content)
startButton.Size = UDim2.new(0,120,0,24)
startButton.Position = UDim2.new(0,10,0,170)
startButton.Text = "Start"
startButton.TextColor3 = COLORS.text
startButton.BackgroundColor3 = COLORS.red
Instance.new("UICorner", startButton)

----------------------------------------------------
-- STATE
----------------------------------------------------
local autoBuyEnabled = false
local antiAfkEnabled = false
local seconds, minutes, hours = 0,0,0

----------------------------------------------------
-- START / STOP
----------------------------------------------------
startButton.MouseButton1Click:Connect(function()
	autoBuyEnabled = not autoBuyEnabled
	if autoBuyEnabled then
		startButton.Text = "Stop"
		startButton.BackgroundColor3 = COLORS.green
		diamondGui.Enabled = false
		antiAfkEnabled = true
	else
		startButton.Text = "Start"
		startButton.BackgroundColor3 = COLORS.red
		diamondGui.Enabled = true
		antiAfkEnabled = false
		seconds, minutes, hours = 0,0,0
		afkTimeLabel.Text = "0:0:0"
	end
end)

----------------------------------------------------
-- GEM LOOP (FAST)
----------------------------------------------------
task.spawn(function()
	while true do
		if autoBuyEnabled then
			local gemIndex = tonumber(gemRemoteBox.Text)
			if gemIndex then
				local remote = getRemote(gemIndex)
				if remote then
					remote:InvokeServer(selectedBundleValue)
				end
			end
		end
		task.wait(0.03)
	end
end)

----------------------------------------------------
-- COMBINE + OPEN LOOP (SLOW)
----------------------------------------------------
task.spawn(function()
	while true do
		if autoBuyEnabled then
			local openIndex = tonumber(openRemoteBox.Text)
			local hugeIndex = tonumber(hugeRemoteBox.Text)
			local ctIndex = tonumber(ctRemoteBox.Text)

			if hugeIndex then
				combinePets(HUGE_IDS, hugeIndex)
				if openIndex then
					openEggs(HUGE_EGG_ID, openIndex)
				end
			end

			if ctIndex then
				combinePets(TITANIC_IDS, ctIndex)
				if openIndex then
					openEggs(TITANIC_EGG_ID, openIndex)
				end
			end
		end
		task.wait(0.05)
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
			afkTimeLabel.Text = string.format("%d:%d:%d", hours, minutes, seconds)
		end
	end
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
