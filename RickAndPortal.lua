-- =====================================================================
-- PORTAL GUN (Rick and Morty style) + MENU + FIXES
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
local portalParticles = {}
local tool = nil

-- ===== МЕНЮ =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- ===== КНОПКА ОТКРЫТИЯ МЕНЮ (ПЕРЕТАСКИВАЕМАЯ) =====
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0, 60)
toggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
toggleBtn.Text = "🌀"
toggleBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 30
toggleBtn.Active = true
toggleBtn.Parent = screenGui

-- ===== ПЕРЕТАСКИВАНИЕ КНОПКИ =====
local dragging = false
local dragStart = nil
local startPos = nil

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = toggleBtn.Position
    end
end)

toggleBtn.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        toggleBtn.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

toggleBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        local moved = (input.Position - dragStart).Magnitude
        dragging = false
        if moved < 10 then
            menuOpen = not menuOpen
            mainFrame.Visible = menuOpen
        end
    end
end)

-- ===== ПАНЕЛЬ МЕНЮ =====
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 25, 15)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(80, 255, 100)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
title.Text = "🌀 PORTAL GUN"
title.TextColor3 = Color3.fromRGB(0, 0, 0)
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

local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -20, 0, 25)
listLabel.Position = UDim2.new(0, 10, 0, 50)
listLabel.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
listLabel.Text = "📋 ВЫБЕРИ ИГРОКА:"
listLabel.TextColor3 = Color3.fromRGB(200, 255, 200)
listLabel.Font = Enum.Font.GothamBold
listLabel.TextSize = 14
listLabel.Parent = mainFrame

local selectedLabel = Instance.new("TextLabel")
selectedLabel.Size = UDim2.new(1, -20, 0, 30)
selectedLabel.Position = UDim2.new(0, 10, 0, 360)
selectedLabel.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
selectedLabel.Text = "Выбран: никто"
selectedLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
selectedLabel.Font = Enum.Font.GothamBold
selectedLabel.TextSize = 14
selectedLabel.Parent = mainFrame

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -20, 0, 280)
playerScroll.Position = UDim2.new(0, 10, 0, 75)
playerScroll.BackgroundColor3 = Color3.fromRGB(10, 20, 10)
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
            btn.BackgroundColor3 = Color3.fromRGB(40, 70, 40)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Parent = playerScroll
            btn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                selectedLabel.Text = "Выбран: " .. plr.Name
                for _, b in pairs(playerScroll:GetChildren()) do
                    if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(40, 70, 40) end
                end
                btn.BackgroundColor3 = Color3.fromRGB(80, 255, 100)
                print("🎯 Выбран: " .. plr.Name)
            end)
        end
    end
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end

updatePlayerList()
players.PlayerAdded:Connect(updatePlayerList)
players.PlayerRemoving:Connect(updatePlayerList)

-- ===== СОЗДАНИЕ ПУШКИ =====
local function createGun()
    local newTool = Instance.new("Tool")
    newTool.Name = "Portal Gun"
    newTool.RequiresHandle = true
    newTool.CanBeDropped = false
    
    local newHandle = Instance.new("Part")
    newHandle.Name = "Handle"
    newHandle.Size = Vector3.new(0.5, 0.5, 1.5)
    newHandle.BrickColor = BrickColor.new("Lime green")
    newHandle.Material = Enum.Material.Neon
    newHandle.Parent = newTool
    
    newTool.Parent = player.Backpack
    return newTool
end

tool = createGun()

-- ===== ФУНКЦИЯ УДАЛЕНИЯ ПОРТАЛА =====
local function destroyPortal()
    if portal then portal:Destroy() portal = nil end
    for _, p in pairs(portalParticles) do
        if p and p.Parent then p:Destroy() end
    end
    portalParticles = {}
end

-- ===== СОЗДАНИЕ ПОРТАЛА =====
local function createPortal(position)
    destroyPortal()

    local portalModel = Instance.new("Model")
    portalModel.Name = "RickPortal"
    portalModel.Parent = ws

    -- Основное тело (овал)
    local body = Instance.new("Part")
    body.Name = "PortalBody"
    body.Shape = Enum.PartType.Ball
    body.Size = Vector3.new(8, 10, 8)
    body.BrickColor = BrickColor.new("Lime green")
    body.Material = Enum.Material.Neon
    body.Anchored = true
    body.CanCollide = false
    body.Transparency = 0.4
    body.Position = position
    body.Parent = portalModel

    -- Внутренний слой
    local inner = Instance.new("Part")
    inner.Name = "PortalInner"
    inner.Shape = Enum.PartType.Ball
    inner.Size = Vector3.new(6.5, 8.5, 6.5)
    inner.BrickColor = BrickColor.new("Dark green")
    inner.Material = Enum.Material.Neon
    inner.Anchored = true
    inner.CanCollide = false
    inner.Transparency = 0.3
    inner.Position = position
    inner.Parent = portalModel

    -- Кольцо 1
    local ring = Instance.new("Part")
    ring.Name = "PortalRing"
    ring.Shape = Enum.PartType.Cylinder
    ring.Size = Vector3.new(0.5, 11, 11)
    ring.BrickColor = BrickColor.new("Lime green")
    ring.Material = Enum.Material.Neon
    ring.Anchored = true
    ring.CanCollide = false
    ring.Transparency = 0.2
    ring.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    ring.Parent = portalModel

    -- Кольцо 2
    local ring2 = Instance.new("Part")
    ring2.Name = "PortalRing2"
    ring2.Shape = Enum.PartType.Cylinder
    ring2.Size = Vector3.new(0.3, 9, 9)
    ring2.BrickColor = BrickColor.new("Bright green")
    ring2.Material = Enum.Material.Neon
    ring2.Anchored = true
    ring2.CanCollide = false
    ring2.Transparency = 0.4
    ring2.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
    ring2.Parent = portalModel

    -- Частицы 1
    local attach = Instance.new("Attachment")
    attach.Parent = body

    local emitter = Instance.new("ParticleEmitter")
    emitter.Parent = attach
    emitter.Texture = "rbxassetid://243660364"
    emitter.Rate = 60
    emitter.Lifetime = NumberRange.new(0.6, 1.2)
    emitter.Speed = NumberRange.new(2, 6)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 255, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 200, 50))
    })
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.LightEmission = 1
    table.insert(portalParticles, emitter)

    -- Частицы 2
    local attach2 = Instance.new("Attachment")
    attach2.Position = Vector3.new(0, 2, 0)
    attach2.Parent = body

    local emitter2 = Instance.new("ParticleEmitter")
    emitter2.Parent = attach2
    emitter2.Texture = "rbxassetid://243660364"
    emitter2.Rate = 40
    emitter2.Lifetime = NumberRange.new(0.8, 1.5)
    emitter2.Speed = NumberRange.new(1, 4)
    emitter2.SpreadAngle = Vector2.new(360, 360)
    emitter2.Color = ColorSequence.new(Color3.fromRGB(150, 255, 150))
    emitter2.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter2.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter2.LightEmission = 1
    table.insert(portalParticles, emitter2)

    -- Свет
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(80, 255, 100)
    light.Range = 20
    light.Brightness = 3
    light.Parent = body

    -- Анимация
    spawn(function()
        while portalModel and portalModel.Parent do
            if ring and ring.Parent then
                ring.CFrame = ring.CFrame * CFrame.Angles(math.rad(3), 0, 0)
            end
            if ring2 and ring2.Parent then
                ring2.CFrame = ring2.CFrame * CFrame.Angles(math.rad(-5), 0, 0)
            end
            if body and body.Parent then
                local pulse = 1 + math.sin(tick() * 3) * 0.05
                body.Size = Vector3.new(8 * pulse, 10 * pulse, 8 * pulse)
                inner.Size = Vector3.new(6.5 * pulse, 8.5 * pulse, 6.5 * pulse)
            end
            wait(0.05)
        end
    end)

    -- Телепорт при касании
    body.Touched:Connect(function(hit)
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
                    print("❌ Игрок не выбран!")
                end
            end
        end
    end)

    portal = portalModel
    return portalModel
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

    hitPosition = hitPosition + camera.CFrame.LookVector * 2

    createPortal(hitPosition)
    print("🌀 Портал открыт! Заходи — телепорт к выбранному игроку.")
end)

-- ===== ПЕРЕПОДКЛЮЧЕНИЕ (ПУШКА ВОЗВРАЩАЕТСЯ) =====
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = newChar:WaitForChild("HumanoidRootPart")

    wait(1)

    if tool then
        tool.Parent = player.Backpack
    else
        tool = createGun()
        -- Перепривязываем Activated
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

            hitPosition = hitPosition + camera.CFrame.LookVector * 2

            createPortal(hitPosition)
            print("🌀 Портал открыт!")
        end)
    end
end)

-- Страховка: если пушка улетела в Character перед смертью — вернуть
player.CharacterRemoving:Connect(function()
    if tool and tool.Parent ~= player.Backpack then
        tool.Parent = player.Backpack
    end
end)

-- Проверка раз в 2 секунды, что пушка у нас
spawn(function()
    while true do
        wait(2)
        if tool and tool.Parent == nil then
            tool = createGun()
        end
    end
end)

print("🌀 PORTAL GUN (Rick and Morty style) загружена!")
print("📋 Нажми 🌀 слева — выбери игрока (кнопку можно таскать)")
print("🔫 Стреляй — создаёшь портал как в сериале")
print("🚀 Заходи в портал — телепорт к выбранному")
print("♻️ Пушка возвращается после смерти")
