local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "DeadzoneGuide"
gui.ResetOnSpawn = false
local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.fromScale(0.5, 0.025)
label.Size = UDim2.new(0.9, 0, 0, 82)
if game:GetService("UserInputService").TouchEnabled then
	label.AnchorPoint = Vector2.zero
	label.Position = UDim2.fromOffset(8, 4)
	label.Size = UDim2.new(1, -152, 0, 68)
end
local limit = Instance.new("UISizeConstraint")
limit.MaxSize = Vector2.new(600, 82)
limit.Parent = label
label.BackgroundColor3 = Color3.fromRGB(28, 34, 43)
label.TextColor3 = Color3.fromRGB(255, 225, 174)
label.TextScaled = true
label.TextWrapped = true
label.Font = Enum.Font.GothamBold
local textLimit = Instance.new("UITextSizeConstraint")
textLimit.MaxTextSize = 18
textLimit.Parent = label
label.Parent = gui
local corners = Instance.new("UICorner")
corners.CornerRadius, corners.Parent = UDim.new(0, 13), label
local outline = require(script.Parent.InterfaceArt).panel(label, Color3.fromRGB(94,235,213))
local feedbackVersion = 0
local showFeedback = true
local function update()
	local power = player:GetAttribute("ClaimedPower")
	local feedback = player:GetAttribute("ClaimFeedback")
	local wallet = player:GetAttribute("ScrapCash") or 0
	local pending = player:GetAttribute("PendingScrap") or 0
	local price = player:GetAttribute("NextUpgradePrice")
	local nextName = player:GetAttribute("NextUpgradeName")
	local nextFloor = player:GetAttribute("NextUpgradeFloor") or 1
	local floor = if nextFloor == 1 then "Floor One · purchase deck" else "Floor " .. nextFloor .. " · take the stairs"
	local rebirthPrice = player:GetAttribute("RebirthPrice")
	local rebirthFloor = player:GetAttribute("RebirthFloor") or 2
	local rebirths = player:GetAttribute("Rebirths") or 0
	local targetCost = rebirthPrice or price
	local nextStep = if rebirthPrice then string.format("Floor %d · Rebirth Console · %d Scrap", rebirthFloor, rebirthPrice)
		elseif price and nextName then string.format("%s\n%s · %d Scrap", floor, nextName, price)
		else "Choose a pet, equip at the arsenal, or head to Reactor Crown."
	if targetCost and wallet < targetCost then
		local savingFor = if rebirthPrice then "rebirth" else nextName or "the next upgrade"
		nextStep = if wallet + pending >= targetCost then "Use COLLECT SCRAP for " .. savingFor .. "."
			else string.format("Saving for %s · %d / %d Scrap", savingFor, wallet + pending, targetCost)
	end
	if rebirths == 0 and pending > 0 and not player:GetAttribute("HasProduction") and not player:GetAttribute("FirstScrapCollected") then
		nextStep = "Pick up your first Scrap at COLLECT SCRAP."
	end
	local objective = if power then string.format("%s  ·  %d Scrap  ·  %d ready  ·  R%d\n%s", power, wallet, pending, rebirths, nextStep)
		else "Choose a power\nUse the district map to find a gate. Claim at its terminal."
	label.Text = if feedback and showFeedback then objective .. "\n" .. feedback else objective
	if player:GetAttribute("PlaytestPreset") then label.Text = "PLAYTEST · " .. label.Text end
	local plot = power and workspace:FindFirstChild("DeadzonePhase1") and workspace.DeadzonePhase1:FindFirstChild(power)
	local terminal = plot and plot:FindFirstChild("ClaimTerminal")
	outline.Color = if terminal then terminal.Color else Color3.fromRGB(94,235,213)
end
player:GetAttributeChangedSignal("ClaimedPower"):Connect(update)
player:GetAttributeChangedSignal("ClaimFeedback"):Connect(function()
	feedbackVersion += 1
	local version = feedbackVersion
	showFeedback = true
	update()
	task.delay(10, function()
		if feedbackVersion ~= version then return end
		showFeedback = false
		update()
	end)
end)
for _, attribute in {"ScrapCash", "PendingScrap", "NextUpgradePrice", "NextUpgradeName", "NextUpgradeFloor", "RebirthPrice", "RebirthFloor", "PlaytestPreset", "Rebirths", "HasProduction", "FirstScrapCollected"} do
	player:GetAttributeChangedSignal(attribute):Connect(update)
end
update()
gui.Parent = player:WaitForChild("PlayerGui")
