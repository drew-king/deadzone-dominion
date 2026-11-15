local ProfileStore = {}
ProfileStore.__index = ProfileStore

local VERSION = 4
local backpack = require(game:GetService("ReplicatedStorage").Shared.BackpackConfig)
local MAX_WALLET = 1000000000
local petIds = {}
for _, pet in ipairs(require(game:GetService("ReplicatedStorage").Shared.PetConfig)) do petIds[pet.Id] = true end

local function normalize(raw)
	if type(raw) ~= "table" or (raw.version ~= 1 and raw.version ~= 2 and raw.version ~= 3 and raw.version ~= VERSION) or type(raw.wallet) ~= "number"
		or raw.wallet ~= raw.wallet or raw.wallet < 0 or raw.wallet > MAX_WALLET
		or raw.wallet % 1 ~= 0 or type(raw.upgrades) ~= "table" then
		return nil
	end
	local upgrades = {}
	local count = 0
	for name, unlocked in pairs(raw.upgrades) do
		count += 1
		if count > 128 or type(name) ~= "string" or #name > 64 or unlocked ~= true then
			return nil
		end
		upgrades[name] = true
	end
	local rebirths = raw.rebirths or 0
	if raw.version == 1 then
		if upgrades.Foundry or upgrades.Reactor or upgrades.Arsenal then upgrades.IonUnlock = true end
		if upgrades.Reactor or upgrades.Arsenal then upgrades.ArcUnlock = true end
	end
	if raw.version < 3 then
		if next(upgrades) ~= nil then upgrades.StarterFactory = true end
		if upgrades.IonUnlock or upgrades.ArcUnlock or upgrades.Arsenal or upgrades.PrismArmory then upgrades.ArsenalBench = true end
		if upgrades.AlloyPress or upgrades.ReturnLane or upgrades.PrismRefiner or upgrades.PrismArmory or upgrades.CrownUplink then upgrades.UpperAccess = true end
	end
	if upgrades.Foundry or upgrades.Reactor then upgrades.BeltAnnex=true end
	if upgrades.Reactor then upgrades.BeltDispatch=true end
	if type(rebirths) ~= "number" or not (rebirths >= 0 and rebirths <= 1000 and rebirths % 1 == 0) then return nil end
	local pets = {}
	if raw.pets ~= nil then
		if type(raw.pets) ~= "table" then return nil end
		for id, owned in raw.pets do
			if not petIds[id] or owned ~= true then return nil end
			pets[id] = true
		end
	end
	local equipped = raw.equippedPet
	if equipped ~= nil and (type(equipped) ~= "string" or not pets[equipped]) then return nil end
	local slots=raw.extraPetSlots or 0
	if type(slots)~="number" or slots%1~=0 or slots<0 or slots>backpack.MaxPreviewTiers then return nil end
	local loadout={}
	local seen={}
	if raw.equippedPets~=nil then
		if type(raw.equippedPets)~="table" or #raw.equippedPets>backpack.BaseSlots+slots then return nil end
		for index,id in raw.equippedPets do
			if type(index)~="number" or index%1~=0 or index<1 or index>#raw.equippedPets or not pets[id] or seen[id] then return nil end
			loadout[index],seen[id]=id,true
		end
	elseif equipped then
		loadout[1]=equipped
	end
	local potions={}
	if raw.potions~=nil then
		if type(raw.potions)~="table" then return nil end
		for key,doses in raw.potions do
			if not backpack.Potions[key] or type(doses)~="number" or doses%1~=0 or doses<1 or doses>10000 then return nil end
			potions[key]=doses
		end
	end
	local cosmetics = {}
	if type(raw.cosmetics) == "table" then
		for _, id in {"Aqua", "Mango", "Berry"} do if raw.cosmetics[id] == true then cosmetics[id] = true end end
	end
	local petTrail = type(raw.petTrail) == "string" and cosmetics[raw.petTrail] and raw.petTrail or nil
	return {version = VERSION, wallet = if not upgrades.StarterFactory then math.max(25, raw.wallet) else raw.wallet, upgrades = upgrades, rebirths = rebirths,
		cosmetics = cosmetics, petTrail = petTrail,
		pets = pets, equippedPet = loadout[1], equippedPets=loadout, extraPetSlots=slots, potions=potions,
		starterEggUsed = raw.starterEggUsed == true}
end

function ProfileStore.new(adapter)
	if not adapter then
		local memory = {}
		adapter = {
			read = function(userId)
				return memory[userId]
			end,
			write = function(userId, snapshot)
				memory[userId] = snapshot
				return true
			end,
		}
	end
	return setmetatable({adapter = adapter, writable = {}}, ProfileStore)
end

function ProfileStore:load(userId)
	self.writable[userId] = nil
	local ok, raw, readError = pcall(self.adapter.read, userId)
	if not ok or readError then
		return nil, "Profile read failed"
	end
	local profile = if raw == nil then {version = VERSION, wallet = 25, upgrades = {}, rebirths = 0,
		pets = {}, cosmetics = {}, equippedPets={}, potions={}, extraPetSlots=0} else normalize(raw)
	if not profile then
		return nil, "Profile schema is unsupported or corrupt"
	end
	self.writable[userId] = profile
	return profile
end

function ProfileStore:save(userId, profile)
	if not profile or self.writable[userId] ~= profile then
		return false, "Profile requires a successful load before saving"
	end
	local snapshot = normalize(profile)
	if not snapshot then
		return false, "Invalid profile"
	end
	local ok, written, writeError = pcall(self.adapter.write, userId, snapshot)
	if not ok or written ~= true then
		return false, if ok and type(writeError) == "string" then writeError else "Profile write failed"
	end
	return true
end

function ProfileStore:close(userId, profile)
	if self.writable[userId] ~= profile then return end
	self.writable[userId] = nil
	if self.adapter.forget then self.adapter.forget(userId) end
end

return ProfileStore
