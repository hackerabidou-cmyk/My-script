-- [[ 4H+ Server Hopper & Chest Farmer ]] --
repeat wait() until game:IsLoaded()

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Player = game.Players.LocalPlayer

-- Settings
local REQUIRED_AGE = 4 * 3600 -- 4 hours in seconds
local serverAge = workspace.DistributedGameTime

-- Function to Hop Servers
local function hop()
    local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(sfUrl))
    end)
    
    if success and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                return
            end
        end
    end
    task.wait(2)
    hop()
end

-- 1. Check Server Age
if serverAge < REQUIRED_AGE then
    print("Server too young (" .. math.floor(serverAge/3600) .. "h). Hopping...")
    hop()
    return
end

print("Old Server Found! (" .. math.floor(serverAge/3600) .. "h). Starting Chest Farm...")

-- 2. Chest Farming Logic
spawn(function()
    while task.wait(0.5) do
        for _, v in pairs(game.Workspace:GetChildren()) do
            -- Look for Chests (Chest1, Chest2, Chest3)
            if v.name:find("Chest") and v:IsA("BasePart") then
                -- Teleport to chest
                Player.Character.HumanoidRootPart.CFrame = v.CFrame
                task.wait(0.2)
                -- If we get the Fist, stop farming
                if Player.Backpack:FindFirstChild("Fist of Darkness") or Player.Character:FindFirstChild("Fist of Darkness") then
                    print("!!! FIST OF DARKNESS OBTAINED !!!")
                    return
                end
            end
        end
    end
end)
