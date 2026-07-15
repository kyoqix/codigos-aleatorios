local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local terrain = Workspace:FindFirstChildOfClass("Terrain")

local oldStretchGui = playerGui:FindFirstChild("StretchController")
if oldStretchGui then
	oldStretchGui:Destroy()
end

RunService:UnbindFromRenderStep("StretchControllerRender")
RunService:UnbindFromRenderStep("TesteHubScreenStretch")

local existing = playerGui:FindFirstChild("TesteHub")
if existing then
	existing:Destroy()
end

local theme = {
	background = Color3.fromRGB(7, 7, 7),
	surface = Color3.fromRGB(11, 11, 11),
	elevated = Color3.fromRGB(15, 15, 15),
	hover = Color3.fromRGB(21, 21, 21),
	active = Color3.fromRGB(238, 238, 238),
	text = Color3.fromRGB(224, 224, 224),
	subtext = Color3.fromRGB(135, 135, 135),
	dim = Color3.fromRGB(82, 82, 82),
	border = Color3.fromRGB(42, 42, 42),
	borderActive = Color3.fromRGB(90, 90, 90)
}

local function create(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	object.Parent = parent
	return object
end

local function playTween(object, properties, duration, style, direction)
	local animation = TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.2,
			style or Enum.EasingStyle.Quint,
			direction or Enum.EasingDirection.Out
		),
		properties
	)

	animation:Play()
	return animation
end

local function addCorner(object, radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius or 6)
	}, object)
end

local function addStroke(object, color, thickness, transparency)
	return create("UIStroke", {
		Color = color or theme.border,
		Thickness = thickness or 1,
		Transparency = transparency or 0
	}, object)
end

local destroyClasses = {
	ParticleEmitter = true,
	Trail = true,
	Beam = true,
	Smoke = true,
	Fire = true,
	Sparkles = true,
	Explosion = true,
	Highlight = true,
	ForceField = true,
	Atmosphere = true,
	Clouds = true,
	Sky = true,
	SelectionBox = true,
	SelectionSphere = true,
	SurfaceSelection = true,
	BoxHandleAdornment = true,
	SphereHandleAdornment = true,
	CylinderHandleAdornment = true,
	ConeHandleAdornment = true,
	LineHandleAdornment = true,
	WireframeHandleAdornment = true,
	Handles = true,
	ArcHandles = true
}

local noRender = {
	enabled = false,
	vfx = true,
	sfx = true,
	lighting = true,
	parts = true,
	terrain = true,
	descendantConnection = nil,
	propertyLocks = {},
	originalProperties = {},
	processed = 0,
	destroyed = 0
}

local screenStretch = {
	enabled = false,
	minimum = 0.1,
	maximum = 3,
	default = 1,
	factor = 1,
	bindName = "TesteHubScreenStretch",
	lastCamera = nil,
	lastBaseCFrame = nil,
	lastAppliedCFrame = nil
}

local function restoreCameraTransform()
	local camera = screenStretch.lastCamera
	local baseCFrame = screenStretch.lastBaseCFrame

	if camera and baseCFrame then
		pcall(function()
			if not screenStretch.lastAppliedCFrame or camera.CFrame == screenStretch.lastAppliedCFrame then
				camera.CFrame = baseCFrame
			end
		end)
	end

	screenStretch.lastCamera = nil
	screenStretch.lastBaseCFrame = nil
	screenStretch.lastAppliedCFrame = nil
end

local function applyScreenStretch()
	if not screenStretch.enabled or math.abs(screenStretch.factor - 1) < 0.0001 then
		return
	end

	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	pcall(function()
		if screenStretch.lastCamera == camera
			and screenStretch.lastAppliedCFrame
			and screenStretch.lastBaseCFrame
			and camera.CFrame == screenStretch.lastAppliedCFrame then
			camera.CFrame = screenStretch.lastBaseCFrame
		end

		local baseCFrame = camera.CFrame
		local transform = CFrame.new(
			0, 0, 0,
			1, 0, 0,
			0, screenStretch.factor, 0,
			0, 0, 1
		)
		local appliedCFrame = baseCFrame * transform

		screenStretch.lastCamera = camera
		screenStretch.lastBaseCFrame = baseCFrame
		screenStretch.lastAppliedCFrame = appliedCFrame
		camera.CFrame = appliedCFrame
	end)
end

local function setScreenStretchEnabled(state)
	state = state == true

	if screenStretch.enabled == state then
		return
	end

	screenStretch.enabled = state
	RunService:UnbindFromRenderStep(screenStretch.bindName)

	if state then
		RunService:BindToRenderStep(
			screenStretch.bindName,
			Enum.RenderPriority.Camera.Value + 1,
			applyScreenStretch
		)
	else
		restoreCameraTransform()
	end
end

local function setScreenStretchFactor(value)
	screenStretch.factor = math.clamp(
		tonumber(value) or screenStretch.default,
		screenStretch.minimum,
		screenStretch.maximum
	)

	if math.abs(screenStretch.factor - 1) < 0.0001 then
		restoreCameraTransform()
	end
end

local function getPropertyBucket(container, instance, createBucket)
	local bucket = container[instance]

	if not bucket and createBucket then
		bucket = {}
		container[instance] = bucket
	end

	return bucket
end

local function safeDestroy(instance)
	if not instance or not instance.Parent then
		return false
	end

	local success = pcall(function()
		instance:Destroy()
	end)

	if success then
		noRender.destroyed += 1
	end

	return success
end

local function lockProperty(instance, property, value)
	if not instance then
		return
	end

	local locks = getPropertyBucket(noRender.propertyLocks, instance, true)
	if locks[property] then
		return
	end

	local success, originalValue = pcall(function()
		return instance[property]
	end)

	if not success then
		return
	end

	local originals = getPropertyBucket(noRender.originalProperties, instance, true)
	originals[property] = originalValue

	pcall(function()
		instance[property] = value
	end)

	locks[property] = instance:GetPropertyChangedSignal(property):Connect(function()
		if not noRender.enabled then
			return
		end

		pcall(function()
			if instance[property] ~= value then
				instance[property] = value
			end
		end)
	end)
end

local function unlockProperty(instance, property, restore)
	local locks = getPropertyBucket(noRender.propertyLocks, instance, false)
	local originals = getPropertyBucket(noRender.originalProperties, instance, false)

	if locks and locks[property] then
		locks[property]:Disconnect()
		locks[property] = nil
	end

	if restore and originals and originals[property] ~= nil then
		pcall(function()
			instance[property] = originals[property]
		end)
	end

	if originals then
		originals[property] = nil
	end

	if locks and next(locks) == nil then
		noRender.propertyLocks[instance] = nil
	end

	if originals and next(originals) == nil then
		noRender.originalProperties[instance] = nil
	end
end

local function unlockAllProperties(restore)
	for instance, locks in pairs(noRender.propertyLocks) do
		for property, connection in pairs(locks) do
			connection:Disconnect()
			locks[property] = nil
		end
		noRender.propertyLocks[instance] = nil
	end

	if restore then
		for instance, originals in pairs(noRender.originalProperties) do
			for property, value in pairs(originals) do
				pcall(function()
					instance[property] = value
				end)
				originals[property] = nil
			end
			noRender.originalProperties[instance] = nil
		end
	else
		table.clear(noRender.originalProperties)
	end
end

local function applyGlobalSettings()
	if noRender.sfx then
		lockProperty(SoundService, "Volume", 0)
	else
		unlockProperty(SoundService, "Volume", true)
	end

	if noRender.lighting then
		lockProperty(Lighting, "GlobalShadows", false)
		lockProperty(Lighting, "ShadowSoftness", 0)
		lockProperty(Lighting, "EnvironmentDiffuseScale", 0)
		lockProperty(Lighting, "EnvironmentSpecularScale", 0)
	else
		unlockProperty(Lighting, "GlobalShadows", true)
		unlockProperty(Lighting, "ShadowSoftness", true)
		unlockProperty(Lighting, "EnvironmentDiffuseScale", true)
		unlockProperty(Lighting, "EnvironmentSpecularScale", true)
	end

	if terrain then
		if noRender.terrain then
			lockProperty(terrain, "Decoration", false)
			lockProperty(terrain, "WaterWaveSize", 0)
			lockProperty(terrain, "WaterWaveSpeed", 0)
			lockProperty(terrain, "WaterReflectance", 0)
		else
			unlockProperty(terrain, "Decoration", true)
			unlockProperty(terrain, "WaterWaveSize", true)
			unlockProperty(terrain, "WaterWaveSpeed", true)
			unlockProperty(terrain, "WaterReflectance", true)
		end
	end
end

local function processInstance(instance)
	if not noRender.enabled or not instance or not instance.Parent then
		return
	end

	noRender.processed += 1

	if noRender.vfx and destroyClasses[instance.ClassName] then
		safeDestroy(instance)
		return
	end

	if noRender.sfx then
		if instance:IsA("Sound") then
			pcall(function()
				instance.Volume = 0
				instance.Playing = false
			end)
			safeDestroy(instance)
			return
		end

		if instance:IsA("SoundEffect") then
			safeDestroy(instance)
			return
		end
	end

	if noRender.lighting then
		if instance:IsA("PostEffect") or instance:IsA("Light") then
			safeDestroy(instance)
			return
		end
	end

	if noRender.parts and instance:IsA("BasePart") then
		pcall(function()
			instance.CastShadow = false
			instance.Reflectance = 0
		end)
	end
end

local function scanGame()
	if not noRender.enabled then
		return
	end

	noRender.processed = 0
	noRender.destroyed = 0

	local descendants = game:GetDescendants()

	for index, instance in ipairs(descendants) do
		processInstance(instance)

		if index % 500 == 0 then
			task.wait()
		end
	end
end

local function connectNoRender()
	if noRender.descendantConnection then
		noRender.descendantConnection:Disconnect()
	end

	noRender.descendantConnection = game.DescendantAdded:Connect(function(instance)
		task.defer(processInstance, instance)
	end)
end

local function setNoRenderEnabled(state)
	if noRender.enabled == state then
		return
	end

	noRender.enabled = state

	if state then
		applyGlobalSettings()
		connectNoRender()
		task.spawn(scanGame)
	else
		if noRender.descendantConnection then
			noRender.descendantConnection:Disconnect()
			noRender.descendantConnection = nil
		end

		unlockAllProperties(true)
	end
end

local function refreshNoRender()
	if not noRender.enabled then
		return
	end

	applyGlobalSettings()
	task.spawn(scanGame)
end

local gui = create("ScreenGui", {
	Name = "TesteHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local root = create("CanvasGroup", {
	Name = "Root",
	Size = UDim2.fromOffset(520, 334),
	Position = UDim2.new(0.5, -260, 0.5, -167),
	BackgroundColor3 = theme.background,
	BorderSizePixel = 0,
	GroupTransparency = 1,
	ClipsDescendants = true
}, gui)

addCorner(root, 8)
addStroke(root, theme.borderActive, 1, 0.35)

local scale = create("UIScale", {
	Scale = 1
}, root)

local function updateScale()
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end

	local viewport = camera.ViewportSize
	local target = math.min(viewport.X / 620, viewport.Y / 430, 1)
	scale.Scale = math.clamp(target, 0.72, 1)
end

updateScale()

if Workspace.CurrentCamera then
	Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local topbar = create("Frame", {
	Name = "Topbar",
	Size = UDim2.new(1, 0, 0, 42),
	BackgroundColor3 = theme.surface,
	BorderSizePixel = 0
}, root)

create("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = theme.border,
	BorderSizePixel = 0
}, topbar)

local brand = create("TextLabel", {
	Size = UDim2.fromOffset(210, 20),
	Position = UDim2.fromOffset(15, 5),
	BackgroundTransparency = 1,
	Text = "TESTE",
	TextColor3 = theme.text,
	TextSize = 14,
	Font = Enum.Font.SourceSansSemibold,
	TextXAlignment = Enum.TextXAlignment.Left
}, topbar)

create("TextLabel", {
	Size = UDim2.fromOffset(210, 12),
	Position = UDim2.fromOffset(15, 23),
	BackgroundTransparency = 1,
	Text = "no render / anti lag",
	TextColor3 = theme.subtext,
	TextSize = 10,
	Font = Enum.Font.SourceSans,
	TextXAlignment = Enum.TextXAlignment.Left
}, topbar)

local minimizeButton = create("TextButton", {
	Size = UDim2.fromOffset(29, 28),
	Position = UDim2.new(1, -68, 0, 7),
	BackgroundColor3 = theme.surface,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Text = "-",
	TextColor3 = theme.subtext,
	TextSize = 15,
	Font = Enum.Font.SourceSans,
	AutoButtonColor = false
}, topbar)

addCorner(minimizeButton, 5)

local closeButton = create("TextButton", {
	Size = UDim2.fromOffset(29, 28),
	Position = UDim2.new(1, -35, 0, 7),
	BackgroundColor3 = theme.surface,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Text = "x",
	TextColor3 = theme.subtext,
	TextSize = 14,
	Font = Enum.Font.SourceSans,
	AutoButtonColor = false
}, topbar)

addCorner(closeButton, 5)

local sidebar = create("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 132, 1, -42),
	Position = UDim2.fromOffset(0, 42),
	BackgroundColor3 = theme.surface,
	BorderSizePixel = 0
}, root)

create("Frame", {
	Size = UDim2.new(0, 1, 1, 0),
	Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = theme.border,
	BorderSizePixel = 0
}, sidebar)

create("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18),
	Position = UDim2.fromOffset(12, 12),
	BackgroundTransparency = 1,
	Text = "NAVIGATION",
	TextColor3 = theme.dim,
	TextSize = 10,
	Font = Enum.Font.SourceSans,
	TextXAlignment = Enum.TextXAlignment.Left
}, sidebar)

local navigation = create("Frame", {
	Size = UDim2.new(1, -16, 0, 150),
	Position = UDim2.fromOffset(8, 38),
	BackgroundTransparency = 1
}, sidebar)

create("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder
}, navigation)

local shortcut = create("Frame", {
	Size = UDim2.new(1, -16, 0, 42),
	Position = UDim2.new(0, 8, 1, -50),
	BackgroundColor3 = theme.elevated,
	BorderSizePixel = 0
}, sidebar)

addCorner(shortcut, 5)
addStroke(shortcut, theme.border, 1, 0.3)

create("TextLabel", {
	Size = UDim2.new(1, -16, 0, 16),
	Position = UDim2.fromOffset(8, 5),
	BackgroundTransparency = 1,
	Text = "RIGHT SHIFT",
	TextColor3 = theme.text,
	TextSize = 10,
	Font = Enum.Font.SourceSans,
	TextXAlignment = Enum.TextXAlignment.Left
}, shortcut)

create("TextLabel", {
	Size = UDim2.new(1, -16, 0, 13),
	Position = UDim2.fromOffset(8, 21),
	BackgroundTransparency = 1,
	Text = "show / hide",
	TextColor3 = theme.subtext,
	TextSize = 10,
	Font = Enum.Font.SourceSans,
	TextXAlignment = Enum.TextXAlignment.Left
}, shortcut)

local content = create("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -132, 1, -42),
	Position = UDim2.fromOffset(132, 42),
	BackgroundColor3 = theme.background,
	BorderSizePixel = 0,
	ClipsDescendants = true
}, root)

local pageContainer = create("Frame", {
	Size = UDim2.new(1, -24, 1, -20),
	Position = UDim2.fromOffset(12, 10),
	BackgroundTransparency = 1,
	ClipsDescendants = true
}, content)

local pages = {}
local tabs = {}
local activePage
local switching = false

local function createPage(name)
	local page = create("CanvasGroup", {
		Name = name,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false
	}, pageContainer)

	local scroll = create("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = theme.borderActive,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	}, page)

	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, scroll)

	create("UIPadding", {
		PaddingRight = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 6)
	}, scroll)

	pages[name] = {
		group = page,
		scroll = scroll
	}

	return scroll
end

local function setTabVisual(name, selected)
	local tab = tabs[name]
	if not tab then
		return
	end

	playTween(tab.button, {
		BackgroundColor3 = selected and theme.active or theme.surface
	}, 0.2)

	playTween(tab.text, {
		TextColor3 = selected and theme.background or theme.subtext
	}, 0.2)

	playTween(tab.indicator, {
		BackgroundTransparency = selected and 0 or 1,
		Size = selected and UDim2.fromOffset(2, 14) or UDim2.fromOffset(2, 4)
	}, 0.2)
end

local function switchPage(name)
	if switching or activePage == name or not pages[name] then
		return
	end

	switching = true

	local incoming = pages[name].group
	local outgoing = activePage and pages[activePage].group

	for tabName in pairs(tabs) do
		setTabVisual(tabName, tabName == name)
	end

	if outgoing then
		playTween(outgoing, {
			GroupTransparency = 1,
			Position = UDim2.fromOffset(-12, 0)
		}, 0.16)

		task.wait(0.12)
		outgoing.Visible = false
	end

	incoming.Visible = true
	incoming.GroupTransparency = 1
	incoming.Position = UDim2.fromOffset(14, 0)

	playTween(incoming, {
		GroupTransparency = 0,
		Position = UDim2.fromOffset(0, 0)
	}, 0.22)

	activePage = name
	task.wait(0.22)
	switching = false
end

local function createTab(name, label, index)
	local button = create("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 31),
		BackgroundColor3 = theme.surface,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = index
	}, navigation)

	addCorner(button, 5)
	addStroke(button, theme.border, 1, 0.45)

	local indicator = create("Frame", {
		Size = UDim2.fromOffset(2, 4),
		Position = UDim2.new(0, 7, 0.5, -2),
		BackgroundColor3 = theme.background,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}, button)

	addCorner(indicator, 1)

	local text = create("TextLabel", {
		Size = UDim2.new(1, -26, 1, 0),
		Position = UDim2.fromOffset(20, 0),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = theme.subtext,
		TextSize = 11,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, button)

	tabs[name] = {
		button = button,
		text = text,
		indicator = indicator
	}

	button.MouseEnter:Connect(function()
		if activePage ~= name then
			playTween(button, {
				BackgroundColor3 = theme.hover
			}, 0.15)

			playTween(text, {
				TextColor3 = theme.text
			}, 0.15)
		end
	end)

	button.MouseLeave:Connect(function()
		if activePage ~= name then
			playTween(button, {
				BackgroundColor3 = theme.surface
			}, 0.15)

			playTween(text, {
				TextColor3 = theme.subtext
			}, 0.15)
		end
	end)

	button.MouseButton1Click:Connect(function()
		switchPage(name)
	end)
end

local function createSection(parent, text)
	return create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = string.upper(text),
		TextColor3 = theme.dim,
		TextSize = 10,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, parent)
end

local function createCard(parent, height)
	local card = create("Frame", {
		Size = UDim2.new(1, -2, 0, height or 44),
		BackgroundColor3 = theme.surface,
		BorderSizePixel = 0
	}, parent)

	addCorner(card, 6)
	local cardStroke = addStroke(card, theme.border, 1, 0.3)

	card.MouseEnter:Connect(function()
		playTween(card, {
			BackgroundColor3 = theme.elevated
		}, 0.16)

		playTween(cardStroke, {
			Color = theme.borderActive
		}, 0.16)
	end)

	card.MouseLeave:Connect(function()
		playTween(card, {
			BackgroundColor3 = theme.surface
		}, 0.16)

		playTween(cardStroke, {
			Color = theme.border
		}, 0.16)
	end)

	return card
end

local function createInfo(parent, titleText, description)
	local card = createCard(parent, 62)

	create("TextLabel", {
		Size = UDim2.new(1, -22, 0, 18),
		Position = UDim2.fromOffset(11, 8),
		BackgroundTransparency = 1,
		Text = titleText,
		TextColor3 = theme.text,
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	create("TextLabel", {
		Size = UDim2.new(1, -22, 0, 28),
		Position = UDim2.fromOffset(11, 27),
		BackgroundTransparency = 1,
		Text = description,
		TextColor3 = theme.subtext,
		TextSize = 10,
		Font = Enum.Font.SourceSans,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top
	}, card)

	return card
end

local function createButton(parent, text, callback)
	local button = create("TextButton", {
		Size = UDim2.new(1, -2, 0, 39),
		BackgroundColor3 = theme.surface,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 11,
		Font = Enum.Font.SourceSans,
		AutoButtonColor = false
	}, parent)

	addCorner(button, 6)
	local buttonStroke = addStroke(button, theme.border, 1, 0.3)

	button.MouseEnter:Connect(function()
		playTween(button, {
			BackgroundColor3 = theme.hover
		}, 0.15)

		playTween(buttonStroke, {
			Color = theme.borderActive
		}, 0.15)
	end)

	button.MouseLeave:Connect(function()
		playTween(button, {
			BackgroundColor3 = theme.surface
		}, 0.15)

		playTween(buttonStroke, {
			Color = theme.border
		}, 0.15)
	end)

	button.MouseButton1Down:Connect(function()
		playTween(button, {
			BackgroundColor3 = theme.active,
			TextColor3 = theme.background
		}, 0.08)
	end)

	button.MouseButton1Up:Connect(function()
		playTween(button, {
			BackgroundColor3 = theme.hover,
			TextColor3 = theme.text
		}, 0.1)
	end)

	button.MouseButton1Click:Connect(function()
		if callback then
			callback()
		end
	end)

	return button
end

local function createToggle(parent, text, defaultValue, callback)
	local enabled = defaultValue == true
	local card = createCard(parent, 44)

	create("TextLabel", {
		Size = UDim2.new(1, -72, 1, 0),
		Position = UDim2.fromOffset(11, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 11,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local toggle = create("TextButton", {
		Size = UDim2.fromOffset(34, 17),
		Position = UDim2.new(1, -46, 0.5, -8),
		BackgroundColor3 = enabled and theme.active or theme.elevated,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false
	}, card)

	addCorner(toggle, 9)
	addStroke(toggle, theme.borderActive, 1, 0.3)

	local knob = create("Frame", {
		Size = UDim2.fromOffset(11, 11),
		Position = enabled and UDim2.new(1, -14, 0.5, -5) or UDim2.fromOffset(3, 3),
		BackgroundColor3 = enabled and theme.background or theme.subtext,
		BorderSizePixel = 0
	}, toggle)

	addCorner(knob, 6)

	local function update(runCallback)
		playTween(toggle, {
			BackgroundColor3 = enabled and theme.active or theme.elevated
		}, 0.18)

		playTween(knob, {
			Position = enabled and UDim2.new(1, -14, 0.5, -5) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = enabled and theme.background or theme.subtext
		}, 0.18)

		if runCallback and callback then
			callback(enabled)
		end
	end

	toggle.MouseButton1Click:Connect(function()
		enabled = not enabled
		update(true)
	end)

	return {
		card = card,
		set = function(value, runCallback)
			enabled = value == true
			update(runCallback == true)
		end,
		get = function()
			return enabled
		end
	}
end

local function createSlider(parent, text, minimum, maximum, defaultValue, precision, callback)
	local decimals = math.max(0, precision or 0)
	local increment = 10 ^ -decimals
	local value = math.clamp(defaultValue or minimum, minimum, maximum)
	local dragging = false
	local activeTouch = nil
	local card = createCard(parent, 60)

	create("TextLabel", {
		Size = UDim2.new(1, -82, 0, 20),
		Position = UDim2.fromOffset(11, 6),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 11,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local valueLabel = create("TextLabel", {
		Size = UDim2.fromOffset(52, 20),
		Position = UDim2.new(1, -63, 0, 6),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = theme.subtext,
		TextSize = 10,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Right
	}, card)

	local track = create("Frame", {
		Size = UDim2.new(1, -22, 0, 3),
		Position = UDim2.fromOffset(11, 43),
		BackgroundColor3 = theme.border,
		BorderSizePixel = 0
	}, card)

	addCorner(track, 2)

	local fill = create("Frame", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = theme.active,
		BorderSizePixel = 0
	}, track)

	addCorner(fill, 2)

	local knob = create("Frame", {
		Size = UDim2.fromOffset(9, 9),
		Position = UDim2.new(0, -4, 0.5, -4),
		BackgroundColor3 = theme.active,
		BorderSizePixel = 0
	}, track)

	addCorner(knob, 5)

	local hitbox = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0.5, -10),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false
	}, track)

	local function formatValue(number)
		return string.format("%." .. tostring(decimals) .. "f", number)
	end

	local function getRatio(number)
		return math.clamp((number - minimum) / (maximum - minimum), 0, 1)
	end

	local function render(animated)
		local ratio = getRatio(value)
		local fillSize = UDim2.new(ratio, 0, 1, 0)
		local knobPosition = UDim2.new(ratio, -4, 0.5, -4)

		valueLabel.Text = formatValue(value) .. "x"

		if animated then
			playTween(fill, {Size = fillSize}, 0.12, Enum.EasingStyle.Quad)
			playTween(knob, {Position = knobPosition}, 0.12, Enum.EasingStyle.Quad)
		else
			fill.Size = fillSize
			knob.Position = knobPosition
		end
	end

	local function setValue(nextValue, runCallback, animated)
		nextValue = math.clamp(tonumber(nextValue) or minimum, minimum, maximum)
		nextValue = math.floor((nextValue / increment) + 0.5) * increment
		value = math.clamp(nextValue, minimum, maximum)
		render(animated == true)

		if runCallback and callback then
			callback(value)
		end
	end

	local function setFromX(positionX)
		local width = track.AbsoluteSize.X
		if width <= 0 then
			return
		end

		local ratio = math.clamp(
			(positionX - track.AbsolutePosition.X) / width,
			0,
			1
		)

		setValue(minimum + ((maximum - minimum) * ratio), true, false)
	end

	local function beginDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			activeTouch = nil
			setFromX(input.Position.X)
		elseif input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			activeTouch = input
			setFromX(input.Position.X)
		end

		if dragging then
			playTween(knob, {
				Size = UDim2.fromOffset(11, 11),
				Position = UDim2.new(getRatio(value), -5, 0.5, -5)
			}, 0.1)
		end
	end

	hitbox.InputBegan:Connect(beginDrag)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if activeTouch then
			if input == activeTouch then
				setFromX(input.Position.X)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseMovement then
			setFromX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not activeTouch then
			dragging = false
		elseif activeTouch and input == activeTouch then
			dragging = false
			activeTouch = nil
		end

		if not dragging then
			playTween(knob, {
				Size = UDim2.fromOffset(9, 9),
				Position = UDim2.new(getRatio(value), -4, 0.5, -4)
			}, 0.1)
		end
	end)

	render(false)

	return {
		set = function(nextValue, runCallback)
			setValue(nextValue, runCallback == true, true)
		end,
		get = function()
			return value
		end
	}
end

local function createStatus(parent)
	local card = createCard(parent, 62)

	local statusTitle = create("TextLabel", {
		Size = UDim2.new(1, -22, 0, 18),
		Position = UDim2.fromOffset(11, 8),
		BackgroundTransparency = 1,
		Text = "STATUS: DISABLED",
		TextColor3 = theme.text,
		TextSize = 12,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local statusText = create("TextLabel", {
		Size = UDim2.new(1, -22, 0, 28),
		Position = UDim2.fromOffset(11, 27),
		BackgroundTransparency = 1,
		Text = "Waiting for activation.",
		TextColor3 = theme.subtext,
		TextSize = 10,
		Font = Enum.Font.SourceSans,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top
	}, card)

	return function()
		statusTitle.Text = noRender.enabled and "STATUS: ENABLED" or "STATUS: DISABLED"

		if noRender.enabled then
			statusText.Text = string.format(
				"Processed %d instances. Removed %d effects.",
				noRender.processed,
				noRender.destroyed
			)
		else
			statusText.Text = "Future cleanup stopped. Removed instances cannot be restored."
		end
	end
end

local notifications = create("Frame", {
	Size = UDim2.fromOffset(230, 180),
	Position = UDim2.new(1, -242, 1, -192),
	BackgroundTransparency = 1
}, gui)

create("UIListLayout", {
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder
}, notifications)

local function notify(text)
	local notification = create("CanvasGroup", {
		Size = UDim2.fromOffset(215, 42),
		BackgroundColor3 = theme.surface,
		BorderSizePixel = 0,
		GroupTransparency = 1
	}, notifications)

	addCorner(notification, 6)
	addStroke(notification, theme.borderActive, 1, 0.3)

	create("Frame", {
		Size = UDim2.fromOffset(2, 18),
		Position = UDim2.fromOffset(9, 12),
		BackgroundColor3 = theme.active,
		BorderSizePixel = 0
	}, notification)

	create("TextLabel", {
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.fromOffset(20, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 10,
		Font = Enum.Font.SourceSans,
		TextXAlignment = Enum.TextXAlignment.Left
	}, notification)

	notification.Position = UDim2.fromOffset(15, 0)

	playTween(notification, {
		GroupTransparency = 0,
		Position = UDim2.fromOffset(0, 0)
	}, 0.5)

	task.delay(2.8, function()
		playTween(notification, {
			GroupTransparency = 1,
			Position = UDim2.fromOffset(15, 0)
		}, 0.5)

		task.wait(0.52)
		notification:Destroy()
	end)
end

local homePage = createPage("Home")
local controlsPage = createPage("Controls")
local settingsPage = createPage("Settings")

createTab("Home", "01   HOME", 1)
createTab("Controls", "02   CONTROLS", 2)
createTab("Settings", "03   SETTINGS", 3)

createSection(homePage, "Overview")
createInfo(homePage, "TESTE", "Compact no render, anti lag and display adjustment panel.")

createSection(homePage, "Status")
local updateStatus = createStatus(homePage)

createSection(homePage, "Actions")
createButton(homePage, "Run cleanup scan", function()
	if not noRender.enabled then
		notify("Enable No Render first")
		return
	end

	task.spawn(function()
		scanGame()
		updateStatus()
		notify("Cleanup scan completed")
	end)
end)

createButton(homePage, "Refresh status", function()
	updateStatus()
	notify("Status refreshed")
end)

createSection(controlsPage, "Main")

local mainToggle
mainToggle = createToggle(controlsPage, "No Render", false, function(value)
	setNoRenderEnabled(value)

	if value then
		notify("No Render enabled")
		task.delay(0.5, updateStatus)
	else
		notify("No Render disabled")
		updateStatus()
	end
end)

createSection(controlsPage, "Cleanup")

createToggle(controlsPage, "Visual effects", true, function(value)
	noRender.vfx = value
	refreshNoRender()
end)

createToggle(controlsPage, "Sounds and effects", true, function(value)
	noRender.sfx = value
	refreshNoRender()
end)

createToggle(controlsPage, "Lighting and post effects", true, function(value)
	noRender.lighting = value
	refreshNoRender()
end)

createToggle(controlsPage, "Part shadows and reflectance", true, function(value)
	noRender.parts = value
	refreshNoRender()
end)

createToggle(controlsPage, "Terrain decoration and water", true, function(value)
	noRender.terrain = value
	refreshNoRender()
end)

createSection(controlsPage, "Display")

local stretchToggle
local stretchSlider

stretchToggle = createToggle(controlsPage, "Screen stretch", false, function(value)
	setScreenStretchEnabled(value)
	notify(value and "Screen stretch enabled" or "Screen stretch disabled")
end)

stretchSlider = createSlider(
	controlsPage,
	"Stretch factor",
	screenStretch.minimum,
	screenStretch.maximum,
	screenStretch.default,
	2,
	function(value)
		setScreenStretchFactor(value)
	end
)

createButton(controlsPage, "Reset screen stretch", function()
	stretchSlider.set(screenStretch.default, true)
	notify("Screen stretch reset")
end)

createSection(settingsPage, "Interface")

createButton(settingsPage, "Reset interface position", function()
	playTween(root, {
		Position = UDim2.new(0.5, -260, 0.5, -167)
	}, 0.3)

	notify("Position reset")
end)

createButton(settingsPage, "Disable and close", function()
	setNoRenderEnabled(false)
	setScreenStretchEnabled(false)

	playTween(root, {
		GroupTransparency = 1,
		Size = UDim2.fromOffset(520, 20)
	}, 0.2)

	task.wait(0.22)
	gui:Destroy()
end)

createInfo(settingsPage, "KEYBIND", "Press RightShift to fade the interface in or out.")

local visible = true
local minimized = false
local normalSize = UDim2.fromOffset(520, 334)

local function setVisible(state)
	if visible == state then
		return
	end

	visible = state

	if state then
		root.Visible = true
		root.GroupTransparency = 1
		root.Position = UDim2.new(
			root.Position.X.Scale,
			root.Position.X.Offset,
			root.Position.Y.Scale,
			root.Position.Y.Offset + 8
		)

		playTween(root, {
			GroupTransparency = 0,
			Position = UDim2.new(
				root.Position.X.Scale,
				root.Position.X.Offset,
				root.Position.Y.Scale,
				root.Position.Y.Offset - 8
			)
		}, 0.22)
	else
		playTween(root, {
			GroupTransparency = 1,
			Position = UDim2.new(
				root.Position.X.Scale,
				root.Position.X.Offset,
				root.Position.Y.Scale,
				root.Position.Y.Offset + 8
			)
		}, 0.18)

		task.delay(0.18, function()
			if not visible then
				root.Visible = false
			end
		end)
	end
end

local function buttonHover(button, hovering)
	playTween(button, {
		BackgroundTransparency = hovering and 0 or 1,
		BackgroundColor3 = theme.hover,
		TextColor3 = hovering and theme.text or theme.subtext
	}, 0.14)
end

minimizeButton.MouseEnter:Connect(function()
	buttonHover(minimizeButton, true)
end)

minimizeButton.MouseLeave:Connect(function()
	buttonHover(minimizeButton, false)
end)

closeButton.MouseEnter:Connect(function()
	buttonHover(closeButton, true)
end)

closeButton.MouseLeave:Connect(function()
	buttonHover(closeButton, false)
end)

minimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized

	if minimized then
		sidebar.Visible = false
		content.Visible = false

		playTween(root, {
			Size = UDim2.fromOffset(520, 42)
		}, 0.25)

		minimizeButton.Text = "+"
	else
		playTween(root, {
			Size = normalSize
		}, 0.25)

		task.delay(0.14, function()
			sidebar.Visible = true
			content.Visible = true
		end)

		minimizeButton.Text = "-"
	end
end)

closeButton.MouseButton1Click:Connect(function()
	setNoRenderEnabled(false)
	setScreenStretchEnabled(false)

	playTween(root, {
		GroupTransparency = 1,
		Size = UDim2.fromOffset(520, 20)
	}, 0.2)

	task.wait(0.22)
	gui:Destroy()
end)

local dragging = false
local dragStart
local startPosition

topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = root.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		local delta = input.Position - dragStart

		root.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.RightShift then
		setVisible(not visible)
	end
end)

for name, page in pairs(pages) do
	page.group.Visible = name == "Home"
	page.group.GroupTransparency = name == "Home" and 0 or 1
	page.group.Position = UDim2.fromOffset(0, 0)
end

activePage = "Home"

for name in pairs(tabs) do
	setTabVisual(name, name == "Home")
end

updateStatus()

root.Size = UDim2.fromOffset(520, 30)
root.Position = UDim2.new(0.5, -260, 0.5, -152)

playTween(root, {
	GroupTransparency = 0,
	Size = normalSize,
	Position = UDim2.new(0.5, -260, 0.5, -167)
}, 0.35)

gui.Destroying:Connect(function()
	setScreenStretchEnabled(false)
end)

task.delay(0.4, function()
	notify("TESTE loaded")
end)
