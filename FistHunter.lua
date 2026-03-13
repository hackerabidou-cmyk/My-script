-- [[ 2026 DELITE/DELTA COMPATIBLE FIST HUNTER ]] --

-- Delta-Safe Variables
local lp = game:GetService("Players").LocalPlayer
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

getgenv().Speed = 300

-- Function to safely teleport on Delta
local function deltaTween(targetCFrame)
    local char = lp.Character or lp.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local info = TweenInfo.new(dist / getgenv().Speed, Enum.EasingStyle.Linear)
    
    local tween = TweenService:Create(root, info, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

-- Function to grab chests
local function collectChests()
    print("Delta: Starting Chest Sweep...")
    local chests = {}
    
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v.Name:find("Chest") and v:IsA("Part") then
            table.insert(chests, v)
        end
    end

    for _, chest in ipairs(chests) do
        if chest.Transparency < 1 then
            deltaTween(chest.CFrame)
            task.wait(0.2) -- Extra time for Delta to register the 'Touch'
            
            if lp.Backpack:FindFirstChild("Fist of Darkness") or lp.Character:FindFirstChild("Fist of Darkness") then
                print("FIST FOUND!")
                -- Delta Safety: Fly high immediately
                lp.Character.HumanoidRootPart.CFrame = CFrame.new(0, 2000, 0)
                return true
            end
        end
    end
    return false
end

-- Delta Execute
local success = collectChests()
if not success then
    print("No Fist. Delta is ready for manual hop.")
end
