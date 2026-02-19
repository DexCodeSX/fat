local p = game:GetService("Players")
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")
local lp = p.LocalPlayer
local pg = lp:WaitForChild("PlayerGui")

local host = ""
local connected = false

local accentPrimary = Color3.fromRGB(124, 77, 255)
local accentSecondary = Color3.fromRGB(100, 181, 246)
local accentGlow = Color3.fromRGB(149, 117, 255)
local bgDark = Color3.fromRGB(12, 12, 18)
local bgCard = Color3.fromRGB(18, 18, 28)
local bgElevated = Color3.fromRGB(24, 24, 36)
local bgInput = Color3.fromRGB(20, 20, 32)
local borderSub = Color3.fromRGB(38, 38, 55)
local txtPrimary = Color3.fromRGB(230, 230, 245)
local txtSecondary = Color3.fromRGB(140, 140, 165)
local txtMuted = Color3.fromRGB(80, 80, 100)
local successClr = Color3.fromRGB(46, 213, 115)
local warnClr = Color3.fromRGB(255, 193, 7)
local errorClr = Color3.fromRGB(255, 71, 87)

local sg = Instance.new("ScreenGui")
sg.Name = "FatUI"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = pg

local function mk(cls, props)
	local o = Instance.new(cls)
	for k, v in pairs(props) do
		if k ~= "Parent" then o[k] = v end
	end
	if props.Parent then o.Parent = props.Parent end
	return o
end

local function tw(obj, t, props, style, dir)
	ts:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props):Play()
end

local function corner(obj, r)
	mk("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = obj})
end

local function stroke(obj, c, t)
	return mk("UIStroke", {Color = c or borderSub, Thickness = t or 1, Parent = obj, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

local function grad(obj, c1, c2, rot)
	mk("UIGradient", {Color = ColorSequence.new(c1, c2), Rotation = rot or 90, Parent = obj})
end

local function hover(btn, normClr, hoverClr)
	btn.MouseEnter:Connect(function()
		tw(btn, 0.15, {BackgroundColor3 = hoverClr})
	end)
	btn.MouseLeave:Connect(function()
		tw(btn, 0.2, {BackgroundColor3 = normClr})
	end)
end

local function ripple(btn)
	btn.ClipsDescendants = true
	btn.MouseButton1Click:Connect(function()
		local circle = mk("Frame", {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.75,
			BorderSizePixel = 0,
			Parent = btn,
			ZIndex = btn.ZIndex + 1
		})
		corner(circle, 999)
		tw(circle, 0.5, {Size = UDim2.new(2.5, 0, 2.5, 0), BackgroundTransparency = 1})
		task.delay(0.55, function() circle:Destroy() end)
	end)
end

local function pressScale(btn)
	btn.MouseButton1Down:Connect(function()
		tw(btn, 0.08, {Size = UDim2.new(btn.Size.X.Scale * 0.97, btn.Size.X.Offset * 0.97, btn.Size.Y.Scale, btn.Size.Y.Offset - 1)})
	end)
	btn.MouseButton1Up:Connect(function()
		tw(btn, 0.15, {Size = btn.Size})
	end)
end

local tog = mk("TextButton", {
	Size = UDim2.new(0, 46, 0, 46),
	Position = UDim2.new(0, 20, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = accentPrimary,
	Text = "",
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = sg,
	ZIndex = 100
})
corner(tog, 14)

local togIcon = mk("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "F",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 20,
	Font = Enum.Font.GothamBlack,
	Parent = tog,
	ZIndex = 101
})

mk("UIStroke", {
	Color = accentGlow,
	Thickness = 1.5,
	Transparency = 0.3,
	Parent = tog,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border
})

do
	local dragging, dragStart, startPos
	local moved = false
	tog.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = i.Position
			startPos = tog.Position
		end
	end)
	uis.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local delta = i.Position - dragStart
			if delta.Magnitude > 4 then moved = true end
			tog.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	uis.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local main = mk("Frame", {
	Size = UDim2.new(0, 440, 0, 380),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = bgDark,
	BorderSizePixel = 0,
	Parent = sg,
	ClipsDescendants = true,
	Visible = false
})
corner(main, 14)
stroke(main, Color3.fromRGB(45, 45, 65), 1)

local accentLine = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 2),
	Position = UDim2.new(0, 0, 0, 0),
	BorderSizePixel = 0,
	Parent = main,
	ZIndex = 10
})
grad(accentLine, accentPrimary, accentSecondary, 0)

local titlebar = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 42),
	Position = UDim2.new(0, 0, 0, 2),
	BackgroundColor3 = bgCard,
	BorderSizePixel = 0,
	Parent = main,
	ZIndex = 8
})

mk("TextLabel", {
	Size = UDim2.new(0, 20, 0, 20),
	Position = UDim2.new(0, 14, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundTransparency = 1,
	Text = "F",
	TextColor3 = accentPrimary,
	TextSize = 14,
	Font = Enum.Font.GothamBlack,
	Parent = titlebar,
	ZIndex = 9
})

mk("TextLabel", {
	Size = UDim2.new(1, -80, 1, 0),
	Position = UDim2.new(0, 38, 0, 0),
	BackgroundTransparency = 1,
	Text = "fat",
	TextColor3 = txtPrimary,
	TextSize = 14,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = titlebar,
	ZIndex = 9
})

local verLbl = mk("TextLabel", {
	Size = UDim2.new(0, 60, 1, 0),
	Position = UDim2.new(0, 56, 0, 0),
	BackgroundTransparency = 1,
	Text = "v0.1.1",
	TextColor3 = txtMuted,
	TextSize = 10,
	Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = titlebar,
	ZIndex = 9
})

local minBtn = mk("TextButton", {
	Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(1, -68, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = bgElevated,
	Text = "─",
	TextColor3 = txtSecondary,
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = titlebar,
	ZIndex = 9
})
corner(minBtn, 6)
hover(minBtn, bgElevated, Color3.fromRGB(45, 45, 60))

local closeBtn = mk("TextButton", {
	Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(1, -36, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = bgElevated,
	Text = "✕",
	TextColor3 = txtSecondary,
	TextSize = 11,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = titlebar,
	ZIndex = 9
})
corner(closeBtn, 6)
hover(closeBtn, bgElevated, Color3.fromRGB(200, 50, 50))

do
	local dragging, dragStart, startPos
	titlebar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = main.Position
		end
	end)
	uis.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local delta = i.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	uis.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local tabBar = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 36),
	Position = UDim2.new(0, 0, 0, 44),
	BackgroundColor3 = Color3.fromRGB(14, 14, 22),
	BorderSizePixel = 0,
	Parent = main,
	ZIndex = 7
})

mk("Frame", {
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, 0),
	BackgroundColor3 = borderSub,
	BorderSizePixel = 0,
	Parent = tabBar,
	ZIndex = 8
})

local tabIndicator = mk("Frame", {
	Size = UDim2.new(0, 70, 0, 2),
	Position = UDim2.new(0, 14, 1, -2),
	BackgroundColor3 = accentPrimary,
	BorderSizePixel = 0,
	Parent = tabBar,
	ZIndex = 9
})
corner(tabIndicator, 1)

local tabNames = {"Settings", "Decompile", "About"}
local tabBtns = {}
local tabPages = {}
local curTab = 1

for idx, name in ipairs(tabNames) do
	local btn = mk("TextButton", {
		Size = UDim2.new(0, #name * 8 + 16, 1, 0),
		Position = UDim2.new(0, (idx == 1 and 8) or (idx == 2 and 88) or 184, 0, 0),
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = idx == 1 and accentPrimary or txtMuted,
		TextSize = 11,
		Font = Enum.Font.GothamSemibold,
		BorderSizePixel = 0,
		Parent = tabBar,
		ZIndex = 9
	})
	tabBtns[idx] = btn
end

local content = mk("Frame", {
	Size = UDim2.new(1, -28, 1, -92),
	Position = UDim2.new(0, 14, 0, 84),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Parent = main,
	ZIndex = 5,
	ClipsDescendants = true
})

local settingPage = mk("Frame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Parent = content,
	ZIndex = 5
})

mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundTransparency = 1,
	Text = "SERVER HOST",
	TextColor3 = txtMuted,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = settingPage,
	ZIndex = 6
})

local hostBox = mk("TextBox", {
	Size = UDim2.new(1, 0, 0, 38),
	Position = UDim2.new(0, 0, 0, 20),
	BackgroundColor3 = bgInput,
	Text = "",
	PlaceholderText = "your-host.ngrok-free.app",
	TextColor3 = txtPrimary,
	PlaceholderColor3 = txtMuted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = settingPage,
	ZIndex = 6
})
corner(hostBox, 10)
local hostStroke = stroke(hostBox, borderSub, 1)
mk("UIPadding", {PaddingLeft = UDim.new(0, 14), Parent = hostBox})

hostBox.Focused:Connect(function()
	tw(hostBox, 0.15, {BackgroundColor3 = Color3.fromRGB(26, 26, 40)})
	tw(hostStroke, 0.15, {Color = accentPrimary})
end)
hostBox.FocusLost:Connect(function()
	host = hostBox.Text
	tw(hostBox, 0.2, {BackgroundColor3 = bgInput})
	tw(hostStroke, 0.2, {Color = borderSub})
end)

mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 68),
	BackgroundTransparency = 1,
	Text = "PROTOCOL",
	TextColor3 = txtMuted,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = settingPage,
	ZIndex = 6
})

local protoFrame = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 32),
	Position = UDim2.new(0, 0, 0, 86),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Parent = settingPage,
	ZIndex = 6
})

local useHttps = true

local httpsBtn = mk("TextButton", {
	Size = UDim2.new(0.48, 0, 1, 0),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundColor3 = accentPrimary,
	Text = "HTTPS",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 11,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = protoFrame,
	ZIndex = 7
})
corner(httpsBtn, 8)
ripple(httpsBtn)

local httpBtn = mk("TextButton", {
	Size = UDim2.new(0.48, 0, 1, 0),
	Position = UDim2.new(0.52, 0, 0, 0),
	BackgroundColor3 = bgElevated,
	Text = "HTTP",
	TextColor3 = txtSecondary,
	TextSize = 11,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = protoFrame,
	ZIndex = 7
})
corner(httpBtn, 8)
stroke(httpBtn, borderSub, 1)
ripple(httpBtn)

httpsBtn.MouseButton1Click:Connect(function()
	useHttps = true
	tw(httpsBtn, 0.2, {BackgroundColor3 = accentPrimary})
	httpsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tw(httpBtn, 0.2, {BackgroundColor3 = bgElevated})
	httpBtn.TextColor3 = txtSecondary
end)

httpBtn.MouseButton1Click:Connect(function()
	useHttps = false
	tw(httpBtn, 0.2, {BackgroundColor3 = accentPrimary})
	httpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tw(httpsBtn, 0.2, {BackgroundColor3 = bgElevated})
	httpsBtn.TextColor3 = txtSecondary
end)

local connectBtn = mk("TextButton", {
	Size = UDim2.new(1, 0, 0, 40),
	Position = UDim2.new(0, 0, 0, 130),
	BackgroundColor3 = accentPrimary,
	Text = "Connect",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 13,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = settingPage,
	ZIndex = 6
})
corner(connectBtn, 10)
hover(connectBtn, accentPrimary, accentGlow)
ripple(connectBtn)

local settingStatus = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 34),
	Position = UDim2.new(0, 0, 0, 180),
	BackgroundColor3 = Color3.fromRGB(16, 16, 24),
	BorderSizePixel = 0,
	Parent = settingPage,
	ZIndex = 6
})
corner(settingStatus, 8)

local sDot = mk("Frame", {
	Size = UDim2.new(0, 8, 0, 8),
	Position = UDim2.new(0, 14, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = txtMuted,
	BorderSizePixel = 0,
	Parent = settingStatus,
	ZIndex = 7
})
corner(sDot, 99)

local sLbl = mk("TextLabel", {
	Size = UDim2.new(1, -34, 1, 0),
	Position = UDim2.new(0, 30, 0, 0),
	BackgroundTransparency = 1,
	Text = "Not connected",
	TextColor3 = txtMuted,
	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = settingStatus,
	ZIndex = 7
})

local function setConnStatus(txt, clr)
	sLbl.Text = txt
	sLbl.TextColor3 = clr
	tw(sDot, 0.25, {BackgroundColor3 = clr})
end

local decompPage = mk("Frame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Parent = content,
	Visible = false,
	ZIndex = 5
})

mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundTransparency = 1,
	Text = "SCRIPT PATH",
	TextColor3 = txtMuted,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = decompPage,
	ZIndex = 6
})

local pathBox = mk("TextBox", {
	Size = UDim2.new(1, 0, 0, 38),
	Position = UDim2.new(0, 0, 0, 20),
	BackgroundColor3 = bgInput,
	Text = "",
	PlaceholderText = "game.Workspace.Script",
	TextColor3 = txtPrimary,
	PlaceholderColor3 = txtMuted,
	TextSize = 12,
	Font = Enum.Font.GothamMedium,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = decompPage,
	ZIndex = 6
})
corner(pathBox, 10)
local pathStroke = stroke(pathBox, borderSub, 1)
mk("UIPadding", {PaddingLeft = UDim.new(0, 14), Parent = pathBox})

pathBox.Focused:Connect(function()
	tw(pathBox, 0.15, {BackgroundColor3 = Color3.fromRGB(26, 26, 40)})
	tw(pathStroke, 0.15, {Color = accentPrimary})
end)
pathBox.FocusLost:Connect(function()
	tw(pathBox, 0.2, {BackgroundColor3 = bgInput})
	tw(pathStroke, 0.2, {Color = borderSub})
end)

mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 68),
	BackgroundTransparency = 1,
	Text = "ACTIONS",
	TextColor3 = txtMuted,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = decompPage,
	ZIndex = 6
})

local btnRow = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 40),
	Position = UDim2.new(0, 0, 0, 86),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Parent = decompPage,
	ZIndex = 6
})

local saveBtn = mk("TextButton", {
	Size = UDim2.new(0.48, 0, 1, 0),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundColor3 = bgElevated,
	Text = "Save Instance",
	TextColor3 = txtPrimary,
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = btnRow,
	ZIndex = 7
})
corner(saveBtn, 10)
stroke(saveBtn, borderSub, 1)
hover(saveBtn, bgElevated, Color3.fromRGB(35, 35, 50))
ripple(saveBtn)

local decompBtn = mk("TextButton", {
	Size = UDim2.new(0.48, 0, 1, 0),
	Position = UDim2.new(0.52, 0, 0, 0),
	BackgroundColor3 = accentPrimary,
	Text = "Decompile",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = btnRow,
	ZIndex = 7
})
corner(decompBtn, 10)
hover(decompBtn, accentPrimary, accentGlow)
ripple(decompBtn)

local dStatusBar = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 34),
	Position = UDim2.new(0, 0, 0, 138),
	BackgroundColor3 = Color3.fromRGB(16, 16, 24),
	BorderSizePixel = 0,
	Parent = decompPage,
	ZIndex = 6
})
corner(dStatusBar, 8)

local dDot = mk("Frame", {
	Size = UDim2.new(0, 8, 0, 8),
	Position = UDim2.new(0, 14, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = txtMuted,
	BorderSizePixel = 0,
	Parent = dStatusBar,
	ZIndex = 7
})
corner(dDot, 99)

local dLbl = mk("TextLabel", {
	Size = UDim2.new(1, -34, 1, 0),
	Position = UDim2.new(0, 30, 0, 0),
	BackgroundTransparency = 1,
	Text = "Ready",
	TextColor3 = txtMuted,
	TextSize = 11,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = dStatusBar,
	ZIndex = 7
})

local function setDecompStatus(txt, clr)
	dLbl.Text = txt
	dLbl.TextColor3 = clr
	tw(dDot, 0.25, {BackgroundColor3 = clr})
end

local resultBox = mk("TextBox", {
	Size = UDim2.new(1, 0, 0, 70),
	Position = UDim2.new(0, 0, 0, 182),
	BackgroundColor3 = bgInput,
	Text = "",
	PlaceholderText = "decompiled output appears here...",
	TextColor3 = txtSecondary,
	PlaceholderColor3 = txtMuted,
	TextSize = 10,
	Font = Enum.Font.Code,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextWrapped = true,
	MultiLine = true,
	Parent = decompPage,
	ZIndex = 6
})
corner(resultBox, 8)
stroke(resultBox, borderSub, 1)
mk("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingTop = UDim.new(0, 8), PaddingRight = UDim.new(0, 10), Parent = resultBox})

local aboutPage = mk("Frame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Parent = content,
	Visible = false,
	ZIndex = 5
})

local logoFrame = mk("Frame", {
	Size = UDim2.new(0, 60, 0, 60),
	Position = UDim2.new(0.5, 0, 0, 10),
	AnchorPoint = Vector2.new(0.5, 0),
	BackgroundColor3 = accentPrimary,
	BorderSizePixel = 0,
	Parent = aboutPage,
	ZIndex = 6
})
corner(logoFrame, 16)
grad(logoFrame, accentPrimary, accentSecondary, 135)

mk("TextLabel", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "F",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 28,
	Font = Enum.Font.GothamBlack,
	Parent = logoFrame,
	ZIndex = 7
})

mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 22),
	Position = UDim2.new(0, 0, 0, 80),
	BackgroundTransparency = 1,
	Text = "fat",
	TextColor3 = txtPrimary,
	TextSize = 18,
	Font = Enum.Font.GothamBlack,
	Parent = aboutPage,
	ZIndex = 6
})

mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 104),
	BackgroundTransparency = 1,
	Text = "Lua(u) Decompiler v0.1.1",
	TextColor3 = txtMuted,
	TextSize = 11,
	Font = Enum.Font.Gotham,
	Parent = aboutPage,
	ZIndex = 6
})

mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 0, 138),
	BackgroundTransparency = 1,
	Text = "Made by bisam",
	TextColor3 = accentPrimary,
	TextSize = 13,
	Font = Enum.Font.GothamBold,
	Parent = aboutPage,
	ZIndex = 6
})

mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 60),
	Position = UDim2.new(0, 0, 0, 168),
	BackgroundTransparency = 1,
	Text = "Based on medal by\nJujhar Singh & Mathias Pedersen\n\nGPL v3 License",
	TextColor3 = txtMuted,
	TextSize = 10,
	Font = Enum.Font.Gotham,
	TextWrapped = true,
	Parent = aboutPage,
	ZIndex = 6
})

tabPages = {settingPage, decompPage, aboutPage}

local function switchTab(idx)
	curTab = idx
	for i, page in ipairs(tabPages) do
		page.Visible = (i == idx)
		tabBtns[i].TextColor3 = (i == idx) and accentPrimary or txtMuted
	end
	local btn = tabBtns[idx]
	tw(tabIndicator, 0.25, {
		Position = UDim2.new(0, btn.Position.X.Offset + 6, 1, -2),
		Size = UDim2.new(0, btn.Size.X.Offset - 12, 0, 2)
	})
end

for i, btn in ipairs(tabBtns) do
	btn.MouseButton1Click:Connect(function()
		switchTab(i)
	end)
end

local uiOpen = false

local function openUI()
	main.Visible = true
	main.Size = UDim2.new(0, 440, 0, 0)
	main.BackgroundTransparency = 0.5
	tw(main, 0.4, {Size = UDim2.new(0, 440, 0, 380), BackgroundTransparency = 0})
	uiOpen = true
end

local function closeUI()
	tw(main, 0.3, {Size = UDim2.new(0, 440, 0, 0), BackgroundTransparency = 0.5})
	task.delay(0.31, function() main.Visible = false end)
	uiOpen = false
end

closeBtn.MouseButton1Click:Connect(function()
	closeUI()
	tog.Visible = true
	tw(tog, 0.3, {BackgroundTransparency = 0})
end)

minBtn.MouseButton1Click:Connect(function()
	closeUI()
	tog.Visible = true
	tw(tog, 0.3, {BackgroundTransparency = 0})
end)

tog.MouseButton1Click:Connect(function()
	tw(tog, 0.15, {BackgroundTransparency = 1})
	task.delay(0.15, function() tog.Visible = false end)
	openUI()
end)

local pulseConn
local function startPulse(dot)
	if pulseConn then pulseConn:Disconnect() end
	local t = 0
	pulseConn = rs.Heartbeat:Connect(function(dt)
		t = t + dt
		dot.BackgroundTransparency = 0.2 + math.sin(t * 5) * 0.3
	end)
end

local function stopPulse(dot)
	if pulseConn then pulseConn:Disconnect() pulseConn = nil end
	dot.BackgroundTransparency = 0
end

local function getUrl(path)
	local proto = useHttps and "https://" or "http://"
	return proto .. host .. (path or "")
end

connectBtn.MouseButton1Click:Connect(function()
	host = hostBox.Text
	if host == "" then
		setConnStatus("Enter a host address", warnClr)
		return
	end

	setConnStatus("Connecting...", warnClr)
	startPulse(sDot)
	connectBtn.Text = "..."

	local ok, err = pcall(function()
		local r = request({Url = getUrl("/"), Method = "GET"})
		if r and r.StatusCode == 200 then
			connected = true
		else
			connected = false
		end
	end)

	stopPulse(sDot)
	connectBtn.Text = "Connect"

	if ok and connected then
		setConnStatus("Connected to " .. host, successClr)
		task.delay(0.3, function() switchTab(2) end)
	elseif not ok then
		connected = false
		setConnStatus("Failed: " .. tostring(err):sub(1, 40), errorClr)
	else
		connected = false
		setConnStatus("Failed: bad response", errorClr)
	end
end)

saveBtn.MouseButton1Click:Connect(function()
	if not connected then
		setDecompStatus("Connect first", errorClr)
		return
	end

	saveBtn.Text = "..."
	setDecompStatus("Saving instance...", warnClr)
	startPulse(dDot)

	local ok, err = pcall(function()
		getgenv().decompile = function(s)
			local b = getscriptbytecode(s)
			local e = crypt.base64encode(b)
			return request({Url = getUrl("/luau/decompile"), Method = "POST", Body = e}).Body
		end
		loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau"))()({mode = "scripts", NilInstances = true})
	end)

	stopPulse(dDot)
	saveBtn.Text = "Save Instance"

	if ok then
		setDecompStatus("Instance saved", successClr)
	else
		setDecompStatus("Error: " .. tostring(err):sub(1, 40), errorClr)
	end
end)

decompBtn.MouseButton1Click:Connect(function()
	if not connected then
		setDecompStatus("Connect first", errorClr)
		return
	end

	local pth = pathBox.Text
	if pth == "" then
		setDecompStatus("Enter a script path", warnClr)
		return
	end

	decompBtn.Text = "..."
	setDecompStatus("Decompiling...", warnClr)
	startPulse(dDot)
	resultBox.Text = ""

	local t0 = tick()
	local decompResult = nil

	local ok, err = pcall(function()
		local clean = pth
		clean = clean:gsub('game:GetService%("([^"]+)"%)', "%1")
		clean = clean:gsub("game:GetService%('([^']+)'%)", "%1")
		clean = clean:gsub("^game%.", "")
		clean = clean:gsub("^Game%.", "")

		local segs = clean:split(".")
		local cur = game
		for _, seg in ipairs(segs) do
			local child = cur:FindFirstChild(seg)
			if not child then
				child = pcall(function() return game:GetService(seg) end) and game:GetService(seg) or nil
			end
			if not child then error("not found: " .. seg) end
			cur = child
		end

		if not (cur:IsA("ModuleScript") or cur:IsA("LocalScript") or cur:IsA("Script")) then
			error("not a script")
		end

		local b = getscriptbytecode(cur)
		local e = crypt.base64encode(b)
		local r = request({Url = getUrl("/luau/decompile"), Method = "POST", Body = e})

		if r and r.Body then
			decompResult = r.Body
			resultBox.Text = r.Body:sub(1, 500)
			if setclipboard then
				setclipboard(r.Body)
			end
		end
	end)

	local took = tick() - t0

	stopPulse(dDot)
	decompBtn.Text = "Decompile"

	if ok and decompResult then
		setDecompStatus("Done - " .. string.format("%.2fs", took) .. " - copied", successClr)
		task.delay(0.3, function()
			openEditor(decompResult, pth, took)
		end)
	elseif ok then
		setDecompStatus("Done but empty response", warnClr)
	else
		setDecompStatus("Error: " .. tostring(err):sub(1, 40), errorClr)
	end
end)

main.Visible = false
tog.Visible = false
task.delay(0.1, function()
	tog.Visible = true
	tog.BackgroundTransparency = 1
	tw(tog, 0.4, {BackgroundTransparency = 0})
	task.delay(0.5, function()
		openUI()
	end)
end)

task.spawn(function()
	while true do
		if tog.Visible then
			tw(tog, 2, {BackgroundColor3 = Color3.fromRGB(100, 60, 230)})
			task.wait(2)
			tw(tog, 2, {BackgroundColor3 = accentPrimary})
			task.wait(2)
		else
			task.wait(0.5)
		end
	end
end)

local footerLbl = mk("TextLabel", {
	Size = UDim2.new(1, 0, 0, 16),
	Position = UDim2.new(0, 0, 1, -20),
	BackgroundTransparency = 1,
	Text = "Made by bisam",
	TextColor3 = txtMuted,
	TextSize = 9,
	Font = Enum.Font.Gotham,
	Parent = main,
	ZIndex = 10
})

local ICONS = {
	copy = "rbxassetid://78979572434545",
	download = "rbxassetid://134814648082393",
	x = "rbxassetid://76821953846248",
	save = "rbxassetid://126116963775616",
	file = "rbxassetid://74748492079329",
}

local editorData = {
	source = "",
	scriptPath = "",
	decompTime = 0,
}

local editorWin = mk("Frame", {
	Size = UDim2.new(0, 540, 0, 420),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = bgDark,
	BorderSizePixel = 0,
	Parent = sg,
	ClipsDescendants = true,
	Visible = false,
	ZIndex = 200
})
corner(editorWin, 14)
stroke(editorWin, Color3.fromRGB(45, 45, 65), 1)

local edAccent = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 2),
	Position = UDim2.new(0, 0, 0, 0),
	BorderSizePixel = 0,
	Parent = editorWin,
	ZIndex = 210
})
grad(edAccent, accentPrimary, accentSecondary, 0)

local edTitle = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 38),
	Position = UDim2.new(0, 0, 0, 2),
	BackgroundColor3 = bgCard,
	BorderSizePixel = 0,
	Parent = editorWin,
	ZIndex = 208
})

local edTitleIcon = mk("ImageLabel", {
	Size = UDim2.new(0, 14, 0, 14),
	Position = UDim2.new(0, 12, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundTransparency = 1,
	Image = ICONS.file,
	ImageColor3 = accentPrimary,
	Parent = edTitle,
	ZIndex = 209
})

local edTitleLbl = mk("TextLabel", {
	Size = UDim2.new(1, -120, 1, 0),
	Position = UDim2.new(0, 32, 0, 0),
	BackgroundTransparency = 1,
	Text = "Fat - Notepad",
	TextColor3 = txtPrimary,
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Parent = edTitle,
	ZIndex = 209
})

do
	local dragging, dragStart, startPos
	edTitle.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = editorWin.Position
		end
	end)
	uis.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local delta = i.Position - dragStart
			editorWin.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	uis.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

local edCopyBtn = mk("TextButton", {
	Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(1, -100, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = bgElevated,
	Text = "",
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = edTitle,
	ZIndex = 209
})
corner(edCopyBtn, 6)
hover(edCopyBtn, bgElevated, Color3.fromRGB(45, 45, 60))
mk("ImageLabel", {
	Size = UDim2.new(0, 14, 0, 14),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = ICONS.copy,
	ImageColor3 = txtSecondary,
	Parent = edCopyBtn,
	ZIndex = 210
})

local edDlBtn = mk("TextButton", {
	Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(1, -68, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = bgElevated,
	Text = "",
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = edTitle,
	ZIndex = 209
})
corner(edDlBtn, 6)
hover(edDlBtn, bgElevated, Color3.fromRGB(45, 45, 60))
mk("ImageLabel", {
	Size = UDim2.new(0, 14, 0, 14),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundTransparency = 1,
	Image = ICONS.download,
	ImageColor3 = txtSecondary,
	Parent = edDlBtn,
	ZIndex = 210
})

local edCloseBtn = mk("TextButton", {
	Size = UDim2.new(0, 28, 0, 28),
	Position = UDim2.new(1, -36, 0.5, 0),
	AnchorPoint = Vector2.new(0, 0.5),
	BackgroundColor3 = bgElevated,
	Text = "✕",
	TextColor3 = txtSecondary,
	TextSize = 11,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = edTitle,
	ZIndex = 209
})
corner(edCloseBtn, 6)
hover(edCloseBtn, bgElevated, Color3.fromRGB(200, 50, 50))

local edInfoBar = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 22),
	Position = UDim2.new(0, 0, 0, 40),
	BackgroundColor3 = Color3.fromRGB(14, 14, 22),
	BorderSizePixel = 0,
	Parent = editorWin,
	ZIndex = 207
})

local edInfoLbl = mk("TextLabel", {
	Size = UDim2.new(1, -16, 1, 0),
	Position = UDim2.new(0, 8, 0, 0),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = txtMuted,
	TextSize = 9,
	Font = Enum.Font.Code,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextTruncate = Enum.TextTruncate.AtEnd,
	Parent = edInfoBar,
	ZIndex = 208
})

local edBody = mk("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, -62),
	Position = UDim2.new(0, 0, 0, 62),
	BackgroundColor3 = Color3.fromRGB(16, 16, 24),
	BorderSizePixel = 0,
	ScrollBarThickness = 8,
	ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80),
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.XY,
	Parent = editorWin,
	ZIndex = 205,
	ScrollingDirection = Enum.ScrollingDirection.XY,
	TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
	BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
	MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
})
corner(edBody, 0)

local lineCol = mk("Frame", {
	Size = UDim2.new(0, 40, 0, 0),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundColor3 = Color3.fromRGB(14, 14, 20),
	BorderSizePixel = 0,
	Parent = edBody,
	ZIndex = 206,
	AutomaticSize = Enum.AutomaticSize.Y,
})

local codeCol = mk("Frame", {
	Size = UDim2.new(0, 0, 0, 0),
	Position = UDim2.new(0, 44, 0, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Parent = edBody,
	ZIndex = 206,
	AutomaticSize = Enum.AutomaticSize.XY,
})

mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = lineCol})
mk("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = codeCol})

local kwColors = {
	["local"] = Color3.fromRGB(198, 120, 221),
	["function"] = Color3.fromRGB(198, 120, 221),
	["end"] = Color3.fromRGB(198, 120, 221),
	["if"] = Color3.fromRGB(198, 120, 221),
	["then"] = Color3.fromRGB(198, 120, 221),
	["else"] = Color3.fromRGB(198, 120, 221),
	["elseif"] = Color3.fromRGB(198, 120, 221),
	["for"] = Color3.fromRGB(198, 120, 221),
	["while"] = Color3.fromRGB(198, 120, 221),
	["do"] = Color3.fromRGB(198, 120, 221),
	["repeat"] = Color3.fromRGB(198, 120, 221),
	["until"] = Color3.fromRGB(198, 120, 221),
	["return"] = Color3.fromRGB(198, 120, 221),
	["in"] = Color3.fromRGB(198, 120, 221),
	["not"] = Color3.fromRGB(198, 120, 221),
	["and"] = Color3.fromRGB(198, 120, 221),
	["or"] = Color3.fromRGB(198, 120, 221),
	["true"] = Color3.fromRGB(209, 154, 102),
	["false"] = Color3.fromRGB(209, 154, 102),
	["nil"] = Color3.fromRGB(209, 154, 102),
	["self"] = Color3.fromRGB(224, 108, 117),
	["break"] = Color3.fromRGB(198, 120, 221),
	["continue"] = Color3.fromRGB(198, 120, 221),
}

local numClr = Color3.fromRGB(209, 154, 102)
local strClr = Color3.fromRGB(152, 195, 121)
local commentClr = Color3.fromRGB(92, 99, 112)
local defaultClr = Color3.fromRGB(200, 200, 220)
local lineH = 16

local function colorLine(lineText)
	local parts = {}
	local i = 1
	local len = #lineText

	while i <= len do
		local ch = lineText:sub(i, i)

		if lineText:sub(i, i + 1) == "--" then
			table.insert(parts, {lineText:sub(i), commentClr})
			break
		elseif ch == '"' or ch == "'" then
			local close = ch
			local j = i + 1
			while j <= len do
				if lineText:sub(j, j) == close then j = j + 1 break end
				if lineText:sub(j, j) == "\\" then j = j + 1 end
				j = j + 1
			end
			table.insert(parts, {lineText:sub(i, j - 1), strClr})
			i = j
			continue
		elseif ch:match("%d") then
			local j = i
			while j <= len and lineText:sub(j, j):match("[%d%.xXaAbBcCdDeEfF]") do j = j + 1 end
			table.insert(parts, {lineText:sub(i, j - 1), numClr})
			i = j
			continue
		elseif ch:match("[%a_]") then
			local j = i
			while j <= len and lineText:sub(j, j):match("[%w_]") do j = j + 1 end
			local word = lineText:sub(i, j - 1)
			local clr = kwColors[word] or defaultClr
			table.insert(parts, {word, clr})
			i = j
			continue
		else
			local j = i
			while j <= len do
				local c2 = lineText:sub(j, j)
				if c2:match("[%a_%d\"']") or lineText:sub(j, j + 1) == "--" then break end
				j = j + 1
			end
			table.insert(parts, {lineText:sub(i, j - 1), defaultClr})
			i = j
			continue
		end
	end

	return parts
end

local function renderEditor(src, path, took)
	for _, c in pairs(lineCol:GetChildren()) do
		if c:IsA("TextLabel") then c:Destroy() end
	end
	for _, c in pairs(codeCol:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end

	local lines = src:split("\n")
	local header = "-- Script Path: " .. path .. "\n-- Took " .. string.format("%.2f", took) .. "s to decompile\n"
	lines = (header .. src):split("\n")

	edInfoLbl.Text = path .. "  |  " .. #lines .. " lines  |  " .. string.format("%.2fs", took)
	edTitleLbl.Text = "Fat - " .. (path:match("[^%.]+$") or path)

	local maxW = 400
	for idx, line in ipairs(lines) do
		mk("TextLabel", {
			Size = UDim2.new(1, 0, 0, lineH),
			BackgroundTransparency = 1,
			Text = tostring(idx),
			TextColor3 = Color3.fromRGB(55, 55, 75),
			TextSize = 11,
			Font = Enum.Font.Code,
			LayoutOrder = idx,
			Parent = lineCol,
			ZIndex = 207
		})

		local row = mk("Frame", {
			Size = UDim2.new(0, 0, 0, lineH),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = idx,
			Parent = codeCol,
			ZIndex = 207,
			AutomaticSize = Enum.AutomaticSize.X,
		})

		local parts = colorLine(line)
		local xOff = 0
		for _, part in ipairs(parts) do
			local txt = part[1]
			local clr = part[2]
			local w = #txt * 7
			mk("TextLabel", {
				Size = UDim2.new(0, w, 0, lineH),
				Position = UDim2.new(0, xOff, 0, 0),
				BackgroundTransparency = 1,
				Text = txt,
				TextColor3 = clr,
				TextSize = 11,
				Font = Enum.Font.Code,
				TextXAlignment = Enum.TextXAlignment.Left,
				Parent = row,
				ZIndex = 207,
				RichText = false,
			})
			xOff = xOff + w
		end
		if xOff > maxW then maxW = xOff end
	end
end

local function openEditor(src, path, took)
	editorData.source = src
	editorData.scriptPath = path
	editorData.decompTime = took
	renderEditor(src, path, took)
	editorWin.Visible = true
	editorWin.Size = UDim2.new(0, 540, 0, 0)
	editorWin.BackgroundTransparency = 0.3
	tw(editorWin, 0.35, {Size = UDim2.new(0, 540, 0, 420), BackgroundTransparency = 0})
end

local function closeEditor()
	tw(editorWin, 0.25, {Size = UDim2.new(0, 540, 0, 0), BackgroundTransparency = 0.3})
	task.delay(0.26, function() editorWin.Visible = false end)
end

edCloseBtn.MouseButton1Click:Connect(closeEditor)

edCopyBtn.MouseButton1Click:Connect(function()
	if setclipboard and editorData.source ~= "" then
		setclipboard(editorData.source)
		edTitleLbl.Text = "Copied!"
		task.delay(1.5, function()
			edTitleLbl.Text = "Fat - " .. (editorData.scriptPath:match("[^%.]+$") or editorData.scriptPath)
		end)
	end
end)

local dlPopup = mk("Frame", {
	Size = UDim2.new(0, 320, 0, 160),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = bgDark,
	BorderSizePixel = 0,
	Parent = sg,
	ClipsDescendants = true,
	Visible = false,
	ZIndex = 300
})
corner(dlPopup, 14)
stroke(dlPopup, Color3.fromRGB(45, 45, 65), 1)

local dlAccent = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 2),
	Position = UDim2.new(0, 0, 0, 0),
	BorderSizePixel = 0,
	Parent = dlPopup,
	ZIndex = 310
})
grad(dlAccent, accentPrimary, accentSecondary, 0)

mk("TextLabel", {
	Size = UDim2.new(1, -20, 0, 16),
	Position = UDim2.new(0, 10, 0, 14),
	BackgroundTransparency = 1,
	Text = "SAVE AS",
	TextColor3 = txtMuted,
	TextSize = 9,
	Font = Enum.Font.GothamBold,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = dlPopup,
	ZIndex = 301
})

local dlNameBox = mk("TextBox", {
	Size = UDim2.new(1, -20, 0, 34),
	Position = UDim2.new(0, 10, 0, 34),
	BackgroundColor3 = bgInput,
	Text = "",
	PlaceholderText = "filename.lua",
	TextColor3 = txtPrimary,
	PlaceholderColor3 = txtMuted,
	TextSize = 12,
	Font = Enum.Font.Code,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = dlPopup,
	ZIndex = 301
})
corner(dlNameBox, 8)
stroke(dlNameBox, borderSub, 1)
mk("UIPadding", {PaddingLeft = UDim.new(0, 10), Parent = dlNameBox})

local dlBtnRow = mk("Frame", {
	Size = UDim2.new(1, -20, 0, 36),
	Position = UDim2.new(0, 10, 0, 80),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Parent = dlPopup,
	ZIndex = 301
})

local dlSaveBtn = mk("TextButton", {
	Size = UDim2.new(0.48, 0, 1, 0),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundColor3 = accentPrimary,
	Text = "Save",
	TextColor3 = Color3.fromRGB(255, 255, 255),
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = dlBtnRow,
	ZIndex = 302
})
corner(dlSaveBtn, 8)
hover(dlSaveBtn, accentPrimary, accentGlow)
ripple(dlSaveBtn)

local dlCancelBtn = mk("TextButton", {
	Size = UDim2.new(0.48, 0, 1, 0),
	Position = UDim2.new(0.52, 0, 0, 0),
	BackgroundColor3 = bgElevated,
	Text = "Close",
	TextColor3 = txtPrimary,
	TextSize = 12,
	Font = Enum.Font.GothamBold,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Parent = dlBtnRow,
	ZIndex = 302
})
corner(dlCancelBtn, 8)
stroke(dlCancelBtn, borderSub, 1)
hover(dlCancelBtn, bgElevated, Color3.fromRGB(35, 35, 50))
ripple(dlCancelBtn)

local dlStatus = mk("TextLabel", {
	Size = UDim2.new(1, -20, 0, 16),
	Position = UDim2.new(0, 10, 0, 124),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = successClr,
	TextSize = 10,
	Font = Enum.Font.GothamMedium,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = dlPopup,
	ZIndex = 301
})

local function closeDlPopup()
	tw(dlPopup, 0.2, {BackgroundTransparency = 0.5})
	task.delay(0.21, function() dlPopup.Visible = false end)
end

local function openDlPopup()
	local pid = "0"
	pcall(function() pid = tostring(game.PlaceId) end)
	local shortPath = editorData.scriptPath:gsub("%.", "_")
	dlNameBox.Text = pid .. "_" .. shortPath .. ".lua"
	dlStatus.Text = ""
	dlPopup.Visible = true
	dlPopup.BackgroundTransparency = 0.5
	tw(dlPopup, 0.2, {BackgroundTransparency = 0})
end

edDlBtn.MouseButton1Click:Connect(openDlPopup)
dlCancelBtn.MouseButton1Click:Connect(closeDlPopup)

dlSaveBtn.MouseButton1Click:Connect(function()
	local fname = dlNameBox.Text
	if fname == "" then
		dlStatus.Text = "enter a filename"
		dlStatus.TextColor3 = warnClr
		return
	end
	local ok, err = pcall(function()
		if writefile then
			writefile(fname, editorData.source)
		elseif isfile then
			writefile(fname, editorData.source)
		end
	end)
	if ok then
		dlStatus.Text = "saved to workspace/" .. fname
		dlStatus.TextColor3 = successClr
		task.delay(2, closeDlPopup)
	else
		dlStatus.Text = "failed: " .. tostring(err):sub(1, 35)
		dlStatus.TextColor3 = errorClr
	end
end)
