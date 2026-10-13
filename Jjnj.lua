-- ========================================================
-- 📱 SIMPLEST VERSION FOR MOBILE
-- เรียบง่ายที่สุด ลดปัญหาให้น้อยที่สุด
-- ========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

print("🚀 กำลังเริ่มทำงาน...")

-- ======================= ตัวแปร
local Enabled = {
    Aimbot = false,
    ESP = false,
    NoClip = false
}
local IsTouching = false

-- ===================== สร้างปุ่มลอย
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Position = UDim2.new(0.02, 0, 0.5, -30)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
ToggleBtn.Text = "🔴"
ToggleBtn.TextSize = 30
ToggleBtn.AutoLocalize = false
ToggleBtn.Parent = ScreenGui
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 15)

print("✅ ปุ่มสร้างเสร็จ แตะที่ปุ่มเพื่อเปิดเมนู")

-- ===================== สร้างเมนู
local Menu = Instance.new("Frame")
Menu.Size = UDim2.new(0, 250, 0, 200)
Menu.Position = UDim2.new(0.1, 0, 0.3, 0)
Menu.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Menu.Visible = false
Menu.Parent = ScreenGui
Instance.new("UICorner", Menu).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
Title.Text = "📱 MOBILE HUB"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.Parent = Menu
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local function MakeButton(name, yPos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 14
    btn.AutoLocalize = false
    btn.Parent = Menu
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function()
        Enabled[name] = not Enabled[name]
        btn.BackgroundColor3 = Enabled[name] and color or Color3.fromRGB(60, 60, 70)
        callback(Enabled[name])
    end)
    return btn
end

-- สร้าง 3 ปุ่ม
MakeButton("🎯 Aimbot", 50, Color3.fromRGB(50, 180, 255), function(state) end)
MakeButton("👁️ ESP", 100, Color3.fromRGB(50, 255, 100), function(state) end)
MakeButton("🔨 NoClip", 150, Color3.fromRGB(255, 150, 50), function(state) end)

-- เปิด-ปิดเมนู
local MenuOpen = false
ToggleBtn.MouseButton1Click:Connect(function()
    MenuOpen = not MenuOpen
    Menu.Visible = MenuOpen
    ToggleBtn.Text = MenuOpen and "🟢" or "🔴"
end)

-- ===================== ตรวจจับการแตะ
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        IsTouching = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        IsTouching = false
    end
end)

-- ===================== ลูปทำงาน
RunService.RenderStepped:Connect(function()
    local LocalChar = LocalPlayer.Character
    if not LocalChar then return end

    -- ===== NoClip
    local HumanoidRootPart = LocalChar:FindFirstChild("HumanoidRootPart")
    if Enabled.NoClip then
        for _, Part in pairs(LocalChar:GetChildren()) do
            if Part:IsA("BasePart") then
                Part.CanCollide = false
            end
        end
    end

    -- ===== Aimbot
    if Enabled.Aimbot and IsTouching then
        local ClosestTarget = nil
        local ClosestAngle = math.huge
        
        for _, Player in pairs(Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character then
                local Hum = Player.Character:FindFirstChild("Humanoid")
                local Head = Player.Character:FindFirstChild("Head")
                if Hum and Hum.Health > 0 and Head then
                    local Pos = Head.Position
                    local Dir = (Pos - Camera.CFrame.Position).Unit
                    local Angle = math.de(math.acos(math.clamp(Camera.CFrame.LookVector:Dot(Dir), -1, 1)))
                    local Dist = (Camera.CFrame.Position - Pos).Magnitude
                    
                    if Angle < 70 and Dist < 150 and Angle < ClosestAngle then
                        ClosestAngle = Angle
                        ClosestTarget = Head
                    end
                end
            end
        end
        
        if ClosestTarget then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, ClosestTarget.Position), 0.15)
        end
    end
end)

print("✅ โหลดเสร็จแล้ว! แตะปุ่ม 🔴 ทางซ้ายเพื่อเปิดเมนู")
print("💡 Aimbot: เปิดแล้วแตะค้างบนจอเพื่อล็อกเป้า")
