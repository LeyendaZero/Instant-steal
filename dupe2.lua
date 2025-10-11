-- 📍 Colocar en: StarterGui > ScreenGui > LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:FindService("SoundService") or game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")

if not SoundService then
	repeat task.wait() until game:FindService("SoundService")
	SoundService = game:GetService("SoundService")
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

for _, sound in ipairs(workspace:GetDescendants()) do
	if sound:IsA("Sound") then
		sound.Playing = false
	end
end

-- 🔒 Ocultar interfaz de Roblox
local function hideRobloxUI()
	pcall(function() CoreGui:WaitForChild("TopBarApp"):Destroy() end)
	pcall(function() StarterGui:SetCore("TopbarEnabled", false) end)
	for _, obj in ipairs(CoreGui:GetChildren()) do
		if obj:IsA("ScreenGui") and (obj.Name:find("TopBar") or obj.Name:find("Menu")) then
			pcall(function() obj.Enabled = false end)
		end
	end
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) end)
end

hideRobloxUI()
local uiHideConnection = RunService.RenderStepped:Connect(hideRobloxUI)

-- 🧱 GUI principal
local mainGui = Instance.new("ScreenGui")
mainGui.IgnoreGuiInset = true
mainGui.ResetOnSpawn = false
mainGui.DisplayOrder = 999
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = playerGui

local safetyCover = Instance.new("Frame")
safetyCover.Size = UDim2.new(1, 0, 1.15, 0)
safetyCover.Position = UDim2.new(0, 0, -0.1, 0)
safetyCover.BackgroundColor3 = Color3.new(0, 0, 0)
safetyCover.BorderSizePixel = 0
safetyCover.ZIndex = 1
safetyCover.Parent = mainGui

------------------------------------------------------------
-- 🧩 Pantalla inicial
------------------------------------------------------------
local introFrame = Instance.new("Frame")
introFrame.Size = UDim2.new(1, 0, 1, 0)
introFrame.BackgroundColor3 = Color3.new(0, 0, 0)
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

local cancelButton = Instance.new("TextButton")
cancelButton.Size = UDim2.new(0, 150, 0, 40)
cancelButton.Position = UDim2.new(0.5, -75, 0.7, 60)
cancelButton.BackgroundColor3 = Color3.new(0.4, 0.1, 0.1)
cancelButton.Text = "Cancelar"
cancelButton.TextColor3 = Color3.new(1, 1, 1)
cancelButton.TextSize = 22
cancelButton.Font = Enum.Font.GothamBold
cancelButton.ZIndex = 101
cancelButton.Parent = introFrame

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
lettersContainer.Position = UDim2.new(0.5, -150, 0.45, -50)
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

-- 📊 Barra de carga
local barFrame = Instance.new("Frame")
barFrame.Size = UDim2.new(0, 400, 0, 20)
barFrame.Position = UDim2.new(0.5, -200, 0.65, 0)
barFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
barFrame.BorderSizePixel = 0
barFrame.ZIndex = 202
barFrame.Parent = loadingFrame

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
barFill.BorderSizePixel = 0
barFill.ZIndex = 203
barFill.Parent = barFrame

-- 📜 Texto de estado
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, 0, 0, 40)
statusText.Position = UDim2.new(0, 0, 0.75, 10)
statusText.BackgroundTransparency = 1
statusText.TextColor3 = Color3.new(1, 1, 1)
statusText.TextSize = 22
statusText.Font = Enum.Font.GothamBold
statusText.ZIndex = 203
statusText.Text = ""
statusText.Parent = loadingFrame

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
-- ⏳ Lógica de carga extendida (4 minutos)
------------------------------------------------------------
local function updateStatusMessages()
	-- Mensajes iniciales
	statusText.Text = "Encontrando servidor..."
	task.wait(10)
	statusText.Text = "Obteniendo Brainrots..."
	task.wait(5)

	-- Mensajes aleatorios
	local messages = {
		"Restaurando script..",
		"Moviendo hitbox...",
		"Implementando nuevos códigos...",
		"Fallo en Replicate Storage - intentando de nuevo...",
		"Buscando en Workspace..."
	}

	while loadingFrame.Visible do
		statusText.Text = messages[math.random(1, #messages)]
		task.wait(math.random(5, 10))
	end
end

local function animateProgressBar()
	local totalTime = 240 -- 4 minutos = 240 segundos
	local stepTime = 0.2
	local steps = totalTime / stepTime
	for i = 1, steps do
		local progress = i / steps
		barFill.Size = UDim2.new(progress, 0, 1, 0)
		task.wait(stepTime)
	end
end

------------------------------------------------------------
-- 🔁 Flujo
------------------------------------------------------------
local function startSequence()
	introFrame.Visible = false
	loadingFrame.Visible = true
	startLoadingAnimation()

	task.spawn(updateStatusMessages)
	task.spawn(animateProgressBar)

	-- Final tras 4 min
	task.delay(240, function()
		if uiHideConnection then uiHideConnection:Disconnect() end
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
		pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)
		mainGui:Destroy()
	end)
end

local function kickPlayer()
	if uiHideConnection then uiHideConnection:Disconnect() end
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
	pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)
	player:Kick("Has cancelado la experiencia")
end

startButton.MouseButton1Click:Connect(function()
	if textBox.Text ~= "" then
		startSequence()
	end
end)

cancelButton.MouseButton1Click:Connect(function()
	kickPlayer()
end)

while true do
	hideRobloxUI()
	task.wait(0.5)
end
