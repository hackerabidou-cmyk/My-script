-- [[ 2026 DEFINITIVE ELITE SNIPER ]] --

-- 1. Updated 2026 Whitelist
local TargetFruits = {
    -- The New Kings
    "Dragon East", "Dragon West", "Kitsune", "Gas", "Yeti", "Tiger",
    
    -- Mythicals & Reworks
    "Dough", "Spirit", "Control", "Gravity", "Mammoth", "T-Rex",
    
    -- High-Value Legendaries
    "Buddha", "Portal", "Blizzard", "Lightning", "Pain",
}

-- Settings
getgenv().TweenSpeed = 220
local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- Logic to check if the fruit name matches our 2026 list
local function isValuable(name)
    local lowerName = name:lower()
    for _, eliteName in pairs(TargetFruits) do
        if lowerName:find(eliteName:lower()) then
            return true
        end
    end
    -- Special check for "Dragon" to catch any variation
    if lowerName:find("dragon") then return true end
    return false
end

-- Function to store the fruit
local function storeFruit(fruitName)
    local fruitObj = lp.Backpack:FindFirstChild(fruitName) or lp.Character:FindFirstChild(fruitName)
    if fruitObj then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", fruitName, fruitObj)
        print("Successfully Stored: " .. fruitName)
    end
end

-- Main Hunt
local function startHunt()
    if not game:IsLoaded() then game.Loaded:Wait() end
    
    -- Auto-Join Team
    if not lp.Team then
        pcall(function() 
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates") 
        end)
    end

    local fruitFound = false
    
    -- Workspace scan
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v:IsA("Tool") and (v:FindFirstChild("Handle") or v.Name:find("Fruit")) then
            if isValuable(v.Name) then
                fruitFound = true
                print("2026 TARGET FOUND: " .. v.Name)
                
                local root = lp.Character:WaitForChild("HumanoidRootPart")
                local targetPos = v:FindFirstChild("Handle") and v.Handle.CFrame or v.PrimaryPart.CFrame
                
                local info = TweenInfo.new((root.Position - targetPos.Position).Magnitude / getgenv().TweenSpeed, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(root, info, {CFrame = targetPos})
                tween:Play()
                tween.Completed:Wait()
                
                task.wait(1.5)
                storeFruit(v.Name)
            else
                print("Skipping non-elite: " .. v.Name)
            end
        end
    end
    
    -- Server Hopping
    task.wait(2)
    print("Searching for fresh 2026 server...")
    
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and servers then
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, lp)
                break
            end
        end
    end
end

startHunt()
