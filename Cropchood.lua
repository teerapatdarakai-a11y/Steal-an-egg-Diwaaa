-- ==============================================================================
-- DELTA HUB - MM2 MASTER PRO EDITION (Complete with Toggle UI & Full Kill Switch)
-- ==============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ตัวแปรควบคุมสถานะ (Settings)
local AimbotEnabled = false
local WallCheckEnabled = true
local LockThroughWalls = false
local ShootThroughWalls = false
local ESPBoxEnabled = true
local NoclipEnabled = false

local CachedTarget = nil
local LastCheckTick = 0
local CheckInterval = 0.05

-- 1. สร้าง UI หน้าต่างหลักและปุ่มลอย
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaHub_MasterPro_Ultimate"
ScreenGui.ResetOnSpawn = false
if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

-- ปุ่มไอคอนลอยเปิด-ปิด UI (กดสลับซ่อน/แสดงเมนู)
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 52, 0, 52)
FloatingBtn.Position = UDim2.new(0, 30, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
FloatingBtn.Text = "⚡"
FloatingBtn.TextSize = 26
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner", FloatingBtn)
FloatCorner.CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = Color3.fromRGB(46, 204, 113)
FloatStroke.Thickness = 2

-- หน้าต่างเมนูหลัก
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 270, 0, 465) -- ขยายความสูงเพิ่มรองรับปุ่มปิดทั้งหมด
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -232)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(45, 45, 65)
MainStroke.Thickness = 1.5

-- แถบหัวข้อด้านบน
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "⚡ DELTA HUB | MASTER PRO"
Title.TextColor3 = Color3.fromRGB(46, 204, 113)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- เส้นคั่นหัวข้อ
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -30, 0, 1)
Divider.Position = UDim2.new(0, 15, 0, 45)
Divider.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

-- ฟังก์ชันสร้างปุ่มเมนูดีไซน์สวยหรู
local function CreateMenuButton(posY, defaultText, inactiveColor)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -30, 0, 42)
    btn.Position = UDim2.new(0, 15, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    btn.Text = defaultText
    btn.TextColor3 = inactiveColor
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(45, 45, 65)
    stroke.Thickness = 1
    
    return btn, stroke
end

-- สร้างปุ่มฟังก์ชันต่างๆ
local ToggleBtn, Stroke1 = CreateMenuButton(60, "Aimbot : OFF ❌", Color3.fromRGB(255, 100, 100))
local WallCheckBtn, Stroke2 = CreateMenuButton(110, "WallCheck : ON ✅", Color3.fromRGB(100, 255, 100))
local LockWallBtn, Stroke3 = CreateMenuButton(160, "Lock Through Walls : OFF ❌", Color3.fromRGB(255, 100, 100))
local ShootWallBtn, Stroke4 = CreateMenuButton(210, "Shoot/Knife Through : OFF ❌", Color3.fromRGB(255, 100, 100))
local ESPBtn, Stroke5 = CreateMenuButton(260, "ESP Box + Distance : ON ✅", Color3.fromRGB(100, 255, 100))
local NoclipBtn, Stroke6 = CreateMenuButton(310, "Smart Noclip : OFF ❌", Color3.fromRGB(255, 100, 100))

-- [ปุ่มใหม่] ปุ่มกากบาทปิดทุกอย่าง (Kill Switch / Unload Script)
local CloseAllBtn, Stroke7 = CreateMenuButton(365, "❌ ปิดการทำงานทั้งหมด & ปิด UI", Color3.fromRGB(255, 70, 70))
CloseAllBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)

-- ฟังก์ชันจัดการสลับสถานะปุ่ม
local function UpdateButtonState(btn, stroke, state, activeText, inactiveText, activeColor)
    if state then
        btn.Text = activeText
        btn.TextColor3 = activeColor
        stroke.Color = activeColor
    else
        btn.Text = inactiveText
        btn.TextColor3 = Color3.fromRGB(255, 100, 100)
        stroke.Color = Color3.fromRGB(45, 45, 65)
    end
end

-- เชื่อมโยงปุ่มกดแต่ละอัน
ToggleBtn.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    UpdateButtonState(ToggleBtn, Stroke1, AimbotEnabled, "Aimbot : ON ✅", "Aimbot : OFF ❌", Color3.fromRGB(100, 255, 100))
    if not AimbotEnabled then CachedTarget = nil end
end)

WallCheckBtn.MouseButton1Click:Connect(function()
    WallCheckEnabled = not WallCheckEnabled
    UpdateButtonState(WallCheckBtn, Stroke2, WallCheckEnabled, "WallCheck : ON ✅", "WallCheck : OFF ❌", Color3.fromRGB(100, 255, 100))
end)

LockWallBtn.MouseButton1Click:Connect(function()
    LockThroughWalls = not LockThroughWalls
    UpdateButtonState(LockWallBtn, Stroke3, LockThroughWalls, "Lock Through Walls : ON 🔥", "Lock Through Walls : OFF ❌", Color3.fromRGB(255, 165, 0))
end)

ShootWallBtn.MouseButton1Click:Connect(function()
    ShootThroughWalls = not ShootThroughWalls
    UpdateButtonState(ShootWallBtn, Stroke4, ShootThroughWalls, "Shoot/Knife Through : ON 🚀", "Shoot/Knife Through : OFF ❌", Color3.fromRGB(0, 255, 255))
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESPBoxEnabled = not ESPBoxEnabled
    UpdateButtonState(ESPBtn, Stroke5, ESPBoxEnabled, "ESP Box + Distance : ON ✅", "ESP Box + Distance : OFF ❌", Color3.fromRGB(100, 255, 100))
end)

NoclipBtn.MouseButton1Click:Connect(function()
    NoclipEnabled = not NoclipEnabled
    UpdateButtonState(NoclipBtn, Stroke6, NoclipEnabled, "Smart Noclip : ON 👻", "Smart Noclip : OFF ❌", Color3.fromRGB(155, 89, 182))
end)

-- ตัวแปรเก็บการเชื่อมต่อ Connections ทั้งหมดเพื่อใช้ยกเลิกการทำงานเมื่อกดปิด
local Connections = {}

-- ฟังก์ชันสำหรับทำลายทุกอย่างทิ้งแบบหมดจด (Kill Switch)
local function UnloadScript()
    -- ปิดสถานะการทำงานทั้งหมด
    AimbotEnabled = false
    WallCheckEnabled = false
    LockThroughWalls = false
    ShootThroughWalls = false
    ESPBoxEnabled = false
    NoclipEnabled = false
    
    -- ตัดการเชื่อมต่อลูปการทำงานทั้งหมด
    for _, conn in ipairs(Connections) do
        if conn and conn.Connected then
            conn:Disconnect()
        end
    end
    
    -- ลบเส้น ESP Drawing ทั้งหมดบนหน้าจอทันที
    pcall(function()
        for _, cache in pairs(ESPCache) do
            if cache.Box then cache.Box:Remove() end
            if cache.DistanceText then cache.DistanceText:Remove() end
        end
    end)
    
    -- คืนค่าการชนของตัวละครให้เป็นปกติ
    local myChar = LocalPlayer.Character
    if myChar then
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    -- ลบหน้าต่าง UI และปุ่มลอยทั้งหมดออกจากจอ
    ScreenGui:Destroy()
end

-- กดปุ่มกากบาทเพื่อปิดทุกอย่าง
CloseAllBtn.MouseButton1Click:Connect(UnloadScript)

-- ปุ่มไอคอนลอย: กดเพื่อซ่อน/เปิดแสดงหน้าต่างเมนูหลัก
local menuVisible = true
FloatingBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    MainFrame.Visible = menuVisible
end)

-- 2. ระบบแคช Drawing สำหรับ ESP กล่องเขียวและระยะทาง
local ESPCache = {}

local function CreateESP(player)
    if ESPCache[player] then return ESPCache[player] end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(46, 204, 113)
    box.Thickness = 1.5
    box.Filled = false

    local distText = Drawing.new("Text")
    distText.Visible = false
    distText.Color = Color3.fromRGB(46, 204, 113)
    distText.Size = 13
    distText.Center = true
    distText.Outline = true

    local cache = {Box = box, DistanceText = distText}
    ESPCache[player] = cache
    return cache
end

local function RemoveESP(player)
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].DistanceText then ESPCache[player].DistanceText:Remove() end
        ESPCache[player] = nil
    end
end

table.insert(Connections, Players.PlayerRemoving:Connect(RemoveESP))

-- 3. ฟังก์ชันตรวจสอบการมองเห็น (Raycast เริ่มจากตำแหน่งกล้องจริง)
local function IsVisible(targetPart)
    if LockThroughWalls then return true end
    if not WallCheckEnabled then return true end
    
    local myChar = LocalPlayer.Character
    if not myChar then return false end
    
    local origin = Camera.CFrame.Position 
    local destination = targetPart.Position
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {myChar, targetPart.Parent}
    raycastParams.IgnoreWater = true
    
    local result = Workspace:Raycast(origin, destination - origin, raycastParams)
    return result == nil
end

-- 4. ฟังก์ชันหาเป้าหมายที่ใกล้ที่สุด (ล็อกหัว)
local function GetClosestTarget()
    local target = nil
    local shortestDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local pChar = player.Character
            local humanoid = pChar:FindFirstChild("Humanoid")
            local head = pChar:FindFirstChild("Head")
            
            if humanoid and humanoid.Health > 0 and head then
                if IsVisible(head) then
                    local distance = (myChar.HumanoidRootPart.Position - head.Position).Magnitude
                    if distance < shortestDist then
                        shortestDist = distance
                        target = head
                    end
                end
            end
        end
    end
    return target
end

-- 5. ระบบ Noclip และ Shoot Through Walls
table.insert(Connections, RunService.Stepped:Connect(function()
    local myChar = LocalPlayer.Character
    if not myChar then return end

    if ShootThroughWalls then
        local tool = myChar:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                for _, v in ipairs(tool:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end)
        end
    end

    if NoclipEnabled then
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        local hrp = myChar:FindFirstChild("HumanoidRootPart")
        if hrp then
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = {myChar}
            local result = Workspace:Raycast(hrp.Position, Vector3.new(0, -10, 0), rayParams)
            if result and result.Instance then
                result.Instance.CanCollide = true
            end
        end
    end
end))

-- 6. ลูปการทำงานหลัก (RenderStepped) ควบคุม ESP และ Aimbot
table.insert(Connections, RunService.RenderStepped:Connect(function()
    -- จัดการส่วน ESP Box และ Distance
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pChar = player.Character
            local cache = CreateESP(player)
            
            if ESPBoxEnabled and pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                local rootPart = pChar.HumanoidRootPart
                local vector, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

                if onScreen then
                    local head = pChar:FindFirstChild("Head")
                    local topPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                    local bottomPos = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

                    local height = math.abs(topPos.Y - bottomPos.Y)
                    local width = height / 2

                    cache.Box.Size = Vector2.new(width, height)
                    cache.Box.Position = Vector2.new(vector.X - width / 2, topPos.Y)
                    cache.Box.Visible = true

                    local distance = math.floor((Camera.CFrame.Position - rootPart.Position).Magnitude)
                    cache.DistanceText.Text = "[" .. distance .. "m]"
                    cache.DistanceText.Position = Vector2.new(vector.X, bottomPos.Y + 4)
                    cache.DistanceText.Visible = true
                else
                    cache.Box.Visible = false
                    cache.DistanceText.Visible = false
                end
            else
                cache.Box.Visible = false
                cache.DistanceText.Visible = false
            end
        end
    end

    -- จัดการส่วน Aimbot
    if not AimbotEnabled then return end
    
    local currentTime = tick()
    if currentTime - LastCheckTick >= CheckInterval then
        LastCheckTick = currentTime
        CachedTarget = GetClosestTarget()
    end
    
    if CachedTarget and CachedTarget.Parent and CachedTarget.Parent:FindFirstChild("Humanoid") and CachedTarget.Parent.Humanoid.Health > 0 then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, CachedTarget.Position)
    else
        CachedTarget = nil
    end
end))
