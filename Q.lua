-- [[ 1. สั่งถอนรากถอนโคนระบบเก่าและลบวัตถุตกค้างทั้งหมดเพื่อความปลอดภัยสูงสุด ]] --
local CoreGui = game:GetService("CoreGui")
local function SafeWipe(uiName)
    local check = CoreGui:FindFirstChild(uiName)
    if check then check:Destroy() end
end
SafeWipe("StealEggClassicHub")
SafeWipe("StealEggMiniHub")
SafeWipe("StealEggRawUI")

if _G.SpeedConn then _G.SpeedConn:Disconnect() end
if _G.FlyConn then _G.FlyConn:Disconnect() end
if _G.AfkConn then _G.AfkConn:Disconnect() end
if _G.ChatBypassConnection then _G.ChatBypassConnection:Disconnect() end

-- [[ 2. เริ่มต้นค่าระบบแบบซ่อนเร้น (No Asset Creation) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local SuperSpeedEnabled = false
local SpeedMultiplier = 3.0 -- ปรับตัวคูณเดินเร็วตรงนี้
local FlyEnabled = false
local FlySpeed = 150        -- ปรับระดับความเร็วบินตรงนี้

-- ฟังก์ชันรันระบบ CFrame Engine (แก้ระบบคูณทิศทางปุ่มสลับ W/S เรียบร้อย)
local function updateBypassMovement()
    if _G.SpeedConn then _G.SpeedConn:Disconnect(); _G.SpeedConn = nil end
    if _G.FlyConn then _G.FlyConn:Disconnect(); _G.FlyConn = nil end
    
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    -- ลูปรันเดินเร็ว (SPEED)
    if SuperSpeedEnabled and not FlyEnabled then
        _G.SpeedConn = RunService.Heartbeat:Connect(function(deltaTime)
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if h and r and h.MoveDirection.Magnitude > 0 then
                local currentSpeed = h.WalkSpeed
                -- เดินหน้าตรงตามปุ่มควบคุมนิ้วกด
                r.CFrame = r.CFrame + (h.MoveDirection * (currentSpeed * SpeedMultiplier) * deltaTime)
            end
        end)
    end
    
    -- ลูปรันบินพุ่ง (FLY - แก้ปัญหาอาการบินสลับทิศ W เป็น S)
    if FlyEnabled then
        _G.FlyConn = RunService.Heartbeat:Connect(function(deltaTime)
            local c = LocalPlayer.Character
            local r = c and c:FindFirstChild("HumanoidRootPart")
            local h = c and c:FindFirstChildOfClass("Humanoid")
            if not r or not h then return end
            
            r.Velocity = Vector3.new(0, 0, 0) -- ต้านแรงโน้มถ่วง
            local camera = workspace.CurrentCamera
            
            if h.MoveDirection.Magnitude > 0 and camera then
                -- 🌟 แก้ไขจุดเทคนิคคำนวณเวกเตอร์ทิศทางกล้อง: ปรับให้บินตรงไปข้างหน้าไม่สลับทิศทาง
                local forwardVector = camera.CFrame.LookVector
                local rightVector = camera.CFrame.RightVector
                
                -- คำนวณทิศทางการเคลี่อนที่ให้สัมพันธ์กับนิ้วกดเดินหน้า/ถอยหลังแบบตรงตัว
                local flyVelocity = (forwardVector * (-h.MoveDirection.Z) + rightVector * h.MoveDirection.X).Unit
                
                -- ตรวจเช็คค่าป้องกันการหลุด Void
                local nextCFrame = r.CFrame + (flyVelocity * FlySpeed * deltaTime)
                if nextCFrame.Y < -50 then
                    nextCFrame = CFrame.new(nextCFrame.X, -50, nextCFrame.Z)
                elseif nextCFrame.Y > 1000 then
                    nextCFrame = CFrame.new(nextCFrame.X, 1000, nextCFrame.Z)
                end
                
                r.CFrame = nextCFrame
            end
        end)
    end
end

-- [[ 3. ระบบควบคุมคำสั่งผ่านแชทตัวฉบับไร้เงา (Chat Controller) ]] --
_G.ChatBypassConnection = LocalPlayer.Chatted:Connect(function(message)
    local args = string.split(message, " ")
    local command = string.lower(args[1])
    
    -- สลับเปิด/ปิด วิ่งเร็ว (พิมพ์ /s หรือ :s ในแชท)
    if command == "/s" or command == ":s" then
        SuperSpeedEnabled = not SuperSpeedEnabled
        if SuperSpeedEnabled then FlyEnabled = false end
        
        -- ปรับแต่งตัวคูณเพิ่มผ่านแชทได้ทันที เช่นพิมพ์ /s 5
        if args[2] and tonumber(args[2]) then SpeedMultiplier = tonumber(args[2]) end
        
        updateBypassMovement()
        
    -- สลับเปิด/ปิด บินพุ่ง (พิมพ์ /f หรือ :f ในแชท)
    elseif command == "/f" or command == ":f" then
        FlyEnabled = not FlyEnabled
        if FlyEnabled then SuperSpeedEnabled = false end
        
        -- ปรับแต่งความเร็วบินเพิ่มผ่านแชทได้ทันที เช่นพิมพ์ /f 250
        if args[2] and tonumber(args[2]) then FlySpeed = tonumber(args[2]) end
        
        if not FlyEnabled then
            pcall(function() LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0) end)
        end
        
        updateBypassMovement()
    end
end)

print("--- STEAL EGG NO-UI BYPASS READY ---")
