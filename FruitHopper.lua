local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Player = game.Players.LocalPlayer

-- Function to Server Hop
local function serverHop()
    local x = {}
    for _, v in ipairs(HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")).data) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            x[#x + 1] = v.id
        end
    end
    if #x > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
    else
        warn("No servers found, retrying...")
        wait(1)
        serverHop()
    end
end

-- Function to Find and Teleport to Fruit
local function findFruit()
    for _, v in pairs(game.Workspace:GetChildren()) do
        -- Blox Fruits typically names spawned fruits "Fruit " or includes "Fruit" in the model name
        if v:IsA("Model") and (string.find(v.name, "Fruit") or v:FindFirstChild("Handle")) then
            print("Fruit found: " .. v.name)
            local target = v:FindFirstChild("Handle") or v.PrimaryPart
            
            if target then
                -- Teleporting
                Player.Character.HumanoidRootPart.CFrame = target.CFrame
                wait(1) -- Wait to ensure it's picked up
                return true
            end
        end
    end
    return false
end

-- Main Execution
repeat wait() until game:IsLoaded()

local fruitFound = findFruit()

if fruitFound then
    print("Fruit secured. Hopping in 5 seconds...")
    wait(5)
    serverHop()
else
    print("No fruit in this server. Hopping now...")
    serverHop()
end
