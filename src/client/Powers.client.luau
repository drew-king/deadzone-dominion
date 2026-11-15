local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("DeadzonePowerAction", 15)
if not remote then return end

local hints = {
	JuggerJigg = "Dance to build armor. Attacking stops your dance.",
	["Spam-Him-Up"] = "Land consecutive hits on one opponent to gain speed.",
	["Double Pop"] = "Score two eliminations to empower your next hits.",
	["Rising Sun"] = "Revive after lethal damage while ready.",
	SlurperAid = "Collect a healing bubble at an elimination site.",
	PlopperFizz = "Land after a large drop to create a burst.",
	CritShot = "Earn extra generator Scrap. Valid hits have a 4% instant elimination chance.",
	["PolarBear Kick"] = "Collect temporary weapons at elimination sites.",
}

local colors = {
	JuggerJigg = Color3.fromRGB(255, 111, 128),
	["Spam-Him-Up"] = Color3.fromRGB(96, 243, 252),
	["Double Pop"] = Color3.fromRGB(255, 169, 103),
	["Rising Sun"] = Color3.fromRGB(255, 226, 128),
	SlurperAid = Color3.fromRGB(146, 251, 167),
	PlopperFizz = Color3.fromRGB(200, 137, 255),
	CritShot = Color3.fromRGB(199, 255, 104),
	["PolarBear Kick"] = Color3.fromRGB(156, 215, 255),
}

local gui = Instance.new("ScreenGui")
gui.Name = "DeadzonePowerHUD"
gui.ResetOnSpawn = false
gui.DisplayOrder = 4
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "PowerCard"
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.new(0.5, 0, 1, -86)
panel.Size = UDim2.new(0.86, 0, 0, 99)
panel.BackgroundColor3 = Color3.fromRGB(17, 24, 35)
panel.BackgroundTransparency = 0.1
panel.Visible = false
panel.Parent = gui

local panelSize = Instance.new("UISizeConstraint")
panelSize.MaxSize = Vector2.new(410, 99)
panelSize.Parent = panel
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel
local stroke = Instance.new("UIStroke")
stroke.Transparency = 0.6
stroke.Parent = panel
require(script.Parent.InterfaceArt).panel(panel, Color3.fromRGB(201,157,255))

local function label(name, top, height, font, size)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Position = UDim2.fromOffset(12, top)
	item.Size = UDim2.new(1, -24, 0, height)
	item.BackgroundTransparency = 1
	item.Font = font
	item.TextSize = size
	item.TextColor3 = Color3.fromRGB(230, 239, 252)
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.TextWrapped = true
	item.Parent = panel
	return item
end

local title = label("PowerName", 7, 20, Enum.Font.GothamBold, 17)
local hint = label("PowerInstruction", 28, 34, Enum.Font.Gotham, 13)
local status = label("PowerStatus", 65, 25, Enum.Font.GothamMedium, 14)
local danceButton = Instance.new("TextButton")
danceButton.Name = "Dance"
danceButton.Position = UDim2.new(1, -106, 0, 64)
danceButton.Size = UDim2.fromOffset(94, 30)
danceButton.BackgroundColor3 = Color3.fromRGB(95, 42, 58)
danceButton.Font = Enum.Font.GothamBold
danceButton.TextSize = 13
danceButton.TextColor3 = Color3.new(1, 1, 1)
danceButton.Parent = panel

local function toggleDance()
	if player:GetAttribute("ActivePower") == "JuggerJigg" then
		remote:FireServer("dance")
	end
end

danceButton.Activated:Connect(toggleDance)
local danceBound = false
local function update()
	local power = player:GetAttribute("ActivePower")
	panel.Visible = hints[power] ~= nil
	local dance = power == "JuggerJigg"
	if dance and not danceBound then
		ContextActionService:BindAction("DeadzonePowerDance", function(_, state)
			if state == Enum.UserInputState.Begin then toggleDance() end
			return Enum.ContextActionResult.Sink
		end, false, Enum.KeyCode.Q, Enum.KeyCode.ButtonY)
		danceBound = true
	elseif not dance and danceBound then
		ContextActionService:UnbindAction("DeadzonePowerDance")
		danceBound = false
	end
	if not panel.Visible then return end

	title.Text = power
	title.TextColor3 = colors[power]
	stroke.Color = colors[power]
	hint.Text = hints[power]
	local now = workspace:GetServerTimeNow()
	local cooldown = math.max(0, math.ceil((player:GetAttribute("PowerCooldownUntil") or 0) - now))
	local boost = math.max(0, math.ceil((player:GetAttribute("PowerBoostUntil") or 0) - now))
	local charges = player:GetAttribute("PowerCharges") or 0
	local armor = player:GetAttribute("PowerArmor") or 0
	danceButton.Visible = dance
	status.Size = UDim2.new(1, if dance then -124 else -24, 0, 25)
	if dance then
		danceButton.Text = if player:GetAttribute("PowerDancing") then "Stop dance" else "Dance"
		status.Text = string.format("Armor %d", math.floor(armor))
	elseif cooldown > 0 then
		status.Text = string.format("Cooldown %ds", cooldown)
	elseif boost > 0 then
		status.Text = string.format("Speed boost %ds", boost)
	elseif charges > 0 then
		status.Text = string.format("%d empowered hits", charges)
	elseif power == "Rising Sun" then
		status.Text = "Revive ready"
	else
		local state = player:GetAttribute("PowerState")
		status.Text = if typeof(state) == "string" then state else ""
	end
end

for _, attribute in {"ActivePower", "PowerCooldownUntil", "PowerBoostUntil", "PowerCharges", "PowerArmor", "PowerDancing", "PowerState"} do
	player:GetAttributeChangedSignal(attribute):Connect(update)
end

local markers = {}
local function removePickup(id)
	local pickup = markers[id]
	if pickup then
		markers[id] = nil
		pickup.marker:Destroy()
	end
end

local function showPickup(id, position, kind, expiresAt, weaponName)
	removePickup(id)
	local heal = kind == "heal"
	local marker = Instance.new("Part")
	marker.Name = "PowerPickupPreview"
	marker.Shape = Enum.PartType.Ball
	marker.Size = Vector3.new(1.15, 1.15, 1.15)
	marker.Position = position
	marker.Anchored = true
	marker.CanCollide, marker.CanTouch, marker.CanQuery = false, false, false
	marker.Material = Enum.Material.Neon
	marker.Color = if heal then colors.SlurperAid else colors["PolarBear Kick"]
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Collect"
	prompt.ObjectText = if heal then "Healing bubble" else weaponName or "Temporary weapon"
	prompt.MaxActivationDistance = 9
	prompt.HoldDuration = 0.15
	prompt.RequiresLineOfSight = false
	prompt.Parent = marker
	prompt.Triggered:Connect(function()
		remote:FireServer("collect", id)
	end)
	local pickup = {marker = marker, power = if heal then "SlurperAid" else "PolarBear Kick"}
	markers[id] = pickup
	marker.Parent = if player:GetAttribute("ActivePower") == pickup.power then workspace else nil
	task.delay(math.max(0, expiresAt - workspace:GetServerTimeNow()), function()
		if markers[id] == pickup then removePickup(id) end
	end)
end

local activeEffects = 0
local function showEffect(kind, position)
	local effectColors = {
		landing = colors.PlopperFizz,
		revive = colors["Rising Sun"],
		fullHeal = Color3.fromRGB(143, 41, 52),
	}
	local color = effectColors[kind]
	if not color or activeEffects >= 12 then return end
	activeEffects += 1
	local glow = Instance.new("Part")
	glow.Name = "PowerEffect"
	glow.Shape = Enum.PartType.Ball
	glow.Size = Vector3.one
	glow.Position = position
	glow.Anchored = true
	glow.CanCollide, glow.CanTouch, glow.CanQuery = false, false, false
	glow.Material = Enum.Material.Neon
	glow.Color = color
	glow.Transparency = 0.55
	glow.Parent = workspace
	local diameter = if kind == "landing" then 26 else 8
	local tween = TweenService:Create(glow, TweenInfo.new(0.35), {
		Size = Vector3.one * diameter,
		Transparency = 1,
	})
	tween.Completed:Once(function()
		activeEffects -= 1
		glow:Destroy()
	end)
	tween:Play()
end

remote.OnClientEvent:Connect(function(action, first, second, third, fourth, fifth)
	if action == "pickup" then
		showPickup(first, second, third, fourth, fifth)
	elseif action == "remove" then
		removePickup(first)
	elseif action == "effect" then
		showEffect(first, second)
	end
end)

player:GetAttributeChangedSignal("ActivePower"):Connect(function()
	local active = player:GetAttribute("ActivePower")
	for id, pickup in markers do
		if active == pickup.power then
			pickup.marker.Parent = workspace
		elseif pickup.marker.Parent then
			removePickup(id)
		end
	end
end)

task.spawn(function()
	while gui.Parent do
		update()
		task.wait(0.25)
	end
end)
