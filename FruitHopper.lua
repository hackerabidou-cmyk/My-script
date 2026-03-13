-- SERVICES
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- CONFIGURATION: Your Specific List
local WantedFruits = {
    ["Dragon East"] = true, ["Dragon West"] = true,
    ["Kitsune"] = true,     ["Yeti"] = true,
    ["Control"] = true,     ["Gas"] = true,
    ["Dough"] = true,       ["T-Rex"] = true,
    ["Lightning"] = true,   ["Blizzard"] = true,
    ["Pain"] = true,        ["Buddha"] = true,
    ["Portal"] = true
}

local LocalPlayer = Players.LocalPlayer

-- FUNCTION: Smooth Movement (Anti-Cheat Bypass)
local function travelTo(targetCFrame)
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local info = TweenInfo.new(distance / 300, Enum.EasingStyle.Linear) -- Constant speed
    
    local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- FUNCTION: Store the Fruit
local function storeFruit(fruitTool)
    -- This fires the game's internal 'Store' command
    -- Path: ReplicatedStorage -> Remotes -> CommF_
    local storeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
    storeRemote:InvokeServer("StoreFruit", fruitTool.Name, fruitTool)
end

-- MAIN LOGIC
local function scanAndCollect()
    for _, item in pairs(game.Workspace:GetChildren()) do
        -- Check if it's a Fruit Tool or a Fruit Model with a Handle
        if item:IsA("Tool") and (item.Name:find("Fruit") or item:FindFirstChild("Handle")) then
            local cleanName = item.Name:gsub(" Fruit", "")
            
            if WantedFruits[cleanName] then
                print("Target Located: " .. cleanName)
                travelTo(item.Handle.CFrame)
                task.wait(0.5) -- Small delay to ensure pickup
                storeFruit(item)
                task.wait(1)
            end
        end
    end
end

-- SERVER HOPPER
local function serverHop()
    print("No fruits found. Hopping to a new server...")
    local PlaceId = game.PlaceId
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    
    for _, server in pairs(servers) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(PlaceId, server.id)
            break
        end
    end
end

-- EXECUTION
scanAndCollect()
task.wait(2)
serverHop()
