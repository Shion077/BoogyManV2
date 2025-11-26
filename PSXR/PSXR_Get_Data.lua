local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local PetsFolder = ReplicatedStorage.__DIRECTORY.Pets

local PetList = {}
local keywords = {"titanic","huge","gargantuan"}

local function matchesFilter(petName)
    local lower = string.lower(petName)
    for _, word in ipairs(keywords) do
        if string.find(lower, word) then
            return true
        end
    end
    return false
end

for _, folder in ipairs(PetsFolder:GetChildren()) do
    if folder:IsA("Folder") then
        local petDataModule = folder:FindFirstChild("Petdata")
        if petDataModule and petDataModule:IsA("ModuleScript") then
            local ok, data = pcall(require, petDataModule)
            if ok and typeof(data) == "table" then
                local name = data.name or folder.Name
                if matchesFilter(name) then
                    local thumb = data.thumbnail or ""
                    table.insert(PetList, {name, thumb})
                end
            end
        end
    end
end

local jsonOutput = HttpService:JSONEncode(PetList)

if writefile then
    writefile("pets.json", jsonOutput)
end

print("Saved Finish")
