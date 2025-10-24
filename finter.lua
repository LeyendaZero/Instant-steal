local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer

-- 🕒 Función para obtener hora de México corregida
local function horaMexico()
    local time = os.time()
    -- México tiene UTC-6, pero verifica si está en horario de verano
    local offset = -6 * 3600
    local localTime = os.date("!*t", time + offset)
    return string.format("%04d-%02d-%02d %02d:%02d:%02d", localTime.year, localTime.month, localTime.day, localTime.hour, localTime.min, localTime.sec)
end

-- 🧠 Función mejorada para extraer datos de Brainrots
local function getBrainrotData(plot)
    local resultsMS = {}
    local resultsKS = {}
    
    if not plot then 
        print("❌ No se proporcionó plot")
        return {}, {} 
    end

    local animalPodiums = plot:FindFirstChild("AnimalPodiums")
    if not animalPodiums then 
        print("❌ No se encontró AnimalPodiums en el plot")
        return {}, {} 
    end

    print("🔍 Buscando brainrots en AnimalPodiums...")
    
    for _, folder in ipairs(animalPodiums:GetChildren()) do
        if folder:IsA("Folder") then
            local displayText, genText, mutationText = "N/A", "N/A", "N/A"

            -- Buscar en todos los descendientes
            for _, descendant in ipairs(folder:GetDescendants()) do
                if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
                    local text = descendant.Text
                    local name = string.lower(descendant.Name)
                    
                    if name:find("display") or name:find("name") then
                        displayText = text
                    elseif name:find("generation") or name:find("gen") then
                        genText = text
                    elseif name:find("mutation") or name:find("mut") then
                        mutationText = text
                    end
                end
            end

            -- Verificar si encontramos datos válidos
            local genLower = string.lower(genText or "")
            local fullText = displayText .. " - " .. genText .. " - " .. mutationText
            
            print("📝 Revisando: " .. displayText .. " | Gen: " .. genText)

            if string.find(genLower, "m/s") then
                table.insert(resultsMS, fullText)
                print("🟣 Encontrado M/s: " .. fullText)
            elseif string.find(genLower, "k/s") then
                table.insert(resultsKS, fullText)
                print("🟡 Encontrado K/s: " .. fullText)
            end
        end
    end

    print("📊")
    return resultsMS, resultsKS
end

-- 🎯 Función mejorada para encontrar el plot del jugador
local function findMyPlot()
    local plotsFolder = workspace:FindFirstChild("Plots")
    if not plotsFolder then 
        print("❌")
        return nil 
    end

    print("🔍 Buscando plot del jugador: " .. LP.Name)
    
    for _, plot in pairs(plotsFolder:GetChildren()) do
        -- Buscar diferentes nombres posibles para el sign
        local plotSign = plot:FindFirstChild("Plotsign") or plot:FindFirstChild("PlotSign") or plot:FindFirstChild("Sign")
        
        if plotSign then
            -- Buscar SurfaceGui o cualquier GUI
            local surfaceGui = plotSign:FindFirstChild("SurfaceGui") or plotSign:FindFirstChildWhichIsA("SurfaceGui")
            local textToCheck = ""
            
            if surfaceGui then
                -- Buscar Frame y TextLabel
                local frame = surfaceGui:FindFirstChild("Frame") or surfaceGui:FindFirstChildWhichIsA("Frame")
                if frame then
                    local textLabel = frame:FindFirstChild("TextLabel") or frame:FindFirstChildWhichIsA("TextLabel")
                    if textLabel then
                        textToCheck = textLabel.Text
                    end
                end
            else
                -- Buscar directamente TextLabels en el plotSign
                for _, child in ipairs(plotSign:GetChildren()) do
                    if child:IsA("TextLabel") or child:IsA("TextButton") then
                        textToCheck = child.Text
                        break
                    end
                end
            end

            -- Verificar si el texto contiene el nombre del jugador
            if string.find(string.lower(textToCheck or ""), string.lower(LP.Name)) then
                print("✅")
                return plot
            end
        end
    end
    
    print("❌ No se encontró el plot del jugador")
    return nil
end

-- 🚀 Función para enviar webhook mejorada
local function sendToWebhook(url, data, brainrotList, plotInfo, category)
    if #brainrotList == 0 then
        print("📭")
        return
    end

    local brainrotText = table.concat(brainrotList, "\n")
    if #brainrotText > 1000 then
        brainrotText = string.sub(brainrotText, 1, 1000) .. "..."
    end
    
    local categoryTitle = ""
    local categoryColor = 65280
    
    if category == "MS" then
        categoryTitle = "🟣 "
        categoryColor = 10181046  -- Morado
    elseif category == "KS" then
        categoryTitle = "🟡 "
        categoryColor = 16776960  -- Amarillo
    end

    local embedData = {
        username = "Pet Finder Bot",
        avatar_url = "https://i.imgur.com/6sYJgZv.png",
        embeds = {{
            title = categoryTitle,
            color = categoryColor,
            fields = {
                {
                    name = "👤 Usuario",
                    value = "`" .. LP.Name .. "`",
                    inline = true
                },
                {
                    name = "📊 Información del Plot",
                    value = plotInfo or "No disponible",
                    inline = false
                },
                {
                    name = "🧠 Brainrots Detectados (" .. #brainrotList .. ")",
                    value = "```" .. brainrotText .. "```",
                    inline = false
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
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time())
        }}
    }

    local success, response = pcall(function()
        local httpResponse = HttpService:RequestAsync({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(embedData)
        })
        return httpResponse
    end)

    if success then
        print("✅")
    else
        warn("❌")
    end
end

-- 🔔 Función principal mejorada
local function sendToSpecificWebhooks()
    print("🚀 Iniciando búsqueda de brainrots...")
    
    local myPlot = findMyPlot()
    if not myPlot then 
        warn("❌ No se pudo encontrar el plot del jugador")
        return 
    end
    
    local resultsMS, resultsKS = getBrainrotData(myPlot)
    local plotInfo = "Plot: " .. myPlot.Name .. " | Jugador: " .. LP.Name

    -- 📋 WEBHOOKS (reemplaza con tus URLs reales)
    local webhookMS = "https://discord.com/api/webhooks/1428688781359185953/gVafJRJvT9rJdwha1NTx3l8AUUiUNfmEJxBrIk5qsa_HDh6ZU6jA2pOHsPM-cAEQ961m"
    local webhookKS = "https://discord.com/api/webhooks/1428688781359185953/gVafJRJvT9rJdwha1NTx3l8AUUiUNfmEJxBrIk5qsa_HDh6ZU6jA2pOHsPM-cAEQ961m"

    -- Enviar resultados
    if #resultsMS > 0 then
        print("🟣 Enviando " .. #resultsMS .. " brainrots M/s...")
        sendToWebhook(webhookMS, nil, resultsMS, plotInfo, "MS")
    else
        print("📭 No se encontraron brainrots con M/s")
    end
    
    if #resultsKS > 0 then
        print("🟡 Enviando " .. #resultsKS .. " brainrots K/s...")
        sendToWebhook(webhookKS, nil, resultsKS, plotInfo, "KS")
    else
        print("📭 No se encontraron brainrots con K/s")
    end
    
    print("✅ Proceso completado")
end

-- 🔄 Función para ejecutar el scanner
local function runBrainrotScanner()
    task.spawn(function()
        sendToSpecificWebhooks()
    end)
end

-- 🎮 Ejemplo de uso:
-- Ejecuta esta función cuando quieras escanear
runBrainrotScanner()

return {
    runScanner = runBrainrotScanner,
    findMyPlot = findMyPlot,
    getBrainrotData = getBrainrotData
}
