-- ========================================================
-- 🎯 MOBILE AIMBOT — เปิดแล้วทำงานเลย
-- มี FOV / Smoothness / ระยะปรับได้ • ใช้งานได้จริง
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ⚙️ ปรับค่าที่นี่ได้เลย
local Settings = {
    Aimbot = {
        Enabled = false,
        FOV = 85,              -- มุมมองล็อกเป้า (องศา)
        Smoothness = 0.35,     -- ความนุ่มนวล 0.1=เร็ว / 0.6=ช้า
        MaxDistance = 120,     -- ระยะสูงสุดที่จะล็อกเป้า
        AimPart = "Head"       -- ล็อกที่ส่วนไหน: "Head" หรือ "HumanoidRootPart"
    },
    NoClip = { Enabled = false },
    ESP = { Enabled = false }
}

local State = {
    ESPData = {},
    OriginalCollisions = {}
}

-- ======================================
-- 🔍 คำนวณมุม FOV
-- ======================================
local function GetAngleBetween(v1, v2)
    return math.acos(math.clamp(v1.Unit:Dot(v2.Unit), -1, 1))
end

-- ======================================
-- 🎯 หาเป้าหมายที่อยู่ใน FOV
-- ======================================
local function GetBestTarget()
    if not Settings.Aimbot.Enabled then return nil end
    
    local camPos = Camera.CFrame.Position
    local camDir = Camera.CFrame.LookVector
    local bestTarget = nil
    local bestAngle = math.rad(Settings.Aimbot.FOV)

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character then
            local Humanoid = Player.Character:FindFirstChild("Humanoid")
            local AimPart = Player.Character:FindFirstChild(Settings.Aimbot.AimPart)
            local RootPart = Player.Character:FindFirstChild("HumanoidRootPart")

            if Humanoid and Humanoid.Health > 0 and AimPart and RootPart then
                -- เช็กระยะ
                local distance = (camPos - RootPart.Position).Magnitude
                if distance > Settings.Aimbot.MaxDistance then continue end

                -- เช็ค FOV
                local directionTo = (AimPart.Position - camPos).Unit
                local angle = GetAngleBetween(camDir, directionTo)
                
                if angle < bestAngle then
                    bestAngle = angle
                    bestTarget = AimPart
                end
            end
        end
    end
    return bestTarget
end

-- ======================================
-- 📱 สร้าง UI — รันแล้วขึ้นทันที
-- ======================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- ปุ่มลอย เปิด-ปิดเมนู
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size = UDim2.new(0, 55, 0, 55)
FloatBtn.Position = UDim2.new(0.015, 0, 0.45, -27)
FloatBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
FloatBtn.Text = "⚡"
FloatBtn.TextSize = 26
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.AutoLocalize = false
FloatBtn.Parent = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0, 14)

-- หน้าต่างเมนู
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 260)
MainFrame.Position = UDim2.new(0.08, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
MainFrame.Visible = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- หัวเมนู
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(44, 44, 54)
TitleBar.Parent = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🎯 AIMBOT HUB"
TitleText.TextColor3 = Color3.new(1,1,1)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 15
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- ข้อมูลค่าปัจจุบัน
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 30)
InfoLabel.Position = UDim2.new(0, 10, 0, 55)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "FOV: " .. Settings.Aimbot.FOV .. "°  |  Smooth: " .. Settings.Aimbot.Smoothness
InfoLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextSize = 11
InfoLabel.Parent = MainFrame

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -95)
Content.Position = UDim2.new(0, 10, 0, 90)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.Parent = Content

-- 🎨 สร้างปุ่มเปิด-ปิด
local function CreateToggle(name, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 48)
    Container.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    Container.Parent = Content
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Switch = Instance.new("TextButton")
    Switch.Size = UDim2.new(0, 52, 0, 26)
    Switch.Position = UDim2.new(1, -62, 0.5, -13)
    Switch.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    Switch.Text = ""
    Switch.AutoLocalize = false
    Switch.Parent = Container
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 13)

    local Dot = Instance.new("Frame")
    Dot.Size = UDim2.new(0, 20, 0, 20)
    Dot.Position = UDim2.new(0, 3, 0.5, -10)
    Dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Dot.Parent = Switch
    Instance.new("UICorner", Dot).CornerRadius = UDim.new(0, 10)

    local isOn = false
    Switch.MouseButton1Click:Connect(function()
        isOn = not isOn
        Switch.BackgroundColor3 = isOn and Color3.fromRGB(45, 170, 255) or Color3.fromRGB(70, 70, 80)
        Dot.Position = isOn and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        Dot.BackgroundColor3 = isOn and Color3.new(1,1,1) or Color3.fromRGB(150, 150, 150)
        callback(isOn)
    end)
end

-- สร้าง 3 ปุ่ม
CreateToggle("🎯 Aimbot (เปิดแล้วล็อกเลย)", function(v) 
    Settings.Aimbot.Enabled = v 
    InfoLabel.Text = "FOV: " .. Settings.Aimbot.FOV .. "°  |  Smooth: " .. Settings.Aimbot.Smoothness
end)
CreateToggle("🔨 ทะลุผนัง", function(v) Settings.NoClip.Enabled = v end)
CreateToggle("👁️ มองทะลุ (กล่อง+ระยะ)", function(v) Settings.ESP.Enabled = v end)

-- เปิด-ปิดเมนู
local MenuOpen = true
FloatBtn.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
end)

-- ======================================
-- 👁️ มองทะลุ
-- ======================================
local HasDraw, DrawingLib = pcall(function() return Drawing end)
local function UpdateESP()
    if not HasDraw or not Settings.ESP.Enabled then
        for _, d in pairs(State.ESPData) do
            if d.Box then d.Box.Visible = false end
            if d.Text then d.Text.Visible = false end
        end
        return
    end

    local idx = 0
    for _, Plr in pairs(Players:GetPlayers()) do
        if Plr ~= LocalPlayer and Plr.Character then
            local Root = Plr.Character:FindFirstChild("HumanoidRootPart")
            local Hum = Plr.Character:FindFirstChild("Humanoid")
            local Head = Plr.Character:FindFirstChild("Head")
            if Root and Hum and Hum.Health > 0 and Head then
                idx += 1
                local rPos, rOnScrn = Camera:WorldToViewportPoint(Root.Position)
                local hPos, hOnScrn = Camera:WorldToViewportPoint(Head.Position)
                if rOnScrn and hOnScrn then
                    local dist = math.floor((Camera.CFrame.Position - Root.Position).Magnitude)
                    if dist > 150 then goto skip end
                    local h = math.abs(rPos.Y - hPos.Y) * 2.5
                    local w = h * 0.6
                    local cx, cy = rPos.X, (rPos.Y + hPos.Y) / 2

                    if not State.ESPData[idx] then
                        State.ESPData[idx] = {
                            Box = DrawingLib.new("Square"),
                            Text = DrawingLib.new("Text")
                        }
                        State.ESPData[idx].Box.Color = Color3.fromRGB(50, 255, 50)
                        State.ESPData[idx].Box.Thickness = 1.5
                        State.ESPData[idx].Box.Filled = false
                        State.ESPData[idx].Text.Color = Color3.new(1,1,1)
                        State.ESPData[idx].Text.Center = true
                        State.ESPData[idx].Text.Outline = true
                        State.ESPData[idx].Text.Size = 12
                    end

                    local d = State.ESPData[idx]
                    d.Box.Visible = true
                    d.Box.Size = Vector2.new(w, h)
                    d.Box.Position = Vector2.new(cx - w/2, cy - h/2)
                    d.Text.Visible = true
                    d.Text.Position = Vector2.new(cx, cy - h/2 - 16)
                    d.Text.Text = dist .. "m"
                    ::skip::
                end
            end
        end
    end
    for i = idx + 1, #State.ESPData do
        local d = State.ESPData[i]
        if d then
            if d.Box then d.Box.Visible = false end
            if d.Text then d.Text.Visible = false end
        end
    end
end

-- ======================================
-- 🔄 ลูปหลัก — ทำงานตลอดเวลา
-- ======================================
RunService.RenderStepped:Connect(function(dt)
    local Character = LocalPlayer.Character
    if not Character then return end

    -- ===== ทะลุผนัง
    if Settings.NoClip.Enabled then
        for _, Part in pairs(Character:GetChildren()) do
            if Part:IsA("BasePart") then
                if State.OriginalCollisions[Part] == nil then
                    State.OriginalCollisions[Part] = Part.CanCollide
                end
                Part.CanCollide = false
            end
        end
    else
        for Part, Orig in pairs(State.OriginalCollisions) do
            if Part then Part.CanCollide = Orig end
        end
        table.clear(State.OriginalCollisions)
    end

    -- ===== 🎯 AIMBOT — เปิดแล้วทำงานเลย!
    local Target = GetBestTarget()
    if Target then
        local DesiredCFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(DesiredCFrame, Settings.Aimbot.Smoothness * dt * 60)
    end

    -- ===== มองทะลุ
    UpdateESP()
end)

print("✅ โหลดสำเร็จ!")
print("🎯 Aimbot: เปิดปุ๊บ ล็อกเป้าเลย ไม่ต้องกดอะไรเพิ่ม")
print("⚙️ ปรับ FOV/Smooth ได้ในโค้ด")
print("💡 แตะ ⚡ ทางซ้ายเพื่อซ่อน/แสดงเมนู")
