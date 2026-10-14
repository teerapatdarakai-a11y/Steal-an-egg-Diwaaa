-- ==============================================================================
-- DELTA HUB - MM2 OPTIMIZED ROLE ESP (Final Complete Version)
-- ==============================================================================

if not Drawing or not getgenv then
    print("Executor ของคุณไม่รองรับ Drawing API")
    return
end

-- ป้องกันการรันซ้ำและเคลียร์ของเก่า
if getgenv().MM2_LoadedUI then
    pcall(function()
        getgenv().MM2_LoadedUI:Destroy()
    end)
end

if getgenv().MM2_Connection then
    getgenv().MM2_Connection:Disconnect()
end

if getgenv().MM2_PlayerRemoving then
    getgenv().MM2_PlayerRemoving:Disconnect()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- สร้าง ScreenGui สำหรับปุ่มเปิด/ปิด
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_ESP_Gui"
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end
getgenv().MM2_LoadedUI = ScreenGui

-- ปุ่มลอยเปิด/ปิดเมนู ESP
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Size = UDim2.new(0, 52, 0, 52)
FloatingBtn.Position = UDim2.new(0, 30, 0.4, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
FloatingBtn.Text = "🔪"
FloatingBtn.TextColor3 = Color3.fromRGB(231, 76, 60)
FloatingBtn.TextSize = 24
FloatingBtn.Font = Enum.Font.GothamBold
FloatingBtn.Active = true
FloatingBtn.Draggable = true
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(231, 76, 60)
FloatStroke.Thickness = 2.5
FloatStroke.Parent = FloatingBtn

-- หน้าต่างควบคุมสถานะ
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 130)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "MM2 ROLE ESP"
Title.TextColor3 = Color3.fromRGB(231, 76, 60)
Title.TextSize = 15
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
StatusLabel.Text = "บทบาท: กำลังตรวจสอบ..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextSize = 13
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Parent = MainFrame

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusLabel

-- ควบคุมเปิด/ปิด UI ด้วยปุ่มลอย
local uiVisible = true
FloatingBtn.MouseButton1Click:Connect(function()
    uiVisible = not uiVisible
    MainFrame.Visible = uiVisible
end)

-- ระบบแคชบทบาทผู้เล่นและ ESP
local RoleCache = {}
local ESPCache = {}

local function RemoveESP(player)
    if ESPCache[player] then
        if ESPCache[player].Box then ESPCache[player].Box:Remove() end
        if ESPCache[player].NameText then ESPCache[player].NameText:Remove() end
        ESPCache[player] = nil
    end
    RoleCache[player] = nil
end

-- ฟังก์ชันตรวจสอบบทบาท (ปรับปรุงให้จับมีด/ปืนได้อย่างแม่นยำ)
local function UpdatePlayerRole(player)
    local char = player.Character
    if not char then return "Innocent" end
    
    local function checkContainer(container)
        if not container then return nil end
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                local itemName = item.Name:lower()
                if itemName == "knife" or itemName:find("knife") or itemName:find("blade") then
                    return "Murderer"
                elseif itemName == "gun" or itemName == "revolver" then
                    return "Sheriff"
                end
            end
        end
        return nil
    end

    -- 1. เช็คในตัวละคร (Character)
    local role = checkContainer(char)
    if role then return role end

    -- 2. เช็คในกระเป๋า (Backpack)
    if player:FindFirstChild("Backpack") then
        role = checkContainer(player.Backpack)
        if role then return role end
    end
    
    return "Innocent"
end

-- ผูก Event ติดตามเมื่อผู้เล่นเปลี่ยนตัวละครหรือหยิบ/ทิ้งไอเทม
local function SetupPlayerTracking(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        RoleCache[player] = UpdatePlayerRole(player)
        
        char.ChildAdded:Connect(function()
            RoleCache[player] = UpdatePlayerRole(player)
        end)
        char.ChildRemoved:Connect(function()
            task.wait(0.1)
            RoleCache[player] = UpdatePlayerRole(player)
        end)

        task.wait(0.2)
        if player:FindFirstChild("Backpack") then
            player.Backpack.ChildAdded:Connect(function()
                RoleCache[player] = UpdatePlayerRole(player)
            end)
            player.Backpack.ChildRemoved:Connect(function()
                task.wait(0.1)
                RoleCache[player] = UpdatePlayerRole(player)
            end)
        end
    end)
    
    if player.Character then
        RoleCache[player] = UpdatePlayerRole(player)
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    SetupPlayerTracking(p)
end

Players.PlayerAdded:Connect(SetupPlayerTracking)
getgenv().MM2_PlayerRemoving = Players.PlayerRemoving:Connect(RemoveESP)

-- อัปเดตบทบาทของ LocalPlayer ทันทีตั้งแต่เริ่มรัน
if LocalPlayer.Character then
    RoleCache[LocalPlayer] = UpdatePlayerRole(LocalPlayer)
end

-- ตัวแปรควบคุมความถี่ (Throttling)
local lastUpdate = 0
local updateInterval = 0.2

-- ลูปการทำงานหลัก (RenderStepped)
getgenv().MM2_Connection = RunService.RenderStepped:Connect(function()
    local tickTime = tick()
    
    if tickTime - lastUpdate >= updateInterval then
        lastUpdate = tickTime
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                RoleCache[player] = UpdatePlayerRole(player)
            end
        end
    end

    local myRole = RoleCache[LocalPlayer] or UpdatePlayerRole(LocalPlayer)
    StatusLabel.Text = "บทบาทของคุณ: " .. myRole

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local pChar = player.Character
            if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 then
                
                local targetRole = RoleCache[player] or "Innocent"
                local showBox = false
                local boxColor = Color3.fromRGB(231, 76, 60)

                if myRole == "Innocent" then
                    if targetRole == "Murderer" then
                        showBox = true
                        boxColor = Color3.fromRGB(231, 76, 60) -- ฆาตกรสีแดง
                    elseif targetRole == "Sheriff" then
                        showBox = true
                        boxColor = Color3.fromRGB(52, 152, 219) -- นายอำเภอสีน้ำเงิน
                    end
                elseif myRole == "Murderer" then
                    showBox = true
                    boxColor = Color3.fromRGB(231, 76, 60)
                elseif myRole == "Sheriff" then
                    if targetRole == "Murderer" then
                        showBox = true
                        boxColor = Color3.fromRGB(231, 76, 60)
                    end
                end

                -- สร้างหรือดึง ESP Cache
                if not ESPCache[player] then
                    local box = Drawing.new("Square")
                    box.Visible = false
                    box.Thickness = 1.5
                    box.Filled = false

                    local nameText = Drawing.new("Text")
                    nameText.Visible = false
                    nameText.Size = 13
                    nameText.Center = true
                    nameText.Outline = true

                    ESPCache[player] = {Box = box, NameText = nameText}
                end

                local cache = ESPCache[player]

                if showBox then
                    for _, part in ipairs(pChar:GetDescendants()) do
                        if part:IsA("BasePart") and part.LocalTransparencyModifier ~= 0.5 then
                            part.LocalTransparencyModifier = 0.5
                        end
                    end

                    cache.Box.Color = boxColor
                    cache.NameText.Color = boxColor

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

                        cache.NameText.Text = "[" .. targetRole .. "]"
                        cache.NameText.Position = Vector2.new(vector.X, topPos.Y - 16)
                        cache.NameText.Visible = true
                    else
                        cache.Box.Visible = false
                        cache.NameText.Visible = false
                    end
                else
                    for _, part in ipairs(pChar:GetDescendants()) do
                        if part:IsA("BasePart") and part.LocalTransparencyModifier ~= 0 then
                            part.LocalTransparencyModifier = 0
                        end
                    end
                    cache.Box.Visible = false
                    cache.NameText.Visible = false
                end

            else
                RemoveESP(player)
            end
        end
    end
end)
