local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = require(ReplicatedStorage.Shared.CombatConfig)
local Art = require(script.Parent.FactoryArt)
local palette = require(ReplicatedStorage.Shared.VisualTheme)

local Combat = {}
local WEAPON_NAME = "Scrap Pulse"
local hitEvent = Instance.new("BindableEvent")
local eliminationEvent = Instance.new("BindableEvent")
Combat.Hit = hitEvent.Event
Combat.Elimination = eliminationEvent.Event
local credited = setmetatable({}, {__mode = "k"})
local issued = {}
local looted = {}
local nextPulse = {}

local silhouettes = {
	{{"Emitter", Vector3.new(.5,.48,.68), CFrame.new(0,.44,-1.08), Enum.PartType.Cylinder}},
	{{"IonCell", Vector3.new(.5,.6,.44), CFrame.new(0,.14,-.88)},
		{"IonSight", Vector3.new(.22,.27,.46), CFrame.new(0,.78,-.58)}},
	{{"ArcRail", Vector3.new(.36,.26,1.4), CFrame.new(0,.55,-1.47)},
		{"ArcTip", Vector3.new(.34,.37,.42), CFrame.new(0,.55,-2.2), Enum.PartType.Ball}},
	{{"ReactorCore", Vector3.new(.77,.7,.85), CFrame.new(0,.5,-1.24), Enum.PartType.Cylinder},
		{"HeatShield", Vector3.new(.95,.22,.64), CFrame.new(0,.84,-1.08)}},
	{{"Prism", Vector3.new(.67,.67,.77), CFrame.new(0,.58,-1.58)*CFrame.Angles(0,0,math.pi/4)},
		{"PrismRail", Vector3.new(.25,.21,1.12), CFrame.new(0,.27,-1.65)}},
	{{"CinderShroud", Vector3.new(.8,.55,1.25), CFrame.new(0,.5,-1.68)},
		{"CinderVent", Vector3.new(.72,.18,.65), CFrame.new(0,.84,-1.56)}},
	{{"FluxEmitter", Vector3.new(.38,.28,1.9), CFrame.new(0,.52,-1.9)},
		{"FluxCoil", Vector3.new(.86,.66,.68), CFrame.new(0,.46,-1.33), Enum.PartType.Ball}},
	{{"CrownChamber", Vector3.new(.97,.75,.93), CFrame.new(0,.5,-1.55), Enum.PartType.Cylinder},
		{"CrownSight", Vector3.new(.31,.35,.84), CFrame.new(0,.94,-1.45)}},
}

local function addWeaponSilhouette(tool, grip, level, color)
	for _, piece in silhouettes[level] do
		local name, size, offset, shape = table.unpack(piece)
		local part = Instance.new("Part")
		part.Name, part.Size, part.CFrame = name, size, grip.CFrame * offset
		part.Color, part.Material = color:Lerp(palette.Cream,.28), Enum.Material.SmoothPlastic
		if shape then part.Shape = shape end
		part.CanCollide, part.CanTouch, part.CanQuery, part.Massless = false, false, false, true
		part.CastShadow, part.Parent = false, tool
		local weld = Instance.new("WeldConstraint")
		weld.Part0, weld.Part1, weld.Parent = grip, part, part
	end
end

local function inArena(position)
	return Vector2.new(position.X, position.Z).Magnitude <= config.ArenaRadius
end

local function getLivingCharacter(player)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		return
	end
	return character, root, humanoid
end

local function isProtected(character, root, plots)
	if character:FindFirstChildOfClass("ForceField") then
		return true
	end
	for _, plot in ipairs(plots) do
		local localPosition = plot.Model:GetPivot():PointToObjectSpace(root.Position)
		if math.abs(localPosition.X) <= 11 and math.abs(localPosition.Z - 38) <= 8
			and localPosition.Y >= 0 and localPosition.Y <= 12 then
			return true
		end
	end
	return false
end

function Combat.reset(player)
	player:SetAttribute("StarterWeaponEquipped", nil)
	local weapon = issued[player]
	issued[player] = nil
	nextPulse[player] = nil
	if weapon then weapon:Destroy() end
	Combat.clearLoot(player)
end

function Combat.clearLoot(player)
	for tool in looted[player] or {} do tool:Destroy() end
	looted[player] = nil
end

local function createWeapon(level)
	local tuning = config.Weapons[level]
	local weapon = Instance.new("Tool")
	weapon.Name = tuning.Name
	weapon.ToolTip = string.format("%d damage · %.2fs cadence", tuning.Damage, tuning.Interval)
	weapon.CanBeDropped = false
	weapon:SetAttribute("DeadzoneStarterWeapon", true)
	weapon:SetAttribute("WeaponLevel", level)
	local grip = Instance.new("Part")
	grip.Name = "Handle"
	grip.Size = Vector3.new(0.6, 0.8, 1.3)
	grip.Color = tuning.Color
	grip.Material = Enum.Material.SmoothPlastic
	grip.CanCollide = false
	grip.CanQuery = false
	grip.CanTouch = false
	grip.Massless = true
	grip.Parent = weapon
	local housing = Instance.new("Part")
	housing.Name = "PulseHousing"
	housing.Size = Vector3.new(.8, .42, 1.4 + level * .35)
	housing.Color = Color3.fromRGB(44, 53, 66)
	housing.Material = Enum.Material.Metal
	housing.CanCollide, housing.CanTouch, housing.CanQuery, housing.Massless = false, false, false, true
	housing.CFrame = grip.CFrame * CFrame.new(0, .45, -.35)
	housing.Parent = weapon
	local weld = Instance.new("WeldConstraint")
	weld.Part0, weld.Part1, weld.Parent = grip, housing, housing
	for _, side in {-1, 1} do
		local shell = Instance.new("Part")
		shell.Name, shell.Size = "ColorShell", Vector3.new(.16, .32 + level * .04, 1.18 + level * .27)
		shell.CFrame = grip.CFrame * CFrame.new(side * .43, .48, -.32)
		shell.Color, shell.Material = tuning.Color, Enum.Material.SmoothPlastic
		shell.CanCollide, shell.CanTouch, shell.CanQuery, shell.Massless = false, false, false, true
		shell.Parent = weapon
		local connection = Instance.new("WeldConstraint")
		connection.Part0, connection.Part1, connection.Parent = grip, shell, shell
	end
	addWeaponSilhouette(weapon, grip, level, tuning.Color)
	return weapon
end

local function equip(player, humanoid, level)
	local character = player.Character
	local backpack = player:FindFirstChildOfClass("Backpack")
	if not backpack then return false end
	local weapon = issued[player]
	if not weapon or weapon:GetAttribute("WeaponLevel") ~= level or (weapon.Parent ~= backpack and weapon.Parent ~= character) then
		if weapon then weapon:Destroy() end
		weapon = createWeapon(level)
		issued[player] = weapon
		weapon.Parent = backpack
	end
	humanoid:EquipTool(weapon)
	return weapon.Parent == character
end

local function finite(value)
	return value == value and math.abs(value) < math.huge
end

function Combat.start(options)
	local remote = Instance.new("RemoteEvent")
	remote.Name = "DeadzoneScrapPulse"
	local armory = Instance.new("RemoteEvent")
	armory.Name = "DeadzoneArsenal"
	local stations, nextSelection = {}, {}
	local function armoryAccess(player)
		local station = stations[options.getPlot(player)]
		local character, root, humanoid = getLivingCharacter(player)
		if not station or not station.Enabled or not root
			or not options.canUseWeapon(player, 1)
			or (root.Position - station.Parent.WorldPosition).Magnitude > config.StationRange then
			return nil
		end
		return character, humanoid
	end
	local function sendCatalog(player, character, action, message)
		local unlocked = {}
		for level in config.Weapons do
			unlocked[level] = options.canUseWeapon(player, level) == true
		end
		local tool = issued[player]
		local equipped = if tool and tool.Parent == character then tool:GetAttribute("WeaponLevel") else nil
		armory:FireClient(player, action, unlocked, equipped, message)
	end
	local function sparring(player)
		return options.isSparring and options.isSparring(player) == true
	end
	local function canAffect(player, target)
		if player == target or not options.getPlot(player) or not options.getPlot(target)
			or (options.isPaused and options.isPaused()) or sparring(player) ~= sparring(target) then return false end
		local a, origin = getLivingCharacter(player)
		local b, destination = getLivingCharacter(target)
		return a ~= nil and b ~= nil and not isProtected(a, origin, options.plots)
			and not isProtected(b, destination, options.plots)
			and (sparring(player) or (inArena(origin.Position) and inArena(destination.Position)))
			and (not options.allowsDamage or options.allowsDamage(player, target))
	end
	local function dealDamage(player, target, amount, kind)
		if not canAffect(player, target) then return false end
		local character, _, humanoid = getLivingCharacter(target)
		local held = character:FindFirstChildOfClass("Tool")
		local heldLoot = held and looted[target] and looted[target][held]
		local issuedLevel = held and issued[target] == held and held:GetAttribute("WeaponLevel")
		local snapshot = if heldLoot then heldLoot.level
			elseif issuedLevel and options.canUseWeapon(target, issuedLevel) then issuedLevel else nil
		local power = options.getPowers and options.getPowers()
		local regular = not sparring(player)
		if power and regular then amount = power.beforeDamage(player, target, amount, kind) end
		if typeof(amount) ~= "number" or not finite(amount) then return false end
		local before = humanoid.Health
		humanoid:TakeDamage(math.clamp(amount, 0, 1000))
		local applied = before - humanoid.Health
		if applied <= 0 then return false end
		if regular then
			if power then power.onHit(player, target, applied, kind) end
			hitEvent:Fire(player, target, applied)
		end
		if humanoid.Health <= 0 and not credited[humanoid] then
			credited[humanoid] = true
			if regular then
				player:SetAttribute("ArenaEliminations", (player:GetAttribute("ArenaEliminations") or 0) + 1)
				if power then power.onElimination(player, target, snapshot) end
				eliminationEvent:Fire(player, target)
			end
			remote:FireClient(player, "Eliminated " .. target.DisplayName .. ".")
			remote:FireClient(target, "Eliminated by " .. player.DisplayName .. ".")
		else
			remote:FireClient(player, "Pulse hit.")
		end
		return true
	end
	local function grantLootWeapon(player, level, ammo)
		local character = getLivingCharacter(player)
		local backpack = player:FindFirstChildOfClass("Backpack")
		if not character or not backpack or not config.Weapons[level] then return false end
		local owned = looted[player] or {}
		looted[player] = owned
		local count = 0
		for tool in owned do
			if tool.Parent == character or tool.Parent == backpack then count += 1 else owned[tool] = nil end
		end
		if count >= 2 then return false end
		local tool = createWeapon(level)
		tool.Name = "Looted " .. tool.Name
		tool:SetAttribute("ReserveAmmo", ammo)
		owned[tool] = {level = level, ammo = ammo}
		tool.Parent = backpack
		return true
	end
	for _, plot in ipairs(options.plots) do
		local marker = plot.Model.FutureStations.WeaponStation
		local station = Instance.new("Part")
		station.Name = "WeaponStation"
		station.Size = Vector3.new(5, 2.5, 3)
		station.CFrame = marker.CFrame * CFrame.new(0, 1.25, 0)
		station.Color = Color3.fromRGB(37, 104, 116)
		station.Material = Enum.Material.Metal
		station.Anchored = true
		station.Parent = plot.Model
		Art.station(station, plot.Theme[3])
		Art.crest(station, station.CFrame * CFrame.new(-1.82, -.17, 1.57), .40, plot.Index)
		local plate = Art.detail(station, "ArsenalPlate", station.CFrame * CFrame.new(.35, -.18, 1.62)
			* CFrame.Angles(-math.rad(12), 0, 0), Vector3.new(2.95, .58, .12), palette.Ink, Enum.Material.SmoothPlastic)
		local nameplate = Instance.new("SurfaceGui")
		nameplate.Name, nameplate.Face = "ArsenalNameplate", Enum.NormalId.Back
		nameplate.SizingMode, nameplate.PixelsPerStud = Enum.SurfaceGuiSizingMode.PixelsPerStud, 70
		nameplate.LightInfluence = 0
		nameplate.Parent = plate
		local title = Instance.new("TextLabel")
		title.Size = UDim2.fromScale(1, 1)
		title.BackgroundColor3 = palette.Ink
		title.Font, title.TextScaled = Enum.Font.GothamBold, true
		title.Text, title.TextColor3 = "ARSENAL", palette.Cream
		title.Parent = nameplate
		local rack = Art.detail(station, "ArsenalRack", station.CFrame * CFrame.new(0, 1.46, -.63),
			Vector3.new(4.2,.4,1.04), palette.Ink, Enum.Material.SmoothPlastic)
		for slot = -1, 1 do
			Art.detail(rack, "ArsenalIndicator", rack.CFrame * CFrame.new(slot * 1.26,.24,0),
				Vector3.new(.64,.1,.48), plot.Theme[3], Enum.Material.SmoothPlastic)
		end
		local interaction = Instance.new("Attachment")
		interaction.Name = "ArsenalInteraction"
		interaction.Position = Vector3.new(0, 1.8, 1.65)
		interaction.Parent = station
		local prompt = Instance.new("ProximityPrompt")
		prompt.Name = "OpenArsenal"
		prompt.ObjectText = "Arsenal"
		prompt.ActionText = "Open Arsenal"
		prompt.MaxActivationDistance = config.StationRange
		prompt.RequiresLineOfSight = false
		prompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
		prompt.Parent = interaction
		stations[plot] = prompt
		prompt.Triggered:Connect(function(player)
			if options.getPlot(player) ~= plot then return end
			local character = armoryAccess(player)
			if character then sendCatalog(player, character, "open") end
		end)
		plot.Construction.ArsenalBench = {station}
		Art.setBuilt(station, false)
	end
	armory.OnServerEvent:Connect(function(player, level)
		if type(level) ~= "number" or not finite(level) or not config.Weapons[level] then return end
		local now = os.clock()
		if now < (nextSelection[player] or 0) then return end
		nextSelection[player] = now + .2
		local character, humanoid = armoryAccess(player)
		if not character then
			armory:FireClient(player, "close")
			remote:FireClient(player, "Return to your own Arsenal to equip a weapon.")
			return
		end
		if not options.canUseWeapon(player, level) then
			sendCatalog(player, character, "refresh", "This weapon is still locked.")
			return
		end
		if equip(player, humanoid, level) then
			if not player:GetAttribute("StarterWeaponEquipped") then
				player:SetAttribute("ClaimFeedback", "Weapon ready. Try the Siege Console in the rear orange lane.")
			end
			player:SetAttribute("StarterWeaponEquipped", true)
			sendCatalog(player, character, "refresh", config.Weapons[level].Name .. " equipped.")
		else
			sendCatalog(player, character, "refresh", "Equip failed. Try again after respawning.")
		end
	end)
	remote.OnServerEvent:Connect(function(player, aim)
		if typeof(aim) ~= "Vector3" or not finite(aim.X) or not finite(aim.Y) or not finite(aim.Z) then return end
		local character, root = getLivingCharacter(player)
		local weapon = character and character:FindFirstChildOfClass("Tool")
		local copies = looted[player]
		local copy = weapon and copies and copies[weapon]
		if not root or not weapon or (weapon ~= issued[player] and not copy) or not options.getPlot(player) then return end
		local level = if copy then copy.level else weapon:GetAttribute("WeaponLevel") or 1
		if not copy and not options.canUseWeapon(player, level) then
			Combat.reset(player)
			return
		end
		local tuning = config.Weapons[level]
		local now = os.clock()
		if now < (nextPulse[player] or 0) then return end
		nextPulse[player] = now + tuning.Interval
		if options.isPaused and options.isPaused() then
			remote:FireClient(player, "Combat is paused.")
			return
		end
		if isProtected(character, root, options.plots) then
			remote:FireClient(player, "Leave the protected spawn to fire.")
			return
		end
		local sparring = options.isSparring and options.isSparring(player)
		local inPvP = sparring or inArena(root.Position)
		local inSiege = not sparring and options.canFireSiege(player, root.Position)
		local inOutbreak = not sparring and options.canFireOutbreak(player, root.Position)
		if not inPvP and not inSiege and not inOutbreak then
			remote:FireClient(player, "Fire in Reactor Crown, the orange outbreak zones, or during a raid.")
			return
		end
		local origin = root.Position + Vector3.new(0, 1, 0)
		local offset = aim - origin
		if offset.Magnitude < 0.1 or not finite(offset.Magnitude) then return end
		local power = options.getPowers and options.getPowers()
		if power and not sparring then
			if not power.canAttack(player) then return end
			if power.onAttack then power.onAttack(player) end
		end
		if copy then
			copy.ammo -= 1
			if copy.ammo > 0 then
				weapon:SetAttribute("ReserveAmmo", copy.ammo)
			else
				copies[weapon] = nil
				weapon:Destroy()
			end
		end
		local direction = offset.Unit
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {character}
		local reach = math.min(tuning.Reach, offset.Magnitude + 1)
		local hit = workspace:Raycast(origin, direction * reach, params)
		remote:FireAllClients("Pulse fired", origin, if hit then hit.Position else origin + direction * reach)
		if not hit then
			remote:FireClient(player, "Pulse missed.")
			return
		end
		local model = hit.Instance:FindFirstAncestorOfClass("Model")
		local pveDamage = (inSiege or inOutbreak) and options.pveDamage(player,tuning.Damage) or tuning.Damage
		if inSiege and model and options.hitSiege(player, model, pveDamage) then
			remote:FireClient(player, "Siege hit.")
			return
		end
		if inOutbreak and model and options.hitOutbreak(player, model, pveDamage) then
			remote:FireClient(player, "Outbreak hit.")
			return
		end
		if not inPvP then return end
		local target = model and Players:GetPlayerFromCharacter(model)
		if not target or target == player or not options.getPlot(target) then
			remote:FireClient(player, "Pulse missed.")
			return
		end
		local targetCharacter, targetRoot, humanoid = getLivingCharacter(target)
		if targetCharacter ~= model then return end
		local targetSparring = options.isSparring and options.isSparring(target)
		if (not not sparring) ~= (not not targetSparring) or (not sparring and not inArena(targetRoot.Position)) then
			remote:FireClient(player, "Target is outside your combat session.")
			return
		end
		if options.allowsDamage and not options.allowsDamage(player, target) then
			remote:FireClient(player, "This target is friendly.")
			return
		end
		if isProtected(targetCharacter, targetRoot, options.plots) then
			remote:FireClient(player, "Target is protected.")
			return
		end
		dealDamage(player, target, tuning.Damage, if level == 2 or level == 5 then "rapid" else "pulse")
	end)
	Players.PlayerRemoving:Connect(function(player)
		nextSelection[player] = nil
		Combat.reset(player)
	end)
	armory.Parent = ReplicatedStorage
	remote.Parent = ReplicatedStorage
	return {canAffect = canAffect, dealDamage = dealDamage, grantLootWeapon = grantLootWeapon, clearLoot = Combat.clearLoot}
end

return Combat
