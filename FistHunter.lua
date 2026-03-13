-- [[ 2026 UNIFIED FIST HUNTER & SERVER AGED HOPPER ]] --

local lp = game:GetService("Players").LocalPlayer
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

_G.CollectSpeed = 280
_G.TargetAge = 4 -- Hours

local function getServerAge()
    return workspace.DistributedGameTime / 3600
end

local function hop()
    print("Finding a new potential 4H+ server...")
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    end)
    
    if success and servers then
        for _, s in pairs(servers.data) do
            -- Target servers with 6-9 players (statistically older)
            if s.playing >= 6 and s.playing <= 9 and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
                break
            end
        end
    end
end

local function sweep()
    print("Server Age: " .. string.format("%.2f", getServerAge()) .. " hours.")
    
    local chests = {}
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent and v.Parent.Name:find("Chest") then
            table.insert(chests, v.Parent)
        end
    end

    for _, chest in ipairs(chests) do
        if chest:IsA("BasePart") and chest.Transparency < 1 then
            local char = lp.Character or lp.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart")
            local dist = (root.Position - chest.Position).Magnitude
            
            local tween = TweenService:Create(root, TweenInfo.new(dist / _G.CollectSpeed, Enum.EasingStyle.Linear), {CFrame = chest.CFrame})
            tween:Play()
            tween.Completed:Wait()
            task.wait(0.4) -- Delta-safe delay
            
            if lp.Backpack:FindFirstChild("Fist of Darkness") or char:FindFirstChild("Fist of Darkness") then
                print("!!! FIST OF DARKNESS SECURED !!!")
                root.CFrame = CFrame.new(root.Position.X, 2000, root.Position.Z)
                return true
            end
        end
    end
    return false
end

-- Main Logic
local age = getServerAge()
if age >= _G.TargetAge then
    print("Server is old enough! Checking chests...")
    local found = sweep()
    if not found then
        print("Chest sweep failed. Someone likely took it. Hopping...")
        task.wait(2)
        hop()
    end
else
    print("Server is too new (" .. string.format("%.2f", age) .. "h). Hopping...")
    task.wait(2)
    hop()
end
