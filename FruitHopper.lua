-- [[ BLOX FRUIT SNIPER & HOPPER ]] --

repeat task.wait() until game:IsLoaded()

-- Auto Join Team (Pirates)
local function joinTeam()
    local joinRemote = game:GetService("ReplicatedStorage").Remotes.CommF_
    joinRemote:InvokeServer("SetTeam", "Pirates")
end

-- Fallback if not joined
if not game.Players.LocalPlayer.Team then
    pcall(joinTeam)
end

-- Settings
getgenv().TweenSpeed = 200 -- Safe speed for mobile executors
local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- 1. Auto-Store Logic
local function storeFruit(fruitName)
    local fruitObj = lp.Backpack:FindFirstChild(fruitName) or lp.Character:FindFirstChild(fruitName)
    if fruitObj then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", fruitName, fruitObj)
        print("Successfully Stored: " .. fruitName)
    end
end

-- 2. Smooth Movement (Anti-Kick)
local function teleport(targetCFrame)
    local char = lp.Character or lp.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local info = TweenInfo.new(distance / getgenv().TweenSpeed, Enum.EasingStyle.Linear)
    
    local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- 3. Server Hopper
local function serverHop()
    print("Finding new server...")
    local placeId = game.PlaceId
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"))
    
    for _, server in pairs(servers.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            TeleportService:TeleportToPlaceInstance(placeId, server.id, lp)
            break
        end
    end
end

-- 4. Main Loop
local function startHunt()
    local fruitFound = false
    
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
            fruitFound = true
            print("Fruit Spotted: " .. v.Name)
            teleport(v.Handle.CFrame)
            
            task.wait(1) -- Wait for pickup
            storeFruit(v.Name)
        end
    end
    
    if not fruitFound then
        print("No fruits found. Hopping in 3 seconds...")
        task.wait(3)
    end
    
    serverHop()
end

-- RUN
startHunt()
