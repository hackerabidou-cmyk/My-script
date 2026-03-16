local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🌊 Fist Hunter Hub | Akuma Edition",
   LoadingTitle = "Initializing Akuma Systems...",
   LoadingSubtitle = "by hackerabidou-cmyk",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "AkumaHub",
      FileName = "FistHunter"
   },
   KeySystem = false
})

-- [[ GLOBAL SETTINGS ]] --
_G.TweenSpeed = 100
_G.AutoAttack = false
_G.SelectedWeapon = "Melee" 
_G.Skills = {Z = true, X = true, C = true, V = true}

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")

-- [[ HELPER FUNCTIONS ]] --
local function getBoat()
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        local seat = Player.Character.Humanoid.SeatPart
        if seat and seat:IsA("VehicleSeat") then
            return seat.Parent
        end
    end
    return nil
end

local function equipWeapon()
    local tool = Player.Backpack:FindFirstChild(_G.SelectedWeapon) or Character:FindFirstChild(_G.SelectedWeapon)
    if tool then
        Player.Character.Humanoid:EquipTool(tool)
    end
end

local function useSkills()
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
   Name = "Movement Speed",
   Range = {50, 500},
   Increment = 10,
   Suffix = "SPS",
   CurrentValue = 100,
   Flag = "TweenSlider",
   Callback = function(Value) _G.TweenSpeed = Value end,
})

-- [[ SEA EVENT LOGIC ]] --
MainTab:CreateToggle({
   Name = "Auto Sail (Universal Forward)",
   CurrentValue = false,
   Callback = function(Value)
      _G.NormalSail = Value
      task.spawn(function()
          while _G.NormalSail do
              local boat = getBoat()
              if boat then
                  local speed = _G.TweenSpeed / 50
                  boat:SetPrimaryPartCFrame(boat:GetPrimaryPartCFrame() * CFrame.new(0, 0, -speed))
              else
                  _G.NormalSail = false
                  Rayfield:Notify({Title = "Akuma Hub", Content = "Please sit in driver's seat!", Duration = 2})
                  break
              end
              task.wait()
          end
      end)
   end,
})

MainTab:CreateToggle({
   Name = "Auto Sail (Universal Square)",
   CurrentValue = false,
   Callback = function(Value)
      _G.SquareSail = Value
      task.spawn(function()
          local points = {
              Vector3.new(1, 0, 0), 
              Vector3.new(0, 0, 1), 
              Vector3.new(-1, 0, 0), 
              Vector3.new(0, 0, -1)
          }
          local currentPoint = 1
          local timer = 0
          while _G.SquareSail do
              local boat = getBoat()
              if boat then
                  local speed = _G.TweenSpeed / 50
                  boat:SetPrimaryPartCFrame(boat:GetPrimaryPartCFrame() * CFrame.new(points[currentPoint].X * speed, 0, points[currentPoint].Z * speed))
                  
                  timer = timer + 1
                  if timer >= 500 then -- Change direction roughly every few seconds
                      currentPoint = currentPoint % 4 + 1
                      timer = 0
                  end
              else
                  _G.SquareSail = false
                  break
              end
              task.wait()
          end
      end)
   end,
})

MainTab:CreateToggle({
   Name = "Auto Attack Sea Beast",
   CurrentValue = false,
   Callback = function(Value)
      _G.AutoSB = Value
      task.spawn(function()
          while _G.AutoSB do
              local sb = workspace.Enemies:FindFirstChild("Sea Beast") or workspace:FindFirstChild("Sea Beast")
              if sb and sb:FindFirstChild("HumanoidRootPart") then
                  equipWeapon()
                  Root.CFrame = sb.HumanoidRootPart.CFrame * CFrame.new(0, 60, 0)
                  
                  -- Attack logic
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
   Name = "Select Weapon Category",
   Options = {"Melee", "Sword", "Fruit"},
   CurrentOption = "Melee",
   Callback = function(Option)
       for _, v in pairs(Player.Backpack:GetChildren()) do
           if v:IsA("Tool") and v.ToolTip == Option then
               _G.SelectedWeapon = v.name
           end
       end
   end,
})

CombatTab:CreateSection("Skills")
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
      task.spawn(function()
          while _G.FastAttack do
              game:GetService("ReplicatedStorage").Remotes.Validator:FireServer("Attack")
              task.wait(0.05)
          end
      end)
   end,
})
