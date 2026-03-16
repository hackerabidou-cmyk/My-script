-- [[ SETTINGS & TOGGLES ]] --
_G.AutoFarm = false
_G.AutoCollect = false
_G.AntiAFK = true

-- [[ UI LIBRARY SETUP ]] --
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Container = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "UniversalPetHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true -- Allows you to move the Hub

Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "PET SIM HUB [PRO]"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Parent = MainFrame

Container.Name = "Container"
Container.Parent = MainFrame
Container.BackgroundTransparency = 1
Container.Position = UDim2.new(0, 5, 0, 45)
Container.Size = UDim2.new(1, -10, 1, -50)
Container.CanvasSize = UDim2.new(0, 0, 1.5, 0)

UIListLayout.Parent = Container
UIListLayout.Padding = UDim.new(0, 5)

-- [[ HELPER FUNCTION: CREATE BUTTONS ]] --
local function AddToggle(text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.Text = text .. ": OFF"
    Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 18
    Button.Parent = Container

    local state = false
    Button.MouseButton1Click:Connect(function()
        state = not state
        Button.Text = text .. ": " .. (state and "ON" or "OFF")
        Button.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- [[ THE "HACK" LOGIC ]] --

-- 1. AUTO FARM
AddToggle("Auto Farm", function(v)
    _G.AutoFarm = v
    task.spawn(function()
        while _G.AutoFarm do
            pcall(function()
                -- Locates the coins folder (standard path for PSX/PS99)
                local coins = game:GetService("Workspace").__THINGS.Coins:GetChildren()
                if #coins > 0 then
                    local target = coins[math.random(1, #coins)]
                    -- Replace 'JoinCoin' with the name found via RemoteSpy if it changes!
                    game:GetService("ReplicatedStorage").Framework.Remote.JoinCoin:InvokeServer(target.Name, {})
                end
            end)
            task.wait(0.5)
        end
    end)
end)

-- 2. AUTO COLLECT (MAGNET)
AddToggle("Auto Collect Orbs", function(v)
    _G.AutoCollect = v
    task.spawn(function()
        while _G.AutoCollect do
            pcall(function()
                local orbs = game:GetService("Workspace").__THINGS.Orbs:GetChildren()
                for _, orb in pairs(orbs) do
                    orb.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                end
            end)
            task.wait(0.1)
        end
    end)
end)

-- 3. WALK SPEED
AddToggle("Super Speed", function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 100 or 16
end)

-- 4. ANTI-AFK (Always Active)
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    if _G.AntiAFK then
        local vu = game:GetService("VirtualUser")
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end
end)

print("Hub loaded and GitHub synced!")
