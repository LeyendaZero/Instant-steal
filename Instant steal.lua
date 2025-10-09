-- Key System Script for Roblox (con animaciones del Halloween GUI)
-- Requiere TweenService para animaciones suaves

local TweenService = game:GetService("TweenService")

-- Crear UI
local function createKeyUI()
	local ScreenGui = Instance.new("ScreenGui")
	local MainFrame = Instance.new("Frame")
	local Title = Instance.new("TextLabel")
	local KeyInput = Instance.new("TextBox")
	local SubmitButton = Instance.new("TextButton")
	local GetKeyButton = Instance.new("TextButton")
	local StatusLabel = Instance.new("TextLabel")

	ScreenGui.Name = "Speed X Hub"
	ScreenGui.Parent = game:GetService("CoreGui")
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui
	MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	MainFrame.BorderSizePixel = 0
	MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
	MainFrame.Size = UDim2.new(0, 300, 0, 200)

	Title.Name = "Title"
	Title.Parent = MainFrame
	Title.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	Title.BorderSizePixel = 0
	Title.Size = UDim2.new(1, 0, 0, 30)
	Title.Font = Enum.Font.GothamSemibold
	Title.Text = "Script Key System"
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 16.000

	KeyInput.Name = "KeyInput"
	KeyInput.Parent = MainFrame
	KeyInput.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
	KeyInput.BorderSizePixel = 0
	KeyInput.Position = UDim2.new(0.5, -125, 0.3, 0)
	KeyInput.Size = UDim2.new(0, 250, 0, 30)
	KeyInput.Font = Enum.Font.Gotham
	KeyInput.PlaceholderText = "Enter your key here..."
	KeyInput.Text = ""
	KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	KeyInput.TextSize = 14.000

	SubmitButton.Name = "SubmitButton"
	SubmitButton.Parent = MainFrame
	SubmitButton.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
	SubmitButton.BorderSizePixel = 0
	SubmitButton.Position = UDim2.new(0.5, -60, 0.55, 0)
	SubmitButton.Size = UDim2.new(0, 120, 0, 30)
	SubmitButton.Font = Enum.Font.GothamSemibold
	SubmitButton.Text = "Submit Key"
	SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SubmitButton.TextSize = 14.000

	GetKeyButton.Name = "GetKeyButton"
	GetKeyButton.Parent = MainFrame
	GetKeyButton.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
	GetKeyButton.BorderSizePixel = 0
	GetKeyButton.Position = UDim2.new(0.5, -60, 0.75, 0)
	GetKeyButton.Size = UDim2.new(0, 120, 0, 30)
	GetKeyButton.Font = Enum.Font.GothamSemibold
	GetKeyButton.Text = "Get Key"
	GetKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	GetKeyButton.TextSize = 14.000

	StatusLabel.Name = "StatusLabel"
	StatusLabel.Parent = MainFrame
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Position = UDim2.new(0, 0, 0.9, 0)
	StatusLabel.Size = UDim2.new(1, 0, 0, 20)
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.Text = ""
	StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	StatusLabel.TextSize = 12.000

	-- Crear toast (notificación)
	local ToastFrame = Instance.new("Frame")
	ToastFrame.Size = UDim2.new(0, 300, 0, 50)
	ToastFrame.Position = UDim2.new(0.5, -150, 0, -80)
	ToastFrame.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
	ToastFrame.BorderSizePixel = 0
	ToastFrame.Visible = false
	ToastFrame.Parent = ScreenGui

	local ToastCorner = Instance.new("UICorner")
	ToastCorner.CornerRadius = UDim.new(0, 10)
	ToastCorner.Parent = ToastFrame

	local ToastLabel = Instance.new("TextLabel")
	ToastLabel.Parent = ToastFrame
	ToastLabel.BackgroundTransparency = 1
	ToastLabel.Size = UDim2.new(1, 0, 1, 0)
	ToastLabel.Font = Enum.Font.GothamBold
	ToastLabel.Text = "✅ Link copied to clipboard!"
	ToastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ToastLabel.TextSize = 16
	ToastLabel.TextXAlignment = Enum.TextXAlignment.Center

	return {
		ScreenGui = ScreenGui,
		KeyInput = KeyInput,
		SubmitButton = SubmitButton,
		GetKeyButton = GetKeyButton,
		StatusLabel = StatusLabel,
		ToastFrame = ToastFrame,
		ToastLabel = ToastLabel
	}
end

-- Animación de hover para botones
local function animateButton(button, hoverColor, normalColor)
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
	end)
end

-- Mostrar notificación (toast)
local function showToast(toastFrame)
	toastFrame.Visible = true
	toastFrame.Position = UDim2.new(0.5, -150, 0, -80)
	TweenService:Create(toastFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -150, 0, 20)}):Play()

	task.delay(3, function()
		TweenService:Create(toastFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -150, 0, -80)}):Play()
		task.wait(0.5)
		toastFrame.Visible = false
	end)
end

-- Verificar key
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

-- Inicializar sistema de llaves
local function initKeySystem()
	local ui = createKeyUI()

	-- Aplicar animaciones a botones
	animateButton(ui.SubmitButton, Color3.fromRGB(45, 210, 110), Color3.fromRGB(34, 197, 94))
	animateButton(ui.GetKeyButton, Color3.fromRGB(80, 90, 110), Color3.fromRGB(51, 65, 85))

	ui.GetKeyButton.MouseButton1Click:Connect(function()
		local keyWebsite = "https://leyenda0959.github.io/SpeedhubKeyInstantSteal/"
		setclipboard(keyWebsite)
		ui.ToastLabel.Text = "✅ Link copied to clipboard!"
		ui.ToastFrame.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
		showToast(ui.ToastFrame)
	end)

	ui.SubmitButton.MouseButton1Click:Connect(function()
		local key = ui.KeyInput.Text

		if key == "" then
			ui.StatusLabel.Text = "Please enter a key!"
			ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
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
				if status == "expired" then
					ui.StatusLabel.Text = "This key has expired!"
				elseif status == "used" then
					ui.StatusLabel.Text = "This key has already been used!"
				else
					ui.StatusLabel.Text = "Invalid key!"
				end
				ui.StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
			end
		end)
	end)
end

initKeySystem()
