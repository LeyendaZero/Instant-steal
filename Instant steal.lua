-- Key System Script (Halloween Glass Edition)
-- Realistic glass blur + neon texts
-- Conserva toda la funcionalidad original

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- ======= FONDO CON EFECTO GLASS =======
local blur = Instance.new("BlurEffect")
blur.Size = 30
blur.Parent = Lighting

-- ======= CREACIÓN DE INTERFAZ =======
local function createKeyUI()
	local ScreenGui = Instance.new("ScreenGui")
	local MainFrame = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local KeyInput = Instance.new("TextBox")
	local SubmitButton = Instance.new("TextButton")
	local GetKeyButton = Instance.new("TextButton")
	local DupeButton = Instance.new("TextButton")
	local StatusLabel = Instance.new("TextLabel")

	ScreenGui.Name = "SpeedXHub"
	ScreenGui.Parent = game:GetService("CoreGui")
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Fondo principal efecto glass
	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui
	MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	MainFrame.BackgroundTransparency = 0.3
	MainFrame.BorderSizePixel = 0
	MainFrame.Position = UDim2.new(0.5, -160, 0.5, -130)
	MainFrame.Size = UDim2.new(0, 320, 0, 260)

	-- Efecto cristal
	local blurGlass = Instance.new("UIGradient")
	blurGlass.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 70, 90)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
	}
	blurGlass.Transparency = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0.4)
	}
	blurGlass.Rotation = 45
	blurGlass.Parent = MainFrame

	local corner = Instance.new("UICorner", MainFrame)
	corner.CornerRadius = UDim.new(0, 15)

	local stroke = Instance.new("UIStroke", MainFrame)
	stroke.Thickness = 2
	stroke.Color = Color3.fromRGB(0, 255, 200)
	stroke.Transparency = 0.5

	-- ======= TÍTULO =======
	Title.Name = "Title"
	Title.Parent = MainFrame
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0, 0, 0.05, 0)
	Title.Size = UDim2.new(1, 0, 0, 35)
	Title.Font = Enum.Font.GothamSemibold
	Title.Text = "Speed X Hub"
	Title.TextColor3 = Color3.fromRGB(0, 255, 200)
	Title.TextSize = 20
	Title.TextStrokeTransparency = 0.5
	local titleStroke = Instance.new("UIStroke", Title)
	titleStroke.Thickness = 1.6
	titleStroke.Color = Color3.fromRGB(0, 255, 200)
	titleStroke.Transparency = 0.3

	-- ======= INPUT DE LLAVE =======
	KeyInput.Name = "KeyInput"
	KeyInput.Parent = MainFrame
	KeyInput.BackgroundColor3 = Color3.fromRGB(40, 50, 65)
	KeyInput.BackgroundTransparency = 0.2
	KeyInput.BorderSizePixel = 0
	KeyInput.Position = UDim2.new(0.5, -130, 0.25, 0)
	KeyInput.Size = UDim2.new(0, 260, 0, 35)
	KeyInput.Font = Enum.Font.Gotham
	KeyInput.PlaceholderText = "Enter your key here..."
	KeyInput.Text = ""
	KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	KeyInput.TextSize = 14

	local inputCorner = Instance.new("UICorner", KeyInput)
	inputCorner.CornerRadius = UDim.new(0, 8)
	local inputStroke = Instance.new("UIStroke", KeyInput)
	inputStroke.Color = Color3.fromRGB(0, 255, 255)
	inputStroke.Thickness = 1.2
	inputStroke.Transparency = 0.5

	-- ======= BOTONES =======
	local function makeButton(button, text, color)
		button.BackgroundColor3 = color
		button.BackgroundTransparency = 0.2
		button.BorderSizePixel = 0
		button.Size = UDim2.new(0, 120, 0, 32)
		button.Font = Enum.Font.GothamSemibold
		button.Text = text
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.TextSize = 14
		local c = Instance.new("UICorner", button)
		c.CornerRadius = UDim.new(0, 8)
		local s = Instance.new("UIStroke", button)
		s.Thickness = 1.5
		s.Transparency = 0.5
		s.Color = color
	end

	SubmitButton.Name = "SubmitButton"
	SubmitButton.Parent = MainFrame
	SubmitButton.Position = UDim2.new(0.12, 0, 0.48, 0)
	makeButton(SubmitButton, "Submit Key", Color3.fromRGB(0, 255, 100))

	GetKeyButton.Name = "GetKeyButton"
	GetKeyButton.Parent = MainFrame
	GetKeyButton.Position = UDim2.new(0.58, 0, 0.48, 0)
	makeButton(GetKeyButton, "Get Key", Color3.fromRGB(0, 200, 255))

	DupeButton.Name = "DupeButton"
	DupeButton.Parent = MainFrame
	DupeButton.Position = UDim2.new(0.5, -60, 0.7, 0)
	makeButton(DupeButton, "(free)Dupe Brainrot", Color3.fromRGB(255, 85, 180))

	-- ======= STATUS LABEL =======
	StatusLabel.Name = "StatusLabel"
	StatusLabel.Parent = MainFrame
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Position = UDim2.new(0, 0, 0.88, 0)
	StatusLabel.Size = UDim2.new(1, 0, 0, 20)
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.Text = ""
	StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	StatusLabel.TextSize = 13
	local statusStroke = Instance.new("UIStroke", StatusLabel)
	statusStroke.Color = Color3.fromRGB(0, 255, 255)
	statusStroke.Transparency = 0.6

	-- ======= TOAST =======
	local ToastFrame = Instance.new("Frame")
	ToastFrame.Size = UDim2.new(0, 300, 0, 50)
	ToastFrame.Position = UDim2.new(0.5, -150, 0, -80)
	ToastFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	ToastFrame.BackgroundTransparency = 0.15
	ToastFrame.BorderSizePixel = 0
	ToastFrame.Visible = false
	ToastFrame.Parent = ScreenGui
	local tcorner = Instance.new("UICorner", ToastFrame)
	tcorner.CornerRadius = UDim.new(0, 10)
	local tstroke = Instance.new("UIStroke", ToastFrame)
	tstroke.Color = Color3.fromRGB(255, 255, 255)
	tstroke.Thickness = 1
	tstroke.Transparency = 0.5
	local ToastLabel = Instance.new("TextLabel")
	ToastLabel.Parent = ToastFrame
	ToastLabel.BackgroundTransparency = 1
	ToastLabel.Size = UDim2.new(1, 0, 1, 0)
	ToastLabel.Font = Enum.Font.GothamBold
	ToastLabel.Text = "✅ Link copied to clipboard!"
	ToastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ToastLabel.TextSize = 16
	local tlabelStroke = Instance.new("UIStroke", ToastLabel)
	tlabelStroke.Color = Color3.fromRGB(255, 255, 255)
	tlabelStroke.Transparency = 0.4

	return {
		ScreenGui = ScreenGui,
		KeyInput = KeyInput,
		SubmitButton = SubmitButton,
		GetKeyButton = GetKeyButton,
		DupeButton = DupeButton,
		StatusLabel = StatusLabel,
		ToastFrame = ToastFrame,
		ToastLabel = ToastLabel
	}
end

-- ======= ANIMACIONES =======
local function animateButton(button, hoverColor, normalColor)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.25), {BackgroundColor3 = hoverColor}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.25), {BackgroundColor3 = normalColor}):Play()
	end)
end

local function showToast(toastFrame, toastLabel, text, color, duration)
	duration = duration or 3
	toastLabel.Text = text
	toastFrame.BackgroundColor3 = color
	toastFrame.Visible = true
	toastFrame.Position = UDim2.new(0.5, -150, 0, -80)
	TweenService:Create(toastFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0, 20)}):Play()
	task.delay(duration, function()
		TweenService:Create(toastFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -150, 0, -80)}):Play()
		task.wait(0.5)
		toastFrame.Visible = false
	end)
end

local function verifyKey(key)
	local url = "https://luarmor.org/?verify=1&key=" .. key
	local success, response = pcall(function()
		return game:HttpGet(url)
	end)
	if success then
		if response == "valid" then
			return true, "valid"
		elseif response == "expired" then
			return false, "expired"
		elseif response == "used" then
			return false, "used"
		else
			return false, "invalid"
		end
	else
		return false, "error"
	end
end

local function runMainScript()
	local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/Estevansit0/KJJK/refs/heads/main/PusarX-loader.lua"))()
	for PlaceID, Execute in pairs(Games) do
		if PlaceID == game.PlaceId then
			loadstring(game:HttpGet(Execute))()
		end
	end
end

local function loadDupeScriptAndRemoveUI(ui)
	ui.ScreenGui:Destroy()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/LeyendaZero/Instant-steal/main/dupe.lua"))()
end

-- ======= DETECTOR DE SERVIDOR PRIVADO =======
local function isPlayerInOwnPrivateServer(ui)
	local workspace = game:GetService("Workspace")

	-- Buscar el objeto "PrivateServerMessage" dentro de la jerarquía
	local success, privateServerMessage = pcall(function()
		return workspace:WaitForChild("Map"):WaitForChild("Codes"):WaitForChild("Main")
			:WaitForChild("SurfaceGui"):WaitForChild("MainFrame"):WaitForChild("PrivateServerMessage")
	end)

	-- Si no se encuentra o no es un GuiObject, se considera público
	if not success or not privateServerMessage or not privateServerMessage:IsA("GuiObject") then
		showToast(ui.ToastFrame, ui.ToastLabel, "Solo disponible en servidores privados", Color3.fromRGB(255, 0, 85), 3)
		return false
	end

	-- Si existe pero está oculto, también se considera público
	if not privateServerMessage.Visible then
		showToast(ui.ToastFrame, ui.ToastLabel, "Solo disponible en servidores privados", Color3.fromRGB(255, 0, 85), 3)
		return false
	end

	-- Escuchar si cambia la visibilidad mientras el jugador está dentro
	privateServerMessage:GetPropertyChangedSignal("Visible"):Connect(function()
		if not privateServerMessage.Visible then
			showToast(ui.ToastFrame, ui.ToastLabel, "Solo disponible en servidores privados", Color3.fromRGB(255, 0, 85), 3)
		end
	end)

	-- Si llegó hasta aquí, es un servidor privado válido
	return true
end
-- ======= SISTEMA DE LLAVES =======
local function initKeySystem()
	local ui = createKeyUI()

	animateButton(ui.SubmitButton, Color3.fromRGB(0, 255, 140), Color3.fromRGB(0, 255, 100))
	animateButton(ui.GetKeyButton, Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 200, 255))
	animateButton(ui.DupeButton, Color3.fromRGB(255, 120, 200), Color3.fromRGB(255, 85, 180))

	ui.GetKeyButton.MouseButton1Click:Connect(function()
		local keyWebsite = "https://coomingsoon"
		pcall(function() setclipboard(keyWebsite) end)
		showToast(ui.ToastFrame, ui.ToastLabel, "✅ Link copied to clipboard!", Color3.fromRGB(0, 255, 100))
	end)

	ui.SubmitButton.MouseButton1Click:Connect(function()
		local key = ui.KeyInput.Text
		if key == "" then
			ui.StatusLabel.Text = "Please enter a key!"
			ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			return
		end
		ui.StatusLabel.Text = "Verifying key..."
		ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
		task.delay(1.5, function()
			local isValid, status = verifyKey(key)
			if isValid then
				ui.StatusLabel.Text = "Key verified successfully!"
				ui.StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
				task.delay(1, function()
					ui.ScreenGui:Destroy()
					runMainScript()
				end)
			else
				local msg = (status == "expired" and "This key has expired!")
					or (status == "used" and "This key has already been used!")
					or "Invalid key!"
				ui.StatusLabel.Text = msg
				ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
			end
		end)
	end)

ui.DupeButton.MouseButton1Click:Connect(function()local result = isPlayerInOwnPrivateServer(ui)
if not result then return end

	loadDupeScriptAndRemoveUI(ui)
	
end)

end

initKeySystem()
