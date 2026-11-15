local Art = {}
local palette = require(game:GetService("ReplicatedStorage").Shared.VisualTheme)
local assets = game:GetService("ServerStorage"):FindFirstChild("DeadzoneArt")

function Art.mesh(assetName, name, frame, size, color)
	local template = assets and assets:FindFirstChild(assetName)
	if not template or not template:IsA("MeshPart") or template.MeshId == "" then return nil end
	local mesh = template:Clone()
	mesh.Name, mesh.Size, mesh.CFrame, mesh.Color = name, size, frame, color
	mesh.Material, mesh.Anchored, mesh.CastShadow = Enum.Material.SmoothPlastic, true, false
	mesh.CanCollide, mesh.CanTouch, mesh.CanQuery = false, false, false
	return mesh
end

function Art.setBuilt(instance, built)
	local function update(item)
		if item:IsA("BasePart") then
			local original = item:GetAttribute("BuiltTransparency")
			if original == nil then
				original = item.Transparency
				item:SetAttribute("BuiltTransparency", original)
				item:SetAttribute("BuiltCollision", item.CanCollide)
				item:SetAttribute("BuiltQuery", item.CanQuery)
				item:SetAttribute("BuiltShadow", item.CastShadow)
			end
			local visible = built and not instance:GetAttribute("SiegeBreachOpen")
			item.Transparency = if visible then original else 1
			item.CanCollide = visible and item:GetAttribute("BuiltCollision") == true
			item.CanQuery = visible and item:GetAttribute("BuiltQuery") == true
			item.CanTouch = false
			item.CastShadow = visible and item:GetAttribute("BuiltShadow") == true
		elseif item:IsA("ProximityPrompt") or item:IsA("SurfaceGui") or item:IsA("BillboardGui")
			or item:IsA("Light") or item:IsA("ParticleEmitter") or item:IsA("Beam") or item:IsA("Trail") then
			item.Enabled = built
		elseif item:IsA("Decal") then
			local original = item:GetAttribute("BuiltTransparency")
			if original == nil then
				original = item.Transparency
				item:SetAttribute("BuiltTransparency", original)
			end
			item.Transparency = if built then original else 1
		end
	end
	update(instance)
	for _, item in instance:GetDescendants() do update(item) end
end

function Art.detail(parent, name, frame, size, color, material)
	local part = Instance.new("Part")
	part.Name, part.CFrame, part.Size, part.Color = name, frame, size, color
	part.Material = material or Enum.Material.DiamondPlate
	part.Anchored = true
	part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
	part.CastShadow = false
	part.Parent = parent
	return part
end

-- All crests face local +Z. A single geometric vocabulary works at gate and egg scale.
function Art.crest(parent, frame, unit, index)
	local theme = palette.Plots[index]
	local function glyph(name, x, y, sx, sy, angle, color, shape)
		local item = Art.detail(parent, name, frame * CFrame.new(x * unit, y * unit, 0)
			* CFrame.Angles(0, 0, angle or 0), Vector3.new(sx, sy, .23) * unit, color or theme[3], Enum.Material.SmoothPlastic)
		if shape then item.Shape = shape end
		return item
	end
	local function disc(x, y, size, color)
		local item = glyph("CrestDisc", x, y, .23, size, 0, color, Enum.PartType.Cylinder)
		item.Size = Vector3.new(.23, size, size) * unit
		item.CFrame *= CFrame.Angles(0, math.pi / 2, 0)
		return item
	end
	if index == 1 then
		glyph("Shield", 0, .2, 1.6, 1.1)
		glyph("ShieldPoint", 0, -.28, .9, .9, math.pi / 4)
		glyph("ShieldBand", 0, .36, 1.9, .25, 0, theme[2])
	elseif index == 2 then
		for blade = 0, 3 do
			local angle = blade * math.pi / 2
			glyph("FanBlade", math.cos(angle) * .55, math.sin(angle) * .55, .96, .31, angle + .44)
		end
		disc(0, 0, .56, theme[2])
	elseif index == 3 then
		for _, side in {-1, 1} do
			disc(side * .63, 0, 1, theme[3])
			local core = disc(side * .63, 0, .55, theme[2])
			core.CFrame = core.CFrame + frame.LookVector * (-.12 * unit)
		end
	elseif index == 4 then
		disc(0, 0, 1.03, theme[3])
		for ray = 0, 7 do
			local angle = ray * math.pi / 4
			glyph("SunRay", math.cos(angle) * .82, math.sin(angle) * .82, .38, .17, angle)
		end
	elseif index == 5 then
		glyph("BioVertical", 0, 0, .53, 1.73)
		glyph("BioHorizontal", 0, 0, 1.73, .48)
	elseif index == 6 then
		disc(0, -.27, 1.12, theme[3])
		disc(-.59, .36, .48, theme[3])
		disc(.48, .61, .58, theme[3])
	elseif index == 7 then
		for _, side in {-1, 1} do
			glyph("TargetSide", side * .67, 0, .23, 1.42)
			glyph("TargetBar", 0, side * .6, 1.42, .23)
		end
		disc(0, 0, .38, theme[3])
	else
		glyph("IceFacet", 0, .04, 1, 1, math.pi / 4)
		glyph("IceShard", -.78, -.28, .44, .44, math.pi / 4)
		glyph("IceShard", .78, -.28, .44, .44, math.pi / 4)
	end
end

function Art.station(base, accent)
	local model = Instance.new("Model")
	model.Name = base.Name .. "Art"
	local width, height, depth = base.Size.X, base.Size.Y, base.Size.Z
	for _, face in {-1, 1} do
		Art.detail(model, "UpperTrim", base.CFrame * CFrame.new(0, height / 2 - .14, face * (depth / 2 + .08)),
			Vector3.new(width * 1.04, .18, .16), accent, Enum.Material.SmoothPlastic)
	end
	Art.detail(model, "StatusBar", base.CFrame * CFrame.new(0, height * .24, depth / 2 + .07),
		Vector3.new(width * .58, .16, .14), palette.Cream, Enum.Material.SmoothPlastic)
	model.Parent = base
end

function Art.processHead(machine, effect, accent, light)
	local top = machine.Size.Y / 2
	local function piece(name, x, y, z, size, color, shape)
		local part = Art.detail(machine, name, machine.CFrame * CFrame.new(x, top + y, z), size, color, Enum.Material.SmoothPlastic)
		part.Shape = shape or Enum.PartType.Block
		return part
	end
	local terminal
	if effect == "Base" then
		for index = 0, 3 do
			local diameter = 1.15 + index * .62
			terminal = piece("FunnelRing", 0, .24 + index * .48, 0, Vector3.new(.48, diameter, diameter),
				if index == 3 then light else accent, Enum.PartType.Cylinder)
			terminal.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
		end
		local mouth = piece("IntakeMouth", 0, 1.93, 0, Vector3.new(.09, 2.56, 2.56), palette.Ink, Enum.PartType.Cylinder)
		mouth.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
	elseif effect == "Speed" then
		for index = -2, 2 do
			terminal = piece("DriveRoller", 0, .48, index * .58, Vector3.new(4.2, .48, .48),
				if index % 2 == 0 then accent else light, Enum.PartType.Cylinder)
		end
		for _, side in {-1, 1} do
			piece("RollerFrame", side * 2.23, .47, 0, Vector3.new(.42, .92, 2.98), palette.Ink)
		end
	elseif effect == "Lamp" then
		piece("LampStem", 0, 1.35, 0, Vector3.new(.42, 2.7, .42), palette.Ink)
		terminal = piece("LampLens", 0, 2.91, 0, Vector3.new(1.62, .75, 1.62), light, Enum.PartType.Ball)
	elseif effect == "Multiplier" then
		for _, side in {-1, 1} do
			piece("ScanArchLeg", side * 2.02, 1.42, 0, Vector3.new(.42, 2.84, 1.08), accent)
		end
		piece("ScanArchCrossbar", 0, 2.66, 0, Vector3.new(4.45, .38, 1.08), accent)
		terminal = piece("ScanStrip", 0, 2.43, 0, Vector3.new(3.35, .1, .4), light)
		piece("SampleTray", 0, .2, 0, Vector3.new(2.2, .4, 1.55), palette.Ink)
	elseif effect == "Routing" then
		for _, side in {-1, 1} do
			piece("RoutingLevers", side * 1.48, .57, 0, Vector3.new(.31, 1.14, .35), accent)
		end
		terminal = piece("RoutingScreen", 0, .52, -.15, Vector3.new(2.15, 1.04, .85), light)
		terminal.CFrame *= CFrame.Angles(math.rad(-18), 0, 0)
	elseif effect == "Arsenal" then
		piece("GearRack", 0, .22, 0, Vector3.new(3.9, .44, 1.5), palette.Ink)
		terminal = piece("GearDisplay", 0, .61, 0, Vector3.new(3.22, .38, .76), accent)
	else
		for index = -1, 1 do
			local height = if index == 0 then 2.28 else 1.32
			terminal = piece("AlloyCell", index * 1.18, height / 2, 0, Vector3.new(.94, height, .94), if index == 0 then light else accent)
		end
	end
	return terminal
end

return Art
