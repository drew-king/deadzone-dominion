local player = game:GetService("Players").LocalPlayer
local storage = game:GetService("ReplicatedStorage")
local request = storage:WaitForChild("DeadzoneShop", 20)
if not request then return end
local preview = storage:WaitForChild("DeadzonePassPreview", 20)
local gui = Instance.new("ScreenGui")
gui.Name, gui.ResetOnSpawn = "DeadzoneShop", false
gui.Parent = player:WaitForChild("PlayerGui")
local panel
local position = 0
local function order(item, parent)
	if panel and parent == panel then
		position += 1
		item.LayoutOrder = position
	end
end

local function button(parent, title, color)
	local item = Instance.new("TextButton")
	item.Size = UDim2.new(1, 0, 0, 44)
	item.BackgroundColor3, item.TextColor3 = color, Color3.fromRGB(18, 30, 51)
	item.Text, item.TextSize, item.TextWrapped, item.Font = title, 16, true, Enum.Font.GothamBold
	order(item,parent)
	item.Parent = parent
	local round = Instance.new("UICorner")
	round.CornerRadius, round.Parent = UDim.new(0, 10), item
	return item
end
local toggle = button(gui, "▣  SHOP", Color3.fromRGB(255, 205, 78))
toggle.Name = "OpenShop"
toggle.Size, toggle.Position = UDim2.fromOffset(114, 44), UDim2.new(1, -126, .5, -78)
if game:GetService("UserInputService").TouchEnabled then
	toggle.Size, toggle.Position = UDim2.fromOffset(128, 44), UDim2.new(1, -136, 0, 4)
end
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(255, 176, 124))
gradient.Rotation, gradient.Parent = 90, toggle
panel = Instance.new("ScrollingFrame")
panel.Name = "Catalog"
panel.AnchorPoint, panel.Position = Vector2.new(.5, .5), UDim2.fromScale(.5, .5)
panel.Size, panel.Visible = UDim2.fromScale(.85, .78), false
panel.CanvasSize, panel.AutomaticCanvasSize = UDim2.new(), Enum.AutomaticSize.Y
panel.ScrollBarThickness = 6
panel.BackgroundColor3, panel.Parent = Color3.fromRGB(32, 47, 77), gui
require(script.Parent.InterfaceArt).panel(panel, Color3.fromRGB(255,200,106))
local limit = Instance.new("UISizeConstraint")
limit.MaxSize, limit.Parent = Vector2.new(510, 618), panel
local stack = Instance.new("UIListLayout")
stack.SortOrder = Enum.SortOrder.LayoutOrder
stack.Padding, stack.Parent = UDim.new(0, 5), panel
local padding = Instance.new("UIPadding")
padding.PaddingLeft, padding.PaddingRight = UDim.new(0, 10), UDim.new(0, 14)
padding.PaddingTop, padding.PaddingBottom, padding.Parent = UDim.new(0, 8), UDim.new(0, 8), panel
local info = Instance.new("TextLabel")
info.Size, info.TextColor3, info.BackgroundTransparency = UDim2.new(1, 0, 0, 43), Color3.new(1,1,1), 1
order(info,panel)
info.TextSize, info.TextWrapped, info.Text, info.Parent = 17, true, "DOMINION SHOP", panel
local pending = false
local function caption(parent, value, x, y, right, height, size, color)
	local text = Instance.new("TextLabel")
	text.Position, text.Size = UDim2.fromOffset(x,y), UDim2.new(1,-right,0,height)
	text.Text, text.TextSize, text.TextColor3 = value,size,color
	text.TextXAlignment, text.TextWrapped = Enum.TextXAlignment.Left,true
	order(text,parent)
	text.BackgroundTransparency,text.Font,text.Parent=1,Enum.Font.GothamBold,parent
	return text
end
for index, item in require(storage.Shared.PassPreviewConfig) do
	local card=Instance.new("Frame")
	card.Name,card.Size,card.BackgroundColor3=item.Id,UDim2.new(1,0,0,if index==1 then 169 else 155),item.Dark
	order(card,panel)
	card.Parent=panel
	local rounded=Instance.new("UICorner")
	rounded.CornerRadius,rounded.Parent=UDim.new(0,15),card
	local stroke=Instance.new("UIStroke")
	stroke.Color,stroke.Transparency,stroke.Parent=item.Accent,.55,card
	local tone=Instance.new("UIGradient")
	tone.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(132,142,171))
	tone.Rotation,tone.Parent=18,card
	local icon=Instance.new("Frame")
	icon.Position,icon.Size,icon.BackgroundColor3=UDim2.fromOffset(12,15),UDim2.fromOffset(55,55),item.Accent
	icon.Parent=card
	local bevel=Instance.new("UICorner")
	bevel.CornerRadius,bevel.Parent=UDim.new(0,12),icon
	local function mark(x,y,w,h,rotation,color)
		local shape=Instance.new("Frame")
		shape.BorderSizePixel,shape.Rotation=0,rotation
		shape.Position,shape.Size=UDim2.fromOffset(x,y),UDim2.fromOffset(w,h)
		shape.BackgroundColor3,shape.Parent=color,icon
		local corner=Instance.new("UICorner")
		corner.CornerRadius,corner.Parent=UDim.new(0,3),shape
	end
	local ink=Color3.fromRGB(21,42,66)
	local highlight=Color3.fromRGB(246,255,237)
	if item.Id=="AutoCollect" then
		for _, coin in {{13,8},{27,12},{20,21}} do mark(coin[1],coin[2],9,9,45,highlight) end
		mark(9,31,37,14,0,ink)
		mark(15,33,25,3,0,highlight)
		mark(23,40,9,3,0,item.Accent)
	else
		for _, x in {15,29} do
			mark(x,13,7,20,-43,ink)
			mark(x,24,7,20,43,ink)
		end
		mark(6,26,12,4,0,highlight)
	end
	caption(card,item.Label,77,9,88,17,11,item.Accent)
	caption(card,item.Name,77,25,88,24,20,Color3.new(1,1,1))
	caption(card,item.Benefit,77,51,88,42,14,Color3.fromRGB(237,247,255))
	local offer=caption(card,"",12,91,24,15,11,item.Accent)
	offer.Text=string.format("PROPOSED PRICE · %d ROBUX",item.Price)
	local action=button(card,"Preview pass",item.Accent)
	action.Name="Preview"
	action.Size,action.Position=UDim2.new(1,-24,0,44),UDim2.fromOffset(12,108)
	local attribute="PreviewPass_"..item.Id
	local localTest=game:GetService("RunService"):IsStudio() and game.PlaceId==0
	local function updatePass()
		action.Text=if player:GetAttribute(attribute) then "Preview active · turn off"
			elseif localTest then "Try in Studio" else "Coming soon"
	end
	action.Active=localTest and preview~=nil
	action.Activated:Connect(function()
		if not localTest or not preview or pending then return end
		pending=true
		local ok, _, message=pcall(preview.InvokeServer,preview,item.Id)
		info.Text=if ok then message else "Preview unavailable. Try again shortly."
		pending=false
	end)
	player:GetAttributeChangedSignal(attribute):Connect(updatePass)
	updatePass()
end
local supporter = require(storage.Shared.SupporterConfig)
local marketplace = game:GetService("MarketplaceService")
if storage:GetAttribute("DeadzoneSupporterEnabled") then
	local donation = button(panel, "Supporter Donation · loading price…", Color3.fromRGB(114, 185, 255))
	donation.Name = "SupporterDonation"
	local price
	local function updateDonation()
		if not price then
			donation.Text = "Supporter Donation · unavailable"
		else
			local benefit = if player:GetAttribute("DeadzoneSupporter") then "Support again" else "Unlock a permanent blue nametag"
			donation.Text = string.format("Supporter Donation · %d Robux\n%s", price, benefit)
		end
	end
	donation.Activated:Connect(function()
		if price then marketplace:PromptProductPurchase(player, supporter.ProductId) end
	end)
	player:GetAttributeChangedSignal("DeadzoneSupporter"):Connect(updateDonation)
	task.spawn(function()
		local ok, details = pcall(marketplace.GetProductInfo, marketplace, supporter.ProductId, Enum.InfoType.Product)
		if ok and details.IsForSale and type(details.PriceInRobux) == "number" then price = details.PriceInRobux end
		updateDonation()
	end)
end
local bagConfig=require(storage.Shared.BackpackConfig)
local slotLabel=button(panel,"",Color3.fromRGB(147,196,255))
local function slotText()
	local active=player:GetAttribute("PetSlots") or bagConfig.BaseSlots
	local tier=active-bagConfig.BaseSlots+1
	slotLabel.Text=if tier<=bagConfig.MaxPreviewTiers then
		string.format("Equip one more pet · %d Robux\nStudio price preview",bagConfig.FirstSlotPrice*2^(tier-1))
		else "Extra slot preview limit reached"
end
slotLabel.Activated:Connect(function()
	if not preview or not game:GetService("RunService"):IsStudio() or game.PlaceId~=0 or pending then return end
	pending=true
	local tier=(player:GetAttribute("PetSlots") or bagConfig.BaseSlots)-bagConfig.BaseSlots+1
	local ok,_,message=pcall(preview.InvokeServer,preview,"PreviewNextSlot",tier)
	info.Text=if ok then message else "Slot preview unavailable."
	pending=false
end)
player:GetAttributeChangedSignal("PetSlots"):Connect(slotText)
slotText()
caption(panel,"POTIONS · SCRAP",4,0,8,28,13,Color3.fromRGB(160,234,201))
local potionRemote=storage:WaitForChild("DeadzonePotions",20)
for _,key in {"Cash","Speed","Damage","Armor"} do
	local potion=bagConfig.Potions[key]
	local offer=button(panel,string.format("%s · %d Scrap\n%d%% · %ds",potion.Name,potion.Price,
		math.round(math.abs(1-potion.Factor)*100),potion.Duration),potion.Color)
	offer.Activated:Connect(function()
		if not potionRemote or pending then return end
		pending=true
		local ok,_,message=pcall(potionRemote.InvokeServer,potionRemote,"Buy",key)
		info.Text=if ok then message else "Potion purchase unavailable."
		pending=false
	end)
end
local premium = require(storage.Shared.PetConfig).Premium
local isPreview = game:GetService("RunService"):IsStudio() and game.PlaceId==0 and preview~=nil
local function petAction(name, tint, id)
	local action = button(panel,name,tint)
	action.Activated:Connect(function()
		if not isPreview or pending then return end
		pending=true
		local ok, _, message=pcall(preview.InvokeServer,preview,id)
		info.Text=if ok then message else "Preview unavailable. Try again shortly."
		pending=false
	end)
end
caption(panel,"PREMIUM PETS · INCOME & STYLE",4,0,8,28,13,Color3.fromRGB(242,203,255))
petAction("Gilt Moth · Guaranteed · +23% income\n"..(if isPreview then "Preview pet" else "Coming soon"),premium[1].Color,"PreviewPet")
local odds={}
for _, pet in premium do
	table.insert(odds,string.format("%s %g%%",pet.Name,pet.Weight/10))
end
local oddsLabel=caption(panel,table.concat({odds[1].."  ·  "..odds[2],odds[3].."  ·  "..odds[4]},"\n"),
	4,0,8,52,13,Color3.fromRGB(227,233,254))
oddsLabel.Size=UDim2.new(1,0,0,52)
petAction("Reactor Royal Egg\n"..(if isPreview then "Preview hatch" else "Coming soon"),Color3.fromRGB(187,146,255),"PreviewEgg")
if isPreview then petAction("End pet preview",Color3.fromRGB(154,186,227),"EndPetPreview") end
caption(panel,"SCRAP COSMETICS",4,0,8,25,13,Color3.fromRGB(240,217,255))
for _, item in require(storage.Shared.ShopConfig) do
	local row = button(panel, "", item.Color)
	local function update()
		row.Text = item.Name .. (if player:GetAttribute("PetTrail") == item.Id then " · Equipped"
			elseif player:GetAttribute("Shop_" .. item.Id) then " · Equip" else string.format(" · %d Scrap", item.Price))
	end
	row.Activated:Connect(function()
		if pending then return end
		pending = true
		local invoked, _, message = pcall(request.InvokeServer, request, item.Id)
		pending = false
		info.Text = if invoked then message else "Shop unavailable. Try again shortly."
	end)
	player:GetAttributeChangedSignal("Shop_" .. item.Id):Connect(update)
	player:GetAttributeChangedSignal("PetTrail"):Connect(update)
	update()
end
button(panel, "Power eggs · find your plot incubator", Color3.fromRGB(215, 144, 255)).Activated:Connect(function()
	local theme = require(storage.Shared.PetConfig).Themes[player:GetAttribute("ClaimedPower")]
	info.Text = if theme then theme.Name .. " · Buy the incubator after Twin Dropper. First hatch included."
		else "Claim a numbered plot to discover its power egg."
end)
button(panel, "Close", Color3.fromRGB(168, 190, 244)).Activated:Connect(function() panel.Visible = false end)
toggle.Activated:Connect(function() panel.Visible = not panel.Visible end)
