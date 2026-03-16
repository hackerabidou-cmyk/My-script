local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌊 Fist Hunter Hub | Akuma Edition",
   LoadingTitle = "Initializing Akuma Systems...",
   LoadingSubtitle = "by hackerabidou-cmyk",
   KeySystem = false
})

-- [[ GLOBAL SETTINGS ]] --
_G.TweenSpeed = 100
_G.AutoAttack = false
_G.SelectedWeapon = "Melee" -- Default
_G.Skills = {Z = true, X = true, C = true, V = true}

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- [[ HELPER FUNCTIONS ]] --
local function equipWeapon()
    local tool = Player.Backpack:FindFirstChild(_G.SelectedWeapon) or Character:FindFirstChild(_G.SelectedWeapon)
    if tool then
        Player.Character.Humanoid:EquipTool(tool)
    end
end

local function useSkills()
    if not _G.AutoAttack then return end
    local VirtualInputManager = game:GetService("VirtualInputManager")
    for skill, enabled in pairs(_G.Skills) do
        if enabled then
            VirtualInputManager:SendKeyEvent(true, skill, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, skill, false, game)
        end
    end
end

-- [[ TABS ]] --
local MainTab = Window:CreateTab("Sea Events", 4483362458)
local CombatTab = Window:CreateTab("Combat Config", 4483362458)
local MiscTab = Window:CreateTab("Movement & Misc", 4483362458)

-- [[ MOVEMENT & TWEEN SPEED ]] --
MiscTab:CreateSlider({
   Name = "Tween Speed",
   Range = {50, 500},
   Increment = 10,
   Suffix = "SPS",
   CurrentValue = 100,
   Flag = "TweenSlider",
   Callback = function(Value) _G.TweenSpeed = Value end,
})

-- [[ SEA BEAST LOGIC ]] --
MainTab:CreateToggle({
   Name = "Auto Sail (Forward Only)",
   CurrentValue = false,
   Callback = function(Value)
      _G.NormalSail = Value
      spawn(function()
          while _G.NormalSail do
              local boat = workspace.Boats:FindFirstChild(Player.Name .. "Boat") or workspace.Boats:FindFirstChildWhichIsA("Model")
              if boat and boat:FindFirstChild("VehicleSeat") then
                  boat.VehicleSeat.LinearVelocity = boat.VehicleSeat.CFrame.LookVector * _G.TweenSpeed
              end
              task.wait(0.1)
          end
      end)
   end,
})

MainTab:CreateToggle({
   Name = "Auto Attack Sea Beast",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoSB = Value
      spawn(function()
          while _G.AutoSB do
              local sb = workspace.Enemies:FindFirstChild("Sea Beast") or workspace:FindFirstChild("Sea Beast")
              if sb and sb:FindFirstChild("HumanoidRootPart") then
                  equipWeapon()
                  Root.CFrame = sb.HumanoidRootPart.CFrame * CFrame.new(0, 60, 0)
                  -- Click Attack
                  game:GetService("VirtualUser"):CaptureController()
                  game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
                  useSkills()
              end
              task.wait(0.1)
          end
      end)
   end,
})

-- [[ COMBAT CONFIG ]] --
CombatTab:CreateDropdown({
   Name = "Select Weapon Type",
   Options = {"Melee", "Sword", "Fruit"},
   CurrentOption = "Melee",
   Callback = function(Option)
       -- Logic to find the actual item name in backpack
       for _, v in pairs(Player.Backpack:GetChildren()) do
           if v:IsA("Tool") and v.ToolTip == Option then
               _G.SelectedWeapon = v.name
           end
       end
   end,
})

CombatTab:CreateSection("Skills to Use")
for _, key in pairs({"Z", "X", "C", "V"}) do
    CombatTab:CreateToggle({
       Name = "Use " .. key .. " Skill",
       CurrentValue = true,
       Callback = function(Value) _G.Skills[key] = Value end,
    })
end

CombatTab:CreateToggle({
   Name = "Fast Attack (Caution)",
   CurrentValue = false,
   Callback = function(Value)
      _G.FastAttack = Value
      spawn(function()
          while _G.FastAttack do
              game:GetService("ReplicatedStorage").Remotes.Validator:FireServer("Attack")
              task.wait(0.05)
          end
      end)
   end,
})
