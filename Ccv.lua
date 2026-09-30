-- =================================================================
-- Remote Spy (Delta Android - Server-Hop Fixed & Extended Logs)
-- =================================================================

local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local DeltaUI = {}
DeltaUI.Window = {}
DeltaUI.Window.__index = DeltaUI.Window

function DeltaUI.Window.new()
	local self = setmetatable({}, DeltaUI.Window)
	
	local gui = Instance.new("ScreenGui")
	gui.Name = "RemoteSpy_DeltaFix"
	gui.ResetOnSpawn = false
	
	if gethui then
		gui.Parent = gethui()
	elseif syn and syn.protect_gui then
		syn.protect_gui(gui)
		gui.Parent = CoreGui
	else
		gui.Parent = CoreGui
	end

	local frame = Instance.new("Frame")
	frame.Name = "MainFrame"
	frame.Size = UDim2.new(0, 520, 0, 320)
	frame.Position = UDim2.new(0.5, -260, 0.5, -160)
	frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Parent = gui

	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

	-- Smooth Touch Dragging
	local dragging, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	local titleBar = Instance.new("Frame", frame)
	titleBar.Size = UDim2.new(1, 0, 0, 30)
	titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	titleBar.BorderSizePixel = 0
	Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)

	local titleLabel = Instance.new("TextLabel", titleBar)
	titleLabel.Size = UDim2.new(1, -40, 1, 0)
	titleLabel.Position = UDim2.new(0, 12, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Remote Spy (Uncapped & Anti-Teleport)"
	titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 15
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local minBtn = Instance.new("TextButton", titleBar)
	minBtn.Size = UDim2.new(0, 30, 0, 24)
	minBtn.Position = UDim2.new(1, -34, 0, 3)
	minBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	minBtn.Text = "X"
	minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minBtn.Font = Enum.Font.SourceSansBold
	minBtn.TextSize = 14
	Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

	local toggleBtn = Instance.new("TextButton", gui)
	toggleBtn.Size = UDim2.new(0, 45, 0, 45)
	toggleBtn.Position = UDim2.new(0, 15, 0, 80)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	toggleBtn.Text = "SPY"
	toggleBtn.TextColor3 = Color3.fromRGB(100, 200, 255)
	toggleBtn.Font = Enum.Font.SourceSansBold
	toggleBtn.TextSize = 14
	toggleBtn.Visible = false
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
	
	minBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
		toggleBtn.Visible = true
	end)

	toggleBtn.MouseButton1Click:Connect(function()
		frame.Visible = true
		toggleBtn.Visible = false
	end)

	local content = Instance.new("Frame", frame)
	content.Size = UDim2.new(1, 0, 1, -30)
	content.Position = UDim2.new(0, 0, 0, 30)
	content.BackgroundTransparency = 1

	self.Gui = gui
	self.Frame = frame
	self.TitleLabel = titleLabel
	self.GuiElems = { Content = content }

	return self
end

local function safe_clipboard(text)
	if setclipboard then
		setclipboard(text)
	elseif toclipboard then
		toclipboard(text)
	end
end

local function safe_str(v)
	local t = typeof(v)
	if t == "Instance" then
		local parts, cur = {}, v
		while cur and cur ~= game do
			table.insert(parts, 1, cur.Name)
			cur = cur.Parent
		end
		table.insert(parts, 1, "game")
		return table.concat(parts, ".")
	elseif t == "string" then
		local s = #v > 80 and v:sub(1, 80) .. "…" or v
		return '"' .. s:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n') .. '"'
	elseif t == "table" then
		local out, n = {}, 0
		for k, val in pairs(v) do
			n = n + 1
			if n > 5 then out[n] = "…" break end
			out[n] = tostring(k) .. "=" .. safe_str(val)
		end
		return "{" .. table.concat(out, ", ") .. "}"
	else
		return tostring(v)
	end
end

local function args_str(args)
	local n = args.n or #args
	if n == 0 then return "()" end
	local out = {}
	for i = 1, n do out[i] = safe_str(args[i]) end
	return table.concat(out, ", ")
end

local function inst_path(obj)
	if not obj then return "?" end
	local parts, cur = {}, obj
	while cur and cur ~= game do
		table.insert(parts, 1, cur.Name)
		cur = cur.Parent
	end
	table.insert(parts, 1, "game")
	return table.concat(parts, ".")
end

local function main()
	local spy = {}

	local logs        = {}
	local log_frames  = {}
	local filter_text = ""
	local paused      = false
	local log_limit   = 9999 -- [UPDATED] Extended Log Limit
	local active      = false
	local hook_incoming = false -- [UPDATED] Off by default to stop auto-rejoin/server hop bugs

	local namecall_orig = nil
	local hook_cons   = {}
	local seen        = {}
	setmetatable(seen, { __mode = "k" })

	local colors = {
		out_remote   = Color3.fromRGB(100, 200, 255),
		in_remote    = Color3.fromRGB(120, 255, 120),
		out_bindable = Color3.fromRGB(255, 200, 80),
		in_bindable  = Color3.fromRGB(255, 140, 60),
	}

	local remote_classes = {
		RemoteEvent           = true,
		RemoteFunction        = true,
		UnreliableRemoteEvent = true,
		BindableEvent         = true,
		BindableFunction      = true,
	}

	local out_methods = {
		FireServer = true, InvokeServer = true,
		fireServer = true, invokeServer = true,
		Fire = true, Invoke = true,
		fire = true, invoke = true,
	}

	local in_signals = {
		RemoteEvent           = "OnClientEvent",
		UnreliableRemoteEvent = "OnClientEvent",
		BindableEvent         = "Event",
	}

	local window, scroll_frame, status_label

	local function color_for(dir, class_name)
		local is_bind = class_name == "BindableEvent" or class_name == "BindableFunction"
		if dir == "out" then
			return is_bind and colors.out_bindable or colors.out_remote
		else
			return is_bind and colors.in_bindable or colors.in_remote
		end
	end

	local function matches(entry)
		if filter_text == "" then return true end
		local low = filter_text:lower()
		return entry.path:lower():find(low, 1, true)
			or entry.method:lower():find(low, 1, true)
			or entry.args:lower():find(low, 1, true)
	end

	local function push_row(entry)
		if not scroll_frame then return end
		local col = color_for(entry.dir, entry.class)

		local row = Instance.new("Frame")
		row.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
		row.BorderSizePixel  = 0
		row.Size             = UDim2.new(1, -4, 0, 42)
		row.ClipsDescendants = true
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

		local badge = Instance.new("Frame", row)
		badge.BackgroundColor3 = col
		badge.BorderSizePixel  = 0
		badge.Size             = UDim2.new(0, 4, 1, 0)

		local dl = Instance.new("TextLabel", row)
		dl.BackgroundTransparency = 1
		dl.Position  = UDim2.new(0, 10, 0, 2)
		dl.Size      = UDim2.new(0, 180, 0, 18)
		dl.Font      = Enum.Font.SourceSansBold
		dl.TextSize  = 13
		dl.TextColor3 = col
		dl.TextXAlignment = Enum.TextXAlignment.Left
		dl.Text = (entry.dir == "out" and "[OUT] " or "[IN] ") .. entry.class

		local ml = Instance.new("TextLabel", row)
		ml.BackgroundTransparency = 1
		ml.Position  = UDim2.new(0, 190, 0, 2)
		ml.Size      = UDim2.new(1, -200, 0, 18)
		ml.Font      = Enum.Font.Code
		ml.TextSize  = 12
		ml.TextColor3 = Color3.fromRGB(220, 220, 220)
		ml.TextXAlignment = Enum.TextXAlignment.Left
		ml.Text = ":" .. entry.method .. "()"

		local pl = Instance.new("TextLabel", row)
		pl.BackgroundTransparency = 1
		pl.Position  = UDim2.new(0, 10, 0, 22)
		pl.Size      = UDim2.new(0.55, -10, 0, 16)
		pl.Font      = Enum.Font.Code
		pl.TextSize  = 11
		pl.TextColor3 = Color3.fromRGB(160, 160, 160)
		pl.TextXAlignment = Enum.TextXAlignment.Left
		pl.TextTruncate = Enum.TextTruncate.AtEnd
		pl.Text = entry.path

		local al = Instance.new("TextLabel", row)
		al.BackgroundTransparency = 1
		al.Position  = UDim2.new(0.55, 0, 0, 22)
		al.Size      = UDim2.new(0.45, -8, 0, 16)
		al.Font      = Enum.Font.Code
		al.TextSize  = 11
		al.TextColor3 = Color3.fromRGB(210, 210, 140)
		al.TextXAlignment = Enum.TextXAlignment.Right
		al.TextTruncate = Enum.TextTruncate.AtEnd
		al.Text = entry.args

		row.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
				row.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
				safe_clipboard(entry.path)
			end
		end)
		row.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
				row.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
			end
		end)

		row.LayoutOrder = #log_frames + 1
		row.Parent = scroll_frame
		table.insert(log_frames, row)
	end

	local function add_log(dir, inst, method, raw_args)
		if not active or paused then return end

		local path = inst_path(inst)
		
		-- [ANTI-TELEPORT FILTER] Ignore Teleport/Rejoin Related Remotes
		if path:find("Teleport") or path:find("Rejoin") or path:find("ServerHop") then
			return
		end

		local entry = {
			time   = os.date("%H:%M:%S"),
			dir    = dir,
			path   = path,
			class  = inst.ClassName,
			method = method,
			args   = args_str(raw_args),
		}

		table.insert(logs, entry)
		
		if #logs > log_limit then
			table.remove(logs, 1)
			if #log_frames > 0 then
				local old_frame = table.remove(log_frames, 1)
				old_frame:Destroy()
			end
		end

		if window and matches(entry) then
			push_row(entry)
		end

		if status_label then
			status_label.Text = #logs .. " logs"
		end
	end

	local function rebuild_list()
		for _, f in ipairs(log_frames) do f:Destroy() end
		log_frames = {}
		for _, e in ipairs(logs) do
			if matches(e) then push_row(e) end
		end
	end

	local function hook_instance(inst)
		if not hook_incoming then return end -- Bypass incoming hooks to prevent server hopping
		if seen[inst] then return end
		local sig = in_signals[inst.ClassName]
		if not sig then return end
		seen[inst] = true

		local ok, con = pcall(function()
			return inst[sig]:Connect(function(...)
				add_log("in", inst, sig, table.pack(...))
			end)
		end)
		if ok and con then
			hook_cons[#hook_cons + 1] = con
		end
	end

	local function start()
		if active then return end
		active = true

		if hookmetamethod and not namecall_orig then
			local ok, orig = pcall(hookmetamethod, game, "__namecall", function(self, ...)
				local method = getnamecallmethod and getnamecallmethod() or ""
				if active
					and typeof(self) == "Instance"
					and remote_classes[self.ClassName]
					and out_methods[method]
				then
					add_log("out", self, method, table.pack(...))
				end
				return namecall_orig(self, ...)
			end)
			if ok then namecall_orig = orig end
		end

		if hook_incoming then
			local ok, descs = pcall(game.GetDescendants, game)
			if ok then
				for _, inst in ipairs(descs) do
					hook_instance(inst)
				end
			end
		end

		local da_con = game.DescendantAdded:Connect(function(inst)
			if active and hook_incoming then hook_instance(inst) end
		end)
		hook_cons[#hook_cons + 1] = da_con
	end

	local function stop()
		if not active then return end
		active = false

		for _, con in ipairs(hook_cons) do
			pcall(function() con:Disconnect() end)
		end
		hook_cons = {}

		seen = {}
		setmetatable(seen, { __mode = "k" })
	end

	local function make_btn(parent, text, x, w)
		local btn = Instance.new("TextButton")
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		btn.BorderSizePixel  = 0
		btn.Font             = Enum.Font.SourceSansBold
		btn.TextSize         = 13
		btn.TextColor3       = Color3.new(1, 1, 1)
		btn.Text             = text
		btn.AutoButtonColor  = false
		btn.Size             = UDim2.new(0, w, 0, 24)
		btn.Position         = UDim2.new(0, x, 0, 2)
		btn.Parent           = parent
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
		return btn
	end

	spy.Init = function()
		window = DeltaUI.Window.new()

		local toolbar = Instance.new("Frame")
		toolbar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		toolbar.BorderSizePixel  = 0
		toolbar.Size             = UDim2.new(1, 0, 0, 28)
		toolbar.Parent           = window.GuiElems.Content

		local start_btn = make_btn(toolbar, "▶ Start", 2,   65)
		local stop_btn  = make_btn(toolbar, "■ Stop",  70,  60)
		local clear_btn = make_btn(toolbar, "Clear",  133, 50)
		local pause_btn = make_btn(toolbar, "Pause",  186, 50)
		local copy_btn  = make_btn(toolbar, "Copy All",239, 65)

		status_label = Instance.new("TextLabel")
		status_label.BackgroundTransparency = 1
		status_label.Font       = Enum.Font.SourceSans
		status_label.TextSize   = 12
		status_label.TextColor3 = Color3.fromRGB(150, 150, 150)
		status_label.TextXAlignment = Enum.TextXAlignment.Right
		status_label.Size       = UDim2.new(1, -310, 1, 0)
		status_label.Position   = UDim2.new(0, 305, 0, 0)
		status_label.Text       = "0 logs"
		status_label.Parent     = toolbar

		local search_bar = Instance.new("Frame")
		search_bar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		search_bar.BorderSizePixel  = 0
		search_bar.Size             = UDim2.new(1, 0, 0, 25)
		search_bar.Position         = UDim2.new(0, 0, 0, 28)
		search_bar.Parent           = window.GuiElems.Content

		local search_box = Instance.new("TextBox", search_bar)
		search_box.BackgroundTransparency = 1
		search_box.PlaceholderText  = "Filter remote name / args…"
		search_box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
		search_box.Text             = ""
		search_box.Font             = Enum.Font.Code
		search_box.TextSize         = 13
		search_box.TextColor3       = Color3.new(1, 1, 1)
		search_box.TextXAlignment   = Enum.TextXAlignment.Left
		search_box.ClearTextOnFocus = false
		search_box.Size             = UDim2.new(1, -10, 1, 0)
		search_box.Position         = UDim2.new(0, 5, 0, 0)
		search_box:GetPropertyChangedSignal("Text"):Connect(function()
			filter_text = search_box.Text
			rebuild_list()
		end)

		scroll_frame = Instance.new("ScrollingFrame")
		scroll_frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		scroll_frame.BorderSizePixel  = 0
		scroll_frame.Size             = UDim2.new(1, 0, 1, -53)
		scroll_frame.Position         = UDim2.new(0, 0, 0, 53)
		scroll_frame.ScrollBarThickness = 6
		scroll_frame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
		scroll_frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll_frame.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll_frame.Parent = window.GuiElems.Content

		local layout = Instance.new("UIListLayout", scroll_frame)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding   = UDim.new(0, 2)

		start_btn.MouseButton1Click:Connect(function()
			start()
			start_btn.BackgroundColor3 = Color3.fromRGB(35, 120, 60)
			start_btn.Text = "▶ Active"
			stop_btn.BackgroundColor3  = Color3.fromRGB(50, 50, 50)
			stop_btn.Text  = "■ Stop"
		end)

		stop_btn.MouseButton1Click:Connect(function()
			stop()
			start_btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			start_btn.Text = "▶ Start"
			stop_btn.BackgroundColor3  = Color3.fromRGB(130, 40, 40)
			stop_btn.Text  = "■ Stopped"
		end)

		clear_btn.MouseButton1Click:Connect(function()
			logs = {}
			for _, f in ipairs(log_frames) do f:Destroy() end
			log_frames = {}
			status_label.Text = "0 logs"
		end)

		pause_btn.MouseButton1Click:Connect(function()
			paused = not paused
			pause_btn.Text = paused and "Resume" or "Pause"
			pause_btn.BackgroundColor3 = paused
				and Color3.fromRGB(120, 90, 20)
				or  Color3.fromRGB(50, 50, 50)
		end)

		copy_btn.MouseButton1Click:Connect(function()
			local lines = {}
			for _, e in ipairs(logs) do
				lines[#lines + 1] = string.format("[%s] %s %s:%s() | %s",
					e.time, e.dir, e.path, e.method, e.args)
			end
			safe_clipboard(table.concat(lines, "\n"))
		end)
	end

	return spy
end

-- Execute
local spyInstance = main()
spyInstance.Init()
