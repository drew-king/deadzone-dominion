local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")
local plots, neutralSpawn = require(script.Parent.MapBuilder).build(require(Shared.MapConfig))
local claims = {}

local function placeCharacter(player, character)
	local root = character:WaitForChild("HumanoidRootPart", 5)
	if root and player.Character == character then
		local plot = claims[player]
		character:PivotTo(if plot then plot.Spawn else neutralSpawn)
	end
end

local function setup(player)
	player.CharacterAdded:Connect(function(character)
		placeCharacter(player, character)
	end)
	if player.Character then
		task.spawn(placeCharacter, player, player.Character)
	end
end

for _, plot in ipairs(plots) do
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
		-- This reservation does not yield, so competing requests see the owner immediately.
		claims[player], plot.Owner = plot, player
		plot.Model:SetAttribute("OwnerUserId", player.UserId)
		plot.Label.Text = string.format("%02d  %s\n@%s", plot.Index, plot.Name, player.Name)
		plot.Prompt.ActionText = "Check ownership"
		player:SetAttribute("ClaimedPower", plot.Name)
		player:SetAttribute("ClaimFeedback", "Base claimed. Follow the road to Reactor Crown.")
		character:PivotTo(plot.Spawn)
		print(string.format("[Deadzone] %s claimed %s", player.Name, plot.Name))
	end)
end

Players.PlayerAdded:Connect(setup)
Players.PlayerRemoving:Connect(function(player)
	local plot = claims[player]
	if not plot then return end
	claims[player], plot.Owner = nil, nil
	plot.Model:SetAttribute("OwnerUserId", nil)
	plot.Label.Text = string.format("%02d  %s\nAVAILABLE", plot.Index, plot.Name)
	plot.Prompt.ActionText = "Claim base"
end)
for _, player in ipairs(Players:GetPlayers()) do setup(player) end
print("[Deadzone] Phase 1 ready: eight plots and Reactor Crown")
