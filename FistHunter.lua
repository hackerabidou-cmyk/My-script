-- [[ 2026 FIST OF DARKNESS & 4H+ HOPPER ]] --

local lp = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- Configuration
getgenv().CollectSpeed = 350

local function getServerAge()
    local uptime = workspace.DistributedGameTime
    return math.floor(uptime / 3600) -- Returns hours
end

local function hopToOldServer()
    print("Looking for an established server...")
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)
    
    if success and servers then
        for _, s in pairs(servers.data) do
            if s.playing >= 7 and s.playing <= 10 and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
                break
            end
        end
    end
end

local function sweepChests()
    if game.PlaceId ~= 4442245221 then -- Second Sea ID
        warn("You must be in the Second Sea to find the Fist of Darkness!")
        return
    end

    local char = lp.Character or lp.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    local chests = {}
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v.Name:find("Chest") and v:IsA("Part") then table.insert(chests, v) end
    end

    print("Checking " .. #chests .. " chests in this " .. getServerAge() .. "h server...")

    for _, chest in ipairs(chests) do
        if chest.Transparency < 1 then
            local dist = (root.Position - chest.Position).Magnitude
            local tween = TweenService:Create(root, TweenInfo.new(dist/getgenv().CollectSpeed, Enum.EasingStyle.Linear), {CFrame = chest.CFrame})
            tween:Play()
            tween.Completed:Wait()
            task.wait(0.2)
            
            if lp.Backpack:FindFirstChild("Fist of Darkness") or char:FindFirstChild("Fist of Darkness") then
                print("!!! FIST FOUND !!! FLYING TO SAFETY !!!")
                root.CFrame = CFrame.new(root.Position.X, 2000, root.Position.Z)
                return true
            end
        end
    end
    return false
end

-- Start Logic
if not sweepChests() then
    print("No Fist here. Hopping...")
    task.wait(1)
    hopToOldServer()
end
