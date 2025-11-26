-- =========================
-- 📦 Wait until game and player are ready
-- =========================
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer and game.Players.LocalPlayer.Character

-- =========================
-- 📦 SERVICES & GLOBALS
-- =========================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- =========================
-- 🖼 GUI SETUP
-- =========================
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "PSX Spy"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 120, 0, 80)
frame.Position = UDim2.new(0.5, -160, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local header = Instance.new("Frame", frame)
header.Size = UDim2.new(1, 0, 0, 20)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
header.BorderSizePixel = 0
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", header)
title.Text = "💀Remote Spy V1"
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

-- Label + Button Helpers
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
	lbl.BorderSizePixel = 0
	return lbl
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
	btn.BorderSizePixel = 0
	return btn
end

local Status1Lbl = createLabel("Status1Lbl", "STATUS :", UDim2.new(0, 5, 0, -5), 52.5, 20, Color3.fromRGB(50, 50, 50))
local StatusLbl = createLabel("StatusLbl", "Inactive", UDim2.new(0, 62, 0, -5), 52.5, 20, Color3.fromRGB(30, 30, 30), Color3.fromRGB(255, 50, 50))
local SwitchBtn = createButton("SwitchBtn", "Turn On", UDim2.new(0, 5, 0, 20), 110, 20, Color3.fromRGB(40, 120, 40))

-- =========================
-- 🔘 STATUS SYSTEM
-- =========================
local active = false
local oldNamecall

local function setStatus(state)
	active = state
	if active then
		StatusLbl.Text = "Active"
		StatusLbl.TextColor3 = Color3.fromRGB(50, 255, 50)
		SwitchBtn.Text = "Turn Off"
		SwitchBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	else
		StatusLbl.Text = "Inactive"
		StatusLbl.TextColor3 = Color3.fromRGB(255, 50, 50)
		SwitchBtn.Text = "Turn On"
		SwitchBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
	end
end

-- =========================
-- 🧠 SPY FUNCTION (safe)
-- =========================
local function activateSpy()
	local remoteFunctions = {}
	local indexMap = {}
	local count = 0

	for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
		if obj:IsA("RemoteFunction") then
			count += 1
			remoteFunctions[obj] = true
			indexMap[obj] = count
			warn("Tracking RemoteFunction #" .. count .. ": " .. obj.Name)
		end
	end

	local function printTable(t, indent)
		indent = indent or 0
		local prefix = string.rep("   ", indent)
		for k, v in pairs(t) do
			if typeof(v) == "table" then
				print(prefix .. tostring(k) .. " = {")
				printTable(v, indent + 1)
				print(prefix .. "}")
			else
				print(prefix .. tostring(k) .. " = " .. tostring(v))
			end
		end
	end

	local mt = getrawmetatable(game)
	oldNamecall = oldNamecall or mt.__namecall
	setreadonly(mt, false)

	mt.__namecall = newcclosure(function(self, ...)
		local method = getnamecallmethod()
		local args = {...}
		if remoteFunctions[self] and (method == "InvokeServer") then
			local index = indexMap[self] or "?"
			warn("[SPY] RemoteFunction #" .. index .. " called:", self.Name)
			for i, v in ipairs(args) do
				if typeof(v) == "table" then
					print(" Arg[" .. i .. "] = {")
					printTable(v, 1)
					print(" }")
				else
					print(" Arg[" .. i .. "] = " .. tostring(v))
				end
			end
		end
		return oldNamecall(self, ...)
	end)

	setreadonly(mt, true)
	print("✅ Spy is now active on ALL RemoteFunctions in ReplicatedStorage!")
end

local function deactivateSpy()
	if oldNamecall then
		local mt = getrawmetatable(game)
		setreadonly(mt, false)
		mt.__namecall = oldNamecall
		setreadonly(mt, true)
		print("🛑 Spy disabled.")
	end
end

-- =========================
-- 🎛 BUTTON CONTROL
-- =========================
SwitchBtn.MouseButton1Click:Connect(function()
	if active then
		deactivateSpy()
		setStatus(false)
	else
		activateSpy()
		setStatus(true)
	end
end)

-- =========================
-- 🔲 FRAME CONTROL
-- =========================
local isMinimized = false
local originalSize = frame.Size
minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	content.Visible = not isMinimized
	frame.Size = isMinimized and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, header.Size.Y.Offset) or originalSize
	minimizeBtn.Text = isMinimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
