-- =============================================
-- 🟢 Dola ESP | กล่องเขียว + ระยะทาง
-- เปิด/ปิดได้ | ตรวจทีม | ไม่มีชื่อ
-- =============================================

-- เช็ครองรับ
if not Drawing or not getgenv then
    print("⚠️ Executor ไม่รองรับ Drawing API")
    return
end

-- ป้องกันรันซ้ำ
if getgenv().DolaESPLoaded then
    print("ℹ️ ESP กำลังทำงานอยู่แล้ว")
    return
end
getgenv().DolaESPLoaded = true

-- ทำความสะอาดเก่า
if getgenv().DolaESP_Connection then
    getgenv().DolaESP_Connection:Disconnect()
end
if getgenv().DolaESP_UI then
    getgenv().DolaESP_UI:Destroy()
end

-- บริการหลัก
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ⚙️ ตัวเลือกการทำงาน
local Config = {
    ShowBox = true,
    ShowDistance = true,
    TeamCheck = true,
    BoxColor = Color3.fromRGB(0, 255, 0),
    TextColor = Color3.fromRGB(255, 255, 255)
}

-- 📦 ที่เก็บวัตถุ ESP
local ESP_Objects = {}

-- 🎨 สร้าง UI เมนู
local UI = Instance.new("ScreenGui")
UI.Name = "DolaESP_Menu"
UI.ResetOnSpawn = false
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ป้องกันถูกลบ
if gethui then
    UI.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(UI)
    UI.Parent = CoreGui
else
    UI.Parent = CoreGui
end
getgenv().DolaESP_UI = UI

-- ปุ่มลอย
local BtnFloat = Instance.new("TextButton")
BtnFloat.Size = UDim2.new(0, 45, 0, 45)
BtnFloat.Position = UDim2.new(0, 20, 0.5, 0)
BtnFloat.BackgroundColor3 = Color3.fromRGB(30, 136, 229)
BtnFloat.Text = "🟢"
BtnFloat.TextSize = 20
BtnFloat.Font = Enum.Font.GothamBold
BtnFloat.TextColor3 = Color3.new(1,1,1)
BtnFloat.Active = true
BtnFloat.Draggable = true
BtnFloat.Parent = UI

Instance.new("UICorner", BtnFloat).CornerRadius = UDim.new(1,0)

-- หน้าต่างเมนู
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 260, 0, 220)
MainPanel.Position = UDim2.new(0.5, -130, 0.5, -110)
MainPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
MainPanel.BorderSizePixel = 0
MainPanel.Active = true
MainPanel.Draggable = true
MainPanel.Visible = true
MainPanel.Parent = UI

Instance.new("UICorner", MainPanel).CornerRadius = UDim.new(0, 10)

-- แถบหัว
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 136, 229)
TopBar.Parent = MainPanel
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)
local Tittle = Instance.new("TextLabel")
Tittle.Size = UDim2.new(1,0,1,0)
Tittle.BackgroundTransparency = 1
Tittle.Text = "🟢 Dola ESP"
Tittle.TextColor3 = Color3.new(1,1,1)
Tittle.Font = Enum.Font.GothamBold
Tittle.TextSize = 14
Tittle.Parent = TopBar

-- คอนเทนต์
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -55)
Content.Position = UDim2.new(0, 10, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = MainPanel

-- ฟังก์ชันสร้างปุ่มสลับ
local function MakeToggle(label, default, callback)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 38)
    Container.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Container.Parent = Content
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Text = Instance.new("TextLabel")
    Text.Size = UDim2.new(1, -50, 1, 0)
    Text.Position = UDim2.new(0, 12, 0, 0)
    Text.BackgroundTransparency = 1
    Text.Text = label
    Text.TextColor3 = Color3.fromRGB(230,230,230)
    Text.Font = Enum.Font.Gotham
    Text.TextSize = 13
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.Parent = Container

    local Switch = Instance.new("Frame")
    Switch.Size = UDim2.new(0, 22, 0, 22)
    Switch.Position = UDim2.new(1, -34, 0.5, -11)
    Switch.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(80,80,100)
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 5)
    Switch.Parent = Container

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1,0,1,0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Container

    local State = default
    Btn.MouseButton1Click:Connect(function()
        State = not State
        Switch.BackgroundColor3 = State and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(80,80,100)
        callback(State)
    end)
end

-- สร้างปุ่มในเมนู
MakeToggle("แสดงกล่อง ESP", Config.ShowBox, function(v)
    Config.ShowBox = v
end)

MakeToggle("แสดงระยะทาง", Config.ShowDistance, function(v)
    Config.ShowDistance = v
end)

MakeToggle("ซ่อนพวกเดียวกัน", Config.TeamCheck, function(v)
    Config.TeamCheck = v
end)

-- สลับเมนูเปิดปิด
local MenuOpen = true
BtnFloat.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    MainPanel.Visible = MenuOpen
end)

-- 🧹 ลบ ESP
local function ClearPlayerESP(Player)
    if ESP_Objects[Player] then
        if ESP_Objects[Player].Box then ESP_Objects[Player].Box:Remove() end
        if ESP_Objects[Player].Distance then ESP_Objects[Player].Distance:Remove() end
        ESP_Objects[Player] = nil
    end
end

-- 🎨 สร้าง/อัปเดต ESP
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

-- 🔄 ลูปหลักทำงาน
getgenv().DolaESP_Connection = RunService.RenderStepped:Connect(function()
    -- อัปเดตผู้เล่นทุกคน
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        local Char = Player.Character
        local MyChar = LocalPlayer.Character

        -- ตรวจสอบเงื่อนไข
        if not Char or not MyChar 
        or not Char:FindFirstChild("HumanoidRootPart") 
        or not Char:FindFirstChild("Humanoid")
        or Char.Humanoid.Health <= 0 then
            ClearPlayerESP(Player)
            continue
        end

        -- ตรวจทีม
        if Config.TeamCheck and Player.Team == LocalPlayer.Team then
            ClearPlayerESP(Player)
            continue
        end

        -- สร้างถ้ายังไม่มี
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

            -- กล่อง
            if Config.ShowBox then
                Data.Box.Position = Vector2.new(Vec.X - W/2, Vec.Y - H/2)
                Data.Box.Size = Vector2.new(W, H)
                Data.Box.Visible = true
            else
                Data.Box.Visible = false
            end

            -- ระยะทาง
            if Config.ShowDistance then
                Data.Distance.Text = string.format("%.0f ม.", Dist)
                Data.Distance.Position = Vector2.new(Vec.X, Vec.Y + H/2 + 4)
                Data.Distance.Visible = true
            else
                Data.Distance.Visible = false
            end
        else
            Data.Box.Visible = false
            Data.Distance.Visible = false
        end
    end
end)

-- ลบเมื่อผู้เล่นออก
Players.PlayerRemoving:Connect(ClearPlayerESP)

print("✅ Dola ESP พร้อมใช้งาน! กดปุ่ม 🟢 เพื่อเปิด/ปิดเมนู")
