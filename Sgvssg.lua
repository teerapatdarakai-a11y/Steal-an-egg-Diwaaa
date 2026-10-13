-- =============================================
-- 🟢 Dola ESP + Aimbot
-- มือถือ | 2 สวิตช์ | ปิดระบบทั้งหมดได้
-- =============================================

if not Drawing or not getgenv then
    print("⚠️ Executor ไม่รองรับ Drawing API")
    return
end

-- ป้องกันรันซ้ำ + ทำความสะอาดเก่า
if getgenv().Dola_Cleanup then
    getgenv().Dola_Cleanup()
end

-- ตัวแปรหลัก
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ⚙️ ตัวเลือก
local Config = {
    ESPEnabled = true,
    AimbotEnabled = false,
    TeamCheck = true,
    AimPart = "Head",
    FOV = 140,
    BoxColor = Color3.fromRGB(0, 255, 0),
    TextColor = Color3.fromRGB(255, 255, 255)
}

local ESP_Objects = {}
local Connections = {}
local UI = nil
local MenuVisible = true

-- 🧹 ฟังก์ชันทำความสะอาดทั้งระบบ
local function FullCleanup()
    -- หยุดลูปทั้งหมด
    for _, conn in pairs(Connections) do
        conn:Disconnect()
    end
    table.clear(Connections)

    -- ลบ ESP ทั้งหมด
    for _, data in pairs(ESP_Objects) do
        if data.Box then data.Box:Remove() end
        if data.Distance then data.Distance:Remove() end
    end
    table.clear(ESP_Objects)

    -- ลบ UI
    if UI then
        UI:Destroy()
        UI = nil
    end

    -- ลบตัวแปร
    getgenv().DolaESP_UI = nil
    getgenv().Dola_Connection = nil
    getgenv().Dola_Cleanup = nil
    getgenv().Dola_Loaded = nil

    print("✅ ปิดระบบทั้งหมดเรียบร้อย")
end
getgenv().Dola_Cleanup = FullCleanup
getgenv().Dola_Loaded = true

-- =============================================
-- 🎨 สร้าง UI
-- =============================================
UI = Instance.new("ScreenGui")
UI.Name = "Dola_Menu"
UI.ResetOnSpawn = false
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if gethui then
    UI.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(UI)
    UI.Parent = CoreGui
else
    UI.Parent = CoreGui
end
getgenv().DolaESP_UI = UI

-- 🟢 ปุ่มลอยเปิดเมนู
local BtnFloat = Instance.new("TextButton")
BtnFloat.Size = UDim2.new(0, 50, 0, 50)
BtnFloat.Position = UDim2.new(0, 15, 0.5, 0)
BtnFloat.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
BtnFloat.Text = "🟢"
BtnFloat.TextSize = 22
BtnFloat.Font = Enum.Font.GothamBold
BtnFloat.Active = true
BtnFloat.Draggable = true
BtnFloat.Parent = UI
Instance.new("UICorner", BtnFloat).CornerRadius = UDim.new(1, 0)

-- 📋 หน้าต่างเมนู
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 200)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.Parent = UI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

-- แถบหัว
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Dola ESP + Aimbot"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- ❌ ปุ่มปิดระบบทั้งหมด
local CloseAllBtn = Instance.new("TextButton")
CloseAllBtn.Size = UDim2.new(0, 32, 0, 32)
CloseAllBtn.Position = UDim2.new(1, -38, 0.5, -16)
CloseAllBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
CloseAllBtn.Text = "✕"
CloseAllBtn.TextColor3 = Color3.new(1,1,1)
CloseAllBtn.TextSize = 16
CloseAllBtn.Font = Enum.Font.GothamBold
CloseAllBtn.Parent = TopBar
Instance.new("UICorner", CloseAllBtn).CornerRadius = UDim.new(0, 8)

-- เนื้อหาเมนู
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -50)
Content.Position = UDim2.new(0, 10, 0, 48)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- =============================================
-- 🔘 ฟังก์ชันสร้างสวิตช์
-- =============================================
local function CreateSwitch(label, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 45)
    Container.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    Container.Parent = Content
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 8)

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -60, 1, 0)
    Text.Position = UDim2.new(0, 15, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = label
    Text.TextColor3 = Color3.fromRGB(230, 230, 230)
    Text.Font = Enum.Font.Gotham
    Text.TextSize = 15
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Container

    local SwitchBg = Instance.new("Frame")
    SwitchBg.Size = UDim2.new(0, 44, 0, 24)
    SwitchBg.Position = UDim2.new(1, -58, 0.5, -12)
    SwitchBg.BackgroundColor3 = default and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(80, 80, 100)
    Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
    SwitchBg.Parent = Container

    local SwitchKnob = Instance.new("Frame")
    SwitchKnob.Size = UDim2.new(0, 20, 0, 20)
    SwitchKnob.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    SwitchKnob.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", SwitchKnob).CornerRadius = UDim.new(1, 0)
    SwitchKnob.Parent = SwitchBg

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Container

    local State = default
    Btn.MouseButton1Click:Connect(function()
        State = not State
        SwitchBg.BackgroundColor3 = State and Color3.fromRGB(0, 180, 80) or Color3.fromRGB(80, 80, 100)
        SwitchKnob.Position = State and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        callback(State)
    end)
end

-- =============================================
-- � สร้างสวิตช์ในเมนู
-- =============================================
CreateSwitch("ESP", Config.ESPEnabled, function(v)
    Config.ESPEnabled = v
    if not v then
        for _, data in pairs(ESP_Objects) do
            if data.Box then data.Box.Visible = false end
            if data.Distance then data.Distance.Visible = false end
        end
    end
end)

CreateSwitch("AIMBOT", Config.AimbotEnabled, function(v)
    Config.AimbotEnabled = v
end)

-- =============================================
-- 🔄 เปิด-ปิดเมนู ด้วยปุ่มลอย
-- =============================================
BtnFloat.MouseButton1Click:Connect(function()
    MenuVisible = not MenuVisible
    MainFrame.Visible = MenuVisible
end)

-- =============================================
-- ❌ ปิดระบบทั้งหมด
-- =============================================
CloseAllBtn.MouseButton1Click:Connect(function()
    FullCleanup()
end)

-- =============================================
-- 🎨 ระบบ ESP
-- =============================================
local function ClearPlayerESP(Player)
    if ESP_Objects[Player] then
        if ESP_Objects[Player].Box then ESP_Objects[Player].Box:Remove() end
        if ESP_Objects[Player].Distance then ESP_Objects[Player].Distance:Remove() end
        ESP_Objects[Player] = nil
    end
end

local function SetupPlayerESP(Player)
    if Player == LocalPlayer then return end
    if ESP_Objects[Player] then return end

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Config.BoxColor
    Box.Thickness = 2
    Box.Filled = false

    local DistText = Drawing.new("Text")
    DistText.Visible = false
    DistText.Color = Config.TextColor
    DistText.Size = 13
    DistText.Center = true
    DistText.Outline = true

    ESP_Objects[Player] = {Box = Box, Distance = DistText}
end

-- =============================================
-- 🎯 หาเป้าหมาย Aimbot
-- =============================================
local function FindTarget()
    local BestTarget, BestDist = nil, Config.FOV
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if Config.TeamCheck and Player.Team == LocalPlayer.Team then continue end
        
        local Char = Player.Character
        if not Char or not Char:FindFirstChild("Humanoid") or Char.Humanoid.Health <= 0 then continue end
        
        local AimPart = Char:FindFirstChild(Config.AimPart)
        if not AimPart then continue end
        
        local Pos, OnScreen = Camera:WorldToViewportPoint(AimPart.Position)
        if not OnScreen then continue end
        
        local Dist = (Vector2.new(Pos.X, Pos.Y) - ScreenCenter).Magnitude
        if Dist < BestDist then
            BestDist = Dist
            BestTarget = AimPart
        end
    end
    return BestTarget
end

-- =============================================
-- 🔄 ลูปหลัก
-- =============================================
local MainConnection = RunService.RenderStepped:Connect(function()
    -- อัปเดต ESP
    if Config.ESPEnabled then
        for _, Player in ipairs(Players:GetPlayers()) do
            if Player == LocalPlayer then continue end
            local Char = Player.Character
            local MyChar = LocalPlayer.Character

            if not Char or not MyChar 
            or not Char:FindFirstChild("HumanoidRootPart") 
            or not Char:FindFirstChild("Humanoid")
            or Char.Humanoid.Health <= 0 then
                ClearPlayerESP(Player)
                continue
            end

            if Config.TeamCheck and Player.Team == LocalPlayer.Team then
                ClearPlayerESP(Player)
                continue
            end

            SetupPlayerESP(Player)
            local Data = ESP_Objects[Player]
            local Root = Char.HumanoidRootPart
            local MyRoot = MyChar:FindFirstChild("HumanoidRootPart")
            local Vec, OnScreen = Camera:WorldToViewportPoint(Root.Position)

            if OnScreen then
                local Dist = (MyRoot.Position - Root.Position).Magnitude
                local Scale = 1400 / Vec.Z
                local H = Scale * 1.7
                local W = Scale

                Data.Box.Position = Vector2.new(Vec.X - W/2, Vec.Y - H/2)
                Data.Box.Size = Vector2.new(W, H)
                Data.Box.Visible = true

                Data.Distance.Text = string.format("%.0f ม.", Dist)
                Data.Distance.Position = Vector2.new(Vec.X, Vec.Y + H/2 + 5)
                Data.Distance.Visible = true
            else
                Data.Box.Visible = false
                Data.Distance.Visible = false
            end
        end
    else
        for _, data in pairs(ESP_Objects) do
            data.Box.Visible = false
            data.Distance.Visible = false
        end
    end

    -- Aimbot
    if Config.AimbotEnabled then
        local Target = FindTarget()
        if Target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position)
        end
    end
end)

table.insert(Connections, MainConnection)

-- ลบเมื่อผู้เล่นออก
Players.PlayerRemoving:Connect(ClearPlayerESP)

print("✅ พร้อมใช้งาน!")
print("🟢 แตะปุ่มลอยเพื่อเปิด/ปิดเมนู")
print("✕ กดกากบาทเพื่อปิดระบบทั้งหมด")
