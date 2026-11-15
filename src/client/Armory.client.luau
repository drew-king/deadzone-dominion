local Players = game:GetService("Players")
local Storage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local Input = game:GetService("UserInputService")
local Actions = game:GetService("ContextActionService")
local player = Players.LocalPlayer
local shared = Storage:WaitForChild("Shared")
local weapons = require(shared:WaitForChild("CombatConfig")).Weapons
local economy = require(shared:WaitForChild("EconomyConfig"))
local palette = require(shared:WaitForChild("VisualTheme"))
local remote = Storage:WaitForChild("DeadzoneArsenal")

local function create(class, parent, properties)
	local item = Instance.new(class)
	for key, value in properties do item[key] = value end
	item.Parent = parent
	return item
end

local gui = create("ScreenGui", player:WaitForChild("PlayerGui"), {
	Name = "DeadzoneArmory", DisplayOrder = 15, ResetOnSpawn = false, Enabled = false,
})
local panel = create("Frame", gui, {
	Name = "Catalog", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
	Size = UDim2.fromScale(.85, .88), BackgroundColor3 = palette.Ink, BorderSizePixel = 0,
})
create("UISizeConstraint", panel, {MaxSize = Vector2.new(535, 470)})
create("UICorner", panel, {CornerRadius = UDim.new(0, 12)})
require(script.Parent.InterfaceArt).panel(panel, palette.Teal)
create("TextLabel", panel, {
	Text = "ARSENAL", Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = palette.Cream,
	Position = UDim2.fromOffset(14, 7), Size = UDim2.new(1, -115, 0, 35),
	TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
})
local close = create("TextButton", panel, {
	Name = "Close", Text = "Close", Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = palette.Ink,
	BackgroundColor3 = palette.Cream, Position = UDim2.new(1, -92, 0, 7), Size = UDim2.fromOffset(82, 42),
})
create("UICorner", close, {CornerRadius = UDim.new(0, 8)})
local list = create("ScrollingFrame", panel, {
	Name = "Weapons", Position = UDim2.fromOffset(10, 56), Size = UDim2.new(1, -20, 1, -95),
	BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 7,
	AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y,
})
create("UIListLayout", list, {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})
local status = create("TextLabel", panel, {
	Name = "Status", Position = UDim2.new(0, 12, 1, -34), Size = UDim2.new(1, -24, 0, 29),
	Text = "", TextWrapped = true, TextSize = 14, TextColor3 = palette.Cream, Font = Enum.Font.Gotham,
	TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
})
local rows = {}
for level, weapon in weapons do
	local row = create("TextButton", list, {
		Name = "Weapon" .. level, LayoutOrder = level, Size = UDim2.new(1, -8, 0, 54),
		Text = "", TextSize = 15, Font = Enum.Font.GothamBold, TextWrapped = true,
	})
	create("UICorner", row, {CornerRadius = UDim.new(0, 8)})
	row.Activated:Connect(function() remote:FireServer(level) end)
	rows[level] = row
end

local function hide()
	gui.Enabled = false
	Actions:UnbindAction("CloseDeadzoneArsenal")
	local selected = GuiService.SelectedObject
	if selected and selected:IsDescendantOf(gui) then GuiService.SelectedObject = nil end
end

close.Activated:Connect(hide)
player.CharacterRemoving:Connect(hide)
player:GetAttributeChangedSignal("ClaimedPower"):Connect(hide)
player:GetAttributeChangedSignal("Rebirths"):Connect(hide)
remote.OnClientEvent:Connect(function(action, unlocked, equipped, message)
	if action == "close" then hide(); return end
	if action ~= "open" and not gui.Enabled then return end
	local preceding = close
	local first
	for level, weapon in weapons do
		local row, owned = rows[level], unlocked[level]
		row.Active, row.Selectable, row.AutoButtonColor = owned, owned, owned
		row.TextColor3 = if owned then palette.Cream else Color3.fromRGB(192, 188, 205)
		row.BackgroundColor3 = palette.Ink:Lerp(weapon.Color, if equipped == level then .56 elseif owned then .32 else .12)
		row.Text = if owned then string.format("%s · %s\n%d damage · %.2fs between shots · %d stud reach",
			weapon.Name, if equipped == level then "Equipped" else "Equip", weapon.Damage, weapon.Interval, weapon.Reach)
			else weapon.Name .. " · Locked\nBuild " .. economy.Names[weapon.Unlock]
		if owned then
			preceding.NextSelectionDown = row
			row.NextSelectionUp = preceding
			first = first or row
			preceding = row
		end
	end
	preceding.NextSelectionDown = close
	close.NextSelectionUp = preceding
	status.Text = message or "Choose an unlocked weapon. The Cargo Analyzer is a separate utility."
	if action == "open" then
		gui.Enabled = true
		list.CanvasPosition = Vector2.zero
		Actions:BindAction("CloseDeadzoneArsenal", function(_, state)
			if state == Enum.UserInputState.Begin then hide() end
			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.ButtonB)
		if Input:GetLastInputType().Name:find("Gamepad", 1, true) then GuiService.SelectedObject = first or close end
	end
end)
