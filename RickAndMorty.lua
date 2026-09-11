-- =====================================================================
-- PORTAL MENU HUB by DeepSeek
-- =====================================================================
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local ws = game:GetService("Workspace")
local players = game:GetService("Players")

-- ===== ПЕРЕМЕННЫЕ =====
local menuOpen = false
local selectedPlayer = nil
local spawnedItem = nil
local portalA = nil
local portalB = nil
local teleportCooldown = false

-- ===== ГЛАВНОЕ МЕНЮ (GUI) =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
toggleBtn.Text = "🌀"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 30
toggleBtn.Parent = screenGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 450)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
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
title.TextSize = 22
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

-- ===== СПИСОК ИГРОКОВ =====
local playerListLabel = Instance.new("TextLabel")
playerListLabel.Size = UDim2.new(1, -20, 0, 25)
playerListLabel.Position = UDim2.new(0, 10, 0, 50)
playerListLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
playerListLabel.Text = "📋 ВЫБЕРИ ИГРОКА:"
playerListLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
playerListLabel.Font = Enum.Font.GothamBold
playerListLabel.TextSize = 14
playerListLabel.Parent = mainFrame

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -20, 0, 120)
playerScroll.Position = UDim2.new(0, 10, 0, 80)
playerScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 5
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.Parent = mainFrame

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Parent = playerScroll
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder

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
                print("🎯 Выбран игрок: " .. plr.Name)
                btn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                wait(0.3)
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
            end)
        end
    end
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, playerListLayout.AbsoluteContentSize.Y)
end

updatePlayerList()
players.PlayerAdded:Connect(updatePlayerList)
players.PlayerRemoving:Connect(updatePlayerList)

-- ===== СПАВН ПРЕДМЕТА =====
local itemLabel = Instance.new("TextLabel")
itemLabel.Size = UDim2.new(1, -20, 0, 25)
itemLabel.Position = UDim2.new(0, 10, 0, 210)
itemLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
itemLabel.Text = "📦 СПАВН ПРЕДМЕТА (ID):"
itemLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
itemLabel.Font = Enum.Font.GothamBold
itemLabel.TextSize = 14
itemLabel.Parent = mainFrame

local itemInput = Instance.new("TextBox")
itemInput.Size = UDim2.new(1, -20, 0, 35)
itemInput.Position = UDim2.new(0, 10, 0, 240)
itemInput.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
itemInput.Text = "Введи ID предмета..."
itemInput.TextColor3 = Color3.fromRGB(200, 200, 200)
itemInput.Font = Enum.Font.Gotham
itemInput.TextSize = 13
itemInput.Parent = mainFrame

local spawnBtn = Instance.new("TextButton")
spawnBtn.Size = UDim2.new(1, -20, 0, 35)
spawnBtn.Position = UDim2.new(0, 10, 0, 285)
spawnBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
spawnBtn.Text = "📦 ЗАСПАВНИТЬ"
spawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.TextSize = 15
spawnBtn.Parent = mainFrame

spawnBtn.MouseButton1Click:Connect(function()
    local id = tonumber(itemInput.Text)
    if id then
        local item = Instance.new("Part")
        item.Size = Vector3.new(2, 2, 2)
        item.BrickColor = BrickColor.Random()
        item.Material = Enum.Material.Neon
        item.Anchored = true
        item.CanCollide = false
        item.Position = root.Position + root.CFrame.LookVector * 5
        item.Name = "SpawnedItem_" .. id
        item.Parent = ws
        spawnedItem = item
        print("📦 Предмет заспавнен (ID: " .. id .. ")")
    else
        print("❌ Введи корректный ID!")
    end
end)

-- ===== ТЕЛЕПОРТ К ИГРОКУ =====
local tpToPlayerBtn = Instance.new("TextButton")
tpToPlayerBtn.Size = UDim2.new(1, -20, 0, 35)
tpToPlayerBtn.Position = UDim2.new(0, 10, 0, 330)
tpToPlayerBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 200)
tpToPlayerBtn.Text = "🎯 ТЕЛЕПОРТ К ИГРОКУ"
tpToPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpToPlayerBtn.Font = Enum.Font.GothamBold
tpToPlayerBtn.TextSize = 15
tpToPlayerBtn.Parent = mainFrame

tpToPlayerBtn.MouseButton1Click:Connect(function()
    if selectedPlayer and selectedPlayer.Character then
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            root.CFrame = targetRoot.CFrame + Vector3.new(0, 2, 0)
            print("🎯 Телепорт к " .. selectedPlayer.Name)
        end
    else
        print("❌ Игрок не выбран или мёртв.")
    end
end)

-- ===== ПОРТАЛ К ПРЕДМЕТУ =====
local portalToItemBtn = Instance.new("TextButton")
portalToItemBtn.Size = UDim2.new(1, -20, 0, 35)
portalToItemBtn.Position = UDim2.new(0, 10, 0, 375)
portalToItemBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
portalToItemBtn.Text = "🌀 ПОРТАЛ К ПРЕДМЕТУ"
portalToItemBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
portalToItemBtn.Font = Enum.Font.GothamBold
portalToItemBtn.TextSize = 15
portalToItemBtn.Parent = mainFrame

portalToItemBtn.MouseButton1Click:Connect(function()
    if spawnedItem and spawnedItem.Parent then
        if portalA then portalA:Destroy() end
        if portalB then portalB:Destroy() end
        
        portalA = createPortal(root.Position + root.CFrame.LookVector * 5, BrickColor.new("Bright green"), "PortalA")
        portalB = createPortal(spawnedItem.Position + Vector3.new(3, 0, 0), BrickColor.new("Bright blue"), "PortalB")
        print("🌀 Порталы созданы! Заходи в зелёный — выходишь у предмета.")
    else
        print("❌ Сначала заспавни предмет!")
    end
end)

-- ===== ФУНКЦИЯ ПОРТАЛА =====
function createPortal(position, color, name)
    local portal = Instance.new("Part")
    portal.Name = name
    portal.Shape = Enum.PartType.Ball
    portal.Size = Vector3.new(6, 6, 6)
    portal.BrickColor = color
    portal.Material = Enum.Material.Neon
    portal.Anchored = true
    portal.CanCollide = false
    portal.Transparency = 0.3
    portal.Position = position
    portal.Parent = ws
    
    local spin = Instance.new("BodyAngularVelocity")
    spin.AngularVelocity = Vector3.new(0, 5, 0)
    spin.MaxTorque = Vector3.new(0, math.huge, 0)
    spin.Parent = portal
    
    portal.Touched:Connect(function(hit)
        if teleportCooldown then return end
        local hitChar = hit.Parent
        if hitChar and hitChar:FindFirstChild("HumanoidRootPart") then
            if game.Players:GetPlayerFromCharacter(hitChar) == player then
                teleportCooldown = true
                local target = (portal.Name == "PortalA") and portalB or portalA
                if target and target.Parent then
                    hitChar.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 0, 5)
                end
                wait(1)
                teleportCooldown = false
            end
        end
    end)
    
    return portal
end

-- ===== ПЕРЕПОДКЛЮЧЕНИЕ =====
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")
end)

print("✅ PORTAL MENU HUB загружен!")
print("🌀 Нажми на кнопку '🌀' в левом верхнем углу.")
