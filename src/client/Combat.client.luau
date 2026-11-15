local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local remote = ReplicatedStorage:WaitForChild("DeadzoneScrapPulse")
local config = require(ReplicatedStorage.Shared.CombatConfig)
local gui = Instance.new("ScreenGui")
gui.Name = "DeadzoneCombatFeedback"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local message = Instance.new("TextLabel")
message.Size = UDim2.new(0.74, 0, 0, 38)
message.Position = UDim2.fromScale(0.5, 0.68)
message.AnchorPoint = Vector2.new(0.5, 0.5)
message.BackgroundTransparency = 0.16
message.BackgroundColor3 = Color3.fromRGB(19, 28, 37)
message.TextColor3 = Color3.fromRGB(166, 240, 242)
message.Font = Enum.Font.GothamBold
message.TextSize = 16
message.Visible = false
message.Parent = gui
require(script.Parent.InterfaceArt).panel(message, Color3.fromRGB(106,221,230))
local maxSize = Instance.new("UISizeConstraint")
maxSize.MaxSize = Vector2.new(320, 38)
maxSize.Parent = message

local reticle = Instance.new("TextLabel")
reticle.Size = UDim2.fromOffset(24, 24)
reticle.Position = UDim2.fromScale(0.5, 0.5)
reticle.AnchorPoint = Vector2.new(0.5, 0.5)
reticle.BackgroundTransparency = 1
reticle.Text = "+"
reticle.TextColor3 = message.TextColor3
reticle.TextStrokeTransparency = 0.35
reticle.Font = Enum.Font.GothamBold
reticle.TextSize = 19
reticle.Visible = false
reticle.Parent = gui

local function usesCenteredAim(input)
	return input == Enum.UserInputType.Touch or string.find(input.Name, "Gamepad", 1, true) ~= nil
end

local function updateReticle()
	local character = player.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	reticle.Visible = tool ~= nil and tool:GetAttribute("DeadzoneStarterWeapon") == true
		and usesCenteredAim(UserInputService:GetLastInputType())
end

UserInputService.LastInputTypeChanged:Connect(updateReticle)

local revision = 0
remote.OnClientEvent:Connect(function(text, origin, endpoint)
	if origin and endpoint then
		local distance = (endpoint - origin).Magnitude
		if distance > 0.05 then
			local pulse = Instance.new("Part")
			pulse.Size = Vector3.new(0.12, 0.12, distance)
			pulse.CFrame = CFrame.lookAt((origin + endpoint) / 2, endpoint)
			pulse.Anchored, pulse.CanCollide, pulse.CanTouch, pulse.CanQuery = true, false, false, false
			pulse.Material = Enum.Material.Neon
			pulse.Color = Color3.fromRGB(82, 211, 223)
			pulse.Parent = workspace
			game:GetService("Debris"):AddItem(pulse, 0.09)
		end
		return
	end
	revision += 1
	local current = revision
	message.Text = text
	message.Visible = true
	task.delay(1.9, function()
		if current == revision then message.Visible = false end
	end)
end)

local wasInArena
RunService.Heartbeat:Connect(function()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then wasInArena = nil; return end
	local inside = Vector2.new(root.Position.X, root.Position.Z).Magnitude <= config.ArenaRadius
	if wasInArena ~= nil and wasInArena ~= inside then
		revision += 1
		local current = revision
		message.Text = if inside then "Reactor Crown · PvP active" else "Outside Reactor Crown · PvP inactive"
		message.Visible = true
		task.delay(1.9, function()
			if current == revision then message.Visible = false end
		end)
	end
	wasInArena = inside
end)

local connections = {}
local function watch(character)
	for _, connection in ipairs(connections) do connection:Disconnect() end
	table.clear(connections)
	local function connectTool(tool)
		if not tool:IsA("Tool") or not tool:GetAttribute("DeadzoneStarterWeapon") then return end
		table.insert(connections, tool.Activated:Connect(function()
			if tool.Parent ~= character then return end
			local camera = workspace.CurrentCamera
			if not camera then return end
			local input = UserInputService:GetLastInputType()
			local target = mouse.Hit.Position
			if usesCenteredAim(input) then
				local ray = camera:ViewportPointToRay(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {character}
				local weapon = config.Weapons[tool:GetAttribute("WeaponLevel") or 1]
				local reach = if weapon then weapon.Reach else config.Reach
				local hit = workspace:Raycast(ray.Origin, ray.Direction * reach, params)
				target = if hit then hit.Position else ray.Origin + ray.Direction * reach
			end
			remote:FireServer(target)
		end))
	end
	-- A tool can move between backpack and character many times.
	local bound = setmetatable({}, {__mode = "k"})
	local function onChild(child)
		if bound[child] then return end
		bound[child] = true
		connectTool(child)
	end
	table.insert(connections, character.ChildAdded:Connect(function(child)
		onChild(child)
		updateReticle()
	end))
	table.insert(connections, character.ChildRemoved:Connect(updateReticle))
	for _, child in ipairs(character:GetChildren()) do onChild(child) end
	updateReticle()
end

player.CharacterAdded:Connect(watch)
if player.Character then watch(player.Character) end
