-- ========================================================
-- 🎯 WORKING VERSION — รันแล้วเห็นเมนูทันที
-- เปิด Aimbot = ทำงานเลย มี FOV + Smoothness
-- ========================================================

print("🚀 กำลังโหลด...")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ลบเก่าทิ้งก่อน
if PlayerGui:FindFirstChild("AimbotHub") then
    PlayerGui.AimbotHub:Destroy()
end

-- ⚙️ ตั้งค่า
local Settings = {
    Aimbot = {
        Enabled = false,
        FOV = 85,
        Smoothness = 0.35,
        MaxDistance = 120
    },
    NoClip = false,
    ESP = false
}

local OriginalCollisions = {}

-- 📱 สร้างเมนู
local Gui = Instance.new("ScreenGui")
Gui.Name = "AimbotHub"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

-- กล่องเมนูหลัก
local MainBox = Instance.new("Frame")
MainBox.Size = UDim2.new(0, 260, 0, 230)
MainBox.Position = UDim2.new(0.05, 0, 0.15, 0)
MainBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainBox.BorderSizePixel = 0
MainBox.Parent = Gui
Instance.new("UICorner", MainBox).CornerRadius = UDim.new(0, 12)

-- หัว
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
Title.Text = "🎯 AIMBOT HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainBox
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

-- ข้อมูล
local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1, -20, 0, 25)
Info.Position = UDim2.new(0, 10, 0, 55)
Info.BackgroundTransparency = 1
Info.Text = "FOV: "..Settings.Aimbot.FOV.."°  |  Smooth: "..Settings.Aimbot.Smoothness
Info.TextColor3 = Color3.fromRGB(120, 200, 255)
Info.Font = Enum.Font.Gotham
Info.TextSize = 11
Info.Parent = MainBox

-- ฟังก์ชันสร้างปุ่ม
local function MakeButton(text, yPos, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -20, 0, 40)
    Btn.Position = UDim2.new(0, 10, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    Btn.Text = "❌ "..text
    Btn.TextColor3 = Color3.new(1,1,1)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13
    Btn.AutoLocalize = false
    Btn.Parent = MainBox
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    local IsOn = false
    Btn.MouseButton1Click:Connect(function()
        IsOn = not IsOn
        Btn.Text = (IsOn and "✅ " or "❌ ")..text
        Btn.BackgroundColor3 = IsOn and color or Color3.fromRGB(60, 60, 75)
        callback(IsOn)
    end)
end

-- สร้าง 3 ปุ่ม
MakeButton("Aimbot (ล็อกอัตโนมัติ)", 85, Color3.fromRGB(40, 160, 255), function(v)
    Settings.Aimbot.Enabled = v
end)
MakeButton("ทะลุผนัง", 135, Color3.fromRGB(255, 140, 40), function(v)
    Settings.NoClip = v
end)
MakeButton("มองทะลุ (แจ้งระยะ)", 185, Color3.fromRGB(50, 220, 80), function(v)
    Settings.ESP = v
end)

-- 🔍 คำนวณมุม
local function AngleBetween(v1, v2)
    return math.acos(math.clamp(v1.Unit:Dot(v2.Unit), -1, 1))
end

-- 🎯 หาเป้าหมาย
local function GetTarget()
    if not Settings.Aimbot.Enabled then return nil end
    local CamPos = Camera.CFrame.Position
    local CamDir = Camera.CFrame.LookVector
    local Best, BestAngle = nil, math.rad(Settings.Aimbot.FOV)

    for _, Plr in pairs(Players:GetPlayers()) do
        if Plr ~= LocalPlayer and Plr.Character then
            local Head = Plr.Character:FindFirstChild("Head")
            local Root = Plr.Character:FindFirstChild("HumanoidRootPart")
            local Hum = Plr.Character:FindFirstChild("Humanoid")
            if Head and Root and Hum and Hum.Health > 0 then
                local Dist = (CamPos - Root.Position).Magnitude
                if Dist > Settings.Aimbot.MaxDistance then continue end
                local Dir = (Head.Position - CamPos).Unit
                local Ang = AngleBetween(CamDir, Dir)
                if Ang < BestAngle then
                    BestAngle = Ang
                    Best = Head
                end
            end
        end
    end
    return Best
end

-- 👁️ มองทะลุ
local ESPObjects = {}
local HasDraw, Drawing = pcall(function() return Drawing end)
local function UpdateESP()
    if not HasDraw or not Settings.ESP then
        for _, v in pairs(ESPObjects) do
            if v.Box then v.Box.Visible = false end
            if v.Txt then v.Txt.Visible = false end
        end
        return
    end
    local I = 0
    for _, Plr in pairs(Players:GetPlayers()) do
        if Plr ~= LocalPlayer and Plr.Character then
            local Root = Plr.Character:FindFirstChild("HumanoidRootPart")
            local Head = Plr.Character:FindFirstChild("Head")
            local Hum = Plr.Character:FindFirstChild("Humanoid")
            if Root and Head and Hum and Hum.Health > 0 then
                I += 1
                local RP, RVis = Camera:WorldToViewportPoint(Root.Position)
                local HP, HVis = Camera:WorldToViewportPoint(Head.Position)
                if RVis and HVis then
                    local Dist = math.floor((Camera.CFrame.Position - Root.Position).Magnitude)
                    if Dist > 150 then goto Skip end
                    local H = math.abs(RP.Y - HP.Y) * 2.5
                    local W = H * 0.6
                    local CX, CY = RP.X, (RP.Y + HP.Y) / 2

                    if not ESPObjects[I] then
                        ESPObjects[I] = {
                            Box = Drawing.new("Square"),
                            Txt = Drawing.new("Text")
                        }
                        ESPObjects[I].Box.Color = Color3.fromRGB(50, 255, 50)
                        ESPObjects[I].Box.Thickness = 1.5
                        ESPObjects[I].Box.Filled = false
                        ESPObjects[I].Txt.Color = Color3.new(1,1,1)
                        ESPObjects[I].Txt.Center = true
                        ESPObjects[I].Txt.Outline = true
                        ESPObjects[I].Txt.Size = 12
                    end
                    local Obj = ESPObjects[I]
                    Obj.Box.Visible = true
                    Obj.Box.Size = Vector2.new(W, H)
                    Obj.Box.Position = Vector2.new(CX - W/2, CY - H/2)
                    Obj.Txt.Visible = true
                    Obj.Txt.Position = Vector2.new(CX, CY - H/2 - 16)
                    Obj.Txt.Text = Dist.."m"
                    ::Skip::
                end
            end
        end
    end
    for J = I + 1, #ESPObjects do
        local v = ESPObjects[J]
        if v then
            if v.Box then v.Box.Visible = false end
            if v.Txt then v.Txt.Visible = false end
        end
    end
end

-- 🔄 ลูปหลัก
RunService.RenderStepped:Connect(function(dt)
    local Char = LocalPlayer.Character
    if not Char then return end

    -- ทะลุผนัง
    if Settings.NoClip then
        for _, P in pairs(Char:GetChildren()) do
            if P:IsA("BasePart") then
                if OriginalCollisions[P] == nil then
                    OriginalCollisions[P] = P.CanCollide
                end
                P.CanCollide = false
            end
        end
    else
        for P, Orig in pairs(OriginalCollisions) do
            if P then P.CanCollide = Orig end
        end
        table.clear(OriginalCollisions)
    end

    -- 🎯 Aimbot — เปิดแล้วทำงานเลย
    local Target = GetTarget()
    if Target then
        local Desired = CFrame.new(Camera.CFrame.Position, Target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(Desired, Settings.Aimbot.Smoothness * dt * 60)
    end

    -- มองทะลุ
    UpdateESP()
end)

print("✅ เสร็จสิ้น! เมนูอยู่ที่มุมซ้ายบน แตะปุ่มเพื่อเปิดใช้งาน")
