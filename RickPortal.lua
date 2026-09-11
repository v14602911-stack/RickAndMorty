-- =====================================================================
-- PORTAL GUN + PLAYER MENU
-- =====================================================================
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local ws = game:GetService("Workspace")
local players = game:GetService("Players")

-- ===== ПЕРЕМЕННЫЕ =====
local selectedPlayer = nil
local menuOpen = false
local portal = nil
local cooldown = false

-- ===== МЕНЮ =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- Кнопка открытия меню
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
toggleBtn.Text = "🌀"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 30
toggleBtn.Parent = screenGui

-- Панель меню
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 100)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
title.Text = "🌀 PORTAL MENU"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -38, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    menuOpen = false
end)

toggleBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    mainFrame.Visible = menuOpen
end)

-- Заголовок списка
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -20, 0, 25)
listLabel.Position = UDim2.new(0, 10, 0, 50)
listLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
listLabel.Text = "📋 ВЫБЕРИ ИГРОКА:"
listLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
listLabel.Font = Enum.Font.GothamBold
listLabel.TextSize = 14
listLabel.Parent = mainFrame

-- Инфа о выбранном
local selectedLabel = Instance.new("TextLabel")
selectedLabel.Size = UDim2.new(1, -20, 0, 30)
selectedLabel.Position = UDim2.new(0, 10, 0, 360)
selectedLabel.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
selectedLabel.Text = "Выбран: никто"
selectedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedLabel.Font = Enum.Font.GothamBold
selectedLabel.TextSize = 14
selectedLabel.Parent = mainFrame

-- Скролл со списком
local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -20, 0, 280)
playerScroll.Position = UDim2.new(0, 10, 0, 75)
playerScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 5
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = playerScroll

local function updatePlayerList()
    for _, v in pairs(playerScroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for _, plr in pairs(players:GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Parent = playerScroll
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                selectedLabel.Text = "Выбран: " .. plr.Name
                for _, b in pairs(playerScroll:GetChildren()) do
                    if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(60, 60, 90) end
                end
                btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                print("🎯 Выбран: " .. plr.Name)
            end)
        end
    end
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

updatePlayerList()
players.PlayerAdded:Connect(updatePlayerList)
players.PlayerRemoving:Connect(updatePlayerList)

-- ===== ПОРТАЛЬНАЯ ПУШКА =====
local tool = Instance.new("Tool")
tool.Name = "Portal Gun"
tool.RequiresHandle = true
tool.CanBeDropped = false
tool.Parent = player.Backpack

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(0.5, 0.5, 1.5)
handle.BrickColor = BrickColor.new("Bright green")
handle.Material = Enum.Material.Neon
handle.Parent = tool

-- ===== СОЗДАНИЕ ПОРТАЛА =====
local function createPortal(position)
    if portal then portal:Destroy() end
    local p = Instance.new("Part")
    p.Name = "Portal"
    p.Shape = Enum.PartType.Ball
    p.Size = Vector3.new(6, 6, 6)
    p.BrickColor = BrickColor.new("Bright green")
    p.Material = Enum.Material.Neon
    p.Anchored = true
    p.CanCollide = false
    p.Transparency = 0.3
    p.Position = position
    p.Parent = ws

    local spin = Instance.new("BodyAngularVelocity")
    spin.AngularVelocity = Vector3.new(0, 5, 0)
    spin.MaxTorque = Vector3.new(0, math.huge, 0)
    spin.Parent = p

    p.Touched:Connect(function(hit)
        if cooldown then return end
        local hitChar = hit.Parent
        if hitChar and hitChar:FindFirstChild("HumanoidRootPart") then
            if game.Players:GetPlayerFromCharacter(hitChar) == player then
                if selectedPlayer and selectedPlayer.Character then
                    local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        cooldown = true
                        hitChar.HumanoidRootPart.CFrame = targetRoot.CFrame + Vector3.new(0, 2, 0)
                        print("🎯 Телепорт к " .. selectedPlayer.Name)
                        wait(1)
                        cooldown = false
                    end
                else
                    print("❌ Игрок не выбран! Открой меню и выбери.")
                end
            end
        end
    end)

    portal = p
    return p
end

-- ===== ВЫСТРЕЛ =====
tool.Activated:Connect(function()
    local camera = ws.CurrentCamera
    local rayOrigin = camera.CFrame.Position
    local rayDirection = camera.CFrame.LookVector * 500

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char, tool}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = ws:Raycast(rayOrigin, rayDirection, rayParams)

    local hitPosition
    if result then
        hitPosition = result.Position
    else
        hitPosition = rayOrigin + rayDirection
    end

    createPortal(hitPosition)
    print("🌀 Портал создан! Заходи в него — телепорт к выбранному игроку.")
end)

-- ===== ПЕРЕПОДКЛЮЧЕНИЕ =====
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
    tool.Parent = player.Backpack
end)

print("🌀 PORTAL MENU + GUN загружена!")
print("📋 Нажми 🌀 слева — выбери игрока")
print("🔫 Стреляй пушкой — создаёшь портал")
print("🚀 Заходи в портал — телепорт к выбранному")
