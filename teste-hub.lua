local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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

local function new(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	object.Parent = parent
	return object
end

local function tween(object, properties, duration, style, direction)
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
	return new("UICorner", {
		CornerRadius = UDim.new(0, radius or 6)
	}, object)
end

local function addStroke(object, color, thickness, transparency)
	return new("UIStroke", {
		Color = color or theme.border,
		Thickness = thickness or 1,
		Transparency = transparency or 0
	}, object)
end

local gui = new("ScreenGui", {
	Name = "TesteHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local root = new("CanvasGroup", {
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

local scale = new("UIScale", {
	Scale = 1
}, root)

local function updateScale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end

	local viewport = camera.ViewportSize
	local target = math.min(viewport.X / 620, viewport.Y / 430, 1)
	scale.Scale = math.clamp(target, 0.72, 1)
end

updateScale()

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local topbar = new("Frame", {
	Name = "Topbar",
	Size = UDim2.new(1, 0, 0, 42),
	BackgroundColor3 = theme.surface,
	BorderSizePixel = 0
}, root)

new("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = theme.border,
	BorderSizePixel = 0
}, topbar)

local brand = new("TextLabel", {
	Size = UDim2.fromOffset(210, 20),
	Position = UDim2.fromOffset(15, 5),
	BackgroundTransparency = 1,
	Text = "TESTE",
	TextColor3 = theme.text,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, topbar)

local version = new("TextLabel", {
	Size = UDim2.fromOffset(210, 12),
	Position = UDim2.fromOffset(15, 23),
	BackgroundTransparency = 1,
	Text = "interface preview",
	TextColor3 = theme.subtext,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, topbar)

local minimizeButton = new("TextButton", {
	Size = UDim2.fromOffset(29, 28),
	Position = UDim2.new(1, -68, 0, 7),
	BackgroundColor3 = theme.surface,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Text = "—",
	TextColor3 = theme.subtext,
	TextSize = 13,
	Font = Enum.Font.Gotham,
	AutoButtonColor = false
}, topbar)

addCorner(minimizeButton, 5)

local closeButton = new("TextButton", {
	Size = UDim2.fromOffset(29, 28),
	Position = UDim2.new(1, -35, 0, 7),
	BackgroundColor3 = theme.surface,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Text = "×",
	TextColor3 = theme.subtext,
	TextSize = 15,
	Font = Enum.Font.Gotham,
	AutoButtonColor = false
}, topbar)

addCorner(closeButton, 5)

local sidebar = new("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 132, 1, -42),
	Position = UDim2.fromOffset(0, 42),
	BackgroundColor3 = theme.surface,
	BorderSizePixel = 0
}, root)

new("Frame", {
	Size = UDim2.new(0, 1, 1, 0),
	Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = theme.border,
	BorderSizePixel = 0
}, sidebar)

local navigationLabel = new("TextLabel", {
	Size = UDim2.new(1, -24, 0, 18),
	Position = UDim2.fromOffset(12, 12),
	BackgroundTransparency = 1,
	Text = "NAVIGATION",
	TextColor3 = theme.dim,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, sidebar)

local navigation = new("Frame", {
	Size = UDim2.new(1, -16, 0, 150),
	Position = UDim2.fromOffset(8, 38),
	BackgroundTransparency = 1
}, sidebar)

new("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder
}, navigation)

local shortcut = new("Frame", {
	Size = UDim2.new(1, -16, 0, 42),
	Position = UDim2.new(0, 8, 1, -50),
	BackgroundColor3 = theme.elevated,
	BorderSizePixel = 0
}, sidebar)

addCorner(shortcut, 5)
addStroke(shortcut, theme.border, 1, 0.3)

new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 16),
	Position = UDim2.fromOffset(8, 5),
	BackgroundTransparency = 1,
	Text = "RIGHT SHIFT",
	TextColor3 = theme.text,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, shortcut)

new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 13),
	Position = UDim2.fromOffset(8, 21),
	BackgroundTransparency = 1,
	Text = "show / hide",
	TextColor3 = theme.subtext,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, shortcut)

local content = new("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -132, 1, -42),
	Position = UDim2.fromOffset(132, 42),
	BackgroundColor3 = theme.background,
	BorderSizePixel = 0,
	ClipsDescendants = true
}, root)

local pageContainer = new("Frame", {
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
	local page = new("CanvasGroup", {
		Name = name,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromOffset(14, 0),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false
	}, pageContainer)

	local scroll = new("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = theme.borderActive,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y
	}, page)

	new("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, scroll)

	new("UIPadding", {
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

	tween(tab.button, {
		BackgroundColor3 = selected and theme.active or theme.surface
	}, 0.2)

	tween(tab.text, {
		TextColor3 = selected and theme.background or theme.subtext
	}, 0.2)

	tween(tab.indicator, {
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
		tween(outgoing, {
			GroupTransparency = 1,
			Position = UDim2.fromOffset(-12, 0)
		}, 0.16)

		task.wait(0.12)
		outgoing.Visible = false
	end

	incoming.Visible = true
	incoming.GroupTransparency = 1
	incoming.Position = UDim2.fromOffset(14, 0)

	tween(incoming, {
		GroupTransparency = 0,
		Position = UDim2.fromOffset(0, 0)
	}, 0.22)

	activePage = name
	task.wait(0.22)
	switching = false
end

local function createTab(name, label, index)
	local button = new("TextButton", {
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

	local indicator = new("Frame", {
		Size = UDim2.fromOffset(2, 4),
		Position = UDim2.new(0, 7, 0.5, -2),
		BackgroundColor3 = theme.background,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}, button)

	addCorner(indicator, 1)

	local text = new("TextLabel", {
		Size = UDim2.new(1, -26, 1, 0),
		Position = UDim2.fromOffset(20, 0),
		BackgroundTransparency = 1,
		Text = label,
		TextColor3 = theme.subtext,
		TextSize = 9,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, button)

	tabs[name] = {
		button = button,
		text = text,
		indicator = indicator
	}

	button.MouseEnter:Connect(function()
		if activePage ~= name then
			tween(button, {
				BackgroundColor3 = theme.hover
			}, 0.15)

			tween(text, {
				TextColor3 = theme.text
			}, 0.15)
		end
	end)

	button.MouseLeave:Connect(function()
		if activePage ~= name then
			tween(button, {
				BackgroundColor3 = theme.surface
			}, 0.15)

			tween(text, {
				TextColor3 = theme.subtext
			}, 0.15)
		end
	end)

	button.MouseButton1Click:Connect(function()
		switchPage(name)
	end)
end

local function createSection(parent, text)
	return new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = string.upper(text),
		TextColor3 = theme.dim,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, parent)
end

local function createCard(parent, height)
	local card = new("Frame", {
		Size = UDim2.new(1, -2, 0, height or 44),
		BackgroundColor3 = theme.surface,
		BorderSizePixel = 0
	}, parent)

	addCorner(card, 6)
	local cardStroke = addStroke(card, theme.border, 1, 0.3)

	card.MouseEnter:Connect(function()
		tween(card, {
			BackgroundColor3 = theme.elevated
		}, 0.16)

		tween(cardStroke, {
			Color = theme.borderActive
		}, 0.16)
	end)

	card.MouseLeave:Connect(function()
		tween(card, {
			BackgroundColor3 = theme.surface
		}, 0.16)

		tween(cardStroke, {
			Color = theme.border
		}, 0.16)
	end)

	return card
end

local function createInfo(parent, titleText, description)
	local card = createCard(parent, 62)

	new("TextLabel", {
		Size = UDim2.new(1, -22, 0, 18),
		Position = UDim2.fromOffset(11, 8),
		BackgroundTransparency = 1,
		Text = titleText,
		TextColor3 = theme.text,
		TextSize = 10,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	new("TextLabel", {
		Size = UDim2.new(1, -22, 0, 28),
		Position = UDim2.fromOffset(11, 27),
		BackgroundTransparency = 1,
		Text = description,
		TextColor3 = theme.subtext,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top
	}, card)

	return card
end

local function createButton(parent, text, callback)
	local button = new("TextButton", {
		Size = UDim2.new(1, -2, 0, 39),
		BackgroundColor3 = theme.surface,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 9,
		Font = Enum.Font.Gotham,
		AutoButtonColor = false
	}, parent)

	addCorner(button, 6)
	local buttonStroke = addStroke(button, theme.border, 1, 0.3)

	button.MouseEnter:Connect(function()
		tween(button, {
			BackgroundColor3 = theme.hover
		}, 0.15)

		tween(buttonStroke, {
			Color = theme.borderActive
		}, 0.15)
	end)

	button.MouseLeave:Connect(function()
		tween(button, {
			BackgroundColor3 = theme.surface
		}, 0.15)

		tween(buttonStroke, {
			Color = theme.border
		}, 0.15)
	end)

	button.MouseButton1Down:Connect(function()
		tween(button, {
			BackgroundColor3 = theme.active,
			TextColor3 = theme.background
		}, 0.08)
	end)

	button.MouseButton1Up:Connect(function()
		tween(button, {
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

	new("TextLabel", {
		Size = UDim2.new(1, -72, 1, 0),
		Position = UDim2.fromOffset(11, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 9,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local toggle = new("TextButton", {
		Size = UDim2.fromOffset(34, 17),
		Position = UDim2.new(1, -46, 0.5, -8),
		BackgroundColor3 = enabled and theme.active or theme.elevated,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false
	}, card)

	addCorner(toggle, 9)
	addStroke(toggle, theme.borderActive, 1, 0.3)

	local knob = new("Frame", {
		Size = UDim2.fromOffset(11, 11),
		Position = enabled and UDim2.new(1, -14, 0.5, -5) or UDim2.fromOffset(3, 3),
		BackgroundColor3 = enabled and theme.background or theme.subtext,
		BorderSizePixel = 0
	}, toggle)

	addCorner(knob, 6)

	local function update()
		tween(toggle, {
			BackgroundColor3 = enabled and theme.active or theme.elevated
		}, 0.18)

		tween(knob, {
			Position = enabled and UDim2.new(1, -14, 0.5, -5) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = enabled and theme.background or theme.subtext
		}, 0.18)

		if callback then
			callback(enabled)
		end
	end

	toggle.MouseButton1Click:Connect(function()
		enabled = not enabled
		update()
	end)

	return card
end

local function createInput(parent, titleText, placeholder, callback)
	local card = createCard(parent, 62)

	new("TextLabel", {
		Size = UDim2.new(1, -22, 0, 16),
		Position = UDim2.fromOffset(11, 7),
		BackgroundTransparency = 1,
		Text = titleText,
		TextColor3 = theme.subtext,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local inputFrame = new("Frame", {
		Size = UDim2.new(1, -22, 0, 27),
		Position = UDim2.fromOffset(11, 27),
		BackgroundColor3 = theme.background,
		BorderSizePixel = 0
	}, card)

	addCorner(inputFrame, 4)
	local inputStroke = addStroke(inputFrame, theme.border, 1, 0.2)

	local input = new("TextBox", {
		Size = UDim2.new(1, -18, 1, 0),
		Position = UDim2.fromOffset(9, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = placeholder,
		PlaceholderColor3 = theme.dim,
		TextColor3 = theme.text,
		TextSize = 9,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false
	}, inputFrame)

	input.Focused:Connect(function()
		tween(inputFrame, {
			BackgroundColor3 = theme.elevated
		}, 0.16)

		tween(inputStroke, {
			Color = theme.active,
			Transparency = 0.35
		}, 0.16)
	end)

	input.FocusLost:Connect(function(enterPressed)
		tween(inputFrame, {
			BackgroundColor3 = theme.background
		}, 0.16)

		tween(inputStroke, {
			Color = theme.border,
			Transparency = 0.2
		}, 0.16)

		if callback then
			callback(input.Text, enterPressed)
		end
	end)

	return input
end

local function createSlider(parent, text, minimum, maximum, defaultValue, callback)
	local value = math.clamp(defaultValue or minimum, minimum, maximum)
	local dragging = false
	local card = createCard(parent, 60)

	new("TextLabel", {
		Size = UDim2.new(1, -76, 0, 20),
		Position = UDim2.fromOffset(11, 6),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 9,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local valueLabel = new("TextLabel", {
		Size = UDim2.fromOffset(46, 20),
		Position = UDim2.new(1, -57, 0, 6),
		BackgroundTransparency = 1,
		Text = tostring(value),
		TextColor3 = theme.subtext,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Right
	}, card)

	local track = new("Frame", {
		Size = UDim2.new(1, -22, 0, 3),
		Position = UDim2.fromOffset(11, 43),
		BackgroundColor3 = theme.border,
		BorderSizePixel = 0
	}, card)

	addCorner(track, 2)

	local ratio = (value - minimum) / (maximum - minimum)

	local fill = new("Frame", {
		Size = UDim2.new(ratio, 0, 1, 0),
		BackgroundColor3 = theme.active,
		BorderSizePixel = 0
	}, track)

	addCorner(fill, 2)

	local knob = new("Frame", {
		Size = UDim2.fromOffset(9, 9),
		Position = UDim2.new(ratio, -4, 0.5, -4),
		BackgroundColor3 = theme.active,
		BorderSizePixel = 0
	}, track)

	addCorner(knob, 5)

	local hitbox = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 18),
		Position = UDim2.new(0, 0, 0.5, -9),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false
	}, track)

	local function update(positionX)
		local currentRatio = math.clamp(
			(positionX - track.AbsolutePosition.X) / track.AbsoluteSize.X,
			0,
			1
		)

		value = math.floor(minimum + ((maximum - minimum) * currentRatio))

		tween(fill, {
			Size = UDim2.new(currentRatio, 0, 1, 0)
		}, 0.07, Enum.EasingStyle.Linear)

		tween(knob, {
			Position = UDim2.new(currentRatio, -4, 0.5, -4)
		}, 0.07, Enum.EasingStyle.Linear)

		valueLabel.Text = tostring(value)

		if callback then
			callback(value)
		end
	end

	hitbox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input.Position.X)

			tween(knob, {
				Size = UDim2.fromOffset(11, 11),
				Position = UDim2.new(knob.Position.X.Scale, -5, 0.5, -5)
			}, 0.1)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			update(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false

			tween(knob, {
				Size = UDim2.fromOffset(9, 9),
				Position = UDim2.new(knob.Position.X.Scale, -4, 0.5, -4)
			}, 0.1)
		end
	end)

	return card
end

local notifications = new("Frame", {
	Size = UDim2.fromOffset(230, 180),
	Position = UDim2.new(1, -242, 1, -192),
	BackgroundTransparency = 1
}, gui)

new("UIListLayout", {
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	Padding = UDim.new(0, 7),
	SortOrder = Enum.SortOrder.LayoutOrder
}, notifications)

local function notify(text)
	local notification = new("CanvasGroup", {
		Size = UDim2.fromOffset(215, 42),
		BackgroundColor3 = theme.surface,
		BorderSizePixel = 0,
		GroupTransparency = 1
	}, notifications)

	addCorner(notification, 6)
	addStroke(notification, theme.borderActive, 1, 0.3)

	new("Frame", {
		Size = UDim2.fromOffset(2, 18),
		Position = UDim2.fromOffset(9, 12),
		BackgroundColor3 = theme.active,
		BorderSizePixel = 0
	}, notification)

	new("TextLabel", {
		Size = UDim2.new(1, -28, 1, 0),
		Position = UDim2.fromOffset(20, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, notification)

	notification.Position = UDim2.fromOffset(15, 0)

	tween(notification, {
		GroupTransparency = 0,
		Position = UDim2.fromOffset(0, 0)
	}, 0.22)

	task.delay(2.2, function()
		tween(notification, {
			GroupTransparency = 1,
			Position = UDim2.fromOffset(15, 0)
		}, 0.2)

		task.wait(0.22)
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

createInfo(
	homePage,
	"TESTE",
	"Compact monochrome interface built for layout, transition and component testing."
)

createSection(homePage, "Input")

createInput(homePage, "TEXT INPUT", "Type something...", function(text, enterPressed)
	if enterPressed and text ~= "" then
		notify(text)
	end
end)

createSection(homePage, "Actions")

createButton(homePage, "Show notification", function()
	notify("Interface test completed")
end)

createButton(homePage, "Run test action", function()
	notify("Test action executed")
end)

createSection(controlsPage, "Toggles")

createToggle(controlsPage, "Primary option", false, function()
end)

createToggle(controlsPage, "Secondary option", true, function()
end)

createToggle(controlsPage, "Visual option", false, function()
end)

createSection(controlsPage, "Values")

createSlider(controlsPage, "Intensity", 0, 100, 50, function()
end)

createSlider(controlsPage, "Speed", 1, 25, 10, function()
end)

createSection(settingsPage, "Interface")

createToggle(settingsPage, "Animations", true, function()
end)

createToggle(settingsPage, "Notifications", true, function()
end)

createInput(settingsPage, "CUSTOM LABEL", "Enter a label...", function(text, enterPressed)
	if enterPressed and text ~= "" then
		brand.Text = string.upper(text)
		notify("Title updated")
	end
end)

createSection(settingsPage, "Session")

createButton(settingsPage, "Reset interface position", function()
	tween(root, {
		Position = UDim2.new(0.5, -260, 0.5, -167)
	}, 0.3)

	notify("Position reset")
end)

createInfo(
	settingsPage,
	"KEYBIND",
	"Press RightShift to fade the interface in or out."
)

local visible = true
local minimized = false
local normalSize = UDim2.fromOffset(520, 334)

local function setVisible(state)
	if visible == state then
		return
	end

	visible = state

	if state then
		gui.Enabled = true
		root.Visible = true
		root.GroupTransparency = 1
		root.Position = UDim2.new(
			root.Position.X.Scale,
			root.Position.X.Offset,
			root.Position.Y.Scale,
			root.Position.Y.Offset + 8
		)

		tween(root, {
			GroupTransparency = 0,
			Position = UDim2.new(
				root.Position.X.Scale,
				root.Position.X.Offset,
				root.Position.Y.Scale,
				root.Position.Y.Offset - 8
			)
		}, 0.22)
	else
		tween(root, {
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
	tween(button, {
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

		tween(root, {
			Size = UDim2.fromOffset(520, 42)
		}, 0.25)

		minimizeButton.Text = "+"
	else
		tween(root, {
			Size = normalSize
		}, 0.25)

		task.delay(0.14, function()
			sidebar.Visible = true
			content.Visible = true
		end)

		minimizeButton.Text = "—"
	end
end)

closeButton.MouseButton1Click:Connect(function()
	tween(root, {
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

root.Size = UDim2.fromOffset(520, 30)
root.Position = UDim2.new(0.5, -260, 0.5, -152)

tween(root, {
	GroupTransparency = 0,
	Size = normalSize,
	Position = UDim2.new(0.5, -260, 0.5, -167)
}, 0.35)

task.delay(0.4, function()
	notify("TESTE loaded")
end)
