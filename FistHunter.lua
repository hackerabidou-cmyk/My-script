-- [[ 2026 FIST OF DARKNESS SEEKER ]] --
getgenv().CollectSpeed = 350
local lp = game.Players.LocalPlayer
local Character = lp.Character or lp.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- Function to find all chests in Second Sea
local function getChests()
    local chests = {}
    for _, v in pairs(game.Workspace:GetChildren()) do
        if v.Name:find("Chest") and v:IsA("Part") then
            table.insert(chests, v)
        end
    end
    return chests
end

-- Function to sweep the map
local function sweepChests()
    local chests = getChests()
    print("Sweeping " .. #chests .. " chests for Fist of Darkness...")
    
    for _, chest in ipairs(chests) do
        -- Only go for chests that haven't been taken
        if chest.Transparency < 1 then
            local dist = (Root.Position - chest.Position).Magnitude
            local tween = game:GetService("TweenService"):Create(Root, TweenInfo.new(dist/getgenv().CollectSpeed, Enum.EasingStyle.Linear), {CFrame = chest.CFrame})
            tween:Play()
            tween.Completed:Wait()
            
            task.wait(0.1) -- Collection time
            
            -- Check if we found it
            if lp.Backpack:FindFirstChild("Fist of Darkness") or lp.Character:FindFirstChild("Fist of Darkness") then
                print("!!! FIST OF DARKNESS FOUND !!!")
                -- Teleport to a safe height to avoid dying
                Root.CFrame = CFrame.new(0, 1000, 0)
                return true
            end
        end
    end
    return false
end

-- Main Execution
if sweepChests() == false then
    print("Fist not in this server. Prepare to hop.")
    -- You can add your serverHop() function here
end
