local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local PetsFolder = ReplicatedStorage:WaitForChild("__DIRECTORY"):WaitForChild("Pets")

local PetList = {}

for _, folder in ipairs(PetsFolder:GetChildren()) do
    if folder:IsA("Folder") then
        local petDataModule = folder:FindFirstChild("Petdata")
        if petDataModule and petDataModule:IsA("ModuleScript") then
            local success, data = pcall(require, petDataModule)
            if success and typeof(data) == "table" then
                
                local name = data.name or folder.Name
                local thumb = data.thumbnail or ""

                table.insert(PetList, {
                    name,
                    thumb
                })
            end
        end
    end
end

local jsonOutput = HttpService:JSONEncode(PetList)

if writefile then
    writefile("pets.json", jsonOutput)
    print("Saved to pets.json")
end
