local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌊 Fist Hunter Hub | Akuma Edition",
   LoadingTitle = "Hunting the Sea...",
   LoadingSubtitle = "by hackerabidou-cmyk",
   KeySystem = false
})

-- [[ VARIABLES ]] --
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local BoatPath = {Vector3.new(5000, 0, 5000), Vector3.new(-5000, 0, 5000), Vector3.new(-5000, 0, -5000), Vector3.new(5000, 0, -5000)}

-- [[ SEA BEAST TAB ]] --
local SBTab = Window:CreateTab("Sea Beast Hunter", 4483362458)

SBTab:CreateToggle({
   Name = "Auto Sail (Square Pattern)",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoSail = Value
      spawn(function()
          local step = 1
          while _G.AutoSail do
              local boat = workspace.Boats:FindFirstChild(Player.Name .. "Boat") or workspace.Boats:FindFirstChildWhichIsA("Model")
              if boat and boat:FindFirstChild("VehicleSeat") then
                  local seat = boat.VehicleSeat
                  local target = BoatPath[step]
                  seat.LinearVelocity = (target - seat.Position).Unit * 100 -- Moving the boat
                  if (seat.Position - target).Magnitude < 100 then
                      step = step % 4 + 1
                  end
              end
              task.wait(1)
          end
      end)
   end,
})

SBTab:CreateToggle({
   Name = "Auto Attack Sea Beast",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoSB = Value
      spawn(function()
          while _G.AutoSB do
              local sb = workspace.Enemies:FindFirstChild("Sea Beast") or workspace:FindFirstChild("Sea Beast")
              if sb and sb:FindFirstChild("HumanoidRootPart") then
                  Root.CFrame = sb.HumanoidRootPart.CFrame * CFrame.new(0, 50, 0) -- Hover above it
                  game:GetService("ReplicatedStorage").Remotes.Validator:FireServer("Attack") -- Generic Attack
              end
              task.wait(0.1)
          end
      end)
   end,
})

-- [[ CHEST TAB ]] --
local ChestTab = Window:CreateTab("Chest Farm", 4483362458)

ChestTab:CreateToggle({
   Name = "Auto Collect All Chests",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoChest = Value
      spawn(function()
          while _G.AutoChest do
              for _, v in pairs(game.Workspace:GetChildren()) do
                  if v.name:find("Chest") and v:IsA("BasePart") then
                      Root.CFrame = v.CFrame
                      task.wait(0.3)
                  end
              end
              task.wait(1)
          end
      end)
   end,
})

-- [[ TELEPORT TAB ]] --
local TPTab = Window:CreateTab("Teleports", 4483362458)

local Locations = {
    ["Cafe (Second Sea)"] = Vector3.new(-382, 73, 284),
    ["Mansion (Third Sea)"] = Vector3.new(-12463, 332, -7549),
    ["Graveyard"] = Vector3.new(-3154, 48, -3259),
    ["Kingdom of Rose"] = Vector3.new(428, 73, 834)
}

for name, coords in pairs(Locations) do
    TPTab:CreateButton({
        Name = "Go to " .. name,
        Callback = function()
            Root.CFrame = CFrame.new(coords)
        end,
    })
end

Rayfield:Notify({Title = "Fist Hunter Loaded", Content = "Ready to hunt!", Duration = 3})
