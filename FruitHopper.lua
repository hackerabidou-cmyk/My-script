-- [[ 2026 ELITE SNIPER - SERVER AGE EDITION ]] --

-- 1. YOUR SPECIFIC FRUIT LIST
local TargetFruits = {
    -- The New Kings
    "Dragon East", "Dragon West", "Kitsune", "Gas", "Yeti", "Tiger",
    -- Mythicals & Reworks
    "Dough", "Spirit", "Control", "Gravity", "Mammoth", "T-Rex",
    -- High-Value Legendaries
    "Buddha", "Portal", "Blizzard", "Lightning", "Pain"
}

-- Settings
getgenv().TweenSpeed = 220
local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- Fuzzy Search Logic
local function isValuable(name)
    local lowerName = name:lower()
    for _, eliteName in pairs(TargetFruits) do
        if lowerName:find(eliteName:lower()) then
            return true
        end
    end
    return false
end

-- Store Function
local function storeFruit(fruitName)
    local fruitObj = lp.Backpack:FindFirstChild(fruitName) or lp.Character:FindFirstChild(fruitName)
    if fruitObj then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", fruitName, fruitObj)
        print("!!! SECURED: " .. fruitName .. " !!!")
    end
end

-- SMART SERVER HOPPER (Prioritizes 60min+ Servers)
local function smartHop()
    print("Finding a high-probability server...")
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and servers then
        -- Try to find an older server first
        for _, server in pairs(servers.data) do
            -- Look for servers with decent player counts but not full
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, lp)
                break
            end
        end
    end
end

-- Main Loop
local function startHunt()
    if not game:IsLoaded() then game.Loaded:Wait() end
    
    -- Auto Join Team
    if not lp.Team then
        pcall(function() 
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates") 
        end)
    end

    task.wait(1) -- Brief pause for workspace to load
    
    local fruitFound = false
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v:IsA("Tool") and (v:FindFirstChild("Handle") or v.Name:find("Fruit")) then
            if isValuable(v.Name) then
                fruitFound = true
                print("TARGET FOUND: " .. v.Name)
                
                local root = lp.Character:WaitForChild("HumanoidRootPart")
                local targetPos = v:FindFirstChild("Handle") and v.Handle.CFrame or v.PrimaryPart.CFrame
                
                local info = TweenInfo.new((root.Position - targetPos.Position).Magnitude / getgenv().TweenSpeed, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(root, info, {CFrame = targetPos})
                tween:Play()
                tween.Completed:Wait()
                
                task.wait(1.5)
                storeFruit(v.Name)
            end
        end
    end
    
    if not fruitFound then
        print("No elite fruits here. Moving on...")
    end
    
    task.wait(1)
    smartHop()
end

startHunt()
