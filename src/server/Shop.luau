local Shop = {}
local Storage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local catalog = require(Storage.Shared.ShopConfig)
local backpack=require(Storage.Shared.BackpackConfig)
local byId = {}
for _, item in catalog do byId[item.Id] = item end

function Shop.start(profiles, getPlot, economy, publishPets)
	local request = Instance.new("RemoteFunction")
	request.Name = "DeadzoneShop"
	local last = {}
	request.OnServerInvoke = function(player, id)
		local now = os.clock()
		if now < (last[player] or 0) then return false, "Try again in a moment." end
		last[player] = now + .35
		local item = type(id) == "string" and byId[id]
		local profile, plot = profiles[player], getPlot(player)
		if not item or not profile or not plot then return false, "Claim a base to use the shop." end
		if not profile.cosmetics[id] then
			if profile.wallet < item.Price then return false, "You need " .. item.Price .. " Scrap." end
			profile.wallet -= item.Price
			profile.cosmetics[id] = true
			if not player:GetAttribute("PlaytestPreset") then
				player:SetAttribute("ScrapSpent", (player:GetAttribute("ScrapSpent") or 0) + item.Price)
			end
		end
		profile.petTrail = id
		Shop.publish(player, profile)
		economy.publish(plot)
		return true, item.Name .. " equipped."
	end
	request.Parent = Storage
	Players.PlayerRemoving:Connect(function(player) last[player] = nil end)
	local preview = Instance.new("RemoteFunction")
	preview.Name = "DeadzonePassPreview"
	local catalogById = {}
	for _, item in require(Storage.Shared.PassPreviewConfig) do catalogById[item.Id] = true end
	local premium = require(Storage.Shared.PetConfig).Premium
	local random = Random.new()
	local test = RunService:IsStudio() and game.PlaceId == 0
		preview.OnServerInvoke = function(player, id, expectedTier)
		if not test then return false, "Pass previews are available in the local Studio build." end
		if type(id) ~= "string" or not (catalogById[id] or id=="PreviewPet" or id=="PreviewEgg" or id=="EndPetPreview" or id=="PreviewNextSlot") then
			return false, "Unknown offer."
		end
		if not profiles[player] then return false, "Wait for your profile to load." end
		local now = os.clock()
		if now < (last[player] or 0) then return false, "Try again in a moment." end
		last[player] = now + .35
		if id=="PreviewNextSlot" then
			local extra=player:GetAttribute("PreviewExtraSlots") or 0
			local tier=extra+(profiles[player].extraPetSlots or 0)+1
			if tier~=expectedTier or tier>backpack.MaxPreviewTiers then return false,"That price tier changed or is unavailable." end
			player:SetAttribute("PreviewExtraSlots",extra+1)
			publishPets(player)
			return true,"Added one equipped slot for this Studio session."
		end
		if id == "EndPetPreview" then
			player:SetAttribute("PreviewPremiumPet",nil)
			publishPets(player)
			return true, "Premium pet preview ended."
		elseif id == "PreviewPet" or id == "PreviewEgg" then
			local pet = premium[1]
			if id == "PreviewEgg" then
				local roll = random:NextInteger(1,1000)
				for _, outcome in premium do
					roll -= outcome.Weight
					if roll <= 0 then pet=outcome; break end
				end
			end
			player:SetAttribute("PreviewPremiumPet",pet.Id)
			publishPets(player)
			return true, pet.Name .. " following for this session."
		end
		local enabled = not player:GetAttribute("PreviewPass_"..id)
		player:SetAttribute("PreviewPass_"..id, enabled)
		return true, if enabled then "Preview active for this Studio session." else "Preview ended."
	end
	preview.Parent = Storage
	if not test then return end
	task.spawn(function()
		local cycles = 0
		while task.wait(.25) do
			cycles = (cycles+1)%8
			for _, player in Players:GetPlayers() do
				local plot = getPlot(player)
				if cycles == 0 and plot and player:GetAttribute("PreviewPass_AutoCollect") then economy.collect(plot,player) end
			end
		end
	end)
end

function Shop.publish(player, profile)
	for _, item in catalog do player:SetAttribute("Shop_" .. item.Id, profile.cosmetics[item.Id] == true) end
	player:SetAttribute("PetTrail", profile.petTrail)
end

return Shop
