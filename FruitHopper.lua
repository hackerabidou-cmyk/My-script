-- [[ SELECTIVE FRUIT SNIPER ]] --

-- 1. The Whitelist (Only these will be picked up)
local TargetFruits = {
    "Kitsune Fruit",
    "Leopard Fruit",
    "Dragon Fruit",
    "Spirit Fruit",
    "Control Fruit",
    "Venom Fruit",
    "Shadow Fruit",
    "Dough Fruit",
    "Mammoth Fruit",
    "T-Rex Fruit",
    "Gravity Fruit"
}

-- Settings
getgenv().TweenSpeed = 220
local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- Function to check if fruit is in our Whitelist
local function isMythical(name)
    for _, mythicalName in pairs(TargetFruits) do
        if name:find(mythicalName) then
            return true
        end
    end
    return false
end

-- Function to store the fruit
local function storeFruit(fruitName)
    local fruitObj = lp.Backpack:FindFirstChild(fruitName) or lp.Character:FindFirstChild(fruitName)
    if fruitObj then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", fruitName, fruitObj)
        print("!!! STORED MYTHICAL: " .. fruitName .. " !!!")
    end
end

-- Main Logic
local function startHunt()
    if not game:IsLoaded() then game.Loaded:Wait() end
    
    -- Auto Join Pirates if no team
    if not lp.Team then
        pcall(function() 
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetTeam", "Pirates") 
        end)
    end

    local fruitFound = false
    
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v:IsA("Tool") and v:FindFirstChild("Handle") then
            if isMythical(v.Name) then
                fruitFound = true
                print("MYTHICAL SPOTTED: " .. v.Name)
                
                -- Teleport/Tween
                local root = lp.Character:WaitForChild("HumanoidRootPart")
                local info = TweenInfo.new((root.Position - v.Handle.Position).Magnitude / getgenv().TweenSpeed, Enum.EasingStyle.Linear)
                local tween = TweenService:Create(root, info, {CFrame = v.Handle.CFrame})
                tween:Play()
                tween.Completed:Wait()
                
                task.wait(1)
                storeFruit(v.Name)
            else
                print("Skipping common fruit: " .. v.Name)
            end
        end
    end
    
    -- Hop to find mythicals elsewhere
    task.wait(2)
    
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    for _, server in pairs(servers.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, lp)
            break
        end
    end
end

startHunt()
