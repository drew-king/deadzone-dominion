local Economy = {}
local TweenService = game:GetService("TweenService")
local Art = require(script.Parent.FactoryArt)
local RefineryArt = require(script.Parent.RefineryArt)
local CargoArt = require(script.Parent.CargoArt)
local CargoRoutes = require(game.ReplicatedStorage.Shared.CargoRoutes)
local ProductionModel = require(game.ReplicatedStorage.Shared.ProductionModel)
local Backpack = require(game.ReplicatedStorage.Shared.BackpackConfig)
local palette = require(game:GetService("ReplicatedStorage").Shared.VisualTheme)

function Economy.start(plots, config, getPlot, profiles, incomeMultiplier, onRebirth)
	local productionRate, costRate = 1, 1
	local paused, combatPaused = false, false
	local function setPad(prompt, label, visible)
		local pad = prompt.Parent
		pad.Transparency = if visible then 0 else 1
		pad.CanCollide, pad.CanTouch, pad.CanQuery = false, false, visible
		prompt.Enabled, label.Parent.Enabled = visible, visible
		local rim = pad:FindFirstChild("PadRim")
		if rim then Art.setBuilt(rim, visible) end
	end
	local function refreshDocks(plot,upgrades)
		local draining={}
		for item in plot.Cargo do draining[item:GetAttribute("CargoDock") or "Starter"]=true end
		Art.setBuilt(plot.Model.ScrapExchange, upgrades.StarterFactory == true and (not upgrades.BeltAnnex or draining.Starter)==true)
		Art.setBuilt(plot.ExtensionDocks.annex, upgrades.BeltAnnex == true and (not upgrades.BeltDispatch or draining.Annex)==true)
		Art.setBuilt(plot.ExtensionDocks.refinery, upgrades.RefineryBelt == true and (not upgrades.CargoLift or draining.Refinery)==true)
	end
	local function construction(plot, upgrades)
		for key, items in plot.Construction do
			for _, item in items do Art.setBuilt(item, upgrades[key] == true) end
		end
		Art.setBuilt(plot.ForgeGate, upgrades.UpperAccess == true and upgrades.ForgeAccess ~= true)
		Art.setBuilt(plot.Model.CargoShaftCover, upgrades.ForgeAccess == true and upgrades.CargoLift ~= true)
		refreshDocks(plot,upgrades)
		plot.UpperDirectory.Text = if upgrades.UpperAccess then "FLOOR TWO · REFINERY\nUse the stairs beside this sign"
			else "FLOOR TWO · REFINERY\nBuy access after Reactor Dropper"
		for index, stage in plot.DropperStages do
			local key = ({"StarterFactory", "Production", "Foundry", "Reactor"})[index]
			for _, item in stage do Art.setBuilt(item, upgrades[key] == true) end
		end
	end
	local function publishCollector(plot)
		local ready = plot.Pending > 0
		plot.Collector.ActionText = "Collect " .. plot.Pending .. " Scrap"
		plot.CollectorDisplay.Text = if ready then "COLLECT SCRAP\n" .. plot.Pending .. " READY" else "COLLECT SCRAP\nWAITING FOR CARGO"
		plot.CollectorIndicator.Color = if ready then palette.Gold else palette.Teal
		plot.RefineryDispatch.Text = if plot.LastCargoSale then string.format("03 · DISPATCH\nLatest +%d · Bank %d Scrap",
			plot.LastCargoSale, plot.Pending) else "03 · DISPATCH\nWaiting for a sale"
	end
	local function publishBalance(plot)
		local owner = plot.Owner
		local profile = owner and profiles[owner]
		if not profile then return end
		owner:SetAttribute("ScrapCash", profile.wallet)
		owner:SetAttribute("PendingScrap", plot.Pending)
		publishCollector(plot)
		if plot.LastLabelWallet == profile.wallet and plot.LastLabelCost == costRate then return end
		plot.LastLabelWallet, plot.LastLabelCost = profile.wallet, costRate
		for key, prompt in plot.Purchases do
			local label = plot.PurchaseLabels[key]
			local price = math.ceil(config.Prices[key] * costRate)
			local affordable = profile.wallet >= price
			local base = prompt.Parent.Color
			label.BackgroundColor3 = base:Lerp(Color3.new(), if affordable then .25 else .62)
			local action = if affordable then "Buy" else "Need"
			label.Text = string.upper(config.Names[key]) .. "\n" .. config.Benefits[key]
				.. "\n" .. action .. " · " .. price .. " Scrap"
		end
	end
	local function collect(plot, player)
		local profile = profiles[player]
		if not profile or plot.Owner ~= player or getPlot(player) ~= plot or not profile.upgrades.StarterFactory then return 0 end
		local taken = math.min(plot.Pending, config.MaxWallet - profile.wallet)
		profile.wallet += taken
		plot.Pending -= taken
		if taken > 0 then player:SetAttribute("FirstScrapCollected", true) end
		publishBalance(plot)
		return taken
	end
	local function publish(plot)
		local p = plot.Owner
		if not p then return end
		local profile = profiles[p]
		if not profile then return end
		p:SetAttribute("HasWalls", profile.upgrades.Walls == true)
		p:SetAttribute("HasProduction", profile.upgrades.Production == true)
		local nextKey
		local choices = {}
		for _, branch in config.Branches do
			for _, key in branch.Keys do
				if config.canPurchase(profile.upgrades, key, profile.rebirths) then
					table.insert(choices, branch.Name .. ": " .. config.Names[key])
					break
				end
			end
		end
		p:SetAttribute("UpgradeChoices", table.concat(choices, "  |  "))
		for _, key in {"StarterFactory", "Production", "BeltAnnex", "Foundry", "BeltDispatch", "Reactor", "UpperAccess"} do
			if config.canPurchase(profile.upgrades, key, profile.rebirths) then
				nextKey = key
				break
			end
		end
		if not nextKey then
			for _, key in config.Order do
				if config.canPurchase(profile.upgrades, key, profile.rebirths)
					and (not nextKey or config.Prices[key] < config.Prices[nextKey]) then nextKey = key end
			end
		end
		p:SetAttribute("NextUpgradePrice", if nextKey then math.ceil(config.Prices[nextKey] * costRate) else nil)
		p:SetAttribute("NextUpgradeName", nextKey and config.Names[nextKey])
		p:SetAttribute("NextUpgradeFloor", nextKey and config.FloorByUpgrade[nextKey])
		local capstone, rebirthCost, topFloor = config.rebirthRequirement(profile.rebirths)
		p:SetAttribute("RebirthPrice", if profile.upgrades[capstone] then rebirthCost else nil)
		p:SetAttribute("RebirthFloor", topFloor)
		local installedCount, eligibleCount = 0, 0
		for key, prompt in plot.Purchases do
			local installed = profile.upgrades[key] == true
			if installed then installedCount += 1 end
			if (profile.rebirths or 0) >= (config.MinimumRebirth[key] or 0) then eligibleCount += 1 end
			setPad(prompt, plot.PurchaseLabels[key], config.canPurchase(profile.upgrades, key, profile.rebirths))
			prompt.ActionText = "Buy · " .. math.ceil(config.Prices[key] * costRate) .. " Scrap"
		end
		publishBalance(plot)
		p:SetAttribute("FloorProgress", string.format("%d/%d installed", installedCount, eligibleCount))
		p:SetAttribute("Rebirths", profile.rebirths or 0)
		for floorNumber, rebirthPrompt in plot.RebirthPrompts do
			local active = floorNumber == topFloor and profile.upgrades[capstone] == true
			Art.setBuilt(rebirthPrompt.Parent, active)
			rebirthPrompt.ActionText = "Reset plot · " .. rebirthCost .. " Scrap"
		end
		for key, pieces in plot.FloorDetails do
			for _, piece in pieces do
				if piece:IsA("BasePart") then
					piece.Transparency = if profile.upgrades[key] then 0 else 1
					piece.CanCollide = profile.upgrades[key] == true and piece.Name == "BayScreen"
					piece.CanQuery = piece.CanCollide
				elseif piece:IsA("Light") or piece:IsA("SurfaceGui") then
					piece.Enabled = profile.upgrades[key] == true
				elseif piece:IsA("ProximityPrompt") then
					piece.Enabled = profile.upgrades[key] == true
				end
			end
		end
		construction(plot, profile.upgrades)
		if plot.EggPrompt then
			plot.EggPrompt.ActionText = if not profile.starterEggUsed then "View odds · first hatch free"
				else "View odds · "..Backpack.EggPrices[1].." Scrap"
		end
		plot.Generator.Color = if profile.upgrades.Production then Color3.fromRGB(74, 232, 164) else Color3.fromRGB(255, 174, 72)
	end

	local function station(plot, name, offset, size, color)
		local part = Instance.new("Part")
		part.Name, part.Anchored, part.Size, part.Color = name, true, size, color
		part.Material = Enum.Material.Metal
		part.CFrame = plot.Model:GetPivot() * CFrame.new(offset)
		part.Parent = plot.Model
		return part
	end

	local function prompt(part, name, action)
		local ui = Instance.new("ProximityPrompt")
		ui.ObjectText, ui.ActionText, ui.MaxActivationDistance = name, action, 10
		ui.Parent = part
		return ui
	end

	local function panel(part, text, face)
		local gui = Instance.new("SurfaceGui")
		gui.Face = face
		gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
		gui.PixelsPerStud = 36
		gui.Parent = part
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundColor3 = Color3.fromRGB(19, 28, 37)
		label.TextColor3 = Color3.fromRGB(247, 236, 200)
		label.TextScaled, label.TextWrapped = true, true
		label.Font = Enum.Font.GothamBold
		label.Text = text
		label.Parent = gui
		return label
	end
	local function machineReadout(machine, text, face)
		local side = if face == Enum.NormalId.Back then 1 else -1
		local plate = Art.detail(machine, "MachineReadout",
			machine.CFrame * CFrame.new(0, -.18, side * (machine.Size.Z / 2 + .14)),
			Vector3.new(machine.Size.X * .85, math.min(1.08, machine.Size.Y * .66), .14), palette.Ink, Enum.Material.SmoothPlastic)
		local label = panel(plate, text, face)
		label.Parent.LightInfluence = 0
		return label
	end

	local function authorized(player, plot, ui)
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if getPlot(player) ~= plot or plot.Owner ~= player or not profiles[player]
			or not root or not humanoid or humanoid.Health <= 0 then return false end
		local anchor = ui.Parent
		local position = if anchor:IsA("Attachment") then anchor.WorldPosition else anchor.Position
		local offset = root.Position - position
		return math.abs(offset.Y) <= 5 and offset.Magnitude <= ui.MaxActivationDistance
	end

	local function clearCargo(plot)
		for part, tween in plot.Cargo do
			plot.Cargo[part] = nil
			tween:Cancel()
			part:Destroy()
		end
	end

	local function dropCargo(plot, owner, profile, z, earned, speed, color, tier, refinery)
		local count = 0
		for _ in plot.Cargo do count += 1 end
		if count >= 20 then return end
		local pivot = plot.Model:GetPivot()
		local route = CargoRoutes.points(profile.upgrades,z,refinery)
		local offset = route[1] + Vector3.yAxis * 2.86
		local size = if tier >= 4 then Vector3.new(1.75, 1.4, 1.75) else Vector3.new(1.35, 1.15, 1.55)
		local item = Art.mesh("CargoTier" .. tier, "ScrapCargo", pivot * CFrame.new(offset), size, color)
		if not item then
			local fallback = station(plot, "ScrapCargo", offset, size, color)
			if tier == 1 or tier >= 4 then fallback.Shape = Enum.PartType.Ball
			elseif tier == 2 then fallback.Shape = Enum.PartType.Cylinder
			else fallback.CFrame *= CFrame.Angles(0, math.pi / 4, 0) end
			item = fallback
		end
		item:SetAttribute("CargoTier", tier)
		item:SetAttribute("CargoLine", if refinery then (if profile.upgrades.CargoLift then "Lift" else "Refinery") else "Ground")
		item:SetAttribute("CargoDock",if refinery then (if profile.upgrades.CargoLift then "Lift" else "Refinery")
			elseif profile.upgrades.BeltDispatch then "Dispatch" elseif profile.upgrades.BeltAnnex then "Annex" else "Starter")
		item.Material = Enum.Material.SmoothPlastic
		item.CastShadow = false
		local rotation = item.CFrame.Rotation
		item.CanCollide, item.CanTouch, item.CanQuery = false, false, false
		item.Parent = plot.Model
		local function target(point)
			return CFrame.new(pivot:PointToWorldSpace(point+Vector3.yAxis*size.Y/2))*rotation
		end
		local landing = TweenService:Create(item, TweenInfo.new(.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = target(route[1]),
		})
		plot.Cargo[item] = landing
		local function advance(index,tween,result)
				if plot.Cargo[item] ~= tween then return end
				if result == Enum.PlaybackState.Completed and index < #route and plot.Owner == owner and profiles[owner] == profile then
					local nextTween=TweenService:Create(item,TweenInfo.new((route[index+1]-route[index]).Magnitude/speed,Enum.EasingStyle.Linear),
						{CFrame=target(route[index+1])})
					plot.Cargo[item]=nextTween
					nextTween.Completed:Once(function(state) advance(index+1,nextTween,state) end)
					nextTween:Play()
					return
				end
				plot.Cargo[item] = nil
				item:Destroy()
				if plot.Owner==owner and profiles[owner]==profile then refreshDocks(plot,profile.upgrades) end
				if result ~= Enum.PlaybackState.Completed or paused or plot.Owner ~= owner or profiles[owner] ~= profile then return end
				local total = earned + plot.FractionalScrap
				local whole = math.floor(total)
				local upgrades = profile.upgrades
				local space = if upgrades.LabAccess then 16 elseif upgrades.GridAccess then 8
					elseif upgrades.ForgeAccess then 4 elseif upgrades.UpperAccess then 2 else 1
				local capacity = config.MaxPending * space
				local credited = math.min(whole, math.max(0, capacity - plot.Pending))
				plot.LastCargoSale = credited
				plot.Pending += credited
				plot.FractionalScrap = if plot.Pending >= capacity then 0 else total - whole
				plot.ExchangeLabel.Text = if credited > 0 then "SCRAP EXCHANGE\n+" .. credited .. " SCRAP"
					elseif plot.Pending >= capacity then "SCRAP EXCHANGE\nBUFFER FULL" else "SCRAP EXCHANGE\nCARGO PROCESSED"
				publishBalance(plot)
		end
		landing.Completed:Once(function(state) advance(1,landing,state) end)
		landing:Play()
	end

	local function bindRouting(plot, key, machine, readout, value, speed)
		local switch = prompt(machine, config.Names[key], "Switch to Express")
		switch.Enabled, switch.RequiresLineOfSight = false, false
		local function showMode(express)
			plot.ExpressRouting[key] = express
			readout.Text = if express then "EXPRESS\n+" .. speed .. " STUDS/S BELT SPEED" else "VALUE\n+" .. value .. " BASE SCRAP / CARGO"
			switch.ActionText = if express then "Switch to Value" else "Switch to Express"
		end
		plot.RoutingDisplays[key] = showMode
		showMode(false)
		switch.Triggered:Connect(function(player)
			if not authorized(player, plot, switch) or not profiles[player].upgrades[key] then return end
			showMode(not plot.ExpressRouting[key])
			player:SetAttribute("ClaimFeedback", readout.Text:gsub("\n", " · "))
		end)
		table.insert(plot.FloorDetails[key], switch)
	end
	for _, plot in plots do
		plot.ExpressRouting, plot.RoutingDisplays = {}, {}
		plot.ResetRunDevices = function()
			plot.LastCargoSale = nil
			for _, showMode in plot.RoutingDisplays do showMode(false) end
			if plot.Analyzer then
				plot.Analyzer:Destroy()
				plot.Analyzer = nil
			end
		end
		local beforeFactory = {}
		for _, item in plot.Model:GetChildren() do beforeFactory[item] = true end
		local gold, teal = plot.Theme[3], plot.Theme[2]
		plot.Pending = 0
		plot.FractionalScrap = 0
		plot.Generator = station(plot, "ScrapGenerator", Vector3.new(-33.75, 2.9, 19), Vector3.new(6, 5, 7), gold)
		Art.station(plot.Generator, teal)
		plot.Cargo, plot.FloorDetails, plot.PurchaseLabels = {}, {}, {}
		station(plot, "ConveyorFrame", Vector3.new(-22, .58, 0), Vector3.new(5, .36, 52), Color3.fromRGB(38, 49, 66))
		for z = -22, 22, 8 do
			for _, x in {-24.55, -19.45} do
				Art.detail(plot.Model, "ConveyorMarker", plot.Model:GetPivot() * CFrame.new(x, .76, z),
					Vector3.new(.16, .2, 1.5), gold, Enum.Material.SmoothPlastic)
			end
		end
		for z = -25, 25, 2 do
			station(plot, "BeltRoller", Vector3.new(-22, .85, z), Vector3.new(4.2, .18, 1.6), if z % 4 == 1 then teal else Color3.fromRGB(54, 67, 81))
		end
		for _, x in {-24.35, -19.65} do
			station(plot, "BeltEdge", Vector3.new(x, 1, 0), Vector3.new(.23, .32, 52), gold)
		end
		local exchange = station(plot, "ScrapExchange", Vector3.new(-22, 2.25, -27), Vector3.new(6, 3.7, 2), Color3.fromRGB(44, 77, 102))
		plot.ExchangeLabel = panel(exchange, "SCRAP EXCHANGE", Enum.NormalId.Back)
		local exchangePlate = Art.detail(exchange, "ExchangeFrontPlate", exchange.CFrame * CFrame.new(0, .48, -1.07),
			Vector3.new(5.4, 1.48, .14), palette.Ink, Enum.Material.SmoothPlastic)
		panel(exchangePlate, "CARGO EXCHANGE\nCONVERTS CARGO TO SCRAP", Enum.NormalId.Front).Parent.LightInfluence = 0
		Art.detail(exchange, "ExchangeStatusTrim", exchangePlate.CFrame * CFrame.new(0, -.81, 0),
			Vector3.new(5.4, .23, .18), teal, Enum.Material.Neon)
		Art.station(exchange, teal)
		local collector = station(plot, "ScrapCollector", Vector3.new(-13, 1.9, -29), Vector3.new(5, 3, 5), palette.Teal)
		local collectorAnchor = Instance.new("Attachment")
		collectorAnchor.Name, collectorAnchor.Position = "CollectorInteraction", Vector3.new(0, 2, -1.5)
		collectorAnchor.Parent = collector
		plot.Collector = prompt(collectorAnchor, "Scrap collector", "Collect")
		local display = Art.detail(collector, "CollectorDisplay", collector.CFrame * CFrame.new(0, .47, -2.65)
			* CFrame.Angles(math.rad(20), 0, 0), Vector3.new(4.65, 1.52, .17), palette.Ink, Enum.Material.SmoothPlastic)
		plot.CollectorDisplay = panel(display, "COLLECT SCRAP\nWAITING FOR CARGO", Enum.NormalId.Front)
		plot.CollectorDisplay.Parent.LightInfluence = 0
		plot.CollectorIndicator = Art.detail(collector, "CollectorIndicator", display.CFrame * CFrame.new(0, -.84, 0),
			Vector3.new(4.65, .2, .24), palette.Teal, Enum.Material.Neon)
		plot.Wall = station(plot, "ReinforcedBarricade", Vector3.new(-35, 3.4, 49), Vector3.new(11, 6, 2), teal)
		Art.station(collector, gold)
		Art.station(plot.Wall, gold)
		table.insert(plot.Construction.Walls, plot.Wall)
		plot.Construction.StarterFactory = {}
		for _, item in plot.Model:GetChildren() do
			if not beforeFactory[item] and item ~= plot.Wall then
				table.insert(plot.Construction.StarterFactory, item)
			end
		end
		plot.Purchases = {}
		plot.DropperStages = {}
		for index = 1, 4 do
			local z = CargoRoutes.GroundDropperZ[index]
			local details = {}
			for _, piece in ipairs({
				{"Chassis", Vector3.new(4, 1, 5), Vector3.new(-27, .9, z), Color3.fromRGB(48, 59, 73)},
				{"Column", Vector3.new(2, 5, 2), Vector3.new(-27, 3.5, z), teal},
				{"FeedHousing", Vector3.new(6, 2, 3), Vector3.new(-24.5, 6, z), gold},
				{"OutputNozzle", Vector3.new(2, 1.5, 2), Vector3.new(-22.5, 4.6, z), teal},
				{"EnergyCell", Vector3.new(1.4, 2 + index * .35, 1.4), Vector3.new(-26.8, 5.7, z + 1.5), Color3.fromHSV(.10 + index * .14, .68, 1)},
			}) do
				local detail = station(plot, "Dropper" .. index .. piece[1], piece[3], piece[2], piece[4])
				detail.CanCollide, detail.CanQuery, detail.CanTouch = false, false, false
				if piece[1] == "EnergyCell" then detail.Material = Enum.Material.Neon end
				if piece[1] == "FeedHousing" then
					local model = Art.mesh("DropperHousing", "HousingMesh", detail.CFrame, detail.Size, gold)
					if model then
						detail.Transparency = 1
						model.Parent = detail
					else
						Art.station(detail, teal)
					end
					Art.crest(detail, detail.CFrame * CFrame.new(0, 0, 1.57), .72, plot.Index)
				elseif piece[1] == "OutputNozzle" then
					detail.Shape = Enum.PartType.Cylinder
					detail.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
					detail.Size = Vector3.new(1.5, 2, 2)
				end
				table.insert(details, detail)
			end
			plot.DropperStages[index] = details
			local accent = Color3.fromHSV(.24 + (index - 1) * .14, .68, 1)
			for fin = 1, index + 1 do
				local coolingFin = Art.detail(plot.Model, "Dropper" .. index .. "CoolingFin",
					plot.Model:GetPivot() * CFrame.new(-26.8, 6.99, z - 1.2 + fin * .42),
					Vector3.new(2.4, .52 + index * .14, .18), accent, Enum.Material.Metal)
				table.insert(details, coolingFin)
			end
		end
		CargoArt.build(plot)
		local locations={{-14,-43},{-14,-50},{-16,-43},{-8,-43},{0,-43},{10,-35}}
		for index,row in CargoRoutes.Nodes do
			local id, label, _, floorNumber=table.unpack(row)
			local x,z=table.unpack(locations[index])
			local pad=station(plot,id.."Pad",Vector3.new(x,.51+12*(floorNumber-1),z),Vector3.new(4.4,.22,4.4),teal)
			plot.Purchases[id]=prompt(pad,label,"Locked")
		end
		for _,entry in {{"ForgeEggMachine",3},{"LabEggMachine",5}} do
			local id, level = table.unpack(entry)
			local pad=station(plot,id.."Pad",Vector3.new(-41,.51+12*(level-1),-18),Vector3.new(4.4,.22,4.4),gold)
			plot.Purchases[id]=prompt(pad,config.Names[id],"Locked")
		end
		for branchIndex, branch in config.Branches do
			for index, key in branch.Keys do
				if config.FloorByUpgrade[key] ~= 1 then continue end
				local column = (index - 1) % 3
				local row = math.floor((index - 1) / 3)
				local x = if branchIndex == 1 then -5 + column * 6 elseif branchIndex == 2 then 31
					elseif branchIndex == 4 then 42 elseif branchIndex == 5 then -12 else 13 + column * 6
				local z = if branchIndex == 2 then -48 + (index - 1) * 6 elseif branchIndex == 4 then 35
					elseif branchIndex == 5 then 15 else -43 + row * 7
				if branch.Name == "Defense" then
					x, z = -47 + column * 6, 35 + row * 6
				end
				local pad = station(plot, key .. "Pad", Vector3.new(x, .51, z), Vector3.new(4.4, .22, 4.4),
					Color3.fromHSV(.08 + branchIndex * .16, .65, .92))
				plot.Purchases[key] = prompt(pad, config.Names[key], "Locked")
				pad.Material = Enum.Material.SmoothPlastic
			end
		end
		for index, row in config.Floor do
			local key, _, _, kind, bay = table.unpack(row)
			local slot = (index - 1) % 5
			local z = 1 + slot * 6
			local accent = Color3.fromHSV(.46 + bay * .1, .65, .96)
			local detailX = ({-46, -39, 20, 28})[bay]
			local heights = {machine = 4, rail = 1, scanner = 5, lights = 7, screen = 5}
			if kind == "scanner" then detailX, z = -22, -1 - bay * 5 end
			local size = if kind == "scanner" then Vector3.new(5.7, .6, 1.2)
				else Vector3.new(if kind == "screen" then 1 else 3, heights[kind], if kind == "screen" then 5 else 3)
			local baseY = if kind == "scanner" then 2.8 else .4
			local detail = station(plot, if kind == "screen" then "BayScreen" else key, Vector3.new(detailX, baseY + size.Y / 2, z), size, accent)
			detail.CanCollide, detail.CanTouch, detail.CanQuery, detail.Transparency = false, false, false, 1
			local trim = station(plot, key .. "Trim", Vector3.new(detailX, baseY + size.Y + .2, z), Vector3.new(size.X + .35, .4, size.Z + .35), gold)
			trim.Material = Enum.Material.SmoothPlastic
			trim.CanCollide, trim.CanTouch, trim.CanQuery, trim.Transparency = false, false, false, 1
			local pieces = {detail, trim}
			local status = panel(detail, config.Names[key] .. "\n" .. config.Benefits[key],
				if kind == "rail" or kind == "scanner" then Enum.NormalId.Top else Enum.NormalId.Back)
			status.Parent.LightInfluence, status.Parent.Enabled = 0, false
			table.insert(pieces, status.Parent)
			if kind == "machine" then
				local head = Art.detail(detail, "ProcessingHead", detail.CFrame * CFrame.new(0, 1.65, 0),
					Vector3.new(2.05, 1.4, 2.05), gold, Enum.Material.Metal)
				for _, side in {-1, 1} do
					local rib = Art.detail(detail, "CoolingRib", detail.CFrame * CFrame.new(side * 1.56, .5, 0),
						Vector3.new(.2, 2.1, 2.18), palette.Ink, Enum.Material.Metal)
					rib.Transparency = 1
					table.insert(pieces, rib)
				end
				head.Transparency = 1
				table.insert(pieces, head)
			end
			if kind == "scanner" then
				for _, side in {-1, 1} do
					local post = station(plot, key .. "Post", Vector3.new(detailX + side * 2.85, 1.6, z), Vector3.new(.55, 2.4, .8), accent)
					post.CanCollide, post.CanTouch, post.CanQuery, post.Transparency = false, false, false, 1
					table.insert(pieces, post)
				end
			end
			if kind == "lights" then
				local lamp = Instance.new("PointLight")
				lamp.Color, lamp.Range, lamp.Brightness, lamp.Enabled = accent, 10, .55, false
				lamp.Parent = trim
				table.insert(pieces, lamp)
			end
			plot.FloorDetails[key] = pieces
		end
		RefineryArt.build(plot)
		for index, row in config.Upper do
			local key, name = table.unpack(row)
			local originalRow = index <= 5
			local x = if originalRow then -23 + (index - 1) * 9 else -33 + (index - 6) * 8.5
			local pad = station(plot, key .. "Pad", Vector3.new(x, 12.51, if originalRow then 36 else 27),
				Vector3.new(5, .22, 5), if originalRow then teal else gold)
			plot.Purchases[key] = prompt(pad, name, "Locked")
			local machine = station(plot, key .. "Module", Vector3.new(x, 13.85, if originalRow then 46 else 19),
				Vector3.new(5, 2.9, 3.6), if originalRow then gold else teal)
			Art.station(machine, teal)
			local frame = machine.CFrame
			Art.detail(machine, "RefineryBase", frame * CFrame.new(0, -1.27, 0),
				Vector3.new(5.3, .36, 3.8), palette.Ink, Enum.Material.SmoothPlastic)
			local kind = (index - 1) % 4
			for slot = 1, kind + 1 do
				Art.detail(machine, "RefineryCell", frame * CFrame.new(-1.8 + (slot - 1) * 1.15, 1.69, 0),
					Vector3.new(.87, .48, 1.95), if slot == 1 then palette.Cream else gold, Enum.Material.SmoothPlastic)
			end
			machine.Transparency, machine.CanCollide, machine.CanTouch, machine.CanQuery = 1, false, false, false
			local readout = machineReadout(machine, name .. "\n" .. config.Benefits[key],
				if originalRow then Enum.NormalId.Front else Enum.NormalId.Back)
			readout.Parent.Enabled = false
			plot.FloorDetails[key] = {machine, readout.Parent}
			for _, piece in machine:GetDescendants() do
				if piece:IsA("BasePart") then
					piece.Transparency = 1
					table.insert(plot.FloorDetails[key], piece)
				end
			end
			if key == "RefineryLamps" or key == "RefineryBeacon" then
				local lamp = Instance.new("PointLight")
				lamp.Color, lamp.Range, lamp.Brightness, lamp.Enabled = gold, 17, .7, false
				lamp.Parent = machine
				table.insert(plot.FloorDetails[key], lamp)
			elseif key == "RoutingConsole" then
				bindRouting(plot, key, machine, readout, 30, 10)
			elseif key == "CargoAnalyzer" then
				local issue = prompt(machine, "Cargo Analyzer", "Equip scanner")
				issue.Enabled, issue.RequiresLineOfSight = false, false
				issue.Triggered:Connect(function(player)
					if not authorized(player, plot, issue) or not profiles[player].upgrades.CargoAnalyzer then return end
					local backpack = player:FindFirstChildOfClass("Backpack")
					if not backpack then return end
					if plot.Analyzer then plot.Analyzer:Destroy() end
					local tool = Instance.new("Tool")
					tool.Name, tool.CanBeDropped = "Cargo Analyzer", false
					tool.ToolTip = "Scan your exchange and the latest shipment"
					local handle = Instance.new("Part")
					handle.Name, handle.Size, handle.Color = "Handle", Vector3.new(.65, .4, 1.2), gold
					handle.CanCollide, handle.CanQuery, handle.CanTouch, handle.Massless = false, false, false, true
					handle.Parent = tool
					local screen = Instance.new("SurfaceGui")
					screen.Face, screen.LightInfluence, screen.Parent = Enum.NormalId.Top, 0, handle
					local name = Instance.new("TextLabel")
					name.Size, name.BackgroundColor3, name.TextColor3 = UDim2.fromScale(1, 1), palette.Ink, palette.Cream
					name.Text, name.TextScaled, name.Parent = "SCAN", true, screen
					tool.Activated:Connect(function()
						if not player.Character or tool.Parent ~= player.Character or getPlot(player) ~= plot
							or not profiles[player] or not profiles[player].upgrades.CargoAnalyzer then return end
						player:SetAttribute("ClaimFeedback", string.format("Exchange: %d Scrap ready · latest sale: %d Scrap",
							plot.Pending, plot.LastCargoSale or 0))
					end)
					plot.Analyzer = tool
					tool.Parent = backpack
					player.Character:FindFirstChildOfClass("Humanoid"):EquipTool(tool)
					player:SetAttribute("ClaimFeedback", "Cargo Analyzer equipped. Use it to read the exchange from anywhere.")
				end)
				table.insert(plot.FloorDetails[key], issue)
			end
		end
		for _, floorPlan in config.Expansion do
			local level, key = floorPlan.Number, floorPlan.Access
			local deckY = 12.4 + 12 * (level - 2)
			local tone = floorPlan.Color:Lerp(gold, .20)
			local entry = station(plot, key .. "Pad", Vector3.new(19, deckY - 11.89, 33),
				Vector3.new(5.5, .22, 5.5), tone)
			plot.Purchases[key] = prompt(entry, config.Names[key], "Locked")
			for index, row in floorPlan.Nodes do
				local node, name, _, effect, amount, speed = table.unpack(row)
				local front = index <= 6
				local x = -32 + ((index - 1) % 6) * 9.2
				local pad = station(plot, node .. "Pad", Vector3.new(x, deckY + .11, if front then 27 else 40),
					Vector3.new(5, .22, 5), tone)
				plot.Purchases[node] = prompt(pad, name, "Locked")
				local z = if front then 20 else 47
				local height = if effect == "Routing" or effect == "Capstone" then 3.4
					elseif effect == "Speed" or effect == "Display" then 1.3 else 1.85
				local width = if effect == "Lamp" then 2.6 elseif effect == "Arsenal" or effect == "Speed" then 5.5 else 4.5
				local depth = if effect == "Lamp" then 2.6 elseif effect == "Arsenal" then 2.5 else 3.6
				local machine = station(plot, node .. "Module", Vector3.new(x, deckY + height / 2, z), Vector3.new(width, height, depth), tone)
				machine.CanCollide, machine.CanTouch, machine.CanQuery = false, false, false
				Art.station(machine, gold)
			local top = Art.processHead(machine, effect, tone:Lerp(palette.Ink, .25), gold)
			local readout = machineReadout(machine, name .. "\n" .. config.Benefits[node], if front then Enum.NormalId.Back else Enum.NormalId.Front)
				local pieces = {machine, readout.Parent}
				plot.FloorDetails[node] = pieces
				for _, piece in machine:GetDescendants() do
					if piece:IsA("BasePart") then table.insert(pieces, piece) end
				end
				if effect == "Routing" then bindRouting(plot, node, machine, readout, amount, speed) end
				if effect == "Lamp" or effect == "Capstone" then
					local lamp = Instance.new("PointLight")
					lamp.Color, lamp.Range, lamp.Brightness, lamp.Enabled = tone, 15, 1.1, false
					lamp.Parent = top
					table.insert(pieces, lamp)
				end
				for _, piece in pieces do
					if piece:IsA("BasePart") then piece.Transparency = 1 else piece.Enabled = false end
				end
			end
		end
		for key, ui in plot.Purchases do
			ui.MaxActivationDistance = 6.5
			ui.RequiresLineOfSight = false
			plot.PurchaseLabels[key] = panel(ui.Parent, string.upper(config.Names[key]) .. "\n" .. config.Benefits[key], Enum.NormalId.Top)
			local label = plot.PurchaseLabels[key]
			local pad = ui.Parent
			Art.detail(pad, "PadRim", pad.CFrame * CFrame.new(0, -.035, 0),
				Vector3.new(pad.Size.X + .32, .14, pad.Size.Z + .32), pad.Color:Lerp(palette.Cream, .4), Enum.Material.SmoothPlastic)
			label.BackgroundColor3, label.TextColor3 = ui.Parent.Color:Lerp(Color3.new(), .44), Color3.new(1, 1, 1)
			label.Parent.LightInfluence = 0
			local rounded = Instance.new("UICorner")
			rounded.CornerRadius, rounded.Parent = UDim.new(.14, 0), label
			local stroke = Instance.new("UIStroke")
			stroke.ApplyStrokeMode, stroke.Color = Enum.ApplyStrokeMode.Border, ui.Parent.Color:Lerp(Color3.new(1, 1, 1), .5)
			stroke.Thickness, stroke.Parent = 4, label
			setPad(ui, plot.PurchaseLabels[key], false)
		end
		local armed = {}
		plot.RebirthArmed = armed
		plot.RebirthPrompts = {}
		local function rebirthPlayer(p, rebirthPrompt, floorNumber)
			if not authorized(p, plot, rebirthPrompt) then return end
			local profile = profiles[p]
			local capstone, cost, topFloor = config.rebirthRequirement(profile.rebirths)
			if floorNumber ~= topFloor or not profile.upgrades[capstone] or profile.wallet < cost or (profile.rebirths or 0) >= 1000 then
				p:SetAttribute("ClaimFeedback", "Rebirth requires " .. config.Names[capstone] .. " and " .. cost .. " Scrap.")
				return
			end
			local now = os.clock()
			if not armed[p.UserId] or now > armed[p.UserId] then
				armed[p.UserId] = now + 8
				local nextFloor = if topFloor < 5 then " Floor " .. (topFloor + 1) .. " becomes eligible." else " Floor 5 stays eligible."
				p:SetAttribute("ClaimFeedback", "Confirm within 8 seconds. Construction resets. Keep pets and trails, gain +20% output." .. nextFloor)
				return
			end
			armed[p.UserId] = nil
			clearCargo(plot)
			plot.ResetRunDevices()
			profile.rebirths = (profile.rebirths or 0) + 1
			profile.wallet, profile.upgrades, plot.Pending, plot.FractionalScrap = config.RebirthStarterCash, {}, 0, 0
			if onRebirth then onRebirth(p) end
			publish(plot)
			if p.Character then p.Character:PivotTo(plot.Spawn) end
			p:SetAttribute("ClaimFeedback", "Rebirth complete. Build toward Floor " .. math.min(topFloor + 1, 5) .. ".")
		end
		for floorNumber = 2, 5 do
			local offset = if floorNumber == 2 then Vector3.new(-20, 14, 52)
				else Vector3.new(18, 13.9 + 12 * (floorNumber - 2), 51)
			local rebirth = station(plot, "RebirthConsole", offset, Vector3.new(5, 3, 4), gold)
			Art.station(rebirth, teal)
			panel(rebirth, "REBIRTH\n+20% OUTPUT · 25 STARTER SCRAP", Enum.NormalId.Top)
			local rebirthPrompt = prompt(rebirth, "Rebirth · resets construction", "Rebirth")
			rebirthPrompt.RequiresLineOfSight = false
			plot.RebirthPrompts[floorNumber] = rebirthPrompt
			Art.setBuilt(rebirth, false)
			rebirthPrompt.Triggered:Connect(function(player) rebirthPlayer(player, rebirthPrompt, floorNumber) end)
		end
		construction(plot, {})
		plot.Collector.Triggered:Connect(function(p)
			if not authorized(p, plot, plot.Collector) then return end
			local taken = collect(plot, p)
			p:SetAttribute("ClaimFeedback", if taken > 0 then "+" .. taken .. " Scrap collected. Find your next pad on the purchase deck."
				elseif plot.Pending > 0 then "Your Scrap wallet is full." else "No Scrap ready to collect.")
		end)
		for key, ui in plot.Purchases do
			ui.Triggered:Connect(function(p)
				if not authorized(p, plot, ui) then return end
				local profile = profiles[p]
				if not config.canPurchase(profile.upgrades, key, profile.rebirths) then
					p:SetAttribute("ClaimFeedback", "Complete earlier construction stages first.")
					return
				end
				local price = math.ceil(config.Prices[key] * costRate)
				if profile.upgrades[key] or profile.wallet < price then
					p:SetAttribute("ClaimFeedback", if profile.upgrades[key] then "Already installed." else "You need " .. (price - profile.wallet) .. " more Scrap.")
					return
				end
				profile.wallet -= price
				if not p:GetAttribute("PlaytestPreset") then
					p:SetAttribute("ScrapSpent", (p:GetAttribute("ScrapSpent") or 0) + price)
				end
				profile.upgrades[key] = true
				publish(plot)
				local nextHint = if key == "Production" then " Egg Incubator purchase available."
					elseif key == "Reactor" then " Stairs and deck purchase available."
					elseif key == "ArsenalBench" then " At the ARSENAL counter, use Open Arsenal to choose a weapon."
					else ""
				p:SetAttribute("ClaimFeedback", config.Names[key] .. " installed. " .. config.Benefits[key] .. nextHint)
			end)
		end
	end

	task.spawn(function()
		local tick = 0
		while true do
			task.wait(config.TickSeconds)
			tick += 1
			for _, plot in plots do
				local profile = plot.Owner and profiles[plot.Owner]
				local active = profile and profile.upgrades.StarterFactory and not paused
				if active then
					local baseline, refinery, speed, tiers=ProductionModel.estimate(config,profile.upgrades,profile.rebirths or 0,plot.ExpressRouting)
					local stage=(tick-1)%tiers
					local factor=productionRate*(if incomeMultiplier then incomeMultiplier(plot.Owner) else 1)
					local earned=baseline*factor
					dropCargo(plot, plot.Owner, profile, CargoRoutes.GroundDropperZ[stage+1], earned, speed, Color3.fromHSV(.24 + stage * .14, .68, 1), stage + 1)
					if refinery > 0 then
						dropCargo(plot,plot.Owner,profile,8,refinery*factor,speed,plot.Theme[2],2,true)
					end
				end
			end
		end
	end)

	local function inspect(player)
		local profile = profiles[player]
		local plot = getPlot(player)
		return {
			wallet = profile and profile.wallet or 0,
			pending = plot and plot.Pending or 0,
			plot = plot and plot.Name or "",
			upgrades = profile and table.clone(profile.upgrades) or {},
		}
	end

	local function command(action, target, payload)
		if action == "pauseProduction" or action == "pauseCombat" then
			if typeof(payload.enabled) ~= "boolean" then return false, "Expected a toggle value." end
			if action == "pauseProduction" then paused = payload.enabled else combatPaused = payload.enabled end
			return true, "Server setting changed."
		end
		if action == "productionRate" or action == "costRate" then
			local amount = payload.amount
			if typeof(amount) ~= "number" or not (amount >= .2 and amount <= 10) then return false, "Multiplier must be 0.2–10." end
			if action == "productionRate" then productionRate = amount else costRate = amount end
			for _, plot in plots do publish(plot) end
			return true, "Server multiplier updated."
		end
		local profile = target and profiles[target]
		local plot = target and getPlot(target)
		if not profile then return false, "Target profile unavailable." end
		local before = inspect(target)
		if action == "grantCash" or action == "deductCash" or action == "setCash" then
			local amount = payload.amount
			if typeof(amount) ~= "number" or not (amount >= 0 and amount <= config.MaxWallet and amount % 1 == 0) then return false, "Invalid Scrap amount." end
			if action == "grantCash" then profile.wallet = math.min(config.MaxWallet, profile.wallet + amount)
			elseif action == "deductCash" then profile.wallet = math.max(0, profile.wallet - amount)
			else profile.wallet = amount end
		elseif action == "grantUpgrade" then
			if not config.Prices[payload.upgrade] then return false, "Invalid upgrade." end
			profile.upgrades[payload.upgrade] = true
		elseif action == "clearPending" or action == "resetPlot" then
			if not plot then return false, "No owned plot." end
			plot.Pending = 0
			if action == "resetPlot" then
				clearCargo(plot)
				plot.ResetRunDevices()
				plot.FractionalScrap = 0
				table.clear(profile.upgrades)
			end
		elseif action == "preset" then
			if not game:GetService("RunService"):IsStudio() then return false, "Presets require Studio." end
			local preset = payload.preset
			if preset ~= "fresh" and preset ~= "first" and preset ~= "upgraded" and preset ~= "sparring" then return false, "Unknown preset." end
			profile.wallet = if preset == "fresh" or preset == "first" then 25 else 100
			table.clear(profile.upgrades)
			if preset == "upgraded" then
				for _, upgrade in config.Order do
					if (profile.rebirths or 0) >= (config.MinimumRebirth[upgrade] or 0) then profile.upgrades[upgrade] = true end
				end
			end
			if plot then
				clearCargo(plot)
				plot.ResetRunDevices()
				plot.Pending, plot.FractionalScrap = 0, 0
			end
		elseif action == "rollback" then
			local old, expected = payload.before, payload.after
			if typeof(old) ~= "table" or typeof(expected) ~= "table" or before.plot ~= expected.plot then
				return false, "State changed since the snapshot."
			end
			local walletChanged = old.wallet ~= expected.wallet
			local pendingChanged = old.pending ~= expected.pending
			if (walletChanged and before.wallet ~= expected.wallet) or (pendingChanged and before.pending ~= expected.pending) then
				return false, "Balance changed since the snapshot."
			end
			for key in config.Prices do
				if old.upgrades[key] ~= expected.upgrades[key] and before.upgrades[key] ~= expected.upgrades[key] then
					return false, "Upgrade changed since the snapshot."
				end
			end
			if walletChanged then profile.wallet = old.wallet end
			for key in config.Prices do
				if old.upgrades[key] ~= expected.upgrades[key] then profile.upgrades[key] = old.upgrades[key] end
			end
			if plot and pendingChanged then plot.Pending = old.pending end
		else
			return false, "Unknown economy command."
		end
		if plot then publish(plot) else target:SetAttribute("ScrapCash", profile.wallet) end
		return true, "Updated " .. target.Name, before, inspect(target)
	end

	return {
		publish = publish,
		collect = collect,
		inspect = inspect,
		command = command,
		isCombatPaused = function() return combatPaused end,
		resetPlot = function(plot)
			table.clear(plot.RebirthArmed)
			plot.Pending = 0
			plot.FractionalScrap = 0
			plot.ResetRunDevices()
			construction(plot, {})
			for _, rebirthPrompt in plot.RebirthPrompts do Art.setBuilt(rebirthPrompt.Parent, false) end
			plot.Generator.Color = Color3.fromRGB(255, 174, 72)
			clearCargo(plot)
			plot.ExchangeLabel.Text = "SCRAP EXCHANGE"
			for _, pieces in plot.FloorDetails do
				for _, piece in pieces do
					if piece:IsA("BasePart") then piece.Transparency, piece.CanCollide, piece.CanQuery = 1, false, false
					elseif piece:IsA("Light") or piece:IsA("SurfaceGui") or piece:IsA("ProximityPrompt") then piece.Enabled = false end
				end
			end
			publishCollector(plot)
			plot.LastLabelWallet, plot.LastLabelCost = nil, nil
			for key, ui in plot.Purchases do
				setPad(ui, plot.PurchaseLabels[key], false)
				plot.PurchaseLabels[key].Text = string.upper(config.Names[key]) .. "\n" .. config.Benefits[key]
			end
		end,
	}
end

return Economy
