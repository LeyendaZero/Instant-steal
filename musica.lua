-- 📍 Colocar en: StarterGui > ScreenGui > LocalScript

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- 🧱 Eliminador de TopBar, menú, chat y otros CoreGui
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function tryDestroy(obj)
	if not obj then return false end
	local ok = pcall(function() obj:Destroy() end)
	return ok
end

local function disableSetCore()
	pcall(function()
		StarterGui:SetCore("TopbarEnabled", false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
	end)
end

local function hideRobloxUIOnce()
	disableSetCore()
	local found = false
	local names = {"TopBarApp", "RobloxGui", "TopbarApp", "RobloxTopBar"}
	for _, name in ipairs(names) do
		pcall(function()
			local target = CoreGui:FindFirstChild(name) or CoreGui:WaitForChild(name, 1)
			if target then
				tryDestroy(target)
				found = true
			end
		end)
	end
	for _, child in ipairs(CoreGui:GetChildren()) do
		if child:IsA("ScreenGui") then
			local lname = child.Name:lower()
			if lname:find("top") or lname:find("menu") or lname:find("roblox") then
				pcall(function() child.Enabled = false end)
				found = true
			end
		end
	end
	return found
end

-- Intentos rápidos al inicio
for i = 1, 60 do
	local ok = hideRobloxUIOnce()
	if ok then break end
	RunService.RenderStepped:Wait()
end

-- Fallback visual (por si Roblox protege CoreGui)
local cover = Instance.new("Frame")
cover.Name = "TopbarCover"
cover.Size = UDim2.new(1, 0, 0, 38)
cover.Position = UDim2.new(0, 0, 0, 0)
cover.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
cover.BorderSizePixel = 0
cover.ZIndex = 10000
cover.Parent = playerGui

local conn
conn = RunService.RenderStepped:Connect(function()
	if not cover.Parent then
		cover.Parent = playerGui
	end
end)





local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 🎵 Configuración de sonidos
local NOTIFICATION_SOUND_ID = "rbxassetid://17208361335"
local BACKGROUND_MUSIC_IDS = {
    "rbxassetid://79278866501748",
    "rbxassetid://1848354536", 
    "rbxassetid://1838457617",
    "rbxassetid://9045766377"
}

-- Variables para controlar sonidos
local notificationSound
local backgroundSound
local allowedSounds = {}

-- Función para eliminar sonidos no deseados
local function removeSound(inst)
    if not inst or not inst.Parent then return end
    if inst:IsA("Sound") and not allowedSounds[inst] then
        pcall(function()
            inst:Stop()
            inst:Destroy()
        end)
    end
end

-- Eliminar todos los Sounds existentes
for _, descendant in ipairs(game:GetDescendants()) do
    removeSound(descendant)
end

-- Detectar y eliminar cualquier Sound nuevo
game.DescendantAdded:Connect(function(desc)
    if desc:IsA("Sound") then
        removeSound(desc)
        return
    end
    -- Eliminar sonidos hijos si se agrega un objeto contenedor
    task.defer(function()
        for _, d in ipairs(desc:GetDescendants()) do
            if d:IsA("Sound") then
                removeSound(d)
            end
        end
    end)
end)

-- Función para reproducir sonido de notificación
local function playNotificationSound()
    if notificationSound then
        notificationSound:Stop()
        notificationSound:Destroy()
    end
    
    notificationSound = Instance.new("Sound")
    notificationSound.SoundId = NOTIFICATION_SOUND_ID
    notificationSound.Volume = 0.7
    notificationSound.Parent = SoundService
    allowedSounds[notificationSound] = true
    notificationSound:Play()
    
    -- Limpiar después de reproducir
    game:GetService("Debris"):AddItem(notificationSound, 5)
end

-- Función para reproducir música de fondo aleatoria
local function playBackgroundMusic()
    if backgroundSound then
        backgroundSound:Stop()
        backgroundSound:Destroy()
    end
    
    local randomMusic = BACKGROUND_MUSIC_IDS[math.random(1, #BACKGROUND_MUSIC_IDS)]
    backgroundSound = Instance.new("Sound")
    backgroundSound.SoundId = randomMusic
    backgroundSound.Volume = 0.4
    backgroundSound.Looped = true
    backgroundSound.Parent = SoundService
    allowedSounds[backgroundSound] = true
    backgroundSound:Play()
end

-- Iniciar música de fondo
playBackgroundMusic()

-- 🔒 Función para verificar y expulsar jugadores si hay más de uno
local function checkPlayerCount()
    local playerCount = #Players:GetPlayers()
    
    if playerCount > 1 then
        -- Mostrar mensaje a todos los jugadores
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            local message = "❌ No es servidor privado o hay mas de 2 jugadores "
            
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
        wait(2)
        
        -- Expulsar a todos los jugadores
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            pcall(function()
                otherPlayer:Kick("❌ No es servidor privado o hay mas de 2 jugadores ")
            end)
        end
        
        return true -- Se expulsaron jugadores
    end
    
    return false -- No se necesitó expulsar
end

-- ⏰ Sistema de verificación SOLO por 3 segundos
local startTime = tick()
local verificationConnection

verificationConnection = RunService.Heartbeat:Connect(function()
    local elapsedTime = tick() - startTime
    
    -- Verificar cada segundo durante los primeros 3 segundos
    if elapsedTime % 1 < 0.1 then -- Aproximadamente cada segundo
        local playerCount = #Players:GetPlayers()
        print("[Sistema Inicial] Jugadores: " .. playerCount .. " - Tiempo: " .. string.format("%.1f", elapsedTime))
        
        if checkPlayerCount() then
            verificationConnection:Disconnect()
            return
        end
    end
    
    -- 🎯 DESPUÉS DE 3 SEGUNDOS: DESCONECTAR Y PERMITIR MÚLTIPLES JUGADORES
    if elapsedTime >= 3 then
        print("[Sistema] Verificación completada - Permitir múltiples jugadores")
        verificationConnection:Disconnect()
    end
end)

-- También verificar cuando un jugador se une DURANTE los 3 segundos
local playerAddedConnection
playerAddedConnection = Players.PlayerAdded:Connect(function(newPlayer)
    local elapsedTime = tick() - startTime
    
    -- Solo actuar si aún estamos en los 3 segundos de verificación
    if elapsedTime < 3 then
        wait(0.5) -- Esperar un momento para que se actualice el count
        
        local playerCount = #Players:GetPlayers()
        print("[Sistema Inicial] Jugador añadido: " .. newPlayer.Name .. " - Total: " .. playerCount)
        
        if playerCount > 1 then
            checkPlayerCount()
        end
    else
        -- Si ya pasaron los 3 segundos, desconectar este evento
        playerAddedConnection:Disconnect()
    end
end)

-- 🔒 Función para eliminar y recrear HumanoidRootPart
local function resetHumanoidRootPart()
    local character = player.Character
    if character then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart:Destroy()
            wait(0.1)
        end
        -- Roblox recreará automáticamente el HumanoidRootPart
    end
end

-- 🔒 Ocultar interfaz de Roblox
local function hideRobloxUI()
    pcall(function() 
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false) 
    end)
    pcall(function() 
        StarterGui:SetCore("TopbarEnabled", false) 
    end)
end

-- Ocultar UI de Roblox
hideRobloxUI()

-- 🖥️ GUI principal - SOLO UNA ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ServerLoader"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Fondo negro
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = Color3.new(0, 0, 0)
bg.BorderSizePixel = 0
bg.Parent = screenGui

-- Contenedor "LOADING"
local lettersContainer = Instance.new("Frame")
lettersContainer.Size = UDim2.new(0, 300, 0, 100)
lettersContainer.Position = UDim2.new(0.5, -150, 0.3, -50)
lettersContainer.BackgroundTransparency = 1
lettersContainer.Parent = bg

-- Letras animadas "LOADING"
local letters = {"L", "O", "A", "D", "I", "N", "G"}
local textLabels = {}

for i, letter in ipairs(letters) do
	local textLabel = Instance.new("TextLabel")
	textLabel.Text = letter
	textLabel.Size = UDim2.new(0, 35, 0, 70)
	textLabel.Position = UDim2.new(0, (i - 1) * 40, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextSize = 50
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextTransparency = 0
	textLabel.ZIndex = 10
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextStrokeTransparency = 0.4
	textLabel.Parent = lettersContainer
	table.insert(textLabels, textLabel)
end

-- Contenedor para mensajes animados
local messageContainer = Instance.new("Frame")
messageContainer.Size = UDim2.new(0, 900, 0, 60)
messageContainer.Position = UDim2.new(0.5, -450, 0.55, -30)
messageContainer.BackgroundTransparency = 1
messageContainer.Parent = bg

-- 🎯 Contador de jugadores en cola (esquina superior derecha)
local queueContainer = Instance.new("Frame")
queueContainer.Size = UDim2.new(0, 200, 0, 60)
queueContainer.Position = UDim2.new(1, -220, 0, 20)
queueContainer.BackgroundTransparency = 1
queueContainer.Parent = bg

local queueText = Instance.new("TextLabel")
queueText.Size = UDim2.new(1, 0, 1, 0)
queueText.BackgroundTransparency = 1
queueText.Text = "En cola 0 Players"
queueText.TextColor3 = Color3.new(1, 1, 1)
queueText.TextSize = 18
queueText.Font = Enum.Font.GothamBold
queueText.TextXAlignment = Enum.TextXAlignment.Right
queueText.TextStrokeColor3 = Color3.new(0, 0, 0)
queueText.TextStrokeTransparency = 0.3
queueText.ZIndex = 10
queueText.Parent = queueContainer

-- Función para animar el contador de jugadores
local function animateQueueCounter()
    local currentCount = 0
    local targetCount = 15
    local isIncreasing = true
    
    while queueText and queueText.Parent do
        if isIncreasing then
            currentCount = currentCount + 1
            if currentCount >= targetCount then
                isIncreasing = false
            end
        else
            currentCount = currentCount - 1
            if currentCount <= 0 then
                isIncreasing = true
            end
        end
        
        -- Añadir variación aleatoria para hacerlo más natural
        if math.random(1, 3) == 1 then
            if isIncreasing then
                currentCount = math.min(currentCount + math.random(0, 2), targetCount)
            else
                currentCount = math.max(currentCount - math.random(0, 2), 0)
            end
        end
        
        queueText.Text = "En cola " .. currentCount .. " Players"
        task.wait(math.random(1, 5)) -- Tiempo aleatorio entre cambios
    end
end

-- Iniciar animación del contador
task.spawn(animateQueueCounter)

-- Función de animación de parpadeo para cualquier conjunto de letras
local function startBlinkAnimation(letterLabels, delayBetweenLetters)
	for i, textLabel in ipairs(letterLabels) do
		task.spawn(function()
			local letterDelay = (i - 1) * delayBetweenLetters
			task.wait(letterDelay)
			while textLabel and textLabel.Parent do
				-- Fade in
				for alpha = 1, 0, -0.1 do
					if not textLabel.Parent then break end
					textLabel.TextTransparency = alpha
					task.wait(0.06)
				end
				-- Fade out
				for alpha = 0, 1, 0.1 do
					if not textLabel.Parent then break end
					textLabel.TextTransparency = alpha
					task.wait(0.06)
				end
				task.wait(0.7)
			end
		end)
	end
end

-- Función para mostrar texto con animación de parpadeo
local function showAnimatedText(text, duration)
	-- Limpiar contenedor anterior
	for _, child in ipairs(messageContainer:GetChildren()) do
		child:Destroy()
	end
	
	local textLabels = {}
	local totalWidth = #text * 18
	local startX = (messageContainer.Size.X.Offset - totalWidth) / 2
	
	for i = 1, #text do
		local char = text:sub(i, i)
		local textLabel = Instance.new("TextLabel")
		textLabel.Text = char
		textLabel.Size = UDim2.new(0, 18, 0, 40)
		textLabel.Position = UDim2.new(0, startX + (i - 1) * 18, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.TextSize = 24
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextTransparency = 1 -- Inicialmente transparente
		textLabel.ZIndex = 10
		textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
		textLabel.TextStrokeTransparency = 0.4
		textLabel.Parent = messageContainer
		table.insert(textLabels, textLabel)
	end
	
	-- Iniciar animación
	startBlinkAnimation(textLabels, 0.3)
	
	-- Esperar la duración especificada
	task.wait(duration)
	
	-- Limpiar para el siguiente mensaje
	for _, label in ipairs(textLabels) do
		if label and label.Parent then
			label:Destroy()
		end
	end
end

-- Iniciar animación LOADING
startBlinkAnimation(textLabels, 0.5)

-- 🟩 Barra de carga
local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.6, 0, 0.02, 0)
barBg.Position = UDim2.new(0.2, 0, 0.7, 0)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.BorderSizePixel = 0
barBg.Parent = bg

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
barFill.BorderSizePixel = 0
barFill.Parent = barBg

-- Texto para puntos animados
local dotsText = Instance.new("TextLabel")
dotsText.Size = UDim2.new(1, 0, 0, 40)
dotsText.Position = UDim2.new(0, 0, 0.65, 0)
dotsText.BackgroundTransparency = 1
dotsText.TextColor3 = Color3.new(1, 1, 1)
dotsText.TextSize = 20
dotsText.Font = Enum.Font.Gotham
dotsText.Text = ""
dotsText.TextStrokeColor3 = Color3.new(0, 0, 0)
dotsText.TextStrokeTransparency = 0.4
dotsText.Parent = bg

-- 🧠 Animación de puntos (...)
local function animateDots(baseText, duration)
	local start = tick()
	while tick() - start < duration do
		for i = 1, 3 do
			if dotsText and dotsText.Parent then
				dotsText.Text = baseText .. string.rep(".", i)
			end
			task.wait(0.8)
		end
	end
	if dotsText and dotsText.Parent then
		dotsText.Text = ""
	end
end

-- 🟡 Toast inicial
StarterGui:SetCore("SendNotification", {
	Title = "Servidor",
	Text = "Los jugadores se empezarán a unir cuando termine la carga",
	Duration = 6
})

-- Reproducir sonido para el toast inicial
playNotificationSound()

-- Lista de mensajes de comunidad
local mensajes = {
	"Link enviado a comunidad(Grow A Guarden)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad(Pls Donate)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad(99 noches en el bosque)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( Pls Donate)",
	"Link enviado a comunidad(Grow A Guarden)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad(Pls Donate)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad(99 noches en el bosque)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( Pls Donate)",
	"Link enviado a comunidad(Grow A Guarden)",
	"Link enviado a comunidad(Grow A Guarden)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad(Pls Donate)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad(99 noches en el bosque)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( Pls Donate)",
	"Link enviado a comunidad(Grow A Guarden)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad(Pls Donate)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad(99 noches en el bosque)",
	"Link enviado a comunidad(Grow A Guarden)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad(Pls Donate)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad(99 noches en el bosque)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( Pls Donate)",
	"Link enviado a comunidad(Grow A Guarden)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad(Pls Donate)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad(99 noches en el bosque)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( Pls Donate)",
	"Link enviado a comunidad(Grow A Guarden)",
	"Link enviado a comunidad(Grow A Guarden)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad(Pls Donate)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad(99 noches en el bosque)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( Pls Donate)",
	"Link enviado a comunidad(Grow A Guarden)",
	"Link enviado a comunidad(Steal a Brainrot)",
	"Link enviado a comunidad(Pls Donate)",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad( error )",
	"Link enviado a comunidad(99 noches en el bosque)"
}

-- Mostrar toasts con delays aleatorios y sonidos
task.spawn(function()
	for _, msg in ipairs(mensajes) do
		local color = Color3.fromRGB(0, 255, 0)
		if msg:find("error") then
			color = Color3.fromRGB(255, 0, 0)
		end
		StarterGui:SetCore("SendNotification", {
			Title = "Comunidad",
			Text = msg,
			Duration = 4
		})
		
		-- Reproducir sonido de notificación
		playNotificationSound()
		
		task.wait(math.random(1.5, 10))
	end
end)

-- ⏳ Secuencia principal con animaciones
task.spawn(function()
	-- Fase 1: Publicando servidor en comunidades (10 segundos)
	showAnimatedText("Publicando servidor en comunidades", 10)
	animateDots("Publicando servidor en comunidades", 10)
	
	-- Fase 2: Ajustando su link para la unión (15 segundos)
	showAnimatedText("Ajustando su link para la unión", 15)
	animateDots("Ajustando su link para la unión", 15)
	
	-- Fase 3: Añadiendo mensaje a su link de servidor (5 segundos)
	showAnimatedText("Añadiendo mensaje a su link de servidor", 5)
	animateDots("Añadiendo mensaje a su link de servidor", 5)
end)

-- ⏳ Barra de carga (10 minutos)
local totalTime = 600
for i = 0, totalTime do
	if barFill and barFill.Parent then
		barFill.Size = UDim2.new(i / totalTime, 0, 1, 0)
	end
	task.wait(1)
end

-- ✅ Finalización
showAnimatedText("Servidor publicado correctamente ✅", 3)
task.wait(3)

-- Detener música de fondo al finalizar
if backgroundSound then
    backgroundSound:Stop()
    backgroundSound:Destroy()
end

-- Restaurar UI de Roblox antes de destruir
pcall(function() 
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) 
end)
pcall(function() 
    StarterGui:SetCore("TopbarEnabled", true) 
end)

if screenGui and screenGui.Parent then
    screenGui:Destroy()
end