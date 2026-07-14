-- fodase

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- nao duplicar
local antiga = playerGui:FindFirstChild("InterfaceTeste")
if antiga then
	antiga:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "InterfaceTeste"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local janela = Instance.new("Frame")
janela.Name = "Janela"
janela.Size = UDim2.fromOffset(360, 230)
janela.Position = UDim2.new(0.5, -180, 0.5, -115)
janela.BackgroundColor3 = Color3.fromRGB(24, 25, 32)
janela.BorderSizePixel = 0
janela.Parent = gui

local cantoJanela = Instance.new("UICorner")
cantoJanela.CornerRadius = UDim.new(0, 14)
cantoJanela.Parent = janela

local contorno = Instance.new("UIStroke")
contorno.Color = Color3.fromRGB(86, 102, 255)
contorno.Thickness = 1.5
contorno.Transparency = 0.25
contorno.Parent = janela

local barra = Instance.new("Frame")
barra.Name = "BarraSuperior"
barra.Size = UDim2.new(1, 0, 0, 50)
barra.BackgroundColor3 = Color3.fromRGB(31, 33, 43)
barra.BorderSizePixel = 0
barra.Parent = janela

local cantoBarra = Instance.new("UICorner")
cantoBarra.CornerRadius = UDim.new(0, 14)
cantoBarra.Parent = barra

-- Corrige os cantos inferiores arredondados da barra
local preenchimento = Instance.new("Frame")
preenchimento.Size = UDim2.new(1, 0, 0, 14)
preenchimento.Position = UDim2.new(0, 0, 1, -14)
preenchimento.BackgroundColor3 = barra.BackgroundColor3
preenchimento.BorderSizePixel = 0
preenchimento.Parent = barra

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, -100, 1, 0)
titulo.Position = UDim2.fromOffset(18, 0)
titulo.BackgroundTransparency = 1
titulo.Text = "Interface de teste"
titulo.TextColor3 = Color3.fromRGB(240, 240, 245)
titulo.TextSize = 18
titulo.Font = Enum.Font.GothamSemibold
titulo.TextXAlignment = Enum.TextXAlignment.Left
titulo.Parent = barra

local fechar = Instance.new("TextButton")
fechar.Size = UDim2.fromOffset(34, 34)
fechar.Position = UDim2.new(1, -43, 0, 8)
fechar.BackgroundColor3 = Color3.fromRGB(44, 46, 58)
fechar.Text = "×"
fechar.TextColor3 = Color3.fromRGB(220, 220, 225)
fechar.TextSize = 24
fechar.Font = Enum.Font.Gotham
fechar.AutoButtonColor = false
fechar.Parent = barra

local cantoFechar = Instance.new("UICorner")
cantoFechar.CornerRadius = UDim.new(0, 9)
cantoFechar.Parent = fechar

local descricao = Instance.new("TextLabel")
descricao.Size = UDim2.new(1, -40, 0, 48)
descricao.Position = UDim2.fromOffset(20, 70)
descricao.BackgroundTransparency = 1
descricao.Text = "Uma interface simples para testar botões, animações e arrastar a janela."
descricao.TextColor3 = Color3.fromRGB(165, 168, 180)
descricao.TextSize = 14
descricao.Font = Enum.Font.Gotham
descricao.TextWrapped = true
descricao.TextXAlignment = Enum.TextXAlignment.Left
descricao.Parent = janela

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -40, 0, 30)
status.Position = UDim2.fromOffset(20, 125)
status.BackgroundTransparency = 1
status.Text = "Status: desativado"
status.TextColor3 = Color3.fromRGB(190, 192, 205)
status.TextSize = 14
status.Font = Enum.Font.GothamMedium
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = janela

local botao = Instance.new("TextButton")
botao.Size = UDim2.new(1, -40, 0, 48)
botao.Position = UDim2.new(0, 20, 1, -68)
botao.BackgroundColor3 = Color3.fromRGB(86, 102, 255)
botao.Text = "Ativar teste"
botao.TextColor3 = Color3.fromRGB(255, 255, 255)
botao.TextSize = 15
botao.Font = Enum.Font.GothamSemibold
botao.AutoButtonColor = false
botao.Parent = janela

local cantoBotao = Instance.new("UICorner")
cantoBotao.CornerRadius = UDim.new(0, 11)
cantoBotao.Parent = botao

local ativado = false

local function animar(objeto, propriedades, tempo)
	TweenService:Create(
		objeto,
		TweenInfo.new(tempo or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		propriedades
	):Play()
end

botao.MouseEnter:Connect(function()
	animar(botao, {
		BackgroundColor3 = ativado
			and Color3.fromRGB(225, 76, 93)
			or Color3.fromRGB(105, 119, 255)
	})
end)

botao.MouseLeave:Connect(function()
	animar(botao, {
		BackgroundColor3 = ativado
			and Color3.fromRGB(205, 65, 82)
			or Color3.fromRGB(86, 102, 255)
	})
end)

botao.MouseButton1Click:Connect(function()
	ativado = not ativado

	if ativado then
		botao.Text = "Desativar teste"
		status.Text = "Status: ativado"
		status.TextColor3 = Color3.fromRGB(97, 220, 150)

		animar(botao, {
			BackgroundColor3 = Color3.fromRGB(205, 65, 82)
		})
	else
		botao.Text = "Ativar teste"
		status.Text = "Status: desativado"
		status.TextColor3 = Color3.fromRGB(190, 192, 205)

		animar(botao, {
			BackgroundColor3 = Color3.fromRGB(86, 102, 255)
		})
	end
end)

fechar.MouseEnter:Connect(function()
	animar(fechar, {
		BackgroundColor3 = Color3.fromRGB(205, 65, 82)
	})
end)

fechar.MouseLeave:Connect(function()
	animar(fechar, {
		BackgroundColor3 = Color3.fromRGB(44, 46, 58)
	})
end)

fechar.MouseButton1Click:Connect(function()
	animar(janela, {
		Size = UDim2.fromOffset(0, 0),
		BackgroundTransparency = 1
	}, 0.25)

	task.wait(0.25)
	gui:Destroy()
end)

-- Permite arrastar a janela pela barra superior
local arrastando = false
local inicioMouse
local inicioPosicao

barra.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		arrastando = true
		inicioMouse = input.Position
		inicioPosicao = janela.Position
	end
end)

barra.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		arrastando = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not arrastando then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then

		local diferenca = input.Position - inicioMouse

		janela.Position = UDim2.new(
			inicioPosicao.X.Scale,
			inicioPosicao.X.Offset + diferenca.X,
			inicioPosicao.Y.Scale,
			inicioPosicao.Y.Offset + diferenca.Y
		)
	end
end)

-- animacao d entrada c der certo tlgd
local tamanhoFinal = janela.Size
janela.Size = UDim2.fromOffset(0, 0)

animar(janela, {
	Size = tamanhoFinal
}, 0.35)