-- Универсальное Roblox чит-меню с исправленным полётом через встроенный джойстик/клавиатуру.
-- Добавлено: отдельная кнопка для закрытия/открытия меню на экране сверху (ПК и мобильный).
-- Всё остальное В КОДЕ НЕ МЕНЯЛОСЬ (кроме кнопки меню).

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local walkSpeed, jumpPower, flySpeed = 16, 50, 50
local isFlying, antiKB, fastStand, enlargedHitbox, espEnabled = false, false, false, false, false

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

--== UI ==
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "UniversalCheatMenu"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 350, 0, 420)
frame.Position = UDim2.new(0, 60, 0, 70)
frame.BackgroundColor3 = Color3.fromRGB(32,32,32)
frame.Active = true
frame.Draggable = true
frame.Visible = true -- Для управления видимостью

-- КНОПКА МЕНЮ для ПК/МОБИЛКИ (всегда сверху)
local menuBtn = Instance.new("TextButton", gui)
menuBtn.Size = UDim2.new(0, 90, 0, 40)
menuBtn.Position = UDim2.new(0,10,0,10)
menuBtn.Text = "Меню"
menuBtn.BackgroundColor3 = Color3.fromRGB(90,30,30)
menuBtn.TextColor3 = Color3.new(1,1,1)
menuBtn.Font = Enum.Font.SourceSansBold
menuBtn.TextSize = 18
menuBtn.Visible = true
menuBtn.ZIndex = 9999
frame:GetPropertyChangedSignal("Visible"):Connect(function()
    if frame.Visible then
        menuBtn.Text = "Закрыть"
    else
        menuBtn.Text = "Меню"
    end
end)
menuBtn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local y = 0

local function makeTitle(text)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1,0,0,34)
    lbl.Position = UDim2.new(0,0,0,y)
    y = y + 0.08
    lbl.BackgroundColor3 = Color3.fromRGB(50,50,50)
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Text = text
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 21
    return lbl
end

local function makeLabel(labelText)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0, 190, 0, 30)
    label.Position = UDim2.new(0, 12, 0, y*frame.Size.Y.Offset)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.SourceSans
    label.Text = labelText
    label.TextSize = 18
    return label
end

local function makeInput(x,labelText, defaultV, callback)
    makeLabel(labelText)
    local box = Instance.new("TextBox", frame)
    box.Size = UDim2.new(0, 80, 0, 28)
    box.Position = UDim2.new(0, 210, 0, y*frame.Size.Y.Offset-2)
    box.BackgroundColor3 = Color3.fromRGB(45,45,42)
    box.Text = tostring(defaultV)
    box.TextColor3 = Color3.new(1,1,1)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 17
    box.ClearTextOnFocus = false
    box.FocusLost:Connect(function(enter)
        local n = tonumber(box.Text)
        if n then
            callback(n)
        else
            box.Text = tostring(defaultV) -- сброс
        end
    end)
    y = y + 0.10
    return box
end

local function makeToggle(labelText, defaultValue, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 300, 0, 32)
    btn.Position = UDim2.new(0, 25, 0, y*frame.Size.Y.Offset)
    btn.BackgroundColor3 = defaultValue and Color3.fromRGB(70,170,70) or Color3.fromRGB(100,30,30)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = labelText .. (defaultValue and " [ВКЛ]" or " [ВЫКЛ]")
    btn.TextSize = 18
    local state = defaultValue
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(70,170,70) or Color3.fromRGB(100,30,30)
        btn.Text = labelText .. (state and " [ВКЛ]" or " [ВЫКЛ]")
        callback(state)
    end)
    y = y + 0.079
    return btn
end

makeTitle("CHEAT МЕНЮ — ПК/МОБИЛКА")

makeInput(0, "Скорость (ходьба):", walkSpeed, function(n)
    walkSpeed = math.clamp(n,0,200)
    local hum = getChar():FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = walkSpeed end
end)
makeInput(0, "Прыжок:", jumpPower, function(n)
    jumpPower = math.clamp(n,0,200)
    local hum = getChar():FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = jumpPower end
end)
makeInput(0, "Скорость полёта:", flySpeed, function(n)
    flySpeed = math.clamp(n,4,200)
end)

makeToggle("Полет (F или кнопка)", false, function(val) isFlying = val end)
makeToggle("Анти-отдача", false, function(val) antiKB = val end)
makeToggle("Быстрое вставание", false, function(val) fastStand = val end)
makeToggle("Большой хитбокс врага", false, function(val)
    enlargedHitbox = val
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local part = plr.Character.HumanoidRootPart
            if enlargedHitbox then
                part.Size = Vector3.new(7,7,7)
                part.Transparency = 0.5
                part.Color = Color3.fromRGB(255,0,0)
            else
                part.Size = Vector3.new(2,2,1)
                part.Transparency = 1
                part.Color = Color3.fromRGB(163, 162, 165)
            end
        end
    end
end)
makeToggle("ESP на игроков сервера", false, function(val)
    espEnabled = val
    for _,plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if espEnabled then
                local box = Instance.new("BoxHandleAdornment")
                box.Adornee = plr.Character.HumanoidRootPart
                box.AlwaysOnTop = true
                box.ZIndex = 15
                box.Size = Vector3.new(4, 7, 4)
                box.Transparency = 0.6
                box.Color3 = Color3.fromRGB(255,50,50)
                box.Name = "ESPBOX"
                box.Parent = plr.Character
            else
                if plr.Character:FindFirstChild("ESPBOX") then
                    plr.Character.ESPBOX:Destroy()
                end
            end
        end
    end
end)

-- == РАБОТАЮЩИЙ ПОЛЁТ через MoveDirection ==
RS:BindToRenderStep("FixedFly", Enum.RenderPriority.Character.Value, function()
    local char = getChar()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if not hrp or not hum then return end

    if not isFlying and hrp:FindFirstChild("FlyVelocity") then
        hrp.FlyVelocity:Destroy()
        if hrp:FindFirstChild("FlyGyro") then hrp.FlyGyro:Destroy() end
        return
    end
    if isFlying then
        if not hrp:FindFirstChild("FlyVelocity") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "FlyVelocity"
            bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.P = 1280
            bv.Velocity = Vector3.new(0,0,0)
            bv.Parent = hrp
            local bg = Instance.new("BodyGyro")
            bg.Name = "FlyGyro"
            bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bg.P = 20000
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
        end
        local bv = hrp:FindFirstChild("FlyVelocity")
        local bg = hrp:FindFirstChild("FlyGyro")
        if bv and bg then
            local moveVec = hum.MoveDirection
            local vert = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) then vert = vert + 1 end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vert = vert - 1 end
            if hum.Jump and UIS.TouchEnabled then vert = 1 end
            local final = moveVec * flySpeed + Vector3.new(0,vert*flySpeed,0)
            if final.Magnitude > flySpeed then final = final.Unit * flySpeed end
            bv.Velocity = final
            bg.CFrame = workspace.CurrentCamera.CFrame
            hum.PlatformStand = false
        end
    end
end)

-- == Горячие клавиши (ПК) для меню и полёта ==
UIS.InputBegan:Connect(function(input, gp)
    if not gp then
        if input.KeyCode == Enum.KeyCode.F then -- fly on/off с ПК
            isFlying = not isFlying
        end
        if input.KeyCode == Enum.KeyCode.M then -- скрыть/показать меню
            frame.Visible = not frame.Visible
        end
    end
end)

-- == Антиотдача и FastStand ==
local function guardHumanoid()
    local humanoid = getChar():FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Changed:Connect(function(prop)
            if antiKB and prop == "SeatPart" and humanoid.SeatPart then
                humanoid.Sit = false
            end
        end)
        humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if fastStand and humanoid.PlatformStand then
                wait(0.05)
                humanoid.PlatformStand = false
            end
        end)
    end
end
getChar().ChildAdded:Connect(function(obj)
    if obj:IsA("Humanoid") then guardHumanoid() end
end)
guardHumanoid()

-- == Speed/Jump постоянная поддержка ==
RS.RenderStepped:Connect(function()
    local char = getChar()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then 
        if not isFlying then
            hum.WalkSpeed = walkSpeed
        else
            hum.WalkSpeed = 0
        end
        hum.JumpPower = jumpPower
    end
end)