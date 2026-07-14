-- diaboso hub (la ele)
-- 
-- 

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("NoirHub")
if oldGui then
	oldGui:Destroy()
end

local COLORS = {
	background = Color3.fromRGB(8, 8, 8),
	panel = Color3.fromRGB(13, 13, 13),
	panelLight = Color3.fromRGB(18, 18, 18),
	hover = Color3.fromRGB(24, 24, 24),

	white = Color3.fromRGB(235, 235, 235),
	text = Color3.fromRGB(210, 210, 210),
	muted = Color3.fromRGB(115, 115, 115),

	border = Color3.fromRGB(55, 55, 55),
	borderLight = Color3.fromRGB(75, 75, 75)
}

local function create(className, properties, parent)
	local object = Instance.new(className)

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	object.Parent = parent
	return object
end

local function corner(object, radius)
	return create("UICorner", {
		CornerRadius = UDim.new(0, radius or 6)
	}, object)
end

local function stroke(object, color, thickness, transparency)
	return create("UIStroke", {
		Color = color or COLORS.border,
		Thickness = thickness or 1,
		Transparency = transparency or 0
	}, object)
end

local function tween(object, properties, duration)
	local animation = TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.18,
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		),
		properties
	)

	animation:Play()
	return animation
end

local gui = create("ScreenGui", {
	Name = "NoirHub",
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local main = create("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(480, 310),
	Position = UDim2.new(0.5, -240, 0.5, -155),
	BackgroundColor3 = COLORS.background,
	BorderSizePixel = 0,
	ClipsDescendants = true
}, gui)

corner(main, 7)
stroke(main, COLORS.borderLight, 1, 0.25)

local topbar = create("Frame", {
	Name = "Topbar",
	Size = UDim2.new(1, 0, 0, 38),
	BackgroundColor3 = COLORS.panel,
	BorderSizePixel = 0
}, main)

local topLine = create("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = COLORS.border,
	BorderSizePixel = 0
}, topbar)

local title = create("TextLabel", {
	Size = UDim2.fromOffset(170, 20),
	Position = UDim2.fromOffset(14, 5),
	BackgroundTransparency = 1,
	Text = "NOIR / HUB",
	TextColor3 = COLORS.white,
	TextSize = 12,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, topbar)

local subtitle = create("TextLabel", {
	Size = UDim2.fromOffset(170, 13),
	Position = UDim2.fromOffset(14, 20),
	BackgroundTransparency = 1,
	Text = "minimal interface",
	TextColor3 = COLORS.muted,
	TextSize = 9,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, topbar)

local minimize = create("TextButton", {
	Size = UDim2.fromOffset(28, 26),
	Position = UDim2.new(1, -64, 0, 6),
	BackgroundTransparency = 1,
	Text = "—",
	TextColor3 = COLORS.muted,
	TextSize = 13,
	Font = Enum.Font.Gotham,
	AutoButtonColor = false
}, topbar)

local close = create("TextButton", {
	Size = UDim2.fromOffset(28, 26),
	Position = UDim2.new(1, -34, 0, 6),
	BackgroundTransparency = 1,
	Text = "×",
	TextColor3 = COLORS.muted,
	TextSize = 15,
	Font = Enum.Font.Gotham,
	AutoButtonColor = false
}, topbar)

local sidebar = create("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, 120, 1, -38),
	Position = UDim2.fromOffset(0, 38),
	BackgroundColor3 = COLORS.panel,
	BorderSizePixel = 0
}, main)

local sideLine = create("Frame", {
	Size = UDim2.new(0, 1, 1, 0),
	Position = UDim2.new(1, -1, 0, 0),
	BackgroundColor3 = COLORS.border,
	BorderSizePixel = 0
}, sidebar)

local sidebarLabel = create("TextLabel", {
	Size = UDim2.new(1, -20, 0, 20),
	Position = UDim2.fromOffset(12, 11),
	BackgroundTransparency = 1,
	Text = "NAVIGATION",
	TextColor3 = COLORS.muted,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left
}, sidebar)

local navigation = create("Frame", {
	Size = UDim2.new(1, -16, 0, 150),
	Position = UDim2.fromOffset(8, 36),
	BackgroundTransparency = 1
}, sidebar)

create("UIListLayout", {
	Padding = UDim.new(0, 5),
	SortOrder = Enum.SortOrder.LayoutOrder
}, navigation)

local footer = create("TextLabel", {
	Size = UDim2.new(1, -20, 0, 30),
	Position = UDim2.new(0, 12, 1, -40),
	BackgroundTransparency = 1,
	Text = "RIGHT SHIFT\nshow / hide",
	TextColor3 = COLORS.muted,
	TextSize = 8,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Center
}, sidebar)

local content = create("Frame", {
	Name = "Content",
	Size = UDim2.new(1, -120, 1, -38),
	Position = UDim2.fromOffset(120, 38),
	BackgroundColor3 = COLORS.background,
	BorderSizePixel = 0,
	ClipsDescendants = true
}, main)

local pages = {}
local tabButtons = {}
local currentPage

local function makePage(name)
	local page = create("ScrollingFrame", {
		Name = name,
		Size = UDim2.new(1, -24, 1, -20),
		Position = UDim2.fromOffset(12, 10),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = COLORS.borderLight,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false
	}, content)

	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	}, page)

	create("UIPadding", {
		PaddingBottom = UDim.new(0, 6)
	}, page)

	pages[name] = page
	return page
end

local function showPage(name)
	for pageName, page in pairs(pages) do
		page.Visible = pageName == name
	end

	for buttonName, button in pairs(tabButtons) do
		local active = buttonName == name

		tween(button, {
			BackgroundColor3 = active and COLORS.white or COLORS.panel
		})

		button.TextColor3 = active and COLORS.background or COLORS.muted
	end

	currentPage = name
end

local function makeTab(name, text, order)
	local button = create("TextButton", {
		Name = name,
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = COLORS.panel,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = COLORS.muted,
		TextSize = 10,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		LayoutOrder = order
	}, navigation)

	create("UIPadding", {
		PaddingLeft = UDim.new(0, 10)
	}, button)

	corner(button, 5)
	stroke(button, COLORS.border, 1, 0.45)

	button.MouseEnter:Connect(function()
		if currentPage ~= name then
			tween(button, {
				BackgroundColor3 = COLORS.hover
			})
		end
	end)

	button.MouseLeave:Connect(function()
		if currentPage ~= name then
			tween(button, {
				BackgroundColor3 = COLORS.panel
			})
		end
	end)

	button.MouseButton1Click:Connect(function()
		showPage(name)
	end)

	tabButtons[name] = button
	return button
end

local function makeSection(page, titleText)
	return create("TextLabel", {
		Size = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = string.upper(titleText),
		TextColor3 = COLORS.muted,
		TextSize = 8,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, page)
end

local function makeCard(page, height)
	local card = create("Frame", {
		Size = UDim2.new(1, -2, 0, height or 42),
		BackgroundColor3 = COLORS.panel,
		BorderSizePixel = 0
	}, page)

	corner(card, 5)
	stroke(card, COLORS.border, 1, 0.4)

	return card
end

local function makeInfo(page, titleText, description)
	local card = makeCard(page, 58)

	create("TextLabel", {
		Size = UDim2.new(1, -20, 0, 18),
		Position = UDim2.fromOffset(10, 8),
		BackgroundTransparency = 1,
		Text = titleText,
		TextColor3 = COLORS.text,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	create("TextLabel", {
		Size = UDim2.new(1, -20, 0, 26),
		Position = UDim2.fromOffset(10, 26),
		BackgroundTransparency = 1,
		Text = description,
		TextColor3 = COLORS.muted,
		TextSize = 9,
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top
	}, card)

	return card
end

local function makeButton(page, text, callback)
	local button = create("TextButton", {
		Size = UDim2.new(1, -2, 0, 38),
		BackgroundColor3 = COLORS.panel,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = COLORS.text,
		TextSize = 10,
		Font = Enum.Font.Gotham,
		AutoButtonColor = false
	}, page)

	corner(button, 5)
	stroke(button, COLORS.border, 1, 0.4)

	button.MouseEnter:Connect(function()
		tween(button, {
			BackgroundColor3 = COLORS.hover
		})
	end)

	button.MouseLeave:Connect(function()
		tween(button, {
			BackgroundColor3 = COLORS.panel
		})
	end)

	button.MouseButton1Click:Connect(function()
		tween(button, {
			BackgroundColor3 = COLORS.white,
			TextColor3 = COLORS.background
		}, 0.08)

		task.delay(0.1, function()
			tween(button, {
				BackgroundColor3 = COLORS.panel,
				TextColor3 = COLORS.text
			})
		end)

		if callback then
			callback()
		end
	end)

	return button
end

local function makeToggle(page, text, defaultValue, callback)
	local enabled = defaultValue or false
	local card = makeCard(page, 42)

	local label = create("TextLabel", {
		Size = UDim2.new(1, -75, 1, 0),
		Position = UDim2.fromOffset(11, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLORS.text,
		TextSize = 10,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local toggleButton = create("TextButton", {
		Size = UDim2.fromOffset(34, 16),
		Position = UDim2.new(1, -46, 0.5, -8),
		BackgroundColor3 = enabled and COLORS.white or COLORS.panelLight,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false
	}, card)

	corner(toggleButton, 8)
	stroke(toggleButton, COLORS.borderLight, 1, 0.2)

	local circle = create("Frame", {
		Size = UDim2.fromOffset(10, 10),
		Position = enabled
			and UDim2.new(1, -13, 0.5, -5)
			or UDim2.fromOffset(3, 3),
		BackgroundColor3 = enabled and COLORS.background or COLORS.muted,
		BorderSizePixel = 0
	}, toggleButton)

	corner(circle, 5)

	local function update()
		tween(toggleButton, {
			BackgroundColor3 = enabled and COLORS.white or COLORS.panelLight
		})

		tween(circle, {
			Position = enabled
				and UDim2.new(1, -13, 0.5, -5)
				or UDim2.fromOffset(3, 3),

			BackgroundColor3 = enabled
				and COLORS.background
				or COLORS.muted
		})

		if callback then
			callback(enabled)
		end
	end

	toggleButton.MouseButton1Click:Connect(function()
		enabled = not enabled
		update()
	end)

	card.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			enabled = not enabled
			update()
		end
	end)

	return card
end

local function makeSlider(page, text, minimum, maximum, defaultValue, callback)
	local value = math.clamp(defaultValue or minimum, minimum, maximum)
	local dragging = false

	local card = makeCard(page, 58)

	local label = create("TextLabel", {
		Size = UDim2.new(1, -75, 0, 25),
		Position = UDim2.fromOffset(11, 3),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLORS.text,
		TextSize = 10,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, card)

	local valueLabel = create("TextLabel", {
		Size = UDim2.fromOffset(45, 25),
		Position = UDim2.new(1, -56, 0, 3),
		BackgroundTransparency = 1,
		Text = tostring(value),
		TextColor3 = COLORS.muted,
		TextSize = 9,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Right
	}, card)

	local sliderBackground = create("Frame", {
		Size = UDim2.new(1, -22, 0, 3),
		Position = UDim2.fromOffset(11, 41),
		BackgroundColor3 = COLORS.border,
		BorderSizePixel = 0
	}, card)

	corner(sliderBackground, 2)

	local fill = create("Frame", {
		Size = UDim2.new(
			(value - minimum) / (maximum - minimum),
			0,
			1,
			0
		),
		BackgroundColor3 = COLORS.white,
		BorderSizePixel = 0
	}, sliderBackground)

	corner(fill, 2)

	local handle = create("Frame", {
		Size = UDim2.fromOffset(8, 8),
		Position = UDim2.new(
			(value - minimum) / (maximum - minimum),
			-4,
			0.5,
			-4
		),
		BackgroundColor3 = COLORS.white,
		BorderSizePixel = 0
	}, sliderBackground)

	corner(handle, 4)

	local function setValue(mouseX)
		local relative = math.clamp(
			(mouseX - sliderBackground.AbsolutePosition.X)
				/ sliderBackground.AbsoluteSize.X,
			0,
			1
		)

		value = math.floor(
			minimum + ((maximum - minimum) * relative)
		)

		fill.Size = UDim2.new(relative, 0, 1, 0)
		handle.Position = UDim2.new(relative, -4, 0.5, -4)
		valueLabel.Text = tostring(value)

		if callback then
			callback(value)
		end
	end

	sliderBackground.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			setValue(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then
			setValue(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = false
		end
	end)

	return card
end

local function notify(text)
	local notification = create("Frame", {
		Size = UDim2.fromOffset(210, 38),
		Position = UDim2.new(1, 15, 1, -50),
		BackgroundColor3 = COLORS.panel,
		BorderSizePixel = 0
	}, main)

	corner(notification, 5)
	stroke(notification, COLORS.borderLight, 1, 0.2)

	create("TextLabel", {
		Size = UDim2.new(1, -20, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLORS.text,
		TextSize = 9,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left
	}, notification)

	tween(notification, {
		Position = UDim2.new(1, -222, 1, -50)
	}, 0.3)

	task.delay(2.2, function()
		tween(notification, {
			Position = UDim2.new(1, 15, 1, -50),
			BackgroundTransparency = 1
		}, 0.25)

		task.wait(0.3)

		if notification then
			notification:Destroy()
		end
	end)
end

local homePage = makePage("Home")
local controlsPage = makePage("Controls")
local settingsPage = makePage("Settings")

makeTab("Home", "01   HOME", 1)
makeTab("Controls", "02   CONTROLS", 2)
makeTab("Settings", "03   SETTINGS", 3)

makeSection(homePage, "Overview")

makeInfo(
	homePage,
	"NOIR HUB",
	"Painel compacto com interface minimalista, animações suaves e controles básicos."
)

makeSection(homePage, "Actions")

makeButton(homePage, "Testar notificação", function()
	notify("notificação executada")
end)

makeButton(homePage, "Executar ação de teste", function()
	print("[NOIR HUB] ação executada")
	notify("ação executada")
end)

makeSection(controlsPage, "Main controls")

makeToggle(controlsPage, "Sistema principal", false, function(value)
	print("Sistema principal:", value)
end)

makeToggle(controlsPage, "Modo alternativo", false, function(value)
	print("Modo alternativo:", value)
end)

makeToggle(controlsPage, "Opção visual", true, function(value)
	print("Opção visual:", value)
end)

makeSection(controlsPage, "Values")

makeSlider(controlsPage, "Intensidade", 0, 100, 50, function(value)
	print("Intensidade:", value)
end)

makeSlider(controlsPage, "Velocidade", 1, 25, 10, function(value)
	print("Velocidade:", value)
end)

makeSection(settingsPage, "Interface")

makeToggle(settingsPage, "Animações", true, function(value)
	print("Animações:", value)
end)

makeToggle(settingsPage, "Notificações", true, function(value)
	print("Notificações:", value)
end)

makeButton(settingsPage, "Recarregar interface", function()
	notify("interface recarregada")
end)

makeSection(settingsPage, "Information")

makeInfo(
	settingsPage,
	"Atalho de teclado",
	"Pressione RightShift para esconder ou mostrar a interface."
)

showPage("Home")

close.MouseEnter:Connect(function()
	tween(close, {
		TextColor3 = COLORS.white,
		BackgroundTransparency = 0,
		BackgroundColor3 = COLORS.hover
	})
end)

close.MouseLeave:Connect(function()
	tween(close, {
		TextColor3 = COLORS.muted,
		BackgroundTransparency = 1
	})
end)

minimize.MouseEnter:Connect(function()
	tween(minimize, {
		TextColor3 = COLORS.white,
		BackgroundTransparency = 0,
		BackgroundColor3 = COLORS.hover
	})
end)

minimize.MouseLeave:Connect(function()
	tween(minimize, {
		TextColor3 = COLORS.muted,
		BackgroundTransparency = 1
	})
end)

close.MouseButton1Click:Connect(function()
	tween(main, {
		Size = UDim2.fromOffset(480, 0),
		BackgroundTransparency = 1
	}, 0.25)

	task.wait(0.27)
	gui:Destroy()
end)

local minimized = false
local normalSize = UDim2.fromOffset(480, 310)

minimize.MouseButton1Click:Connect(function()
	minimized = not minimized

	sidebar.Visible = not minimized
	content.Visible = not minimized

	tween(main, {
		Size = minimized
			and UDim2.fromOffset(480, 38)
			or normalSize
	}, 0.25)

	minimize.Text = minimized and "+" or "—"
end)

local dragging = false
local dragStart
local startPosition

topbar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then
		local delta = input.Position - dragStart

		main.Position = UDim2.new(
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
		gui.Enabled = not gui.Enabled
	end
end)

local finalSize = main.Size
main.Size = UDim2.fromOffset(480, 0)

tween(main, {
	Size = finalSize
}, 0.35)

task.delay(0.4, function()
	notify("NOIR HUB carregada")
end)