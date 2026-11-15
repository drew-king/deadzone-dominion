local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Storage = game:GetService("ReplicatedStorage")
local config = require(Storage.Shared.SupporterConfig)
local Supporter = {}

local function showTag(player, character)
	if not player:GetAttribute("DeadzoneSupporter") then return end
	local head = character:WaitForChild("Head", 5)
	if not head or player.Character ~= character or head:FindFirstChild("SupporterTag") then return end
	local tag = Instance.new("BillboardGui")
	tag.Name, tag.Size, tag.MaxDistance = "SupporterTag", UDim2.fromOffset(158, 27), 60
	tag.StudsOffsetWorldSpace = Vector3.new(0, 3.15, 0)
	local display = Instance.new("TextLabel")
	display.Size, display.TextSize = UDim2.fromScale(1, 1), 14
	display.BackgroundColor3 = Color3.fromRGB(22, 62, 135)
	display.TextColor3, display.TextTruncate = Color3.fromRGB(229, 246, 255), Enum.TextTruncate.AtEnd
	display.Font, display.Text = Enum.Font.GothamBold, player.DisplayName .. " · SUPPORTER"
	display.Parent = tag
	local corner = Instance.new("UICorner")
	corner.CornerRadius, corner.Parent = UDim.new(0, 8), display
	tag.Parent = head
end

function Supporter.process(receipt, store, productId, onGrant)
	if receipt.ProductId ~= productId or type(receipt.PlayerId) ~= "number" or receipt.PlayerId <= 0 then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	-- The only grant is a permanent entitlement. Replaying any receipt writes the same value.
	local ok, record = pcall(function()
		return store:UpdateAsync("user_" .. receipt.PlayerId, function() return true end)
	end)
	if not ok or record ~= true then return Enum.ProductPurchaseDecision.NotProcessedYet end
	if onGrant then onGrant(receipt.PlayerId) end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function Supporter.start()
	local live = not RunService:IsStudio() and game.GameId == config.UniverseId and game.PlaceId == config.PlaceId
	Storage:SetAttribute("DeadzoneSupporterEnabled", live)
	if not live then return end
	local store = DataStoreService:GetDataStore("DeadzoneSupporter_v1")
	local function mark(player)
		player:SetAttribute("DeadzoneSupporter", true)
		if player.Character then task.spawn(showTag, player, player.Character) end
	end
	local function setup(player)
		player.CharacterAdded:Connect(function(character) showTag(player, character) end)
		local ok, entitled = pcall(store.GetAsync, store, "user_" .. player.UserId)
		if ok and entitled == true and player.Parent == Players then mark(player) end
	end
	Players.PlayerAdded:Connect(setup)
	for _, player in Players:GetPlayers() do task.spawn(setup, player) end
	MarketplaceService.ProcessReceipt = function(receipt)
		return Supporter.process(receipt, store, config.ProductId, function(id)
			local player = Players:GetPlayerByUserId(id)
			if player then mark(player) end
		end)
	end
end

return Supporter
