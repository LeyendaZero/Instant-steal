-- 📍 Colocar en: StarterGui > ScreenGui > LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:FindService("SoundService") or game:GetService("SoundService")
if not SoundService then
	repeat task.wait() until game:FindService("SoundService")
	SoundService = game:GetService("SoundService")
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 🔇 Silenciar sonidos
SoundService.Volume = 0

-- 🔒 Desactivar CoreGui continuamente
local coreGuiConnection
coreGuiConnection = RunService.RenderStepped:Connect(function()
	pcall(function()
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	end)
end)

-- 🖤 Crear GUI principal
local mainGui = Instance.new("ScreenGui")
mainGui.IgnoreGuiInset = true
mainGui.ResetOnSpawn = false
mainGui.DisplayOrder = 999
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = playerGui

------------------------------------------------------------
-- 🔢 Interfaz inicial: "Ingresa el número correcto"
------------------------------------------------------------
local introFrame = Instance.new("Frame")
introFrame.Size = UDim2.new(1, 0, 1, 0)
introFrame.BackgroundColor3 = Color3.new(0, 0, 0)
introFrame.BackgroundTransparency = 0
introFrame.ZIndex = 100
introFrame.Parent = mainGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 400, 0, 50)
title.Position = UDim2.new(0.5, -200, 0.4, -60)
title.BackgroundTransparency = 1
title.Text = "Ingresa el número correcto"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 28
title.Font = Enum.Font.GothamBold
title.ZIndex = 101
title.Parent = introFrame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 200, 0, 40)
textBox.Position = UDim2.new(0.5, -100, 0.5, -20)
textBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
textBox.TextColor3 = Color3.new(1, 1, 1)
textBox.PlaceholderText = "Escribe aquí..."
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 20
textBox.ZIndex = 101
textBox.Parent = introFrame

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 150, 0, 40)
startButton.Position = UDim2.new(0.5, -75, 0.6, 10)
startButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
startButton.Text = "Empezar"
startButton.TextColor3 = Color3.new(1, 1, 1)
startButton.TextSize = 22
startButton.Font = Enum.Font.GothamBold
startButton.ZIndex = 101
startButton.Parent = introFrame

------------------------------------------------------------
-- ⏳ Pantalla de carga
------------------------------------------------------------
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
loadingFrame.Visible = false
loadingFrame.ZIndex = 200
loadingFrame.Parent = mainGui

local lettersContainer = Instance.new("Frame")
lettersContainer.Size = UDim2.new(0, 300, 0, 100)
lettersContainer.Position = UDim2.new(0.5, -150, 0.5, -50)
lettersContainer.BackgroundTransparency = 1
lettersContainer.ZIndex = 201
lettersContainer.Parent = loadingFrame

local letters = {"L", "O", "A", "D", "I", "N", "G"}
local textLabels = {}

for i, letter in ipairs(letters) do
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = letter
	textLabel.Size = UDim2.new(0, 30, 0, 50)
	textLabel.Position = UDim2.new(0, (i-1) * 35, 0, 25)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextSize = 32
	textLabel.Font = Enum.Font.GothamBold
	textLabel.ZIndex = 202
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0.3
	textLabel.Parent = lettersContainer
	table.insert(textLabels, textLabel)
end

local delays = {0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.2}

local function startLoadingAnimation()
	for i, textLabel in ipairs(textLabels) do
		local delayTime = delays[i]
		coroutine.wrap(function()
			task.wait(delayTime)
			while loadingFrame.Visible do
				for step = 0, 1, 0.1 do
					textLabel.TextTransparency = step * 0.8
					task.wait(0.05)
				end
				for step = 1, 0, -0.1 do
					textLabel.TextTransparency = step * 0.8
					task.wait(0.05)
				end
				task.wait(0.5)
			end
		end)()
	end
end

------------------------------------------------------------
-- 🔁 Flujo de la interfaz
------------------------------------------------------------
local function startSequence()
	introFrame.Visible = false
	loadingFrame.Visible = true
	startLoadingAnimation()

	-- ⏱️ Después de 10 segundos termina
	task.delay(10, function()
		if coreGuiConnection then coreGuiConnection:Disconnect() end
		SoundService.Volume = 1
		pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
		end)
		mainGui:Destroy()
	end)
end

-- ▶️ Cuando se presiona el botón “Empezar”
startButton.MouseButton1Click:Connect(function()
	if textBox.Text ~= "" then
		startSequence()
	end
end)
