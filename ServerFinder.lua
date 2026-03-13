-- [[ 2026 FIST OF DARKNESS / CHEST TELEPORT ]] --

local lp = game.Players.LocalPlayer
local Character = lp.Character or lp.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- Settings
getgenv().CollectSpeed = 300 -- Speed of moving between chests

local function getChests()
    local chests = {}
    for _, v in pairs(game.Workspace:GetChildren()) do
        -- Blox Fruits chests are usually named "Chest1", "Chest2", "Chest3"
        if v.Name:find("Chest") and v:IsA("Part") then
            table.insert(chests, v)
        end
    end
    return chests
end

local function teleportToChests()
    local allChests = getChests()
    print("Found " .. #allChests .. " chests. Starting sweep...")

    for i, chest in ipairs(allChests) do
        if chest:FindFirstChild("TouchInterest") or chest.Transparency < 1 then
            -- Tween to chest
            local dist = (Root.Position - chest.Position).Magnitude
            local tween = game:GetService("TweenService"):Create(Root, TweenInfo.new(dist/getgenv().CollectSpeed, Enum.EasingStyle.Linear), {CFrame = chest.CFrame})
            tween:Play()
            tween.Completed:Wait()
            task.wait(0.2) -- Small delay to ensure collection
            
            -- Check if we got the Fist
            if lp.Backpack:FindFirstChild("Fist of Darkness") or lp.Character:FindFirstChild("Fist of Darkness") then
                print("!!! FIST OF DARKNESS OBTAINED !!!")
                return true
            end
        end
    end
    print("Sweep complete. No Fist found.")
    return false
end

-- Run the sweep
local found = teleportToChests()

if not found then
    print("Fist not found. Server might be under 4 hours or already looted.")
    -- You can add a server hop call here if you want it to be automatic
end
