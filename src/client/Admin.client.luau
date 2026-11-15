local Players = game:GetService("Players")
local Storage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local remote = Storage:WaitForChild("DominionControl", 20)
local announcement = Storage:WaitForChild("DominionAnnouncement", 5)
if not remote then return end

local background = Color3.fromRGB(23, 28, 36)
local surface = Color3.fromRGB(38, 46, 58)
local textColor = Color3.fromRGB(239, 244, 251)
local accent = Color3.fromRGB(255, 192, 99)

local function create(class, parent, properties)
	local item = Instance.new(class)
	for key, value in pairs(properties) do item[key] = value end
	item.Parent = parent
	return item
end

local gui = create("ScreenGui", playerGui, {Name = "DominionControl", ResetOnSpawn = false, DisplayOrder = 20})
local function label(parent, value, size)
	return create("TextLabel", parent, {
		Size = UDim2.new(1, 0, 0, size or 26), BackgroundTransparency = 1,
		Text = value, TextColor3 = textColor, TextSize = 15, Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
	})
end

if announcement then
	announcement.OnClientEvent:Connect(function(message)
		local banner = label(gui, "SERVER MESSAGE  ·  " .. message, 58)
		banner.AnchorPoint = Vector2.new(0.5, 0)
		banner.Position = UDim2.new(0.5, 0, 0.025, 92)
		banner.Size = UDim2.new(0.82, 0, 0, 58)
		banner.BackgroundColor3 = background
		banner.BackgroundTransparency = 0
		banner.TextXAlignment = Enum.TextXAlignment.Center
		task.delay(6, function()
			TweenService:Create(banner, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
			task.delay(0.35, function() banner:Destroy() end)
		end)
	end)
end

local function request(...)
	local ok, result = pcall(remote.InvokeServer, remote, ...)
	if ok and type(result) == "table" then return result end
	return {ok = false, message = "Server did not complete the command."}
end

local roster = request("list")
if not roster.ok then return end

local function button(parent, title, callback)
	local item = create("TextButton", parent, {
		Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = surface,
		Text = title, TextColor3 = textColor, TextSize = 13, TextWrapped = true,
		Font = Enum.Font.GothamMedium,
	})
	create("UICorner", item, {CornerRadius = UDim.new(0, 5)})
	item.Activated:Connect(callback)
	return item
end

local panel = create("Frame", gui, {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.52),
	Size = UDim2.fromScale(0.92, 0.77), BackgroundColor3 = background, Visible = false,
})
create("UISizeConstraint", panel, {MaxSize = Vector2.new(760, 610)})
create("UICorner", panel, {CornerRadius = UDim.new(0, 10)})
require(script.Parent.InterfaceArt).panel(panel, accent)
local toggle = button(gui, "Dominion Control", function() panel.Visible = not panel.Visible end)
toggle.Size = UDim2.fromOffset(148, 34)
toggle.Position = UDim2.new(1, -158, 1, -48)
if game:GetService("UserInputService").TouchEnabled then
	toggle.Size, toggle.Position = UDim2.fromOffset(128, 44), UDim2.new(1, -136, 0, 100)
end
local title = label(panel, "DOMINION CONTROL", 30)
title.Position = UDim2.fromOffset(12, 5)
title.TextColor3 = accent
local subtitle = label(panel, "Current server · Changes are session only", 23)
subtitle.Position = UDim2.fromOffset(12, 33)
local status = label(panel, "Select a player or choose a server command.", 53)
status.Position = UDim2.new(0, 12, 1, -57)
status.Size = UDim2.new(1, -24, 0, 53)

local function input(parent, placeholder)
	return create("TextBox", parent, {
		Size = UDim2.new(1, 0, 0, 33), BackgroundColor3 = surface, TextColor3 = textColor,
		PlaceholderText = placeholder, PlaceholderColor3 = Color3.fromRGB(173, 185, 201),
		Text = "", TextSize = 14, Font = Enum.Font.Gotham, ClearTextOnFocus = false,
	})
end

local function scrolling(parent, position, size)
	local frame = create("ScrollingFrame", parent, {
		Size = size, Position = position, BackgroundTransparency = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.fromOffset(0, 0),
		ScrollBarThickness = 5, BorderSizePixel = 0,
	})
	create("UIListLayout", frame, {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
	create("UIPadding", frame, {PaddingRight = UDim.new(0, 8)})
	return frame
end

local players = scrolling(panel, UDim2.fromOffset(12, 94), UDim2.new(0.29, -16, 1, -158))
local body = scrolling(panel, UDim2.new(0.29, 8, 0, 94), UDim2.new(0.71, -20, 1, -158))
local tabs = create("Frame", panel, {
	Position = UDim2.fromOffset(12, 59), Size = UDim2.new(1, -24, 0, 29), BackgroundTransparency = 1,
})
create("UIListLayout", tabs, {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4)})

local selected, selectedName
local filter = input(players, "Search players")
local playerButtons = {}
local pending
local busy = false

local function show(message, ok)
	status.Text = message
	status.TextColor3 = if ok then textColor else Color3.fromRGB(255, 161, 145)
end

local function describe(state)
	if type(state) ~= "table" then return "" end
	local upgrades = {}
	if type(state.upgrades) == "table" then
		for key, value in pairs(state.upgrades) do
			if type(key) == "number" then table.insert(upgrades, tostring(value))
			elseif value == true then table.insert(upgrades, tostring(key)) end
		end
		table.sort(upgrades)
	end
	return string.format("Plot %s | Cash %s | Pending %s | Power %s | Upgrades %s",
		tostring(state.plot or "—"), tostring(state.wallet or "—"), tostring(state.pending or "—"),
		tostring(state.power or "—"), #upgrades > 0 and table.concat(upgrades, ", ") or "—")
end

local function refreshPlayers()
	for _, item in ipairs(playerButtons) do item:Destroy() end
	table.clear(playerButtons)
	local search = string.lower(filter.Text)
	for _, entry in ipairs(roster.players) do
		if string.find(string.lower(entry.name .. " " .. entry.displayName), search, 1, true) then
			local item = button(players, entry.name, function()
				selected, selectedName, pending = entry.id, entry.name, nil
				show("Target: " .. selectedName, true)
			end)
			table.insert(playerButtons, item)
		end
	end
end

button(players, "Refresh roster", function()
	local update = request("list")
	if update.ok then roster = update; refreshPlayers() else show(update.message, false) end
end)
filter:GetPropertyChangedSignal("Text"):Connect(refreshPlayers)
refreshPlayers()

local tabsConfig = {
	Players = {
		{"Inspect selected player", "inspect"}, {"Teleport to plot", "teleport", "plot"},
		{"Teleport to Reactor Crown", "teleport", "reactor"}, {"Respawn", "respawn"},
		{"Invulnerability · seconds", "protect", "number"},
	},
	Economy = {
		{"Grant cash", "grantCash", "number"}, {"Deduct cash", "deductCash", "number"},
		{"Set cash", "setCash", "number"}, {"Clear pending output", "clearPending"},
		{"Undo last reversible change", "rollback"}, {"Grant cash to everyone · preview first", "bulkCash", "number", true},
		{"Grant Walls upgrade", "grantUpgrade", "Walls"}, {"Grant Production upgrade", "grantUpgrade", "Production"},
		{"Set server production multiplier", "productionRate", "number", true},
		{"Set server price multiplier", "costRate", "number", true},
	},
	Powers = {
		{"Revoke assigned identity", "revokePower"}, {"Lock power identity · seconds", "lockPower", "number"},
	},
	World = {
		{"Pause production", "pauseProduction", true, true}, {"Resume production", "pauseProduction", false, true},
		{"Pause combat", "pauseCombat", true, true}, {"Resume combat", "pauseCombat", false, true},
		{"Set time of day · 0–23.99", "clock", "number", true}, {"Send server announcement", "announce", "text", true},
		{"Release selected plot", "releasePlot"}, {"Reset selected plot", "resetPlot"},
	},
	Lab = {
		{"Fresh join", "preset", "fresh"}, {"First purchase", "preset", "first"},
		{"Fully upgraded", "preset", "upgraded"}, {"Combat sparring", "preset", "sparring"},
	},
}

local function run(action, target, arg, reason, confirm)
	if busy then return end
	busy = true
	local result = request(action, target, arg, reason, confirm)
	busy = false
	if result.preview then
		pending = {action = action, target = target, arg = arg, reason = reason, token = result.preview}
	end
	local details = describe(result.state)
	if result.state and result.state.playtestUntil then
		details ..= string.format(" | Test expires in %ds", math.max(0, math.ceil(result.state.playtestUntil - workspace:GetServerTimeNow())))
	end
	show((result.message or "Current player state") .. (details ~= "" and "\n" .. details or ""), result.ok)
end

local function switch(name)
	pending = nil
	for _, item in ipairs(body:GetChildren()) do
		if item:IsA("GuiObject") then item:Destroy() end
	end
	if name == "Audit" then
		local search = input(body, "Filter by actor, target, action, or result")
		local rows = {}
		local entries = {}
		local function render()
			for _, row in ipairs(rows) do row:Destroy() end
			table.clear(rows)
			local needle = string.lower(search.Text)
			for _, entry in ipairs(entries) do
				local heading = string.format("%s · %s → %s · %s · %s",
					os.date("%H:%M:%S", entry.time), tostring(entry.actor), tostring(entry.target or "server"),
					entry.action, entry.ok and "applied" or "denied")
				if string.find(string.lower(heading .. " " .. (entry.result or "")), needle, 1, true) then
					local content = table.concat({
						heading .. " · " .. entry.scope,
						entry.result or "",
						"Reason: " .. (entry.reason ~= "" and entry.reason or "—"),
						"Before: " .. describe(entry.before),
						"After: " .. describe(entry.after),
					}, "\n")
					table.insert(rows, label(body, content, 115))
				end
			end
		end
		search:GetPropertyChangedSignal("Text"):Connect(render)
		button(body, "Load audit log", function()
			local result = request("audit")
			if result.ok then entries = result.audit; render(); show("Audit log loaded.", true)
			else show(result.message, false) end
		end)
		return
	end
	if name == "Powers" then
		label(body, if roster.studio then "Studio prototypes · select a player with a plot." else "Preview only · gameplay is available in Studio.", 29)
	end
	if name == "Lab" then label(body, "Studio-only test profiles", 29) end
	local value = input(body, "Value for commands that require one")
	local reason = input(body, "Reason (optional, up to 100 bytes)")
	local function command(titleText, action, argType, server)
		button(body, titleText, function()
			pending = nil
			if not server and selected == nil then show("Select a player first.", false); return end
			local arg = argType
			if argType == "number" then arg = tonumber(value.Text)
			elseif argType == "text" then arg = value.Text end
			run(action, if server then nil else selected, arg, reason.Text)
		end)
	end
	button(body, "Confirm preview", function()
		local entry = pending
		pending = nil
		if not entry then show("Select a command that creates a preview first.", false); return end
		run(entry.action, entry.target, entry.arg, entry.reason, entry.token)
	end)
	for _, entry in ipairs(tabsConfig[name]) do command(table.unpack(entry, 1, 4)) end
	if name == "Powers" then
		if roster.studio then
			command("Reset power cooldown", "resetPowerCooldown")
			command("Clear power effects", "clearPowerEffects")
			command("Tune selected power · key=value", "setPowerTuning", "text")
		end
		for _, power in ipairs(roster.powers) do command("Assign " .. power, "assignPower", power) end
	end
end

for _, name in ipairs({"Players", "Economy", "Powers", "World", "Lab", "Audit"}) do
	local tab = button(tabs, name, function() switch(name) end)
	tab.Size = UDim2.new(1 / 6, -4, 1, 0)
end
switch("Players")
