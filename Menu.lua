-- UI ZL Compact Hack
-- Diseño cuadrado compacto con secciones laterales
-- Compatible con Roblox Mobile & PC

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Detectar entorno
local isMobile = UserInputService.TouchEnabled

-- Crear interfaz principal
local screenGui = Instance.new("ScreenGui")
if gethui then
    screenGui.Parent = gethui()
else
    screenGui.Parent = game:GetService("CoreGui")
end
screenGui.Name = "ZLCompactUI"
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Variables de estado
local uiOpen = false
local dragging = false
local dragStart, frameStart

-- FUNCIÓN PARA CREAR ELEMENTOS
function createElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

-- BOTÓN INICIAL ZL
local mainButton = createElement("ImageButton", {
    Parent = screenGui,
    Name = "MainButton",
    BackgroundColor3 = Color3.new(0, 0, 0),
    Position = UDim2.new(0, 20, 0, 20),
    Size = UDim2.new(0, 50, 0, 50),
    AutoButtonColor = false
})

-- Hacerlo redondo
local buttonCorner = createElement("UICorner", {
    Parent = mainButton,
    CornerRadius = UDim.new(1, 0)
})

-- Borde neón
local buttonStroke = createElement("UIStroke", {
    Parent = mainButton,
    Color = Color3.new(1, 0, 0),
    Thickness = 2
})

-- Texto ZL
local buttonText = createElement("TextLabel", {
    Parent = mainButton,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "ZL",
    TextColor3 = Color3.new(1, 0, 0),
    TextScaled = true
})

-- MENÚ PRINCIPAL COMPACTO
local mainFrame = createElement("Frame", {
    Parent = screenGui,
    Name = "MainFrame",
    BackgroundColor3 = Color3.fromRGB(20, 20, 25),
    Position = UDim2.new(0.3, 0, 0.3, 0),
    Size = UDim2.new(0, 350, 0, 250),
    Visible = false
})

-- Borde y esquinas
local frameCorner = createElement("UICorner", {
    Parent = mainFrame,
    CornerRadius = UDim.new(0, 6)
})

local frameStroke = createElement("UIStroke", {
    Parent = mainFrame,
    Color = Color3.fromRGB(80, 80, 90),
    Thickness = 1
})

-- BARRA DE TÍTULO
local titleBar = createElement("Frame", {
    Parent = mainFrame,
    Name = "TitleBar",
    BackgroundColor3 = Color3.fromRGB(15, 15, 20),
    Size = UDim2.new(1, 0, 0, 30)
})

local titleCorner = createElement("UICorner", {
    Parent = titleBar,
    CornerRadius = UDim.new(0, 6)
})

local titleText = createElement("TextLabel", {
    Parent = titleBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 0),
    Size = UDim2.new(1, -40, 1, 0),
    Font = Enum.Font.GothamBold,
    Text = "ZL HACK MENU",
    TextColor3 = Color3.fromRGB(220, 220, 220),
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left
})

-- BOTÓN CERRAR
local closeButton = createElement("TextButton", {
    Parent = titleBar,
    Name = "CloseButton",
    BackgroundColor3 = Color3.fromRGB(200, 50, 50),
    Position = UDim2.new(1, -25, 0, 5),
    Size = UDim2.new(0, 20, 0, 20),
    Font = Enum.Font.GothamBold,
    Text = "X",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 12
})

local closeCorner = createElement("UICorner", {
    Parent = closeButton,
    CornerRadius = UDim.new(0, 4)
})

-- CONTENEDOR PRINCIPAL
local container = createElement("Frame", {
    Parent = mainFrame,
    Name = "Container",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, 30),
    Size = UDim2.new(1, 0, 1, -30)
})

-- BARRA LATERAL DE SECCIONES
local sidebar = createElement("Frame", {
    Parent = container,
    Name = "Sidebar",
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    Size = UDim2.new(0, 100, 1, 0)
})

local sidebarCorner = createElement("UICorner", {
    Parent = sidebar,
    CornerRadius = UDim.new(0, 6)
})

-- CONTENIDO DE SECCIONES
local contentFrame = createElement("Frame", {
    Parent = container,
    Name = "ContentFrame",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 105, 0, 0),
    Size = UDim2.new(1, -105, 1, 0)
})

-- FUNCIÓN PARA CREAR BOTONES DE SECCIÓN
function createSectionButton(name, position, isFirst)
    local button = createElement("TextButton", {
        Parent = sidebar,
        Name = name .. "Btn",
        BackgroundColor3 = isFirst and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(30, 30, 35),
        Position = position,
        Size = UDim2.new(1, -10, 0, 30),
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 12,
        AutoButtonColor = false
    })
    
    createElement("UICorner", {
        Parent = button,
        CornerRadius = UDim.new(0, 4)
    })
    
    return button
end

-- FUNCIÓN PARA CREAR TOGGLE BUTTON
function createToggle(name, position, parent)
    local toggleFrame = createElement("Frame", {
        Parent = parent,
        Name = name .. "Toggle",
        BackgroundColor3 = Color3.fromRGB(35, 35, 40),
        Position = position,
        Size = UDim2.new(1, -10, 0, 25)
    })
    
    createElement("UICorner", {
        Parent = toggleFrame,
        CornerRadius = UDim.new(0, 4)
    })
    
    createElement("UIStroke", {
        Parent = toggleFrame,
        Color = Color3.fromRGB(60, 60, 70),
        Thickness = 1
    })
    
    local toggleText = createElement("TextLabel", {
        Parent = toggleFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 8, 0, 0),
        Size = UDim2.new(1, -35, 1, 0),
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local toggleButton = createElement("TextButton", {
        Parent = toggleFrame,
        Name = "ToggleBtn",
        BackgroundColor3 = Color3.fromRGB(80, 80, 90),
        Position = UDim2.new(1, -22, 0, 3),
        Size = UDim2.new(0, 19, 0, 19),
        Font = Enum.Font.SourceSans,
        Text = "",
        AutoButtonColor = false
    })
    
    createElement("UICorner", {
        Parent = toggleButton,
        CornerRadius = UDim.new(1, 0)
    })
    
    local toggleState = false
    
    local function updateToggle()
        if toggleState then
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(0, 200, 0),
                Position = UDim2.new(1, -22, 0, 3)
            }):Play()
        else
            TweenService:Create(toggleButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(80, 80, 90),
                Position = UDim2.new(1, -22, 0, 3)
            }):Play()
        end
    end
    
    toggleButton.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        updateToggle()
        print("[" .. parent.Name .. "] " .. name .. ": " .. (toggleState and "ON" or "OFF"))
    end)
    
    updateToggle()
    
    return toggleFrame
end

-- CREAR SECCIONES
local sections = {
    "Steal",
    "Movement", 
    "Visual",
    "Server"
}

local sectionButtons = {}
local sectionContents = {}

-- Crear botones de sección en sidebar
for i, sectionName in ipairs(sections) do
    local buttonPos = UDim2.new(0, 5, 0, (i-1) * 35 + 5)
    sectionButtons[sectionName] = createSectionButton(sectionName, buttonPos, i == 1)
    
    -- Crear frame de contenido para cada sección
    local content = createElement("ScrollingFrame", {
        Parent = contentFrame,
        Name = sectionName .. "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = i == 1,
        CanvasSize = UDim2.new(0, 0, 0, 200),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
    })
    
    sectionContents[sectionName] = content
    
    -- Agregar funciones específicas a cada sección
    local functions = {}
    
    if sectionName == "Steal" then
        functions = {"Desync", "Go to Best", "Auto laser cap", "Steal speed", "Aimbot"}
    elseif sectionName == "Movement" then
        functions = {"Fly walking", "3rd floor", "Speed", "Fly", "Fly V2"}
    elseif sectionName == "Visual" then
        functions = {"Xray", "Esp + notify"}
    elseif sectionName == "Server" then
        functions = {"Server hop"}
    end
    
    for j, funcName in ipairs(functions) do
        createToggle(funcName, UDim2.new(0, 0, 0, (j-1) * 30 + 5), content)
    end
end

-- SISTEMA DE CAMBIO DE SECCIONES
local currentSection = "Steal"

function showSection(sectionName)
    if currentSection then
        sectionContents[currentSection].Visible = false
        TweenService:Create(sectionButtons[currentSection], TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        }):Play()
    end
    
    currentSection = sectionName
    sectionContents[sectionName].Visible = true
    TweenService:Create(sectionButtons[sectionName], TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    }):Play()
end

-- Conectar botones de sección
for sectionName, button in pairs(sectionButtons) do
    button.MouseButton1Click:Connect(function()
        showSection(sectionName)
    end)
end

-- SISTEMA DE ARRASTRE
local function startDrag(input)
    dragging = true
    dragStart = input.Position
    frameStart = mainFrame.Position
    
    local connection
    connection = input.Changed:Connect(function()
        if input.UserInputState == Enum.UserInputState.End then
            dragging = false
            connection:Disconnect()
        end
    end)
end

local function updateDrag(input)
    if dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            frameStart.X.Scale, 
            frameStart.X.Offset + delta.X,
            frameStart.Y.Scale, 
            frameStart.Y.Offset + delta.Y
        )
    end
end

-- Conectar eventos de arrastre
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startDrag(input)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

-- FUNCIONES DE ANIMACIÓN
function toggleUI()
    uiOpen = not uiOpen
    
    if uiOpen then
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 350, 0, 250)
        }):Play()
    else
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween:Play()
        tween.Completed:Wait()
        mainFrame.Visible = false
    end
end

-- CONECTAR EVENTOS
mainButton.MouseButton1Click:Connect(toggleUI)
closeButton.MouseButton1Click:Connect(toggleUI)

-- MENSAJE INICIAL
print("🔓 ZL Compact UI Cargada!")
print("📱 Compatible con Mobile: " .. tostring(isMobile))
print("🎮 Usa el botón ZL para abrir/cerrar")

return screenGui
