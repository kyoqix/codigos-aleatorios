local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("TesteHub")
if existing then existing:Destroy() end

local theme = {
	background = Color3.fromRGB(10, 10, 12),
	surface = Color3.fromRGB(18, 18, 22),
	elevated = Color3.fromRGB(24, 24, 30),
	hover = Color3.fromRGB(32, 32, 40),
	primary = Color3.fromRGB(108, 99, 255),
	primaryDark = Color3.fromRGB(80, 70, 220),
	primaryLight = Color3.fromRGB(140, 130, 255),
	text = Color3.fromRGB(235, 235, 240),
	subtext = Color3.fromRGB(160, 160, 175),
	dim = Color3.fromRGB(100, 100, 120),
	border = Color3.fromRGB(50, 50, 65),
	borderActive = Color3.fromRGB(108, 99, 255),
	success = Color3.fromRGB(80, 220, 160),
}

local function new(c, p, parent) local o=Instance.new(c) for k,v in pairs(p or {}) do o[k]=v end o.Parent=parent return o end
local function tween(o, p, d, s, dir) return TweenService:Create(o, TweenInfo.new(d or 0.2, s or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p):Play() end
local function corner(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end
local function stroke(o, c, t, tr) return new("UIStroke", {Color = c or theme.border, Thickness = t or 1, Transparency = tr or 0}, o) end

local gui = new("ScreenGui", {Name = "TesteHub", ResetOnSpawn = false, IgnoreGuiInset = false}, playerGui)

local root = new("CanvasGroup", {Name = "Root", Size = UDim2.fromOffset(540, 360), Position = UDim2.new(0.5, -270, 0.5, -180), BackgroundColor3 = theme.background, BackgroundTransparency = 0.15, GroupTransparency = 1, ClipsDescendants = true}, gui)
corner(root, 12)
stroke(root, theme.borderActive, 1.5, 0.6)

local glass = new("Frame", {Size = UDim2.new(1,0,1,0), BackgroundColor3 = theme.background, BackgroundTransparency = 0.35}, root)
corner(glass, 12)

local scale = new("UIScale", {Scale = 1}, root)
local function updateScale() local c=workspace.CurrentCamera if not c then return end local v=c.ViewportSize local t=math.min(v.X/640, v.Y/450, 1) scale.Scale=math.clamp(t,0.7,1) end
updateScale()
if workspace.CurrentCamera then workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end

local topbar = new("Frame", {Size = UDim2.new(1,0,0,46), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.3}, root)
corner(topbar, 12)
new("Frame", {Size = UDim2.new(1,-24,0,1), Position = UDim2.new(0,12,1,-1), BackgroundColor3 = theme.border, BackgroundTransparency = 0.5}, topbar)

new("TextLabel", {Size = UDim2.fromOffset(20,20), Position = UDim2.fromOffset(14,13), BackgroundTransparency = 1, Text = "◆", TextColor3 = theme.primary, TextSize = 14, Font = Enum.Font.Gotham}, topbar)
local brand = new("TextLabel", {Size = UDim2.fromOffset(180,22), Position = UDim2.fromOffset(38,6), BackgroundTransparency = 1, Text = "TESTE", TextColor3 = theme.text, TextSize = 14, Font = Enum.Font.GothamMedium}, topbar)
new("TextLabel", {Size = UDim2.fromOffset(180,14), Position = UDim2.fromOffset(38,26), BackgroundTransparency = 1, Text = "interface · v2.0", TextColor3 = theme.subtext, TextSize = 8, Font = Enum.Font.Gotham}, topbar)

local function winBtn(text, x, hc)
	local b=new("TextButton", {Size=UDim2.fromOffset(30,28), Position=UDim2.new(1,x,0,9), BackgroundTransparency=1, Text=text, TextColor3=theme.subtext, TextSize=14, Font=Enum.Font.Gotham, AutoButtonColor=false}, topbar)
	corner(b,6)
	local function h(v) tween(b, {BackgroundTransparency = v and 0 or 1, BackgroundColor3 = v and hc or theme.surface, TextColor3 = v and theme.text or theme.subtext}, 0.15) end
	b.MouseEnter:Connect(function() h(true) end) b.MouseLeave:Connect(function() h(false) end)
	return b
end
local minimizeButton = winBtn("—", -68, theme.hover)
local closeButton = winBtn("✕", -35, Color3.fromRGB(200,60,60))
local sidebar = new("Frame", {Size = UDim2.new(0,120,1,-46), Position = UDim2.fromOffset(0,46), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.2}, root)
new("Frame", {Size = UDim2.new(0,1,1,-20), Position = UDim2.new(1,-1,0,10), BackgroundColor3 = theme.border, BackgroundTransparency = 0.4}, sidebar)
new("TextLabel", {Size = UDim2.new(1,-20,0,20), Position = UDim2.fromOffset(10,12), BackgroundTransparency = 1, Text = "MENU", TextColor3 = theme.dim, TextSize = 8, Font = Enum.Font.GothamMedium}, sidebar)
local navigation = new("Frame", {Size = UDim2.new(1,-12,0,180), Position = UDim2.fromOffset(6,40), BackgroundTransparency = 1}, sidebar)
new("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder}, navigation)

local shortcut = new("Frame", {Size = UDim2.new(1,-16,0,48), Position = UDim2.new(0,8,1,-56), BackgroundColor3 = theme.elevated, BackgroundTransparency = 0.3}, sidebar)
corner(shortcut,6); stroke(shortcut, theme.borderActive,1,0.5)
new("TextLabel", {Size = UDim2.new(1,-16,0,16), Position = UDim2.fromOffset(8,6), BackgroundTransparency = 1, Text = "⌨ RIGHT SHIFT", TextColor3 = theme.text, TextSize = 9, Font = Enum.Font.GothamMedium}, shortcut)
new("TextLabel", {Size = UDim2.new(1,-16,0,14), Position = UDim2.fromOffset(8,24), BackgroundTransparency = 1, Text = "show / hide", TextColor3 = theme.subtext, TextSize = 8, Font = Enum.Font.Gotham}, shortcut)

local content = new("Frame", {Size = UDim2.new(1,-120,1,-46), Position = UDim2.fromOffset(120,46), BackgroundColor3 = theme.background, BackgroundTransparency = 0.1, ClipsDescendants = true}, root)
local pageContainer = new("Frame", {Size = UDim2.new(1,-28,1,-24), Position = UDim2.fromOffset(14,12), BackgroundTransparency = 1, ClipsDescendants = true}, content)

local pages, tabs, activePage, switching = {}, {}, nil, false

local function createPage(name)
	local page = new("CanvasGroup", {Name = name, Size = UDim2.new(1,0,1,0), Position = UDim2.fromOffset(14,0), BackgroundTransparency = 1, GroupTransparency = 1, Visible = false}, pageContainer)
	local scroll = new("ScrollingFrame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ScrollBarThickness = 3, ScrollBarImageColor3 = theme.primary, ScrollBarImageTransparency = 0.6, CanvasSize = UDim2.fromOffset(0,0), AutomaticCanvasSize = Enum.AutomaticSize.Y}, page)
	new("UIListLayout", {Padding = UDim.new(0,10), SortOrder = Enum.SortOrder.LayoutOrder}, scroll)
	new("UIPadding", {PaddingRight = UDim.new(0,4), PaddingBottom = UDim.new(0,6)}, scroll)
	pages[name] = {group = page, scroll = scroll}
	return scroll
end

local function setTabVisual(name, selected)
	local tab = tabs[name] if not tab then return end
	tween(tab.button, {BackgroundColor3 = selected and theme.primary or theme.surface, BackgroundTransparency = selected and 0.2 or 0.3}, 0.2)
	tween(tab.text, {TextColor3 = selected and theme.text or theme.subtext}, 0.2)
	tween(tab.indicator, {BackgroundTransparency = selected and 0 or 1, Size = selected and UDim2.fromOffset(3,20) or UDim2.fromOffset(3,6), Position = selected and UDim2.new(0,8,0.5,-10) or UDim2.new(0,8,0.5,-3)}, 0.25)
end

local function switchPage(name)
	if switching or activePage == name or not pages[name] then return end
	switching = true
	local incoming = pages[name].group
	local outgoing = activePage and pages[activePage].group
	for tabName in pairs(tabs) do setTabVisual(tabName, tabName == name) end
	if outgoing then tween(outgoing, {GroupTransparency = 1, Position = UDim2.fromOffset(-16,0)}, 0.18) task.wait(0.14) outgoing.Visible = false end
	incoming.Visible = true incoming.GroupTransparency = 1 incoming.Position = UDim2.fromOffset(16,0)
	tween(incoming, {GroupTransparency = 0, Position = UDim2.fromOffset(0,0)}, 0.25)
	activePage = name task.wait(0.25) switching = false
end

local function createTab(name, icon, label, index)
	local btn = new("TextButton", {Size = UDim2.new(1,0,0,36), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.3, Text = "", AutoButtonColor = false, LayoutOrder = index}, navigation)
	corner(btn,6); stroke(btn, theme.border,1,0.4)
	local ind = new("Frame", {Size = UDim2.fromOffset(3,6), Position = UDim2.new(0,8,0.5,-3), BackgroundColor3 = theme.primary, BackgroundTransparency = 1}, btn)
	corner(ind,2)
	new("TextLabel", {Size = UDim2.fromOffset(18,18), Position = UDim2.fromOffset(24,9), BackgroundTransparency = 1, Text = icon, TextColor3 = theme.primary, TextSize = 12, Font = Enum.Font.Gotham}, btn)
	local txt = new("TextLabel", {Size = UDim2.new(1,-56,1,0), Position = UDim2.fromOffset(46,0), BackgroundTransparency = 1, Text = label, TextColor3 = theme.subtext, TextSize = 9, Font = Enum.Font.GothamMedium}, btn)
	tabs[name] = {button = btn, text = txt, indicator = ind}
	btn.MouseEnter:Connect(function() if activePage ~= name then tween(btn, {BackgroundColor3 = theme.hover, BackgroundTransparency = 0.2}, 0.15) tween(txt, {TextColor3 = theme.text}, 0.15) end end)
	btn.MouseLeave:Connect(function() if activePage ~= name then tween(btn, {BackgroundColor3 = theme.surface, BackgroundTransparency = 0.3}, 0.15) tween(txt, {TextColor3 = theme.subtext}, 0.15) end end)
	btn.MouseButton1Click:Connect(function() switchPage(name) end)
end local function createSection(parent, text)
	return new("TextLabel", {Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, Text = string.upper(text), TextColor3 = theme.primary, TextSize = 10, Font = Enum.Font.GothamMedium}, parent)
end

local function createCard(parent, h)
	local c = new("Frame", {Size = UDim2.new(1,-2,0,h or 48), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.2}, parent)
	corner(c,10); local s = stroke(c, theme.border,1,0.3)
	c.MouseEnter:Connect(function() tween(c, {BackgroundTransparency = 0.05}, 0.18) tween(s, {Color = theme.borderActive, Transparency = 0.6}, 0.18) end)
	c.MouseLeave:Connect(function() tween(c, {BackgroundTransparency = 0.2}, 0.18) tween(s, {Color = theme.border, Transparency = 0.3}, 0.18) end)
	return c
end

local function createInfo(p, t, d)
	local c = createCard(p, 68)
	new("TextLabel", {Size = UDim2.new(1,-24,0,20), Position = UDim2.fromOffset(12,10), BackgroundTransparency = 1, Text = t, TextColor3 = theme.text, TextSize = 12, Font = Enum.Font.GothamMedium}, c)
	new("TextLabel", {Size = UDim2.new(1,-24,0,30), Position = UDim2.fromOffset(12,32), BackgroundTransparency = 1, Text = d, TextColor3 = theme.subtext, TextSize = 9, Font = Enum.Font.Gotham, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top}, c)
	return c
end

local function createButton(p, t, cb)
	local b = new("TextButton", {Size = UDim2.new(1,-2,0,40), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.2, Text = t, TextColor3 = theme.text, TextSize = 10, Font = Enum.Font.GothamMedium, AutoButtonColor = false}, p)
	corner(b,8); local s = stroke(b, theme.border,1,0.3)
	b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = theme.primary, BackgroundTransparency = 0.2}, 0.15) tween(s, {Color = theme.borderActive, Transparency = 0.6}, 0.15) end)
	b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = theme.surface, BackgroundTransparency = 0.2}, 0.15) tween(s, {Color = theme.border, Transparency = 0.3}, 0.15) end)
	b.MouseButton1Down:Connect(function() tween(b, {BackgroundTransparency = 0.5, TextColor3 = theme.primary}, 0.08) end)
	b.MouseButton1Up:Connect(function() tween(b, {BackgroundTransparency = 0.2, TextColor3 = theme.text}, 0.1) end)
	b.MouseButton1Click:Connect(function() if cb then cb() end end)
	return b
end

local function createToggle(p, t, def, cb)
	local enabled = def == true
	local c = createCard(p, 48)
	new("TextLabel", {Size = UDim2.new(1,-80,1,0), Position = UDim2.fromOffset(12,0), BackgroundTransparency = 1, Text = t, TextColor3 = theme.text, TextSize = 10, Font = Enum.Font.Gotham}, c)
	local tog = new("TextButton", {Size = UDim2.fromOffset(40,20), Position = UDim2.new(1,-52,0.5,-10), BackgroundColor3 = enabled and theme.primary or theme.elevated, BackgroundTransparency = enabled and 0.3 or 0.5, Text = "", AutoButtonColor = false}, c)
	corner(tog,10); local s = stroke(tog, theme.borderActive,1, enabled and 0.6 or 0.3)
	local knob = new("Frame", {Size = UDim2.fromOffset(14,14), Position = enabled and UDim2.new(1,-18,0.5,-7) or UDim2.fromOffset(3,3), BackgroundColor3 = enabled and theme.background or theme.subtext}, tog)
	corner(knob,7)
	local function upd() tween(tog, {BackgroundColor3 = enabled and theme.primary or theme.elevated, BackgroundTransparency = enabled and 0.3 or 0.5}, 0.2) tween(s, {Transparency = enabled and 0.6 or 0.3}, 0.2) tween(knob, {Position = enabled and UDim2.new(1,-18,0.5,-7) or UDim2.fromOffset(3,3), BackgroundColor3 = enabled and theme.background or theme.subtext}, 0.2) if cb then cb(enabled) end end
	tog.MouseButton1Click:Connect(function() enabled = not enabled upd() end)
	return c
end

local function createInput(p, t, ph, cb)
	local c = createCard(p, 68)
	new("TextLabel", {Size = UDim2.new(1,-24,0,18), Position = UDim2.fromOffset(12,8), BackgroundTransparency = 1, Text = t, TextColor3 = theme.subtext, TextSize = 9, Font = Enum.Font.Gotham}, c)
	local f = new("Frame", {Size = UDim2.new(1,-24,0,30), Position = UDim2.fromOffset(12,30), BackgroundColor3 = theme.background, BackgroundTransparency = 0.3}, c)
	corner(f,6); local s = stroke(f, theme.border,1,0.2)
	local inp = new("TextBox", {Size = UDim2.new(1,-20,1,0), Position = UDim2.fromOffset(10,0), BackgroundTransparency = 1, Text = "", PlaceholderText = ph, PlaceholderColor3 = theme.dim, TextColor3 = theme.text, TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false}, f)
	inp.Focused:Connect(function() tween(f, {BackgroundTransparency = 0.1}, 0.16) tween(s, {Color = theme.primary, Transparency = 0.5}, 0.16) end)
	inp.FocusLost:Connect(function(enter) tween(f, {BackgroundTransparency = 0.3}, 0.16) tween(s, {Color = theme.border, Transparency = 0.2}, 0.16) if cb then cb(inp.Text, enter) end end)
	return inp
end

local function createSlider(p, t, min, max, def, cb)
	local val = math.clamp(def or min, min, max)
	local dragging = false
	local c = createCard(p, 64)
	new("TextLabel", {Size = UDim2.new(1,-80,0,22), Position = UDim2.fromOffset(12,6), BackgroundTransparency = 1, Text = t, TextColor3 = theme.text, TextSize = 10, Font = Enum.Font.Gotham}, c)
	local valLabel = new("TextLabel", {Size = UDim2.fromOffset(50,22), Position = UDim2.new(1,-62,0,6), BackgroundTransparency = 1, Text = tostring(val), TextColor3 = theme.primary, TextSize = 10, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Right}, c)
	local track = new("Frame", {Size = UDim2.new(1,-24,0,4), Position = UDim2.fromOffset(12,46), BackgroundColor3 = theme.border, BackgroundTransparency = 0.5}, c)
	corner(track,2)
	local ratio = (val - min) / (max - min)
	local fill = new("Frame", {Size = UDim2.new(ratio,0,1,0), BackgroundColor3 = theme.primary, BackgroundTransparency = 0.3}, track)
	corner(fill,2)
	local knob = new("Frame", {Size = UDim2.fromOffset(12,12), Position = UDim2.new(ratio,-6,0.5,-6), BackgroundColor3 = theme.primary, BackgroundTransparency = 0.1}, track)
	corner(knob,6); stroke(knob, theme.borderActive,1,0.4)
	local hit = new("TextButton", {Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,0.5,-10), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, track)
	local function upd(x)
		local r = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		val = math.floor(min + ((max - min) * r))
		tween(fill, {Size = UDim2.new(r,0,1,0)}, 0.08, Enum.EasingStyle.Linear)
		tween(knob, {Position = UDim2.new(r,-6,0.5,-6)}, 0.08, Enum.EasingStyle.Linear)
		valLabel.Text = tostring(val)
		if cb then cb(val) end
	end
	hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true upd(i.Position.X) tween(knob, {Size = UDim2.fromOffset(16,16), Position = UDim2.new(knob.Position.X.Scale, -8, 0.5, -8)}, 0.1) end end)
	UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end end)
	UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false tween(knob, {Size = UDim2.fromOffset(12,12), Position = UDim2.new(knob.Position.X.Scale, -6, 0.5, -6)}, 0.1) end end)
	return c
end

local notifications = new("Frame", {Size = UDim2.fromOffset(260,200), Position = UDim2.new(1,-280,1,-220), BackgroundTransparency = 1}, gui)
new("UIListLayout", {VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder}, notifications)

local function notify(text)
	local n = new("CanvasGroup", {Size = UDim2.fromOffset(240,48), BackgroundColor3 = theme.surface, BackgroundTransparency = 0.1, GroupTransparency = 1}, notifications)
	corner(n,8); stroke(n, theme.borderActive,1,0.5)
	local bar = new("Frame", {Size = UDim2.fromOffset(3,24), Position = UDim2.fromOffset(10,12), BackgroundColor3 = theme.primary}, n)
	corner(bar,2)
	new("TextLabel", {Size = UDim2.new(1,-32,1,0), Position = UDim2.fromOffset(22,0), BackgroundTransparency = 1, Text = text, TextColor3 = theme.text, TextSize = 9, Font = Enum.Font.Gotham}, n)
	n.Position = UDim2.fromOffset(20,0)
	tween(n, {GroupTransparency = 0, Position = UDim2.fromOffset(0,0)}, 0.25)
	task.delay(2.5, function() tween(n, {GroupTransparency = 1, Position = UDim2.fromOffset(20,0)}, 0.2) task.wait(0.25) n:Destroy() end)
end

local homePage = createPage("Home")
local controlsPage = createPage("Controls")
local settingsPage = createPage("Settings")

createTab("Home", "🏠", "HOME", 1)
createTab("Controls", "🎮", "CONTROLS", 2)
createTab("Settings", "⚙️", "SETTINGS", 3)

createSection(homePage, "Overview")
createInfo(homePage, "TESTE v2.0", "Interface moderna com transições suaves e componentes interativos para testes.")
createSection(homePage, "Input")
createInput(homePage, "TEXT INPUT", "Digite algo...", function(text, enter) if enter and text ~= "" then notify("📝 " .. text) end end)
createSection(homePage, "Actions")
createButton(homePage, "✨ Mostrar notificação", function() notify("✅ Notificação de teste") end)
createButton(homePage, "⚡ Executar ação", function() notify("⚡ Ação executada") end)

createSection(controlsPage, "Toggles")
createToggle(controlsPage, "Opção primária", false, function() end)
createToggle(controlsPage, "Opção secundária", true, function() end)
createToggle(controlsPage, "Modo visual", false, function() end)
createSection(controlsPage, "Sliders")
createSlider(controlsPage, "Intensidade", 0, 100, 50, function() end)
createSlider(controlsPage, "Velocidade", 1, 25, 10, function() end)

createSection(settingsPage, "Interface")
createToggle(settingsPage, "Animações", true, function() end)
createToggle(settingsPage, "Notificações", true, function() end)
createSection(settingsPage, "Personalização")
createInput(settingsPage, "TÍTULO PERSONALIZADO", "Digite um título...", function(text, enter) if enter and text ~= "" then brand.Text = string.upper(text) notify("🏷️ Título atualizado") end end)
createSection(settingsPage, "Sessão")
createButton(settingsPage, "↺ Resetar posição", function() tween(root, {Position = UDim2.new(0.5,-270,0.5,-180)}, 0.4) notify("↺ Posição resetada") end)
createInfo(settingsPage, "ATALHO", "Pressione RIGHT SHIFT para exibir/ocultar a interface.")

local visible, minimized = true, false
local normalSize = UDim2.fromOffset(540, 360)
local function setVisible(state)
	if visible == state then return end visible = state
	if state then gui.Enabled = true root.Visible = true root.GroupTransparency = 1 root.Position = UDim2.new(0.5,-270,0.5,-172) tween(root, {GroupTransparency = 0, Position = UDim2.new(0.5,-270,0.5,-180)}, 0.25)
	else tween(root, {GroupTransparency = 1, Position = UDim2.new(0.5,-270,0.5,-172)}, 0.2) task.delay(0.2, function() if not visible then root.Visible = false end end) end
end

minimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then sidebar.Visible = false content.Visible = false tween(root, {Size = UDim2.fromOffset(540,46)}, 0.3) minimizeButton.Text = "+"
	else tween(root, {Size = normalSize}, 0.3) task.delay(0.18, function() sidebar.Visible = true content.Visible = true end) minimizeButton.Text = "—" end
end)

closeButton.MouseButton1Click:Connect(function()
	tween(root, {GroupTransparency = 1, Size = UDim2.fromOffset(540,20)}, 0.25)
	task.wait(0.3) gui:Destroy()
end)

local dragging = false
local dragStart, startPosition
topbar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPosition = root.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart root.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + d.X, startPosition.Y.Scale, startPosition.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

UserInputService.InputBegan:Connect(function(i, p) if p then return end if i.KeyCode == Enum.KeyCode.RightShift then setVisible(not visible) end end)

for name, page in pairs(pages) do
	page.group.Visible = name == "Home"
	page.group.GroupTransparency = name == "Home" and 0 or 1
	page.group.Position = UDim2.fromOffset(0,0)
end
activePage = "Home"
for name in pairs(tabs) do setTabVisual(name, name == "Home") end

root.Size = UDim2.fromOffset(540,30)
root.Position = UDim2.new(0.5,-270,0.5,-165)
tween(root, {GroupTransparency = 0, Size = normalSize, Position = UDim2.new(0.5,-270,0.5,-180)}, 0.4)
task.delay(0.5, function() notify("🚀 TESTE v2.0 carregado") end)