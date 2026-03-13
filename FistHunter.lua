-- [[ DELTA OPTIMIZED FIST HUNTER 2026 ]] --

local lp = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Configuration
_G.CollectSpeed = 250 -- Lowered for Delta stability
_G.AutoHop = true

local function getChests()
    local chests = {}
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v.Name:find("Chest") and v:IsA("BasePart") then
            table.insert(chests, v)
        end
    end
    return chests
end

local function deltaTween(targetCF)
    local char = lp.Character or lp.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local dist = (root.Position - targetCF.Position).Magnitude
    local info = TweenInfo.new(dist / _G.CollectSpeed, Enum.EasingStyle.Linear)
    
    local tween = TweenService:Create(root, info, {CFrame = targetCF})
    tween:Play()
    
    -- Delta Safety: Wait for tween or manual break
    local reached = false
    tween.Completed:Connect(function() reached = true end)
    
    repeat task.wait() until reached or (root.Position - targetCF.Position).Magnitude < 10
end

local function startSweep()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local chests = getChests()
    
    print("Delta: Checking " .. #chests .. " chests...")
    
    for i, chest in ipairs(chests) do
        if chest.Transparency < 1 then
            deltaTween(chest.CFrame)
            task.wait(0.3) -- Essential for Delta to register touch
            
            if lp.Backpack:FindFirstChild("Fist of Darkness") or char:FindFirstChild("Fist of Darkness") then
                print("!!! FIST FOUND !!!")
                root.CFrame = CFrame.new(root.Position.X, 1500, root.Position.Z)
                return true
            end
        end
    end
    return false
end

-- Delta Manual Hop
local function hop()
    print("Hopping to new server...")
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"))
    for _, s in pairs(servers.data) do
        if s.playing < 12 and s.id ~= game.JobId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, lp)
            break
        end
    end
end

-- Run
local found = startSweep()
if not found and _G.AutoHop then
    task.wait(2)
    hop()
end
