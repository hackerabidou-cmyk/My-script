-- [[ Blox Fruits Auto-Fruit Sniper & Server Hopper ]] --

if not game:IsLoaded() then game.Loaded:Wait() end

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer

-- Configuration
_G.TweenSpeed = 100 -- Adjust speed (Lower = Slower/Safer)

-- Function to safely move to the fruit
local function tweenTo(targetCFrame)
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local distance = (Player.Character.HumanoidRootPart.Position - targetCFrame.p).Magnitude
    local info = TweenInfo.new(distance / _G.TweenSpeed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(Player.Character.HumanoidRootPart, info, {CFrame = targetCFrame})
    
    tween:Play()
    tween.Completed:Wait()
end

-- Function to find a new server
local function serverHop()
    print("Finding new server...")
    local sfUrl = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(sfUrl))
    end)
    
    if success and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                return
            end
        end
    end
    warn("No servers found, retrying in 3 seconds...")
    task.wait(3)
    serverHop()
end

-- Function to search for fruits
local function checkFruits()
    for _, v in pairs(game.Workspace:GetChildren()) do
        -- Blox Fruits usually names them "Fruit " or they have a "Handle"
        if v:IsA("Tool") and (string.find(v.name, "Fruit") or v:FindFirstChild("Handle")) then
            return v
        elseif v:IsA("Model") and string.find(v.name, "Fruit") then
             return v
        end
    end
    return nil
end

-- Main Loop
local foundFruit = checkFruits()

if foundFruit then
    print("Fruit Detected: " .. foundFruit.name)
    local target = foundFruit:FindFirstChild("Handle") or foundFruit:FindFirstChildWhichIsA("BasePart")
    
    if target then
        tweenTo(target.CFrame)
        task.wait(1) -- Time to pick up
    end
    print("Hopping after find...")
    serverHop()
else
    print("No fruit in this server. Hopping...")
    serverHop()
end
