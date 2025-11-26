local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

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

local function FindPetIdByName(displayName)
    for petId, petData in pairs(Library.Directory.Pets) do
        if petData.name and petData.name == displayName then
            return petId
        end
    end
    return nil
end

local function GetUIDsFromNames(petsList, petNamesStr)
    local uids = {}
    for petName in string.gmatch(petNamesStr, '([^,]+)') do
        petName = petName:gsub("^%s*(.-)%s*$", "%1") -- trim spaces
        local petId = FindPetIdByName(petName)
        if petId then
            for _, pet in pairs(petsList) do
                if pet.id == petId and pet.uid then
                    table.insert(uids, pet.uid)
                end
            end
        end
    end
    return uids
end

local function DeletePetsByName(petNamesStr, remoteIndex)
    local save = Library.Save.Get()
    if not save or not save.Pets then
        return
    end

    local pets = save.Pets
    if typeof(pets) == "string" then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(pets)
        end)
        if success and decoded then
            pets = decoded
        else
            return
        end
    end

    local uids = GetUIDsFromNames(pets, petNamesStr)
    if #uids > 0 then
        local remote = getRemote(remoteIndex)
        if remote then
            remote:InvokeServer(uids)
        end
    end
end

local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
gui.Name = "Auto Delete"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 120, 0, 105)
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
title.Text = "💀Auto Delete"
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
PetNameBox.PlaceholderText = "Pet Name(s)"
PetNameBox.Text = "Dog, Cat"
PetNameBox.TextSize = 11
PetNameBox.BorderSizePixel = 0

local remoteBox = Instance.new("TextBox", content)
remoteBox.Size = UDim2.new(0, 100, 0, 20)
remoteBox.Position = UDim2.new(0, 10, 0, 20)
remoteBox.PlaceholderText = "Remote Index"
remoteBox.Text = "61"
remoteBox.TextColor3 = Color3.new(1, 1, 1)
remoteBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
local remoteCorner = Instance.new("UICorner")
remoteCorner.CornerRadius = UDim.new(0, 6)
remoteCorner.Parent = remoteBox

local DeleteBtn = Instance.new("TextButton", content)
DeleteBtn.Size = UDim2.new(0, 100, 0, 20)
DeleteBtn.Position = UDim2.new(0, 10, 0, 45)
DeleteBtn.Text = "Delete Pets"
DeleteBtn.TextSize = 11
DeleteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
DeleteBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
DeleteBtn.BorderSizePixel = 0
Instance.new("UICorner", DeleteBtn).CornerRadius = UDim.new(0, 6)

DeleteBtn.MouseButton1Click:Connect(function()
    local petNames = PetNameBox.Text
    local remoteIndex = tonumber(remoteBox.Text)
    if petNames and petNames ~= "" and remoteIndex then
        DeletePetsByName(petNames, remoteIndex)
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
