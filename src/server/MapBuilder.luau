local Builder = {}
local Art = require(script.Parent.FactoryArt)
local palette = require(game:GetService("ReplicatedStorage").Shared.VisualTheme)
local expansion = require(game:GetService("ReplicatedStorage").Shared.ExpansionFloors)
local steel, concrete, amber = palette.Ink, palette.Cream, palette.Gold

local function part(parent, name, size, frame, color, shape)
	local p = Instance.new("Part")
	p.Name, p.Size, p.CFrame, p.Color = name, size, frame, color
	p.Anchored = true
	p.Material = Enum.Material.SmoothPlastic
	if shape then p.Shape = shape end
	p.Parent = parent
	return p
end

local function sign(partInstance, message, color)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromScale(17, 4.2)
	gui.StudsOffsetWorldSpace = Vector3.new(0, 3.3, 0)
	gui.MaxDistance = 90
	gui.Parent = partInstance
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = steel
	label.BackgroundTransparency = 0.15
	label.TextColor3 = color
	label.Text, label.TextWrapped = message, true
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
	local inset = Instance.new("UIPadding")
	inset.PaddingLeft, inset.PaddingRight = UDim.new(.06, 0), UDim.new(.06, 0)
	inset.PaddingTop, inset.PaddingBottom = UDim.new(.08, 0), UDim.new(.08, 0)
	inset.Parent = label
	local corners = Instance.new("UICorner")
	corners.CornerRadius, corners.Parent = UDim.new(.16, 0), label
	return label
end

local function paint(parent, name, frame, size, color)
	return Art.detail(parent, name, frame, size, color, Enum.Material.SmoothPlastic)
end

local function supportDeck(deck, frame, floorY, accent, halfWidth, halfDepth)
	for _, x in {3.2 - halfWidth, halfWidth - 3.2} do
		for _, z in {4.4 - halfDepth, halfDepth - 4.4} do
			local column = frame * CFrame.new(x, floorY - 6.4, z)
			paint(deck, "StructuralColumn", column, Vector3.new(1.45, 10.8, 1.45), steel:Lerp(accent, .25))
			for _, height in {-5.3, 5.3} do
				paint(deck, "ColumnCollar", column * CFrame.new(0, height, 0), Vector3.new(2.25, .35, 2.25), accent)
			end
		end
	end
end

local function roofFloor(model, group, frame, footprint, level, floorY, shade, accent, shaft)
	local w, d = footprint.X * .5, footprint.Y * .5
	local left, right, front, back = shaft.Left, shaft.Right, shaft.Front, shaft.Back
	local function built(name, size, x, y, z, color)
		local item = part(model, name, size, frame * CFrame.new(x, y, z), color)
		table.insert(group, item)
		return item
	end
	local deckName = if level == 2 then "UpperDeck" else "ExpansionDeck" .. level
	local deck
	for index, bounds in {{-w, left, -d, d}, {left, right, -d, front}, {left, right, back, d}, {right, w, -d, d}} do
		local x0, x1, z0, z1 = table.unpack(bounds)
		local regions = if index == 1 and level == 3 then {
			{x0,19,z0,z1},{19,25,z0,-45},{19,25,-39,z1},{25,x1,z0,z1},
		} else {bounds}
		for sub, region in regions do
			local a,b,c,e=table.unpack(region)
			local slab = built(if index == 1 and sub == 1 then deckName else "RoofSection" .. level,
				Vector3.new(b-a,1,e-c),(a+b)/2,floorY-.5,(c+e)/2,shade)
			if index == 1 and sub == 1 then deck = slab end
		end
	end
	if level == 3 then
		part(model,"CargoShaftCover",Vector3.new(6,1,6),frame*CFrame.new(22,floorY-.5,-42),shade)
	end
	supportDeck(deck, frame, floorY, accent, w, d)
	for _, z in {-d + .23, d - .23} do
		built("RoofPerimeterRail", Vector3.new(footprint.X, 2.75, .45), 0, floorY + 1.375, z, steel)
		paint(deck, "RoofFascia", frame * CFrame.new(0, floorY - .3, z), Vector3.new(footprint.X, .37, .46), accent)
	end
	for _, x in {-w + .23, w - .23} do
		built("RoofPerimeterRail", Vector3.new(.45, 2.75, footprint.Y - .9), x, floorY + 1.375, 0, steel)
		paint(deck, "RoofFascia", frame * CFrame.new(x, floorY - .3, 0), Vector3.new(.46, .37, footprint.Y - .92), accent)
	end
	local railY = floorY + 1.35
	if shaft.Entry ~= "left" then
		built("StairwellGuard", Vector3.new(.4, 2.7, back - front), left - .2, railY, (front + back) / 2, steel)
	end
	built("StairwellGuard", Vector3.new(.4, 2.7, back - front), right + .2, railY, (front + back) / 2, steel)
	if shaft.Entry ~= "front" then
		built("StairwellGuard", Vector3.new(right - left + .8, 2.7, .4), (left + right) / 2, railY, front - .2, steel)
	end
	if shaft.Entry ~= "back" then
		built("StairwellGuard", Vector3.new(right - left + .8, 2.7, .4), (left + right) / 2, railY, back + .2, steel)
	end
	paint(deck, "FloorApproachStripe", frame * CFrame.new(0, floorY + .03, -27), Vector3.new(2.5, .024, 49), accent)
	for _, x in {-21, 15} do
		for _, z in {-25, 29} do
			local lens = paint(deck, "CeilingLight", frame * CFrame.new(x, floorY - 1.06, z), Vector3.new(3.8, .12, 1.1), concrete)
			local light = Instance.new("SurfaceLight")
			light.Face, light.Range, light.Angle = Enum.NormalId.Bottom, 24, 126
			light.Color, light.Brightness, light.Parent = concrete, .8, lens
		end
	end
	return deck
end

local function district(parent, frame, primary, light)
	-- Keep the service fixtures beside the approach and the center lane clear.
	for _, side in {-1, 1} do
		local base = frame * CFrame.new(side * 12, 0, -76)
		paint(parent, "DistrictLightFoot", base * CFrame.new(0, .23, 0), Vector3.new(3.6, .46, 3.6), steel)
		paint(parent, "DistrictLightColumn", base * CFrame.new(0, 2.4, 0), Vector3.new(.9, 4.6, .9), primary)
		paint(parent, "DistrictLightLens", base * CFrame.new(0, 4.6, 0), Vector3.new(1.6, .45, 1.6), light)
	end
end

local function powerDirectory(root, lobby, config)
	local position = lobby.CFrame:PointToWorldSpace(Vector3.new(-13.2, 3.6, -9.5))
	local offset = position - lobby.Position
	local frame = CFrame.lookAt(position, position + Vector3.new(offset.X, 0, offset.Z))
	local board = paint(root, "PowerDirectory", frame, Vector3.new(11.6, 6.8, .55), steel)
	for _, side in {-1, 1} do
		paint(board, "DirectoryLeg", frame * CFrame.new(side * 4.4, -2.7, -.21), Vector3.new(.55, 5.3, .65), palette.Teal)
	end
	paint(board, "DirectoryCap", frame * CFrame.new(0, 3.38, .33), Vector3.new(11.8, .20, .25), amber)
	local face = Instance.new("SurfaceGui")
	face.Face, face.LightInfluence, face.CanvasSize = Enum.NormalId.Back, 0, Vector2.new(960, 560)
	face.Parent = board
	local function textLabel(name, caption, x, y, width, height, textSize)
		local item = Instance.new("TextLabel")
		item.Name, item.Text = name, caption
		item.Position, item.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(width, height)
		item.BackgroundTransparency, item.TextColor3 = 1, concrete
		item.Font, item.TextSize = Enum.Font.GothamBold, textSize
		item.Parent = face
		return item
	end
	local title = textLabel("Title", "POWER DISTRICTS", 42, 23, 870, 54, 44)
	title.TextXAlignment = Enum.TextXAlignment.Left
	local ring = Instance.new("Frame")
	ring.Name, ring.AnchorPoint = "DistrictRing", Vector2.new(.5, .5)
	ring.Position, ring.Size = UDim2.fromOffset(235, 306), UDim2.fromOffset(326, 326)
	ring.BackgroundColor3 = steel:Lerp(palette.Teal, .32)
	ring.Parent = face
	local rounded = Instance.new("UICorner")
	rounded.CornerRadius, rounded.Parent = UDim.new(1, 0), ring
	textLabel("Arena", "REACTOR\nCROWN", 179, 269, 112, 74, 24)
	for index, entry in config.Plots do
		local marker = textLabel("District" .. index, string.format("%02d", index),
			209 + entry[2] * .625, 280 + entry[3] * .625, 52, 52, 25)
		marker.BackgroundTransparency, marker.BackgroundColor3 = 0, palette.Plots[index][3]
		marker.TextColor3 = steel
		local corners = Instance.new("UICorner")
		corners.CornerRadius, corners.Parent = UDim.new(.30, 0), marker
		local legend = textLabel("Power" .. index, string.format("%02d   %s", index, entry[1]), 455, 92 + (index - 1) * 54, 470, 50, 34)
		legend.TextXAlignment, legend.TextColor3 = Enum.TextXAlignment.Left, palette.Plots[index][3]
	end
	local you = textLabel("YouAreHere", "YOU", 216 + lobby.Position.X * .625, 291 + lobby.Position.Z * .625, 38, 30, 16)
	you.BackgroundTransparency, you.BackgroundColor3, you.TextColor3 = 0, amber, steel
	for _, side in {-1, 1} do
		paint(lobby, "SpawnTrim", lobby.CFrame * CFrame.new(side * 8.2, .53, 0),
			Vector3.new(.46, .06, 17.6), palette.Teal)
	end
end

function Builder.build(config)
	local lighting = game:GetService("Lighting")
	lighting.ClockTime, lighting.Brightness, lighting.ExposureCompensation = 14, 2.35, .12
	lighting.Ambient = Color3.fromRGB(141, 129, 151)
	lighting.OutdoorAmbient = Color3.fromRGB(175, 169, 183)
	assert(#config.Plots == 8, "Expected eight plots")
	local templateGround = workspace:FindFirstChild("Baseplate")
	if templateGround and templateGround:IsA("BasePart") and templateGround.Anchored
		and templateGround.Position:FuzzyEq(Vector3.new(0, -templateGround.Size.Y / 2, 0))
		and templateGround.Size.X >= 720 and templateGround.Size.Z >= 720 then
		-- The generated ground owns this surface during play.
		templateGround.Transparency = 1
		templateGround.CanCollide, templateGround.CanTouch, templateGround.CanQuery = false, false, false
		templateGround.CastShadow = false
		for _, layer in templateGround:GetDescendants() do
			if layer:IsA("Decal") then layer.Transparency = 1 end
		end
	end
	local root = Instance.new("Folder")
	root.Name = "DeadzonePhase1"
	for index = 0, 7 do
		local frame = CFrame.Angles(0, index * math.pi / 4, 0) * CFrame.new(26, .25, -94)
		local accent = Color3.fromHSV(index / 8, .65, .95)
		local plinth = Art.detail(root, "GardenPlinth", frame, Vector3.new(6, .45, 6),
			Color3.fromRGB(94, 122, 165), Enum.Material.SmoothPlastic)
		for _, stem in {-1, 0, 1} do
			local bloom = Art.detail(root, "CrystalBloom", plinth.CFrame * CFrame.new(stem * 1.4, 1.9 - math.abs(stem)*.3, 0)
				* CFrame.Angles(0, math.pi/4, stem*.25), Vector3.new(.8, 3, .8), accent, Enum.Material.Glass)
			bloom.CastShadow = false
		end
	end
	root:SetAttribute("DeadzoneGenerated", true)
	part(root, "Ground", Vector3.new(720, 12, 720), CFrame.new(0, -6, 0), palette.Sand)
	for index = 0, 15 do
		local frame = CFrame.Angles(0, index * math.pi / 8, 0) * CFrame.new(0, 0, -333)
		local height = 8 + (index % 4) * 3
		local ridge = paint(root, "DistantReactorRock", frame * CFrame.new(-11, height * .44, 0)
			* CFrame.Angles(0, .38, -.24), Vector3.new(17, height, 13), palette.Sand:Lerp(steel, .25))
		paint(root, "DistantReactorRock", ridge.CFrame * CFrame.new(16, -2, -7)
			* CFrame.Angles(0, -.66, .48), Vector3.new(13, height * .74, 10), palette.Sand:Lerp(palette.Teal, .28))
	end
	local function disc(name, diameter, height, y, color)
		return part(root, name, Vector3.new(height, diameter, diameter),
			CFrame.new(0, y, 0) * CFrame.Angles(0, 0, math.pi / 2), color, Enum.PartType.Cylinder)
	end
	disc("Arena", 145, 0.3, 0.15, concrete)
	disc("ReactorCrown", 34, 4, 2, steel)
	disc("CaptureMarker", 28, 0.12, 4.06, amber)
	local tower = part(root, "ReactorBeacon", Vector3.new(5, 20, 5), CFrame.new(0, 14, 0), palette.Teal)
	local beacon = Art.mesh("ReactorBeacon", "BeaconMesh", tower.CFrame, Vector3.new(5.8, 20, 5.8), palette.Teal)
	if beacon then
		-- The visible inner column is the arena's collision and raycast surface.
		tower.Size = Vector3.new(2.4, 20, 2.4)
		beacon.Parent = tower
	else
		Art.station(tower, Color3.fromRGB(112, 225, 255))
	end
	local mastTop = Art.detail(tower, "BeaconCrown", CFrame.new(0, 24.7, 0), Vector3.new(6, 1.4, 6), amber, Enum.Material.SmoothPlastic)
	sign(mastTop, "REACTOR CROWN", palette.Cream)
	for i = 0, 3 do
		local rotation = CFrame.Angles(0, i * math.pi / 2, 0)
		part(root, "ReactorRamp", Vector3.new(9, 0.6, 17),
			rotation * CFrame.new(0, 2, -23) * CFrame.Angles(-math.atan2(4, 16), 0, 0), concrete)
	end
	for i = 0, 7 do
		local radial = CFrame.Angles(0, (i + 0.5) * math.pi / 4, 0)
		local cover = part(root, "ArenaCover", Vector3.new(12, 5, 4), radial * CFrame.new(0, 2.8, -43), palette.Teal)
		Art.station(cover, amber)
		Art.detail(root, "ReactorPerimeterTick", radial * CFrame.new(0, .32, -69),
			Vector3.new(10, .03, 2), palette.Teal, Enum.Material.SmoothPlastic)
		paint(cover, "CoverBand", cover.CFrame * CFrame.new(0, -.8, -2.055),
			Vector3.new(10.7, .42, .11), palette.Cream)
	end
	for _, objective in ipairs({{"Supply Yard", 64}, {"Quarantine Relay", -64}}) do
		local marker = part(root, objective[1], Vector3.new(10, 1, 10), CFrame.new(objective[2], 0.65, 0), steel)
		Art.station(marker, palette.Teal)
	end
	local plots = {}
	local names = {}
	for index, info in ipairs(config.Plots) do
		local name, x, z = table.unpack(info)
		local theme = palette.Plots[index]
		local accent = theme[2]
		assert(not names[name], "Duplicate plot name")
		names[name] = true
		local pivot = Vector3.new(x, 0, z)
		for other = 1, index - 1 do
			local entry = config.Plots[other]
			assert((pivot - Vector3.new(entry[2], 0, entry[3])).Magnitude > config.Footprint.Magnitude, "Plot footprints overlap")
		end
		local frame = CFrame.lookAt(pivot, Vector3.zero)
		local model = Instance.new("Model")
		local construction = {Walls = {}, UpperAccess = {}}
		model.Name = name
		model:SetAttribute("ThemeIndex", index)
		model.Parent = root
		local function localPart(label, size, lx, y, lz, color)
			local item = part(model, label, size, frame * CFrame.new(lx, y, lz), color)
			local group = if label:find("Wall") or label == "SpawnScreen" then construction.Walls
				elseif label:sub(1, 5) == "Upper" and label ~= "UpperDirectory" then construction.UpperAccess else nil
			if group then table.insert(group, item) end
			return item
		end
		local width, depth = config.Footprint.X, config.Footprint.Y
		localPart("Foundation", Vector3.new(width, 0.4, depth), 0, 0.2, 0, concrete:Lerp(theme[3], .2))
		local trim = localPart("FactoryRunner", Vector3.new(2.8, .035, 91), -1, .423, -3, theme[3])
		trim.CanCollide, trim.CanTouch, trim.CanQuery, trim.CastShadow = false, false, false, false
		local reach = pivot.Magnitude - depth / 2 - 70
		localPart("Approach", Vector3.new(16, 0.2, reach), 0, 0.1, -depth / 2 - reach / 2, concrete)
		paint(model, "RouteStripe", frame * CFrame.new(0, .23, -depth / 2 - reach / 2),
			Vector3.new(.65, .045, reach), accent)
		district(model, frame, accent, theme[3])
		for _, side in ipairs({-1, 1}) do
			local wall = localPart("SideWall", Vector3.new(2, 12, depth), side * 53, 6.4, 0, steel)
			paint(wall, "WallCap", wall.CFrame * CFrame.new(0, 5.79, 0), Vector3.new(2.2, .32, depth - .4), accent)
			paint(wall, "WallRibbon", wall.CFrame * CFrame.new(-side * 1.04, -2.2, 0),
				Vector3.new(.08, .8, depth - 4), theme[3])
			local front = localPart("FrontWall", Vector3.new(43, 12, 2), side * 30.5, 6.4, -57, steel)
			paint(front, "WallCap", front.CFrame * CFrame.new(0, 5.79, 0), Vector3.new(42.8, .32, 2.2), accent)
			localPart("GatePillar", Vector3.new(2, 14, 3), side * 8, 7.4, -57, accent)
			localPart("SpawnScreen", Vector3.new(2, 7, 15), side * 11, 3.9, 41, steel)
		end
		localPart("RearWall", Vector3.new(11, 12, 2), -46.5, 6.4, 58, steel)
		localPart("RearWall", Vector3.new(81, 12, 2), 11.5, 6.4, 58, steel)
		local gate = localPart("GateHeader", Vector3.new(23, 3.2, 3), 0, 12.2, -57, steel)
		for _, y in {-1.48, 1.48} do
			paint(gate, "GateFasciaTrim", gate.CFrame * CFrame.new(0, y, -1.54),
				Vector3.new(23, .24, .18), theme[3])
		end
		local gateSign = Instance.new("SurfaceGui")
		gateSign.Face, gateSign.LightInfluence, gateSign.CanvasSize = Enum.NormalId.Front, 0, Vector2.new(720, 100)
		gateSign.Parent = gate
		local gateTitle = Instance.new("TextLabel")
		gateTitle.Name = "PowerName"
		gateTitle.Size, gateTitle.Position = UDim2.fromScale(.71, .5), UDim2.fromScale(.145, .07)
		gateTitle.BackgroundTransparency, gateTitle.TextColor3 = 1, concrete
		gateTitle.Font, gateTitle.TextScaled, gateTitle.Text = Enum.Font.GothamBold, true, string.format("%02d   %s", index, string.upper(name))
		gateTitle.Parent = gateSign
		local gateStatus = gateTitle:Clone()
		gateStatus.Name, gateStatus.TextColor3 = "Ownership", theme[3]
		gateStatus.Size, gateStatus.Position = UDim2.fromScale(.71, .32), UDim2.fromScale(.145, .58)
		gateStatus.Text, gateStatus.Parent = "Unclaimed", gateSign
		for _, side in {-1, 1} do
			local insignia = gate.CFrame * CFrame.new(side * 9.8, 0, -1.66) * CFrame.Angles(0, math.pi, 0)
			Art.crest(gate, insignia, 1.28, index)
		end
		local direction = paint(model, "ClaimDirection", frame * CFrame.new(-8, 5, -58.57),
			Vector3.new(2.8, 2, .12), steel)
		local directionGui = Instance.new("SurfaceGui")
		directionGui.Face, directionGui.LightInfluence = Enum.NormalId.Front, 0
		directionGui.CanvasSize, directionGui.Parent = Vector2.new(210, 150), direction
		local directionText = gateTitle:Clone()
		directionText.Position, directionText.Size = UDim2.fromOffset(0, 0), UDim2.fromScale(1, 1)
		directionText.Text, directionText.TextWrapped, directionText.Parent = "CLAIM\nINSIDE", true, directionGui
		local terminal = localPart("ClaimTerminal", Vector3.new(4, 4, 3), -6.5, 2.4, -51, accent)
		paint(model, "ClaimBayOutline", frame * CFrame.new(-6.5, .427, -51), Vector3.new(5.3, .035, 4.3), steel)
		for step = 0, 2 do
			paint(model, "ClaimPathLight", frame * CFrame.new(-3.4 - step * .4, .438, -55.1 + step * .9),
				Vector3.new(.5, .04, .72), theme[3])
		end
		Art.station(terminal, theme[3])
		local label = sign(terminal, "CLAIM TERMINAL\nUnclaimed", concrete)
		label.Parent.Size, label.Parent.MaxDistance = UDim2.fromScale(13, 3.4), 31
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText, prompt.ObjectText = "Claim base", name
		prompt.MaxActivationDistance = 10
		prompt.Parent = terminal
		localPart("SpawnPad", Vector3.new(14, 0.2, 12), 0, 0.5, 38, accent)
		local upper = roofFloor(model, construction.UpperAccess, frame, config.Footprint, 2, 12.4,
			Color3.fromRGB(216, 225, 234), theme[2], {Left=25, Right=50.1, Front=42.35, Back=51.65, Entry="left"})
		paint(upper, "UpperRunner", frame * CFrame.new(-7, 12.43, 41), Vector3.new(61.4, .035, 2.8), theme[3])
		paint(upper, "UpperRefineryStripe", frame * CFrame.new(-7, 12.43, 30), Vector3.new(61.4, .035, .55), amber)
		for step = 1, 24 do
			local height = step / 2
			localPart("UpperStair", Vector3.new(1, height, 8), 49.5 - step, .4 + height / 2, 47, concrete)
		end
		for _, z in {42.75, 51.25} do
			local angle = math.atan(.5)
			table.insert(construction.UpperAccess, part(model, "StairRail", Vector3.new(math.sqrt(24 ^ 2 + 12 ^ 2), .4, .4),
				frame * CFrame.new(37, 8.4, z) * CFrame.Angles(0, 0, -angle), accent))
		end
		local forgeGate = localPart("UpperForgeGate", Vector3.new(8.8, 2.5, .5), 30, 13.65, 18, steel)
		local upperSign = localPart("UpperDirectory", Vector3.new(4, 3, 1), 45, 2, 40, accent)
		local upperDirectory = sign(upperSign, "FLOOR TWO · REFINERY\nBuy access after Reactor Dropper", concrete)
		for _, floorPlan in expansion do
			local level = floorPlan.Number
			local floorY = 12.4 + 12 * (level - 2)
			local baseY = floorY - 12
			local color = floorPlan.Color
			local group = {}
			construction[floorPlan.Access] = group
			local function build(name, size, x, y, z, shade)
				local item = part(model, name, size, frame * CFrame.new(x, y, z), shade)
				table.insert(group, item)
				return item
			end
			local x = if level % 2 == 1 then 30 else 44
			local direction = if level % 2 == 1 then 1 else -1
			local startZ = if direction == 1 then 18 else 42
			local endZ = startZ + direction * 24
			local deck = roofFloor(model, group, frame, config.Footprint, level, floorY, concrete:Lerp(color, .30),
				color, {Left=x-4.5, Right=x+4.5, Front=18, Back=42, Entry=if direction == 1 then "back" else "front"})
			paint(deck, "FloorStripe", frame * CFrame.new(-7, floorY + .03, 34), Vector3.new(62, .025, 2), color)
			for step = 1, 24 do
				local z = startZ + direction * (step - .5)
				build("ExpansionStair", Vector3.new(8, .55, 1.05), x, baseY + step * .5 - .275, z, concrete)
			end
			for _, side in {-1, 1} do
				local rail = part(model, "ExpansionHandrail", Vector3.new(.38, .38, math.sqrt(24 ^ 2 + 12 ^ 2)),
					frame * CFrame.new(x + side * 3.88, baseY + 8, (startZ + endZ) / 2)
						* CFrame.Angles(-direction * math.atan(.5), 0, 0), color)
				table.insert(group, rail)
			end
			local directory = build("FloorDirectory", Vector3.new(5, 3.2, 1), -32, floorY + 1.6, 51, color)
			sign(directory, "FLOOR " .. level .. "\n" .. string.upper(floorPlan.Name), concrete)
		end
		local markers = Instance.new("Folder")
		markers.Name = "FutureStations"
		markers.Parent = model
		local stations = {StarterGenerator={-31,19}, ConveyorStart={-22,8}, CurrencyCollector={-13,-29},
			WeaponStation={37,-27}, AbilityStation={29,6}, DefenseTerminal={-38,-34},
			PowerCore={0,0}, UpgradeTerminal={22,30}, Stairs={42,21}}
		for station, offset in pairs(stations) do
			local marker = part(markers, station, Vector3.new(4, 0.06, 4), frame * CFrame.new(offset[1], 0.43, offset[2]), steel)
			marker.Transparency = 1
			marker.CanCollide, marker.CanTouch, marker.CanQuery = false, false, false
		end
		model.WorldPivot = frame
		plots[index] = {Name = name, Label = label, GateStatus = gateStatus, ClaimSign = directionGui, Theme = theme, Prompt = prompt, Terminal = terminal,
			Arrival = frame * CFrame.new(0, 4, -34), Spawn = frame * CFrame.new(0, 4, 38),
			Index = index, Model = model, Construction = construction, ForgeGate = forgeGate, UpperDirectory = upperDirectory}
	end
	local lobby = Instance.new("SpawnLocation")
	lobby.Name = "NeutralSpawn"
	lobby.Size = Vector3.new(18, 1, 18)
	lobby.CFrame = CFrame.lookAt(Vector3.new(53, 0.5, -128), Vector3.new(0, 0.5, -260))
	lobby.Anchored, lobby.Neutral = true, true
	lobby.Duration = 6
	lobby.Color, lobby.Material, lobby.TopSurface = amber, Enum.Material.SmoothPlastic, Enum.SurfaceType.Smooth
	lobby.Parent = root
	powerDirectory(root, lobby, config)
	local existing = workspace:FindFirstChild(root.Name)
	if existing then
		assert(existing:GetAttribute("DeadzoneGenerated") == true, "Generated map name is already in use")
		existing:Destroy()
	end
	root.Parent = workspace
	return plots, lobby.CFrame * CFrame.new(0, 4, 0)
end

return Builder
