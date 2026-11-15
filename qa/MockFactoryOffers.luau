local RunService = game:GetService("RunService")

local MockFactoryOffers = {}

MockFactoryOffers.Product = table.freeze({
	Id = "TEST_FACTORY_EFFICIENCY",
	ProposedRobux = 49,
	Bonus = .15,
	Seconds = 15 * 60,
})

function MockFactoryOffers.new(ledger)
	assert(RunService:IsStudio(), "This simulated offer runs only in Studio")
	local product = MockFactoryOffers.Product
	return {
		apply = function(userId, receiptId, productId, status, now)
			if status ~= "Purchased" then return false, "No grant" end
			if productId ~= product.Id or type(receiptId) ~= "string" or #receiptId == 0 then
				return false, "Invalid test receipt"
			end
			local prior = ledger.receipts[receiptId]
			if prior then
				if prior.userId ~= userId then return false, "Wrong receipt owner" end
				return true, prior.expiry
			end
			local expiry = math.max(ledger.expiry[userId] or 0, now + product.Seconds)
			ledger.expiry[userId] = expiry
			ledger.receipts[receiptId] = {userId = userId, expiry = expiry}
			return true, expiry
		end,
		multiplier = function(userId, now)
			return if (ledger.expiry[userId] or 0) > now then 1 + product.Bonus else 1
		end,
	}
end

return MockFactoryOffers
