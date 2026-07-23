repeat task.wait() until game:IsLoaded()

local ENV = getgenv and getgenv() or _G

if ENV.EagleHubXRuntime and type(ENV.EagleHubXRuntime.Unload) == "function" then
    pcall(function()
        ENV.EagleHubXRuntime:Unload()
    end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StatsService = game:GetService("Stats")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

for _, name in ipairs({
    "EagleHubXGui",
    "SpamCenter",
    "EagleHubMini",
    "SpamHubGui",
    "EagleBallStats",
    "ModNotification"
}) do
    local object = CoreGui:FindFirstChild(name)
    if object then
        object:Destroy()
    end
end

local Runtime = {
    active = true,
    connections = {},
    cleanups = {},
    guis = {},
    window = nil,
    notify = nil,
    parryRemote = nil,
    parryArgs = nil,
    remoteHooked = false,
    remoteNoticeShown = false
}

ENV.EagleHubXRuntime = Runtime

function Runtime:AddConnection(connection)
    if connection then
        table.insert(self.connections, connection)
    end
    return connection
end

function Runtime:Connect(signal, callback)
    return self:AddConnection(signal:Connect(callback))
end

function Runtime:AddCleanup(callback)
    table.insert(self.cleanups, callback)
end

function Runtime:AddGui(gui)
    table.insert(self.guis, gui)
    return gui
end

function Runtime:Notify(title, content)
    if self.notify then
        pcall(self.notify, title, content)
    end
end

function Runtime:Unload()
    if not self.active then
        return
    end

    self.active = false

    local hookState = ENV.__EagleHubXRemoteHookState
    if hookState and hookState.runtime == self then
        hookState.runtime = nil
    end

    for _, connection in ipairs(self.connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    for index = #self.cleanups, 1, -1 do
        pcall(self.cleanups[index])
    end

    if self.window then
        pcall(function()
            if type(self.window.Destroy) == "function" then
                self.window:Destroy()
            elseif type(self.window.Unload) == "function" then
                self.window:Unload()
            end
        end)
    end

    for _, gui in ipairs(self.guis) do
        pcall(function()
            gui:Destroy()
        end)
    end

    for _, name in ipairs({
        "EagleHubXGui",
        "SpamCenter",
        "EagleHubMini",
        "SpamHubGui",
        "EagleBallStats",
        "ModNotification"
    }) do
        local object = CoreGui:FindFirstChild(name)
        if object then
            pcall(function()
                object:Destroy()
            end)
        end
    end

    if ENV.EagleHubXRuntime == self then
        ENV.EagleHubXRuntime = nil
    end
end

local State = {
    autoParry = false,
    animationFix = false,
    antiCurve = false,
    parryDistance = 8,
    curveMethod = "camera",
    lowGraphics = false,
    showBallStats = false,
    abilityESP = false,
    headlessKorblox = false,
    avatarChanger = false,
    avatarName = "",
    skinChanger = false,
    swordName = "",
    spamActive = false,
    spamAnimationFix = true,
    targetCPS = 240,
    infinityDetection = false,
    deathSlashDetection = false,
    timeHoleDetection = false,
    slashesOfFuryDetection = false,
    phantomDetection = false,
    infinityActive = false,
    deathSlashActive = false,
    timeHoleActive = false,
    slashesOfFuryActive = false,
    slashesOfFuryCount = 0,
    maxParryCount = 36,
    parryDelay = 0.005,
    cameraEnabled = false,
    cameraFOV = 70,
    peakVelocity = 0
}

local function safeUnit(vector, fallback)
    if vector.Magnitude <= 0.0001 then
        return fallback or Vector3.zero
    end
    return vector.Unit
end

local function findPath(root, path)
    local current = root
    for _, name in ipairs(path) do
        current = current and current:FindFirstChild(name)
        if not current then
            return nil
        end
    end
    return current
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid(character)
    character = character or getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot(character)
    character = character or getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function isParryRemoteName(remote)
    local name = string.lower(remote.Name)
    if string.find(name, "success", 1, true) then
        return false
    end
    if string.find(name, "all", 1, true) then
        return false
    end
    if string.find(name, "ability", 1, true) then
        return false
    end
    return string.find(name, "parry", 1, true) ~= nil
end

local function hasParryArgumentShape(args)
    if not args or (args.n or 0) < 4 then
        return false
    end

    local thirdType = typeof(args[3])
    local fourthType = typeof(args[4])

    if thirdType == "Vector3" and fourthType == "CFrame" then
        return true
    end

    local hasCFrame = false
    local hasVector = false
    local hasTable = false

    for index = 1, args.n do
        local valueType = typeof(args[index])
        if valueType == "CFrame" then
            hasCFrame = true
        elseif valueType == "Vector3" then
            hasVector = true
        elseif valueType == "table" then
            hasTable = true
        end
    end

    return hasCFrame and hasVector and hasTable
end

function Runtime:ObserveRemote(remote, args)
    if not self.active then
        return
    end

    if checkcaller and checkcaller() then
        return
    end

    if typeof(remote) ~= "Instance" or not remote:IsA("RemoteEvent") then
        return
    end

    local named = isParryRemoteName(remote)
    local shaped = hasParryArgumentShape(args)

    if not named and not shaped then
        return
    end

    local copy = {n = args.n}
    for index = 1, args.n do
        copy[index] = args[index]
    end

    self.parryRemote = remote
    self.parryArgs = copy
    self.remoteHooked = true

    if not self.remoteNoticeShown then
        self.remoteNoticeShown = true
        self:Notify("Eagle Hub X", "Remote de parry capturado")
    end
end

local HookState = ENV.__EagleHubXRemoteHookState

if not HookState then
    HookState = {
        runtime = nil,
        mode = "none"
    }
    ENV.__EagleHubXRemoteHookState = HookState

    if hookmetamethod and getnamecallmethod and newcclosure then
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local runtime = HookState.runtime
            local method = getnamecallmethod()

            if runtime and runtime.active and method == "FireServer" then
                runtime:ObserveRemote(self, table.pack(...))
            end

            return oldNamecall(self, ...)
        end))
        HookState.old = oldNamecall
        HookState.mode = "namecall"
    elseif getrawmetatable and setreadonly and newcclosure then
        local metatable = getrawmetatable(game)
        local oldIndex = metatable.__index

        local function rawIndex(object, key)
            if type(oldIndex) == "function" then
                return oldIndex(object, key)
            end
            return oldIndex[key]
        end

        setreadonly(metatable, false)
        metatable.__index = newcclosure(function(self, key)
            if key == "FireServer" and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
                local rawFire = rawIndex(self, key)
                return function(instance, ...)
                    local runtime = HookState.runtime
                    if runtime and runtime.active then
                        runtime:ObserveRemote(instance, table.pack(...))
                    end
                    return rawFire(instance, ...)
                end
            end
            return rawIndex(self, key)
        end)
        setreadonly(metatable, true)
        HookState.old = oldIndex
        HookState.mode = "index"
    end
end

HookState.runtime = Runtime

local function resolveNamedParryRemote()
    local bestRemote = nil
    local bestScore = -math.huge

    for _, object in ipairs(ReplicatedStorage:GetDescendants()) do
        if object:IsA("RemoteEvent") then
            local name = string.lower(object.Name)
            local score = 0

            if name == "parrybuttonpress" then
                score = 100
            elseif name == "parryattempt" then
                score = 90
            elseif name == "parryevent" then
                score = 80
            elseif name == "parry" then
                score = 70
            elseif isParryRemoteName(object) then
                score = 40
            end

            if string.find(name, "success", 1, true) then
                score = -100
            end

            if score > bestScore then
                bestScore = score
                bestRemote = object
            end
        end
    end

    if bestScore > 0 then
        Runtime.parryRemote = bestRemote
    end
end

pcall(resolveNamedParryRemote)

local WorldCache = {
    alive = Workspace:FindFirstChild("Alive"),
    balls = Workspace:FindFirstChild("Balls"),
    runtime = Workspace:FindFirstChild("Runtime"),
    ball = nil,
    root = nil,
    ping = 0.08,
    lastFolderUpdate = 0,
    lastBallUpdate = 0,
    lastRootUpdate = 0,
    lastPingUpdate = 0,
    eventPositions = {},
    lastEventUpdate = 0
}

local function updateFolders(now)
    if now - WorldCache.lastFolderUpdate < 0.5 then
        return
    end

    WorldCache.lastFolderUpdate = now

    if not WorldCache.alive or not WorldCache.alive.Parent then
        WorldCache.alive = Workspace:FindFirstChild("Alive")
    end

    if not WorldCache.balls or not WorldCache.balls.Parent then
        WorldCache.balls = Workspace:FindFirstChild("Balls")
    end

    if not WorldCache.runtime or not WorldCache.runtime.Parent then
        WorldCache.runtime = Workspace:FindFirstChild("Runtime")
    end
end

local function updateRoot(now)
    if now - WorldCache.lastRootUpdate < 0.1 then
        return
    end

    WorldCache.lastRootUpdate = now
    WorldCache.root = getRoot()
end

local function updateBall(now)
    if now - WorldCache.lastBallUpdate < 0.04 then
        return
    end

    WorldCache.lastBallUpdate = now
    WorldCache.ball = nil

    local folder = WorldCache.balls
    if not folder then
        return
    end

    for _, ball in ipairs(folder:GetChildren()) do
        if ball:IsA("BasePart") and ball:GetAttribute("realBall") then
            WorldCache.ball = ball
            return
        end
    end
end

local function updatePing(now)
    if now - WorldCache.lastPingUpdate < 0.5 then
        return
    end

    WorldCache.lastPingUpdate = now

    pcall(function()
        WorldCache.ping = StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end)
end

local function updateEventPositions(now)
    if now - WorldCache.lastEventUpdate < 0.1 then
        return
    end

    WorldCache.lastEventUpdate = now
    table.clear(WorldCache.eventPositions)

    local camera = Workspace.CurrentCamera
    local character = getCharacter()
    local alive = WorldCache.alive

    if not camera or not alive then
        return
    end

    for _, entity in ipairs(alive:GetChildren()) do
        if entity ~= character then
            local root = entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart
            if root then
                local screenPosition, visible = camera:WorldToScreenPoint(root.Position)
                if visible then
                    WorldCache.eventPositions[tostring(entity)] = screenPosition
                end
            end
        end
    end
end

local function getCurveCFrame()
    local camera = Workspace.CurrentCamera
    local character = getCharacter()
    local root = getRoot(character)

    if not camera then
        return CFrame.new()
    end

    if not root then
        return camera.CFrame
    end

    local alive = WorldCache.alive
    local targetPosition = nil
    local closestDot = -math.huge

    if alive then
        for _, entity in ipairs(alive:GetChildren()) do
            if entity ~= character then
                local targetRoot = entity:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    local cameraDirection = safeUnit(targetRoot.Position - camera.CFrame.Position)
                    local dot = camera.CFrame.LookVector:Dot(cameraDirection)
                    if dot > closestDot then
                        closestDot = dot
                        targetPosition = targetRoot.Position
                    end
                end
            end
        end
    end

    targetPosition = targetPosition or (root.Position + camera.CFrame.LookVector * 1000)

    local targetDirection = safeUnit(targetPosition - root.Position, camera.CFrame.LookVector)
    local method = State.curveMethod

    if method == "dot" then
        return CFrame.lookAt(root.Position, targetPosition + Vector3.new(0, 1.75, 0))
    elseif method == "backwards" then
        return CFrame.lookAt(root.Position, root.Position - targetDirection * 1000)
    elseif method == "slow" then
        return CFrame.lookAt(root.Position, root.Position + Vector3.new(0, -350, 0))
    elseif method == "random" then
        local baseDirection = safeUnit(targetPosition - root.Position, camera.CFrame.LookVector)
        local randomOffset = Vector3.zero

        for _ = 1, 10 do
            randomOffset = Vector3.new(
                math.random(-4000, 4000),
                math.random(-4000, 4000),
                math.random(-4000, 4000)
            )

            local randomDirection = safeUnit(targetPosition + randomOffset - root.Position, baseDirection)
            if baseDirection:Dot(randomDirection) < 0.95 then
                break
            end
        end

        return CFrame.lookAt(root.Position, targetPosition + randomOffset)
    elseif method == "accelerated" then
        return CFrame.lookAt(root.Position, targetPosition + Vector3.new(0, 5, 0))
    elseif method == "high" then
        return CFrame.lookAt(root.Position, targetPosition + Vector3.new(0, 1000000, 0))
    end

    return camera.CFrame
end

local AnimationController = {
    cache = {},
    lastPlayed = 0,
    bypassCooldown = false,
    swordAPI = findPath(ReplicatedStorage, {"Shared", "SwordAPI"})
}

function AnimationController:GetAnimation()
    local character = getCharacter()
    if not character or not self.swordAPI then
        return nil
    end

    local collection = self.swordAPI:FindFirstChild("Collection")
    if not collection then
        return nil
    end

    local currentSword = character:GetAttribute("CurrentlyEquippedSword")

    if currentSword and self.cache[currentSword] then
        return self.cache[currentSword]
    end

    local defaultCollection = collection:FindFirstChild("Default")
    local fallback = defaultCollection and (defaultCollection:FindFirstChild("GrabParry") or defaultCollection:FindFirstChild("Grab"))

    if not currentSword then
        return fallback
    end

    local getSword = findPath(ReplicatedStorage, {"Shared", "ReplicatedInstances", "Swords", "GetSword"})
    local swordData = nil

    if getSword then
        pcall(function()
            swordData = getSword:Invoke(currentSword)
        end)
    end

    if type(swordData) == "table" and swordData.AnimationType then
        local animationFolder = collection:FindFirstChild(swordData.AnimationType)
        local animation = animationFolder and (animationFolder:FindFirstChild("GrabParry") or animationFolder:FindFirstChild("Grab"))
        if animation then
            self.cache[currentSword] = animation
            return animation
        end
    end

    self.cache[currentSword] = fallback
    return fallback
end

function AnimationController:StopTrack(track)
    pcall(function()
        track:Stop(track:GetAttribute("StopFadeTime") or 0.1)
    end)
end

function AnimationController:Play()
    local now = os.clock()
    if not self.bypassCooldown and now - self.lastPlayed < 0.2 then
        return
    end

    self.lastPlayed = now
    self.bypassCooldown = false

    local humanoid = getHumanoid()
    local animation = self:GetAnimation()

    if not humanoid or not animation then
        return
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        return
    end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if track.Name == "GrabParry" or track.Name == "Grab" or track.Name == "SuccessParry" or track.Name == "Success" then
            self:StopTrack(track)
        end
    end

    pcall(function()
        local track = animator:LoadAnimation(animation)
        track:Play(
            track:GetAttribute("PlayFadeTime") or 0,
            track:GetAttribute("PlayWeight") or 1,
            track:GetAttribute("PlaySpeed") or 1
        )
    end)
end

local parrySuccessRemote = findPath(ReplicatedStorage, {"Remotes", "ParrySuccess"})
if parrySuccessRemote and parrySuccessRemote:IsA("RemoteEvent") then
    Runtime:Connect(parrySuccessRemote.OnClientEvent, function()
        AnimationController.bypassCooldown = true

        local humanoid = getHumanoid()
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                if track.Name == "GrabParry" or track.Name == "Grab" then
                    AnimationController:StopTrack(track)
                end
            end
        end
    end)
end

local function fireParry(playAnimation)
    local remote = Runtime.parryRemote
    local originalArgs = Runtime.parryArgs
    local camera = Workspace.CurrentCamera
    local character = getCharacter()

    if not remote or not originalArgs or not remote.Parent or not camera or not character then
        return false
    end

    local now = os.clock()
    updateEventPositions(now)

    local args = {n = math.max(originalArgs.n or 0, 6)}
    for index = 1, originalArgs.n do
        args[index] = originalArgs[index]
    end

    local curveCFrame = getCurveCFrame()
    local viewport = camera.ViewportSize

    args[3] = curveCFrame.LookVector
    args[4] = curveCFrame
    args[5] = WorldCache.eventPositions
    args[6] = {viewport.X / 2, viewport.Y / 2}

    local success = pcall(function()
        remote:FireServer(table.unpack(args, 1, args.n))
    end)

    if success and playAnimation then
        AnimationController:Play()
    end

    return success
end

local Appearance = {}

local function saveTransparency(part)
    if part and part:IsA("BasePart") and part:GetAttribute("EagleOriginalTransparency") == nil then
        part:SetAttribute("EagleOriginalTransparency", part.Transparency)
    end
end

local function restoreTransparency(part)
    if not part or not part:IsA("BasePart") then
        return
    end

    local original = part:GetAttribute("EagleOriginalTransparency")
    if original ~= nil then
        part.Transparency = original
        part:SetAttribute("EagleOriginalTransparency", nil)
    end
end

function Appearance.ApplyHeadless(character)
    local head = character and character:FindFirstChild("Head")
    if not head then
        return
    end

    saveTransparency(head)
    head.Transparency = 1

    for _, child in ipairs(head:GetChildren()) do
        if child:IsA("Decal") then
            if child:GetAttribute("EagleOriginalTransparency") == nil then
                child:SetAttribute("EagleOriginalTransparency", child.Transparency)
            end
            child.Transparency = 1
        elseif child:IsA("SpecialMesh") or child:IsA("DataModelMesh") then
            if child:GetAttribute("EagleOriginalScale") == nil then
                child:SetAttribute("EagleOriginalScale", child.Scale)
            end
            child.Scale = Vector3.zero
        end
    end
end

function Appearance.RestoreHead(character)
    local head = character and character:FindFirstChild("Head")
    if not head then
        return
    end

    restoreTransparency(head)

    for _, child in ipairs(head:GetChildren()) do
        if child:IsA("Decal") then
            local original = child:GetAttribute("EagleOriginalTransparency")
            if original ~= nil then
                child.Transparency = original
                child:SetAttribute("EagleOriginalTransparency", nil)
            end
        elseif child:IsA("SpecialMesh") or child:IsA("DataModelMesh") then
            local originalScale = child:GetAttribute("EagleOriginalScale")
            if originalScale ~= nil then
                child.Scale = originalScale
                child:SetAttribute("EagleOriginalScale", nil)
            end
        end
    end
end

function Appearance.ApplyKorblox(character)
    if not character or character:FindFirstChild("EagleKorbloxVisual") then
        return
    end

    local source = character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg")
    if not source or not source:IsA("BasePart") then
        return
    end

    local hiddenParts = {}

    if character:FindFirstChild("Right Leg") then
        table.insert(hiddenParts, character["Right Leg"])
    else
        local lowerLeg = character:FindFirstChild("RightLowerLeg")
        local foot = character:FindFirstChild("RightFoot")
        if lowerLeg then
            table.insert(hiddenParts, lowerLeg)
        end
        if foot then
            table.insert(hiddenParts, foot)
        end
    end

    for _, part in ipairs(hiddenParts) do
        saveTransparency(part)
        part.Transparency = 1
    end

    local visual = Instance.new("Part")
    visual.Name = "EagleKorbloxVisual"
    visual.Size = source.Size
    visual.CFrame = source.CFrame
    visual.Transparency = 0
    visual.CanCollide = false
    visual.CanTouch = false
    visual.CanQuery = false
    visual.Massless = true
    visual.CastShadow = false
    visual.Parent = character

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://902942096"
    mesh.TextureId = "rbxassetid://902843398"
    mesh.Scale = Vector3.new(1, 1, 1)
    mesh.Offset = character:FindFirstChild("Right Leg") and Vector3.new(0, 0.7, 0) or Vector3.new(0, 0.25, 0)
    mesh.Parent = visual

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = visual
    weld.Part1 = source
    weld.Parent = visual
end

function Appearance.RestoreKorblox(character)
    if not character then
        return
    end

    local visual = character:FindFirstChild("EagleKorbloxVisual")
    if visual then
        visual:Destroy()
    end

    for _, name in ipairs({"Right Leg", "RightLowerLeg", "RightFoot"}) do
        restoreTransparency(character:FindFirstChild(name))
    end
end

function Appearance.ApplyAll(character)
    Appearance.ApplyHeadless(character)
    Appearance.ApplyKorblox(character)
end

function Appearance.RestoreAll(character)
    Appearance.RestoreHead(character)
    Appearance.RestoreKorblox(character)
end

local AvatarChanger = {
    token = 0,
    description = nil
}

local avatarFields = {
    "Shirt",
    "Pants",
    "GraphicTShirt",
    "Face",
    "Head",
    "Torso",
    "LeftArm",
    "RightArm",
    "LeftLeg",
    "RightLeg",
    "BodyTypeScale",
    "DepthScale",
    "HeadScale",
    "HeightScale",
    "ProportionScale",
    "WidthScale",
    "BackAccessory",
    "FaceAccessory",
    "FrontAccessory",
    "HairAccessory",
    "HatAccessory",
    "NeckAccessory",
    "ShouldersAccessory",
    "WaistAccessory"
}

function AvatarChanger:Matches(applied, wanted)
    for _, field in ipairs(avatarFields) do
        local success, matches = pcall(function()
            return tostring(applied[field]) == tostring(wanted[field])
        end)
        if success and not matches then
            return false
        end
    end
    return true
end

function AvatarChanger:Apply(character, description, token)
    if not character or not description or token ~= self.token or not State.avatarChanger then
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 5)
    if not humanoid then
        return
    end

    for _ = 1, 8 do
        if token ~= self.token or not State.avatarChanger or not character.Parent then
            return
        end

        pcall(function()
            humanoid:ApplyDescriptionClientServer(description)
        end)

        task.wait(0.15)

        local applied = nil
        pcall(function()
            applied = humanoid:GetAppliedDescription()
        end)

        if applied and self:Matches(applied, description) then
            if State.headlessKorblox then
                task.wait(0.1)
                Appearance.ApplyAll(character)
            end
            break
        end
    end

    task.spawn(function()
        while Runtime.active and State.avatarChanger and token == self.token and character.Parent do
            task.wait(2)

            local applied = nil
            pcall(function()
                applied = humanoid:GetAppliedDescription()
            end)

            if not applied or not self:Matches(applied, description) then
                pcall(function()
                    humanoid:ApplyDescriptionClientServer(description)
                end)
            end
        end
    end)
end

function AvatarChanger:SetName(name)
    self.token = self.token + 1
    local token = self.token
    self.description = nil

    if not State.avatarChanger or name == "" then
        return
    end

    task.spawn(function()
        local userId = nil
        local description = nil

        local success = pcall(function()
            userId = Players:GetUserIdFromNameAsync(name)
            description = Players:GetHumanoidDescriptionFromUserId(userId)
        end)

        if not success or not description or token ~= self.token then
            Runtime:Notify("Avatar Changer", "Usuário inválido ou indisponível")
            return
        end

        self.description = description
        self:Apply(getCharacter(), description, token)
    end)
end

function AvatarChanger:Disable()
    self.token = self.token + 1
    self.description = nil

    local character = getCharacter()
    local humanoid = getHumanoid(character)

    if character and humanoid then
        task.spawn(function()
            local description = nil
            pcall(function()
                description = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
            end)
            if description then
                pcall(function()
                    humanoid:ApplyDescriptionClientServer(description)
                end)
            end
        end)
    end
end

local ESP = {
    entries = {}
}

function ESP:DestroyEntry(player)
    local entry = self.entries[player]
    if not entry then
        return
    end

    for _, connection in ipairs(entry.connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    if entry.gui then
        pcall(function()
            entry.gui:Destroy()
        end)
    end

    self.entries[player] = nil
end

function ESP:UpdatePlayer(player)
    local entry = self.entries[player]
    if not entry or not entry.label then
        return
    end

    entry.label.Visible = State.abilityESP

    local ability = player:GetAttribute("EquippedAbility")
    if ability and tostring(ability) ~= "" then
        entry.label.Text = player.DisplayName .. " [" .. tostring(ability) .. "]"
    else
        entry.label.Text = player.DisplayName
    end
end

function ESP:Create(player, character)
    if player == LocalPlayer then
        return
    end

    self:DestroyEntry(player)

    local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 10)
    if not head then
        return
    end

    local gui = Instance.new("BillboardGui")
    gui.Name = "AbilityESP_Gui"
    gui.Adornee = head
    gui.Size = UDim2.new(0, 220, 0, 60)
    gui.StudsOffset = Vector3.new(0, 3.5, 0)
    gui.AlwaysOnTop = true
    gui.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.Visible = false
    label.Parent = gui

    local entry = {
        gui = gui,
        label = label,
        connections = {}
    }

    self.entries[player] = entry

    table.insert(entry.connections, player:GetAttributeChangedSignal("EquippedAbility"):Connect(function()
        self:UpdatePlayer(player)
    end))

    table.insert(entry.connections, player:GetPropertyChangedSignal("DisplayName"):Connect(function()
        self:UpdatePlayer(player)
    end))

    table.insert(entry.connections, character.AncestryChanged:Connect(function(_, parent)
        if not parent and self.entries[player] == entry then
            self:DestroyEntry(player)
        end
    end))

    self:UpdatePlayer(player)
end

function ESP:BindPlayer(player)
    if player == LocalPlayer then
        return
    end

    Runtime:Connect(player.CharacterAdded, function(character)
        task.wait(0.1)
        if Runtime.active then
            self:Create(player, character)
        end
    end)

    if player.Character then
        task.spawn(function()
            self:Create(player, player.Character)
        end)
    end
end

function ESP:SetEnabled(enabled)
    State.abilityESP = enabled
    for player in pairs(self.entries) do
        self:UpdatePlayer(player)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    ESP:BindPlayer(player)
end

Runtime:Connect(Players.PlayerAdded, function(player)
    ESP:BindPlayer(player)
end)

Runtime:Connect(Players.PlayerRemoving, function(player)
    ESP:DestroyEntry(player)
end)

Runtime:AddCleanup(function()
    for player in pairs(ESP.entries) do
        ESP:DestroyEntry(player)
    end
end)

local GraphicsController = {
    quality = nil,
    globalShadows = nil,
    fogEnd = nil
}

function GraphicsController:SetLowGraphics(enabled)
    State.lowGraphics = enabled

    if enabled then
        if self.quality == nil then
            pcall(function()
                self.quality = settings().Rendering.QualityLevel
            end)
        end
        if self.globalShadows == nil then
            self.globalShadows = Lighting.GlobalShadows
        end
        if self.fogEnd == nil then
            self.fogEnd = Lighting.FogEnd
        end

        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000000000
    else
        if self.quality ~= nil then
            pcall(function()
                settings().Rendering.QualityLevel = self.quality
            end)
        end
        if self.globalShadows ~= nil then
            Lighting.GlobalShadows = self.globalShadows
        end
        if self.fogEnd ~= nil then
            Lighting.FogEnd = self.fogEnd
        end
    end
end

Runtime:AddCleanup(function()
    GraphicsController:SetLowGraphics(false)
end)

local CameraController = {
    originalFOV = nil,
    connection = nil
}

function CameraController:SetEnabled(enabled)
    State.cameraEnabled = enabled

    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    if enabled then
        if self.originalFOV == nil then
            self.originalFOV = camera.FieldOfView
        end
        camera.FieldOfView = State.cameraFOV

        if not self.connection then
            self.connection = RunService.RenderStepped:Connect(function()
                local currentCamera = Workspace.CurrentCamera
                if Runtime.active and State.cameraEnabled and currentCamera then
                    currentCamera.FieldOfView = State.cameraFOV
                end
            end)
            Runtime:AddConnection(self.connection)
        end
    else
        if self.originalFOV ~= nil then
            camera.FieldOfView = self.originalFOV
        end
        if self.connection then
            self.connection:Disconnect()
            self.connection = nil
        end
    end
end

Runtime:AddCleanup(function()
    CameraController:SetEnabled(false)
end)

local SkinChanger = {
    active = true,
    initialized = false,
    swordModule = nil,
    swordController = nil,
    originalParryConnection = nil,
    replacementConnection = nil,
    originalParryFunction = nil,
    slashName = "SlashEffect"
}

function SkinChanger:SetIdentity(identity)
    if setthreadidentity then
        pcall(setthreadidentity, identity)
    end
end

function SkinChanger:GetIdentity()
    if getthreadidentity then
        local success, identity = pcall(getthreadidentity)
        if success then
            return identity
        end
    end
    return 2
end

function SkinChanger:GetSlashName(swordName)
    if not self.swordModule or swordName == "" then
        return "SlashEffect"
    end

    local oldIdentity = self:GetIdentity()
    self:SetIdentity(2)

    local swordData = nil
    pcall(function()
        swordData = self.swordModule:GetSword(swordName)
    end)

    self:SetIdentity(oldIdentity)
    return swordData and swordData.SlashName or "SlashEffect"
end

function SkinChanger:Equip()
    if not State.skinChanger or State.swordName == "" or not self.swordModule then
        return
    end

    local character = getCharacter()
    local alive = WorldCache.alive
    local humanoid = getHumanoid(character)

    if not character or not alive or character.Parent ~= alive or not humanoid or humanoid.Health <= 0 then
        return
    end

    local oldIdentity = self:GetIdentity()
    self:SetIdentity(2)

    pcall(function()
        if setupvalue then
            setupvalue(rawget(self.swordModule, "EquipSwordTo"), 3, false)
        end
        self.swordModule:EquipSwordTo(character, State.swordName)
    end)

    if self.swordController then
        pcall(function()
            self.swordController:SetSword(State.swordName)
        end)
    end

    self:SetIdentity(oldIdentity)
end

function SkinChanger:Update()
    self.slashName = self:GetSlashName(State.swordName)
    self:Equip()
end

function SkinChanger:Initialize()
    if self.initialized then
        return
    end
    self.initialized = true

    task.spawn(function()
        local swordsContainer = findPath(ReplicatedStorage, {"Shared", "ReplicatedInstances", "Swords"})
        if not swordsContainer then
            return
        end

        local oldIdentity = self:GetIdentity()
        self:SetIdentity(2)
        pcall(function()
            self.swordModule = require(swordsContainer)
        end)
        self:SetIdentity(oldIdentity)

        if not self.swordModule then
            return
        end

        if getconnections and getupvalues and islclosure then
            local fireSwordInfo = findPath(ReplicatedStorage, {"Remotes", "FireSwordInfo"})
            if fireSwordInfo and fireSwordInfo:IsA("RemoteEvent") then
                local deadline = os.clock() + 10
                while Runtime.active and not self.swordController and os.clock() < deadline do
                    for _, connection in ipairs(getconnections(fireSwordInfo.OnClientEvent)) do
                        local callback = connection.Function
                        if callback and islclosure(callback) then
                            local values = getupvalues(callback)
                            if #values == 1 and type(values[1]) == "table" and type(values[1].SetSword) == "function" then
                                self.swordController = values[1]
                                break
                            end
                        end
                    end
                    if not self.swordController then
                        task.wait(0.25)
                    end
                end
            end
        end

        local parrySuccessAll = findPath(ReplicatedStorage, {"Remotes", "ParrySuccessAll"})

        if parrySuccessAll and parrySuccessAll:IsA("RemoteEvent") and getconnections and getinfo then
            local deadline = os.clock() + 10

            while Runtime.active and not self.originalParryFunction and os.clock() < deadline do
                for _, connection in ipairs(getconnections(parrySuccessAll.OnClientEvent)) do
                    local callback = connection.Function
                    if callback then
                        local info = nil
                        pcall(function()
                            info = getinfo(callback)
                        end)
                        if info and info.name == "parrySuccessAll" then
                            self.originalParryFunction = callback
                            self.originalParryConnection = connection
                            break
                        end
                    end
                end

                if not self.originalParryFunction then
                    task.wait(0.25)
                end
            end

            if self.originalParryFunction then
                self.replacementConnection = parrySuccessAll.OnClientEvent:Connect(function(...)
                    local arguments = table.pack(...)
                    local oldThreadIdentity = self:GetIdentity()
                    self:SetIdentity(2)

                    if State.skinChanger and State.swordName ~= "" and tostring(arguments[4]) == LocalPlayer.Name then
                        arguments[1] = self.slashName
                        arguments[3] = State.swordName
                    end

                    pcall(function()
                        self.originalParryFunction(table.unpack(arguments, 1, arguments.n))
                    end)

                    self:SetIdentity(oldThreadIdentity)
                end)

                Runtime:AddConnection(self.replacementConnection)

                pcall(function()
                    self.originalParryConnection:Disable()
                end)
            end
        end

        while Runtime.active and self.active do
            task.wait(0.25)

            if State.skinChanger and State.swordName ~= "" then
                local character = getCharacter()
                local alive = WorldCache.alive
                local humanoid = getHumanoid(character)

                if character and alive and character.Parent == alive and humanoid and humanoid.Health > 0 then
                    local model = character:FindFirstChild(State.swordName)
                    if not model then
                        self:Equip()
                    end
                end
            end
        end
    end)
end

function SkinChanger:Unload()
    self.active = false
    if self.originalParryConnection then
        pcall(function()
            self.originalParryConnection:Enable()
        end)
    end
end

SkinChanger:Initialize()
Runtime:AddCleanup(function()
    SkinChanger:Unload()
end)

local boundRuntimeFolders = {}

local function getRealBall()
    local folder = WorldCache.balls or Workspace:FindFirstChild("Balls")
    if not folder then
        return nil
    end

    for _, ball in ipairs(folder:GetChildren()) do
        if ball:IsA("BasePart") and ball:GetAttribute("realBall") then
            return ball
        end
    end

    return nil
end

local function bindPhantomFolder(folder)
    if not folder or boundRuntimeFolders[folder] then
        return
    end

    boundRuntimeFolders[folder] = true

    Runtime:Connect(folder.ChildAdded, function(object)
        if not State.phantomDetection then
            return
        end

        if object.Name ~= "maxTransmission" and object.Name ~= "transmissionpart" then
            return
        end

        task.spawn(function()
            local weld = object:FindFirstChildWhichIsA("WeldConstraint")
            local weldDeadline = os.clock() + 1

            while not weld and object.Parent and os.clock() < weldDeadline do
                task.wait()
                weld = object:FindFirstChildWhichIsA("WeldConstraint")
            end

            local character = getCharacter()
            local root = getRoot(character)

            if not weld or not root or (weld.Part0 ~= root and weld.Part1 ~= root) then
                return
            end

            weld:Destroy()

            local ball = getRealBall()
            local abilityButton = findPath(ReplicatedStorage, {"Remotes", "AbilityButtonPress"})

            if not ball or not abilityButton then
                return
            end

            local connection
            connection = RunService.RenderStepped:Connect(function()
                if not Runtime.active or not State.phantomDetection or not ball.Parent then
                    connection:Disconnect()
                    return
                end

                local highlighted = ball:GetAttribute("highlighted")
                if highlighted == true then
                    pcall(function()
                        if abilityButton:IsA("BindableEvent") then
                            abilityButton:Fire()
                        elseif abilityButton:IsA("RemoteEvent") then
                            abilityButton:FireServer()
                        end
                    end)
                elseif highlighted == false then
                    connection:Disconnect()
                end
            end)

            Runtime:AddConnection(connection)

            task.delay(3, function()
                if connection and connection.Connected then
                    connection:Disconnect()
                end
            end)
        end)
    end)
end

if WorldCache.runtime then
    bindPhantomFolder(WorldCache.runtime)
end

Runtime:Connect(Workspace.ChildAdded, function(child)
    if child.Name == "Runtime" then
        WorldCache.runtime = child
        bindPhantomFolder(child)
    elseif child.Name == "Alive" then
        WorldCache.alive = child
    elseif child.Name == "Balls" then
        WorldCache.balls = child
    end
end)

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")

if remotesFolder then
    local deathBall = remotesFolder:FindFirstChild("DeathBall")
    if deathBall and deathBall:IsA("RemoteEvent") then
        Runtime:Connect(deathBall.OnClientEvent, function(_, active)
            State.deathSlashActive = not not active
        end)
    end

    local infinityBall = remotesFolder:FindFirstChild("InfinityBall")
    if infinityBall and infinityBall:IsA("RemoteEvent") then
        Runtime:Connect(infinityBall.OnClientEvent, function(_, active)
            State.infinityActive = not not active
        end)
    end
end

local net = findPath(ReplicatedStorage, {"Packages", "_Index", "sleitnick_net@0.1.0", "net"})
local furyLoopToken = 0

if net then
    local timeHoleActivate = net:FindFirstChild("RE/TimeHoleActivate")
    local timeHoleDeactivate = net:FindFirstChild("RE/TimeHoleDeactivate")
    local furyActivate = net:FindFirstChild("RE/SlashesOfFuryActivate")
    local furyEnd = net:FindFirstChild("RE/SlashesOfFuryEnd")
    local furyParry = net:FindFirstChild("RE/SlashesOfFuryParry")
    local furyCatch = net:FindFirstChild("RE/SlashesOfFuryCatch")

    if timeHoleActivate and timeHoleActivate:IsA("RemoteEvent") then
        Runtime:Connect(timeHoleActivate.OnClientEvent, function(player)
            if player == LocalPlayer or (player and player.Name == LocalPlayer.Name) then
                State.timeHoleActive = true
            end
        end)
    end

    if timeHoleDeactivate and timeHoleDeactivate:IsA("RemoteEvent") then
        Runtime:Connect(timeHoleDeactivate.OnClientEvent, function()
            State.timeHoleActive = false
        end)
    end

    if furyActivate and furyActivate:IsA("RemoteEvent") then
        Runtime:Connect(furyActivate.OnClientEvent, function(player)
            if player == LocalPlayer or (player and player.Name == LocalPlayer.Name) then
                furyLoopToken = furyLoopToken + 1
                State.slashesOfFuryActive = true
                State.slashesOfFuryCount = 0
            end
        end)
    end

    if furyEnd and furyEnd:IsA("RemoteEvent") then
        Runtime:Connect(furyEnd.OnClientEvent, function()
            furyLoopToken = furyLoopToken + 1
            State.slashesOfFuryActive = false
            State.slashesOfFuryCount = 0
        end)
    end

    if furyParry and furyParry:IsA("RemoteEvent") then
        Runtime:Connect(furyParry.OnClientEvent, function()
            State.slashesOfFuryCount = State.slashesOfFuryCount + 1
        end)
    end

    if furyCatch and furyCatch:IsA("RemoteEvent") then
        Runtime:Connect(furyCatch.OnClientEvent, function()
            furyLoopToken = furyLoopToken + 1
            local token = furyLoopToken

            task.spawn(function()
                while Runtime.active
                    and token == furyLoopToken
                    and State.slashesOfFuryDetection
                    and State.slashesOfFuryActive
                    and State.slashesOfFuryCount < State.maxParryCount do
                    fireParry(State.animationFix)
                    task.wait(State.parryDelay)
                end
            end)
        end)
    end
end

Runtime:Connect(LocalPlayer.CharacterAdded, function(character)
    task.wait(0.35)

    if State.headlessKorblox then
        Appearance.ApplyAll(character)
    end

    if State.lowGraphics then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    end

    if State.avatarChanger and AvatarChanger.description then
        AvatarChanger:Apply(character, AvatarChanger.description, AvatarChanger.token)
    end
end)

Runtime:AddCleanup(function()
    Appearance.RestoreAll(getCharacter())
    AvatarChanger:Disable()
end)

local P1 = Color3.fromRGB(140, 0, 255)
local P2 = Color3.fromRGB(80, 0, 160)
local P4 = Color3.fromRGB(10, 0, 20)
local WHITE = Color3.new(1, 1, 1)
local LGRAY = Color3.fromRGB(180, 160, 210)

local ScreenGui = Runtime:AddGui(Instance.new("ScreenGui"))
ScreenGui.Name = "SpamHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local StatsGui = Runtime:AddGui(Instance.new("ScreenGui"))
StatsGui.Name = "EagleBallStats"
StatsGui.ResetOnSpawn = false
StatsGui.IgnoreGuiInset = true
StatsGui.Parent = CoreGui

local function makeDraggable(frame, handle)
    handle = handle or frame

    local dragging = false
    local startPosition = nil
    local originalPosition = nil

    Runtime:Connect(handle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPosition = input.Position
            originalPosition = frame.Position
        end
    end)

    Runtime:Connect(UserInputService.InputChanged, function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - startPosition
            frame.Position = UDim2.new(
                originalPosition.X.Scale,
                originalPosition.X.Offset + delta.X,
                originalPosition.Y.Scale,
                originalPosition.Y.Offset + delta.Y
            )
        end
    end)

    Runtime:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local function showNotify(message)
    if not Runtime.active then
        return
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 230, 0, 40)
    frame.Position = UDim2.new(1, 10, 1, -55)
    frame.BackgroundColor3 = P4
    frame.BorderSizePixel = 0
    frame.ZIndex = 20
    frame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = P1
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -14, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = WHITE
    label.ZIndex = 21
    label.Text = message
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -240, 1, -55)
    }):Play()

    task.delay(3, function()
        if not frame.Parent then
            return
        end

        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 10, 1, -55)
        }):Play()

        task.delay(0.35, function()
            if frame.Parent then
                frame:Destroy()
            end
        end)
    end)
end

local CpsCounter = Instance.new("Frame")
CpsCounter.Size = UDim2.new(0, 95, 0, 30)
CpsCounter.Position = UDim2.new(0, 10, 0, 10)
CpsCounter.BackgroundColor3 = P4
CpsCounter.BackgroundTransparency = 0.05
CpsCounter.BorderSizePixel = 0
CpsCounter.Parent = ScreenGui

local CpsCorner = Instance.new("UICorner")
CpsCorner.CornerRadius = UDim.new(0, 10)
CpsCorner.Parent = CpsCounter

local CpsStroke = Instance.new("UIStroke")
CpsStroke.Color = P1
CpsStroke.Thickness = 1.5
CpsStroke.Parent = CpsCounter

local CpsCounterLabel = Instance.new("TextLabel")
CpsCounterLabel.Size = UDim2.new(1, 0, 1, 0)
CpsCounterLabel.BackgroundTransparency = 1
CpsCounterLabel.Text = "0 CPS"
CpsCounterLabel.Font = Enum.Font.GothamBold
CpsCounterLabel.TextSize = 13
CpsCounterLabel.TextColor3 = LGRAY
CpsCounterLabel.Parent = CpsCounter

makeDraggable(CpsCounter)

local SpamPanel = Instance.new("Frame")
SpamPanel.Size = UDim2.new(0, 145, 0, 65)
SpamPanel.Position = UDim2.new(0.5, -72, 1, -80)
SpamPanel.BackgroundColor3 = P4
SpamPanel.BackgroundTransparency = 0.05
SpamPanel.BorderSizePixel = 0
SpamPanel.Visible = false
SpamPanel.Parent = ScreenGui

local SpamCorner = Instance.new("UICorner")
SpamCorner.CornerRadius = UDim.new(0, 12)
SpamCorner.Parent = SpamPanel

local SpamStroke = Instance.new("UIStroke")
SpamStroke.Color = P1
SpamStroke.Thickness = 2
SpamStroke.Parent = SpamPanel

local SpamPanelTitle = Instance.new("TextLabel")
SpamPanelTitle.Size = UDim2.new(1, 0, 0, 22)
SpamPanelTitle.BackgroundTransparency = 1
SpamPanelTitle.Text = "Manual Spam"
SpamPanelTitle.Font = Enum.Font.GothamBold
SpamPanelTitle.TextSize = 11
SpamPanelTitle.TextColor3 = P1
SpamPanelTitle.Parent = SpamPanel

local SpamPanelButton = Instance.new("TextButton")
SpamPanelButton.Size = UDim2.new(0.85, 0, 0, 30)
SpamPanelButton.Position = UDim2.new(0.075, 0, 0, 27)
SpamPanelButton.BackgroundColor3 = P2
SpamPanelButton.Text = "SPAM: OFF"
SpamPanelButton.Font = Enum.Font.GothamBold
SpamPanelButton.TextSize = 13
SpamPanelButton.TextColor3 = WHITE
SpamPanelButton.BorderSizePixel = 0
SpamPanelButton.Parent = SpamPanel

local SpamButtonCorner = Instance.new("UICorner")
SpamButtonCorner.CornerRadius = UDim.new(0, 8)
SpamButtonCorner.Parent = SpamPanelButton

makeDraggable(SpamPanel, SpamPanelTitle)

local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(0, 175, 0, 110)
StatsFrame.Position = UDim2.new(0, 20, 0.5, -55)
StatsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
StatsFrame.BorderSizePixel = 0
StatsFrame.Visible = false
StatsFrame.Parent = StatsGui

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 10)
StatsCorner.Parent = StatsFrame

local StatsStroke = Instance.new("UIStroke")
StatsStroke.Color = Color3.fromRGB(255, 140, 0)
StatsStroke.Parent = StatsFrame

makeDraggable(StatsFrame)

local StatsTitle = Instance.new("TextLabel")
StatsTitle.Size = UDim2.new(1, 0, 0, 28)
StatsTitle.Text = " BALL STATS"
StatsTitle.TextColor3 = Color3.fromRGB(255, 140, 0)
StatsTitle.BackgroundTransparency = 1
StatsTitle.Font = Enum.Font.GothamBold
StatsTitle.TextSize = 13
StatsTitle.TextXAlignment = Enum.TextXAlignment.Left
StatsTitle.Parent = StatsFrame

local VelocityLabel = Instance.new("TextLabel")
VelocityLabel.Position = UDim2.new(0.08, 0, 0.27, 0)
VelocityLabel.Size = UDim2.new(0.8, 0, 0, 14)
VelocityLabel.Text = "Current"
VelocityLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
VelocityLabel.BackgroundTransparency = 1
VelocityLabel.Font = Enum.Font.Gotham
VelocityLabel.TextSize = 10
VelocityLabel.TextXAlignment = Enum.TextXAlignment.Left
VelocityLabel.Parent = StatsFrame

local VelocityLog = Instance.new("TextLabel")
VelocityLog.Position = UDim2.new(0.08, 0, 0.38, 0)
VelocityLog.Size = UDim2.new(0.8, 0, 0, 26)
VelocityLog.Text = "0.0"
VelocityLog.TextColor3 = Color3.new(1, 1, 1)
VelocityLog.BackgroundTransparency = 1
VelocityLog.Font = Enum.Font.GothamBold
VelocityLog.TextSize = 24
VelocityLog.TextXAlignment = Enum.TextXAlignment.Left
VelocityLog.Parent = StatsFrame

local PeakLabel = Instance.new("TextLabel")
PeakLabel.Position = UDim2.new(0.08, 0, 0.67, 0)
PeakLabel.Size = UDim2.new(0.8, 0, 0, 12)
PeakLabel.Text = "Peak"
PeakLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
PeakLabel.BackgroundTransparency = 1
PeakLabel.Font = Enum.Font.Gotham
PeakLabel.TextSize = 10
PeakLabel.TextXAlignment = Enum.TextXAlignment.Left
PeakLabel.Parent = StatsFrame

local PeakLog = Instance.new("TextLabel")
PeakLog.Position = UDim2.new(0.08, 0, 0.76, 0)
PeakLog.Size = UDim2.new(0.8, 0, 0, 18)
PeakLog.Text = "0.0"
PeakLog.TextColor3 = Color3.fromRGB(50, 220, 80)
PeakLog.BackgroundTransparency = 1
PeakLog.Font = Enum.Font.GothamBold
PeakLog.TextSize = 14
PeakLog.TextXAlignment = Enum.TextXAlignment.Left
PeakLog.Parent = StatsFrame

local function setSpamActive(enabled)
    if enabled and not Runtime.remoteHooked then
        showNotify("Bloqueie a bola uma vez primeiro")
        return
    end

    State.spamActive = enabled
    SpamPanelButton.Text = enabled and "SPAM: ON" or "SPAM: OFF"
    SpamPanelButton.BackgroundColor3 = enabled and P1 or P2

    if not enabled then
        CpsCounterLabel.Text = "0 CPS"
        CpsCounterLabel.TextColor3 = LGRAY
        CpsStroke.Color = P1
    end
end

local function toggleSpam()
    setSpamActive(not State.spamActive)
end

Runtime:Connect(SpamPanelButton.MouseButton1Click, toggleSpam)

local airflowSource = nil
local airflowSuccess, airflowError = pcall(function()
    airflowSource = game:HttpGetAsync("https://raw.githubusercontent.com/4lpaca-pin/Airflow/refs/heads/main/src/source.luau")
end)

if not airflowSuccess or not airflowSource then
    Runtime:Unload()
    error("Falha ao carregar Airflow: " .. tostring(airflowError))
end

local Airflow = nil
local librarySuccess, libraryError = pcall(function()
    Airflow = loadstring(airflowSource)()
end)

if not librarySuccess or not Airflow then
    Runtime:Unload()
    error("Falha ao iniciar Airflow: " .. tostring(libraryError))
end

local Window = Airflow:Init({
    Name = "Eagle Hub X",
    Keybind = "RightShift",
    Logo = "http://www.roblox.com/asset/?id=118752982916680"
})

Runtime.window = Window
Runtime.notify = function(title, content)
    Airflow:Notify({
        Title = title,
        Content = content,
        Duration = 3
    })
end

local function notify(title, content)
    Runtime:Notify(title, content)
end

local CombatTab = Window:DrawTab({Name = "Combat", Icon = "shield"})
local AutoParrySection = CombatTab:AddSection({Name = "Auto Parry", Position = "left"})

AutoParrySection:AddToggle({
    Name = "Auto Parry",
    Default = false,
    Callback = function(value)
        State.autoParry = value
        notify("Auto Parry", value and "ON" or "OFF")
    end
})

AutoParrySection:AddToggle({
    Name = "Animation Fix",
    Default = false,
    Callback = function(value)
        State.animationFix = value
    end
})

AutoParrySection:AddToggle({
    Name = "Anti Curve",
    Default = false,
    Callback = function(value)
        State.antiCurve = value
        notify("Anti Curve", value and "ON" or "OFF")
    end
})

AutoParrySection:AddSlider({
    Name = "Parry Distance",
    Default = 8,
    Min = 4,
    Max = 30,
    Callback = function(value)
        State.parryDistance = value
    end
})

AutoParrySection:AddDropdown({
    Name = "Curve Method",
    Values = {"camera", "dot", "backwards", "slow", "random", "accelerated", "high"},
    Multi = false,
    Default = "camera",
    Callback = function(value)
        State.curveMethod = value
    end
})

local SpamSection = CombatTab:AddSection({Name = "Manual Spam", Position = "right"})

SpamSection:AddSlider({
    Name = "Target CPS",
    Default = 240,
    Min = 1,
    Max = 450,
    Callback = function(value)
        State.targetCPS = math.max(1, value)
    end
})

SpamSection:AddToggle({
    Name = "Spam Animation Fix",
    Default = true,
    Callback = function(value)
        State.spamAnimationFix = value
    end
})

SpamSection:AddToggle({
    Name = "Show Manual Spam Panel",
    Default = false,
    Callback = function(value)
        SpamPanel.Visible = value
        notify("Spam Panel", value and "Shown" or "Hidden")
    end
})

SpamSection:AddKeybind({
    Name = "Toggle Spam Key",
    Default = "E",
    Callback = toggleSpam
})

SpamSection:AddButton({
    Name = "Toggle Spam Now",
    Callback = toggleSpam
})

local DetectionTab = Window:DrawTab({Name = "Detection", Icon = "shield-alert"})
local DetectionSection = DetectionTab:AddSection({Name = "Ability Detections", Position = "left"})

DetectionSection:AddToggle({
    Name = "Infinity",
    Default = false,
    Callback = function(value)
        State.infinityDetection = value
        notify("Infinity", value and "ON" or "OFF")
    end
})

DetectionSection:AddToggle({
    Name = "Death Slash",
    Default = false,
    Callback = function(value)
        State.deathSlashDetection = value
        notify("Death Slash", value and "ON" or "OFF")
    end
})

DetectionSection:AddToggle({
    Name = "Time Hole",
    Default = false,
    Callback = function(value)
        State.timeHoleDetection = value
        notify("Time Hole", value and "ON" or "OFF")
    end
})

DetectionSection:AddToggle({
    Name = "Anti-Phantom",
    Default = false,
    Callback = function(value)
        State.phantomDetection = value
        notify("Anti-Phantom", value and "ON" or "OFF")
    end
})

local FurySection = DetectionTab:AddSection({Name = "Slashes of Fury", Position = "right"})

FurySection:AddToggle({
    Name = "Slashes of Fury",
    Default = false,
    Callback = function(value)
        State.slashesOfFuryDetection = value
        notify("Slashes of Fury", value and "ON" or "OFF")
    end
})

FurySection:AddSlider({
    Name = "Parry Delay (ms)",
    Default = 5,
    Min = 5,
    Max = 25,
    Callback = function(value)
        State.parryDelay = value / 1000
    end
})

FurySection:AddSlider({
    Name = "Max Parry Count",
    Default = 36,
    Min = 1,
    Max = 36,
    Callback = function(value)
        State.maxParryCount = value
    end
})

local VisualsTab = Window:DrawTab({Name = "Visuals", Icon = "eye"})
local DisplaySection = VisualsTab:AddSection({Name = "Display", Position = "left"})

DisplaySection:AddToggle({
    Name = "Ball Stats",
    Default = false,
    Callback = function(value)
        State.showBallStats = value
        StatsFrame.Visible = value
        if not value then
            State.peakVelocity = 0
            VelocityLog.Text = "0.0"
            PeakLog.Text = "0.0"
        end
        notify("Ball Stats", value and "ON" or "OFF")
    end
})

DisplaySection:AddToggle({
    Name = "Ability ESP",
    Default = false,
    Callback = function(value)
        ESP:SetEnabled(value)
        notify("Ability ESP", value and "ON" or "OFF")
    end
})

DisplaySection:AddToggle({
    Name = "Low Graphics",
    Default = false,
    Callback = function(value)
        GraphicsController:SetLowGraphics(value)
        notify("Low Graphics", value and "ON" or "OFF")
    end
})

local CameraSection = VisualsTab:AddSection({Name = "Camera", Position = "right"})

CameraSection:AddToggle({
    Name = "FOV Changer",
    Default = false,
    Callback = function(value)
        CameraController:SetEnabled(value)
    end
})

CameraSection:AddSlider({
    Name = "FOV Value",
    Default = 70,
    Min = 50,
    Max = 120,
    Callback = function(value)
        State.cameraFOV = value
        if State.cameraEnabled and Workspace.CurrentCamera then
            Workspace.CurrentCamera.FieldOfView = value
        end
    end
})

local PlayerTab = Window:DrawTab({Name = "Player", Icon = "user"})
local AppearanceSection = PlayerTab:AddSection({Name = "Appearance", Position = "left"})

AppearanceSection:AddToggle({
    Name = "Headless & Korblox",
    Default = false,
    Callback = function(value)
        State.headlessKorblox = value
        local character = getCharacter()

        if character then
            if value then
                Appearance.ApplyAll(character)
            else
                Appearance.RestoreAll(character)
            end
        end

        notify("Headless & Korblox", value and "ON" or "OFF")
    end
})

local AvatarSection = PlayerTab:AddSection({Name = "Avatar Changer", Position = "right"})

AvatarSection:AddToggle({
    Name = "Avatar Changer",
    Default = false,
    Callback = function(value)
        State.avatarChanger = value

        if value then
            AvatarChanger:SetName(State.avatarName)
        else
            AvatarChanger:Disable()
        end

        notify("Avatar Changer", value and "ON" or "OFF")
    end
})

AvatarSection:AddTextbox({
    Name = "Avatar Username",
    Numeric = false,
    Placeholder = "Enter username...",
    Default = "",
    Finished = true,
    Callback = function(value)
        State.avatarName = value
        if State.avatarChanger then
            AvatarChanger:SetName(value)
        end
    end
})

local SkinTab = Window:DrawTab({Name = "Skin Changer", Icon = "zap"})
local SkinSection = SkinTab:AddSection({Name = "Skin Changer", Position = "left"})

SkinSection:AddToggle({
    Name = "Skin Changer",
    Default = false,
    Callback = function(value)
        State.skinChanger = value
        if value then
            SkinChanger:Update()
        end
        notify("Skin Changer", value and "ON" or "OFF")
    end
})

SkinSection:AddTextbox({
    Name = "Sword Name",
    Numeric = false,
    Placeholder = "e.g. Yin Yang Greatsword",
    Default = "",
    Finished = true,
    Callback = function(value)
        State.swordName = value
        if State.skinChanger then
            SkinChanger:Update()
        end
    end
})

local SettingsTab = Window:DrawTab({Name = "Settings", Icon = "settings"})
local MenuSection = SettingsTab:AddSection({Name = "Menu", Position = "left"})

MenuSection:AddKeybind({
    Name = "Menu Keybind",
    Default = "RightShift",
    Callback = function(value)
        pcall(function()
            Window:SetKeybind(value)
        end)
    end
})

MenuSection:AddToggle({
    Name = "Resizable",
    Default = false,
    Callback = function(value)
        pcall(function()
            Window:SetResizable(value)
        end)
    end
})

MenuSection:AddButton({
    Name = "Unload Hub",
    Callback = function()
        Runtime:Unload()
    end
})

notify("Eagle Hub X", "Loaded | RightShift = Toggle UI")

if Runtime.remoteHooked then
    notify("Eagle Hub X", "Remote de parry já capturado")
elseif Runtime.parryRemote then
    showNotify("Bloqueie a bola uma vez para capturar os argumentos")
else
    showNotify("Remote ainda não encontrado")
end

local parriedBalls = {}
local frameCounter = 0
local spamAccumulator = 0
local spamWindowTime = 0
local spamWindowCount = 0

local function getBallTarget(ball)
    for _, attribute in ipairs({"target", "Target", "targetPlayer", "TargetPlayer"}) do
        local value = ball:GetAttribute(attribute)
        if value ~= nil then
            return value, attribute
        end
    end
    return nil, nil
end

local function targetIsLocalPlayer(target)
    return target == LocalPlayer.Name
        or target == LocalPlayer.UserId
        or target == tostring(LocalPlayer.UserId)
        or target == LocalPlayer
end

local function lockBall(ball, attributeName)
    local identifier = ball
    parriedBalls[identifier] = true

    local released = false
    local targetConnection = nil
    local ancestryConnection = nil

    local function release()
        if released then
            return
        end

        released = true
        parriedBalls[identifier] = nil

        if targetConnection then
            targetConnection:Disconnect()
        end
        if ancestryConnection then
            ancestryConnection:Disconnect()
        end
    end

    if attributeName then
        targetConnection = ball:GetAttributeChangedSignal(attributeName):Connect(release)
    end

    ancestryConnection = ball.AncestryChanged:Connect(function(_, parent)
        if not parent then
            release()
        end
    end)

    task.delay(1.5, release)
end

local function shouldBlockAbilityParry()
    return (State.infinityDetection and State.infinityActive)
        or (State.deathSlashDetection and State.deathSlashActive)
        or (State.timeHoleDetection and State.timeHoleActive)
end

local function shouldAutoParry(ball, root, speed, distance)
    if speed <= 0.5 then
        return false
    end

    local zoomies = ball:FindFirstChild("zoomies")
    local velocity = ball.AssemblyLinearVelocity

    if zoomies then
        pcall(function()
            if typeof(zoomies.VectorVelocity) == "Vector3" then
                velocity = zoomies.VectorVelocity
            end
        end)
    end

    if velocity.Magnitude <= 0.001 then
        return false
    end

    if State.antiCurve then
        return distance <= State.parryDistance
    end

    local directionToPlayer = safeUnit(root.Position - ball.Position)
    local movementDirection = safeUnit(velocity)
    local dot = directionToPlayer:Dot(movementDirection)
    local minimumDot = math.clamp(0.15 - WorldCache.ping * 0.3, 0.05, 0.15)

    if dot < minimumDot then
        return false
    end

    local reactionDistance = math.clamp(
        speed * (WorldCache.ping + 0.016) * 2.6,
        State.parryDistance,
        70
    )

    return distance <= reactionDistance
end

Runtime:Connect(RunService.Heartbeat, function(deltaTime)
    if not Runtime.active then
        return
    end

    local now = os.clock()
    frameCounter = frameCounter + 1

    updateFolders(now)
    updateRoot(now)
    updateBall(now)
    updatePing(now)

    if WorldCache.runtime then
        bindPhantomFolder(WorldCache.runtime)
    end

    local root = WorldCache.root
    local ball = WorldCache.ball

    if root and ball and ball.Parent then
        local velocity = ball.AssemblyLinearVelocity.Magnitude

        if State.showBallStats and frameCounter % 3 == 0 then
            VelocityLog.Text = string.format("%.1f", velocity)
            if velocity > State.peakVelocity then
                State.peakVelocity = velocity
                PeakLog.Text = string.format("%.1f", State.peakVelocity)
            end
        end

        if State.autoParry and Runtime.remoteHooked and not shouldBlockAbilityParry() then
            local target, targetAttribute = getBallTarget(ball)

            if targetIsLocalPlayer(target) then
                local identifier = ball

                if not parriedBalls[identifier] then
                    local distance = (root.Position - ball.Position).Magnitude

                    if shouldAutoParry(ball, root, velocity, distance) then
                        if fireParry(State.animationFix) then
                            lockBall(ball, targetAttribute)
                        end
                    end
                end
            end
        end
    elseif State.showBallStats and frameCounter % 3 == 0 then
        VelocityLog.Text = "0.0"
    end

    spamWindowTime = spamWindowTime + deltaTime

    if State.spamActive and Runtime.remoteHooked then
        spamAccumulator = spamAccumulator + deltaTime
        local interval = 1 / math.max(State.targetCPS, 1)
        local firesThisFrame = 0

        while spamAccumulator >= interval and firesThisFrame < 20 do
            spamAccumulator = spamAccumulator - interval

            if fireParry(State.spamAnimationFix) then
                spamWindowCount = spamWindowCount + 1
            end

            firesThisFrame = firesThisFrame + 1
        end

        if firesThisFrame >= 20 then
            spamAccumulator = math.min(spamAccumulator, interval * 2)
        end
    else
        spamAccumulator = 0
    end

    if spamWindowTime >= 0.25 then
        if State.spamActive then
            local realCPS = math.floor(spamWindowCount / spamWindowTime)
            CpsCounterLabel.Text = tostring(realCPS) .. " CPS"

            if realCPS <= 100 then
                CpsCounterLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
                CpsStroke.Color = Color3.fromRGB(255, 60, 60)
            elseif realCPS <= 150 then
                CpsCounterLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                CpsStroke.Color = Color3.fromRGB(255, 200, 0)
            else
                CpsCounterLabel.TextColor3 = Color3.fromRGB(50, 220, 80)
                CpsStroke.Color = Color3.fromRGB(50, 220, 80)
            end
        else
            CpsCounterLabel.Text = "0 CPS"
            CpsCounterLabel.TextColor3 = LGRAY
            CpsStroke.Color = P1
        end

        spamWindowTime = 0
        spamWindowCount = 0
    end
end)
