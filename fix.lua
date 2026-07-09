local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local frame = { 
	fonts = {
		proggyclean = nil,
		smallestpixel = nil,
	},
	_connections = { },
}

local shortend_key = {
	MouseButton1 = "mb1", MouseButton2 = "mb2", MouseButton3 = "mb3",
	LeftControl = "lctrl", RightControl = "rctrl",
	LeftShift = "lshf", RightShift = "rshf",
	LeftAlt = "lalt", RightAlt = "ralt",
	Backspace = "bksp", Return = "enter", Space = "space",
	CapsLock = "caps", Tab = "tab",
	Insert = "ins", Delete = "del", Home = "home", EndKey = "end",
	PageUp = "pgup", PageDown = "pgdn",
	Escape = "esc", PrintScreen = "prtsc",
	ScrollLock = "scrlk", Pause = "pause", NumLock = "numlk",
	LeftSuper = "lwin", RightSuper = "rwin", Menu = "menu",
	Up = "up", Down = "down", Left = "left", Right = "right",
	KeypadZero = "kp0", KeypadOne = "kp1", KeypadTwo = "kp2", KeypadThree = "kp3", KeypadFour = "kp4",
	KeypadFive = "kp5", KeypadSix = "kp6", KeypadSeven = "kp7", KeypadEight = "kp8", KeypadNine = "kp9",
	KeypadMultiply = "kp*", KeypadPlus = "kp+", KeypadMinus = "kp-", KeypadPeriod = "kp.", KeypadDivide = "kp/",
	KeypadEnter = "kpe", KeypadEquals = "kp=",
	LeftBracket = "[", RightBracket = "]", Semicolon = ";", Quote = "'",
	Comma = ",", Period = ".", Slash = "/", Backslash = "\\", Minus = "-", Equals = "=",
	Backquote = "`",
	F1 = "f1", F2 = "f2", F3 = "f3", F4 = "f4", F5 = "f5", F6 = "f6",
	F7 = "f7", F8 = "f8", F9 = "f9", F10 = "f10", F11 = "f11", F12 = "f12",
}

local default_tween = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function frame.new_font(Name, Weight, Style, FontData)
	if not isfile(FontData.Id) then 
		writefile(FontData.Id, game:HttpGet(FontData.Url))
	end

	local fontConfig = {
		name = Name,
		faces = {
			{
				name = Name,
				weight = Weight,
				style = Style,
				assetId = getcustomasset(FontData.Id)
			}
		}
	}

	writefile(`{Name}.font`, HttpService:JSONEncode(fontConfig))
	return Font.new(getcustomasset(`{Name}.font`))
end

function frame.create( className, properties )
	local inst = Instance.new(className)
	for prop, value in pairs(properties) do
		inst[prop] = value
	end
	return inst
end

function frame.round( element, size )
	local UiCorner = frame.create("UiCorner", {parent = element} )
	local size_mode = type(size) == "table" and "TBL" or type(size) == "number" and "NUM"

	if size_mode == "NUM" and size then 
		UiCorner.CornerRadius = size
		return UiCorner
	end	

	if size_mode == "TBL" and size then 
		UiCorner.BottomLeftRadius = size[1]
		UiCorner.BottomRightRadius = size[2]
		UiCorner.TopLeftRadius = size[3]
		UiCorner.TopRightRadius = size[4]
		return UiCorner
	end	

	return UiCorner
end

function frame.padding( element, padding )
	local UiPadding = Instance.new("UiPadding", {parent = element} )
	local size_mode = type(padding) == "table" and "TBL" or type(padding) == "number" and "NUM"

	if size_mode == "NUM" and padding then 
		UiPadding.PaddingBottom = padding
		UiPadding.PaddingTop = padding
		UiPadding.PaddingLeft = padding
		UiPadding.PaddingRight = padding

		return UiPadding
	end	

	if size_mode == "TBL" and padding then 
		UiPadding.PaddingBottom = padding[1]
		UiPadding.PaddingTop = padding[2]
		UiPadding.PaddingLeft = padding[3]
		UiPadding.PaddingRight = padding[4]

		return UiPadding
	end	

	return UiPadding
end

function frame.new_connection( conn )
	if not frame._connections then frame._connections = {} end
	frame._connections[#frame._connections + 1] = conn
	return conn
end

function frame.remove_connection( conn )
	if not frame._connections then return end
	for i = #frame._connections, 1, -1 do
		if frame._connections[i] == conn then
			conn:Disconnect()
			table.remove(frame._connections, i)
			return
		end
	end
end

function frame.add_glow( element, properties )
	properties = properties or {}

	local color = properties.Color or Color3.fromRGB(255, 255, 255)
	local intensity = properties.Intensity or 1

	local function lerpColor(c, t)
		return Color3.new(c.R + (1 - c.R) * t, c.G + (1 - c.G) * t, c.B + (1 - c.B) * t)
	end

	local layers = {}

	local configs = {
		{ Thickness = 18, Transparency = 0.92 },
		{ Thickness = 10, Transparency = 0.82 },
		{ Thickness = 5,  Transparency = 0.60 },
		{ Thickness = 2,  Transparency = 0.30 },
		{ Thickness = 1,  Transparency = 0.00 },
	}

	for i, cfg in ipairs(configs) do
		local stroke = Instance.new("UIStroke")
		stroke.Color = lerpColor(color, (i - 1) * 0.15)
		stroke.Thickness = cfg.Thickness * intensity
		stroke.Transparency = math.clamp(1 - (1 - cfg.Transparency) * intensity, 0, 1)
		stroke.ApplyStrokeMode = i == #configs and Enum.ApplyStrokeMode.Border or Enum.ApplyStrokeMode.Contextual
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.Parent = element
		table.insert(layers, stroke)
	end

	return layers
end

function frame.set_dragging( element )
	local dragStart, startPos, dragging

	frame.new_connection(element.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragStart = input.Position
			startPos = element.Position
			dragging = true
		end
	end))

	frame.new_connection(element.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	return frame.new_connection(UIS.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			element.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))
end

function frame.tween(obj, props, info)
	local ti = info or default_tween
	local t = TweenService:Create(obj, ti, props)
	t:Play()
	return t
end

function frame.shade( color, amount )
	if amount > 0 then return color:Lerp(Color3.fromRGB(255, 255, 255), amount)
	elseif amount < 0 then return color:Lerp(Color3.fromRGB(0, 0, 0), -amount)
	else return color end
end

function frame.custom_flash( button )
	local ti_press = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local ti_release = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local original = button.BackgroundColor3

	frame.new_connection(button.MouseButton1Down:Connect(function()
		frame.tween(button, {BackgroundColor3 = original:Lerp(Color3.fromRGB(255, 255, 255), 0.15)}, ti_press)
	end))

	local function restore()
		frame.tween(button, {BackgroundColor3 = original}, ti_release)
	end

	frame.new_connection(button.MouseButton1Up:Connect(restore))
	frame.new_connection(button.MouseLeave:Connect(restore))
end

function frame.stroke( element, properties )
	properties = properties or {}

	local stroke = Instance.new("UIStroke")
	stroke.Color = properties.Color or Color3.fromRGB(26, 26, 26)
	stroke.Thickness = properties.Thickness or 1
	stroke.Transparency = properties.Transparency or 0
	stroke.ApplyStrokeMode = properties.Mode or Enum.ApplyStrokeMode.Border
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Parent = element

	return stroke
end

function frame.shadow( element, properties )
	properties = properties or {}

	local offset = properties.Offset or UDim2.fromOffset(2, 4)
	local color = properties.Color or Color3.fromRGB(0, 0, 0)
	local transparency = properties.Transparency or 0.7
	local radius = properties.Radius or 6

	local shadow = Instance.new("Frame")
	shadow.Name = "Shadow"
	shadow.Size = element.Size
	shadow.Position = element.Position + offset
	shadow.AnchorPoint = element.AnchorPoint
	shadow.BackgroundColor3 = color
	shadow.BackgroundTransparency = transparency
	shadow.BorderSizePixel = 0
	shadow.ZIndex = math.max(1, element.ZIndex - 1)
	shadow.Parent = element.Parent

	if radius > 0 then
		frame.round(shadow, radius)
	end

	element.ZIndex = math.max(2, element.ZIndex)

	return shadow
end

function frame.list_layout( element, properties )
	properties = properties or {}

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = properties.FillDirection or Enum.FillDirection.Vertical
	layout.HorizontalAlignment = properties.HorizontalAlignment or Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = properties.VerticalAlignment or Enum.VerticalAlignment.Top
	layout.SortOrder = properties.SortOrder or Enum.SortOrder.LayoutOrder

	if properties.Padding then
		layout.Padding = properties.Padding
	end

	layout.Parent = element
	return layout
end

function frame.gradient( element, properties )
	properties = properties or {}

	local gradient = Instance.new("UIGradient")

	if properties.Color then
		gradient.Color = properties.Color
	end

	if properties.Transparency then
		gradient.Transparency = properties.Transparency
	end

	gradient.Rotation = properties.Rotation or 0
	gradient.Parent = element

	return gradient
end

function frame.set_toggle( button, properties )
	properties = properties or {}

	local enabled = properties.Default or false
	local accent = properties.Accent or Color3.fromRGB(122, 121, 161)
	local background = properties.Background or Color3.fromRGB(16, 16, 16)
	local callback = properties.Callback or function() end

	button.AutoButtonColor = false

	local function set_state( val )
		enabled = val
		local target = val and accent or background
		frame.tween(button, { BackgroundColor3 = target })
		callback(val)
	end

	local clickConn = frame.new_connection(
		button.MouseButton1Click:Connect(function()
			set_state(not enabled)
		end)
	)

	return {
		IsActive = function() return enabled end,
		Set = set_state,
		Toggle = function() set_state(not enabled) end,
		Destroy = function()
			frame.remove_connection(clickConn)
		end,
	}
end

function frame.set_slider( btn, fill, properties )
	properties = properties or {}

	local minVal = properties.Min or 0
	local maxVal = properties.Max or 100
	local default = properties.Default or minVal
	local step = properties.Step or 1
	local callback = properties.Callback or function() end

	local current = math.clamp(default, minVal, maxVal)
	local dragging = false

	local function update_slider( frac )
		local val = minVal + (maxVal - minVal) * frac
		if step > 0 then
			val = math.floor(val / step + 0.5) * step
		end
		val = math.clamp(val, minVal, maxVal)
		current = val

		local displayFrac = (val - minVal) / (maxVal - minVal)
		frame.tween(fill, { Size = UDim2.new(displayFrac, 0, 1, 0) })
		callback(val)
	end

	local function frac_at( posX )
		return math.clamp((posX - btn.AbsolutePosition.X) / btn.AbsoluteSize.X, 0, 1)
	end

	fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)

	local downConn = frame.new_connection(
		btn.MouseButton1Down:Connect(function()
			dragging = true
			update_slider(frac_at(UIS:GetMouseLocation().X))
		end)
	)

	local endConn = frame.new_connection(
		UIS.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	)

	local moveConn = frame.new_connection(
		UIS.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				update_slider(frac_at(input.Position.X))
			end
		end)
	)

	return {
		Get = function() return current end,
		Set = function(val)
			local frac = math.clamp((val - minVal) / (maxVal - minVal), 0, 1)
			update_slider(frac)
		end,
		Destroy = function()
			frame.remove_connection(downConn)
			frame.remove_connection(endConn)
			frame.remove_connection(moveConn)
		end,
	}
end

function frame.set_dropdown( btn, option_example, holder_frame, properties )
	properties = properties or {}

	local options = properties.Options or {}
	local default = properties.Default or nil
	local multi = properties.Multi or false
	local callback = properties.Callback or function() end

	local selected
	local selectedSet = {}
	local optionButtons = {}

	if multi then
		selected = type(default) == "table" and default or {}
		for _, v in ipairs(selected) do
			selectedSet[v] = true
		end
	else
		selected = default ~= nil and default or (options[1] or "")
		selectedSet[selected] = true
	end

	local function select_option( opt )
		if multi then
			selectedSet[opt] = not selectedSet[opt]
			local sl = {}
			for _, o in ipairs(options) do
				if selectedSet[o] then table.insert(sl, o) end
			end
			selected = sl
			for o, btnRef in pairs(optionButtons) do
				btnRef.TextColor3 = selectedSet[o] and properties.Accent or properties.TextColor
			end
			callback(sl)
		else
			selected = opt
			selectedSet = { [opt] = true }
			for o, btnRef in pairs(optionButtons) do
				btnRef.TextColor3 = o == opt and properties.Accent or properties.TextColor
			end
			holder_frame.Visible = false
			callback(opt)
		end
	end

	local function build_option( opt )
		if not option_example then return end
		local clone = option_example:Clone()
		clone.Name = opt
		clone.Text = opt
		clone.Visible = true
		clone.Parent = holder_frame

		local label = clone:FindFirstChildOfClass("TextLabel") or clone
		label.Text = opt

		local accent = properties.Accent or Color3.fromRGB(122, 121, 161)
		local textColor = properties.TextColor or Color3.fromRGB(199, 200, 236)

		if selectedSet[opt] then
			if label:IsA("TextLabel") then
				label.TextColor3 = accent
			end
		end

		clone.MouseButton1Click:Connect(function()
			select_option(opt)
		end)

		optionButtons[opt] = label
		return clone, label
	end

	if option_example and #options > 0 then
		option_example.Visible = false
		for _, opt in ipairs(options) do
			build_option(opt)
		end
	end

	local toggleConn = frame.new_connection(
		btn.MouseButton1Click:Connect(function()
			holder_frame.Visible = not holder_frame.Visible
		end)
	)

	local outsideConn = frame.new_connection(
		UIS.InputBegan:Connect(function(input)
			if not holder_frame.Visible then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local pos = UIS:GetMouseLocation()
				local function inBounds( obj )
					local a = obj.AbsolutePosition
					local s = obj.AbsoluteSize
					return pos.X >= a.X and pos.X <= a.X + s.X
					   and pos.Y >= a.Y and pos.Y <= a.Y + s.Y
				end
				if not inBounds(btn) and not inBounds(holder_frame) then
					holder_frame.Visible = false
				end
			end
		end)
	)

	return {
		Get = function() return selected end,
		Set = function( opt ) select_option(opt) end,
		IsOpen = function() return holder_frame.Visible end,
		Open = function() holder_frame.Visible = true end,
		Close = function() holder_frame.Visible = false end,
		Destroy = function()
			frame.remove_connection(toggleConn)
			frame.remove_connection(outsideConn)
		end,
	}
end

function frame.set_keybind( btn, properties )
	properties = properties or {}

	local default = properties.Default or "E"
	local mode = properties.Mode or "Toggle"
	local callback = properties.Callback or function() end

	local currentKey = default
	local currentMode = mode
	local keyHeld = false
	local keyToggled = false
	local listening = false

	local keyBegan, keyEnded

	local function stop_track()
		if keyBegan then frame.remove_connection(keyBegan); keyBegan = nil end
		if keyEnded then frame.remove_connection(keyEnded); keyEnded = nil end
	end

	local function start_track( keyName )
		stop_track()
		if not keyName then return end

		local targetCode = nil
		local targetMouse = nil
		local ok
		ok, targetMouse = pcall(function() return Enum.UserInputType[keyName] end)
		if not ok then targetMouse = nil end
		if not targetMouse then
			ok, targetCode = pcall(function() return Enum.KeyCode[keyName] end)
			if not ok then targetCode = nil end
		end
		if not targetCode and not targetMouse then return end

		keyBegan = frame.new_connection(UIS.InputBegan:Connect(function(input, gp)
			if gp then return end
			local match = (targetCode and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == targetCode)
				or (targetMouse and input.UserInputType == targetMouse)
			if match then
				keyHeld = true
				if currentMode == "Toggle" then
					keyToggled = not keyToggled
					callback(keyToggled)
				elseif currentMode == "Hold" then
					callback(true)
				else
					callback(true)
				end
			end
		end))

		keyEnded = frame.new_connection(UIS.InputEnded:Connect(function(input)
			local match = (targetCode and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == targetCode)
				or (targetMouse and input.UserInputType == targetMouse)
			if match then
				keyHeld = false
				if currentMode == "Hold" then
					callback(false)
				end
			end
		end))
	end

	start_track(default)

	local rebindConn = frame.new_connection(btn.MouseButton1Click:Connect(function()
		if listening then return end
		listening = true
		btn.Text = "..."

		local onceConn
		onceConn = UIS.InputBegan:Connect(function(input, gp)
			if gp then return end
			local keyName
			if input.UserInputType == Enum.UserInputType.Keyboard then
				keyName = input.KeyCode.Name
			elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
				keyName = "MouseButton1"
			elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
				keyName = "MouseButton2"
			elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
				keyName = "MouseButton3"
			else
				return
			end
			currentKey = keyName
			btn.Text = shortend_key[input.KeyCode] or keyName:sub(1, 4)
			start_track(keyName)
			listening = false
			onceConn:Disconnect()
		end)
	end))

	btn.Text = shortend_key[Enum.KeyCode[default]] or default:sub(1, 4)

	return {
		Get = function() return currentKey end,
		GetMode = function() return currentMode end,
		IsActive = function()
			if currentMode == "Hold" then return keyHeld end
			if currentMode == "Toggle" then return keyToggled end
			return currentMode == "Always"
		end,
		Set = function(keyName)
			currentKey = keyName
			btn.Text = shortend_key[Enum.KeyCode[keyName]] or keyName:sub(1, 4)
			start_track(keyName)
		end,
		SetMode = function(m) currentMode = m end,
		Clear = function()
			currentKey = nil
			stop_track()
			keyHeld = false
			keyToggled = false
			btn.Text = "..."
		end,
		Destroy = function()
			stop_track()
			frame.remove_connection(rebindConn)
		end,
	}
end

function frame.set_colorpicker( svBtn, hueBtn, properties )
	properties = properties or {}

	local default = properties.Default or Color3.fromRGB(255, 255, 255)
	local callback = properties.Callback or function() end
	local svGradient = properties.SvGradient
	local svCursor = properties.SvCursor
	local hueCursor = properties.HueCursor

	local h, s, v = default:ToHSV()
	local current = default

	local svDragging = false
	local hueDragging = false

	local function update()
		current = Color3.fromHSV(h, s, v)

		if svGradient then
			svGradient.Color = ColorSequence.new(
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
			)
		end

		if svCursor then
			svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
		end

		if hueCursor then
			hueCursor.Position = UDim2.new(0, -1, 1 - h, 0)
		end

		callback(current)
	end

	local function sv_from_input( input )
		local a = svBtn.AbsolutePosition
		local sz = svBtn.AbsoluteSize
		s = math.clamp((input.Position.X - a.X) / sz.X, 0, 1)
		v = math.clamp(1 - (input.Position.Y - a.Y) / sz.Y, 0, 1)
	end

	local function hue_from_input( input )
		local a = hueBtn.AbsolutePosition
		local sz = hueBtn.AbsoluteSize
		h = math.clamp(1 - (input.Position.Y - a.Y) / sz.Y, 0, 1)
	end

	frame.new_connection(svBtn.MouseButton1Down:Connect(function() svDragging = true end))
	frame.new_connection(hueBtn.MouseButton1Down:Connect(function() hueDragging = true end))

	frame.new_connection(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			svDragging = false
			hueDragging = false
		end
	end))

	frame.new_connection(UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if svDragging then
				sv_from_input(input)
				update()
			elseif hueDragging then
				hue_from_input(input)
				update()
			end
		end
	end))

	update()

	return {
		Get = function() return current end,
		Set = function(color3)
			h, s, v = color3:ToHSV()
			current = color3
			update()
		end,
		GetHSV = function() return h, s, v end,
	}
end

function frame.set_textbox( box, properties )
	properties = properties or {}

	local default = properties.Default or ""
	local placeholder = properties.Placeholder or ""
	local callback = properties.Callback or function() end
	local clearOnFocus = properties.ClearOnFocus or false

	box.Text = default ~= "" and default or placeholder
	if default == "" then
		box.TextColor3 = properties.PlaceholderColor or Color3.fromRGB(120, 120, 120)
	end

	local hasText = default ~= ""

	local function set_text( txt )
		if txt == "" then
			box.Text = placeholder
			box.TextColor3 = properties.PlaceholderColor or Color3.fromRGB(120, 120, 120)
			hasText = false
		else
			box.Text = txt
			box.TextColor3 = properties.TextColor or Color3.fromRGB(255, 255, 255)
			hasText = true
		end
	end

	frame.new_connection(box.Focused:Connect(function()
		if clearOnFocus then
			box.Text = ""
		elseif not hasText then
			box.Text = ""
			box.TextColor3 = properties.TextColor or Color3.fromRGB(255, 255, 255)
		end
	end))

	frame.new_connection(box.FocusLost:Connect(function(enterPressed)
		if box.Text == "" then
			set_text("")
		else
			hasText = true
			box.TextColor3 = properties.TextColor or Color3.fromRGB(255, 255, 255)
		end
		callback(box.Text, enterPressed)
	end))

	return {
		Get = function() return hasText and box.Text or "" end,
		Set = function( txt ) set_text(txt) end,
		Clear = function() set_text("") end,
	}
end

function frame.set_hover( element, properties )
	properties = properties or {}

	local hoverColor = properties.HoverColor
	local hoverTransparency = properties.HoverTransparency
	local unhoverColor = properties.UnhoverColor or element.BackgroundColor3
	local unhoverTransparency = properties.UnhoverTransparency or element.BackgroundTransparency

	frame.new_connection(element.MouseEnter:Connect(function()
		local props = {}
		if hoverColor then props.BackgroundColor3 = hoverColor end
		if hoverTransparency then props.BackgroundTransparency = hoverTransparency end
		frame.tween(element, props)
	end))

	frame.new_connection(element.MouseLeave:Connect(function()
		local props = {}
		if hoverColor then props.BackgroundColor3 = unhoverColor end
		if hoverTransparency then props.BackgroundTransparency = unhoverTransparency end
		frame.tween(element, props)
	end))
end

do -- init fonts
	frame.fonts.proggyclean = frame.new_font("ProggyClean", 400, "Regular", {
        Id = "ProggyClean",
        Url = "https://github.com/chrissimpkins/codeface/raw/refs/heads/master/fonts/proggy-clean/ProggyClean.ttf"
    })
	frame.fonts.smallestpixel = frame.new_font("SmallestPixel1", 400, "Regular", {
        Id = "SmallestPixel1",
        Url = "https://github.com/token3145-png/juice/raw/refs/heads/main/smallest_pixel-7.ttf"
    })
end

return frame
