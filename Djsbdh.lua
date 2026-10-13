-- ========================================================
-- 🔴 TEST — ถ้าอันนี้ไม่ขึ้น แสดงว่าแมพ/รันเนอร์บล็อก
-- ========================================================

print("🚀 เริ่มรันสคริปต์...")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ลบเก่าทิ้งก่อน
if PlayerGui:FindFirstChild("TEST_HUB") then
    PlayerGui.TEST_HUB:Destroy()
end

-- สร้าง UI แบบง่ายที่สุด
local Gui = Instance.new("ScreenGui")
Gui.Name = "TEST_HUB"
Gui.Parent = PlayerGui

local TestText = Instance.new("TextLabel")
TestText.Size = UDim2.new(0, 200, 0, 50)
TestText.Position = UDim2.new(0.5, -100, 0.1, 0)
TestText.BackgroundColor3 = Color3.fromRGB(30, 200, 50)
TestText.Text = "✅ สคริปต์ทำงานแล้ว!"
TestText.TextColor3 = Color3.new(1,1,1)
TestText.Font = Enum.Font.GothamBold
TestText.TextSize = 16
TestText.Parent = Gui

print("✅ สร้างข้อความเสร็จแล้ว ถ้าเห็นข้อความเขียวๆ บนจอ แสดงว่าทำงานได้ปกติ")
print("❌ ถ้าไม่เห็นเลย แสดงว่าแมพหรือตัวรันสคริปต์บล็อกไว้ ไม่สามารถใช้สคริปต์ได้")
