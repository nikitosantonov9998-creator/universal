local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- =========================================================
-- НАСТРОЙКИ И БИНДЫ (CONFIG)
-- =========================================================
local Config = {
	AimbotEnabled = false,
	TriggerbotEnabled = false,
	EspEnabled = false,
	EspNew2Enabled = false,
	MouseUnlocked = false,
	
	AimbotBind = Enum.KeyCode.Z,
	TriggerbotBind = Enum.KeyCode.T,
	EspBind = Enum.KeyCode.X,
	MouseBind = Enum.KeyCode.M,
	
	ShowPlayers = true,
	ShowBots = true,
	ShowBox = true,
	ShowOutline = true,
	ShowTracers = true,
	ShowNames = true,
	ShowDistance = true,
	ShowHealth = true,
	
	PlayerColor = Color3.fromRGB(0, 220, 255),
	BotColor = Color3.fromRGB(255, 60, 90)
}

local activeESPs = {}

-- =========================================================
-- MAIN GUI & VIRTUAL CURSOR
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalScriptsUltraBlue"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local virtualCursor = Instance.new("Frame")
virtualCursor.Name = "VirtualCursor"
virtualCursor.Size = UDim2.new(0, 8, 0, 8)
virtualCursor.AnchorPoint = Vector2.new(0.5, 0.5)
virtualCursor.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
virtualCursor.BorderSizePixel = 0
virtualCursor.ZIndex = 10000
virtualCursor.Visible = false
virtualCursor.Parent = ScreenGui

local cursorCorner = Instance.new("UICorner")
cursorCorner.CornerRadius = UDim.new(1, 0)
cursorCorner.Parent = virtualCursor

local cursorStroke = Instance.new("UIStroke")
cursorStroke.Color = Color3.fromRGB(0, 0, 0)
cursorStroke.Thickness = 1.5
cursorStroke.Parent = virtualCursor

local modalButton = Instance.new("TextButton")
modalButton.Size = UDim2.new(0, 0, 0, 0)
modalButton.BackgroundTransparency = 1
modalButton.Text = ""
modalButton.Visible = false
modalButton.Modal = false
modalButton.Parent = ScreenGui

-- =========================================================
-- МАЛЕНЬКАЯ СИНЯЯ КНОПКА (TOGGLE BUTTON ~2x2 CM)
-- =========================================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "CompactToggleButton"
ToggleButton.Size = UDim2.fromOffset(48, 48)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -24)
ToggleButton.BackgroundColor3 = Color3.fromRGB(10, 16, 26)
ToggleButton.Text = "⚡\nUS"
ToggleButton.TextColor3 = Color3.fromRGB(0, 220, 255)
ToggleButton.TextSize = 12
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.AutoButtonColor = false
ToggleButton.LineHeight = 0.95
ToggleButton.ZIndex = 2000
ToggleButton.Parent = ScreenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 12)
btnCorner.Parent = ToggleButton

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(0, 180, 255)
btnStroke.Thickness = 1.8
btnStroke.Parent = ToggleButton

local btnGradient = Instance.new("UIGradient")
btnGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 24, 42)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 20))
})
btnGradient.Rotation = 45
btnGradient.Parent = ToggleButton

ToggleButton.MouseEnter:Connect(function()
	TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(54, 54)
	}):Play()
	TweenService:Create(btnStroke, TweenInfo.new(0.2), {
		Color = Color3.fromRGB(0, 255, 255)
	}):Play()
end)

ToggleButton.MouseLeave:Connect(function()
	TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(48, 48)
	}):Play()
	TweenService:Create(btnStroke, TweenInfo.new(0.2), {
		Color = Color3.fromRGB(0, 180, 255)
	}):Play()
end)

local btnDragging = false
local btnDragStart, btnStartPos, startMousePos
local dragThreshold = 5

ToggleButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		btnDragging = true
		btnDragStart = input.Position
		btnStartPos = ToggleButton.Position
		startMousePos = input.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if btnDragging then
			btnDragging = false
			local delta = (input.Position - startMousePos).Magnitude
			if delta < dragThreshold then
				MainFrame.Visible = not MainFrame.Visible
			end
		end
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if btnDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - btnDragStart
		ToggleButton.Position = UDim2.new(btnStartPos.X.Scale, btnStartPos.X.Offset + delta.X, btnStartPos.Y.Scale, btnStartPos.Y.Offset + delta.Y)
	end
end)

-- =========================================================
-- УЛУЧШЕННОЕ ГЛАВНОЕ МЕНЮ (PREMIUM NEON BLUE)
-- =========================================================
MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.fromOffset(330, 480)
MainFrame.Position = UDim2.new(0.12, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 15, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 170, 255)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(13, 19, 32)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 11, 18))
})
MainGradient.Rotation = 90
MainGradient.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(7, 10, 17)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -20, 1, 0)
TitleText.Position = UDim2.new(0, 14, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "⚡ UNIVERSAL SCRIPTS"
TitleText.TextColor3 = Color3.fromRGB(0, 220, 255)
TitleText.TextSize = 13
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(8, 8)
StatusDot.Position = UDim2.new(1, -22, 0.5, -4)
StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = TitleBar

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = StatusDot

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local Resizer = Instance.new("TextButton")
Resizer.Size = UDim2.new(0, 18, 0, 18)
Resizer.Position = UDim2.new(1, -18, 1, -18)
Resizer.BackgroundTransparency = 1
Resizer.Text = "◢"
Resizer.TextColor3 = Color3.fromRGB(0, 170, 255)
Resizer.TextSize = 14
Resizer.Font = Enum.Font.GothamBold
Resizer.ZIndex = 10
Resizer.Parent = MainFrame

local resizing = false
local startSize, startMouse

Resizer.MouseButton1Down:Connect(function()
	resizing = true
	startSize = MainFrame.Size
	startMouse = UserInputService:GetMouseLocation()
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
end)

UserInputService.InputChanged:Connect(function(input)
	if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
		local mousePos = UserInputService:GetMouseLocation()
		local delta = mousePos - startMouse
		MainFrame.Size = UDim2.new(0, math.max(290, startSize.X.Offset + delta.X), 0, math.max(250, startSize.Y.Offset + delta.Y))
	end
end)

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -16, 1, -54)
Container.Position = UDim2.new(0, 8, 0, 48)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.ScrollBarThickness = 3
Container.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
Container.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Padding = UDim.new(0, 8)
UIList.Parent = Container

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingRight = UDim.new(0, 4)
UIPadding.Parent = Container

-- =========================================================
-- УЛУЧШЕННЫЕ КОМПОНЕНТЫ УПРАВЛЕНИЯ
-- =========================================================
local function createBindButton(parent, defaultInput, onBind)
	local bindBtn = Instance.new("TextButton")
	bindBtn.Size = UDim2.new(0, 54, 0, 22)
	bindBtn.BackgroundColor3 = Color3.fromRGB(18, 27, 42)
	bindBtn.Text = typeof(defaultInput) == "EnumItem" and defaultInput.Name or "NONE"
	bindBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
	bindBtn.Font = Enum.Font.GothamBold
	bindBtn.TextSize = 11
	bindBtn.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = bindBtn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 140, 220)
	stroke.Thickness = 1
	stroke.Parent = bindBtn

	local listening = false

	bindBtn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		bindBtn.Text = "..."
		bindBtn.TextColor3 = Color3.fromRGB(255, 200, 50)

		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if input.KeyCode ~= Enum.KeyCode.Unknown then
					bindBtn.Text = input.KeyCode.Name
					bindBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
					listening = false
					conn:Disconnect()
					onBind(input.KeyCode)
				end
			elseif input.UserInputType.Name:find("Mouse") then
				local btnName = input.UserInputType.Name:gsub("MouseButton", "MB")
				bindBtn.Text = btnName
				bindBtn.TextColor3 = Color3.fromRGB(0, 210, 255)
				listening = false
				conn:Disconnect()
				onBind(input.UserInputType)
			end
		end)
	end)

	return bindBtn
end

local function createToggle(parent, name, defaultState, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 38)
	frame.BackgroundColor3 = Color3.fromRGB(16, 23, 36)
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(25, 38, 58)
	stroke.Thickness = 1
	stroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.55, 0, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(215, 235, 255)
	label.TextSize = 12
	label.Font = Enum.Font.GothamMedium
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 56, 0, 22)
	btn.Position = UDim2.new(1, -64, 0.5, -11)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.Parent = frame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 5)
	btnCorner.Parent = btn

	local state = defaultState

	local function updateState()
		if state then
			btn.BackgroundColor3 = Color3.fromRGB(0, 175, 255)
			btn.Text = "ON"
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			stroke.Color = Color3.fromRGB(0, 130, 220)
		else
			btn.BackgroundColor3 = Color3.fromRGB(26, 36, 52)
			btn.Text = "OFF"
			btn.TextColor3 = Color3.fromRGB(120, 145, 170)
			stroke.Color = Color3.fromRGB(25, 38, 58)
		end
	end

	btn.MouseButton1Click:Connect(function()
		state = not state
		updateState()
		callback(state)
	end)

	updateState()
	return {
		SetState = function(newState)
			state = newState
			updateState()
			callback(state)
		end,
		GetState = function() return state end,
		Frame = frame
	}
end

-- 1. AIMBOT
local aimToggle = createToggle(Container, "🎯 Aimbot (360°)", Config.AimbotEnabled, function(v)
	Config.AimbotEnabled = v
end)
local aimBindBtn = createBindButton(aimToggle.Frame, Config.AimbotBind, function(newBind)
	Config.AimbotBind = newBind
end)
aimBindBtn.Position = UDim2.new(1, -124, 0.5, -11)

-- 2. TRIGGERBOT
local triggerToggle = createToggle(Container, "⚡ Triggerbot (60 CPS)", Config.TriggerbotEnabled, function(v)
	Config.TriggerbotEnabled = v
end)
local triggerBindBtn = createBindButton(triggerToggle.Frame, Config.TriggerbotBind, function(newBind)
	Config.TriggerbotBind = newBind
end)
triggerBindBtn.Position = UDim2.new(1, -124, 0.5, -11)

-- 3. ESP OLD (EXPANDABLE)
local espHeaderFrame = Instance.new("Frame")
espHeaderFrame.Size = UDim2.new(1, 0, 0, 38)
espHeaderFrame.BackgroundColor3 = Color3.fromRGB(16, 23, 36)
espHeaderFrame.BorderSizePixel = 0
espHeaderFrame.Parent = Container

local espHeaderCorner = Instance.new("UICorner")
espHeaderCorner.CornerRadius = UDim.new(0, 7)
espHeaderCorner.Parent = espHeaderFrame

local espHeaderStroke = Instance.new("UIStroke")
espHeaderStroke.Color = Color3.fromRGB(25, 38, 58)
espHeaderStroke.Thickness = 1
espHeaderStroke.Parent = espHeaderFrame

local expandBtn = Instance.new("TextButton")
expandBtn.Size = UDim2.new(0, 24, 0, 24)
expandBtn.Position = UDim2.new(0, 8, 0.5, -12)
expandBtn.BackgroundColor3 = Color3.fromRGB(10, 15, 24)
expandBtn.Text = "▶"
expandBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
expandBtn.TextSize = 10
expandBtn.Font = Enum.Font.GothamBold
expandBtn.Parent = espHeaderFrame

local expandCorner = Instance.new("UICorner")
expandCorner.CornerRadius = UDim.new(0, 5)
expandCorner.Parent = expandBtn

local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(0.4, 0, 1, 0)
espTitle.Position = UDim2.new(0, 38, 0, 0)
espTitle.BackgroundTransparency = 1
espTitle.Text = "👁️ ESP Old"
espTitle.TextColor3 = Color3.fromRGB(215, 235, 255)
espTitle.TextSize = 12
espTitle.Font = Enum.Font.GothamMedium
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.Parent = espHeaderFrame

local espMainBtn = Instance.new("TextButton")
espMainBtn.Size = UDim2.new(0, 56, 0, 22)
espMainBtn.Position = UDim2.new(1, -64, 0.5, -11)
espMainBtn.BorderSizePixel = 0
espMainBtn.Font = Enum.Font.GothamBold
espMainBtn.TextSize = 11
espMainBtn.Parent = espHeaderFrame

local espMainCorner = Instance.new("UICorner")
espMainCorner.CornerRadius = UDim.new(0, 5)
espMainCorner.Parent = espMainBtn

local espBindBtn = createBindButton(espHeaderFrame, Config.EspBind, function(newBind)
	Config.EspBind = newBind
end)
espBindBtn.Position = UDim2.new(1, -124, 0.5, -11)

local espSubContainer = Instance.new("Frame")
espSubContainer.Size = UDim2.new(1, 0, 0, 0)
espSubContainer.BackgroundTransparency = 1
espSubContainer.ClipsDescendants = true
espSubContainer.Visible = false
espSubContainer.Parent = Container

local subList = Instance.new("UIListLayout")
subList.SortOrder = Enum.SortOrder.LayoutOrder
subList.Padding = UDim.new(0, 4)
subList.Parent = espSubContainer

local isEspExpanded = false
expandBtn.MouseButton1Click:Connect(function()
	isEspExpanded = not isEspExpanded
	expandBtn.Text = isEspExpanded and "▼" or "▶"
	espSubContainer.Visible = isEspExpanded
	if isEspExpanded then
		espSubContainer.Size = UDim2.new(1, 0, 0, subList.AbsoluteContentSize.Y)
	else
		espSubContainer.Size = UDim2.new(1, 0, 0, 0)
	end
end)

local function updateEspState()
	if Config.EspEnabled then
		espMainBtn.BackgroundColor3 = Color3.fromRGB(0, 175, 255)
		espMainBtn.Text = "ON"
		espMainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		espHeaderStroke.Color = Color3.fromRGB(0, 130, 220)
	else
		espMainBtn.BackgroundColor3 = Color3.fromRGB(26, 36, 52)
		espMainBtn.Text = "OFF"
		espMainBtn.TextColor3 = Color3.fromRGB(120, 145, 170)
		espHeaderStroke.Color = Color3.fromRGB(25, 38, 58)
	end
end

espMainBtn.MouseButton1Click:Connect(function()
	Config.EspEnabled = not Config.EspEnabled
	updateEspState()
end)
updateEspState()

-- Подкатегории ESP Old
createToggle(espSubContainer, "   └ Show Players", Config.ShowPlayers, function(v) Config.ShowPlayers = v end)
createToggle(espSubContainer, "   └ Show Bots", Config.ShowBots, function(v) Config.ShowBots = v end)
createToggle(espSubContainer, "   └ 2D Boxes", Config.ShowBox, function(v) Config.ShowBox = v end)
createToggle(espSubContainer, "   └ Chams (Outline)", Config.ShowOutline, function(v) Config.ShowOutline = v end)
createToggle(espSubContainer, "   └ Tracers", Config.ShowTracers, function(v) Config.ShowTracers = v end)
createToggle(espSubContainer, "   └ Names", Config.ShowNames, function(v) Config.ShowNames = v end)
createToggle(espSubContainer, "   └ Distance", Config.ShowDistance, function(v) Config.ShowDistance = v end)
createToggle(espSubContainer, "   └ Health Bar & Text", Config.ShowHealth, function(v) Config.ShowHealth = v end)

subList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	if isEspExpanded then
		espSubContainer.Size = UDim2.new(1, 0, 0, subList.AbsoluteContentSize.Y)
	end
end)

-- 4. ESP NEW 2.0 (LOADER)
local espNew2Toggle = createToggle(Container, "👁️ ESP New 2.0", Config.EspNew2Enabled, function(enabled)
	Config.EspNew2Enabled = enabled
	if enabled then
		task.spawn(function()
			pcall(function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/L5ks8/Esp/main/loader"))()
			end)
		end)
	end
end)

-- 5. UNLOCK MOUSE
local mouseToggle = createToggle(Container, "🖱️ Unlock Mouse", Config.MouseUnlocked, function(enabled)
	Config.MouseUnlocked = enabled
	modalButton.Modal = enabled
	modalButton.Visible = enabled
	if enabled then
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
	end
end)
local mouseBindBtn = createBindButton(mouseToggle.Frame, Config.MouseBind, function(newBind)
	Config.MouseBind = newBind
end)
mouseBindBtn.Position = UDim2.new(1, -124, 0.5, -11)

-- Бинд контроллер
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	local function isMatching(bound)
		if typeof(bound) == "EnumItem" then
			return input.KeyCode == bound or input.UserInputType == bound
		end
		return false
	end

	if isMatching(Config.AimbotBind) then
		aimToggle.SetState(not aimToggle.GetState())
	elseif isMatching(Config.TriggerbotBind) then
		triggerToggle.SetState(not triggerToggle.GetState())
	elseif isMatching(Config.EspBind) then
		Config.EspEnabled = not Config.EspEnabled
		updateEspState()
	elseif isMatching(Config.MouseBind) then
		mouseToggle.SetState(not mouseToggle.GetState())
	end
end)

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP_Container"
ESPFolder.Parent = ScreenGui

-- =========================================================
-- ESP & AIMBOT & TRIGGERBOT МЕХАНИКА
-- =========================================================
local function getRoot(model)
	return model.PrimaryPart
		or model:FindFirstChild("HumanoidRootPart")
		or model:FindFirstChild("UpperTorso")
		or model:FindFirstChild("Torso")
		or model:FindFirstChild("Head")
		or model:FindFirstChildWhichIsA("BasePart")
end

local function isValidTarget(model)
	if not model or not model:IsA("Model") then return false end

	local localChar = LocalPlayer.Character
	if localChar and (model == localChar or model:IsDescendantOf(localChar)) then
		return false
	end

	local plr = Players:GetPlayerFromCharacter(model)
	if plr == LocalPlayer then return false end
	if model:IsDescendantOf(Camera) then return false end

	local isPlayer = (plr ~= nil)
	if isPlayer and not Config.ShowPlayers then return false end
	if not isPlayer and not Config.ShowBots then return false end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end

	local root = getRoot(model)
	if not root then return false end

	return true
end

local function drawTracer(frame, p1, p2)
	local distance = (p2 - p1).Magnitude
	local angle = math.atan2(p2.Y - p1.Y, p2.X - p1.X)
	frame.Size = UDim2.fromOffset(distance, 2)
	frame.Position = UDim2.fromOffset((p1.X + p2.X) / 2, (p1.Y + p2.Y) / 2)
	frame.Rotation = math.deg(angle)
end

local function removeESP(model)
	if activeESPs[model] then
		if activeESPs[model].Box then activeESPs[model].Box:Destroy() end
		if activeESPs[model].Highlight then activeESPs[model].Highlight:Destroy() end
		if activeESPs[model].Tracer then activeESPs[model].Tracer:Destroy() end
		activeESPs[model] = nil
	end
end

local function clearAllESP()
	for model in pairs(activeESPs) do
		removeESP(model)
	end
end

local function createESP(model, isPlayer)
	local color = isPlayer and Config.PlayerColor or Config.BotColor

	local box = Instance.new("Frame")
	box.Name = "Box"
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 1
	box.BorderColor3 = color
	box.Parent = ESPFolder

	local boxStroke = Instance.new("UIStroke")
	boxStroke.Color = Color3.fromRGB(0, 0, 0)
	boxStroke.Thickness = 1.5
	boxStroke.Parent = box

	local label = Instance.new("TextLabel")
	label.Name = "Info"
	label.Size = UDim2.fromOffset(240, 45)
	label.Position = UDim2.new(0.5, -120, 0, -48)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextSize = 12
	label.Font = Enum.Font.GothamBold
	label.Parent = box

	local healthBg = Instance.new("Frame")
	healthBg.Name = "HealthBackground"
	healthBg.Size = UDim2.new(0, 4, 1, 0)
	healthBg.Position = UDim2.fromOffset(-8, 0)
	healthBg.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	healthBg.BorderSizePixel = 0
	healthBg.Parent = box

	local healthBar = Instance.new("Frame")
	healthBar.Name = "Health"
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthBg

	local hpText = Instance.new("TextLabel")
	hpText.Name = "HPText"
	hpText.Size = UDim2.fromOffset(50, 18)
	hpText.Position = UDim2.new(0, -32, 0.5, -9)
	hpText.Rotation = -90
	hpText.BackgroundTransparency = 1
	hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	hpText.TextStrokeTransparency = 0
	hpText.TextSize = 10
	hpText.Font = Enum.Font.GothamBold
	hpText.Parent = box

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESPHighlight"
	highlight.Adornee = model
	highlight.FillColor = color
	highlight.OutlineColor = color
	highlight.FillTransparency = 0.65
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Parent = ESPFolder

	local tracer = Instance.new("Frame")
	tracer.Name = "Tracer"
	tracer.AnchorPoint = Vector2.new(0.5, 0.5)
	tracer.BackgroundColor3 = color
	tracer.BorderSizePixel = 0
	tracer.Parent = ESPFolder

	activeESPs[model] = {
		Box = box,
		Label = label,
		HealthBg = healthBg,
		HealthBar = healthBar,
		HPText = hpText,
		Highlight = highlight,
		Tracer = tracer,
		IsPlayer = isPlayer
	}
end

local function isVisible(targetModel, targetHead)
	local localChar = LocalPlayer.Character
	if not localChar then return false end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = {localChar, targetModel, Camera}
	rayParams.IgnoreWater = true

	local origin = Camera.CFrame.Position
	local direction = targetHead.Position - origin

	local rayResult = Workspace:Raycast(origin, direction, rayParams)
	return rayResult == nil
end

local function executeClick()
	if mouse1click then
		mouse1click()
	else
		local vp = Camera.ViewportSize / 2
		VirtualInputManager:SendMouseButtonEvent(vp.X, vp.Y, 0, true, game, 0)
		VirtualInputManager:SendMouseButtonEvent(vp.X, vp.Y, 0, false, game, 0)
	end
end

-- =========================================================
-- ОСНОВНОЙ РЕНДЕР-ЦИКЛ (60 FPS)
-- =========================================================
RunService.RenderStepped:Connect(function()
	if Config.MouseUnlocked then
		local mousePos = UserInputService:GetMouseLocation()
		virtualCursor.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
		virtualCursor.Visible = true
	else
		virtualCursor.Visible = false
	end

	local currentTargets = {}

	if Config.EspEnabled or Config.AimbotEnabled or Config.TriggerbotEnabled then
		for _, object in ipairs(Workspace:GetDescendants()) do
			if object:IsA("Model") and isValidTarget(object) then
				local player = Players:GetPlayerFromCharacter(object)
				currentTargets[object] = {
					IsPlayer = (player ~= nil),
					Player = player
				}
			end
		end
	end

	-- Triggerbot (Быстрая стрельба при наведении по центру экрана)
	if Config.TriggerbotEnabled then
		local centerRay = Camera:ViewportPointToRay(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
		local rayParams = RaycastParams.new()
		rayParams.FilterType = Enum.RaycastFilterType.Exclude

		local ignoreList = {Camera}
		if LocalPlayer.Character then
			table.insert(ignoreList, LocalPlayer.Character)
		end
		rayParams.FilterDescendantsInstances = ignoreList
		rayParams.IgnoreWater = true

		local rayResult = Workspace:Raycast(centerRay.Origin, centerRay.Direction * 1000, rayParams)
		if rayResult and rayResult.Instance then
			local targetModel = rayResult.Instance:FindFirstAncestorOfClass("Model")
			if targetModel and isValidTarget(targetModel) then
				executeClick()
			end
		end
	end

	if not Config.EspEnabled then
		clearAllESP()
	else
		local localChar = LocalPlayer.Character
		local localRoot = localChar and getRoot(localChar)

		for model in pairs(activeESPs) do
			if not currentTargets[model] or not model.Parent then
				removeESP(model)
			end
		end

		for model, targetInfo in pairs(currentTargets) do
			if not activeESPs[model] then
				createESP(model, targetInfo.IsPlayer)
			end

			local data = activeESPs[model]
			local root = getRoot(model)
			if root then
				local head = model:FindFirstChild("Head") or root
				local humanoid = model:FindFirstChildOfClass("Humanoid")
				local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)

				if data.Highlight then
					data.Highlight.Enabled = Config.ShowOutline
				end

				if onScreen and rootPos.Z > 0 then
					local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
					local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
					local height = math.clamp(math.abs(headPos.Y - bottomPos.Y), 8, 1000)
					local width = height * 0.55

					data.Box.Position = UDim2.fromOffset(rootPos.X - width / 2, headPos.Y)
					data.Box.Size = UDim2.fromOffset(width, height)
					data.Box.Visible = Config.ShowBox

					if Config.ShowNames or Config.ShowDistance then
						data.Label.Visible = true
						local textStr = ""
						if Config.ShowNames then
							if targetInfo.IsPlayer and targetInfo.Player then
								textStr = targetInfo.Player.DisplayName
							else
								textStr = "BOT (" .. model.Name .. ")"
							end
						end
						if Config.ShowDistance and localRoot then
							local dist = math.floor((localRoot.Position - root.Position).Magnitude)
							textStr = textStr .. (textStr ~= "" and "\n" or "") .. "[" .. dist .. "m]"
						end
						data.Label.Text = textStr
					else
						data.Label.Visible = false
					end

					if Config.ShowHealth and humanoid and humanoid.MaxHealth > 0 then
						data.HealthBg.Visible = true
						data.HPText.Visible = true
						
						local currentHp = math.max(0, humanoid.Health)
						local healthPercent = math.clamp(currentHp / humanoid.MaxHealth, 0, 1)
						
						data.HealthBar.Size = UDim2.new(1, 0, healthPercent, 0)
						data.HealthBar.Position = UDim2.new(0, 0, 1 - healthPercent, 0)
						data.HealthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
						
						data.HPText.Text = string.format("%.1f", currentHp)
					else
						data.HealthBg.Visible = false
						data.HPText.Visible = false
					end

					if Config.ShowTracers then
						data.Tracer.Visible = true
						local screenTop = Vector2.new(Camera.ViewportSize.X / 2, 0)
						local headScreenPos = Camera:WorldToViewportPoint(head.Position)
						drawTracer(data.Tracer, screenTop, Vector2.new(headScreenPos.X, headScreenPos.Y))
					else
						data.Tracer.Visible = false
					end
				else
					data.Box.Visible = false
					data.Tracer.Visible = false
				end
			end
		end
	end

	-- Aimbot 360
	if Config.AimbotEnabled then
		local localChar = LocalPlayer.Character
		local localRoot = localChar and getRoot(localChar)

		if localRoot then
			local closestHead = nil
			local shortestDist = math.huge

			for model in pairs(currentTargets) do
				if model.Parent and isValidTarget(model) then
					local head = model:FindFirstChild("Head") or getRoot(model)
					if head and isVisible(model, head) then
						local dist = (localRoot.Position - head.Position).Magnitude
						if dist < shortestDist then
							shortestDist = dist
							closestHead = head
						end
					end
				end
			end

			if closestHead then
				Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestHead.Position)
			end
		end
	end
end)
