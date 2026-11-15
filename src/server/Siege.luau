local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local Art = require(script.Parent.FactoryArt)
local config = require(game.ReplicatedStorage.Shared.SiegeConfig)
local Siege = {}
local ink = Color3.fromRGB(34, 46, 65)
local beacon = Color3.fromRGB(255, 169, 67)
local laneX = -35
local tickSeconds = .15

local function solid(parent, name, frame, size, color)
	local part = Art.detail(parent, name, frame, size, color, Enum.Material.Metal)
	part.CanQuery, part.CanCollide = true, true
	return part
end

local function prompt(part, name, action, caption)
	local attachment = Instance.new("Attachment")
	attachment.Position = Vector3.new(0, part.Size.Y / 2 + .4, 0)
	attachment.Parent = part
	local p = Instance.new("ProximityPrompt")
	p.Name, p.ActionText, p.ObjectText = name, action, caption
	p.MaxActivationDistance, p.RequiresLineOfSight = 9, false
	p.Parent, p.Enabled = attachment, false
	return p
end

local function living(player)
	local character = player and player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	return if humanoid and humanoid.Health > 0 and root then root else nil
end

local function inside(frame, position)
	local p = frame:PointToObjectSpace(position)
	return p.X >= -53 and p.X <= -13 and p.Y >= -.5 and p.Y < 10 and p.Z >= 29 and p.Z <= 78
end

local enemyModel = require(script.Parent.ZombieArt)

function Siege.start(options)
	local byPlot, byModel = {}, {}
	local total = 0
	local function update(s, message)
		if not s.owner then return end
		if message then s.message = message end
		local player = s.owner
		player:SetAttribute("SiegePhase", s.phase)
		player:SetAttribute("SiegeMessage", s.message)
		player:SetAttribute("SiegeDeadline", s.deadline)
		player:SetAttribute("SiegeWave", s.wave)
		player:SetAttribute("SiegeCore", s.core)
		player:SetAttribute("SiegeRemaining", s.phase == "active" and (#s.queue - s.spawned + s.count) or 0)
		player:SetAttribute("SiegeGateHealth", s.gateHP)
		player:SetAttribute("SiegeBarricadeHealth", s.wallHP)
	end

	local function remove(s, model)
		byModel[model], s.enemies[model] = nil, nil
		s.count -= 1
		total -= 1
		model:Destroy()
	end

	local function reset(plot)
		local s = byPlot[plot]
		if not s then return end
		for model in s.enemies do remove(s, model) end
		if s.owner then
			for _, key in {"Phase","Message","Deadline","Wave","Core","Remaining","GateHealth","BarricadeHealth"} do
				s.owner:SetAttribute("Siege"..key, nil)
			end
		end
		s.owner, s.phase, s.wave, s.deadline = nil, "idle", 0, 0
		s.gateHP, s.gateMax, s.wallHP, s.core = 0, 0, 0, config.CoreHealth
		s.hadWall, s.auto, s.retry, s.nextTurret = false, false, false, 0
		s.gate:SetAttribute("SiegeBreachOpen", false)
		Art.setBuilt(s.gate, false)
		s.gateInstalled = false
		s.wall:SetAttribute("SiegeBreachOpen", false)
		s.start.Enabled, s.repair.Enabled = false, false
	end

	local function repairClear(s, barrier)
		local p = OverlapParams.new()
		local characters = {}
		for _, player in Players:GetPlayers() do
			if player.Character then table.insert(characters, player.Character) end
		end
		p.FilterType, p.FilterDescendantsInstances = Enum.RaycastFilterType.Include, characters
		p.MaxParts = 1
		if #workspace:GetPartBoundsInBox(barrier.CFrame, barrier.Size + Vector3.new(.5,.5,2.5), p) > 0 then return false end
		for _, e in s.enemies do
			local localPoint = barrier.CFrame:PointToObjectSpace(e.position)
			if math.abs(localPoint.X) < barrier.Size.X/2+1 and math.abs(localPoint.Z) < barrier.Size.Z/2+1.8 then return false end
		end
		return true
	end

	local function begin(s, now)
		s.phase, s.deadline = "warning", now + config.Warning
		s.core = config.CoreHealth
		if not s.retry then s.wave += 1 end
		s.queue = config.Waves[math.min(s.wave, #config.Waves)]
		s.spawned, s.nextSpawn, s.nextTurret = 0, s.deadline, 0
		update(s, "Raid incoming at the orange rear lane. Keep the Relay Core intact.")
	end

	local function resolve(s, success, now, reason)
		if s.phase ~= "active" then return end
		s.phase, s.deadline = "resolved", now + 4
		for model in s.enemies do remove(s, model) end
		local reward = 0
		local profile = options.profiles[s.owner]
		if success and profile and s.plot.Owner == s.owner and options.getPlot(s.owner) == s.plot then
			reward = math.min(35 + math.min(s.wave, 5) * 20, options.maxWallet - profile.wallet)
			profile.wallet += reward
			options.publish(s.plot)
		end
		s.retry = not success
		s.auto = s.auto or success
		update(s, if success then "Raid cleared · +" .. reward .. " Scrap. Repair before the next raid."
			else reason .. " · Your Scrap and upgrades are safe. Repair and retry.")
	end

	local function eligible(s, player)
		local profile = options.profiles[player]
		return profile and profile.upgrades.StarterFactory and profile.upgrades.ArsenalBench and not options.isSparring(player)
			and s.owner == player and options.getPlot(player) == s.plot and s.plot.Owner == player
	end

	local function createStation(plot, frame, name, key, x, z, size, accent)
		local p = solid(plot.Model, name, frame * CFrame.new(x, .4+size.Y/2,z), size, accent)
		Art.station(p, plot.Theme[3])
		plot.Construction[key] = plot.Construction[key] or {}
		table.insert(plot.Construction[key], p)
		Art.setBuilt(p, false)
		return p
	end

	for _, plot in options.plots do
		local frame = plot.Model:GetPivot()
		local folder = Instance.new("Folder")
		folder.Name, folder.Parent = "SiegeActors", plot.Model
		local console = createStation(plot, frame, "SiegeConsole", "ArsenalBench", -30, 46, Vector3.new(2.5, 2.55, 2), beacon)
		local core = createStation(plot, frame, "RelayCore", "ArsenalBench", laneX, 33, Vector3.new(4, 4.3, 4), plot.Theme[2])
		for _, item in {{console, "SIEGE CONSOLE", "Training and repairs"}, {core, "RELAY CORE", "Protect this objective"}} do
			local board = Instance.new("BillboardGui")
			board.Adornee, board.Parent = item[1], item[1]
			board.Size, board.MaxDistance = UDim2.fromOffset(146, 40), 45
			board.StudsOffsetWorldSpace = Vector3.new(0, item[1].Size.Y/2+1.5, 0)
			local label = Instance.new("TextLabel")
			label.Size, label.Parent = UDim2.fromScale(1, 1), board
			label.BackgroundColor3, label.BackgroundTransparency = ink, .08
			label.TextColor3, label.Font, label.TextSize = Color3.new(1,1,1), Enum.Font.GothamBold, 13
			label.Text = item[2].."\n"..item[3]
			board.Enabled = false
		end
		local gate = createStation(plot, frame, "BreachGate", "SiegeGate", laneX, 58, Vector3.new(11, 5, 1.5), plot.Theme[2])
		-- A purchased gate is installed by the siege service once its footprint is clear.
		plot.Construction.SiegeGate = nil
		local reinforce = createStation(plot, frame, "GateShieldCoils", "SiegeReinforce", -42, 57, Vector3.new(2.8, 4.65, 2.25), beacon)
		local turret = createStation(plot, frame, "WatchTurret", "SiegeTurret", -44, 53, Vector3.new(2.6, 3.25, 2.6), plot.Theme[3])
		local heavy = createStation(plot, frame, "HeavyTurret", "SiegeHeavy", -46, 48.5, Vector3.new(3.4, 4.2, 3.2), Color3.fromRGB(255,117,97))
		local shock = createStation(plot, frame, "ShockTurret", "SiegeShock", -47, 57, Vector3.new(3.1, 3.4, 2.5), Color3.fromRGB(110,198,255))
		createStation(plot, frame, "RepairRelay", "SiegeAutoRepair", -45, 31, Vector3.new(2.75, 3.15, 2.75), Color3.fromRGB(130,224,116))
		local function trim(station, name, x, z, size, color, material)
			local p = Art.detail(station, name, station.CFrame * CFrame.new(x, station.Size.Y/2+.34, z), size, color, material)
			Art.setBuilt(p, false)
		end
		trim(turret, "PulseBarrel", 0, .5, Vector3.new(.75,.6,2.5), ink, Enum.Material.Metal)
		for _, side in {-1,1} do
			trim(heavy, "TwinBarrel", side*.65, .5, Vector3.new(.68,.68,3.3), ink, Enum.Material.Metal)
			trim(shock, "ShockCoil", side*.76, .2, Vector3.new(.72,1.12,2.6), shock.Color, Enum.Material.Neon)
			trim(reinforce, "ShieldCell", side*.76, .1, Vector3.new(.65,1.1,1.45), beacon, Enum.Material.Neon)
		end
		for z = 35, 72, 4 do
			for _, x in {laneX-5.7, laneX+5.7} do
				local marker = Art.detail(plot.Model, "SiegeLaneStripe", frame * CFrame.new(x,.425,z),
					Vector3.new(.36,.035,2.65), beacon, Enum.Material.SmoothPlastic)
				Art.setBuilt(marker, false)
				table.insert(plot.Construction.ArsenalBench, marker)
			end
		end
		-- The combat service contributes its own model to this group.
		local s = {plot=plot, frame=frame, folder=folder, corePart=core, gate=gate, wall=plot.Wall, console=console,
			turret=turret, heavy=heavy, shock=shock, enemies={}, count=0,
			start=prompt(console, "StartSiege", "Start training raid", "Siege Console"),
			repair=prompt(console, "RepairSiege", "Repair defenses · 12 Scrap", "Siege Console")}
		s.repair.KeyboardKeyCode, s.repair.GamepadKeyCode = Enum.KeyCode.F, Enum.KeyCode.ButtonY
		byPlot[plot] = s
		reset(plot)
		s.start.Triggered:Connect(function(player)
			local root = living(player)
			if not root or not eligible(s, player) or (root.Position-console.Position).Magnitude > 11
				or s.phase ~= "idle" or options.isPaused() then return end
			begin(s, workspace:GetServerTimeNow())
		end)
		s.repair.Triggered:Connect(function(player)
			local root, profile = living(player), options.profiles[player]
			if not root or not eligible(s, player) or not (profile.upgrades.SiegeGate or profile.upgrades.Walls)
				or (root.Position-console.Position).Magnitude > 11 or s.phase == "active" or s.phase == "warning" then return end
			if s.gateHP == s.gateMax and (not profile.upgrades.Walls or s.wallHP == 80) then return end
			if (profile.upgrades.SiegeGate and s.gateHP == 0 and not repairClear(s, gate))
				or (profile.upgrades.Walls and s.wallHP == 0 and not repairClear(s, s.wall)) then
				update(s, "Clear the gate and barricade before repairing.")
				return
			end
			if profile.wallet < 12 then
				player:SetAttribute("ClaimFeedback", "Repair costs 12 Scrap.")
				return
			end
			profile.wallet -= 12
			s.gateHP, s.wallHP = s.gateMax, if profile.upgrades.Walls then 80 else 0
			options.publish(plot)
			update(s, "Defenses repaired · 12 Scrap.")
			player:SetAttribute("ClaimFeedback", s.message)
		end)
	end

	local function damage(s, model, e, amount)
		e.health = math.max(0, e.health - amount)
		model:SetAttribute("Health", math.ceil(e.health))
		if e.health == 0 then remove(s, model) end
	end

	local function clearShot(origin, target, exclusions, model)
		local params = RaycastParams.new()
		params.FilterType, params.FilterDescendantsInstances = Enum.RaycastFilterType.Exclude, exclusions
		local hit = workspace:Raycast(origin, target-origin, params)
		return not hit or model and hit.Instance:IsDescendantOf(model)
	end

	local function turretShot(s, now, part, range, amount, shock)
		local exclusions = table.clone(s.laneExclusions)
		table.remove(exclusions, 1)
		table.insert(exclusions, part)
		local origin = part.Position + s.frame.UpVector * (part.Size.Y/2 + 1)
		local selected, target, nearest = nil, nil, range
		for model, e in s.enemies do
			local position = e.position + Vector3.new(0,2.2*e.data.Scale,0)
			local dist = (position-origin).Magnitude
			if dist < nearest and clearShot(origin, position, exclusions, model) then
				selected, target, nearest = model, e, dist
			end
		end
		if not selected then return end
		if shock and target.kind ~= "Abomination" then target.slowUntil = now + 1.6 end
		local position = target.position + Vector3.new(0,2.2*target.data.Scale,0)
		local beam = Art.detail(s.folder, "DefensePulse", CFrame.lookAt((origin+position)/2, position),
			Vector3.new(.12,.12,nearest), part.Color, Enum.Material.Neon)
		Debris:AddItem(beam, .13)
		damage(s, selected, target, amount)
	end

	local function barrierVisible(part, built, open)
		if not built or part:GetAttribute("SiegeBreachOpen") == open then return end
		part:SetAttribute("SiegeBreachOpen", open)
		Art.setBuilt(part, true)
	end

	local function advance(s, model, e, now)
		local gateTarget = s.gateHP > 0 and e.z > 58.3
		local wallTarget = not gateTarget and s.wallHP > 0 and e.z > 49.3
		local targetZ = if gateTarget then 59.2 elseif wallTarget then 50.1 else 35.2
		local ownerRoot = living(s.owner)
		local ownerNear = ownerRoot and inside(s.frame, ownerRoot.Position)
		local ranged = e.kind == "Spitter"
		local selfAim = e.position + Vector3.new(0, 2.1*e.data.Scale, 0)
		local ownerTarget = ownerNear and (ownerRoot.Position-selfAim).Magnitude < e.data.Reach
			and clearShot(selfAim, ownerRoot.Position, {s.folder}, ownerRoot.Parent)
		local reach = if ranged then 2.8 else e.data.Reach
		if not ownerTarget and e.z - targetZ > reach then
			local previous = e.position
			local step = math.min(e.z - targetZ, e.data.Speed * tickSeconds * (if now < e.slowUntil then .55 else 1))
			local nextPosition = s.frame:PointToWorldSpace(Vector3.new(e.x,.42,e.z-step))
			if clearShot(previous + Vector3.yAxis*1.7, nextPosition + Vector3.yAxis*1.7, s.laneExclusions) then
				e.z, e.position, e.blocked = e.z-step, nextPosition, 0
				local gait = e.z*(if e.kind == "Runner" then 3.8 else 2.5)
				model:PivotTo(s.frame * CFrame.new(e.x,.42 + .09*math.abs(math.sin(gait)),e.z)
					* CFrame.Angles(0, 0, math.sin(gait)*.07))
				return
			end
			e.blocked += 1
			-- Replan on the authored lane shoulders. Never lead actors across a plot boundary.
			if e.blocked % 5 == 0 then
				for _, x in {laneX-2.6,laneX+2.6,laneX} do
					local side = s.frame:PointToWorldSpace(Vector3.new(x,.42,e.z))
					local ahead = s.frame:PointToWorldSpace(Vector3.new(x,.42,e.z-1.2))
					if x ~= e.x and clearShot(previous+Vector3.yAxis*1.7, side+Vector3.yAxis*1.7, s.laneExclusions)
						and clearShot(side+Vector3.yAxis*1.7, ahead+Vector3.yAxis*1.7, s.laneExclusions) then
						e.x, e.position = x, side
						model:PivotTo(s.frame * CFrame.new(e.x,.42,e.z))
						break
					end
				end
			end
			if e.blocked >= 45 then resolve(s, false, now, "Raid stopped by an obstructed lane") end
			return
		end
		if now < e.nextAttack then return end
		if (ranged or e.kind == "Abomination") and not e.charging then
			e.charging = true
			e.nextAttack = now + (if ranged then .75 else 1.15)
			e.label.Text = if ranged then "SPIT INCOMING" else "HEAVY STRIKE"
			return
		end
		e.nextAttack, e.charging, e.label.Text = now + (if ranged then 2.1 else 1.3), false, e.kind
		local multiplier = if e.kind == "Saboteur" and not ownerTarget and (gateTarget or wallTarget) then 1.55 else 1
		local hit = math.floor(e.data.Damage * multiplier)
		if ownerTarget then
			options.hurtOwner(s.owner, ownerRoot.Parent:FindFirstChildOfClass("Humanoid"), hit)
		elseif gateTarget then
			s.gateHP = math.max(0, s.gateHP-hit)
		elseif wallTarget then
			s.wallHP = math.max(0, s.wallHP-hit)
		else
			s.core = math.max(0, s.core-hit)
		end
	end

	local function run(s, now)
		local p = s.plot.Owner
		local profile = p and options.profiles[p]
		if not profile or not profile.upgrades.StarterFactory or not profile.upgrades.ArsenalBench or options.isSparring(p) then
			if s.owner then reset(s.plot) end
			return
		end
		if p ~= s.owner then
			reset(s.plot)
			s.owner, s.auto = p, false
			s.message = "Start a training raid at the rear Siege Console when ready."
		end
		local u = profile.upgrades
		if u.SiegeGate and not s.gateInstalled and repairClear(s, s.gate) then
			Art.setBuilt(s.gate, true)
			s.gateInstalled = true
		elseif not u.SiegeGate and s.gateInstalled then
			Art.setBuilt(s.gate, false)
			s.gateInstalled = false
		end
		local max = if not s.gateInstalled then 0 elseif u.SiegeReinforce then 320 else 180
		if max ~= s.gateMax then s.gateHP += max-s.gateMax; s.gateMax = max end
		if u.Walls and not s.hadWall then s.wallHP = 80 end
		s.hadWall = u.Walls == true
		if options.isPaused() then
			s.deadline += tickSeconds
			update(s, "Siege paused by the owner.")
			return
		end
		local safe = s.phase ~= "warning" and s.phase ~= "active"
		s.start.Enabled = s.phase == "idle"
		s.start.ActionText = if s.wave == 0 then "Start training raid"
			elseif s.retry then "Retry raid" else "Start next raid"
		s.repair.Enabled = safe and (s.gateHP < s.gateMax or u.Walls == true and s.wallHP < 80)
		if safe and u.SiegeAutoRepair then
			if s.gateHP < s.gateMax and (s.gateHP > 0 or repairClear(s, s.gate)) then s.gateHP = math.min(s.gateMax,s.gateHP+10*tickSeconds) end
			if u.Walls and s.wallHP < 80 and (s.wallHP > 0 or repairClear(s, s.wall)) then s.wallHP = math.min(80,s.wallHP+10*tickSeconds) end
		end
		if s.phase == "warning" and now >= s.deadline then
			s.phase, s.deadline = "active", now+config.Timeout
			update(s, "Defend the Relay Core. Shoot the incoming zombies.")
		elseif s.phase == "resolved" and now >= s.deadline then
			s.phase, s.deadline = "recovery", now+config.Recovery
		elseif s.phase == "recovery" and now >= s.deadline then
			s.phase, s.deadline = "idle", if s.auto then now+config.Interval else 0
			update(s, if s.auto then "Next raid scheduled. Start it early at the console." else "Ready to retry at the console.")
		elseif s.phase == "idle" and s.auto and now >= s.deadline then
			local root = living(p)
			if root and inside(s.frame, root.Position) then begin(s,now)
			else
				s.deadline = now+10
				update(s, "Raid is waiting for you to return to your rear defense lane.")
			end
		end
		if s.phase == "active" then
			s.laneExclusions = {s.folder}
			for _, player in Players:GetPlayers() do
				if player.Character then table.insert(s.laneExclusions, player.Character) end
			end
			if s.spawned < #s.queue and s.count < config.PlotCap and total < config.ServerCap and now >= s.nextSpawn then
				s.spawned += 1
				local kind = s.queue[s.spawned]
				local data = config.Enemies[kind]
				local model, label = enemyModel(s.folder, kind, data)
				local x, z = laneX+({0,-2.2,2.2})[(s.spawned-1)%3+1], 72
				local position = s.frame:PointToWorldSpace(Vector3.new(x,.42,z))
				model:PivotTo(s.frame * CFrame.new(x,.42,z))
				model:SetAttribute("Health", data.Health)
				s.enemies[model] = {kind=kind,data=data,health=data.Health,x=x,z=z,position=position,label=label,
					nextAttack=now,slowUntil=0,blocked=0}
				byModel[model] = s
				s.count, total, s.nextSpawn = s.count+1, total+1, now + (if s.wave == 1 then 5 else 2.2)
			end
			for model, e in s.enemies do
				advance(s,model,e,now)
				if s.phase ~= "active" then break end
			end
			if s.phase == "active" and now >= s.nextTurret then
				s.nextTurret = now+1
				if u.SiegeTurret then turretShot(s,now,s.turret,30,12,false) end
				if u.SiegeHeavy then turretShot(s,now,s.heavy,36,24,false) end
				if u.SiegeShock then turretShot(s,now,s.shock,32,6,true) end
			end
			if s.core <= 0 then resolve(s,false,now,"Relay Core breached")
			elseif s.count == 0 and s.spawned == #s.queue then resolve(s,true,now)
			elseif now >= s.deadline then resolve(s,false,now,"Raid timed out") end
		end
		barrierVisible(s.gate, s.gateInstalled, s.gateHP <= 0)
		barrierVisible(s.wall, u.Walls, s.wallHP <= 0)
		update(s)
	end

	task.spawn(function()
		while task.wait(tickSeconds) do
			local now = workspace:GetServerTimeNow()
			for _, s in byPlot do run(s, now) end
		end
	end)
	return {
		reset = reset,
		canFire = function(player, position)
			local s = byPlot[options.getPlot(player)]
			return s and s.phase == "active" and eligible(s, player) and inside(s.frame,position)
		end,
		hit = function(player, model, amount)
			local s = byModel[model]
			local root = living(player)
			if not s or not root or not eligible(s, player)
				or s.phase ~= "active" or not inside(s.frame, root.Position) then return false end
			damage(s, model, s.enemies[model], amount)
			return true
		end,
	}
end

return Siege
