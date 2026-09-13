-- =====================================================================
-- FIRE GUN (Rick and Morty style) + DESTRUCTION + MOBILE by DeepSeek
-- =====================================================================
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local ws = game:GetService("Workspace")
local debris = game:GetService("Debris")

-- ===== GUI =====
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- ===== ПЕРЕМЕННЫЕ =====
local tool = nil
local fireObjects = {}
local cooldown = false
local firing = false

-- ===== СОЗДАНИЕ ПУШКИ =====
local function createGun()
    local newTool = Instance.new("Tool")
    newTool.Name = "Fire Gun"
    newTool.RequiresHandle = true
    newTool.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.4, 0.4, 1.5)
    handle.BrickColor = BrickColor.new("Really red")
    handle.Material = Enum.Material.Neon
    handle.Parent = newTool

    local barrel = Instance.new("Part")
    barrel.Name = "Barrel"
    barrel.Size = Vector3.new(0.25, 0.25, 0.8)
    barrel.BrickColor = BrickColor.new("Dark orange")
    barrel.Material = Enum.Material.Metal
    barrel.Parent = newTool

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = barrel
    weld.Parent = handle
    barrel.CFrame = handle.CFrame * CFrame.new(0, 0, -1)

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 100, 0)
    light.Range = 8
    light.Brightness = 2
    light.Parent = handle

    local muzzleAttach = Instance.new("Attachment")
    muzzleAttach.Position = Vector3.new(0, 0, -1.2)
    muzzleAttach.Parent = handle

    local muzzleFire = Instance.new("ParticleEmitter")
    muzzleFire.Parent = muzzleAttach
    muzzleFire.Texture = "rbxassetid://243660364"
    muzzleFire.Rate = 20
    muzzleFire.Lifetime = NumberRange.new(0.3, 0.6)
    muzzleFire.Speed = NumberRange.new(5, 10)
    muzzleFire.SpreadAngle = Vector2.new(30, 30)
    muzzleFire.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 100)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 150, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 0))
    })
    muzzleFire.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0)
    })
    muzzleFire.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1)
    })
    muzzleFire.LightEmission = 1

    newTool.Parent = player.Backpack
    return newTool
end

tool = createGun()

-- ===== ФУНКЦИЯ СОЗДАНИЯ ОГНЕННОГО ПЯТНА =====
local function createFirePatch(position)
    local fireModel = Instance.new("Model")
    fireModel.Name = "FirePatch"
    fireModel.Parent = ws

    local base = Instance.new("Part")
    base.Name = "FireBase"
    base.Shape = Enum.PartType.Cylinder
    base.Size = Vector3.new(0.2, math.random(5, 9), math.random(5, 9))
    base.BrickColor = BrickColor.new("Really red")
    base.Material = Enum.Material.Neon
    base.Anchored = true
    base.CanCollide = false
    base.Transparency = 0.3
    base.CFrame = CFrame.new(position + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, math.rad(90))
    base.Parent = fireModel

    local attach = Instance.new("Attachment")
    attach.Parent = base

    local fire = Instance.new("ParticleEmitter")
    fire.Parent = attach
    fire.Texture = "rbxassetid://243660364"
    fire.Rate = 80
    fire.Lifetime = NumberRange.new(0.5, 1.2)
    fire.Speed = NumberRange.new(3, 8)
    fire.SpreadAngle = Vector2.new(180, 180)
    fire.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 100)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 120, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 0))
    })
    fire.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.2),
        NumberSequenceKeypoint.new(1, 0)
    })
    fire.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    fire.LightEmission = 1

    local smokeAttach = Instance.new("Attachment")
    smokeAttach.Position = Vector3.new(0, 2, 0)
    smokeAttach.Parent = base

    local smoke = Instance.new("ParticleEmitter")
    smoke.Parent = smokeAttach
    smoke.Texture = "rbxassetid://243660364"
    smoke.Rate = 25
    smoke.Lifetime = NumberRange.new(1.5, 3)
    smoke.Speed = NumberRange.new(1, 3)
    smoke.SpreadAngle = Vector2.new(60, 60)
    smoke.Color = ColorSequence.new(Color3.fromRGB(50, 50, 50))
    smoke.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1.5),
        NumberSequenceKeypoint.new(1, 4)
    })
    smoke.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 100, 0)
    light.Range = 15
    light.Brightness = 3
    light.Parent = base

    spawn(function()
        while fireModel and fireModel.Parent do
            local pulse = 1 + math.sin(tick() * 5) * 0.15
            if base and base.Parent then
                base.Size = Vector3.new(0.2, 7 * pulse, 7 * pulse)
            end
            task.wait(0.05)
        end
    end)

    debris:AddItem(fireModel, 10)
    table.insert(fireObjects, fireModel)
    return fireModel
end

-- ===== ВИЗУАЛЬНОЕ РАЗРУШЕНИЕ ОБЪЕКТА =====
local function igniteObject(part, position)
    if not part or not part:IsA("BasePart") then
        createFirePatch(position)
        return
    end

    if part.Parent and part.Parent:FindFirstChild("Humanoid") then
        createFirePatch(position)
        return
    end

    local originalColor = part.BrickColor
    local originalMaterial = part.Material
    local originalTransparency = part.Transparency
    local originalSize = part.Size

    -- Этап 1: обугливание
    part.BrickColor = BrickColor.new("Really black")
    part.Material = Enum.Material.CorrodedMetal

    local crackGui = Instance.new("SurfaceGui")
    crackGui.Face = Enum.NormalId.Top
    crackGui.Parent = part

    local crackFrame = Instance.new("Frame")
    crackFrame.Size = UDim2.new(1, 0, 1, 0)
    crackFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    crackFrame.BackgroundTransparency = 0.3
    crackFrame.Parent = crackGui

    -- Этап 2: оседание
    spawn(function()
        task.wait(1)
        if not part or not part.Parent then return end
        
        local shrinkTime = 0.8
        local startTime = tick()
        while tick() - startTime < shrinkTime do
            if not part or not part.Parent then return end
            local progress = (tick() - startTime) / shrinkTime
            part.Size = Vector3.new(
                originalSize.X * (1 - progress * 0.3),
                originalSize.Y * (1 - progress * 0.5),
                originalSize.Z * (1 - progress * 0.3)
            )
            part.Transparency = originalTransparency + progress * 0.2
            task.wait(0.03)
        end
    end)

    -- Этап 3: осколки
    spawn(function()
        task.wait(1.2)
        if not part or not part.Parent then return end
        
        for i = 1, 12 do
            local chunk = Instance.new("Part")
            chunk.Size = Vector3.new(
                math.random(2, 5) / 10,
                math.random(2, 5) / 10,
                math.random(2, 5) / 10
            )
            chunk.BrickColor = BrickColor.new("Really black")
            chunk.Material = Enum.Material.CorrodedMetal
            chunk.CanCollide = false
            chunk.CFrame = part.CFrame * CFrame.new(
                math.random(-15, 15) / 10,
                math.random(-15, 15) / 10,
                math.random(-15, 15) / 10
            )
            chunk.Parent = ws

            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(
                math.random(-15, 15),
                math.random(5, 20),
                math.random(-15, 15)
            )
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Parent = chunk

            spawn(function()
                local chunkStart = tick()
                while tick() - chunkStart < 1.5 do
                    if not chunk or not chunk.Parent then return end
                    chunk.Transparency = chunk.Transparency + 0.05
                    task.wait(0.05)
                end
                if chunk and chunk.Parent then chunk:Destroy() end
            end)

            debris:AddItem(chunk, 2)
        end
    end)

    -- Этап 4: исчезновение
    spawn(function()
        task.wait(3)
        if not part or not part.Parent then return end
        
        local fadeTime = 1
        local fadeStart = tick()
        while tick() - fadeStart < fadeTime do
            if not part or not part.Parent then return end
            local progress = (tick() - fadeStart) / fadeTime
            part.Transparency = math.min(originalTransparency + 0.2 + progress * 0.8, 1)
            task.wait(0.05)
        end

        if part and part.Parent then
            part.Transparency = 1
            part.CanCollide = false
            part.Anchored = true
        end
        if crackGui and crackGui.Parent then crackGui:Destroy() end

        task.wait(5)
        if part and part.Parent then
            part.BrickColor = originalColor
            part.Material = originalMaterial
            part.Size = originalSize
            part.Transparency = originalTransparency
            part.CanCollide = true
            part.Anchored = false
        end
    end)

    createFirePatch(position)

    -- Цепочка: обугливание соседей
    spawn(function()
        task.wait(0.5)
        for _, other in pairs(ws:GetDescendants()) do
            if other:IsA("BasePart")
            and other ~= part
            and other.Parent
            and not other.Parent:FindFirstChild("Humanoid")
            and (other.Position - position).Magnitude < 8 then
                other.BrickColor = BrickColor.new("Really black")
                other.Material = Enum.Material.CorrodedMetal
            end
        end
    end)
end

-- ===== ФУНКЦИЯ ВЫСТРЕЛА =====
local function shootFire()
    if cooldown then return end
    cooldown = true

    local currentChar = player.Character
    if not currentChar then cooldown = false return end

    local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
    if not currentRoot then cooldown = false return end

    local camera = ws.CurrentCamera
    if not camera then cooldown = false return end

    local rayOrigin = camera.CFrame.Position
    local rayDirection = camera.CFrame.LookVector * 500

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {currentChar, tool}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = ws:Raycast(rayOrigin, rayDirection, rayParams)

    local hitPosition
    local hitPart
    if result then
        hitPosition = result.Position
        hitPart = result.Instance
    else
        hitPosition = rayOrigin + rayDirection
    end

    local projectile = Instance.new("Part")
    projectile.Shape = Enum.PartType.Ball
    projectile.Size = Vector3.new(1.5, 1.5, 1.5)
    projectile.BrickColor = BrickColor.new("Bright orange")
    projectile.Material = Enum.Material.Neon
    projectile.CanCollide = false
    projectile.Anchored = true
    projectile.CFrame = CFrame.new(rayOrigin + camera.CFrame.LookVector * 3)
    projectile.Parent = ws

    local projLight = Instance.new("PointLight")
    projLight.Color = Color3.fromRGB(255, 100, 0)
    projLight.Range = 12
    projLight.Brightness = 3
    projLight.Parent = projectile

    local projAttach = Instance.new("Attachment")
    projAttach.Parent = projectile

    local projFire = Instance.new("ParticleEmitter")
    projFire.Parent = projAttach
    projFire.Texture = "rbxassetid://243660364"
    projFire.Rate = 100
    projFire.Lifetime = NumberRange.new(0.3, 0.6)
    projFire.Speed = NumberRange.new(2, 5)
    projFire.SpreadAngle = Vector2.new(180, 180)
    projFire.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 0))
    })
    projFire.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0)
    })
    projFire.LightEmission = 1

    spawn(function()
        local startPos = projectile.Position
        local distance = (hitPosition - startPos).Magnitude
        local speed = 150
        local travelTime = distance / speed
        local t = 0

        while t < travelTime do
            if not projectile or not projectile.Parent then return end
            t = t + 0.02
            local alpha = math.min(t / travelTime, 1)
            projectile.CFrame = CFrame.new(startPos:Lerp(hitPosition, alpha))
            task.wait(0.02)
        end

        if projectile and projectile.Parent then
            local boomPos = projectile.Position
            projectile:Destroy()

            local boom = Instance.new("Part")
            boom.Shape = Enum.PartType.Ball
            boom.Size = Vector3.new(4, 4, 4)
            boom.BrickColor = BrickColor.new("Bright orange")
            boom.Material = Enum.Material.Neon
            boom.Anchored = true
            boom.CanCollide = false
            boom.Transparency = 0.2
            boom.CFrame = CFrame.new(boomPos)
            boom.Parent = ws

            local boomAttach = Instance.new("Attachment")
            boomAttach.Parent = boom

            local boomFire = Instance.new("ParticleEmitter")
            boomFire.Parent = boomAttach
            boomFire.Texture = "rbxassetid://243660364"
            boomFire.Rate = 200
            boomFire.Lifetime = NumberRange.new(0.5, 1)
            boomFire.Speed = NumberRange.new(10, 20)
            boomFire.SpreadAngle = Vector2.new(360, 360)
            boomFire.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 150)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 0))
            })
            boomFire.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1.5),
                NumberSequenceKeypoint.new(1, 0)
            })
            boomFire.LightEmission = 1

            local boomLight = Instance.new("PointLight")
            boomLight.Color = Color3.fromRGB(255, 150, 0)
            boomLight.Range = 25
            boomLight.Brightness = 5
            boomLight.Parent = boom

            debris:AddItem(boom, 0.8)

            pcall(function()
                if hitPart then igniteObject(hitPart, boomPos) end
            end)
            pcall(function()
                createFirePatch(boomPos)
            end)
        end
    end)

    task.wait(0.4)
    cooldown = false
end

-- ===== АКТИВАЦИЯ ПУШКИ =====
tool.Activated:Connect(shootFire)

-- ===== КНОПКА ОГНЯ ДЛЯ ТЕЛЕФОНА =====
local fireBtn = Instance.new("TextButton")
fireBtn.Size = UDim2.new(0, 100, 0, 100)
fireBtn.Position = UDim2.new(0.8, 0, 0.65, 0)
fireBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 0)
fireBtn.BackgroundTransparency = 0.15
fireBtn.Text = "🔥"
fireBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fireBtn.Font = Enum.Font.GothamBold
fireBtn.TextSize = 50
fireBtn.Active = true
fireBtn.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = fireBtn

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 200, 0)
stroke.Thickness = 3
stroke.Parent = fireBtn

fireBtn.MouseButton1Click:Connect(function()
    shootFire()
end)

fireBtn.MouseButton1Down:Connect(function()
    firing = true
    spawn(function()
        while firing do
            shootFire()
            task.wait(0.15)
        end
    end)
end)

fireBtn.MouseButton1Up:Connect(function()
    firing = false
end)

-- ===== ПЕРЕТАСКИВАНИЕ КНОПКИ =====
local draggingFire = false
local fireDragStart = nil
local fireStartPos = nil

fireBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFire = true
        fireDragStart = input.Position
        fireStartPos = fireBtn.Position
    end
end)

fireBtn.InputChanged:Connect(function(input)
    if draggingFire and (input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - fireDragStart
        fireBtn.Position = UDim2.new(
            fireStartPos.X.Scale, fireStartPos.X.Offset + delta.X,
            fireStartPos.Y.Scale, fireStartPos.Y.Offset + delta.Y
        )
    end
end)

fireBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingFire = false
    end
end)

-- ===== ПЕРЕПОДКЛЮЧЕНИЕ ПРИ СМЕРТИ =====
local function rebindGun(newTool)
    newTool.Activated:Connect(shootFire)
end

player.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = newChar:WaitForChild("HumanoidRootPart")
    task.wait(1)
    if tool and tool.Parent ~= nil then
        tool.Parent = player.Backpack
    else
        tool = createGun()
        rebindGun(tool)
    end
end)

player.CharacterRemoving:Connect(function()
    if tool and tool.Parent ~= player.Backpack then
        tool.Parent = player.Backpack
    end
end)

spawn(function()
    while true do
        task.wait(2)
        if tool and tool.Parent == nil then
            tool = createGun()
            rebindGun(tool)
        end
    end
end)

print("🔥 FIRE GUN (destruction + mobile) загружена!")
print("🔥 Тапни по 🔥 или нажми ЛКМ — выстрел")
print("💥 Объекты разрушаются визуально с осколками")
print("🔥 Огонь распространяется на соседей")
print("🔥 Кнопку можно таскать пальцем")
