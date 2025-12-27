local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local defaultListLink = {
    {
        name = "Auto Buy Gems",
        code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Shion077/BoogyManV2/refs/heads/main/PSXG/PSXG_Auto_Buy_Gems.lua"))()'
    },
    {
        name = "Auto Hatch",
        code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Shion077/BoogyManV2/refs/heads/main/PSXG/PSXG_Auto_Hatch.lua"))()'
    },
    {
        name = "Auto Combine",
        code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Shion077/BoogyManV2/refs/heads/main/PSXG/PSXG_Auto_Combine.lua"))()'
    },
    {
        name = "Remote Spy V1",
        code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Shion077/BoogyManV2/refs/heads/main/PSXR/PSXR_Remote_Spy_V1.lua"))()'
    },
    {
        name = "Remote Spy V2",
        code = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/Shion077/BoogyManV2/refs/heads/main/PSXR/PSXR_Remote_Spy_V2.lua"))()'
    }

}

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "BoogyManV2 Menu"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

local baseHeight = 30
local buttonIncrement = 25
local totalButtons = #defaultListLink
local frameHeight = baseHeight + (totalButtons * buttonIncrement)

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 120, 0, frameHeight)
frame.Position = UDim2.new(0.5, -160, 0.5, -135)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = frame

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 20)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
header.BorderSizePixel = 0
header.Parent = frame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Text = "💀BoogyManV2"
title.Font = Enum.Font.GothamBold
title.TextSize = 10
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Size = UDim2.new(0, 15, 0, 15)
closeBtn.Position = UDim2.new(0, 100, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.Size = UDim2.new(0, 15, 0, 15)
minimizeBtn.Position = UDim2.new(0, 82, 0, 2)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(1, 0)
minimizeCorner.Parent = minimizeBtn

local content = Instance.new("Frame")
content.Name = "Content"
content.Position = UDim2.new(0, 0, 0, 30)
content.Size = UDim2.new(1, 0, 1, -30)
content.BackgroundTransparency = 1
content.Parent = frame

local startY = -5
local increment = 25

for i, info in ipairs(defaultListLink) do
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(0, 100, 0, 20)
    btn.Position = UDim2.new(0, 10, 0, startY + (i-1) * increment)
    btn.Text = info.name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 15
    btn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)

    btn.MouseButton1Click:Connect(function()
        loadstring(info.code)()
    end)
end

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
