local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local releaseConfig = require(Shared.SupporterConfig)
local plots, neutralSpawn = require(script.Parent.MapBuilder).build(require(Shared.MapConfig))
local claims = {}
local profiles = {}
local presetSessions = {}
local adapter = require(script.Parent.AlphaProfileAdapter).forCurrentPlace()
local store = require(script.Parent.ProfileStore).new(adapter)
require(script.Parent.Supporter).start()
local function getPlot(player) return claims[player] end
local powers
local pets
local potions
local siege
local outbreak
local combat = require(script.Parent.Combat)
local combatConfig = require(Shared.CombatConfig)
local function isSparring(player)
	return presetSessions[player] ~= nil and player:GetAttribute("PlaytestPreset") == "sparring"
end
local economy = require(script.Parent.Economy).start(plots, require(Shared.EconomyConfig), getPlot, profiles, function(player)
	if isSparring(player) then return 1 end
	return (if powers then powers.incomeMultiplier(player) else 1) * (if pets then pets.income(player) else 1)
		* (if potions then potions.factor(player,"Cash") else 1)
end, function(player)
	combat.reset(player)
	if siege then siege.reset(getPlot(player)) end
end)
pets = require(script.Parent.Pets).start(plots, profiles, economy)
potions = require(script.Parent.Potions).start(profiles,getPlot,economy)
local shop = require(script.Parent.Shop)
shop.start(profiles, getPlot, economy, pets.publish)
require(script.Parent.LiveBoards).start()
local function hurtPvE(player, humanoid, amount)
	if not humanoid then return end
	local reduced = powers.beforeDamage(nil, player, amount*potions.factor(player,"Armor"), "siege")
	if reduced > 0 then humanoid:TakeDamage(reduced) end
end
local combatAPI = combat.start({
	plots = plots,
	getPlot = getPlot,
	isPaused = economy.isCombatPaused,
	isSparring = isSparring,
	getPowers = function() return powers end,
	pveDamage = function(player,amount) return amount*potions.factor(player,"Damage") end,
	canFireSiege = function(player, position) return siege and siege.canFire(player, position) end,
	hitSiege = function(player, model, amount) return siege and siege.hit(player, model, amount) end,
	canFireOutbreak = function(player, position) return outbreak and outbreak.canFire(player, position) end,
	hitOutbreak = function(player, model, amount) return outbreak and outbreak.hit(player, model, amount) end,
	canUseWeapon = function(player, level)
		local u = profiles[player] and profiles[player].upgrades
		return combatConfig.unlocked(u, level)
	end,
})
powers = require(script.Parent.Powers).start({
	allowLive = game.GameId == releaseConfig.UniverseId and game.PlaceId == releaseConfig.PlaceId,
	getPlot = getPlot,
	isSparring = isSparring,
	canAffect = combatAPI.canAffect,
	dealDamage = combatAPI.dealDamage,
	grantLootWeapon = combatAPI.grantLootWeapon,
	clearLootWeapons = combatAPI.clearLoot,
})
siege = require(script.Parent.Siege).start({
	plots = plots,
	profiles = profiles,
	getPlot = getPlot,
	isSparring = isSparring,
	isPaused = economy.isCombatPaused,
	publish = economy.publish,
	maxWallet = require(Shared.EconomyConfig).MaxWallet,
	hurtOwner = hurtPvE,
})
outbreak = require(script.Parent.Outbreak).start(plots, {
	eligible = function(player) return getPlot(player) ~= nil and not isSparring(player) end,
	paused = economy.isCombatPaused,
	hurt = hurtPvE,
	reward = function(player)
		local profile, plot = profiles[player], getPlot(player)
		if not profile or not plot or player:GetAttribute("PlaytestPreset") then return end
		profile.wallet = math.min(require(Shared.EconomyConfig).MaxWallet, profile.wallet + 4)
		economy.publish(plot)
	end,
})

local function placeCharacter(player, character)
	local root = character:WaitForChild("HumanoidRootPart", 5)
	if root and player.Character == character then
		local plot = claims[player]
		character:PivotTo(if plot then plot.Spawn else neutralSpawn)
	end
end

local function setup(player)
	if profiles[player] then return end
	player.CharacterRemoving:Connect(function()
		combat.reset(player)
	end)
	player.CharacterAdded:Connect(function(character)
		placeCharacter(player, character)
	end)
	if player.Character then
		task.spawn(placeCharacter, player, player.Character)
	end
	local profile, err = store:load(player.UserId)
	if not profile then
		warn("[Deadzone] Profile unavailable", player.UserId, err)
		player:SetAttribute("ClaimFeedback", "Progress unavailable. Rejoin to try again.")
		return
	end
	if player.Parent ~= Players then return end
	profiles[player] = profile
	pets.publish(player)
	potions.publish(player)
	shop.publish(player, profile)
	player:SetAttribute("ScrapCash", profile.wallet)
end

local function showOwnership(plot, player)
	local status = if player then "Owned by " .. player.DisplayName else "Unclaimed"
	plot.Model:SetAttribute("OwnerUserId", if player then player.UserId else nil)
	plot.Label.Text = "CLAIM TERMINAL\n" .. status
	plot.GateStatus.Text = status
	plot.ClaimSign.Enabled = player == nil
	plot.ClaimSign.Parent.Transparency = if player then 1 else 0
	plot.Prompt.ActionText = if player then "Check ownership" else "Claim base"
end

for _, plot in ipairs(plots) do
	showOwnership(plot, nil)
	plot.Prompt.Triggered:Connect(function(player)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if player.Parent ~= Players or not root or not humanoid or humanoid.Health <= 0
			or (root.Position - plot.Terminal.Position).Magnitude > plot.Prompt.MaxActivationDistance then
			return
		end
		if claims[player] or plot.Owner then
			player:SetAttribute("ClaimFeedback", if claims[player] then "You already own a base." else "This base is taken. Try another gate.")
			return
		end
		if not profiles[player] then return end
		-- This reservation does not yield, so competing requests see the owner immediately.
		claims[player], plot.Owner = plot, player
		showOwnership(plot, player)
		player:SetAttribute("ClaimedPower", plot.Name)
		player:SetAttribute("ClaimFeedback", if profiles[player].upgrades.StarterFactory then "Collect Scrap at the teal terminal."
			else "Use your 25 starter Scrap to buy the Starter Factory.")
		economy.publish(plot)
		character:PivotTo(plot.Arrival)
		print(string.format("[Deadzone] %s claimed %s", player.Name, plot.Name))
	end)
end

local function release(player)
	local plot = claims[player]
	if not plot then return false, "No owned plot." end
	claims[player], plot.Owner = nil, nil
	siege.reset(plot)
	if presetSessions[player] then presetSessions[player].plot = nil end
	combat.reset(player)
	economy.resetPlot(plot)
	player:SetAttribute("ClaimedPower", nil)
	player:SetAttribute("PendingScrap", 0)
	player:SetAttribute("HasWalls", false)
	player:SetAttribute("HasProduction", false)
	player:SetAttribute("ClaimFeedback", "Plot released.")
	showOwnership(plot, nil)
	return true, "Plot released."
end

Players.PlayerAdded:Connect(setup)
local saving = {}
local function saveAndClose(player)
	if saving[player] or not profiles[player] then return end
	saving[player] = true
	local profile = if presetSessions[player] then presetSessions[player].profile else profiles[player]
	profiles[player] = nil
	presetSessions[player] = nil
	local ok, err = store:save(player.UserId, profile)
	store:close(player.UserId, profile)
	if not ok then warn("[Deadzone] Profile save failed", player.UserId, err) end
	saving[player] = nil
end
Players.PlayerRemoving:Connect(function(player)
	release(player)
	saveAndClose(player)
end)
if adapter then
	game:BindToClose(function()
		for _, player in Players:GetPlayers() do task.spawn(saveAndClose, player) end
		local deadline = os.clock() + 25
		while next(saving) and os.clock() < deadline do task.wait() end
	end)
end
for _, player in ipairs(Players:GetPlayers()) do setup(player) end
require(script.Parent.Admin).start({
	inspect = economy.inspect,
	command = function(action, target, payload)
		if action == "resetPowerCooldown" or action == "clearPowerEffects" or action == "setPowerTuning" then
			return powers.admin(action, target, payload)
		end
		if action == "preset" then
			if not game:GetService("RunService"):IsStudio() or not target or not profiles[target] then
				return false, "An active Studio profile is required."
			end
			if presetSessions[target] then return false, "A preset is already active." end
			local plot = getPlot(target)
			local snapshot = {profile = profiles[target], plot = plot, pending = plot and plot.Pending or 0}
			local original = snapshot.profile
			profiles[target] = {version = original.version, wallet = original.wallet, upgrades = table.clone(original.upgrades),
				rebirths = original.rebirths, pets = table.clone(original.pets), equippedPet = original.equippedPet,
				starterEggUsed = original.starterEggUsed, cosmetics = table.clone(original.cosmetics), petTrail = original.petTrail}
			local ok, message, before, after = economy.command(action, target, payload)
			if not ok then profiles[target] = original; return false, message end
			pets.publish(target)
			presetSessions[target] = snapshot
			target:SetAttribute("PlaytestPreset", payload.preset)
			target:SetAttribute("AdminPlaytestUntil", workspace:GetServerTimeNow() + 120)
			task.delay(120, function()
				if presetSessions[target] ~= snapshot then return end
				presetSessions[target] = nil
				profiles[target] = original
				pets.publish(target)
				shop.publish(target, original)
				target:SetAttribute("PlaytestPreset", nil)
				target:SetAttribute("AdminPlaytestUntil", nil)
				combat.reset(target)
				local current = getPlot(target)
				if current then
					current.Pending = if current == snapshot.plot then snapshot.pending else 0
					economy.publish(current)
				else
					target:SetAttribute("ScrapCash", original.wallet)
				end
			end)
			return true, message .. " · Test profile expires in 120 seconds.", before, after
		end
		if action == "releasePlot" then
			if not target then return false, "Choose a target." end
			local ok, message = release(target)
			if ok and target.Character then target.Character:PivotTo(neutralSpawn) end
			return ok, message
		end
		return economy.command(action, target, payload)
	end,
})
print("[Deadzone] Phase 2 services ready")
