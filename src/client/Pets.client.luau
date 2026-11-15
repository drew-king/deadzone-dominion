local player = game:GetService("Players").LocalPlayer
local storage = game:GetService("ReplicatedStorage")
local roster = require(storage:WaitForChild("Shared"):WaitForChild("PetConfig"))
local remote = storage:WaitForChild("DeadzonePets", 20)
if not remote then return end
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "DeadzonePetInventory", false
gui.Parent = player:WaitForChild("PlayerGui")
local toggle = Instance.new("TextButton")
toggle.Size, toggle.Position = UDim2.fromOffset(180, 38), UDim2.new(1, -192, .5, -19)
if game:GetService("UserInputService").TouchEnabled then
	toggle.Size, toggle.Position = UDim2.fromOffset(128, 44), UDim2.new(1, -136, 0, 52)
end
toggle.BackgroundColor3, toggle.TextColor3 = Color3.fromRGB(38, 48, 70), Color3.new(1, 1, 1)
toggle.TextWrapped, toggle.TextSize, toggle.Font = true, 14, Enum.Font.GothamBold
toggle.Parent = gui
local panel = Instance.new("ScrollingFrame")
panel.Size, panel.Position = UDim2.fromScale(.86, .68), UDim2.fromScale(.5, .5)
panel.AnchorPoint, panel.Visible = Vector2.new(.5, .5), false
panel.AutomaticCanvasSize, panel.CanvasSize = Enum.AutomaticSize.Y, UDim2.new()
panel.BackgroundColor3, panel.ScrollBarThickness = Color3.fromRGB(23, 29, 44), 6
panel.Parent = gui
require(script.Parent.InterfaceArt).panel(panel, Color3.fromRGB(211,151,252))
local limit = Instance.new("UISizeConstraint")
limit.MaxSize, limit.Parent = Vector2.new(390, 390), panel
local layout = Instance.new("UIListLayout")
layout.Padding, layout.Parent = UDim.new(0, 3), panel
local padding = Instance.new("UIPadding")
padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 8), UDim.new(0, 12)
padding.PaddingTop, padding.PaddingBottom = UDim.new(0, 8), UDim.new(0, 8)
padding.Parent = panel
local heading = Instance.new("TextLabel")
heading.Size, heading.BackgroundTransparency = UDim2.new(1, 0, 0, 52), 1
heading.TextColor3, heading.Font = Color3.fromRGB(255, 238, 204), Enum.Font.GothamBold
heading.TextSize, heading.TextWrapped, heading.Parent = 15, true, panel
local rows = {}
local function row()
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 46)
	button.BackgroundColor3 = Color3.fromRGB(38, 48, 70)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font, button.TextWrapped, button.TextSize = Enum.Font.Gotham, true, 14
	local round = Instance.new("UICorner")
	round.CornerRadius, round.Parent = UDim.new(0, 7), button
	button.Parent = panel
	return button
end
local clear = row()
clear.Text = "Unequip all"
clear.Activated:Connect(function() remote:FireServer("") end)
local close = row()
close.Text = "Close"
close.Activated:Connect(function() panel.Visible = false end)
local bagConfig=require(storage.Shared.BackpackConfig)
local potionRemote=storage:WaitForChild("DeadzonePotions",20)
local potionRows={}
for _,key in {"Cash","Speed","Damage","Armor"} do
	local potion=bagConfig.Potions[key]
	local button=row()
	button.BackgroundColor3=potion.Color:Lerp(Color3.fromRGB(29,39,64),.55)
	potionRows[key]=button
	button.Activated:Connect(function()
		if not potionRemote then return end
		local ok,_,message=pcall(potionRemote.InvokeServer,potionRemote,"Use",key)
		if ok then heading.Text=message end
	end)
end
task.spawn(function()
	while task.wait(.35) do
		local now=workspace:GetServerTimeNow()
		for key,button in potionRows do
			local remain=math.max(0,math.ceil((player:GetAttribute("PotionUntil_"..key) or 0)-now))
			local count=player:GetAttribute("PotionCount_"..key) or 0
			button.Visible=count>0 or remain>0
			button.Text=string.format("%s · %d doses%s",bagConfig.Potions[key].Name,count,if remain>0 then " · "..remain.."s active" else " · Use")
		end
	end
end)
for _, pet in ipairs(roster) do
	local button = row()
	rows[pet.Id] = button
	button.Activated:Connect(function()
		if player:GetAttribute("PetOwned_" .. pet.Id) then remote:FireServer(pet.Id) end
	end)
end
local follower, companion
local PetAppearance = require(script.Parent:WaitForChild("PetAppearance"))
local lastAppearance
local trailCatalog = require(storage.Shared.ShopConfig)
local function update()
	local equipped = player:GetAttribute("EquippedPet")
	local loadout=player:GetAttribute("EquippedPets") or ""
	local active={}
	for id in string.gmatch(loadout,"[^,]+") do active[id]=true end
	if equipped then active[equipped]=true end
	local trailId = player:GetAttribute("PetTrail")
	local appearance = (equipped or "") .. ":" .. (trailId or "") .. ":" .. loadout
	local rebuild = appearance ~= lastAppearance
	toggle.Text = "BACKPACK"
	if rebuild then
		if follower then follower:Destroy(); follower = nil end
		if companion then companion:Destroy(); companion = nil end
		lastAppearance = appearance
	end
	local theme = roster.Themes[player:GetAttribute("ClaimedPower")]
	heading.Text=string.format("Backpack %d/75 · %d equipped slots",player:GetAttribute("BackpackUsed") or 0,player:GetAttribute("PetSlots") or 2)
	local included = {}
	if theme then for _, pet in theme.Pets do included[pet.Id] = true end end
	for index, pet in ipairs(roster) do
		local owned = player:GetAttribute("PetOwned_" .. pet.Id)
		local bonus = if pet.Income > 1 then string.format("+%d%% income", math.round((pet.Income - 1) * 100))
			else string.format("+%d%% damage in future PvE", math.round((pet.Damage - 1) * 100))
		local prefix = if active[pet.Id] then "Equipped" elseif owned then "Equip" else "Undiscovered"
		local odds = if included[pet.Id] then string.format(" · %.1f%%", pet.Weight / 10) else ""
		rows[pet.Id].Text = string.format("%s · %s\n%s%s · %s", prefix, pet.Name, pet.Rarity, odds, bonus)
		rows[pet.Id].TextColor3 = pet.Color:Lerp(Color3.new(1, 1, 1), .4)
		rows[pet.Id].Selectable = owned == true
		rows[pet.Id].Visible = owned == true or included[pet.Id] == true
		if pet.Id ~= equipped and active[pet.Id] and rebuild and not companion then
			companion=PetAppearance.build(pet,pet.Tier or math.clamp(index,1,6))
		end
		if pet.Id == equipped then
			if not rebuild then continue end
			local body
			follower, body = PetAppearance.build(pet, pet.Tier or math.clamp(index,1,6))
			for _, item in trailCatalog do
				if trailId == item.Id then
					local a, b = Instance.new("Attachment"), Instance.new("Attachment")
					a.Position, b.Position = Vector3.new(-.4,0,.5), Vector3.new(.4,0,.5)
					a.Parent, b.Parent = body, body
					local trail = Instance.new("Trail")
					trail.Attachment0, trail.Attachment1 = a, b
					trail.Color, trail.Lifetime, trail.LightEmission = ColorSequence.new(item.Color), .33, .6
					trail.Parent = body
				end
			end
		end
	end
end
toggle.Activated:Connect(function() panel.Visible = not panel.Visible end)
player:GetAttributeChangedSignal("EquippedPet"):Connect(update)
player:GetAttributeChangedSignal("EquippedPets"):Connect(update)
player:GetAttributeChangedSignal("BackpackUsed"):Connect(update)
player:GetAttributeChangedSignal("PetSlots"):Connect(update)
player:GetAttributeChangedSignal("PetTrail"):Connect(update)
player:GetAttributeChangedSignal("ClaimedPower"):Connect(update)
for _, pet in ipairs(roster) do player:GetAttributeChangedSignal("PetOwned_" .. pet.Id):Connect(update) end
game:GetService("RunService").RenderStepped:Connect(function()
	if not follower then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		follower.Parent = nil
		if companion then companion.Parent=nil end
		return
	end
	local frame = root.CFrame * CFrame.new(2.8, math.sin(os.clock() * 4) * .2 - .6, 2.1)
	follower:PivotTo(frame)
	if not follower.Parent then follower.Parent = workspace end
	if companion then
		companion:PivotTo(root.CFrame*CFrame.new(-2.5,math.sin(os.clock()*4+.8)*.2-.6,2.3))
		if not companion.Parent then companion.Parent=workspace end
	end
end)
update()
