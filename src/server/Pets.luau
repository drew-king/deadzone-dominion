local Pets = {}
local Players = game:GetService("Players")
local Storage = game:GetService("ReplicatedStorage")
local roster = require(Storage.Shared.PetConfig)
local artAssets = game:GetService("ServerStorage"):FindFirstChild("DeadzoneArt")
local eggTemplate = artAssets and artAssets:FindFirstChild("PowerEggShell")
local byId = {}
for _, pet in ipairs(roster) do byId[pet.Id] = pet end
local rng = Random.new()
local Backpack = require(Storage.Shared.BackpackConfig)
local stationKeys = {[1]="EggMachine",[3]="ForgeEggMachine",[5]="LabEggMachine"}
local prices = Backpack.EggPrices
local floorTones = {[1]=Color3.fromRGB(148,211,249),[3]=Color3.fromRGB(255,179,79),[5]=Color3.fromRGB(217,133,255)}

function Pets.start(plots, profiles, economy)
	local remote = Instance.new("RemoteEvent")
	remote.Name = "DeadzonePets"
	remote.Parent = Storage
	local counters = {}
	local nextHatch, selections, auto = {}, {}, {}
	local testLoadouts={}
	local hatchUI=Instance.new("RemoteEvent")
	hatchUI.Name,hatchUI.Parent="DeadzoneHatch",Storage
	local function slots(p,profile)
		return Backpack.BaseSlots+(profile.extraPetSlots or 0)+(p:GetAttribute("PreviewExtraSlots") or 0)
	end
	local function publish(player)
		local profile = profiles[player]
		if not profile then return end
		for _, pet in ipairs(roster) do
			player:SetAttribute("PetOwned_" .. pet.Id, if profile.pets[pet.Id] then true else nil)
		end
		local loadout=profile.equippedPets or {}
		profile.equippedPet=loadout[1]
		player:SetAttribute("EquippedPet", player:GetAttribute("PreviewPremiumPet") or loadout[1])
		local visible=table.clone(loadout)
		for _,id in testLoadouts[player] or {} do table.insert(visible,id) end
		player:SetAttribute("EquippedPets",table.concat(visible,","))
		player:SetAttribute("PetSlots",slots(player,profile))
		player:SetAttribute("BackpackUsed",Backpack.Count(profile))
	end
	local function valid(p,selection)
		local profile=profiles[p]
		local char=p.Character
		local root=char and char:FindFirstChild("HumanoidRootPart")
		local human=char and char:FindFirstChildOfClass("Humanoid")
		return profile and selection and root and human and human.Health>0 and selection.plot.Owner==p
			and profile.upgrades[stationKeys[selection.floor]] and (root.Position-selection.station.Position).Magnitude<=10
	end
	local function hatch(p,selection,quantity)
		if not valid(p,selection) then return false,"Return to your egg station." end
		if quantity~=1 and (quantity~=3 or not p:GetAttribute("PreviewPass_TripleHatch")) then return false,"Triple Hatch is unavailable." end
		local now=os.clock()
		if now<(nextHatch[p] or 0) then return false,"Wait for the current hatch." end
		nextHatch[p]=now+.8
		local profile=profiles[p]
		local floor,pool=selection.floor,selection.pool
		local price=(prices[floor]*quantity)-(if floor==1 and not profile.starterEggUsed then prices[1] else 0)
		if profile.wallet<price then return false,"You need "..price.." Scrap." end
		local unowned=0
		for _,pet in pool.Pets do if not profile.pets[pet.Id] then unowned+=1 end end
		local free=math.max(0,Backpack.Capacity-Backpack.Count(profile))
		if math.min(quantity,unowned)>free then return false,"Make room for up to "..math.min(quantity,unowned).." new pet types." end
		local rewards={}
		local freeFirst=floor==1 and not profile.starterEggUsed
		local refund=0
		profile.wallet-=price
		if floor==1 then profile.starterEggUsed=true end
		profile.equippedPets=profile.equippedPets or {}
		for rollIndex=1,quantity do
			local roll=rng:NextInteger(1,1000)
			for _,pet in pool.Pets do
				roll-=pet.Weight
				if roll>0 then continue end
				local duplicate=profile.pets[pet.Id]==true
				if duplicate and not (rollIndex==1 and freeFirst) then refund+=math.floor(prices[floor]/4) end
				profile.pets[pet.Id]=true
				table.insert(rewards,{id=pet.Id,duplicate=duplicate})
				if not duplicate and #profile.equippedPets<Backpack.BaseSlots then table.insert(profile.equippedPets,pet.Id) end
				break
			end
		end
		profile.wallet+=refund
		if not p:GetAttribute("PlaytestPreset") then p:SetAttribute("ScrapSpent",(p:GetAttribute("ScrapSpent") or 0)+price-refund) end
		publish(p)
		economy.publish(selection.plot)
		hatchUI:FireClient(p,"Result",rewards,refund)
		return true
	end
	hatchUI.OnServerEvent:Connect(function(p,action,quantity)
		local selected=selections[p]
		if action=="Stop" then auto[p]=nil; return end
		if action=="Auto" then
			if not p:GetAttribute("PreviewPass_AutoOpen") then hatchUI:FireClient(p,"Status","Auto-Open is unavailable."); return end
			if auto[p] then return end
			local token={}
			auto[p]=token
			task.spawn(function()
				while auto[p]==token and selections[p]==selected and p:GetAttribute("PreviewPass_AutoOpen") do
					local ok,message=hatch(p,selected,quantity)
					if not ok then hatchUI:FireClient(p,"Status",message); break end
					task.wait(2.4)
				end
				if auto[p]==token then auto[p]=nil end
			end)
		elseif action=="Hatch" and not auto[p] then
			local ok,reason=hatch(p,selected,quantity)
			if not ok then hatchUI:FireClient(p,"Status",reason) end
		end
	end)
	for _, plot in plots do
		for _, floor in {1,3,5} do
		local theme = roster.Themes[plot.Name].Floors[floor]
		local levelY=12*(floor-1)
		local station = Instance.new("Part")
		station.Name, station.Anchored = if floor==1 then "PetIncubator" else "PetIncubator"..floor, true
		station.Size, station.Color = Vector3.new(4, 3, 4), theme.Color:Lerp(Color3.fromRGB(35, 47, 71), .55)
		station.CFrame = plot.Model:GetPivot() * CFrame.new(if floor==1 then -13 else -46, 1.9+levelY, if floor==1 then 22 else -18)
		station.Parent = plot.Model
		local art = require(script.Parent.FactoryArt)
		art.station(station, theme.Color)
		local egg
		if eggTemplate and eggTemplate:IsA("MeshPart") and eggTemplate.MeshId ~= "" then
			egg = eggTemplate:Clone()
			egg.Name, egg.Size, egg.Color = "PowerEgg", Vector3.new(2, 2.6, 2), theme.Color
			egg.Material, egg.Anchored, egg.CastShadow = Enum.Material.SmoothPlastic, true, false
			egg.CanCollide, egg.CanQuery, egg.CanTouch = false, false, false
			egg.CFrame, egg.Parent = station.CFrame * CFrame.new(0, 2.45, 0), station
		else
			egg = art.detail(station, "PowerEgg", station.CFrame * CFrame.new(0, 2.45, 0),
				Vector3.new(2, 2.6, 2), theme.Color, Enum.Material.SmoothPlastic)
			egg.Shape = Enum.PartType.Ball
		end
		art.crest(egg, egg.CFrame * CFrame.new(0, .12, 1.03), .48, plot.Index)
		local glow = Instance.new("PointLight")
		glow.Color, glow.Range, glow.Brightness, glow.Parent = floorTones[floor], 11, 1.2, egg
		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText, prompt.ActionText = theme.Name, "View odds · "..prices[floor].." Scrap"
		prompt.MaxActivationDistance, prompt.HoldDuration = 10, .45
		prompt.Parent = station
		prompt.Triggered:Connect(function(player)
			local selected={plot=plot,station=station,floor=floor,pool=theme}
			if not valid(player,selected) then return end
			selections[player],auto[player]=selected,nil
			local profile=profiles[player]
			hatchUI:FireClient(player,"Open",plot.Name,floor,prices[floor],floor==1 and not profile.starterEggUsed)
		end)
		if floor==1 then plot.EggPrompt,plot.EggStation=prompt,station end
		plot.Construction[stationKeys[floor]]={station}
		art.setBuilt(station,false)
		end
	end
	remote.OnServerEvent:Connect(function(player, id)
		local now = os.clock()
		if now < (counters[player] or 0) then return end
		counters[player] = now + .25
		local profile = profiles[player]
		if not profile or type(id) ~= "string" or (id ~= "" and not profile.pets[id]) then return end
		profile.equippedPets=profile.equippedPets or {}
		local loadout=profile.equippedPets
		local extra=testLoadouts[player] or {}
		testLoadouts[player]=extra
		if id=="" then table.clear(loadout); table.clear(extra)
		else
			local index=table.find(loadout,id)
			local previewIndex=table.find(extra,id)
			if index then table.remove(loadout,index)
			elseif previewIndex then table.remove(extra,previewIndex)
			elseif #loadout+#extra<slots(player,profile) then
				local permanent=Backpack.BaseSlots+(profile.extraPetSlots or 0)
				if #loadout<permanent then table.insert(loadout,id)
				else table.insert(extra,id) end
			else player:SetAttribute("ClaimFeedback","No open pet slot. Unequip a pet first.") end
		end
		publish(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		counters[player], nextHatch[player], selections[player],auto[player] = nil,nil,nil,nil
		testLoadouts[player]=nil
	end)
	return {publish = publish, income = function(player)
		local profile = profiles[player]
		if not profile then return 1 end
		local preview=byId[player:GetAttribute("PreviewPremiumPet")]
		local bonus=if preview then preview.Income-1 else 0
		for index,id in (profile.equippedPets or {}) do
			if not (preview and index==1) then bonus+=byId[id].Income-1 end
		end
		for _,id in testLoadouts[player] or {} do bonus+=byId[id].Income-1 end
		return math.min(2,1+bonus)
	end}
end

return Pets
