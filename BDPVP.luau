-- 1. โหลดไลบรารี Rayfield UI และกำหนดค่า Vamp Auth
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ข้อมูลสำหรับ Vamp Auth ของคุณ
local PROJECT_ID = "0V04G4GOWEQABV5T"

-- ฟังก์ชันสำหรับโหลดหน้าต่างหลักของสคริปต์ (จะทำงานเฉพาะหลังใส่คีย์ถูกต้องแล้วเท่านั้น)
local function loadMainHub()
    local Window = Rayfield:CreateWindow({
       Name = "Blood Debt PVP - XEVENS HUB",
       LoadingTitle = "Loading XEVENS HUB...",
       LoadingSubtitle = "By XEVENS HUB",
       ConfigurationSaving = { Enabled = false },
       KeySystem = false,
    })

    -- สร้างหน้าต่าง (Tabs) สำหรับฟังก์ชันต่างๆ
    local ESPTab = Window:CreateTab("1. ESP Settings", 4483362458)
    local AimbotTab = Window:CreateTab("2. Aimbot Settings", 4483362458)

    -- ตัวแปรระบบ
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- ค่าการตั้งค่า ESP
    local ESPEnabled = false
    local ChamFillTransparency = 0.4 -- ความโปร่งใสของสี (ปรับให้ทึบ/จางได้)
    local RemoveOutline = true      -- ค่าเปิด/ปิด การลบขอบขาว

    -- ค่าการตั้งค่า Aimbot
    local AimbotEnabled = false
    local WallCheckEnabled = true
    local FOVEnabled = true
    local FOVRadius = 150
    local PredictionFactor = 0.12 
    local SelectedPart = "Head"
    local SelectedKey = "MouseButton2"
    local Smoothness = 5

    -- สร้างวงกลม FOV บนจอ
    local fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.NumSides = 64
    fovCircle.Radius = FOVRadius
    fovCircle.Filled = false
    fovCircle.Color = Color3.fromRGB(255, 255, 255)
    fovCircle.Visible = false

    -- ฟังก์ชันเช็คว่ามองเห็นเป้าหมายหรือไม่ (ผ่านกำแพงไหม)
    local function isVisible(targetPart, character)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        local filterList = {LocalPlayer.Character, character}
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head") then
            table.insert(filterList, LocalPlayer.Character)
        end
        raycastParams.FilterDescendantsInstances = filterList
        raycastParams.IgnoreWater = true
        
        local origin = Camera.CFrame.Position
        local direction = (targetPart.Position - origin)
        local result = workspace:Raycast(origin, direction, raycastParams)
        
        return result == nil
    end

    -- ฟังก์ชันจัดการ ESP แต่ละคน
    local function setupESP(player)
        player.CharacterAdded:Connect(function(character)
            task.wait(1)
            if ESPEnabled then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESPHighlight"
                highlight.FillTransparency = ChamFillTransparency
                highlight.OutlineTransparency = RemoveOutline and 1 or 0
                highlight.Adornee = character
                highlight.Parent = character
            end
        end)
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            setupESP(player)
            if player.Character and ESPEnabled then
                if not player.Character:FindFirstChild("ESPHighlight") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.FillTransparency = ChamFillTransparency
                    highlight.OutlineTransparency = RemoveOutline and 1 or 0
                    highlight.Adornee = player.Character
                    highlight.Parent = player.Character
                end
            end
        end
    end

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then setupESP(player) end
    end)

    Players.PlayerRemoving:Connect(function(player)
        if player.Character and player.Character:FindFirstChild("ESPHighlight") then
            player.Character.ESPHighlight:Destroy()
        end
    end)

    ------------------ UI: ESP TAB ------------------
    ESPTab:CreateToggle({
       Name = "Toggle ESP (Green=Visible, Red=Behind Wall)",
       CurrentValue = false,
       Flag = "ESPToggle",
       Callback = function(Value)
          ESPEnabled = Value
          for _, player in ipairs(Players:GetPlayers()) do
              if player ~= LocalPlayer and player.Character then
                  if Value then
                      if not player.Character:FindFirstChild("ESPHighlight") then
                          local highlight = Instance.new("Highlight")
                          highlight.Name = "ESPHighlight"
                          highlight.FillTransparency = ChamFillTransparency
                          highlight.OutlineTransparency = RemoveOutline and 1 or 0
                          highlight.Adornee = player.Character
                          highlight.Parent = player.Character
                      end
                  else
                      if player.Character:FindFirstChild("ESPHighlight") then
                          player.Character.ESPHighlight:Destroy()
                      end
                  end
              end
          end
       end,
    })

    ESPTab:CreateToggle({
       Name = "Remove Outline",
       CurrentValue = true,
       Flag = "RemoveOutlineToggle",
       Callback = function(Value)
          RemoveOutline = Value
          for _, player in ipairs(Players:GetPlayers()) do
              if player.Character and player.Character:FindFirstChild("ESPHighlight") then
                  player.Character.ESPHighlight.OutlineTransparency = Value and 1 or 0
              end
          end
       end,
    })

    ESPTab:CreateSlider({
       Name = "Cham Transparency",
       Range = {0, 1},
       Increment = 0.08,
       CurrentValue = 0.4,
       Flag = "ChamTransparencySlider",
       Callback = function(Value)
          ChamFillTransparency = Value
          for _, player in ipairs(Players:GetPlayers()) do
              if player.Character and player.Character:FindFirstChild("ESPHighlight") then
                  player.Character.ESPHighlight.FillTransparency = Value
              end
          end
       end,
    })

    ------------------ UI: AIMBOT TAB ------------------
    AimbotTab:CreateToggle({
       Name = "Toggle Aimbot",
       CurrentValue = false,
       Flag = "AimbotToggle",
       Callback = function(Value) AimbotEnabled = Value end,
    })

    AimbotTab:CreateToggle({
       Name = "Wall Check",
       CurrentValue = true,
       Flag = "WallCheckToggle",
       Callback = function(Value) WallCheckEnabled = Value end,
    })

    AimbotTab:CreateToggle({
       Name = "Show FOV Circle",
       CurrentValue = true,
       Flag = "FOVToggle",
       Callback = function(Value)
          FOVEnabled = Value
          fovCircle.Visible = Value
       end,
    })

    AimbotTab:CreateSlider({
       Name = "FOV Radius",
       Range = {50, 400},
       Increment = 5,
       CurrentValue = 100,
       Flag = "FOVSizeSlider",
       Callback = function(Value)
          FOVRadius = Value
          fovCircle.Radius = Value
       end,
    })

    AimbotTab:CreateSlider({
       Name = "Prediction Strength",
       Range = {0, 0.3},
       Increment = 0.01,
       CurrentValue = 0.10,
       Flag = "PredictionSlider",
       Callback = function(Value) PredictionFactor = Value end,
    })

    AimbotTab:CreateDropdown({
       Name = "Target Part",
       Options = {"Head", "HumanoidRootPart"},
       CurrentOption = "Head",
       Flag = "TargetPartDropdown",
       Callback = function(Option)
          SelectedPart = type(Option) == "table" and Option[1] or Option
       end,
    })

    AimbotTab:CreateDropdown({
       Name = "Aim Key",
       Options = {"MouseButton2 (Right Click)", "MouseButton1 (Left Click)", "E", "Q", "Shift", "Always"},
       CurrentOption = "MouseButton2 (Right Click)",
       Flag = "AimKeyDropdown",
       Callback = function(Option)
          local choice = type(Option) == "table" and Option[1] or Option
          if choice:find("Right Click") then SelectedKey = "MouseButton2"
          elseif choice:find("Left Click") then SelectedKey = "MouseButton1"
          elseif choice == "Always" then SelectedKey = "Always"
          else SelectedKey = choice end
       end,
    })

    AimbotTab:CreateSlider({
       Name = "Aim Smoothness",
       Range = {1, 20},
       Increment = 1,
       CurrentValue = 3,
       Flag = "SmoothnessSlider",
       Callback = function(Value) Smoothness = Value end,
    })

    local function isAimKeyDown()
        if SelectedKey == "Always" then return true end
        if SelectedKey == "MouseButton2" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
        elseif SelectedKey == "MouseButton1" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
        else
            local success, keyCode = pcall(function() return Enum.KeyCode[SelectedKey] end)
            if success and keyCode then return UserInputService:IsKeyDown(keyCode) end
        end
        return false
    end

    -- ฟังก์ชันหาผู้เล่นใกล้ที่สุดที่อยู่ในวงกลม FOV
    local function getClosestPlayer()
        local closestPlayer = nil
        local shortestDistance = FOVRadius

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                local part = player.Character:FindFirstChild(SelectedPart)
                
                if humanoid and humanoid.Health > 0 and part then
                    if not WallCheckEnabled or isVisible(part, player.Character) then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                            local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                            if distance < shortestDistance then
                                shortestDistance = distance
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    -- ลูปอัปเดตการทำงานหลัก (ESP Color + FOV + Aimbot)
    RunService.RenderStepped:Connect(function()
        -- อัปเดตตำแหน่งวงกลม FOV ไว้กลางจอ
        if FOVEnabled then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end

        -- อัปเดตสี ESP ตามสถานะการมองเห็น (เขียว = เห็น, แดง = หลังกำแพง)
        if ESPEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local highlight = player.Character:FindFirstChild("ESPHighlight")
                    local part = player.Character:FindFirstChild(SelectedPart) or player.Character:FindFirstChild("HumanoidRootPart")
                    if highlight and part then
                        if isVisible(part, player.Character) then
                            highlight.FillColor = Color3.fromRGB(0, 255, 0)   -- เขียว (มองเห็น)
                        else
                            highlight.FillColor = Color3.fromRGB(255, 0, 0)   -- แดง (อยู่หลังกำแพง)
                        end
                    end
                end
            end
        end

        -- ระบบ Aimbot + เล็งล่วงหน้า (Prediction)
        if AimbotEnabled and isAimKeyDown() then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild(SelectedPart) then
                local part = target.Character[SelectedPart]
                local velocity = part.AssemblyLinearVelocity or Vector3.new(0,0,0)
                
                -- คำนวณตำแหน่งล่วงหน้าตามความเร็วเป้าหมาย
                local predictedPosition = part.Position + (velocity * PredictionFactor)
                local targetCFrame = CFrame.new(Camera.CFrame.Position, predictedPosition)
                
                local smoothFactor = math.clamp(Smoothness, 1, 20)
                Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, 1 / smoothFactor)
            end
        end
    end)

    Rayfield:LoadConfiguration()
end

-- 3. สร้างหน้าต่างเฉพาะสำหรับระบบใส่คีย์ (Vamp Auth)
local KeyWindow = Rayfield:CreateWindow({
   Name = "Blood Debt PVP - Key System",
   LoadingTitle = "Key System Verification",
   LoadingSubtitle = "Powered by Vamp Auth",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

local KeyTab = KeyWindow:CreateTab("Key System", 4483362458)
local enteredKey = ""

KeyTab:CreateSection("Authentication Required")

KeyTab:CreateButton({
   Name = "Get Key (Copy Work.ink Link)",
   Callback = function()
      local keyUrl = "https://vampauth.com/" .. PROJECT_ID .. "/flow"
      pcall(function() setclipboard(keyUrl) end)
      Rayfield:Notify({
         Title = "Link Copied Successfully!",
         Content = "Paste the link in your browser to complete checkpoints and get your key.",
         Duration = 6.5,
         Image = 4483362458,
      })
   end,
})

KeyTab:CreateInput({
   Name = "Enter Your Key",
   PlaceholderText = "Paste your key here...",
   RemoveFocusText = false,
   Flag = "KeyInput",
   Callback = function(Text)
      enteredKey = Text
   end,
})

KeyTab:CreateButton({
   Name = "Verify Key",
   Callback = function()
      local apiEndpoint = "https://vampauth.com/api/v1/verify?project=" .. PROJECT_ID .. "&key=" .. tostring(enteredKey)
      
      local success, response = pcall(function()
          return game:HttpGet(apiEndpoint)
      end)
      
      local isValid = false
      if success and response then
          if response:lower():find("true") or response:lower():find("success") then
              isValid = true
          end
      end

      if isValid then
         Rayfield:Notify({
            Title = "Success!",
            Content = "Key verified! Opening XEVENS HUB...",
            Duration = 3,
            Image = 4483362458,
         })
         
         pcall(function() KeyWindow:Destroy() end)
         loadMainHub()
      else
         Rayfield:Notify({
            Title = "Invalid Key",
            Content = "The key is incorrect, expired, or invalid for this device.",
            Duration = 5,
            Image = 4483362458,
         })
      end
   end,
})