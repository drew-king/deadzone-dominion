local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Config = require(ReplicatedStorage.Shared.PowerConfig)
local Weapons = require(ReplicatedStorage.Shared.CombatConfig).Weapons
local Powers = {}

function Powers.start(options)
	local active = RunService:IsStudio() and options.enabled ~= false
	local tuning = {}
	for name, entry in Config do tuning[name] = table.clone(entry) end
	local tuningRevisions = {}
	local states, pickups = {}, {}
	local connections = {}
	local random = Random.new()
	local remote = Instance.new("RemoteEvent")
	remote.Name = "DeadzonePowerAction"

	local function clock() return workspace:GetServerTimeNow() end
	local function identity(player)
		if not active or not player or not options.getPlot(player)
			or (options.isSparring and options.isSparring(player)) then return nil end
		local name = player:GetAttribute("AdminPowerIdentity") or player:GetAttribute("ClaimedPower")
		return Config[name] and name or nil
	end

	local function body(player)
		local model = player.Character
		return model and model:FindFirstChildOfClass("Humanoid"), model and model:FindFirstChild("HumanoidRootPart")
	end

	local function notify(player, message)
		player:SetAttribute("PowerState", message)
	end

	local function stopBoost(player, state)
		if state.boostHumanoid and state.boostHumanoid.Parent and state.boostHumanoid.WalkSpeed == state.boostSpeed then
			state.boostHumanoid.WalkSpeed = state.normalSpeed
		end
		state.boostHumanoid = nil
		state.boostUntil = nil
		player:SetAttribute("PowerBoostUntil", nil)
	end

	local function stopDance(player, state)
		if state.danceTrack then
			state.danceTrack:Stop(0.15)
			state.danceTrack:Destroy()
			state.danceTrack = nil
		end
		state.danceAt = nil
		player:SetAttribute("PowerDancing", nil)
	end

	local function removePickup(id)
		local pickup = pickups[id]
		if not pickup then return end
		pickups[id] = nil
		if pickup.owner.Parent == Players then remote:FireClient(pickup.owner, "remove", id) end
	end

	local function reset(player, keepCooldown)
		local old = states[player]
		if old then
			stopDance(player, old)
			stopBoost(player, old)
			if old.reviveField then old.reviveField:Destroy() end
		end
		for id, pickup in pickups do if pickup.owner == player then removePickup(id) end end
		local current = identity(player)
		states[player] = if current then {
			name = current,
			armor = 0,
			charges = 0,
			eliminations = 0,
			cooldown = if keepCooldown and old and old.name == current then old.cooldown else nil,
		} else nil
		player:SetAttribute("ActivePower", current)
		player:SetAttribute("PowerArmor", if current == "JuggerJigg" then 0 else nil)
		player:SetAttribute("PowerCharges", if current == "Double Pop" then 0 else nil)
		player:SetAttribute("PowerDancing", nil)
		player:SetAttribute("PowerCooldownUntil", states[player] and states[player].cooldown)
		player:SetAttribute("PowerBoostUntil", nil)
		player:SetAttribute("PowerState", nil)
		if old and old.name ~= current and options.clearLootWeapons then options.clearLootWeapons(player) end
	end

	local function getState(player)
		local name = identity(player)
		local state = states[player]
		if name ~= (state and state.name) then
			reset(player, false)
			state = states[player]
		end
		return state
	end

	local function onAttack(player)
		local state = getState(player)
		if state then stopDance(player, state) end
	end

	local function canAttack(player)
		local state = getState(player)
		return not state or not state.transformUntil or clock() >= state.transformUntil
	end

	local function beforeDamage(attacker, target, amount, kind)
		local attack = attacker and getState(attacker)
		local defend = getState(target)
		local current = clock()
		local weaponHit = kind == nil or kind == "weapon" or kind == "pulse" or kind == "rapid" or kind == "Scrap Pulse"
		local humanoid, root = body(target)
		if not humanoid or not root or humanoid.Health <= 0 then return 0 end
		if defend and defend.reviveUntil and current < defend.reviveUntil then return 0 end
		if attack and attack.name == "Double Pop" and weaponHit and attack.charges > 0
			and current < attack.chargeUntil then
			amount *= tuning["Double Pop"].multiplier
		end
		if attack and attack.name == "CritShot" and weaponHit and amount > 0
			and random:NextNumber() < tuning.CritShot.chance then
			amount = humanoid.Health + (defend and defend.armor or 0)
			notify(attacker, "Critical pulse")
		end
		if defend and defend.armor > 0 then
			local absorbed = math.min(defend.armor, amount)
			defend.armor -= absorbed
			amount -= absorbed
			target:SetAttribute("PowerArmor", math.floor(defend.armor))
		end
		if defend and defend.name == "Rising Sun" and amount >= humanoid.Health
			and current >= (defend.cooldown or 0) then
			local config = tuning["Rising Sun"]
			local character = humanoid.Parent
			defend.cooldown = current + config.cooldown
			defend.transformUntil = current + config.transformation
			defend.reviveUntil = current + config.transformation + config.protection
			target:SetAttribute("PowerCooldownUntil", defend.cooldown)
			local field = Instance.new("ForceField")
			field.Name = "RisingSunProtection"
			field.Visible = false
			field.Parent = character
			defend.reviveField = field
			local highlight = Instance.new("Highlight")
			highlight.FillColor = Color3.fromRGB(160, 164, 175)
			highlight.OutlineTransparency = 1
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = field
			highlight.Adornee = character
			notify(target, "Rising Sun · reviving")
			remote:FireAllClients("effect", "revive", root.Position)
			task.delay(config.transformation, function()
				if states[target] ~= defend or target.Character ~= character or humanoid.Health <= 0 then return end
				humanoid.Health = math.max(humanoid.Health, humanoid.MaxHealth * config.restoreFraction)
				highlight.FillColor = Color3.fromRGB(255, 207, 89)
				notify(target, "Rising Sun · protected")
			end)
			task.delay(config.transformation + config.protection, function()
				field:Destroy()
				if states[target] == defend then
					defend.reviveField = nil
					notify(target, "Rising Sun · cooldown")
				end
			end)
			return 0
		end
		return amount
	end

	local function onHit(attacker, target, applied, kind)
		local state = getState(attacker)
		if not state or applied <= 0 or kind == "landing" then return end
		local current = clock()
		if state.name == "Double Pop" and state.charges > 0 and current < state.chargeUntil then
			state.charges -= 1
			attacker:SetAttribute("PowerCharges", state.charges)
		elseif state.name == "Spam-Him-Up" then
			local config = tuning[state.name]
			if state.lastTarget ~= target.Character or state.lastWeapon ~= kind or current > (state.hitUntil or 0) then
				state.streak = 0
			end
			state.lastTarget, state.lastWeapon, state.hitUntil = target.Character, kind, current + config.streakWindow
			state.streak = (state.streak or 0) + 1
			local threshold = if kind == "rapid" then config.fastHits else config.hits
			if state.streak >= threshold then
				state.streak = 0
				local humanoid = body(attacker)
				if humanoid then
					stopBoost(attacker, state)
					state.boostHumanoid, state.normalSpeed = humanoid, humanoid.WalkSpeed
					state.boostSpeed = humanoid.WalkSpeed * (1 + config.speedBonus)
					state.boostUntil = current + config.duration
					humanoid.WalkSpeed = state.boostSpeed
					attacker:SetAttribute("PowerBoostUntil", state.boostUntil)
				end
			end
		end
	end

	local function spawnPickup(owner, position, kind, duration, weaponLevel)
		local oldestId, oldest = nil, math.huge
		local count = 0
		for id, pickup in pickups do
			if pickup.owner == owner then
				count += 1
				if pickup.expiry < oldest then oldestId, oldest = id, pickup.expiry end
			end
		end
		if count >= 4 and oldestId then removePickup(oldestId) end
		local id = HttpService:GenerateGUID(false)
		local expiry = clock() + duration
		pickups[id] = {owner = owner, position = position, kind = kind, expiry = expiry, weaponLevel = weaponLevel}
		remote:FireClient(owner, "pickup", id, position, kind, expiry, weaponLevel and Weapons[weaponLevel].Name)
	end

	local function onElimination(attacker, target, weaponSnapshot)
		local state = getState(attacker)
		if not state then return end
		if state.name == "Double Pop" then
			local config = tuning[state.name]
			state.eliminations += 1
			if state.eliminations >= config.eliminations then
				state.eliminations = 0
				state.charges = config.charges
				state.chargeUntil = clock() + config.duration
				attacker:SetAttribute("PowerCharges", state.charges)
			end
		end
		local _, root = body(target)
		if root and state.name == "SlurperAid" then
			spawnPickup(attacker, root.Position + Vector3.new(0, 3.5, 0), "heal", tuning.SlurperAid.lootDuration)
		elseif root and state.name == "PolarBear Kick" and weaponSnapshot and Weapons[weaponSnapshot] then
			spawnPickup(attacker, root.Position + Vector3.new(0, 1.5, 0), "weapon", tuning[state.name].lootDuration, weaponSnapshot)
		end
	end

	local function collect(player, state, id)
		local pickup = type(id) == "string" and pickups[id]
		if not pickup or pickup.owner ~= player or clock() >= pickup.expiry then return end
		local humanoid, root = body(player)
		if not humanoid or humanoid.Health <= 0 or not root or (root.Position - pickup.position).Magnitude > 9 then return end
		if pickup.kind == "heal" and state.name == "SlurperAid" then
			if humanoid.Health >= humanoid.MaxHealth then
				remote:FireClient(player, "effect", "fullHeal", pickup.position)
			else
				humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * tuning.SlurperAid.healFraction)
			end
			removePickup(id)
		elseif pickup.kind == "weapon" and state.name == "PolarBear Kick" and options.grantLootWeapon
			and options.grantLootWeapon(player, pickup.weaponLevel, tuning[state.name].ammo) then
			removePickup(id)
		end
	end

	remote.OnServerEvent:Connect(function(player, action, argument)
		local state = getState(player)
		local current = clock()
		if not state or current < (state.nextInput or 0) then return end
		state.nextInput = current + 0.2
		if action == "collect" then
			collect(player, state, argument)
		elseif action == "dance" and state.name == "JuggerJigg" then
			local humanoid = body(player)
			if not humanoid or humanoid.Health <= 0 then return end
			if state.danceAt then stopDance(player, state); return end
			state.danceAt = current + tuning.JuggerJigg.startup
			player:SetAttribute("PowerDancing", true)
			local animator = humanoid:FindFirstChildOfClass("Animator")
			if animator then
				local animation = Instance.new("Animation")
				animation.AnimationId = if humanoid.RigType == Enum.HumanoidRigType.R15
					then "rbxassetid://507771019" else "rbxassetid://182435998"
				local ok, track = pcall(animator.LoadAnimation, animator, animation)
				animation:Destroy()
				if ok then
					state.danceTrack = track
					track.Looped = true
					track.Priority = Enum.AnimationPriority.Action
					track:Play(0.15)
				end
			end
		end
	end)

	local function track(player)
		local function refresh()
			getState(player)
		end
		connections[player] = {
			player:GetAttributeChangedSignal("ClaimedPower"):Connect(refresh),
			player:GetAttributeChangedSignal("AdminPowerIdentity"):Connect(refresh),
			player:GetAttributeChangedSignal("PlaytestPreset"):Connect(refresh),
			player.CharacterRemoving:Connect(function() reset(player, true) end),
		}
		refresh()
	end
	Players.PlayerAdded:Connect(track)
	Players.PlayerRemoving:Connect(function(player)
		for _, connection in connections[player] or {} do connection:Disconnect() end
		connections[player] = nil
		reset(player, false)
		states[player] = nil
	end)
	for _, player in Players:GetPlayers() do track(player) end

	if active then
		task.spawn(function()
			while true do
				local elapsed = math.min(task.wait(0.1), 0.25)
				local current = clock()
				for id, pickup in pickups do if current >= pickup.expiry then removePickup(id) end end
				for player, state in states do
					local humanoid, root = body(player)
					if state.boostUntil and current >= state.boostUntil then stopBoost(player, state) end
					if state.charges > 0 and current >= state.chargeUntil then
						state.charges = 0
						player:SetAttribute("PowerCharges", 0)
					end
					if humanoid and root and humanoid.Health > 0 then
						if state.danceAt then
							if humanoid.MoveDirection.Magnitude > 0.1 or humanoid.FloorMaterial == Enum.Material.Air then
								stopDance(player, state)
							elseif current >= state.danceAt then
								state.armor = math.min(tuning.JuggerJigg.maxArmor, state.armor + elapsed * tuning.JuggerJigg.armorRate)
								player:SetAttribute("PowerArmor", math.floor(state.armor))
							end
						end
						if state.name == "PlopperFizz" then
							local y = root.Position.Y
							if humanoid.FloorMaterial == Enum.Material.Air then
								state.fallPeak = math.max(y, state.fallPeak or state.lastGround or y)
							else
								local descent = state.fallPeak and state.fallPeak - y or 0
								local priorGround = state.lastGround
								state.fallPeak, state.lastGround = nil, y
								local config = tuning.PlopperFizz
								if descent >= config.descent and priorGround and priorGround - y >= 2 and options.dealDamage
									and not (options.isSparring and options.isSparring(player)) then
									remote:FireAllClients("effect", "landing", root.Position)
									for _, target in Players:GetPlayers() do
										local targetHumanoid, targetRoot = body(target)
										if target ~= player and targetRoot and targetHumanoid and targetHumanoid.Health > 0
											and (targetRoot.Position - root.Position).Magnitude <= config.radius
											and options.canAffect and options.canAffect(player, target) then
											options.dealDamage(player, target, math.min(config.maxDamage, descent * config.damagePerStud), "landing")
										end
									end
								end
							end
						end
					end
				end
			end
		end)
	end

	remote.Parent = ReplicatedStorage
	return {
		beforeDamage = beforeDamage,
		onAttack = onAttack,
		onHit = onHit,
		onElimination = onElimination,
		canAttack = canAttack,
		reset = reset,
		incomeMultiplier = function(player)
			return if identity(player) == "CritShot" then tuning.CritShot.incomeMultiplier else 1
		end,
		admin = function(action, target, arg)
			if not active or not target then return false, "Power controls require Studio and a player." end
			if action == "resetPowerCooldown" then
				local state = getState(target)
				if not state then return false, "No active power." end
				state.cooldown = nil
				target:SetAttribute("PowerCooldownUntil", nil)
			elseif action == "clearPowerEffects" then
				reset(target, true)
			elseif action == "setPowerTuning" then
				local state = getState(target)
				if not state or type(arg) ~= "table" or type(arg.key) ~= "string"
					or type(arg.value) ~= "number" or not (arg.value > 0 and arg.value < math.huge) then
					return false, "Select an active power and enter a tuning field and positive value."
				end
				local default = Config[state.name][arg.key]
				local fixed = state.name == "CritShot" and (arg.key == "chance" or arg.key == "incomeMultiplier")
				if fixed or not default or arg.value < default * 0.5 or arg.value > default * 1.5 then
					return false, "Tuning must remain within 50–150% of the default. CritShot odds and income are fixed."
				end
				if (arg.key == "hits" or arg.key == "fastHits" or arg.key == "charges"
					or arg.key == "eliminations" or arg.key == "ammo") and arg.value % 1 ~= 0 then
					return false, "That tuning field requires a whole number."
				end
				if arg.key == "restoreFraction" or arg.key == "healFraction" then
					if arg.value > 1 then return false, "Fraction cannot exceed 1." end
				end
				local name, key = state.name, arg.key
				local tuneId = name .. ":" .. key
				local revision = (tuningRevisions[tuneId] or 0) + 1
				tuningRevisions[tuneId] = revision
				tuning[name][key] = arg.value
				task.delay(120, function()
					if tuningRevisions[tuneId] == revision then tuning[name][key] = default end
				end)
				return true, string.format("%s %s updated for 120 seconds in this Studio server.", name, key)
			else
				return false, "Unknown power command."
			end
			return true, "Power state updated."
		end,
	}
end

return Powers
