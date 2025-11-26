local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local PetsFolder = ReplicatedStorage.__DIRECTORY.Pets
local PetList = {}
local keywords = {"titanic","huge","gargantuan"}

local function matchesFilter(n)
    n = string.lower(n)
    for _, w in ipairs(keywords) do
        if string.find(n, w) then return true end
    end
end

for _, f in ipairs(PetsFolder:GetChildren()) do
    local mod = f:FindFirstChildWhichIsA("ModuleScript")
    if mod then
        local data
        for i = 1, 20 do
            local ok, d = pcall(require, mod)
            if ok and typeof(d) == "table" and d.name and d.thumbnail then
                data = d
                break
            end
            task.wait(0.05)
        end
        if data and matchesFilter(data.name) then
            table.insert(PetList, {data.name, data.thumbnail})
        end
    end
end

local json = HttpService:JSONEncode(PetList)
if writefile then writefile("pets.json", json) end
print("Finished saving file.")
