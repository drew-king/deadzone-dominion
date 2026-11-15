local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Adapter = {}

function Adapter.forCurrentPlace()
	local studio = RunService:IsStudio()
	local launch = require(game.ReplicatedStorage.Shared.SupporterConfig)
	local release = not studio and game.GameId == launch.UniverseId and game.PlaceId == launch.PlaceId
	if not release and not (studio and workspace:GetAttribute("DeadzoneAlphaPersistence") == true) then return nil end
	local store = if release then DataStoreService:GetDataStore("DeadzoneReleaseProfiles_v1")
		else DataStoreService:GetDataStore("DeadzoneAlphaProfiles_v1", "StudioOnly")
	local readOptions = Instance.new("DataStoreGetOptions")
	readOptions.UseCache = false
	local revisions = {}
	local function key(userId)
		return string.format("tester_%d", userId)
	end
	local function revision(snapshot, info)
		if snapshot == nil then return "missing" end
		if type(snapshot) == "table" and type(snapshot._writeToken) == "string" then
			return "token:" .. snapshot._writeToken
		end
		if info then return string.format("legacy:%s:%d", info.Version, info.UpdatedTime) end
		return nil
	end
	return {
		read = function(userId)
			revisions[userId] = nil
			local snapshot, info = store:GetAsync(key(userId), readOptions)
			revisions[userId] = {value = revision(snapshot, info)}
			return snapshot
		end,
		write = function(userId, snapshot)
			local load = revisions[userId]
			if not load or not load.value then return false, "Profile revision unavailable" end
			local expected = load.value
			local token = HttpService:GenerateGUID(false)
			local record = table.clone(snapshot)
			record._writeToken = token
			local committed = store:UpdateAsync(key(userId), function(current, info)
				if revision(current, info) ~= expected then return nil end
				if info then return record, info:GetUserIds(), info:GetMetadata() end
				return record
			end)
			if type(committed) ~= "table" or committed._writeToken ~= token then
				return false, "A newer profile save exists"
			end
			if revisions[userId] == load then load.value = revision(committed, nil) end
			return true
		end,
		forget = function(userId)
			revisions[userId] = nil
		end,
	}
end

return Adapter
