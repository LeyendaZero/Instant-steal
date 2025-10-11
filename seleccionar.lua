-- 📍 StarterGui > LocalScript
-- 💫 Interfaz Neon con efecto Glass + selección dinámica de NPCs en Workspace.Plots

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- 🟢 Solo continuar si hay un jugador
if #Players:GetPlayers() > 8 then
	warn("Hay más de 1 jugadores en el servidor")
	
	-- 🎯 Crear mensaje toast de error neón
	local playerGui = player:WaitForChild("PlayerGui")
	local toastGui = Instance.new("ScreenGui")
	toastGui.Name = "ErrorToast"
	toastGui.ResetOnSpawn = false
	toastGui.Parent = playerGui

	local toastFrame = Instance.new("Frame")
	toastFrame.Size = UDim2.new(0.6, 0, 0.08, 0)
	toastFrame.Position = UDim2.new(0.2, 0, 0.45, 0)
	toastFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
	toastFrame.BackgroundTransparency = 1
	toastFrame.Parent = toastGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.15, 0)
	corner.Parent = toastFrame

	-- ✨ Borde neón rojo
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 20, 20)
	stroke.Thickness = 3
	stroke.Transparency = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = toastFrame

	local errorLabel = Instance.new("TextLabel")
	errorLabel.Size = UDim2.new(1, 0, 1, 0)
	errorLabel.Text = "⚠️ ERROR: Hay más de 1 jugador en el servidor"
	errorLabel.Font = Enum.Font.GothamBold
	errorLabel.TextScaled = true
	errorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	errorLabel.BackgroundTransparency = 1
	errorLabel.TextTransparency = 1
	errorLabel.TextStrokeColor3 = Color3.fromRGB(255, 60, 60)
	errorLabel.TextStrokeTransparency = 1
	errorLabel.Parent = toastFrame

	-- 🎬 Animación de entrada
	TweenService:Create(toastFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.9
	}):Play()
	
	TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 0
	}):Play()
	
	TweenService:Create(errorLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		TextStrokeTransparency = 0.3
	}):Play()

	-- ⏱️ Mostrar por 4 segundos y luego animar salida
	task.delay(4, function()
		TweenService:Create(toastFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1
		}):Play()
		
		TweenService:Create(stroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		
		TweenService:Create(errorLabel, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		}):Play()
		
		task.wait(0.8)
		toastGui:Destroy()
	end)

	script:Destroy()
	return
end

-- 🌟 CREAR PANTALLA DE CARGA INICIAL
local function createLoadingScreen()
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- Crear el ScreenGui con MÁXIMA prioridad
	local loadingGui = Instance.new("ScreenGui")
	loadingGui.Name = "LoadingGUI"
	loadingGui.IgnoreGuiInset = true
	loadingGui.ResetOnSpawn = false
	loadingGui.DisplayOrder = 999
	loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	loadingGui.Parent = playerGui

	-- Crear frame de fondo que cubra ABSOLUTAMENTE TODO
	local loadingFrame = Instance.new("Frame")
	loadingFrame.Size = UDim2.new(1, 0, 1, 0)
	loadingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	loadingFrame.BorderSizePixel = 0
	loadingFrame.BackgroundTransparency = 0
	loadingFrame.ZIndex = 999
	loadingFrame.Parent = loadingGui

	-- Crear contenedor para las letras con alta prioridad
	local lettersContainer = Instance.new("Frame")
	lettersContainer.Size = UDim2.new(0, 300, 0, 100)
	lettersContainer.Position = UDim2.new(0.5, -150, 0.5, -50)
	lettersContainer.BackgroundTransparency = 1
	lettersContainer.ZIndex = 1000
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
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextSize = 32
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextTransparency = 0
		textLabel.ZIndex = 1001
		textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
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

	startLoadingAnimation()
	
	return loadingGui
end

-- ⏱️ Mostrar pantalla de carga por 3 segundos
local loadingGui = createLoadingScreen()
task.wait(3)

-- 📦 Buscar la carpeta Workspace.Plots
local plotsFolder = Workspace:FindFirstChild("Plots")
if not plotsFolder then
	warn("[NPC Selector] No se encontró Workspace.Plots")
	loadingGui:Destroy()
	return
end

-- 🎨 Lista base de NPCs válidos
local npcNames = {
	"Noobini Pizzanini", "Gattatino Nyanino", "Matteo", "Espresso Signora", "Odin Din Din Dun",
	"Statutino Libertino", "Ballerino Lololo", "Trigoligre Frutonni",
	"Orcalero Orcala", "Los Crocodillitos", "Piccione Macchina",
	"La Vacca Staturno Saturnita", "Chimpanzini Spiderini", "Los Tralaleritos",
	"Las Tralaleritas", "Graipuss Medussi", "La Grande Combinasion",
	"Nuclearo Dinossauro", "Garama and Madundung",
	"Tortuginni Dragonfruitini", "Pot Hotspot", "Las Vaquitas Saturnitas",
	"Chicleteira Bicicleteira", "La Cucaracha"
}

-- 🔍 Buscar NPCs dentro de Workspace.Plots
local availableNPCs = {}
for _, descendant in ipairs(plotsFolder:GetDescendants()) do
	if table.find(npcNames, descendant.Name) then
		table.insert(availableNPCs, descendant.Name)
	end
end

-- ⚠️ Si no hay NPCs válidos en Plots, mostrar un toast
if #availableNPCs == 0 then
	warn("[NPC Selector] No se encontró ningún NPC válido en Workspace.Plots.")
	
	local guiToast = Instance.new("ScreenGui")
	guiToast.Parent = player:WaitForChild("PlayerGui")
	
	local toast = Instance.new("TextLabel")
	toast.Size = UDim2.new(0.6, 0, 0.1, 0)
	toast.Position = UDim2.new(0.2, 0, 0.45, 0)
	toast.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	toast.Text = "⚠️ No se encontró ningún NPC válido en Workspace.Plots"
	toast.Font = Enum.Font.GothamBold
	toast.TextScaled = true
	toast.TextColor3 = Color3.fromRGB(255, 255, 255)
	toast.BackgroundTransparency = 1
	toast.Parent = guiToast

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.2, 0)
	corner.Parent = toast

	-- Animación toast
	TweenService:Create(toast, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.2
	}):Play()

	task.delay(3, function()
		TweenService:Create(toast, TweenInfo.new(0.5), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
		task.wait(0.6)
		guiToast:Destroy()
		loadingGui:Destroy()
	end)
	
	return
end

-- 🌫️ Efecto glass
local blur = Instance.new("BlurEffect")
blur.Size = 25
blur.Parent = Lighting

-- 🧊 TRANSICIÓN SUAVE DE CARGA A INTERFAZ PRINCIPAL
local function transitionToMainInterface()
    -- Animación de salida de la pantalla de carga
    -- En lugar de tweenear el ScreenGui, tweeneamos el Frame interno
    local loadingFrame = loadingGui:FindFirstChildOfClass("Frame")
    if loadingFrame then
        TweenService:Create(loadingFrame, TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
    end
    
    -- También animar la transparencia de las letras
    local lettersContainer = loadingFrame and loadingFrame:FindFirstChildOfClass("Frame")
    if lettersContainer then
        for _, textLabel in ipairs(lettersContainer:GetChildren()) do
            if textLabel:IsA("TextLabel") then
                TweenService:Create(textLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    TextTransparency = 1
                }):Play()
            end
        end
    end
    
    task.wait(5)
    loadingGui:Destroy()
    
    -- 🧊 [El resto del código para crear la GUI principal permanece igual...]
	
	-- 🧊 Crear GUI principal
	local gui = Instance.new("ScreenGui")
	gui.Name = "NeonNPCSelector"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	-- 🌑 Fondo negro sólido
	local background = Instance.new("Frame")
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	background.BackgroundTransparency = 1 -- Comienza transparente para animación
	background.Parent = gui

	-- 🎇 Título con efecto neón
	local titleContainer = Instance.new("Frame")
	titleContainer.Size = UDim2.new(0.6, 0, 0.1, 0)
	titleContainer.Position = UDim2.new(0.2, 0, 0.02, 0)
	titleContainer.BackgroundTransparency = 1
	titleContainer.Parent = background

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 1, 0)
	titleLabel.Text = "SELECCIONA UN NPC"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextScaled = true
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextTransparency = 1
	titleLabel.TextStrokeColor3 = Color3.fromRGB(180, 60, 255)
	titleLabel.TextStrokeTransparency = 1
	titleLabel.Parent = titleContainer

	-- ✨ Contenedor tipo grid
	local grid = Instance.new("Frame")
	grid.Size = UDim2.new(0.85, 0, 0.75, 0)
	grid.Position = UDim2.new(0.075, 0, 0.15, 0)
	grid.BackgroundTransparency = 1
	grid.Parent = background

	local layout = Instance.new("UIGridLayout")
	layout.CellPadding = UDim2.new(0.015, 0, 0.015, 0)
	layout.CellSize = UDim2.new(0.23, 0, 0.12, 0)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = grid

	-- 🎆 Colores neón para los bordes
	local neonColors = {
		Color3.fromRGB(255, 60, 60),
		Color3.fromRGB(255, 120, 40),
		Color3.fromRGB(255, 230, 60),
		Color3.fromRGB(180, 60, 255),
		Color3.fromRGB(90, 255, 100),
		Color3.fromRGB(40, 150, 255),
		Color3.fromRGB(255, 255, 255),
	}

	-- 🧱 Crear botones dinámicos con diseño minimalista
	for i, name in ipairs(availableNPCs) do
		local btn = Instance.new("TextButton")
		btn.Text = name
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextScaled = true
		btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		btn.BackgroundTransparency = 1
		btn.AutoButtonColor = false
		btn.BorderSizePixel = 0
		btn.Parent = grid
		
		-- 🎯 Contorno de texto blanco
		btn.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextStrokeTransparency = 0.8

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.15, 0)
		corner.Parent = btn

		-- 🎇 Borde neón (inicialmente transparente)
		local stroke = Instance.new("UIStroke")
		stroke.Color = neonColors[(i % #neonColors) + 1]
		stroke.Thickness = 2
		stroke.Transparency = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = btn

		-- ✨ Animación de aparición fluida
		btn.TextTransparency = 1
		local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, i * 0.08)
		
		-- Animación simultánea del texto y borde
		local tweenGroup = {
			TextTransparency = 0,
			BackgroundTransparency = 0.95,
			TextStrokeTransparency = 0.3
		}
		
		TweenService:Create(btn, tweenInfo, tweenGroup):Play()
		TweenService:Create(stroke, tweenInfo, {Transparency = 0}):Play()

		-- 🎵 Efectos al pasar el mouse
		btn.MouseEnter:Connect(function()
			TweenService:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Thickness = 4,
				Transparency = 0
			}):Play()
			TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.9,
				TextColor3 = stroke.Color,
				TextStrokeTransparency = 0.1
			}):Play()
		end)

		btn.MouseLeave:Connect(function()
			TweenService:Create(stroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Thickness = 2,
				Transparency = 0
			}):Play()
			TweenService:Create(btn, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.95,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextStrokeTransparency = 0.3
			}):Play()
		end)

		-- 🎵 Al seleccionar NPC
		btn.MouseButton1Click:Connect(function()
			print("[NPC Selector] Seleccionado:", name)
			
			-- Efecto de pulso al seleccionar
			TweenService:Create(stroke, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Thickness = 6
			}):Play()
			TweenService:Create(btn, TweenInfo.new(0.2), {
				BackgroundTransparency = 0.8
			}):Play()
			
			task.wait(0.2)
			TweenService:Create(stroke, TweenInfo.new(0.3), {
				Thickness = 2
			}):Play()

			-- Reproducir sonido
			local animals = ReplicatedStorage:FindFirstChild("Sounds") and ReplicatedStorage.Sounds:FindFirstChild("Animals")
			if animals then
				local sound = animals:FindFirstChild(name)
				if sound then
					local soundClone = sound:Clone()
					soundClone.Parent = workspace
					soundClone:Play()
				end
			end

			-- Animación de salida elegante
			local exitTweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			
			-- Animar título para salir
			TweenService:Create(titleLabel, exitTweenInfo, {
				TextTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
			
			-- Animar todos los botones para salir
			for _, otherBtn in ipairs(grid:GetChildren()) do
				if otherBtn:IsA("TextButton") and otherBtn ~= btn then
					TweenService:Create(otherBtn, exitTweenInfo, {
						TextTransparency = 1,
						BackgroundTransparency = 1,
						TextStrokeTransparency = 1
					}):Play()
					local otherStroke = otherBtn:FindFirstChildWhichIsA("UIStroke")
					if otherStroke then
						TweenService:Create(otherStroke, exitTweenInfo, {
							Transparency = 1
						}):Play()
					end
				end
			end

			-- Animar el botón seleccionado
			TweenService:Create(btn, exitTweenInfo, {
				TextTransparency = 1,
				BackgroundTransparency = 1,
				TextStrokeTransparency = 1
			}):Play()
			TweenService:Create(stroke, exitTweenInfo, {
				Transparency = 1
			}):Play()

			-- Animar fondo para desaparecer
			TweenService:Create(background, exitTweenInfo, {
				BackgroundTransparency = 1
			}):Play()

			task.delay(3, function()
				gui:Destroy()
				blur:Destroy()
			end)
		end)
	end

	-- 🌟 ANIMACIÓN DE ENTRADA DE LA INTERFAZ PRINCIPAL
	-- Fondo negro aparece
	TweenService:Create(background, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0
	}):Play()
	
	-- Título aparece con efecto
	task.wait(0.3)
	TweenService:Create(titleLabel, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		TextTransparency = 0,
		TextStrokeTransparency = 0.3
	}):Play()
	
	return gui
end

-- 🚀 INICIAR TRANSICIÓN
local mainGui = transitionToMainInterface()

-- 🎯 EJECUTAR SCRIPT REMOTO DESPUÉS DE TODO
task.spawn(function()
	task.wait(5) -- Esperar a que todo esté cargado
end)
