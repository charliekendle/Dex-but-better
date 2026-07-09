--[[
	Script Viewer App Module
	
	A script viewer that is basically a notepad
]]
-- Common Locals
local Main,Lib,Apps,Settings -- Main Containers
local Explorer, Properties, ScriptViewer, Notebook -- Major Apps
local API,RMD,env,service,plr,create,createSimple -- Main Locals
local function initDeps(data)
	Main = data.Main
	Lib = data.Lib
	Apps = data.Apps
	Settings = data.Settings
	API = data.API
	RMD = data.RMD
	env = data.env
	service = data.service
	plr = data.plr
	create = data.create
	createSimple = data.createSimple
end
local function initAfterMain()
	Explorer = Apps.Explorer
	Properties = Apps.Properties
	ScriptViewer = Apps.ScriptViewer
	Notebook = Apps.Notebook
end
local function main()
	local ScriptViewer = {}
	local window, codeFrame
	local tabs = {}
	local activeTab = nil
	local tabBar, tabTemplate

	local function updateTabBar()
		for _, tab in pairs(tabs) do
			tab.Button.BackgroundColor3 = tab == activeTab and Color3.fromRGB(40,40,40) or Color3.fromRGB(60,60,60)
			tab.Button.Title.TextColor3 = tab == activeTab and Color3.new(1,1,1) or Color3.fromRGB(180,180,180)
		end
	end

	local function switchTab(tab)
		activeTab = tab
		codeFrame:SetText(tab.Source)
		window:SetTitle("Script Viewer - "..tab.Name)
		updateTabBar()
	end

	local function closeTab(tab)
		local idx = table.find(tabs, tab)
		if not idx then return end
		tab.Button:Destroy()
		table.remove(tabs, idx)

		if activeTab == tab then
			activeTab = nil
			if #tabs > 0 then
				switchTab(tabs[math.max(1, idx-1)])
			else
				codeFrame:SetText("")
				window:SetTitle("Script Viewer")
			end
		end
	end

	local function addTab(name, source)
		for _, tab in pairs(tabs) do
			if tab.Name == name then
				tab.Source = source
				switchTab(tab)
				return
			end
		end

		local btn = createSimple("TextButton", {
			BackgroundColor3 = Color3.fromRGB(60,60,60),
			BorderSizePixel = 0,
			Font = Enum.Font.SourceSans,
			Name = "Tab",
			Size = UDim2.new(0,120,1,0),
			Text = "",
			Parent = tabBar,
		})
		createSimple("TextLabel", {
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSans,
			Name = "Title",
			Size = UDim2.new(1,-18,1,0),
			Text = name,
			TextColor3 = Color3.new(1,1,1),
			TextSize = 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0,4,0,0),
			Parent = btn,
		})
		local closeBtn = createSimple("TextButton", {
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSans,
			Name = "Close",
			Position = UDim2.new(1,-18,0,0),
			Size = UDim2.new(0,18,1,0),
			Text = "x",
			TextColor3 = Color3.fromRGB(180,180,180),
			TextSize = 14,
			Parent = btn,
		})

		local tab = {Name = name, Source = source, Button = btn}
		tabs[#tabs+1] = tab

		btn.MouseButton1Click:Connect(function()
			switchTab(tab)
		end)

		closeBtn.MouseButton1Click:Connect(function()
			closeTab(tab)
		end)

		switchTab(tab)
	end

	ScriptViewer.ViewScript = function(scr)
		local s, source = pcall(env.decompile or function() end, scr)
		if not s or not source then
			source = "-- Failed to decompile"
		end
		addTab(tostring(scr), source)
		window:Show()
	end

	ScriptViewer.Init = function()
		window = Lib.Window.new()
		window:SetTitle("Script Viewer")
		window:Resize(500,400)
		ScriptViewer.Window = window

		-- Tab bar
		tabBar = createSimple("Frame", {
			BackgroundColor3 = Color3.fromRGB(30,30,30),
			BorderSizePixel = 0,
			Name = "TabBar",
			Position = UDim2.new(0,0,0,0),
			Size = UDim2.new(1,0,0,20),
			Parent = window.GuiElems.Content,
			ClipsDescendants = true,
		})
		createSimple("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = tabBar,
		})

		-- Code frame
		codeFrame = Lib.CodeFrame.new()
		codeFrame.Frame.Position = UDim2.new(0,0,0,40)
		codeFrame.Frame.Size = UDim2.new(1,0,1,-40)
		codeFrame.Frame.Parent = window.GuiElems.Content

		-- Toolbar buttons
		local copy = createSimple("TextButton", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0,0,0,20),
			Size = UDim2.new(0.5,0,0,20),
			Text = "Copy to Clipboard",
			TextColor3 = Color3.new(1,1,1),
			Font = Enum.Font.SourceSans,
			TextSize = 14,
			Parent = window.GuiElems.Content,
		})
		copy.MouseButton1Click:Connect(function()
			if env.setclipboard then
				env.setclipboard(codeFrame:GetText())
			end
		end)

		local save = createSimple("TextButton", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5,0,0,20),
			Size = UDim2.new(0.5,0,0,20),
			Text = "Save to File",
			TextColor3 = Color3.new(1,1,1),
			Font = Enum.Font.SourceSans,
			TextSize = 14,
			Parent = window.GuiElems.Content,
		})
		save.MouseButton1Click:Connect(function()
			local source = codeFrame:GetText()
			local filename = "Place_"..game.PlaceId.."_Script_"..os.time()..".txt"
			if env.writefile then
				env.writefile(filename, source)
			end
		end)
	end

	return ScriptViewer
end
-- TODO: Remove when open source
if gethsfuncs then
	_G.moduleData = {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
else
	return {InitDeps = initDeps, InitAfterMain = initAfterMain, Main = main}
end
