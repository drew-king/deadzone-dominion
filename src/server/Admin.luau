local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")

local Admin = {}

local economyActions = {
	grantCash = true, deductCash = true, setCash = true, clearPending = true,
	grantUpgrade = true, productionRate = true, costRate = true, pauseProduction = true,
	pauseCombat = true, releasePlot = true, resetPlot = true, preset = true,
}

local previewActions = {
	setCash = true, clearPending = true, releasePlot = true, resetPlot = true,
	productionRate = true, costRate = true, preset = true, bulkCash = true, setPowerTuning = true,
}

local targetActions = {
	grantCash = true, deductCash = true, setCash = true, clearPending = true,
	grantUpgrade = true, releasePlot = true, resetPlot = true, preset = true,
	teleport = true, respawn = true, protect = true, assignPower = true, revokePower = true, lockPower = true,
	resetPowerCooldown = true, clearPowerEffects = true, setPowerTuning = true,
	rollback = true,
}

local function validNumber(value, min, max)
	return type(value) == "number" and value == value and value >= min and value <= max
end

local OWNER_USER_ID = 1575469696

local function authorized(player)
	if RunService:IsStudio() and player.UserId == -1 then return true end
	return player.UserId == OWNER_USER_ID
end

local function sameState(a, b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for key, value in pairs(a) do
		if not sameState(value, b[key]) then return false end
	end
	for key in pairs(b) do
		if a[key] == nil then return false end
	end
	return true
end

function Admin.start(api)
	local names, powers = {}, {}
	local maxWallet = require(ReplicatedStorage.Shared.EconomyConfig).MaxWallet
	for _, entry in ipairs(require(ReplicatedStorage.Shared.MapConfig).Plots) do
		names[entry[1]] = true
		table.insert(powers, entry[1])
	end

	local remote = Instance.new("RemoteFunction")
	remote.Name = "DominionControl"
	local announce = Instance.new("RemoteEvent")
	announce.Name = "DominionAnnouncement"
	announce.Parent = ReplicatedStorage

	local audit = {}
	local previousRequest, previews, undo = {}, {}, {}
	local function record(actor, target, action, reason, ok, message, before, after)
		table.insert(audit, 1, {
			actor = actor.UserId, target = target and target.UserId or nil,
			action = action, reason = reason, ok = ok, result = message,
			scope = target and "Player" or "Server", time = os.time(), before = before, after = after,
		})
		if #audit > 100 then table.remove(audit) end
	end

	local function inspect(player)
		local result = api.inspect(player) or {}
		result.arenaEliminations = player:GetAttribute("ArenaEliminations") or 0
		result.weaponEquipped = player:GetAttribute("StarterWeaponEquipped") == true
		result.power = player:GetAttribute("AdminPowerIdentity")
		result.powerLocked = player:GetAttribute("AdminPowerLocked") == true
		result.protected = player.Character ~= nil and player.Character:FindFirstChild("DominionAdminProtection") ~= nil
		result.playtestUntil = player:GetAttribute("AdminPlaytestUntil")
		return result
	end

	Players.PlayerRemoving:Connect(function(player)
		previousRequest[player] = nil
		previews[player] = nil
		undo[player] = nil
		for actor, entry in pairs(undo) do
			if entry.target == player then undo[actor] = nil end
		end
	end)

	local function validate(action, arg)
		if action == "grantCash" or action == "deductCash" or action == "setCash" or action == "bulkCash" then
			return validNumber(arg, action == "setCash" and 0 or 1, maxWallet) and arg % 1 == 0, {amount = arg}
		elseif action == "productionRate" or action == "costRate" then
			return validNumber(arg, 0.25, 8), {amount = arg}
		elseif action == "grantUpgrade" then
			return arg == "Walls" or arg == "Production", {upgrade = arg}
		elseif action == "pauseProduction" or action == "pauseCombat" then
			return type(arg) == "boolean", {enabled = arg}
		elseif action == "preset" then
			return RunService:IsStudio() and (arg == "fresh" or arg == "first" or arg == "upgraded" or arg == "sparring"), {preset = arg}
		elseif action == "setPowerTuning" then
			local key, value
			if type(arg) == "string" and #arg <= 48 then key, value = arg:match("^([%a]+)=([%d%.]+)$") end
			local number = tonumber(value)
			return RunService:IsStudio() and key ~= nil and number ~= nil, {key = key, value = number}
		elseif action == "assignPower" then
			return type(arg) == "string" and names[arg] == true, {}
		elseif action == "protect" or action == "lockPower" then
			return validNumber(arg, 1, 300) and arg % 1 == 0, {}
		elseif action == "clock" then
			return validNumber(arg, 0, 23.99), {}
		elseif action == "announce" then
			return type(arg) == "string" and #arg >= 1 and #arg <= 160, {}
		elseif action == "teleport" then
			return arg == "reactor" or arg == "plot", {}
		end
		return arg == nil, {}
	end

	remote.OnServerInvoke = function(actor, action, targetId, arg, reason, confirm)
		if not authorized(actor) then return {ok = false, message = "Access denied."} end
		local now = os.clock()
		if now - (previousRequest[actor] or -math.huge) < 0.2 then
			return {ok = false, message = "Wait before sending another command."}
		end
		previousRequest[actor] = now
		if action == "list" then
			local roster = {}
			for _, player in ipairs(Players:GetPlayers()) do
				table.insert(roster, {id = player.UserId, name = player.Name, displayName = player.DisplayName})
			end
			return {ok = true, players = roster, powers = powers, studio = RunService:IsStudio()}
		end
		if action == "audit" then return {ok = true, audit = audit} end
		if type(action) ~= "string" or #action > 32 then return {ok = false, message = "Unknown command."} end
		local target = if validNumber(targetId, -100, 9e15) and targetId % 1 == 0
			then Players:GetPlayerByUserId(targetId) else nil
		if action == "inspect" then
			return if target then {ok = true, state = inspect(target)} else {ok = false, message = "Select a connected player."}
		end
		if targetActions[action] and not target then return {ok = false, message = "Select a connected player."} end
		if not targetActions[action] then target = nil end
		local valid, payload = validate(action, arg)
		if not valid then return {ok = false, message = "Invalid value or unavailable in this server."} end
		if reason ~= nil and (type(reason) ~= "string" or #reason > 100) then
			return {ok = false, message = "Keep the reason within 100 bytes."}
		end
		local before = if target then inspect(target) else nil
		if action == "clock" then before = {clock = Lighting.ClockTime} end

		if previewActions[action] then
			local pending = previews[actor]
			if confirm == nil then
				local token = HttpService:GenerateGUID(false)
				local affected = {}
				local impact = {}
				if action == "bulkCash" then
					for _, player in ipairs(Players:GetPlayers()) do
						local wallet = inspect(player).wallet
						affected[player] = wallet
						table.insert(impact, string.format("%s: %d → %d", player.Name, wallet, math.min(maxWallet, wallet + arg)))
					end
				end
				previews[actor] = {action = action, target = target, arg = arg, reason = reason,
					before = before, token = token, affected = affected, expires = now + 30}
				local description = if action == "bulkCash" then string.format(
					"Grant %d Scrap to %d connected players: %s", arg, #impact, table.concat(impact, "; "))
					elseif action == "setCash" then string.format("Set %s's wallet: %d → %d", target.Name, before.wallet, arg)
					elseif action == "clearPending" then string.format("Clear %s's pending output: %d → 0", target.Name, before.pending)
					elseif action == "resetPlot" then "Clear the selected plot's pending output and installed upgrades."
					elseif action == "releasePlot" then "Release the selected plot and move its owner to neutral spawn."
					elseif action == "preset" then "Load isolated Studio playtest preset: " .. arg
					elseif action == "setPowerTuning" then "Set Studio server tuning for the selected player's power: " .. arg .. " (120 seconds)."
					else string.format("Set server multiplier to %.2f.", arg)
				return {ok = true, preview = token, state = before,
					message = description .. " Confirm within 30 seconds."}
			end
			previews[actor] = nil
			if not pending or pending.expires < now or pending.action ~= action
				or pending.target ~= target or pending.arg ~= arg or pending.reason ~= reason or pending.token ~= confirm then
				return {ok = false, message = "Create a fresh preview before confirming."}
			end
			if action == "bulkCash" then
				local roster = Players:GetPlayers()
				local affectedCount = 0
				for _ in pairs(pending.affected) do affectedCount += 1 end
				if #roster ~= affectedCount then return {ok = false, message = "Roster changed. Preview again."} end
				for _, player in ipairs(roster) do
					if pending.affected[player] ~= inspect(player).wallet then
						return {ok = false, message = "Roster or balances changed. Preview again."}
					end
				end
				local applied = 0
				for _, player in ipairs(roster) do
					local ok, message, old, new = api.command("grantCash", player, payload)
					record(actor, player, action, reason, ok, message, old, new)
					if ok then applied += 1 end
				end
				return {ok = applied == #roster, message = string.format("Updated %d of %d wallets.", applied, #roster)}
			end
			if action ~= "clearPending" and not sameState(before, pending.before) then
				-- Live income is expected to advance the pending buffer during a preview.
				if type(before) == "table" and type(pending.before) == "table" then
					pending.before.pending = before.pending
				end
				if not sameState(before, pending.before) then
					return {ok = false, message = "The target changed. Create a fresh preview."}
				end
			end
		end

		local ok, message, suppliedBefore, suppliedAfter
		if action == "rollback" then
			local entry = undo[actor]
			if not entry or entry.target ~= target or entry.expires < now then
				ok, message = false, "No recent reversible economy change for this player."
			else
				ok, message, suppliedBefore, suppliedAfter = api.command("rollback", target, {before = entry.before, after = entry.after})
				if ok then undo[actor] = nil end
			end
		elseif economyActions[action] then
			ok, message, suppliedBefore, suppliedAfter = api.command(action, target, payload)
		elseif action == "assignPower" or action == "revokePower" then
			if target:GetAttribute("AdminPowerLocked") then
				ok, message = false, "That power identity is locked."
			else
				target:SetAttribute("AdminPowerIdentity", if action == "assignPower" then arg else nil)
				ok, message = true, "Power identity updated. Gameplay effect is preview only."
			end
		elseif action == "lockPower" then
			local expiry = workspace:GetServerTimeNow() + arg
			target:SetAttribute("AdminPowerLockUntil", expiry)
			target:SetAttribute("AdminPowerLocked", true)
			task.delay(arg, function()
				if target.Parent == Players and target:GetAttribute("AdminPowerLockUntil") == expiry then
					target:SetAttribute("AdminPowerLockUntil", nil)
					target:SetAttribute("AdminPowerLocked", nil)
				end
			end)
			ok, message = true, string.format("Power identity locked for %d seconds.", arg)
		elseif action == "teleport" then
			local root = workspace:FindFirstChild("DeadzonePhase1")
			local plotName = before and before.plot
			local plot = root and type(plotName) == "string" and root:FindFirstChild(plotName)
			local point = if arg == "reactor" then CFrame.new(0, 9, 10)
				elseif plot and plot:IsA("Model") then plot:GetPivot() * CFrame.new(0, 5, 38) else nil
			if point and target.Character then
				target.Character:PivotTo(point)
				ok, message = true, "Player moved."
			else
				ok, message = false, "No character or claimed plot available."
			end
		elseif action == "respawn" then
			task.spawn(function()
				if target.Parent == Players then
					local success, failure = pcall(target.LoadCharacterAsync, target)
					if not success then warn("Dominion Control respawn failed", failure) end
				end
			end)
			ok, message = true, "Respawn requested."
		elseif action == "protect" then
			local character = target.Character
			if not character then
				ok, message = false, "No character available."
			else
				local existing = character:FindFirstChild("DominionAdminProtection")
				if existing then existing:Destroy() end
				local force = Instance.new("ForceField")
				force.Name = "DominionAdminProtection"
				force.Parent = character
				local expiry = workspace:GetServerTimeNow() + arg
				target:SetAttribute("AdminProtected", true)
				target:SetAttribute("AdminProtectionUntil", expiry)
				task.delay(arg, function()
					force:Destroy()
					if target.Parent == Players and target:GetAttribute("AdminProtectionUntil") == expiry then
						target:SetAttribute("AdminProtected", nil)
						target:SetAttribute("AdminProtectionUntil", nil)
					end
				end)
				ok, message = true, string.format("Invulnerability applied to this character for %d seconds.", arg)
			end
		elseif action == "clock" then
			Lighting.ClockTime = arg
			ok, message, suppliedAfter = true, "Time of day updated.", {clock = Lighting.ClockTime}
		elseif action == "announce" then
			local filtered, broadcast = pcall(function()
				return TextService:FilterStringAsync(arg, actor.UserId):GetNonChatStringForBroadcastAsync()
			end)
			if filtered and actor.Parent == Players then
				announce:FireAllClients(broadcast)
				ok, message = true, "Filtered announcement sent."
			else
				ok, message = false, "Announcement could not be filtered."
			end
		else
			ok, message = false, "Unknown command."
		end

		local after = suppliedAfter or (target and target.Parent == Players and inspect(target) or nil)
		if ok and target and (action == "grantCash" or action == "deductCash" or action == "setCash" or action == "grantUpgrade")
			and before and after and validNumber(before.wallet, 0, maxWallet) and validNumber(after.wallet, 0, maxWallet) then
			undo[actor] = {target = target, before = before, after = after, expires = now + 120}
		end
		record(actor, target, action, reason, ok == true, message, suppliedBefore or before, after)
		return {ok = ok == true, message = message or "Command completed.", state = after}
	end

	remote.Parent = ReplicatedStorage
end

return Admin
