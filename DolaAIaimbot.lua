-- ========================================================
-- 🎯 PRO AIMBOT v2.0
-- ฟีเจอร์ครบ: FOV / Smooth / Prediction / WallCheck / Priority
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = workspace
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ⚙️ การตั้งค่าแบบโปร — ปรับทุกอย่างได้
local Aimbot = {
    -- หลัก
    Enabled = false,
    ActivationMode = "Hold",          -- Hold = กดค้าง | Toggle = กดครั้งเดียว | Always = ตลอดเวลา
    ActivationKey = Enum.KeyCode.E,   -- ปุ่มใช้งาน
    
    -- FOV (พื้นที่ตรงกลางจอที่จะจับเป้า)
    FOV = 100,                        -- รัศมี FOV
    ShowFOVCircle = false,            -- แสดงวงกลม FOV บนจอ
    
    -- ความลื่น
    Smoothness = 0.25,                -- ความเร็วในการล็อค (0.1=เร็วมาก, 1.0=ช้ามาก)
    SmoothType = "Linear",            -- Linear = ตรงๆ | Exponential = เร็วปลาย | Humanized = เลียนแบบคน
    MaxDistance = 500,                -- ระยะสูงสุดที่จะล็อค
    
    -- จุดล็อค
    AimPart = "Head",                 -- Head / Torso / HumanoidRootPart
    AimPartPriority = {"Head", "Torso", "HumanoidRootPart"}, -- ลำดับความสำคัญ
    PreferVisiblePart = true,         -- เลือกจุดที่เห็นชัดที่สุด
    
    -- ตัวกรองเป้าหมาย
    TeamCheck = true,                 -- ไม่ล็อคเพื่อนร่วมทีม
    WallCheck = false,                -- ไม่ล็อคเป้าที่อยู่หลังกำแพง
    DeadCheck = true,                 -- ไม่ล็อคคนที่ตายแล้ว
    MaxHealth = 100,                  -- ไม่ล็อคถ้าเลือดเกินค่านี้
    
    -- การเลือกเป้าหมาย
    Priority = "FOV",                 -- FOV = ใกล้กลางจอที่สุด | Distance = ใกล้ตัวเราที่สุด | Health = เลือดน้อยที่สุด
    MultiTarget = false,              -- ล็อคหลายเป้าหมายพร้อมกัน
    
    -- การคาดการณ์ (สำหรับเป้าที่วิ่ง)
    Prediction = {
        Enabled = true,
        Factor = 0.12,                -- ความเข้มการคาดการณ์
        MaxSpeed = 18,                -- ความเร็วสูงสุดของเป้า
    },
    
    -- การล็อค
    KeepLock = true,                  -- ค้างล็อคเป้าเดิมไว้ จนกว่าจะหลุดออกจาก FOV
    ReacquireTime = 0.35,             -- เวลารอกลับมาล็อคเป้าเดิม
    SwitchTargetDelay = 0.15,         -- หน่วงเวลาเปลี่ยนเป้าหมาย
    
    -- มองทะลุ
    IgnoreTransparent = true,         -- มองทะลุผนังบาง/โปร่งแสง
    IgnoreWater = true,               -- มองทะลุน้ำ
}

-- 📐 วาดวงกลม FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Radius = Aimbot.FOV
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)

-- 📦 ตัวแปรสถานะ
local State = {
    LastTarget = nil,
    LastTargetTime = 0,
    CurrentTarget = nil,
    LastMousePos = Vector2.new(0, 0),
    LastUpdate = os.clock(),
    TargetCache = {},
    IsActive = false
}

-- 🔧 ฟังก์ชันช่วยเหลือ
local function Distance2D(a, b)
    return math.sqrt((a.X - b.X)^2 + (a.Y - b.Y)^2)
end

local function IsPartVisible(From, To)
    local Dir = (To - From).Unit
    local Dist = (To - From).Magnitude
    local Params = RaycastParams.new()
    Params.FilterDescendantsInstances = {LocalPlayer.Character}
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.IgnoreWater = Aimbot.IgnoreWater
    
    local Result = Workspace:Raycast(From, Dir * Dist, Params)
    if not Result then return true end
    if Aimbot.IgnoreTransparent and Result.Instance then
        local Trans = Result.Instance:IsA("BasePart") and Result.Instance.Transparency or 0
        if Trans > 0.5 then return true end
    end
    return false
end

local function GetValidParts(Character)
    local Parts = {}
    for _, Name in ipairs(Aimbot.AimPartPriority) do
        local Part = Character:FindFirstChild(Name)
        if Part then table.insert(Parts, Part) end
    end
    return Parts
end

-- 🔍 ค้นหาเป้าหมาย — แบบละเอียด
local function FindTarget()
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local BestTarget, BestPart, BestScore = nil, nil, math.huge

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player == LocalPlayer then continue end
        if Aimbot.TeamCheck and Player.Team == LocalPlayer.Team then continue end
        
        local Character = Player.Character
        if not Character then continue end
        
        local Humanoid = Character:FindFirstChild("Humanoid")
        if not Humanoid then continue end
        if Aimbot.DeadCheck and Humanoid.Health <= 0 then continue end
        if Humanoid.Health > Aimbot.MaxHealth then continue end
        
        local MyRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local TheirRoot = Character:FindFirstChild("HumanoidRootPart")
        if not MyRoot or not TheirRoot then continue end
        
        -- เช็คระยะ
        local Dist3D = (MyRoot.Position - TheirRoot.Position).Magnitude
        if Dist3D > Aimbot.MaxDistance then continue end
        
        -- ลูปหาจุดที่ดีที่สุด
        local ValidParts = GetValidParts(Character)
        for _, Part in ipairs(ValidParts) do
            local Pos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            if not OnScreen or Pos.Z < 0 then continue end
            
            -- เช็ค FOV
            local Dist2D = Distance2D(Vector2.new(Pos.X, Pos.Y), ScreenCenter)
            if Dist2D > Aimbot.FOV then continue end
            
            -- เช็คกำแพง
            if Aimbot.WallCheck then
                local CamPos = Camera.CFrame.Position
                if not IsPartVisible(CamPos, Part.Position) then continue end
            end
            
            -- คำนวณคะแนนตามลำดับความสำคัญ
            local Score
            if Aimbot.Priority == "FOV" then
                Score = Dist2D
            elseif Aimbot.Priority == "Distance" then
                Score = Dist3D
            elseif Aimbot.Priority == "Health" then
                Score = Humanoid.Health
            end
            
            -- ให้คะแนนดีกว่าถ้าเป็นเป้าเดิม
            if State.LastTarget == Player and os.clock() - State.LastTargetTime < Aimbot.ReacquireTime then
                Score *= 0.2
            end
            
            if Score < BestScore then
                BestScore = Score
                BestTarget = Player
                BestPart = Part
            end
            
            -- หยุดเมื่อเจอจุดที่เห็นได้ดีที่สุด
            if Aimbot.PreferVisiblePart then break end
        end
    end
    
    return BestTarget, BestPart
end

-- 📐 คำนวณตำแหน่งเป้าหมายพร้อมคาดการณ์
local function GetAimPosition(TargetPart)
    local Pos = TargetPart.Position
    
    -- เพิ่มการคาดการณ์การเคลื่อนที่
    if Aimbot.Prediction.Enabled then
        local Assembler = TargetPart:FindFirstChild("AssemblyLinearVelocity")
        if Assembler then
            local Velocity = Assembler.AssemblyLinearVelocity
            local Speed = Velocity.Magnitude
            if Speed < Aimbot.Prediction.MaxSpeed then
                Pos += Velocity * Aimbot.Prediction.Factor
            end
        end
    end
    
    return Pos
end

-- 🎯 หมุนกล้องไปหาเป้า
local function AimAt(TargetPos, DeltaTime)
    local CamPos = Camera.CFrame.Position
    local DesiredCFrame = CFrame.new(CamPos, TargetPos)
    
    -- เลือกสูตรการลื่น
    local Alpha
    if Aimbot.SmoothType == "Linear" then
        Alpha = math.min(1, Aimbot.Smoothness * DeltaTime * 60)
    elseif Aimbot.SmoothType == "Exponential" then
        Alpha = 1 - math.pow(1 - Aimbot.Smoothness, DeltaTime * 60)
    elseif Aimbot.SmoothType == "Humanized" then
        local Distance = (DesiredCFrame.LookVector - Camera.CFrame.LookVector).Magnitude
        local Adjusted = Aimbot.Smoothness * (0.8 + Distance * 0.2)
        Alpha = math.min(1, Adjusted * DeltaTime * 60)
    end
    
    Camera.CFrame = Camera.CFrame:Lerp(DesiredCFrame, Alpha)
end

-- 🔘 จัดการปุ่มกด
UserInputService.InputBegan:Connect(function(Input, gp)
    if gp then return end
    if Input.KeyCode == Aimbot.ActivationKey then
        if Aimbot.ActivationMode == "Toggle" then
            Aimbot.Enabled = not Aimbot.Enabled
            State.IsActive = Aimbot.Enabled
        else
            State.IsActive = true
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input, gp)
    if gp then return end
    if Input.KeyCode == Aimbot.ActivationKey and Aimbot.ActivationMode == "Hold" then
        State.IsActive = false
    end
end)

-- 🔄 ลูปหลักทำงาน
RunService.RenderStepped:Connect(function(DeltaTime)
    -- อัปเดตวงกลม FOV
    FOVCircle.Visible = Aimbot.ShowFOVCircle
    FOVCircle.Radius = Aimbot.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    -- ปิดถ้าไม่ใช้งาน
    if not Aimbot.Enabled or not State.IsActive then
        if State.CurrentTarget then
            State.LastTarget = State.CurrentTarget
            State.LastTargetTime = os.clock()
        end
        State.CurrentTarget = nil
        return
    end
    
    -- ค้นหาเป้าหมาย
    local TargetPlayer, TargetPart = FindTarget()
    
    -- เปลี่ยนเป้าหมายพร้อมหน่วงเวลา
    if TargetPart then
        if State.CurrentTarget ~= TargetPlayer then
            if not State.SwitchTime or os.clock() - State.SwitchTime > Aimbot.SwitchTargetDelay then
                State.CurrentTarget = TargetPlayer
                State.SwitchTime = os.clock()
            end
        end
        
        -- คำนวณตำแหน่งและล็อค
        local AimPos = GetAimPosition(TargetPart)
        AimAt(AimPos, DeltaTime)
    else
        -- ไม่มีเป้าหมาย
        if State.CurrentTarget then
            State.LastTarget = State.CurrentTarget
            State.LastTargetTime = os.clock()
        end
        State.CurrentTarget = nil
    end
end)

-- 📋 คำสั่งชุดปรับไว้ใช้งาน
_G.AimbotSettings = Aimbot

print("✅ PRO AIMBOT v2.0 พร้อมใช้งาน!")
print("⌨️ กดปุ่ม E เพื่อล็อคเป้าหมาย")
print("📐 ปรับค่าได้ที่ _G.AimbotSettings")
