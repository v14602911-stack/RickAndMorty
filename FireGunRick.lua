-- =====================================================================
-- FIRE GUN (Rick and Morty style) by DeepSeek
-- =====================================================================
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local ws = game:GetService("Workspace")
local rs = game:GetService("RunService")
local debris = game:GetService("Debris")

-- ===== ПЕРЕМЕННЫЕ =====
local tool = nil
local fireObjects = {}
local cooldown = false

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

    -- Ствол
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

    -- Свет на стволе
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 100, 0)
    light.Range = 8
    light.Brightness = 2
    light.Parent = handle

    -- Частицы огня у дула
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

    -- Основа пятна (тлеющая)
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

    -- Частицы огня
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

    -- Частицы дыма
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

    -- Свет
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 100, 0)
    light.Range = 15
    light.Brightness = 3
    light.Parent = base

    -- Пульсация пламени
    spawn(function()
        while fireModel and fireModel.Parent do
            local pulse = 1 + math.sin(tick() * 5) * 0.15
            if base and base.Parent then
                base.Size = Vector3.new(0.2, 7 * pulse, 7 * pulse)
            end
            wait(0.05)
        end
    end)

    -- Автоудаление пятна через 10 секунд (визуал, не перманентный)
    debris:AddItem(fireModel, 10)

    table.insert(fireObjects, fireModel)
    return fireModel
end

-- ===== ФУНКЦИЯ ПОДЖОГА ОБЪЕКТА (ВИЗУАЛ) =====
local function igniteObject(part, position)
    -- Визуальное "поджаривание" объекта (без реального удара)
    if part and part:IsA("BasePart") then
        local originalColor = part.BrickColor
        local originalMaterial = part.Material
        
        part.BrickColor = BrickColor.new("Really black")
        part.Material = Enum.Material.CorrodedMetal
        
        -- Через 5 секунд возвращаем
        spawn(function()
            wait(5)
            if part and part.Parent then
                part.BrickColor = originalColor
                part.Material = originalMaterial
            end
        end)
    end

    -- Создаём огненное пятно в точке
    createFirePatch(position)
end

-- ===== ФУНКЦИЯ ВЫСТРЕЛА =====
local function shootFire()
    if cooldown then return end
    cooldown = true

    local camera = ws.CurrentCamera
    local rayOrigin = camera.CFrame.Position
    local rayDirection = camera.CFrame.LookVector * 500

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char, tool}
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

    -- Создаём летящий снаряд (визуальный огненный шар)
    local projectile = Instance.new("Part")
    projectile.Shape = Enum.PartType.Ball
    projectile.Size = Vector3.new(1.5, 1.5, 1.5)
    projectile.BrickColor = BrickColor.new("Bright orange")
    projectile.Material = Enum.Material.Neon
    projectile.CanCollide = false
    projectile.Anchored = true
    projectile.CFrame = rayOrigin + camera.CFrame.LookVector * 3
    projectile.Parent = ws

    -- Частицы на снаряде
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

    local projLight = Instance.new("PointLight")
    projLight.Color = Color3.fromRGB(255, 100, 0)
    projLight.Range = 12
    projLight.Brightness = 3
    projLight.Parent = projectile

    -- Полёт снаряда
    spawn(function()
        local steps = 20
        local stepVec = (hitPosition - projectile.Position) / steps
        for i = 1, steps do
            if not projectile or not projectile.Parent then break end
            projectile.CFrame = projectile.CFrame + stepVec
            wait(0.01)
        end
        
        -- При попадании
        if projectile and projectile.Parent then
            local explosionPos = projectile.Position
            projectile:Destroy()
            
            -- Огненный шар взрыва
            local boom = Instance.new("Part")
            boom.Shape = Enum.PartType.Ball
            boom.Size = Vector3.new(4, 4, 4)
            boom.BrickColor = BrickColor.new("Bright orange")
            boom.Material = Enum.Material.Neon
            boom.Anchored = true
            boom.CanCollide = false
            boom.Transparency = 0.2
            boom.CFrame = CFrame.new(explosionPos)
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

            -- Звук взрыва
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://131961136" -- взрыв
            sound.Volume = 1
            sound.Parent = boom
            sound:Play()

            debris:AddItem(boom, 0.8)

            -- Поджигаем то, во что попали
            if hitPart then
                igniteObject(hitPart, explosionPos)
            end
            createFirePatch(explosionPos)
        end
    end)

    wait(0.5)
    cooldown = false
end

-- ===== АКТИВАЦИЯ =====
tool.Activated:Connect(shootFire)

-- ===== ПЕРЕПОДКЛЮЧЕНИЕ (ПУШКА ВОЗВРАЩАЕТСЯ) =====
player.CharacterAdded:Connect(function(newChar)
    char = newChar
    root = newChar:WaitForChild("HumanoidRootPart")
    wait(1)
    if tool then
        tool.Parent = player.Backpack
    else
        tool = createGun()
    end
end)

player.CharacterRemoving:Connect(function()
    if tool and tool.Parent ~= player.Backpack then
        tool.Parent = player.Backpack
    end
end)

spawn(function()
    while true do
        wait(2)
        if tool and tool.Parent == nil then
            tool = createGun()
        end
    end
end)

print("🔥 FIRE GUN загружена!")
print("🔫 Нажми ЛКМ — стреляешь огненным шаром")
print("💥 При попадании — взрыв, огонь, дым, поджог объекта")
print("🌀 Пушка возвращается после смерти")
