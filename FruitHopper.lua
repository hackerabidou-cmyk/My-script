-- [[ 2026 ALL-FRUIT SNIPER & SMART HOPPER ]] --

-- 1. THE COMPLETE 2026 FRUIT LIST
local TargetFruits = {

    -- Mythicals
    "Dough", "Spirit", "Control", "Gravity", "Mammoth", "T-Rex", "Venom", "Shadow", "Dragon East", "Dragon West", "Kitsune", "Gas", "Yeti", "Tiger", "Yeti",
    -- Legendaries
    "Buddha", "Portal", "Blizzard", "Lightning", "Pain", "Sound", "Rumble", "Phoenix", "Spider", "Love", "Quake","Creation"
    -- Rares & Uncommons
    "Magma", "Ghost", "Rubber", "Light", "Diamond", "Dark", "Sand", "Ice", "Flame", "Eagle",
    -- Commons
    "Spike", "Smoke", "Bomb", "Spring", "Spin", "Rocket", "Blade", 
}

-- Settings
getgenv().TweenSpeed = 220
local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- Fuzzy Search Logic
local function isAnyFruit(name)
    local lowerName = name:lower()
    for _, fruitName in pairs(TargetFruits) do
        if lowerName:find(fruitName:lower()) or lowerName:find("fruit") then
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
        print("!!! STORED: " .. fruitName .. " !!!")
    end
end

-- Smart Server Hopper (Age Filter)
local function smartHop()
    print("Finding a high-probability server...")
    local success, servers = pcall(function()
        -- Fetching standard public servers
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)

    if success and servers then
        for _, server in pairs(servers.data) do
            -- Prioritize servers that aren't full and aren't our current one
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

    task.wait(1.5) -- Wait for assets to load
    
    local fruitFound = false
    for _, v in pairs(game.Workspace:GetChildren()) do
        -- Detects any tool with a handle or "Fruit" in the name
        if v:IsA("Tool") and (v:FindFirstChild("Handle") or v.Name:find("Fruit")) then
            if isAnyFruit(v.Name) then
                fruitFound = true
                print("FRUIT SPOTTED: " .. v.Name)
                
                local root = lp.Character:WaitForChild("HumanoidRootPart")
                local targetPos = v:FindFirstChild("Handle") and v.Handle.CFrame or v.PrimaryPart.CFrame
                
                -- Smooth Fly
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
        print("No fruit in this server. Hopping...")
    end
    
    task.wait(1)
    smartHop()
end

-- Start
startHunt()
