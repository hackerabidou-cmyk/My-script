-- [[ AGGRESSIVE DELTA FIST HUNTER 2026 ]] --

local lp = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

_G.CollectSpeed = 200 -- Slower for Delta stability
_G.AutoHop = true

-- Optimized chest finder that scans deep folders
local function getChests()
    local chests = {}
    -- Scan everything in Workspace (including folders)
    for _, v in pairs(game.Workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent and v.Parent.Name:find("Chest") then
            table.insert(chests, v.Parent)
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
    tween.Completed:Wait()
end

local function startSweep()
    print("Delta: Scanning map for chests...")
    local chests = getChests()
    
    if #chests == 0 then
        print("Delta Error: No chests found in workspace. Try moving islands.")
        return false
    end
    
    print("Delta: Found " .. #chests .. " chests. Starting sweep...")
    
    for _, chest in ipairs(chests) do
        -- Skip chests that are already opened (Transparency 1)
        if chest:IsA("BasePart") and chest.Transparency < 1 then
            deltaTween(chest.CFrame)
            task.wait(0.5) -- Buffed for Delta touch registration
            
            if lp.Backpack:FindFirstChild("Fist of Darkness") or lp.Character:FindFirstChild("Fist of Darkness") then
                print("!!! SUCCESS: FIST OBTAINED !!!")
                lp.Character.HumanoidRootPart.CFrame = CFrame.new(0, 1500, 0)
                return true
            end
        end
    end
    return false
end

local function hop()
    print("No Fist found. Hopping...")
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
